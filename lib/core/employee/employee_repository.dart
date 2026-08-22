import 'package:cloud_firestore/cloud_firestore.dart';
import 'employee.dart';

/// Firestore repository for Employee management and sequential Employee ID allocation.
class EmployeeRepository {
  final FirebaseFirestore _firestore;

  EmployeeRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Fetches paginated organization employees with optional filters
  Future<List<Employee>> getEmployees(
    String organizationId, {
    String? departmentId,
    String? status,
    String? searchQuery,
    int limit = 50,
  }) async {
    Query query = _firestore
        .collection('employees')
        .where('organizationId', isEqualTo: organizationId);

    if (departmentId != null && departmentId.isNotEmpty) {
      query = query.where('departmentId', isEqualTo: departmentId);
    }

    if (status != null && status.isNotEmpty) {
      query = query.where('status', isEqualTo: status);
    }

    query = query.limit(limit);
    final snapshot = await query.get();

    var employees = snapshot.docs
        .map((doc) => Employee.fromMap(doc.data() as Map<String, dynamic>))
        .toList();

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final q = searchQuery.trim().toLowerCase();
      employees = employees.where((e) {
        return e.fullName.toLowerCase().contains(q) ||
            e.employeeId.toLowerCase().contains(q) ||
            e.email.toLowerCase().contains(q);
      }).toList();
    }

    return employees;
  }

  /// Fetches an employee record by ID
  Future<Employee?> getEmployeeById(String id) async {
    final doc = await _firestore.collection('employees').doc(id).get();
    if (doc.exists && doc.data() != null) {
      return Employee.fromMap(doc.data()!);
    }
    return null;
  }

  /// Safely allocates unique Employee ID (EMP-001, EMP-002, etc.) and creates Employee record atomically
  Future<Employee> createEmployee({
    required String organizationId,
    required String fullName,
    required String email,
    String? phone,
    String? departmentId,
    String? designationId,
    String? managerId,
    String employmentType = 'full_time',
  }) async {
    final empRef = _firestore.collection('employees').doc();
    final counterRef = _firestore.collection('counters').doc('emp_$organizationId');

    return await _firestore.runTransaction((transaction) async {
      final counterSnapshot = await transaction.get(counterRef);
      int currentSeq = 0;
      if (counterSnapshot.exists && counterSnapshot.data() != null) {
        currentSeq = counterSnapshot.data()!['seq'] as int? ?? 0;
      }

      final nextSeq = currentSeq + 1;
      final formattedEmpId = 'EMP-${nextSeq.toString().padLeft(3, '0')}';
      final now = DateTime.now();

      final employee = Employee(
        id: empRef.id,
        employeeId: formattedEmpId,
        organizationId: organizationId,
        fullName: fullName,
        email: email,
        phone: phone,
        departmentId: departmentId,
        designationId: designationId,
        managerId: managerId,
        employmentType: employmentType,
        status: 'active',
        createdAt: now,
        updatedAt: now,
      );

      transaction.set(counterRef, {'seq': nextSeq});
      transaction.set(empRef, employee.toMap());

      return employee;
    });
  }

  /// Updates full employee profile (HR / Admin only)
  Future<void> updateEmployee(Employee employee) async {
    final updated = employee.copyWith(updatedAt: DateTime.now());
    await _firestore.collection('employees').doc(employee.id).set(
          updated.toMap(),
          SetOptions(merge: true),
        );
  }

  /// Self-service profile update restricted strictly to phone, address, avatarUrl
  Future<void> updateSelfServiceProfile(
    String employeeId, {
    String? phone,
    String? address,
    String? avatarUrl,
  }) async {
    final updates = <String, dynamic>{
      'updatedAt': DateTime.now().toIso8601String(),
    };
    if (phone != null) updates['phone'] = phone;
    if (address != null) updates['address'] = address;
    if (avatarUrl != null) updates['avatarUrl'] = avatarUrl;

    await _firestore.collection('employees').doc(employeeId).update(updates);
  }
}
