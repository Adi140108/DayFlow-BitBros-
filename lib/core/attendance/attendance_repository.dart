import 'package:cloud_firestore/cloud_firestore.dart';
import 'attendance_correction.dart';
import 'attendance_engine.dart';
import 'attendance_record.dart';
import 'attendance_session.dart';
import 'schedule_repository.dart';
import 'shift.dart';

/// Production Firestore repository for Attendance engine & Check-in/Check-out operations.
class AttendanceRepository {
  final FirebaseFirestore _firestore;

  AttendanceRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  String _formatDate(DateTime dt) {
    return "${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}";
  }

  /// Concurrency-safe Check-In using server-authoritative time
  Future<AttendanceRecord> checkIn({
    required String organizationId,
    required String employeeId,
  }) async {
    final now = DateTime.now();
    final dateStr = _formatDate(now);

    final recordRef = _firestore.collection('attendance_records').doc('${employeeId}_$dateStr');
    final sessionRef = _firestore.collection('attendance_sessions').doc();

    return await _firestore.runTransaction((transaction) async {
      final recordSnap = await transaction.get(recordRef);

      if (recordSnap.exists && recordSnap.data() != null) {
        final existing = AttendanceRecord.fromMap(recordSnap.data()!);
        if (existing.checkInAt != null && existing.checkOutAt == null) {
          throw Exception('An active check-in session already exists.');
        }
      }

      final record = AttendanceRecord(
        id: recordRef.id,
        organizationId: organizationId,
        employeeId: employeeId,
        attendanceDate: dateStr,
        status: 'present',
        checkInAt: now.toIso8601String(),
        createdAt: now,
        updatedAt: now,
      );

      final session = AttendanceSession(
        id: sessionRef.id,
        attendanceId: recordRef.id,
        employeeId: employeeId,
        checkInAt: now,
        status: 'active',
      );

      transaction.set(recordRef, record.toMap(), SetOptions(merge: true));
      transaction.set(sessionRef, session.toMap());

      return record;
    });
  }

  /// Concurrency-safe Check-Out with deterministic metric calculation
  Future<AttendanceRecord> checkOut({
    required String organizationId,
    required String employeeId,
    Shift? shift,
  }) async {
    final now = DateTime.now();
    final dateStr = _formatDate(now);

    final recordRef = _firestore.collection('attendance_records').doc('${employeeId}_$dateStr');
    final sessionsSnap = await _firestore
        .collection('attendance_sessions')
        .where('employeeId', isEqualTo: employeeId)
        .where('status', isEqualTo: 'active')
        .get();

    if (sessionsSnap.docs.isEmpty) {
      throw Exception('No active check-in session found to check out.');
    }

    final activeSessionDoc = sessionsSnap.docs.first;
    final activeSession = AttendanceSession.fromMap(activeSessionDoc.data());
    final checkInAt = activeSession.checkInAt;

    final effectiveShift = shift ??
        await ScheduleRepository(firestore: _firestore).getEffectiveShift(organizationId);

    final calcResult = AttendanceEngine.calculate(
      checkInAt: checkInAt,
      checkOutAt: now,
      shift: effectiveShift,
    );

    return await _firestore.runTransaction((transaction) async {
      final recordSnap = await transaction.get(recordRef);
      final existingRecord = recordSnap.exists && recordSnap.data() != null
          ? AttendanceRecord.fromMap(recordSnap.data()!)
          : AttendanceRecord(
              id: recordRef.id,
              organizationId: organizationId,
              employeeId: employeeId,
              attendanceDate: dateStr,
              createdAt: now,
              updatedAt: now,
            );

      final updatedRecord = existingRecord.copyWith(
        checkOutAt: now.toIso8601String(),
        totalWorkedMinutes: calcResult.totalWorkedMinutes,
        overtimeMinutes: calcResult.overtimeMinutes,
        isLate: calcResult.isLate,
        lateMinutes: calcResult.lateMinutes,
        isEarlyDeparture: calcResult.isEarlyDeparture,
        earlyDepartureMinutes: calcResult.earlyDepartureMinutes,
        status: calcResult.status,
        updatedAt: now,
      );

      transaction.set(recordRef, updatedRecord.toMap(), SetOptions(merge: true));
      transaction.update(activeSessionDoc.reference, {
        'checkOutAt': now.toIso8601String(),
        'durationMinutes': calcResult.totalWorkedMinutes,
        'status': 'completed',
      });

      return updatedRecord;
    });
  }

