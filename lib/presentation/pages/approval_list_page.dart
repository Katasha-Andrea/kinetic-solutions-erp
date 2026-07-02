// lib/presentation/pages/approval_list_page.dart
import 'package:flutter/material.dart';
import '../../domain/entities/app_user.dart';
import 'package:kinetic_solutions/core/auth/auth_service.dart';
import 'package:kinetic_solutions/core/theme/app_theme.dart';
import 'package:kinetic_solutions/data/datasources/local_database.dart';
import 'package:kinetic_solutions/domain/entities/approval.dart';
import 'package:intl/intl.dart';

class ApprovalListPage extends StatefulWidget {
  final AppUser currentUser;
  const ApprovalListPage({super.key, required this.currentUser});

  @override
  State<ApprovalListPage> createState() => _ApprovalListPageState();
}

class _ApprovalListPageState extends State<ApprovalListPage> {
  List<Approval> _approvals = [];
  bool _isLoading = true;
  String _filter = 'pending';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final all = LocalDatabase.getApprovals();
    setState(() {
      _approvals = all;
      _isLoading = false;
    });
  }

  Color _getStatusColor(ApprovalStatus status) {
    switch (status) {
      case ApprovalStatus.pending: return AppTheme.warningColor;
      case ApprovalStatus.approved: return AppTheme.primary500;
      case ApprovalStatus.rejected: return AppTheme.errorColor;
      case ApprovalStatus.cancelled: return AppTheme.textMuted;
    }
  }

  Future<void> _approve(Approval a) async {
    final updated = Approval(
      id: a.id,
      type: a.type,
      referenceId: a.referenceId,
      title: a.title,
      details: a.details,
      requestedBy: a.requestedBy,
      status: ApprovalStatus.approved,
      currentLevel: a.currentLevel,
      totalLevels: a.totalLevels,
      steps: a.steps.map((s) => ApprovalStep(
        level: s.level,
        approver: s.approver,
        actualApprover: s.actualApprover ?? widget.currentUser.id,
        comment: s.comment,
        timestamp: DateTime.now(),
        status: ApprovalStatus.approved,
      )).toList(),
      requestedAt: a.requestedAt,
    );
    await LocalDatabase.saveApproval(updated);
    await _loadData();
  }

  Future<void> _reject(Approval a) async {
    final updated = Approval(
      id: a.id,
      type: a.type,
      referenceId: a.referenceId,
      title: a.title,
      details: a.details,
      requestedBy: a.requestedBy,
      status: ApprovalStatus.rejected,
      currentLevel: a.currentLevel,
      totalLevels: a.totalLevels,
      steps: a.steps.map((s) => ApprovalStep(
        level: s.level,
        approver: s.approver,
        actualApprover: s.actualApprover ?? widget.currentUser.id,
        comment: s.comment,
        timestamp: DateTime.now(),
        status: ApprovalStatus.rejected,
      )).toList(),
      requestedAt: a.requestedAt,
    );
    await LocalDatabase.saveApproval(updated);
    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filter == 'pending'
        ? _approvals.where((a) => a.status == ApprovalStatus.pending).toList()
        : _approvals.where((a) => a.status.name == _filter).toList();

    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      appBar: AppBar(
        title: const Text('Approvals'),
        backgroundColor: AppTheme.accentColor,
        foregroundColor: Colors.white,
        actions: [
          DropdownButton<String>(
            value: _filter,
            dropdownColor: Colors.white,
            items: ['pending', 'approved', 'rejected', 'all'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
            onChanged: (val) => setState(() => _filter = val!),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : filtered.isEmpty
              ? const Center(child: Text('No approvals'))
              : ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (ctx, i) {
                    final a = filtered[i];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _getStatusColor(a.status).withOpacity(0.2),
                          child: Icon(Icons.verified, color: _getStatusColor(a.status)),
                        ),
                        title: Text(a.title),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Type: ${a.type.name} • Level ${a.currentLevel}/${a.totalLevels}'),
                            Text('Requested: ${DateFormat('dd MMM HH:mm').format(a.requestedAt)}'),
                            if (a.details.isNotEmpty) Text(a.details, maxLines: 2, overflow: TextOverflow.ellipsis),
                          ],
                        ),
                        trailing: a.status == ApprovalStatus.pending
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.check, color: AppTheme.primary500),
                                    onPressed: () => _approve(a),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.close, color: AppTheme.errorColor),
                                    onPressed: () => _reject(a),
                                  ),
                                ],
                              )
                            : Chip(label: Text(a.status.name), backgroundColor: _getStatusColor(a.status).withOpacity(0.2)),
                      ),
                    );
                  },
                ),
    );
  }
}
