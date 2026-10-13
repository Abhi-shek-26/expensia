
class CreditModel {
  final int? id;
  final String creditType;
  final String name;
  final DateTime date;
  final String planType;
  final double amount;

  const CreditModel({
    this.id,
    required this.creditType,
    required this.name,
    required this.date,
    required this.planType,
    required this.amount,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'creditType': creditType,
      'name': name,
      'date': date.toIso8601String(),
      'planType': planType,
      'amount': amount,
    };
  }

  factory CreditModel.fromMap(Map<String, dynamic> map) {
    return CreditModel(
      id: map['id'] as int?,
      creditType: map['creditType'] as String,
      name: map['name'] as String,
      date: DateTime.parse(map['date'] as String),
      planType: map['planType'] as String,
      amount: (map['amount'] as num).toDouble(),
    );
  }
}
