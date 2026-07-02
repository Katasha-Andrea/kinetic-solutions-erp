// lib/presentation/pages/ppe_issue_page.dart
import 'package:flutter/material.dart';
import 'package:kinetic_solutions/core/auth/auth_service.dart';
import 'package:kinetic_solutions/core/theme/app_theme.dart';
import 'package:kinetic_solutions/data/datasources/local_database.dart';
import 'package:kinetic_solutions/domain/entities/ppe_issue.dart';
import 'package:kinetic_solutions/domain/entities/employee.dart';
import 'package:kinetic_solutions/presentation/pages/ppe_issue_form_page.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/app_user.dart';

class PPEIssuePage extends StatefulWidget {
  final AppUser currentUser;

  const PPEIssuePage({super.key, required this.currentUser});

  @override
  State<PPEIssuePage> createState() => _PPEIssuePageState();
}

class _PPEIssuePageState extends State<PPEIssuePage> {
  List<PPEIssue> _issues = [];
  List<Employee> _employees = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final issues = LocalDatabase.getPPEIssues();
    final emps = LocalDatabase.getEmployees();
    setState(() {
      _issues = issues..sort((a, b) => b.issueDate.compareTo(a.issueDate));
      _employees = emps;
      _isLoading = false;
    });
  }

  String _getEmployeeName(String id) {
    final e = _employees.firstWhere((e) => e.id == id, orElse: () => throw Exception("Not found"));
    return e?.fullName ?? 'Unknown';
  }

  Future<void> _navigateToForm({PPEIssue? issue}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PPEIssueFormPage(currentUser: widget.currentUser, issue: issue)),
    );
    await _loadData();
  }

  Future<void> _deleteIssue(PPEIssue issue) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete PPE Issue'),
        content: Text('Delete ${issue.ppeType} x${issue.quantity}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete', style: TextStyle(color: AppTheme.errorColor))),
        ],
      ),
    );
    if (confirmed == true) {
      await LocalDatabase.deletePPEIssue(issue.id);
      await _loadData();
    }
  }

  Future<void> _returnPPE(PPEIssue issue) async {
    final updated = PPEIssue(
      id: issue.id,
      employeeId: issue.employeeId,
      ppeType: issue.ppeType,
      quantity: issue.quantity,
      issueDate: issue.issueDate,
      returnDate: DateTime.now(),
    );
    await LocalDatabase.savePPEIssue(updated);
    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final canEdit = widget.currentUser.role.canEditEmployees;
    final total = _issues.length;
    final active = _issues.where((i) => i.returnDate == null).length;

    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      appBar: AppBar(
        title: const Text('PPE Issues'),
        backgroundColor: Colors.orange.shade700,
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _buildStat('Total', total, Colors.orange.shade700),
                const SizedBox(width: 12),
                _buildStat('Active', active, Colors.green),
                const SizedBox(width: 12),
                _buildStat('Returned', total - active, Colors.grey),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _issues.isEmpty
                    ? const Center(child: Text('No PPE issues'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _issues.length,
                        itemBuilder: (ctx, i) {
                          final p = _issues[i];
                          final isActive = p.returnDate == null;
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: isActive ? Colors.green.shade100 : Colors.grey.shade200,
                                child: Icon(Icons.security, color: isActive ? Colors.green : Colors.grey),
                              ),
                              title: Text('${p.ppeType} x${p.quantity}'),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Employee: ${_getEmployeeName(p.employeeId)}'),
                                  Text('Issued: ${DateFormat('dd MMM yyyy').format(p.issueDate)}'),
                                  if (p.returnDate != null)
                                    Text('Returned: ${DateFormat('dd MMM yyyy').format(p.returnDate!)}'),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (isActive && canEdit)
                                    IconButton(
                                      icon: const Icon(Icons.undo, color: AppTheme.primary500),
                                      onPressed: () => _returnPPE(p),
                                      tooltip: 'Return PPE',
                                    ),
                                  if (canEdit)
                                    PopupMenuButton(
                                      onSelected: (value) {
                                        if (value == 'edit') _navigateToForm(issue: p);
                                        else if (value == 'delete') _deleteIssue(p);
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
