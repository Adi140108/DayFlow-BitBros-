/// Payroll Period domain model with state machine transitions.
class PayrollPeriod {
  final String id;
  final String organizationId;
  final String name; // e.g. 'August 2026 Payroll'
  final String startDate; // YYYY-MM-DD
  final String endDate; // YYYY-MM-DD
  final String payDate; // YYYY-MM-DD
  final String frequency; // 'monthly'
  final String status; // 'open', 'processing', 'calculated', 'under_review', 'approved', 'published', 'locked'
  final DateTime createdAt;
  final DateTime? calculatedAt;
  final DateTime? approvedAt;
  final DateTime? publishedAt;

  const PayrollPeriod({
    required this.id,
    required this.organizationId,
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.payDate,
    this.frequency = 'monthly',
    this.status = 'open',
    required this.createdAt,
    this.calculatedAt,
    this.approvedAt,
    this.publishedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'organizationId': organizationId,
      'name': name,
      'startDate': startDate,
      'endDate': endDate,
      'payDate': payDate,
      'frequency': frequency,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'calculatedAt': calculatedAt?.toIso8601String(),
      'approvedAt': approvedAt?.toIso8601String(),
      'publishedAt': publishedAt?.toIso8601String(),
    };
  }

  factory PayrollPeriod.fromMap(Map<String, dynamic> map) {
    return PayrollPeriod(
      id: map['id'] as String,
      organizationId: map['organizationId'] as String,
      name: map['name'] as String,
      startDate: map['startDate'] as String,
      endDate: map['endDate'] as String,
      payDate: map['payDate'] as String,
      frequency: map['frequency'] as String? ?? 'monthly',
      status: map['status'] as String? ?? 'open',
      createdAt: DateTime.parse(map['createdAt'] as String),
      calculatedAt: map['calculatedAt'] != null ? DateTime.parse(map['calculatedAt'] as String) : null,
      approvedAt: map['approvedAt'] != null ? DateTime.parse(map['approvedAt'] as String) : null,
      publishedAt: map['publishedAt'] != null ? DateTime.parse(map['publishedAt'] as String) : null,
    );
  }
}
