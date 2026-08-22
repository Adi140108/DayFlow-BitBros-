/// Production-grade Employee domain model for Dayflow HRMS.
class Employee {
  final String id;
  final String employeeId; // e.g. "EMP-001" (unique per org)
  final String? userId; // Linked Auth UID
  final String organizationId;
  final String status; // 'invited', 'onboarding', 'active', 'suspended', 'exited'

  // Personal Information
  final String fullName;
  final String? displayName;
  final String email;
  final String? phone;
  final String? dateOfBirth;
  final String? gender;
  final String? address;
  final String? emergencyContact;
  final String? avatarUrl;

  // Employment Information
  final String? departmentId;
  final String? designationId;
  final String? locationId;
  final String? managerId;
  final String? joiningDate;
  final String employmentType; // 'full_time', 'part_time', 'contract', 'intern'
  final String? salaryRefId; // Reference to salary structure (no calculations)

  final DateTime createdAt;
  final DateTime updatedAt;

  const Employee({
    required this.id,
    required this.employeeId,
    this.userId,
    required this.organizationId,
    this.status = 'active',
    required this.fullName,
    this.displayName,
    required this.email,
    this.phone,
    this.dateOfBirth,
    this.gender,
    this.address,
    this.emergencyContact,
    this.avatarUrl,
    this.departmentId,
    this.designationId,
    this.locationId,
    this.managerId,
    this.joiningDate,
    this.employmentType = 'full_time',
    this.salaryRefId,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'employeeId': employeeId,
      'userId': userId,
      'organizationId': organizationId,
      'status': status,
      'fullName': fullName,
      'displayName': displayName ?? fullName,
      'email': email,
      'phone': phone,
      'dateOfBirth': dateOfBirth,
      'gender': gender,
      'address': address,
      'emergencyContact': emergencyContact,
      'avatarUrl': avatarUrl,
      'departmentId': departmentId,
      'designationId': designationId,
      'locationId': locationId,
      'managerId': managerId,
      'joiningDate': joiningDate,
      'employmentType': employmentType,
      'salaryRefId': salaryRefId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Employee.fromMap(Map<String, dynamic> map) {
    return Employee(
      id: map['id'] as String,
      employeeId: map['employeeId'] as String,
      userId: map['userId'] as String?,
      organizationId: map['organizationId'] as String,
      status: map['status'] as String? ?? 'active',
      fullName: map['fullName'] as String,
      displayName: map['displayName'] as String?,
      email: map['email'] as String,
      phone: map['phone'] as String?,
      dateOfBirth: map['dateOfBirth'] as String?,
      gender: map['gender'] as String?,
      address: map['address'] as String?,
      emergencyContact: map['emergencyContact'] as String?,
      avatarUrl: map['avatarUrl'] as String?,
      departmentId: map['departmentId'] as String?,
      designationId: map['designationId'] as String?,
      locationId: map['locationId'] as String?,
      managerId: map['managerId'] as String?,
      joiningDate: map['joiningDate'] as String?,
      employmentType: map['employmentType'] as String? ?? 'full_time',
      salaryRefId: map['salaryRefId'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  Employee copyWith({
    String? id,
    String? employeeId,
    String? userId,
    String? organizationId,
    String? status,
    String? fullName,
    String? displayName,
    String? email,
    String? phone,
    String? dateOfBirth,
    String? gender,
    String? address,
    String? emergencyContact,
    String? avatarUrl,
    String? departmentId,
    String? designationId,
    String? locationId,
    String? managerId,
    String? joiningDate,
    String? employmentType,
    String? salaryRefId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Employee(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      userId: userId ?? this.userId,
      organizationId: organizationId ?? this.organizationId,
      status: status ?? this.status,
      fullName: fullName ?? this.fullName,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      address: address ?? this.address,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      departmentId: departmentId ?? this.departmentId,
      designationId: designationId ?? this.designationId,
      locationId: locationId ?? this.locationId,
      managerId: managerId ?? this.managerId,
      joiningDate: joiningDate ?? this.joiningDate,
      employmentType: employmentType ?? this.employmentType,
      salaryRefId: salaryRefId ?? this.salaryRefId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
