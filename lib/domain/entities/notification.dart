class AppNotification {
  final String id;
  final String title;
  final String message;
  final String type; // 'info', 'warning', 'success', 'error'
  final bool isRead;
  final DateTime createdAt;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    this.type = 'info',
    this.isRead = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'message': message,
        'type': type,
        'isRead': isRead,
        'createdAt': createdAt.toIso8601String(),
      };

  factory AppNotification.fromMap(Map<String, dynamic> map) => AppNotification(
        id: map['id'] as String,
        title: map['title'] as String,
        message: map['message'] as String,
        type: map['type'] as String? ?? 'info',
        isRead: map['isRead'] as bool? ?? false,
        createdAt: DateTime.parse(map['createdAt'] as String),
      );
}