// lib/presentation/pages/timesheet_page.dart
import 'package:flutter/material.dart';
import 'package:kinetic_solutions/core/auth/auth_service.dart';
import 'package:kinetic_solutions/core/theme/app_theme.dart';
import 'package:kinetic_solutions/data/datasources/local_database.dart';
import 'package:kinetic_solutions/domain/entities/timesheet.dart';
import 'package:kinetic_solutions/domain/entities/employee.dart';
import 'package:kinetic_solutions/domain/entities/project.dart';
import 'package:kinetic_solutions/presentation/pages/timesheet_form_page.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/app_user.dart';

class TimesheetPage extends StatefulWidget {
  final AppUser currentUser;

  const TimesheetPage({super.key, required this.currentUser});

  @override
  State<TimesheetPage> createState() => _TimesheetPageState();
}

class _TimesheetPageState extends State<TimesheetPage> {
  List<Timesheet> _timesheets = [];
  List<Employee> _employees = [];
  List<Project> _projects = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final ts = LocalDatabase.getTimesheets();
    final emps = LocalDatabase.getEmployees();
    final projs = LocalDatabase.getProjects();
    setState(() {
      _timesheets = ts..sort((a, b) => b.date.compareTo(a.date));
      _employees = emps;
      _projects = projs;
      _isLoading = false;
    });
  }

  String _getEmployeeName(String id) {
    final e = _employees.firstWhere((e) => e.id == id, orElse: () => throw Exception("Not found"));
    return e?.fullName ?? 'Unknown';
  }

  String _getProjectName(String id) {
    final p = _projects.firstWhere((p) => p.id == id, orElse: () => throw Exception("Not found"));
    return p?.name ?? 'Unknown';
  }

  Future<void> _navigateToForm({Timesheet? ts}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => TimesheetFormPage(currentUser: widget.currentUser, timesheet: ts)),
    );
    await _loadData();
  }

  Future<void> _deleteTimesheet(Timesheet ts) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Timesheet'),
        content: Text('Delete entry for ${DateFormat('dd MMM yyyy').format(ts.date)}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete', style: TextStyle(color: AppTheme.errorColor))),
        ],
      ),
    );
    if (confirmed == true) {
      await LocalDatabase.deleteTimesheet(ts.id);
      await _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final canEdit = widget.currentUser.role.canEditProjects;
    final total = _timesheets.length;
    final totalHours = _timesheets.fold(0.0, (sum, t) => sum + t.hours);

    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      appBar: AppBar(
        title: const Text('Timesheets'),
        backgroundColor: Colors.purple.shade700,
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
                _buildStat('Total Entries', total, Colors.purple.shade700),
                const SizedBox(width: 12),
                _buildStat('Total Hours', totalHours, AppTheme.infoColor),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search by employee, project, task...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
              ),
              onChanged: (val) => setState(() => _searchQuery = val),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _timesheets.isEmpty
                    ? const Center(child: Text('No timesheets'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _timesheets.length,
                        itemBuilder: (ctx, i) {
                          final t = _timesheets[i];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: AppTheme.primary50,
                                child: Text(t.hours.toStringAsFixed(1)),
                              ),
                              title: Text(_getEmployeeName(t.employeeId)),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${_getProjectName(t.projectId)} • ${t.task}'),
                                  Text(DateFormat('dd MMM yyyy').format(t.date)),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('${t.hours}h', style: const TextStyle(fontWeight: FontWeight.bold)),
                                  const SizedBox(width: 8),
                                  if (canEdit)
                                    PopupMenuButton(
                                      onSelected: (value) {
                                        if (value == 'edit') _navigateToForm(ts: t);
                                        else if (value == 'delete') _deleteTimesheet(t);
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

  Widget _buildStat(String label, dynamic value, Color color) {
    String display = value is double ? value.toStringAsFixed(1) : value.toString();
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
            Text(display, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color)),
            Text(label, style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
          ],
        ),
      ),
    );
  }
}
