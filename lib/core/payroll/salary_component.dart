/// Salary Component domain model for Dayflow.
class SalaryComponent {
  final String id;
  final String name; // e.g. 'Basic Salary', 'House Rent Allowance', 'Provident Fund', 'Health Insurance'
  final String code; // e.g. 'BASIC', 'HRA', 'PF', 'INS'
  final String type; // 'earning', 'deduction', 'employer_contribution'
  final String calculationType; // 'fixed', 'percentage'
  final double amount;
  final double percentageOfBase; // e.g. 50.0 for 50% of Basic

  const SalaryComponent({
    required this.id,
    required this.name,
    required this.code,
    required this.type,
    this.calculationType = 'fixed',
    this.amount = 0.0,
    this.percentageOfBase = 0.0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'type': type,
      'calculationType': calculationType,
      'amount': amount,
      'percentageOfBase': percentageOfBase,
    };
  }

  factory SalaryComponent.fromMap(Map<String, dynamic> map) {
    return SalaryComponent(
      id: map['id'] as String,
      name: map['name'] as String,
      code: map['code'] as String,
      type: map['type'] as String,
      calculationType: map['calculationType'] as String? ?? 'fixed',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      percentageOfBase: (map['percentageOfBase'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
