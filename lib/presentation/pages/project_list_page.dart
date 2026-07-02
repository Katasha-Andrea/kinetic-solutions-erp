import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../data/datasources/local_database.dart';
import '../../domain/entities/project.dart';
import '../../domain/entities/app_user.dart';
import 'project_form_page.dart';
import 'project_detail_page.dart';

class ProjectListPage extends StatefulWidget {
  final AppUser currentUser;
  const ProjectListPage({super.key, required this.currentUser});
  @override
  State<ProjectListPage> createState() => _ProjectListPageState();
}

class _ProjectListPageState extends State<ProjectListPage> {
  List<Project> _all = [], _filtered = [];
  String _search = '';
  ProjectStatus? _statusFilter;
  RiskLevel?     _riskFilter;

  @override
  void initState() { super.initState(); _load(); }

  void _load() { _all = LocalDatabase.getProjects(); _applyFilters(); }

  void _applyFilters() => setState(() {
    _filtered = _all.where((p) {
      final matchSearch = _search.isEmpty ||
          p.name.toLowerCase().contains(_search.toLowerCase()) ||
          p.clientName.toLowerCase().contains(_search.toLowerCase());
      final matchStatus = _statusFilter == null || p.status == _statusFilter;
      final matchRisk   = _riskFilter   == null || p.riskLevel == _riskFilter;
      return matchSearch && matchStatus && matchRisk;
    }).toList();
  });

