/// Document metadata domain model for Dayflow.
class EmployeeDocument {
  final String id;
  final String organizationId;
  final String employeeId;
  final String name;
  final String category; // 'identity', 'employment', 'education', 'experience', 'tax', 'payroll', 'certification', 'other'
  final String contentType; // 'application/pdf', 'image/jpeg', 'image/png'
  final int fileSize;
  final String storageKey;
  final String storageProvider; // 'b2' or 'cloudinary'
  final String uploadedBy;
  final String? expiryDate;
  final String visibility; // 'employee_only', 'hr_admin', 'management'
  final DateTime uploadedAt;

  const EmployeeDocument({
    required this.id,
    required this.organizationId,
    required this.employeeId,
    required this.name,
    required this.category,
    required this.contentType,
    required this.fileSize,
    required this.storageKey,
    this.storageProvider = 'b2',
    required this.uploadedBy,
    this.expiryDate,
    this.visibility = 'hr_admin',
    required this.uploadedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'organizationId': organizationId,
      'employeeId': employeeId,
      'name': name,
      'category': category,
      'contentType': contentType,
      'fileSize': fileSize,
      'storageKey': storageKey,
      'storageProvider': storageProvider,
      'uploadedBy': uploadedBy,
      'expiryDate': expiryDate,
      'visibility': visibility,
      'uploadedAt': uploadedAt.toIso8601String(),
    };
  }

  factory EmployeeDocument.fromMap(Map<String, dynamic> map) {
    return EmployeeDocument(
      id: map['id'] as String,
      organizationId: map['organizationId'] as String,
      employeeId: map['employeeId'] as String,
      name: map['name'] as String,
      category: map['category'] as String,
      contentType: map['contentType'] as String,
      fileSize: map['fileSize'] as int,
      storageKey: map['storageKey'] as String,
      storageProvider: map['storageProvider'] as String? ?? 'b2',
      uploadedBy: map['uploadedBy'] as String,
      expiryDate: map['expiryDate'] as String?,
      visibility: map['visibility'] as String? ?? 'hr_admin',
      uploadedAt: DateTime.parse(map['uploadedAt'] as String),
    );
  }
}
