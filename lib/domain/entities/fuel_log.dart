class FuelLog {
  final String id;
  final String vehicleId;
  final DateTime date;
  final double litres;
  final double cost;
  final double mileage; // current vehicle mileage at refuel

  FuelLog({
    required this.id,
    required this.vehicleId,
    required this.date,
    required this.litres,
    required this.cost,
    required this.mileage,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'vehicleId': vehicleId,
        'date': date.toIso8601String(),
        'litres': litres,
        'cost': cost,
        'mileage': mileage,
      };

  factory FuelLog.fromMap(Map<String, dynamic> map) => FuelLog(
        id: map['id'] as String,
        vehicleId: map['vehicleId'] as String,
        date: DateTime.parse(map['date'] as String),
        litres: map['litres'] as double,
        cost: map['cost'] as double,
        mileage: map['mileage'] as double,
      );
}