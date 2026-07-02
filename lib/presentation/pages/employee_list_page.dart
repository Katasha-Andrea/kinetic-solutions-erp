import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../data/datasources/local_database.dart';
import '../../domain/entities/employee.dart';
import '../../domain/entities/app_user.dart';
import 'employee_form_page.dart';

class EmployeeListPage extends StatefulWidget {
  final AppUser currentUser;
  const EmployeeListPage({super.key, required this.currentUser});
  @override
  State<EmployeeListPage> createState() => _EmployeeListPageState();
}

class _EmployeeListPageState extends State<EmployeeListPage> {
  List<Employee> _all = [], _filtered = [];
  String _search = '';
  String _deptFilter = 'All';
  EmploymentStatus? _statusFilter;

  @override
  void initState() { super.initState(); _load(); }

  void _load() { _all = LocalDatabase.getEmployees(); _applyFilters(); }

  void _applyFilters() => setState(() {
    _filtered = _all.where((e) {
      final matchSearch = _search.isEmpty ||
          e.fullName.toLowerCase().contains(_search.toLowerCase()) ||
          e.position.toLowerCase().contains(_search.toLowerCase());
      final matchDept = _deptFilter == 'All' || e.department == _deptFilter;
      final matchStatus = _statusFilter == null || e.status == _statusFilter;
      return matchSearch && matchDept && matchStatus;
    }).toList();
  });

  List<String> get _departments => ['All', ..._all.map((e) => e.department).toSet().toList()..sort()];

  Future<void> _delete(Employee emp) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Remove employee'),
        content: Text('Remove ${emp.fullName} from the system?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true),
              child: const Text('Remove', style: TextStyle(color: AppTheme.errorColor))),
        ],
      ),
    );
    if (ok == true) { await LocalDatabase.deleteEmployee(emp.id); setState(_load); }
  }

  @override
  Widget build(BuildContext context) {
    final active     = _all.where((e) => e.status == EmploymentStatus.active).length;
    final onLeave    = _all.where((e) => e.status == EmploymentStatus.onLeave).length;
    final totalPayroll = _all
        .where((e) => e.status == EmploymentStatus.active)
        .fold(0.0, (sum, e) => sum + e.netSalary);

    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      body: Column(children: [
        // Header
        Container(
          padding: const EdgeInsets.all(20),
          color: Colors.white,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Expanded(child: Text('Staff', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
              if (widget.currentUser.role.canEditEmployees)
                ElevatedButton.icon(
                  onPressed: () async {
                    await Navigator.push(context, MaterialPageRoute(builder: (_) => const EmployeeFormPage()));
                    setState(_load);
                  },
                  icon: const Icon(Icons.person_add_outlined, size: 16),
                  label: const Text('Add staff'),
                ),
            ]),
            const SizedBox(height: 16),
            Row(children: [
              _SummaryChip('Active', '$active', AppTheme.primaryColor),
              const SizedBox(width: 10),
              _SummaryChip('On leave', '$onLeave', AppTheme.accentColor),
              const SizedBox(width: 10),
              _SummaryChip('Net payroll', '${AppConstants.currencySymbol} ${totalPayroll.toStringAsFixed(0)}', AppTheme.infoColor),
            ]),
          ]),
        ),

        // Search + filters
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(color: AppTheme.borderColor, width: 0.5),
              bottom: BorderSide(color: AppTheme.borderColor, width: 0.5),
            ),
          ),
          child: Row(children: [
            Expanded(child: TextField(
              onChanged: (v) { _search = v; _applyFilters(); },
              decoration: const InputDecoration(
                hintText: 'Search by name or position…',
                prefixIcon: Icon(Icons.search, size: 18),
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              ),
            )),
            const SizedBox(width: 12),
            DropdownButton<String>(
              value: _deptFilter,
              underline: const SizedBox(),
              items: _departments.map((d) => DropdownMenuItem(value: d, child: Text(d, style: const TextStyle(fontSize: 13)))).toList(),
              onChanged: (v) { if (v != null) { _deptFilter = v; _applyFilters(); } },
            ),
            const SizedBox(width: 12),
            DropdownButton<EmploymentStatus?>(
              value: _statusFilter,
              underline: const SizedBox(),
              items: [
                const DropdownMenuItem(value: null, child: Text('All status', style: TextStyle(fontSize: 13))),
                ...EmploymentStatus.values.map((s) => DropdownMenuItem(value: s, child: Text(s.label, style: const TextStyle(fontSize: 13)))),
              ],
              onChanged: (v) { _statusFilter = v; _applyFilters(); },
            ),
          ]),
        ),

        Expanded(
          child: _filtered.isEmpty
            ? _EmptyState(icon: Icons.people_outline, title: 'No staff found',
                subtitle: _search.isNotEmpty ? 'Try a different search' : 'Add your first staff member')
            : ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: _filtered.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) => _EmployeeCard(
                  employee: _filtered[i],
                  canEdit: widget.currentUser.role.canEditEmployees,
                  onEdit: () async {
                    await Navigator.push(context, MaterialPageRoute(
                        builder: (_) => EmployeeFormPage(employee: _filtered[i])));
                    setState(_load);
                  },
                  onDelete: () => _delete(_filtered[i]),
                ),
              ),
        ),
      ]),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final String label, value;
  final Color color;
  const _SummaryChip(this.label, this.value, this.color);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(8),
      border: Border.all(color: color.withOpacity(0.2))),
    child: Column(children: [
      Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: color)),
      Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
    ]),
  );
}

