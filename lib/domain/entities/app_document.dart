enum DocumentType { quotation, purchaseOrder, miv, payslip, completionCertificate, leaveApproval }

class AppDocument {
  final String id;
  final String title;
  final DocumentType type;
  final String category; // e.g., 'Procurement', 'HR', 'Projects'
  final String fileName;
  final String fileUrl; // local path or URL
  final int fileSize; // in bytes
  final String uploadedBy; // user ID
  final DateTime uploadedAt;
  final DateTime expiryDate;
  final List<String> tags;

  AppDocument({
    required this.id,
    required this.title,
    required this.type,
    required this.category,
    required this.fileName,
    required this.fileUrl,
    required this.fileSize,
    required this.uploadedBy,
    required this.uploadedAt,
    required this.expiryDate,
    this.tags = const [],
  });

  bool get isExpired => expiryDate.isBefore(DateTime.now());

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'type': type.name,
        'category': category,
        'fileName': fileName,
        'fileUrl': fileUrl,
        'fileSize': fileSize,
        'uploadedBy': uploadedBy,
        'uploadedAt': uploadedAt.toIso8601String(),
        'expiryDate': expiryDate.toIso8601String(),
        'tags': tags,
      };

  factory AppDocument.fromMap(Map<String, dynamic> map) => AppDocument(
        id: map['id'] as String,
        title: map['title'] as String,
        type: DocumentType.values.firstWhere(
            (e) => e.name == map['type'],
            orElse: () => DocumentType.quotation),
        category: map['category'] as String,
        fileName: map['fileName'] as String,
        fileUrl: map['fileUrl'] as String,
        fileSize: map['fileSize'] as int,
        uploadedBy: map['uploadedBy'] as String,
        uploadedAt: DateTime.parse(map['uploadedAt'] as String),
        expiryDate: DateTime.parse(map['expiryDate'] as String),
        tags: (map['tags'] as List?)?.cast<String>() ?? [],
      );
}