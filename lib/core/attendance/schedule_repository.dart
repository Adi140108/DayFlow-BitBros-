import 'package:cloud_firestore/cloud_firestore.dart';
import 'shift.dart';
import 'work_schedule.dart';

/// Repository for managing organization WorkSchedules and Shifts with cached rule lookup.
class ScheduleRepository {
  final FirebaseFirestore _firestore;
  static final Map<String, Shift> _shiftCache = {};

  ScheduleRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Fetches active work schedules for an organization
  Future<List<WorkSchedule>> getSchedules(String orgId) async {
    final snapshot = await _firestore
        .collection('schedules')
        .where('organizationId', isEqualTo: orgId)
        .where('status', isEqualTo: 'active')
        .get();

    return snapshot.docs.map((doc) => WorkSchedule.fromMap(doc.data())).toList();
  }

  /// Creates or updates a work schedule
  Future<WorkSchedule> createSchedule(WorkSchedule schedule) async {
    await _firestore.collection('schedules').doc(schedule.id).set(schedule.toMap(), SetOptions(merge: true));
    return schedule;
  }

  /// Fetches all configured shifts for an organization
  Future<List<Shift>> getShifts(String orgId) async {
    final snapshot = await _firestore
        .collection('shifts')
        .where('organizationId', isEqualTo: orgId)
        .get();

    if (snapshot.docs.isEmpty) {
      // Default standard shift for initial org setup
      final defaultShift = Shift(
        id: 'shift_default_$orgId',
        organizationId: orgId,
        name: 'Standard Institute / Office Shift',
        startTime: '09:00',
        endTime: '17:00',
        gracePeriodMinutes: 15,
        status: 'active',
      );
      await createShift(defaultShift);
      return [defaultShift];
    }

    final list = snapshot.docs.map((doc) => Shift.fromMap(doc.data())).toList();
    for (var s in list) {
      if (s.status == 'active') _shiftCache[orgId] = s;
    }
    return list;
  }

  /// Resolves the effective active shift for an organization with optimized local cache
  Future<Shift> getEffectiveShift(String orgId) async {
    if (_shiftCache.containsKey(orgId)) {
      return _shiftCache[orgId]!;
    }
    final shifts = await getShifts(orgId);
    final active = shifts.firstWhere(
      (s) => s.status == 'active',
      orElse: () => Shift(
        id: 'fallback_$orgId',
        organizationId: orgId,
        name: 'Standard Workday',
        startTime: '09:00',
        endTime: '17:00',
      ),
    );
    _shiftCache[orgId] = active;
    return active;
  }

  /// Saves, updates or activates a shift
  Future<Shift> createShift(Shift shift) async {
    final ref = _firestore.collection('shifts').doc(shift.id.isNotEmpty ? shift.id : null);
    final toSave = Shift(
      id: ref.id,
      organizationId: shift.organizationId,
      name: shift.name,
      startTime: shift.startTime,
      endTime: shift.endTime,
      timezone: shift.timezone,
      isOvernight: shift.isOvernight,
      gracePeriodMinutes: shift.gracePeriodMinutes,
      status: shift.status,
    );

    await ref.set(toSave.toMap(), SetOptions(merge: true));
    if (toSave.status == 'active') {
      _shiftCache[shift.organizationId] = toSave;
    }
    return toSave;
  }

  /// Deletes or deactivates a shift
  Future<void> deleteShift(String shiftId, String orgId) async {
    await _firestore.collection('shifts').doc(shiftId).delete();
    _shiftCache.remove(orgId);
  }
}
