import 'package:flutter_test/flutter_test.dart';
import 'package:dayflow/core/employee/employee.dart';
import 'package:dayflow/core/employee/department.dart';
import 'package:dayflow/core/employee/designation.dart';
import 'package:dayflow/core/employee/location.dart';
import 'package:dayflow/core/employee/employee_document.dart';

void main() {
  group('Dayflow Employee Domain Tests', () {
    test('Employee model serialization to and from Map', () {
      final now = DateTime.now();
      final emp = Employee(
        id: 'emp_123',
        employeeId: 'EMP-001',
        organizationId: 'org_456',
        fullName: 'Jane Doe',
        email: 'jane@company.com',
        phone: '+1 555-0199',
        departmentId: 'dept_789',
        createdAt: now,
        updatedAt: now,
      );

      final map = emp.toMap();
      final parsed = Employee.fromMap(map);

      expect(parsed.id, equals('emp_123'));
      expect(parsed.employeeId, equals('EMP-001'));
      expect(parsed.fullName, equals('Jane Doe'));
      expect(parsed.email, equals('jane@company.com'));
      expect(parsed.status, equals('active'));
    });

    test('Department and Designation model serialization', () {
      final dept = Department(
        id: 'dept_1',
        organizationId: 'org_1',
        name: 'Engineering',
        code: 'ENG',
      );

      final desig = Designation(
        id: 'desig_1',
        organizationId: 'org_1',
        name: 'Senior Developer',
        departmentId: 'dept_1',
      );

      expect(Department.fromMap(dept.toMap()).name, equals('Engineering'));
      expect(Designation.fromMap(desig.toMap()).name, equals('Senior Developer'));
    });

    test('Location and EmployeeDocument model serialization', () {
      final loc = Location(
        id: 'loc_1',
        organizationId: 'org_1',
        name: 'Headquarters',
        address: '123 Tech Street',
      );

      final doc = EmployeeDocument(
        id: 'doc_1',
        organizationId: 'org_1',
        employeeId: 'emp_123',
        name: 'Passport_Scan.pdf',
        category: 'identity',
        contentType: 'application/pdf',
        fileSize: 102400,
        storageKey: 'org_1/documents/Passport_Scan.pdf',
        uploadedBy: 'user_1',
        uploadedAt: DateTime.now(),
      );

      expect(Location.fromMap(loc.toMap()).name, equals('Headquarters'));
      expect(EmployeeDocument.fromMap(doc.toMap()).category, equals('identity'));
    });
  });
}
