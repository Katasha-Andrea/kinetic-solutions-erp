enum TenderStatus { open, closed, awarded, cancelled }

class Tender {
  final String id;
  final String tenderNumber;
  final String title;
  final String description;
  final String issuingOrganization;
  final DateTime closingDate;
  final DateTime? siteVisitDate;
  final double estimatedValue;
  final double bidBondPercentage;
  final int validityDays;
  final List<String> requirements;
  final String contactInfo;
  final String category;
  final TenderStatus status;
  final List<String> attachedDocumentIds; // NEW

  Tender({
    required this.id,
    required this.tenderNumber,
    required this.title,
    required this.description,
    required this.issuingOrganization,
    required this.closingDate,
    this.siteVisitDate,
    required this.estimatedValue,
    this.bidBondPercentage = 2.0,
    this.validityDays = 30,
    this.requirements = const [],
    required this.contactInfo,
    required this.category,
    this.status = TenderStatus.open,
    this.attachedDocumentIds = const [],
  });

  double get bidBondAmount => estimatedValue * (bidBondPercentage / 100);
  int get daysRemaining => closingDate.difference(DateTime.now()).inDays;

  Map<String, dynamic> toMap() => {
        'id': id,
        'tenderNumber': tenderNumber,
        'title': title,
        'description': description,
        'issuingOrganization': issuingOrganization,
        'closingDate': closingDate.toIso8601String(),
        'siteVisitDate': siteVisitDate?.toIso8601String(),
        'estimatedValue': estimatedValue,
        'bidBondPercentage': bidBondPercentage,
        'validityDays': validityDays,
        'requirements': requirements,
        'contactInfo': contactInfo,
        'category': category,
        'status': status.name,
        'attachedDocumentIds': attachedDocumentIds,
      };

  factory Tender.fromMap(Map<String, dynamic> map) => Tender(
        id: map['id'] as String,
        tenderNumber: map['tenderNumber'] as String,
        title: map['title'] as String,
        description: map['description'] as String,
        issuingOrganization: map['issuingOrganization'] as String,
        closingDate: DateTime.parse(map['closingDate'] as String),
        siteVisitDate: map['siteVisitDate'] != null
            ? DateTime.parse(map['siteVisitDate'] as String)
            : null,
        estimatedValue: map['estimatedValue'] as double,
        bidBondPercentage: map['bidBondPercentage'] as double? ?? 2.0,
        validityDays: map['validityDays'] as int? ?? 30,
        requirements: (map['requirements'] as List?)?.cast<String>() ?? [],
        contactInfo: map['contactInfo'] as String,
        category: map['category'] as String,
        status: TenderStatus.values.firstWhere(
            (e) => e.name == map['status'],
            orElse: () => TenderStatus.open),
        attachedDocumentIds: (map['attachedDocumentIds'] as List?)?.cast<String>() ?? [],
      );
}