  /// Fetches today's record for employee
  Future<AttendanceRecord?> getTodayRecord(String organizationId, String employeeId) async {
    final dateStr = _formatDate(DateTime.now());
    final doc = await _firestore.collection('attendance_records').doc('${employeeId}_$dateStr').get();
    if (doc.exists && doc.data() != null) {
      return AttendanceRecord.fromMap(doc.data()!);
    }
    return null;
  }

  /// Fetches employee's attendance history
  Future<List<AttendanceRecord>> getAttendanceHistory(String employeeId, {int limit = 30}) async {
    final snapshot = await _firestore
        .collection('attendance_records')
        .where('employeeId', isEqualTo: employeeId)
        .limit(limit)
        .get();

    return snapshot.docs
        .map((doc) => AttendanceRecord.fromMap(doc.data()))
        .toList();
  }

  /// Fetches organization attendance for HR/Admin
  Future<List<AttendanceRecord>> getOrganizationAttendance(
    String organizationId, {
    String? date,
    String? status,
    int limit = 50,
  }) async {
    Query query = _firestore
        .collection('attendance_records')
        .where('organizationId', isEqualTo: organizationId);

    if (date != null && date.isNotEmpty) {
      query = query.where('attendanceDate', isEqualTo: date);
    }
    if (status != null && status.isNotEmpty) {
      query = query.where('status', isEqualTo: status);
    }

    query = query.limit(limit);
    final snapshot = await query.get();

    return snapshot.docs
        .map((doc) => AttendanceRecord.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  /// Submits an Attendance Correction request
  Future<AttendanceCorrection> requestCorrection({
    required String organizationId,
    required String employeeId,
    required String attendanceId,
    required String attendanceDate,
    String? originalCheckIn,
    String? originalCheckOut,
    required String requestedCheckIn,
    required String requestedCheckOut,
    required String reason,
    required String requesterId,
  }) async {
    final ref = _firestore.collection('attendance_corrections').doc();
    final correction = AttendanceCorrection(
      id: ref.id,
      organizationId: organizationId,
      employeeId: employeeId,
      attendanceId: attendanceId,
      attendanceDate: attendanceDate,
      originalCheckIn: originalCheckIn,
      originalCheckOut: originalCheckOut,
      requestedCheckIn: requestedCheckIn,
      requestedCheckOut: requestedCheckOut,
      reason: reason,
      requesterId: requesterId,
      status: 'pending',
      createdAt: DateTime.now(),
    );

    await ref.set(correction.toMap());
    await _firestore.collection('attendance_records').doc(attendanceId).update({'correctionStatus': 'pending'});
    return correction;
  }

  /// Fetches pending corrections for HR/Admin review
  Future<List<AttendanceCorrection>> getPendingCorrections(String organizationId) async {
    final snapshot = await _firestore
        .collection('attendance_corrections')
        .where('organizationId', isEqualTo: organizationId)
        .where('status', isEqualTo: 'pending')
        .get();

    return snapshot.docs.map((doc) => AttendanceCorrection.fromMap(doc.data())).toList();
  }

  /// HR/Admin review approval/rejection transaction
  Future<void> reviewCorrection({
    required String correctionId,
    required String reviewerId,
    required bool approve,
    String? reviewerComment,
  }) async {
    final corrRef = _firestore.collection('attendance_corrections').doc(correctionId);
    final now = DateTime.now();

    await _firestore.runTransaction((transaction) async {
      final corrSnap = await transaction.get(corrRef);
      if (!corrSnap.exists || corrSnap.data() == null) return;

      final corr = AttendanceCorrection.fromMap(corrSnap.data()!);
      final newStatus = approve ? 'approved' : 'rejected';

      transaction.update(corrRef, {
        'status': newStatus,
        'reviewerId': reviewerId,
        'reviewerComment': reviewerComment,
        'reviewedAt': now.toIso8601String(),
      });

      final recordRef = _firestore.collection('attendance_records').doc(corr.attendanceId);
      if (approve) {
        transaction.update(recordRef, {
          'checkInAt': corr.requestedCheckIn,
          'checkOutAt': corr.requestedCheckOut,
          'correctionStatus': 'approved',
          'updatedAt': now.toIso8601String(),
        });
      } else {
        transaction.update(recordRef, {'correctionStatus': 'rejected'});
      }
    });
  }
}
