import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../data/datasources/local_database.dart';
import '../../domain/entities/task.dart';
import '../../domain/entities/app_user.dart';
import '../../presentation/widgets/shared_widgets.dart';

class TaskFormPage extends StatefulWidget {
  final String projectId;
  final Task? task;
  const TaskFormPage({super.key, required this.projectId, this.task});
  @override
  State<TaskFormPage> createState() => _TaskFormPageState();
}

class _TaskFormPageState extends State<TaskFormPage> {
  final _formKey      = GlobalKey<FormState>();
  final _titleCtrl    = TextEditingController();
  final _descCtrl     = TextEditingController();
  final _assignedCtrl = TextEditingController();
  final _estHrsCtrl   = TextEditingController();
  final _actHrsCtrl   = TextEditingController();

  TaskPriority _priority   = TaskPriority.medium;
  TaskStatus   _status     = TaskStatus.todo;
  DateTime     _startDate  = DateTime.now();
  DateTime     _dueDate    = DateTime.now().add(const Duration(days: 7));
  int          _completion = 0;
  bool _loading = false;

  bool get _isEdit => widget.task != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      final t = widget.task!;
      _titleCtrl.text    = t.title;
      _descCtrl.text     = t.description;
      _assignedCtrl.text = t.assignedTo;
      _estHrsCtrl.text   = t.estimatedHours.toString();
      _actHrsCtrl.text   = t.actualHours.toString();
      _priority          = t.priority;
      _status            = t.status;
      _startDate         = t.startDate;
      _dueDate           = t.dueDate;
      _completion        = t.completionPercentage;
    }
  }

  @override
  void dispose() {
    for (final c in [_titleCtrl,_descCtrl,_assignedCtrl,_estHrsCtrl,_actHrsCtrl]) c.dispose();
    super.dispose();
  }

  Future<void> _pickDate(bool isStart) async {
    final d = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _dueDate,
      firstDate: DateTime(2020), lastDate: DateTime(2035),
    );
    if (d != null) setState(() { if (isStart) _startDate = d; else _dueDate = d; });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final task = Task(
      id:                   _isEdit ? widget.task!.id : LocalDatabase.generateId(),
      projectId:            widget.projectId,
      title:                _titleCtrl.text.trim(),
      description:          _descCtrl.text.trim(),
      assignedTo:           _assignedCtrl.text.trim(),
      priority:             _priority,
      status:               _status,
      startDate:            _startDate,
      dueDate:              _dueDate,
      completedAt:          _status == TaskStatus.done ? DateTime.now() : null,
      estimatedHours:       double.tryParse(_estHrsCtrl.text) ?? 0,
      actualHours:          double.tryParse(_actHrsCtrl.text) ?? 0,
      completionPercentage: _completion,
    );
    await LocalDatabase.saveTask(task);
    if (mounted) { setState(() => _loading = false); Navigator.pop(context); }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppTheme.bgColor,
    appBar: AppBar(
      title: Text(_isEdit ? 'Edit task' : 'New task'),
      actions: [
        TextButton(
          onPressed: _loading ? null : _save,
          child: _loading
            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
            : const Text('Save', style: TextStyle(fontWeight: FontWeight.w600)),
        ),
      ],
    ),
    body: Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          _FormCard(children: [
            const _SectionTitle('Task details'),
            const SizedBox(height: 14),
            _Field('Task title *', TextFormField(
              controller: _titleCtrl,
              decoration: const InputDecoration(hintText: 'e.g. Install solar panels'),
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            )),
            const SizedBox(height: 14),
            _Field('Assigned to', TextFormField(
              controller: _assignedCtrl,
              decoration: const InputDecoration(hintText: 'Staff member name'),
            )),
            const SizedBox(height: 14),
            _Field('Description', TextFormField(
              controller: _descCtrl,
              maxLines: 3,
              decoration: const InputDecoration(hintText: 'Task details…'),
            )),
          ]),
          const SizedBox(height: 16),

          _FormCard(children: [
            const _SectionTitle('Priority & status'),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(child: _Field('Priority', DropdownButtonFormField<TaskPriority>(
                value: _priority,
                items: TaskPriority.values.map((p) => DropdownMenuItem(value: p, child: Text(p.label))).toList(),
                onChanged: (v) => setState(() => _priority = v ?? TaskPriority.medium),
              ))),
              const SizedBox(width: 12),
              Expanded(child: _Field('Status', DropdownButtonFormField<TaskStatus>(
                value: _status,
                items: TaskStatus.values.map((s) => DropdownMenuItem(value: s, child: Text(s.label))).toList(),
                onChanged: (v) => setState(() => _status = v ?? TaskStatus.todo),
              ))),
            ]),
            const SizedBox(height: 14),
            _Field('Completion: $_completion%', Slider(
              value: _completion.toDouble(),
              min: 0, max: 100, divisions: 10,
              label: '$_completion%',
              activeColor: AppTheme.primaryColor,
              onChanged: (v) => setState(() => _completion = v.round()),
            )),
          ]),
          const SizedBox(height: 16),

          _FormCard(children: [
            const _SectionTitle('Dates & hours'),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(child: _Field('Start date', _DateBtn(date: _startDate, onTap: () => _pickDate(true)))),
              const SizedBox(width: 12),
              Expanded(child: _Field('Due date', _DateBtn(date: _dueDate, onTap: () => _pickDate(false)))),
            ]),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(child: _Field('Estimated hours', TextFormField(
                controller: _estHrsCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(suffixText: 'hrs'),
              ))),
              const SizedBox(width: 12),
              Expanded(child: _Field('Actual hours', TextFormField(
                controller: _actHrsCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(suffixText: 'hrs'),
              ))),
            ]),
          ]),
          const SizedBox(height: 30),
        ]),
      ),
    ),
  );
}

class _DateBtn extends StatelessWidget {
  final DateTime date; final VoidCallback onTap;
  const _DateBtn({required this.date, required this.onTap});
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(10),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.borderColor),
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
      ),
      child: Row(children: [
        const Icon(Icons.calendar_today_outlined, size: 16, color: AppTheme.textMuted),
        const SizedBox(width: 8),
        Text('${date.day}/${date.month}/${date.year}', style: const TextStyle(fontSize: 14)),
      ]),
    ),
  );
}

class _Field extends StatelessWidget {
  final String label; final Widget child;
  const _Field(this.label, this.child);
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
    const SizedBox(height: 6), child,
  ]);
}

// ── Shared private helpers (copy of shared_widgets.dart for single-file convenience) ──

class _InfoBanner extends StatelessWidget {
  final IconData icon;
  final Color color, bgColor;
  final String message;
  const _InfoBanner({required this.icon, required this.color, required this.bgColor, required this.message});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: bgColor, borderRadius: BorderRadius.circular(10),
      border: Border.all(color: color.withOpacity(0.25)),
    ),
    child: Row(children: [
      Icon(icon, color: color, size: 18),
      const SizedBox(width: 10),
      Expanded(child: Text(message, style: TextStyle(fontSize: 13, color: color))),
    ]),
  );
}

class _FormCard extends StatelessWidget {
  final List<Widget> children;
  const _FormCard({required this.children});
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white, borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppTheme.borderColor, width: 0.5),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
  );
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);
  @override
  Widget build(BuildContext context) => Text(text,
    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary));
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);
  @override
  Widget build(BuildContext context) => Text(text,
    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppTheme.textPrimary));
}

