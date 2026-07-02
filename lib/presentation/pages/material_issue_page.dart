// lib/presentation/pages/material_issue_page.dart
import 'package:flutter/material.dart';
import 'package:kinetic_solutions/core/auth/auth_service.dart';
import 'package:kinetic_solutions/core/theme/app_theme.dart';
import 'package:kinetic_solutions/data/datasources/local_database.dart';
import 'package:kinetic_solutions/domain/entities/material_issue.dart';
import 'package:kinetic_solutions/presentation/pages/material_issue_form_page.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/app_user.dart';

class MaterialIssuePage extends StatefulWidget {
  final AppUser currentUser;
  const MaterialIssuePage({super.key, required this.currentUser});

  @override
  State<MaterialIssuePage> createState() => _MaterialIssuePageState();
}

class _MaterialIssuePageState extends State<MaterialIssuePage> {
  List<MaterialIssue> _issues = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final data = LocalDatabase.getMaterialIssues();
    setState(() {
      _issues = data;
      _isLoading = false;
    });
  }

  Future<void> _navigateToForm({MaterialIssue? issue}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => MaterialIssueFormPage(currentUser: widget.currentUser, issue: issue)),
    );
    await _loadData();
  }

  Future<void> _deleteIssue(MaterialIssue issue) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete MIV'),
        content: Text('Delete ${issue.issueNumber}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete', style: TextStyle(color: AppTheme.errorColor))),
        ],
      ),
    );
    if (confirmed == true) {
      await LocalDatabase.deleteMaterialIssue(issue.id);
      await _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final canEdit = widget.currentUser.role.canEditInventory;
    final total = _issues.length;
    final issued = _issues.where((i) => i.status == MIVStatus.issued).length;
    final returned = _issues.where((i) => i.status == MIVStatus.returned).length;

    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      appBar: AppBar(
        title: const Text('Material Issues'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          if (canEdit)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _navigateToForm(),
            ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildStat('Total', total, Colors.teal),
                const SizedBox(width: 12),
                _buildStat('Issued', issued, AppTheme.primary500),
                const SizedBox(width: 12),
                _buildStat('Returned', returned, AppTheme.infoColor),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _issues.isEmpty
                    ? const Center(child: Text('No material issues'))
                    : ListView.builder(
                        itemCount: _issues.length,
                        itemBuilder: (ctx, i) {
                          final issue = _issues[i];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: issue.status == MIVStatus.issued ? AppTheme.primary50 : Colors.grey.shade200,
                                child: Icon(Icons.inventory, color: issue.status == MIVStatus.issued ? AppTheme.primary500 : Colors.grey),
                              ),
                              title: Text('${issue.issueNumber} - ${issue.projectName}'),
                              subtitle: Text('Requested by: ${issue.requestedBy}\nItems: ${issue.items.length}'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Chip(
                                    label: Text(issue.status.name),
                                    backgroundColor: issue.status == MIVStatus.issued ? AppTheme.primary50 : Colors.grey.shade200,
                                  ),
                                  if (canEdit)
                                    PopupMenuButton(
                                      onSelected: (value) {
                                        if (value == 'edit') _navigateToForm(issue: issue);
                                        else if (value == 'delete') _deleteIssue(issue);
                                      },
                                      itemBuilder: (ctx) => const [
                                        PopupMenuItem(value: 'edit', child: Text('Edit')),
                                        PopupMenuItem(value: 'delete', child: Text('Delete')),
                                      ],
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

  Widget _buildStat(String label, int value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value.toString(), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color)),
            Text(label, style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
          ],
        ),
      ),
    );
  }
}
