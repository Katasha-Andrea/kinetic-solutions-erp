import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../data/datasources/local_database.dart';
import '../../domain/entities/project.dart';
import '../../domain/entities/app_user.dart';
import '../../presentation/widgets/shared_widgets.dart';

class ProjectFormPage extends StatefulWidget {
  final Project? project;
  const ProjectFormPage({super.key, this.project});
  @override
  State<ProjectFormPage> createState() => _ProjectFormPageState();
}

class _ProjectFormPageState extends State<ProjectFormPage> {
  final _formKey     = GlobalKey<FormState>();
  final _nameCtrl    = TextEditingController();
  final _descCtrl    = TextEditingController();
  final _clientCtrl  = TextEditingController();
  final _pmCtrl      = TextEditingController();
  final _locationCtrl= TextEditingController();
  final _budgetCtrl  = TextEditingController();
  final _spentCtrl   = TextEditingController();
  final _teamCtrl    = TextEditingController();
  final _notesCtrl   = TextEditingController();

  String        _category = 'IT';
  ProjectStatus _status   = ProjectStatus.planning;
  RiskLevel     _risk     = RiskLevel.low;
  DateTime      _start    = DateTime.now();
  DateTime      _end      = DateTime.now().add(const Duration(days: 90));
  bool _loading = false;

  static const _categories = ['IT','Construction','Agriculture','Logistics','Finance','HR','Operations','Other'];
  bool get _isEdit => widget.project != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      final p = widget.project!;
      _nameCtrl.text     = p.name;
      _descCtrl.text     = p.description;
      _clientCtrl.text   = p.clientName;
      _pmCtrl.text       = p.projectManager;
      _locationCtrl.text = p.location;
      _budgetCtrl.text   = p.budget.toStringAsFixed(2);
      _spentCtrl.text    = p.spent.toStringAsFixed(2);
      _teamCtrl.text     = p.teamSize.toString();
      _notesCtrl.text    = p.notes;
      _category          = p.category;
      _status            = p.status;
      _risk              = p.riskLevel;
      _start             = p.startDate;
      _end               = p.endDate;
    }
  }

  @override
  void dispose() {
    for (final c in [_nameCtrl,_descCtrl,_clientCtrl,_pmCtrl,_locationCtrl,_budgetCtrl,_spentCtrl,_teamCtrl,_notesCtrl]) c.dispose();
    super.dispose();
  }

  Future<void> _pickDate(bool isStart) async {
    final d = await showDatePicker(
      context: context,
      initialDate: isStart ? _start : _end,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (d != null) setState(() { if (isStart) _start = d; else _end = d; });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final now = DateTime.now();
    final p = Project(
      id:             _isEdit ? widget.project!.id : LocalDatabase.generateId(),
      name:           _nameCtrl.text.trim(),
      description:    _descCtrl.text.trim(),
      clientName:     _clientCtrl.text.trim(),
      projectManager: _pmCtrl.text.trim(),
      location:       _locationCtrl.text.trim(),
      category:       _category,
      startDate:      _start,
      endDate:        _end,
      budget:         double.tryParse(_budgetCtrl.text) ?? 0,
      spent:          double.tryParse(_spentCtrl.text)  ?? 0,
      status:         _status,
      teamSize:       int.tryParse(_teamCtrl.text) ?? 1,
      riskLevel:      _risk,
      notes:          _notesCtrl.text.trim(),
      createdAt:      _isEdit ? widget.project!.createdAt : now,
      updatedAt:      now,
    );
    await LocalDatabase.saveProject(p);
    if (mounted) { setState(() => _loading = false); Navigator.pop(context); }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppTheme.bgColor,
    appBar: AppBar(
      title: Text(_isEdit ? 'Edit project' : 'New project'),
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
            const _SectionTitle('Project details'),
            const SizedBox(height: 14),
            _Field('Project name *', TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(hintText: 'e.g. Warehouse Expansion'),
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            )),
            const SizedBox(height: 14),
            _Field('Client name *', TextFormField(
              controller: _clientCtrl,
              decoration: const InputDecoration(hintText: 'Client or company name'),
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            )),
            const SizedBox(height: 14),
            _Field('Project manager *', TextFormField(
              controller: _pmCtrl,
              decoration: const InputDecoration(hintText: 'Responsible manager'),
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            )),
            const SizedBox(height: 14),
            _Field('Location', TextFormField(
              controller: _locationCtrl,
              decoration: const InputDecoration(hintText: 'e.g. Lusaka, Copperbelt'),
            )),
            const SizedBox(height: 14),
            _Field('Category', DropdownButtonFormField<String>(
              value: _category,
              items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (v) => setState(() => _category = v ?? 'IT'),
            )),
            const SizedBox(height: 14),
            _Field('Description', TextFormField(
              controller: _descCtrl,
              maxLines: 3,
              decoration: const InputDecoration(hintText: 'Project overview…'),
            )),
          ]),
          const SizedBox(height: 16),

          _FormCard(children: [
            const _SectionTitle('Timeline & team'),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(child: _Field('Start date', _DateBtn(
                date: _start, onTap: () => _pickDate(true)))),
              const SizedBox(width: 12),
              Expanded(child: _Field('End date', _DateBtn(
                date: _end, onTap: () => _pickDate(false)))),
            ]),
            const SizedBox(height: 14),
            _Field('Team size', TextFormField(
              controller: _teamCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(hintText: '1', suffixText: 'members'),
            )),
          ]),
          const SizedBox(height: 16),

          _FormCard(children: [
            const _SectionTitle('Budget & status'),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(child: _Field('Total budget (ZMW)', TextFormField(
                controller: _budgetCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(prefixText: 'K '),
              ))),
              const SizedBox(width: 12),
              Expanded(child: _Field('Amount spent (ZMW)', TextFormField(
                controller: _spentCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(prefixText: 'K '),
              ))),
            ]),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(child: _Field('Status', DropdownButtonFormField<ProjectStatus>(
                value: _status,
                items: ProjectStatus.values.map((s) => DropdownMenuItem(value: s, child: Text(s.label))).toList(),
                onChanged: (v) => setState(() => _status = v ?? ProjectStatus.planning),
              ))),
              const SizedBox(width: 12),
              Expanded(child: _Field('Risk level', DropdownButtonFormField<RiskLevel>(
                value: _risk,
                items: RiskLevel.values.map((r) => DropdownMenuItem(value: r, child: Text(r.label))).toList(),
                onChanged: (v) => setState(() => _risk = v ?? RiskLevel.low),
              ))),
            ]),
            const SizedBox(height: 14),
            _Field('Notes', TextFormField(
              controller: _notesCtrl,
              maxLines: 3,
              decoration: const InputDecoration(hintText: 'Additional notes…'),
            )),
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