  Future<void> _delete(Project p) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete project'),
        content: Text('Delete "${p.name}"? All tasks and milestones will be removed.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete', style: TextStyle(color: AppTheme.errorColor))),
        ],
      ),
    );
    if (ok == true) { await LocalDatabase.deleteProject(p.id); setState(_load); }
  }

  @override
  Widget build(BuildContext context) {
    final inProgress = _all.where((p) => p.status == ProjectStatus.inProgress).length;
    final atRisk     = _all.where((p) => p.isAtRisk).length;
    final overdue    = _all.where((p) => p.isOverdue).length;

    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      body: Column(children: [
        // Header
        Container(
          padding: const EdgeInsets.all(20),
          color: Colors.white,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Expanded(child: Text('Projects', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
              if (widget.currentUser.role.canEditProjects)
                ElevatedButton.icon(
                  onPressed: () async {
                    await Navigator.push(context, MaterialPageRoute(builder: (_) => const ProjectFormPage()));
                    setState(_load);
                  },
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('New project'),
                ),
            ]),
            const SizedBox(height: 16),
            Row(children: [
              _Chip('In progress', '$inProgress', AppTheme.primaryColor),
              const SizedBox(width: 10),
              _Chip('At risk', '$atRisk', AppTheme.warningColor),
              const SizedBox(width: 10),
              _Chip('Overdue', '$overdue', AppTheme.errorColor),
            ]),
          ]),
        ),

        // Filters
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
                hintText: 'Search projects or clients…',
                prefixIcon: Icon(Icons.search, size: 18),
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              ),
            )),
            const SizedBox(width: 12),
            DropdownButton<ProjectStatus?>(
              value: _statusFilter,
              underline: const SizedBox(),
              items: [
                const DropdownMenuItem(value: null, child: Text('All status', style: TextStyle(fontSize: 13))),
                ...ProjectStatus.values.map((s) => DropdownMenuItem(value: s, child: Text(s.label, style: const TextStyle(fontSize: 13)))),
              ],
              onChanged: (v) { _statusFilter = v; _applyFilters(); },
            ),
            const SizedBox(width: 12),
            DropdownButton<RiskLevel?>(
              value: _riskFilter,
              underline: const SizedBox(),
              items: [
                const DropdownMenuItem(value: null, child: Text('All risk', style: TextStyle(fontSize: 13))),
                ...RiskLevel.values.map((r) => DropdownMenuItem(value: r, child: Text(r.label, style: const TextStyle(fontSize: 13)))),
              ],
              onChanged: (v) { _riskFilter = v; _applyFilters(); },
            ),
          ]),
        ),

        Expanded(
          child: _filtered.isEmpty
            ? _EmptyState(icon: Icons.work_outline, title: 'No projects found',
                subtitle: _search.isNotEmpty ? 'Try a different search' : 'Create your first project')
            : ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: _filtered.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, i) => _ProjectCard(
                  project: _filtered[i],
                  canEdit: widget.currentUser.role.canEditProjects,
                  onTap: () async {
                    await Navigator.push(context, MaterialPageRoute(
                      builder: (_) => ProjectDetailPage(project: _filtered[i], currentUser: widget.currentUser),
                    ));
                    setState(_load);
                  },
                  onEdit: () async {
                    await Navigator.push(context, MaterialPageRoute(
                      builder: (_) => ProjectFormPage(project: _filtered[i]),
                    ));
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

class _Chip extends StatelessWidget {
  final String label, value; final Color color;
  const _Chip(this.label, this.value, this.color);
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

class _ProjectCard extends StatelessWidget {
  final Project project;
  final bool canEdit;
  final VoidCallback onTap, onEdit, onDelete;
  const _ProjectCard({required this.project, required this.canEdit, required this.onTap, required this.onEdit, required this.onDelete});

  Color get _riskColor {
    switch (project.riskLevel) {
      case RiskLevel.low:      return AppTheme.primaryColor;
      case RiskLevel.medium:   return AppTheme.accentColor;
      case RiskLevel.high:     return AppTheme.warningColor;
      case RiskLevel.critical: return AppTheme.errorColor;
    }
  }

  Color get _statusColor {
    if (project.isOverdue) return AppTheme.errorColor;
    switch (project.status) {
      case ProjectStatus.inProgress:  return AppTheme.primaryColor;
      case ProjectStatus.planning:    return AppTheme.infoColor;
      case ProjectStatus.completed:   return AppTheme.primary700;
      case ProjectStatus.onHold:      return AppTheme.accentColor;
      case ProjectStatus.cancelled:   return AppTheme.textMuted;
    }
  }

  String get _statusLabel => project.isOverdue ? 'Overdue' : project.status.label;

  @override
  Widget build(BuildContext context) {
    final util = project.budgetUtilization.clamp(0.0, 100.0);
    final daysLeft = project.endDate.difference(DateTime.now()).inDays;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: project.isOverdue ? AppTheme.errorColor.withOpacity(0.4)
              : project.isAtRisk ? AppTheme.warningColor.withOpacity(0.3)
              : AppTheme.borderColor,
            width: (project.isOverdue || project.isAtRisk) ? 1 : 0.5,
          ),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(project.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text('${project.clientName}  ·  ${project.category}',
                style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
            ])),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: _statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(_statusLabel, style: TextStyle(fontSize: 11, color: _statusColor, fontWeight: FontWeight.w600)),
            ),
            if (canEdit) PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, size: 18, color: AppTheme.textMuted),
              onSelected: (v) { if (v == 'edit') onEdit(); else onDelete(); },
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit_outlined, size: 16), SizedBox(width: 8), Text('Edit')])),
                const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete_outline, size: 16, color: AppTheme.errorColor), SizedBox(width: 8), Text('Delete', style: TextStyle(color: AppTheme.errorColor))])),
              ],
            ),
          ]),
          const SizedBox(height: 14),

          // Budget bar
          Row(children: [
            const Expanded(child: Text('Budget utilisation', style: TextStyle(fontSize: 12, color: AppTheme.textMuted))),
            Text('${util.toStringAsFixed(0)}%', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          ]),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: util / 100,
              minHeight: 6,
              backgroundColor: AppTheme.bgColor,
              color: util > 90 ? AppTheme.errorColor : util > 70 ? AppTheme.accentColor : AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 12),

          Row(children: [
            _ProjStat(Icons.people_outline, '${project.teamSize} members'),
            const SizedBox(width: 16),
            _ProjStat(Icons.calendar_today_outlined,
              daysLeft < 0 ? '${-daysLeft}d overdue' : '$daysLeft days left'),
            const SizedBox(width: 16),
            _ProjStat(Icons.warning_amber_outlined, 'Risk: ${project.riskLevel.label}',
              color: _riskColor),
          ]),
        ]),
      ),
    );
  }
}

class _ProjStat extends StatelessWidget {
  final IconData icon; final String label; final Color? color;
  const _ProjStat(this.icon, this.label, {this.color});
  @override
  Widget build(BuildContext context) => Row(children: [
    Icon(icon, size: 13, color: color ?? AppTheme.textMuted),
    const SizedBox(width: 4),
    Text(label, style: TextStyle(fontSize: 11, color: color ?? AppTheme.textMuted)),
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
