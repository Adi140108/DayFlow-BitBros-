import 'package:cloud_firestore/cloud_firestore.dart';
import 'department.dart';
import 'designation.dart';
import 'location.dart';

/// Repository for Department, Designation, and Location organizational foundations.
class DepartmentRepository {
  final FirebaseFirestore _firestore;

  DepartmentRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<List<Department>> getDepartments(String orgId) async {
    final snapshot = await _firestore
        .collection('departments')
        .where('organizationId', isEqualTo: orgId)
        .where('status', isEqualTo: 'active')
        .get();

    return snapshot.docs.map((doc) => Department.fromMap(doc.data())).toList();
  }

  Future<Department> createDepartment(String orgId, String name, String code) async {
    final ref = _firestore.collection('departments').doc();
    final dept = Department(id: ref.id, organizationId: orgId, name: name, code: code);
    await ref.set(dept.toMap());
    return dept;
  }

  Future<List<Designation>> getDesignations(String orgId) async {
    final snapshot = await _firestore
        .collection('designations')
        .where('organizationId', isEqualTo: orgId)
        .where('status', isEqualTo: 'active')
        .get();

    return snapshot.docs.map((doc) => Designation.fromMap(doc.data())).toList();
  }

  Future<Designation> createDesignation(String orgId, String name, {String? departmentId}) async {
    final ref = _firestore.collection('designations').doc();
    final desig = Designation(id: ref.id, organizationId: orgId, name: name, departmentId: departmentId);
    await ref.set(desig.toMap());
    return desig;
  }

  Future<List<Location>> getLocations(String orgId) async {
    final snapshot = await _firestore
        .collection('locations')
        .where('organizationId', isEqualTo: orgId)
        .where('status', isEqualTo: 'active')
        .get();

    return snapshot.docs.map((doc) => Location.fromMap(doc.data())).toList();
  }

  Future<Location> createLocation(String orgId, String name, {String? address}) async {
    final ref = _firestore.collection('locations').doc();
    final loc = Location(id: ref.id, organizationId: orgId, name: name, address: address);
    await ref.set(loc.toMap());
    return loc;
  }
}
