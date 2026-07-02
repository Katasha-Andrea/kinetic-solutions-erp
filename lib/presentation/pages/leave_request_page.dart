// lib/presentation/pages/leave_request_page.dart
import 'package:flutter/material.dart';
import 'package:kinetic_solutions/core/auth/auth_service.dart';
import 'package:kinetic_solutions/core/theme/app_theme.dart';
import 'package:kinetic_solutions/data/datasources/local_database.dart';
import 'package:kinetic_solutions/domain/entities/leave_request.dart';
import 'package:kinetic_solutions/domain/entities/employee.dart';
import 'package:kinetic_solutions/presentation/pages/leave_request_form_page.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/app_user.dart';

class LeaveRequestPage extends StatefulWidget {
  final AppUser currentUser;
  const LeaveRequestPage({super.key, required this.currentUser});

  @override
  State<LeaveRequestPage> createState() => _LeaveRequestPageState();
}

class _LeaveRequestPageState extends State<LeaveRequestPage> {
  List<LeaveRequest> _requests = [];
  List<Employee> _employees = [];
  bool _isLoading = true;
  String _filterStatus = 'All';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final reqs = LocalDatabase.getLeaveRequests();
    final emps = LocalDatabase.getEmployees();
    setState(() {
      _requests = reqs;
      _employees = emps;
      _isLoading = false;
    });
  }

  String _getEmployeeName(String id) {
    final emp = _employees.firstWhere((e) => e.id == id, orElse: () => throw Exception("Not found"));
    return emp?.fullName ?? 'Unknown';
  }

  Color _getStatusColor(LeaveStatus status) {
    switch (status) {
      case LeaveStatus.pending: return AppTheme.warningColor;
      case LeaveStatus.approved: return AppTheme.primary500;
      case LeaveStatus.rejected: return AppTheme.errorColor;
      case LeaveStatus.cancelled: return AppTheme.textMuted;
    }
  }

  Future<void> _navigateToForm({LeaveRequest? request}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => LeaveRequestFormPage(currentUser: widget.currentUser, request: request)),
    );
    await _loadData();
  }

  Future<void> _deleteRequest(LeaveRequest req) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Leave Request'),
        content: Text('Delete request for ${_getEmployeeName(req.employeeId)}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete', style: TextStyle(color: AppTheme.errorColor))),
        ],
      ),
    );
    if (confirmed == true) {
      await LocalDatabase.deleteLeaveRequest(req.id);
      await _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isManager = widget.currentUser.role.canEditEmployees;
    final filtered = _filterStatus == 'All' ? _requests : _requests.where((r) => r.status.name == _filterStatus).toList();

    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      appBar: AppBar(
        title: const Text('Leave Requests'),
        backgroundColor: AppTheme.infoColor,
        foregroundColor: Colors.white,
        actions: [
          if (isManager)
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
                _buildStat('Total', _requests.length, AppTheme.infoColor),
                const SizedBox(width: 12),
                _buildStat('Pending', _requests.where((r) => r.status == LeaveStatus.pending).length, AppTheme.warningColor),
                const SizedBox(width: 12),
                _buildStat('Approved', _requests.where((r) => r.status == LeaveStatus.approved).length, AppTheme.primary500),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: DropdownButton<String>(
              value: _filterStatus,
              items: ['All', ...LeaveStatus.values.map((e) => e.name)].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (val) => setState(() => _filterStatus = val!),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : filtered.isEmpty
                    ? const Center(child: Text('No leave requests'))
                    : ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (ctx, i) {
                          final r = filtered[i];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: _getStatusColor(r.status).withOpacity(0.2),
                                child: Icon(Icons.beach_access, color: _getStatusColor(r.status)),
                              ),
                              title: Text('${_getEmployeeName(r.employeeId)} - ${r.type.name}'),
                              subtitle: Text('${DateFormat('dd MMM').format(r.startDate)} - ${DateFormat('dd MMM yyyy').format(r.endDate)} (${r.days} days)\n${r.reason}'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Chip(label: Text(r.status.name), backgroundColor: _getStatusColor(r.status).withOpacity(0.2)),
                                  if (isManager)
                                    PopupMenuButton(
                                      onSelected: (value) async {
                                        if (value == 'edit') {
                                          _navigateToForm(request: r);
                                        } else if (value == 'delete') {
                                          _deleteRequest(r);
                                        } else if (value == 'approve') {
                                          final updated = LeaveRequest(
                                            id: r.id,
                                            employeeId: r.employeeId,
                                            type: r.type,
                                            startDate: r.startDate,
                                            endDate: r.endDate,
                                            days: r.days,
                                            reason: r.reason,
                                            status: LeaveStatus.approved,
                                            approvedBy: widget.currentUser.id,
                                            approvedAt: DateTime.now(),
                                          );
                                          await LocalDatabase.saveLeaveRequest(updated);
                                          await _loadData();
                                        } else if (value == 'reject') {
                                          final updated = LeaveRequest(
                                            id: r.id,
                                            employeeId: r.employeeId,
                                            type: r.type,
                                            startDate: r.startDate,
                                            endDate: r.endDate,
                                            days: r.days,
                                            reason: r.reason,
                                            status: LeaveStatus.rejected,
                                            approvedBy: widget.currentUser.id,
                                            approvedAt: DateTime.now(),
                                          );
                                          await LocalDatabase.saveLeaveRequest(updated);
                                          await _loadData();
                                        }
                                      },
                                      itemBuilder: (ctx) {
                                        final items = <PopupMenuItem>[];
                                        if (r.status == LeaveStatus.pending) {
                                          items.add(const PopupMenuItem(value: 'approve', child: Text('Approve')));
                                          items.add(const PopupMenuItem(value: 'reject', child: Text('Reject')));
                                        }
                                        items.add(const PopupMenuItem(value: 'edit', child: Text('Edit')));
                                        items.add(const PopupMenuItem(value: 'delete', child: Text('Delete')));
                                        return items;
                                      },
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
