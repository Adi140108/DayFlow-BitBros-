import 'package:cloud_firestore/cloud_firestore.dart';
import '../attendance/attendance_record.dart';
import '../notification/app_notification.dart';
import 'leave_balance.dart';
import 'leave_request.dart';

/// Production Firestore repository for Leave management, approval workflow, and attendance integration.
class LeaveRepository {
  final FirebaseFirestore _firestore;

  LeaveRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Calculates actual working days between start and end dates (skipping Saturday/Sunday)
  double calculateWorkingLeaveDays(DateTime start, DateTime end, {bool isHalfDay = false}) {
    if (isHalfDay) return 0.5;

    double days = 0.0;
    DateTime current = start;
    while (!current.isAfter(end)) {
      if (current.weekday != DateTime.saturday && current.weekday != DateTime.sunday) {
        days += 1.0;
      }
      current = current.add(const Duration(days: 1));
    }
    return days > 0 ? days : 1.0;
  }

  /// Checks if employee has an overlapping pending or approved leave request
  Future<bool> checkLeaveOverlap(String employeeId, DateTime start, DateTime end) async {
    final snapshot = await _firestore
        .collection('leave_requests')
        .where('employeeId', isEqualTo: employeeId)
        .where('status', whereIn: ['pending', 'approved'])
        .get();

    for (var doc in snapshot.docs) {
      final req = LeaveRequest.fromMap(doc.data());
      final reqStart = DateTime.parse(req.startDate);
      final reqEnd = DateTime.parse(req.endDate);

      final overlaps = !(end.isBefore(reqStart) || start.isAfter(reqEnd));
      if (overlaps) return true;
    }
    return false;
  }

  /// Transactional Leave Application
  Future<LeaveRequest> submitLeaveRequest({
    required String organizationId,
    required String employeeId,
    required String leaveTypeId,
    required DateTime startDate,
    required DateTime endDate,
    bool isHalfDay = false,
    String? halfDayPosition,
    required String remarks,
  }) async {
    final startStr = "${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}";
    final endStr = "${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}";

    final hasOverlap = await checkLeaveOverlap(employeeId, startDate, endDate);
    if (hasOverlap) {
      throw Exception('An overlapping leave request already exists for these dates.');
    }

    final duration = calculateWorkingLeaveDays(startDate, endDate, isHalfDay: isHalfDay);
    final reqRef = _firestore.collection('leave_requests').doc();
    final balanceRef = _firestore.collection('leave_balances').doc('${employeeId}_${leaveTypeId}_${startDate.year}');
    final notifRef = _firestore.collection('notifications').doc();

    return await _firestore.runTransaction((transaction) async {
      final balanceSnap = await transaction.get(balanceRef);
      double currentPending = 0.0;
      double available = 15.0;

      if (balanceSnap.exists && balanceSnap.data() != null) {
        final bal = LeaveBalance.fromMap(balanceSnap.data()!);
        currentPending = bal.pending;
        available = bal.available;
      }

      if (available < duration) {
        throw Exception('Insufficient leave balance available ($available days available, $duration days requested).');
      }

      final now = DateTime.now();
      final request = LeaveRequest(
        id: reqRef.id,
        organizationId: organizationId,
        employeeId: employeeId,
        leaveTypeId: leaveTypeId,
        startDate: startStr,
        endDate: endStr,
        durationDays: duration,
        isHalfDay: isHalfDay,
        halfDayPosition: halfDayPosition,
        remarks: remarks,
        status: 'pending',
        submittedAt: now,
      );

      final notif = AppNotification(
        id: notifRef.id,
        organizationId: organizationId,
        recipientUserId: 'hr_manager',
        type: 'leave_submitted',
        title: 'New Leave Request Submitted',
        message: 'An employee requested $duration day(s) of leave.',
        relatedResourceType: 'leaveRequest',
        relatedResourceId: reqRef.id,
        createdAt: now,
      );

      // Reserve pending balance
      transaction.set(balanceRef, {
        'id': balanceRef.id,
        'organizationId': organizationId,
        'employeeId': employeeId,
        'leaveTypeId': leaveTypeId,
        'year': startDate.year,
        'allocated': 15.0,
        'pending': currentPending + duration,
      }, SetOptions(merge: true));

      transaction.set(reqRef, request.toMap());
      transaction.set(notifRef, notif.toMap());

      return request;
    });
  }

