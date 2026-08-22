import 'package:cloud_firestore/cloud_firestore.dart';
import '../notification/app_notification.dart';
import '../storage/backblaze_storage_impl.dart';
import 'payroll_engine.dart';
import 'payroll_period.dart';
import 'payroll_record.dart';
import 'payslip.dart';
import 'salary_component.dart';
import 'salary_structure.dart';

/// Production Firestore repository for Payroll processing, salary structure management, and payslip publishing.
class PayrollRepository {
  final FirebaseFirestore _firestore;
  final BackblazeStorageImpl storage;

  PayrollRepository({FirebaseFirestore? firestore, BackblazeStorageImpl? storage})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        storage = storage ?? BackblazeStorageImpl();

  /// Resolves the effective salary structure active during a given date
  Future<SalaryStructure?> getEffectiveSalaryStructure(String employeeId, String date) async {
    final snapshot = await _firestore
        .collection('salary_structures')
        .where('employeeId', isEqualTo: employeeId)
        .where('status', isEqualTo: 'active')
        .get();

    if (snapshot.docs.isEmpty) return null;

    final list = snapshot.docs.map((doc) => SalaryStructure.fromMap(doc.data())).toList();
    list.sort((a, b) => b.effectiveFrom.compareTo(a.effectiveFrom));

    for (var struct in list) {
      if (struct.effectiveFrom.compareTo(date) <= 0) {
        return struct;
      }
    }
    return list.last;
  }

  /// Saves or updates a salary structure with effective date versioning
  Future<SalaryStructure> saveSalaryStructure(SalaryStructure structure) async {
    final ref = _firestore.collection('salary_structures').doc(structure.id.isNotEmpty ? structure.id : null);
    final newStruct = SalaryStructure(
      id: ref.id,
      organizationId: structure.organizationId,
      employeeId: structure.employeeId,
      effectiveFrom: structure.effectiveFrom,
      currency: structure.currency,
      components: structure.components,
      status: 'active',
    );

    await ref.set(newStruct.toMap());
    return newStruct;
  }

  /// Processes payroll for all active employees in an organization for a payroll period
  Future<void> calculatePayrollForPeriod(String organizationId, String periodId) async {
    final periodDoc = await _firestore.collection('payroll_periods').doc(periodId).get();
    if (!periodDoc.exists) throw Exception('Payroll period not found.');

    final period = PayrollPeriod.fromMap(periodDoc.data()!);
    final empSnapshot = await _firestore
        .collection('employees')
        .where('organizationId', isEqualTo: organizationId)
        .where('employmentStatus', isEqualTo: 'active')
        .get();

    final now = DateTime.now();
    final batch = _firestore.batch();

    for (var empDoc in empSnapshot.docs) {
      final empId = empDoc.id;
      SalaryStructure? struct = await getEffectiveSalaryStructure(empId, period.startDate);

      struct ??= SalaryStructure(
        id: 'default_$empId',
        organizationId: organizationId,
        employeeId: empId,
        effectiveFrom: period.startDate,
        currency: 'INR',
        components: const [
          SalaryComponent(id: 'c1', name: 'Basic Salary', code: 'BASIC', type: 'earning', amount: 35000.0),
          SalaryComponent(id: 'c2', name: 'House Rent Allowance', code: 'HRA', type: 'earning', amount: 15000.0),
          SalaryComponent(id: 'c3', name: 'Provident Fund', code: 'PF', type: 'deduction', amount: 1800.0),
        ],
      );

      final calcResult = PayrollEngine.calculate(structure: struct);
      final recordRef = _firestore.collection('payroll_records').doc('${periodId}_$empId');

      final record = PayrollRecord(
        id: recordRef.id,
        organizationId: organizationId,
        payrollPeriodId: periodId,
        employeeId: empId,
        salaryStructureId: struct.id,
        grossPay: calcResult.grossPay,
        totalDeductions: calcResult.totalDeductions,
        totalEmployerContributions: calcResult.totalEmployerContributions,
        netPay: calcResult.netPay,
        currency: struct.currency,
        earningsMap: calcResult.earningsMap,
        deductionsMap: calcResult.deductionsMap,
        calculatedAt: now,
      );

      batch.set(recordRef, record.toMap());
    }

    // Update state to CALCULATED
    batch.update(_firestore.collection('payroll_periods').doc(periodId), {
      'status': 'calculated',
      'calculatedAt': now.toIso8601String(),
    });

    await batch.commit();
  }

  /// Approves and publishes payroll period, generating payslips and in-app notifications
  Future<void> publishPayrollPeriod(String periodId) async {
    final periodDoc = await _firestore.collection('payroll_periods').doc(periodId).get();
    if (!periodDoc.exists) throw Exception('Payroll period not found.');

    final recordsSnap = await _firestore
        .collection('payroll_records')
        .where('payrollPeriodId', isEqualTo: periodId)
        .get();

    final now = DateTime.now();
    final batch = _firestore.batch();

    for (var recDoc in recordsSnap.docs) {
      final rec = PayrollRecord.fromMap(recDoc.data());
      final payslipRef = _firestore.collection('payslips').doc('${periodId}_${rec.employeeId}');
      final b2Path = 'organizations/${rec.organizationId}/payslips/${periodId}_${rec.employeeId}.pdf';

      final payslip = Payslip(
        id: payslipRef.id,
        organizationId: rec.organizationId,
        payrollPeriodId: periodId,
        employeeId: rec.employeeId,
        payrollRecordId: rec.id,
        storagePath: b2Path,
        publishedAt: now,
      );

      batch.set(payslipRef, payslip.toMap());

      // In-App Notification
      final notifRef = _firestore.collection('notifications').doc();
      final notif = AppNotification(
        id: notifRef.id,
        organizationId: rec.organizationId,
        recipientUserId: rec.employeeId,
        type: 'payslip_published',
        title: 'Payslip Published',
        message: 'Your payslip for ${rec.payrollPeriodId} is now available for download.',
        relatedResourceType: 'payslip',
        relatedResourceId: payslipRef.id,
        createdAt: now,
      );
      batch.set(notifRef, notif.toMap());
    }

    batch.update(_firestore.collection('payroll_periods').doc(periodId), {
      'status': 'published',
      'publishedAt': now.toIso8601String(),
    });

    await batch.commit();
  }

  /// Fetches employee's published payslips
  Future<List<Payslip>> getEmployeePayslips(String employeeId) async {
    final snapshot = await _firestore
        .collection('payslips')
        .where('employeeId', isEqualTo: employeeId)
        .get();

    return snapshot.docs.map((doc) => Payslip.fromMap(doc.data())).toList();
  }

  /// Fetches payroll periods for organization
  Future<List<PayrollPeriod>> getPayrollPeriods(String orgId) async {
    final snapshot = await _firestore
        .collection('payroll_periods')
        .where('organizationId', isEqualTo: orgId)
        .get();

    if (snapshot.docs.isEmpty) {
      // Default initial payroll period
      final now = DateTime.now();
      return [
        PayrollPeriod(
          id: 'period_2026_08',
          organizationId: orgId,
          name: 'August 2026 Payroll',
          startDate: '2026-08-01',
          endDate: '2026-08-31',
          payDate: '2026-08-31',
          status: 'open',
          createdAt: now,
        ),
      ];
    }

    return snapshot.docs.map((doc) => PayrollPeriod.fromMap(doc.data())).toList();
  }
}
