import 'salary_component.dart';

/// Effective-dated Salary Structure domain model for Dayflow.
class SalaryStructure {
  final String id;
  final String organizationId;
  final String employeeId;
  final String effectiveFrom; // YYYY-MM-DD
  final String currency; // e.g. 'INR', 'USD'
  final List<SalaryComponent> components;
  final String status; // 'active', 'archived'

  const SalaryStructure({
    required this.id,
    required this.organizationId,
    required this.employeeId,
    required this.effectiveFrom,
    this.currency = 'INR',
    this.components = const [],
    this.status = 'active',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'organizationId': organizationId,
      'employeeId': employeeId,
      'effectiveFrom': effectiveFrom,
      'currency': currency,
      'components': components.map((c) => c.toMap()).toList(),
      'status': status,
    };
  }

  factory SalaryStructure.fromMap(Map<String, dynamic> map) {
    return SalaryStructure(
      id: map['id'] as String,
      organizationId: map['organizationId'] as String,
      employeeId: map['employeeId'] as String,
      effectiveFrom: map['effectiveFrom'] as String,
      currency: map['currency'] as String? ?? 'INR',
      components: (map['components'] as List<dynamic>?)
              ?.map((c) => SalaryComponent.fromMap(c as Map<String, dynamic>))
              .toList() ??
          const [],
      status: map['status'] as String? ?? 'active',
    );
  }
}
