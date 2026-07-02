import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../data/datasources/local_database.dart';
import '../../domain/entities/project.dart';
import '../../domain/entities/task.dart';
import '../../domain/entities/app_user.dart';
import 'task_form_page.dart';
import '../../domain/entities/app_user.dart';

class ProjectDetailPage extends StatefulWidget {
  final Project project;
  final AppUser currentUser;
  const ProjectDetailPage({super.key, required this.project, required this.currentUser});
  @override
  State<ProjectDetailPage> createState() => _ProjectDetailPageState();
}

class _ProjectDetailPageState extends State<ProjectDetailPage> with SingleTickerProviderStateMixin {
  late TabController _tab;
  List<Task> _tasks = [];

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
    _loadTasks();
  }

  void _loadTasks() => setState(() => _tasks = LocalDatabase.getTasksForProject(widget.project.id));

  @override
  void dispose() { _tab.dispose(); super.dispose(); }

  Future<void> _deleteTask(Task t) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete task'),
        content: Text('Delete "${t.title}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete', style: TextStyle(color: AppTheme.errorColor))),
        ],
      ),
    );
    if (ok == true) { await LocalDatabase.deleteTask(t.id); _loadTasks(); }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.project;
    final util = p.budgetUtilization.clamp(0.0, 100.0);

    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      appBar: AppBar(
        title: Text(p.name, overflow: TextOverflow.ellipsis),
        bottom: TabBar(controller: _tab, tabs: const [Tab(text: 'Overview'), Tab(text: 'Tasks'), Tab(text: 'Milestones')]),
      ),
      floatingActionButton: _tab.index == 1 && widget.currentUser.role.canEditProjects
        ? FloatingActionButton.extended(
            onPressed: () async {
              await Navigator.push(context, MaterialPageRoute(
                builder: (_) => TaskFormPage(projectId: p.id),
              ));
              _loadTasks();
            },
            icon: const Icon(Icons.add),
            label: const Text('Add task'),
            backgroundColor: AppTheme.primaryColor,
          )
        : null,
      body: TabBarView(controller: _tab, children: [
        // ── Overview ──
        SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(children: [
            // Status cards
            Row(children: [
              Expanded(child: _InfoCard(label: 'Client', value: p.clientName, icon: Icons.business_outlined)),
              const SizedBox(width: 12),
              Expanded(child: _InfoCard(label: 'Manager', value: p.projectManager, icon: Icons.person_outlined)),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: _InfoCard(label: 'Category', value: p.category, icon: Icons.category_outlined)),
              const SizedBox(width: 12),
              Expanded(child: _InfoCard(label: 'Team size', value: '${p.teamSize} members', icon: Icons.people_outline)),
            ]),
            const SizedBox(height: 20),

            // Budget
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.borderColor, width: 0.5)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Budget utilisation', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 14),
                Row(children: [
                  Expanded(child: _BudgetStat('Total budget', '${AppConstants.currencySymbol} ${p.budget.toStringAsFixed(0)}')),
                  Expanded(child: _BudgetStat('Spent', '${AppConstants.currencySymbol} ${p.spent.toStringAsFixed(0)}')),
                  Expanded(child: _BudgetStat('Remaining', '${AppConstants.currencySymbol} ${(p.budget - p.spent).toStringAsFixed(0)}')),
                ]),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: util / 100, minHeight: 10,
                    backgroundColor: AppTheme.bgColor,
                    color: util > 90 ? AppTheme.errorColor : util > 70 ? AppTheme.accentColor : AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: 6),
                Text('${util.toStringAsFixed(1)}% of budget used',
                  style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
              ]),
            ),
            const SizedBox(height: 16),

            // Timeline
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.borderColor, width: 0.5)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Timeline', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 14),
                Row(children: [
                  Expanded(child: _BudgetStat('Start', '${p.startDate.day}/${p.startDate.month}/${p.startDate.year}')),
                  Expanded(child: _BudgetStat('End', '${p.endDate.day}/${p.endDate.month}/${p.endDate.year}')),
                  Expanded(child: _BudgetStat(
                    p.isOverdue ? 'Overdue by' : 'Days left',
                    '${p.endDate.difference(DateTime.now()).inDays.abs()}d',
                  )),
                ]),
              ]),
            ),
            const SizedBox(height: 16),

            if (p.description.isNotEmpty || p.notes.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.borderColor, width: 0.5)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  if (p.description.isNotEmpty) ...[
                    const Text('Description', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Text(p.description, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                  ],
                  if (p.notes.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    const Text('Notes', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Text(p.notes, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                  ],
                ]),
              ),
          ]),
        ),

        // ── Tasks ──
        _tasks.isEmpty
          ? const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.task_outlined, size: 52, color: AppTheme.textMuted),
              SizedBox(height: 12),
              Text('No tasks yet', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              SizedBox(height: 4),
              Text('Tap + to add the first task', style: TextStyle(fontSize: 13, color: AppTheme.textMuted)),
            ]))
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: _tasks.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) => _TaskCard(
                task: _tasks[i],
                canEdit: widget.currentUser.role.canEditProjects,
                onEdit: () async {
                  await Navigator.push(context, MaterialPageRoute(
                    builder: (_) => TaskFormPage(projectId: widget.project.id, task: _tasks[i]),
                  ));
                  _loadTasks();
                },
                onDelete: () => _deleteTask(_tasks[i]),
                onToggle: () async {
                  final t = _tasks[i];
                  final updated = Task(
                    id: t.id, projectId: t.projectId, title: t.title,
                    description: t.description, assignedTo: t.assignedTo,
                    priority: t.priority,
                    status: t.status == TaskStatus.done ? TaskStatus.inProgress : TaskStatus.done,
                    startDate: t.startDate, dueDate: t.dueDate,
                    completedAt: t.status != TaskStatus.done ? DateTime.now() : null,
                    estimatedHours: t.estimatedHours, actualHours: t.actualHours,
                    completionPercentage: t.status != TaskStatus.done ? 100 : t.completionPercentage,
                  );
                  await LocalDatabase.saveTask(updated);
                  _loadTasks();
                },
              ),
            ),

        // ── Milestones (placeholder) ──
        const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.flag_outlined, size: 52, color: AppTheme.textMuted),
          SizedBox(height: 12),
          Text('Milestones coming soon', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          SizedBox(height: 4),
          Text('Track key project checkpoints here', style: TextStyle(fontSize: 13, color: AppTheme.textMuted)),
        ])),
      ]),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String label, value; final IconData icon;
  const _InfoCard({required this.label, required this.value, required this.icon});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10),
      border: Border.all(color: AppTheme.borderColor, width: 0.5)),
    child: Row(children: [
      Icon(icon, size: 18, color: AppTheme.primaryColor),
      const SizedBox(width: 10),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis),
      ])),
    ]),
  );
}

