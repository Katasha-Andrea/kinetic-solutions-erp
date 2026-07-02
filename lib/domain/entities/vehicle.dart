enum VehicleStatus { available, onSite, underRepair, sold }

class Vehicle {
  final String id;
  final String registrationNumber;
  final String make;
  final String model;
  final String year;
  final String type; // e.g., 'Truck', 'Car', 'Excavator'
  final String? driverName;
  final String? currentProject;
  final String? location;
  final VehicleStatus status;
  final double mileage;
  final double fuelTankCapacity;
  final double currentFuelLevel;
  final DateTime insuranceExpiry;
  final DateTime fitnessExpiry;
  final DateTime roadTaxExpiry;
  final double? averageFuelConsumption; // km/l
  final List<Map<String, dynamic>> serviceHistory;
  final DateTime createdAt;
  final DateTime updatedAt;

  Vehicle({
    required this.id,
    required this.registrationNumber,
    required this.make,
    required this.model,
    required this.year,
    required this.type,
    this.driverName,
    this.currentProject,
    this.location,
    this.status = VehicleStatus.available,
    this.mileage = 0,
    this.fuelTankCapacity = 0,
    this.currentFuelLevel = 0,
    required this.insuranceExpiry,
    required this.fitnessExpiry,
    required this.roadTaxExpiry,
    this.averageFuelConsumption,
    this.serviceHistory = const [],
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  bool get isInsuranceExpired => insuranceExpiry.isBefore(DateTime.now());
  bool get isFitnessExpired => fitnessExpiry.isBefore(DateTime.now());
  bool get isRoadTaxExpired => roadTaxExpiry.isBefore(DateTime.now());
  double get fuelPercentage => fuelTankCapacity > 0 ? (currentFuelLevel / fuelTankCapacity * 100) : 0;

  Map<String, dynamic> toMap() => {
        'id': id,
        'registrationNumber': registrationNumber,
        'make': make,
        'model': model,
        'year': year,
        'type': type,
        'driverName': driverName,
        'currentProject': currentProject,
        'location': location,
        'status': status.name,
        'mileage': mileage,
        'fuelTankCapacity': fuelTankCapacity,
        'currentFuelLevel': currentFuelLevel,
        'insuranceExpiry': insuranceExpiry.toIso8601String(),
        'fitnessExpiry': fitnessExpiry.toIso8601String(),
        'roadTaxExpiry': roadTaxExpiry.toIso8601String(),
        'averageFuelConsumption': averageFuelConsumption,
        'serviceHistory': serviceHistory,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory Vehicle.fromMap(Map<String, dynamic> map) => Vehicle(
        id: map['id'] as String,
        registrationNumber: map['registrationNumber'] as String,
        make: map['make'] as String,
        model: map['model'] as String,
        year: map['year'] as String,
        type: map['type'] as String,
        driverName: map['driverName'] as String?,
        currentProject: map['currentProject'] as String?,
        location: map['location'] as String?,
        status: VehicleStatus.values.firstWhere(
            (e) => e.name == map['status'],
            orElse: () => VehicleStatus.available),
        mileage: map['mileage'] as double? ?? 0,
        fuelTankCapacity: map['fuelTankCapacity'] as double? ?? 0,
        currentFuelLevel: map['currentFuelLevel'] as double? ?? 0,
        insuranceExpiry: DateTime.parse(map['insuranceExpiry'] as String),
        fitnessExpiry: DateTime.parse(map['fitnessExpiry'] as String),
        roadTaxExpiry: DateTime.parse(map['roadTaxExpiry'] as String),
        averageFuelConsumption: map['averageFuelConsumption'] as double?,
        serviceHistory: (map['serviceHistory'] as List?)?.cast<Map<String, dynamic>>() ?? [],
        createdAt: DateTime.parse(map['createdAt'] as String),
        updatedAt: DateTime.parse(map['updatedAt'] as String),
      );
}