class _EmployeeCard extends StatelessWidget {
  final Employee employee;
  final bool canEdit;
  final VoidCallback onEdit, onDelete;
  const _EmployeeCard({required this.employee, required this.canEdit, required this.onEdit, required this.onDelete});

  Color get _statusColor {
    switch (employee.status) {
      case EmploymentStatus.active:     return AppTheme.primaryColor;
      case EmploymentStatus.onLeave:    return AppTheme.accentColor;
      case EmploymentStatus.suspended:  return AppTheme.warningColor;
      case EmploymentStatus.terminated: return AppTheme.errorColor;
    }
  }

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppTheme.borderColor, width: 0.5),
    ),
    child: Row(children: [
      CircleAvatar(
        radius: 24,
        backgroundColor: AppTheme.primaryColor,
        child: Text(employee.initials, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      const SizedBox(width: 14),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(employee.fullName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: _statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(employee.status.label,
              style: TextStyle(fontSize: 10, color: _statusColor, fontWeight: FontWeight.w600)),
          ),
        ]),
        const SizedBox(height: 3),
        Text('${employee.position}  ·  ${employee.department}',
          style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
        const SizedBox(height: 8),
        Row(children: [
          _EmpStat('Gross', '${AppConstants.currencySymbol} ${employee.grossSalary.toStringAsFixed(0)}'),
          const SizedBox(width: 16),
          _EmpStat('PAYE', '${AppConstants.currencySymbol} ${employee.payeMonthly.toStringAsFixed(0)}'),
          const SizedBox(width: 16),
          _EmpStat('NAPSA', '${AppConstants.currencySymbol} ${employee.napsaContribution.toStringAsFixed(0)}'),
          const SizedBox(width: 16),
          _EmpStat('Net', '${AppConstants.currencySymbol} ${employee.netSalary.toStringAsFixed(0)}', highlight: true),
        ]),
        if (employee.nrc.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text('NRC: ${employee.nrc}', style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
        ],
      ])),
      if (canEdit) PopupMenuButton<String>(
        icon: const Icon(Icons.more_vert, size: 18, color: AppTheme.textMuted),
        onSelected: (v) { if (v == 'edit') onEdit(); else onDelete(); },
        itemBuilder: (_) => [
          const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit_outlined, size: 16), SizedBox(width: 8), Text('Edit')])),
          const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete_outline, size: 16, color: AppTheme.errorColor), SizedBox(width: 8), Text('Remove', style: TextStyle(color: AppTheme.errorColor))])),
        ],
      ),
    ]),
  );
}

class _EmpStat extends StatelessWidget {
  final String label, value;
  final bool highlight;
  const _EmpStat(this.label, this.value, {this.highlight = false});
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(label, style: const TextStyle(fontSize: 10, color: AppTheme.textMuted)),
    Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
      color: highlight ? AppTheme.primaryColor : AppTheme.textPrimary)),
  ]);
}

class _EmptyState extends StatelessWidget {
  final IconData icon; final String title, subtitle;
  const _EmptyState({required this.icon, required this.title, required this.subtitle});
  @override
  Widget build(BuildContext context) => Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    Icon(icon, size: 56, color: AppTheme.textMuted),
    const SizedBox(height: 14),
    Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
    const SizedBox(height: 4),
    Text(subtitle, style: const TextStyle(fontSize: 13, color: AppTheme.textMuted)),
  ]));
}
