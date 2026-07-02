import 'package:flutter/material.dart';
import 'package:kinetic_solutions/core/auth/auth_service.dart';
import 'package:kinetic_solutions/core/theme/app_theme.dart';
import 'package:kinetic_solutions/data/datasources/local_database.dart';
import 'package:kinetic_solutions/domain/entities/notification.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/app_user.dart';

class NotificationPage extends StatefulWidget {
  final AppUser currentUser;

  const NotificationPage({super.key, required this.currentUser});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  List<AppNotification> _notifications = [];
  bool _isLoading = true;
  String _filter = 'all';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final nots = LocalDatabase.getNotifications();
    setState(() {
      _notifications = nots..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      _isLoading = false;
    });
  }

  Future<void> _markRead(String id) async {
    await LocalDatabase.markNotificationRead(id);
    await _loadData();
  }

  Future<void> _markAllRead() async {
    for (final n in _notifications.where((n) => !n.isRead)) {
      await LocalDatabase.markNotificationRead(n.id);
    }
    await _loadData();
  }

  Future<void> _deleteNotification(String id) async {
    await LocalDatabase.deleteNotification(id);
    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filter == 'all'
        ? _notifications
        : _filter == 'unread'
            ? _notifications.where((n) => !n.isRead).toList()
            : _notifications.where((n) => n.type == _filter).toList();

    final unreadCount = _notifications.where((n) => !n.isRead).length;

    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          if (unreadCount > 0)
            IconButton(
              icon: const Icon(Icons.done_all),
              onPressed: _markAllRead,
              tooltip: 'Mark all as read',
            ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildFilterChip('All', 'all'),
                const SizedBox(width: 8),
                _buildFilterChip('Unread ($unreadCount)', 'unread'),
                const SizedBox(width: 8),
                _buildFilterChip('Info', 'info'),
                const SizedBox(width: 8),
                _buildFilterChip('Warning', 'warning'),
                const SizedBox(width: 8),
                _buildFilterChip('Success', 'success'),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : filtered.isEmpty
                    ? const Center(child: Text('No notifications'))
                    : ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (ctx, i) {
                          final n = filtered[i];
                          final color = n.type == 'warning'
                              ? AppTheme.warningColor
                              : n.type == 'success'
                                  ? AppTheme.primary500
                                  : n.type == 'error'
                                      ? AppTheme.errorColor
                                      : AppTheme.infoColor;
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: color.withOpacity(0.15),
                                child: Icon(
                                  n.type == 'warning'
                                      ? Icons.warning
                                      : n.type == 'success'
                                          ? Icons.check_circle
                                          : n.type == 'error'
                                              ? Icons.error
                                              : Icons.info,
                                  color: color,
                                ),
                              ),
                              title: Text(
                                n.title,
                                style: TextStyle(
                                  fontWeight: n.isRead ? FontWeight.normal : FontWeight.bold,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(n.message),
                                  Text(
                                    DateFormat('dd MMM HH:mm').format(n.createdAt),
                                    style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary),
                                  ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (!n.isRead)
                                    IconButton(
                                      icon: const Icon(Icons.mark_email_read, color: AppTheme.primary500),
                                      onPressed: () => _markRead(n.id),
                                    ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: AppTheme.errorColor),
                                    onPressed: () => _deleteNotification(n.id),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    return FilterChip(
      label: Text(label),
      selected: _filter == value,
      onSelected: (selected) => setState(() => _filter = value),
      selectedColor: AppTheme.primaryColor.withOpacity(0.2),
      labelStyle: TextStyle(
        color: _filter == value ? AppTheme.primaryColor : AppTheme.textSecondary,
      ),
    );
  }
}
