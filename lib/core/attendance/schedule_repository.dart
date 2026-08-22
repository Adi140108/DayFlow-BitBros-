import 'package:cloud_firestore/cloud_firestore.dart';
import 'shift.dart';
import 'work_schedule.dart';

/// Repository for managing organization WorkSchedules and Shifts.
class ScheduleRepository {
  final FirebaseFirestore _firestore;

  ScheduleRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<List<WorkSchedule>> getSchedules(String orgId) async {
    final snapshot = await _firestore
        .collection('schedules')
        .where('organizationId', isEqualTo: orgId)
        .where('status', isEqualTo: 'active')
        .get();

    return snapshot.docs.map((doc) => WorkSchedule.fromMap(doc.data())).toList();
  }

  Future<WorkSchedule> createSchedule(WorkSchedule schedule) async {
    await _firestore.collection('schedules').doc(schedule.id).set(schedule.toMap());
    return schedule;
  }

  Future<List<Shift>> getShifts(String orgId) async {
    final snapshot = await _firestore
        .collection('shifts')
        .where('organizationId', isEqualTo: orgId)
        .where('status', isEqualTo: 'active')
        .get();

    return snapshot.docs.map((doc) => Shift.fromMap(doc.data())).toList();
  }

  Future<Shift> createShift(Shift shift) async {
    await _firestore.collection('shifts').doc(shift.id).set(shift.toMap());
    return shift;
  }
}
