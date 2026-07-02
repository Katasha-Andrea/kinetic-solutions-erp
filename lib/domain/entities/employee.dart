import '../../core/constants/app_constants.dart';

enum EmploymentStatus { active, suspended, terminated, onLeave }

extension EmploymentStatusExt on EmploymentStatus {
  String get label {
    switch (this) {
      case EmploymentStatus.active:     return 'Active';
      case EmploymentStatus.suspended:  return 'Suspended';
      case EmploymentStatus.terminated: return 'Terminated';
      case EmploymentStatus.onLeave:    return 'On Leave';
    }
  }
}

class Employee {
  final String id;
  final String firstName;
  final String lastName;
  final String nrc;
  final String napsaNumber;
  final String phoneNumber;
  final String email;
  final String department;
  final String position;
  final double basicSalary;
  final double housingAllowance;
  final double transportAllowance;
  final EmploymentStatus status;
  final DateTime? joinDate;
  final String? imageUrl;

  Employee({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.nrc,
    this.napsaNumber = '',
    required this.phoneNumber,
    this.email = '',
    required this.department,
    required this.position,
    required this.basicSalary,
    this.housingAllowance = 0,
    this.transportAllowance = 0,
    this.status = EmploymentStatus.active,
    this.joinDate,
    this.imageUrl,
  });

  String get fullName => '$firstName $lastName';
  String get initials => '${firstName[0]}${lastName[0]}'.toUpperCase();

  double get grossSalary => basicSalary + housingAllowance + transportAllowance;

  double get napsaContribution {
    final contribution = basicSalary * AppConstants.napsaRate;
    return contribution > AppConstants.napsaCeiling ? AppConstants.napsaCeiling : contribution;
  }

  double get payeMonthly {
    final annualBasic = basicSalary * 12;
    double annualPaye = 0;
    if (annualBasic <= AppConstants.payeBand1Max) {
      annualPaye = 0;
    } else if (annualBasic <= AppConstants.payeBand2Max) {
      annualPaye = (annualBasic - AppConstants.payeBand1Max) * AppConstants.payeRate2;
    } else if (annualBasic <= AppConstants.payeBand3Max) {
      annualPaye = (AppConstants.payeBand2Max - AppConstants.payeBand1Max) * AppConstants.payeRate2
          + (annualBasic - AppConstants.payeBand2Max) * AppConstants.payeRate3;
    } else {
      annualPaye = (AppConstants.payeBand2Max - AppConstants.payeBand1Max) * AppConstants.payeRate2
          + (AppConstants.payeBand3Max - AppConstants.payeBand2Max) * AppConstants.payeRate3
          + (annualBasic - AppConstants.payeBand3Max) * AppConstants.payeRate4;
    }
    return annualPaye / 12;
  }

  double get netSalary => grossSalary - payeMonthly - napsaContribution;

  Map<String, dynamic> toMap() => {
    'id': id, 'firstName': firstName, 'lastName': lastName, 'nrc': nrc,
    'napsaNumber': napsaNumber, 'phoneNumber': phoneNumber, 'email': email,
    'department': department, 'position': position, 'basicSalary': basicSalary,
    'housingAllowance': housingAllowance, 'transportAllowance': transportAllowance,
    'status': status.name, 'joinDate': joinDate?.toIso8601String(), 'imageUrl': imageUrl,
  };

  factory Employee.fromMap(Map<String, dynamic> m) => Employee(
    id: m['id'], firstName: m['firstName'], lastName: m['lastName'], nrc: m['nrc'],
    napsaNumber: m['napsaNumber'] ?? '', phoneNumber: m['phoneNumber'], email: m['email'] ?? '',
    department: m['department'], position: m['position'],
    basicSalary: (m['basicSalary'] as num).toDouble(),
    housingAllowance: (m['housingAllowance'] as num? ?? 0).toDouble(),
    transportAllowance: (m['transportAllowance'] as num? ?? 0).toDouble(),
    status: EmploymentStatus.values.firstWhere((s) => s.name == m['status'], orElse: () => EmploymentStatus.active),
    joinDate: m['joinDate'] != null ? DateTime.parse(m['joinDate']) : null,
    imageUrl: m['imageUrl'],
  );
}