  /// Transactional Approval with Self-Approval Prevention and Attendance Integration
  Future<void> approveLeaveRequest({
    required String requestId,
    required String approverId,
    String? reviewerComment,
  }) async {
    final reqRef = _firestore.collection('leave_requests').doc(requestId);
    final now = DateTime.now();

    await _firestore.runTransaction((transaction) async {
      final reqSnap = await transaction.get(reqRef);
      if (!reqSnap.exists || reqSnap.data() == null) throw Exception('Leave request not found.');

      final req = LeaveRequest.fromMap(reqSnap.data()!);
      if (req.employeeId == approverId) {
        throw Exception('Self-approval is strictly forbidden by policy.');
      }
      if (req.status != 'pending') {
        throw Exception('Leave request is no longer pending.');
      }

      final balanceRef = _firestore.collection('leave_balances').doc('${req.employeeId}_${req.leaveTypeId}_${DateTime.parse(req.startDate).year}');
      final balanceSnap = await transaction.get(balanceRef);
      if (balanceSnap.exists && balanceSnap.data() != null) {
        final bal = LeaveBalance.fromMap(balanceSnap.data()!);
        transaction.update(balanceRef, {
          'used': bal.used + req.durationDays,
          'pending': (bal.pending - req.durationDays) < 0 ? 0.0 : (bal.pending - req.durationDays),
        });
      }

      transaction.update(reqRef, {
        'status': 'approved',
        'approverId': approverId,
        'reviewerComment': reviewerComment,
        'reviewedAt': now.toIso8601String(),
      });

      // Employee Notification
      final notifRef = _firestore.collection('notifications').doc();
      final notif = AppNotification(
        id: notifRef.id,
        organizationId: req.organizationId,
        recipientUserId: req.employeeId,
        type: 'leave_approved',
        title: 'Leave Request Approved',
        message: 'Your leave request for ${req.startDate} to ${req.endDate} has been approved.',
        relatedResourceType: 'leaveRequest',
        relatedResourceId: req.id,
        createdAt: now,
      );
      transaction.set(notifRef, notif.toMap());

      // Attendance Integration: Materialize AttendanceRecord with status = LEAVE
      DateTime current = DateTime.parse(req.startDate);
      final endDate = DateTime.parse(req.endDate);
      while (!current.isAfter(endDate)) {
        if (current.weekday != DateTime.saturday && current.weekday != DateTime.sunday) {
          final dateStr = "${current.year}-${current.month.toString().padLeft(2, '0')}-${current.day.toString().padLeft(2, '0')}";
          final attRef = _firestore.collection('attendance_records').doc('${req.employeeId}_$dateStr');
          final attRec = AttendanceRecord(
            id: attRef.id,
            organizationId: req.organizationId,
            employeeId: req.employeeId,
            attendanceDate: dateStr,
            status: 'leave',
            createdAt: now,
            updatedAt: now,
          );
          transaction.set(attRef, attRec.toMap(), SetOptions(merge: true));
        }
        current = current.add(const Duration(days: 1));
      }
    });
  }

  /// Transactional Rejection
  Future<void> rejectLeaveRequest({
    required String requestId,
    required String approverId,
    String? reviewerComment,
  }) async {
    final reqRef = _firestore.collection('leave_requests').doc(requestId);
    final now = DateTime.now();

    await _firestore.runTransaction((transaction) async {
      final reqSnap = await transaction.get(reqRef);
      if (!reqSnap.exists || reqSnap.data() == null) throw Exception('Leave request not found.');

      final req = LeaveRequest.fromMap(reqSnap.data()!);
      if (req.employeeId == approverId) {
        throw Exception('Self-approval/rejection is strictly forbidden by policy.');
      }

      final balanceRef = _firestore.collection('leave_balances').doc('${req.employeeId}_${req.leaveTypeId}_${DateTime.parse(req.startDate).year}');
      final balanceSnap = await transaction.get(balanceRef);
      if (balanceSnap.exists && balanceSnap.data() != null) {
        final bal = LeaveBalance.fromMap(balanceSnap.data()!);
        transaction.update(balanceRef, {
          'pending': (bal.pending - req.durationDays) < 0 ? 0.0 : (bal.pending - req.durationDays),
        });
      }

      transaction.update(reqRef, {
        'status': 'rejected',
        'approverId': approverId,
        'reviewerComment': reviewerComment,
        'reviewedAt': now.toIso8601String(),
      });

      final notifRef = _firestore.collection('notifications').doc();
      final notif = AppNotification(
        id: notifRef.id,
        organizationId: req.organizationId,
        recipientUserId: req.employeeId,
        type: 'leave_rejected',
        title: 'Leave Request Rejected',
        message: 'Your leave request for ${req.startDate} was rejected.',
        relatedResourceType: 'leaveRequest',
        relatedResourceId: req.id,
        createdAt: now,
      );
      transaction.set(notifRef, notif.toMap());
    });
  }

  /// Fetches employee's leave balances
  Future<List<LeaveBalance>> getEmployeeBalances(String employeeId, int year) async {
    final snapshot = await _firestore
        .collection('leave_balances')
        .where('employeeId', isEqualTo: employeeId)
        .where('year', isEqualTo: year)
        .get();

    if (snapshot.docs.isEmpty) {
      // Default initial balances for Paid, Sick, Unpaid
      return [
        LeaveBalance(id: '1', organizationId: '', employeeId: employeeId, leaveTypeId: 'paid', year: year, allocated: 15.0),
        LeaveBalance(id: '2', organizationId: '', employeeId: employeeId, leaveTypeId: 'sick', year: year, allocated: 10.0),
        LeaveBalance(id: '3', organizationId: '', employeeId: employeeId, leaveTypeId: 'unpaid', year: year, allocated: 30.0),
      ];
    }

    return snapshot.docs.map((doc) => LeaveBalance.fromMap(doc.data())).toList();
  }

  /// Fetches employee's leave request history
  Future<List<LeaveRequest>> getEmployeeLeaveRequests(String employeeId) async {
    final snapshot = await _firestore
        .collection('leave_requests')
        .where('employeeId', isEqualTo: employeeId)
        .get();

    return snapshot.docs.map((doc) => LeaveRequest.fromMap(doc.data())).toList();
  }

  /// Fetches all organization leave requests for HR/Admin approval
  Future<List<LeaveRequest>> getOrganizationLeaveRequests(String orgId, {String? status}) async {
    Query query = _firestore.collection('leave_requests').where('organizationId', isEqualTo: orgId);
    if (status != null && status.isNotEmpty) {
      query = query.where('status', isEqualTo: status);
    }
    final snapshot = await query.get();
    return snapshot.docs.map((doc) => LeaveRequest.fromMap(doc.data() as Map<String, dynamic>)).toList();
  }
}