class _BudgetStat extends StatelessWidget {
  final String label, value;
  const _BudgetStat(this.label, this.value);
  @override
  Widget build(BuildContext context) => Column(children: [
    Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
    Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
  ]);
}

class _TaskCard extends StatelessWidget {
  final Task task;
  final bool canEdit;
  final VoidCallback onEdit, onDelete, onToggle;
  const _TaskCard({required this.task, required this.canEdit, required this.onEdit, required this.onDelete, required this.onToggle});

  Color get _priorityColor {
    switch (task.priority) {
      case TaskPriority.low:      return AppTheme.primaryColor;
      case TaskPriority.medium:   return AppTheme.infoColor;
      case TaskPriority.high:     return AppTheme.accentColor;
      case TaskPriority.critical: return AppTheme.errorColor;
    }
  }

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(
        color: task.isOverdue ? AppTheme.errorColor.withOpacity(0.4) : AppTheme.borderColor,
        width: task.isOverdue ? 1 : 0.5,
      ),
    ),
    child: Row(children: [
      Checkbox(
        value: task.status == TaskStatus.done,
        onChanged: (_) => onToggle(),
        activeColor: AppTheme.primaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(task.title,
          style: TextStyle(
            fontSize: 14, fontWeight: FontWeight.w600,
            decoration: task.status == TaskStatus.done ? TextDecoration.lineThrough : null,
            color: task.status == TaskStatus.done ? AppTheme.textMuted : AppTheme.textPrimary,
          )),
        const SizedBox(height: 3),
        Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
            decoration: BoxDecoration(
              color: _priorityColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(task.priority.label, style: TextStyle(fontSize: 10, color: _priorityColor, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 8),
          Text(task.status.label, style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
          if (task.assignedTo.isNotEmpty) ...[
            const SizedBox(width: 8),
            Text('· ${task.assignedTo}', style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
          ],
          if (task.isOverdue) ...[
            const SizedBox(width: 8),
            const Text('Overdue', style: TextStyle(fontSize: 11, color: AppTheme.errorColor, fontWeight: FontWeight.w500)),
          ],
        ]),
        if (task.completionPercentage > 0) ...[
          const SizedBox(height: 6),
          LinearProgressIndicator(
            value: task.completionPercentage / 100,
            minHeight: 3,
            backgroundColor: AppTheme.bgColor,
            color: AppTheme.primaryColor,
          ),
        ],
      ])),
      if (canEdit) PopupMenuButton<String>(
        icon: const Icon(Icons.more_vert, size: 16, color: AppTheme.textMuted),
        onSelected: (v) { if (v == 'edit') onEdit(); else onDelete(); },
        itemBuilder: (_) => [
          const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit_outlined, size: 16), SizedBox(width: 8), Text('Edit')])),
          const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete_outline, size: 16, color: AppTheme.errorColor), SizedBox(width: 8), Text('Delete', style: TextStyle(color: AppTheme.errorColor))])),
        ],
      ),
    ]),
  );
}
