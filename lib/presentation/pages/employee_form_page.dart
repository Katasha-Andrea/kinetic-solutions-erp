import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../data/datasources/local_database.dart';
import '../../domain/entities/employee.dart';
import '../../domain/entities/app_user.dart';
import '../../presentation/widgets/shared_widgets.dart';

class EmployeeFormPage extends StatefulWidget {
  final Employee? employee;
  const EmployeeFormPage({super.key, this.employee});
  @override
  State<EmployeeFormPage> createState() => _EmployeeFormPageState();
}

class _EmployeeFormPageState extends State<EmployeeFormPage> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TabController _tab;

  final _firstNameCtrl   = TextEditingController();
  final _lastNameCtrl    = TextEditingController();
  final _nrcCtrl         = TextEditingController();
  final _napsaCtrl       = TextEditingController();
  final _phoneCtrl       = TextEditingController();
  final _emailCtrl       = TextEditingController();
  final _deptCtrl        = TextEditingController();
  final _positionCtrl    = TextEditingController();
  final _basicCtrl       = TextEditingController();
  final _housingCtrl     = TextEditingController();
  final _transportCtrl   = TextEditingController();

  EmploymentStatus _status = EmploymentStatus.active;
  DateTime? _joinDate;
  bool _loading = false;

  bool get _isEdit => widget.employee != null;

  static const _departments = ['Finance','HR','Sales','Operations','IT','Logistics','Management','Field','Other'];

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
    if (_isEdit) {
      final e = widget.employee!;
      _firstNameCtrl.text  = e.firstName;
      _lastNameCtrl.text   = e.lastName;
      _nrcCtrl.text        = e.nrc;
      _napsaCtrl.text      = e.napsaNumber;
      _phoneCtrl.text      = e.phoneNumber;
      _emailCtrl.text      = e.email;
      _deptCtrl.text       = e.department;
      _positionCtrl.text   = e.position;
      _basicCtrl.text      = e.basicSalary.toStringAsFixed(2);
      _housingCtrl.text    = e.housingAllowance.toStringAsFixed(2);
      _transportCtrl.text  = e.transportAllowance.toStringAsFixed(2);
      _status              = e.status;
      _joinDate            = e.joinDate;
    }
  }

  @override
  void dispose() {
    _tab.dispose();
    for (final c in [_firstNameCtrl,_lastNameCtrl,_nrcCtrl,_napsaCtrl,_phoneCtrl,_emailCtrl,_deptCtrl,_positionCtrl,_basicCtrl,_housingCtrl,_transportCtrl]) c.dispose();
    super.dispose();
  }

  // Live calculations
  double get _basic    => double.tryParse(_basicCtrl.text)     ?? 0;
  double get _housing  => double.tryParse(_housingCtrl.text)   ?? 0;
  double get _transport=> double.tryParse(_transportCtrl.text) ?? 0;

  double get _gross => _basic + _housing + _transport;

  double get _napsa {
    final c = _basic * AppConstants.napsaRate;
    return c > AppConstants.napsaCeiling ? AppConstants.napsaCeiling : c;
  }

  double get _paye {
    final annual = _basic * 12;
    double a = 0;
    if (annual <= AppConstants.payeBand1Max) a = 0;
    else if (annual <= AppConstants.payeBand2Max)
      a = (annual - AppConstants.payeBand1Max) * AppConstants.payeRate2;
    else if (annual <= AppConstants.payeBand3Max)
      a = (AppConstants.payeBand2Max - AppConstants.payeBand1Max) * AppConstants.payeRate2
          + (annual - AppConstants.payeBand2Max) * AppConstants.payeRate3;
    else
      a = (AppConstants.payeBand2Max - AppConstants.payeBand1Max) * AppConstants.payeRate2
          + (AppConstants.payeBand3Max - AppConstants.payeBand2Max) * AppConstants.payeRate3
          + (annual - AppConstants.payeBand3Max) * AppConstants.payeRate4;
    return a / 12;
  }

  double get _net => _gross - _paye - _napsa;

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final emp = Employee(
      id:                _isEdit ? widget.employee!.id : LocalDatabase.generateId(),
      firstName:         _firstNameCtrl.text.trim(),
      lastName:          _lastNameCtrl.text.trim(),
      nrc:               _nrcCtrl.text.trim(),
      napsaNumber:       _napsaCtrl.text.trim(),
      phoneNumber:       _phoneCtrl.text.trim(),
      email:             _emailCtrl.text.trim(),
      department:        _deptCtrl.text.trim(),
      position:          _positionCtrl.text.trim(),
      basicSalary:       _basic,
      housingAllowance:  _housing,
      transportAllowance:_transport,
      status:            _status,
      joinDate:          _joinDate,
    );
    await LocalDatabase.saveEmployee(emp);
    if (mounted) { setState(() => _loading = false); Navigator.pop(context); }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppTheme.bgColor,
    appBar: AppBar(
      title: Text(_isEdit ? 'Edit staff member' : 'Add staff member'),
      bottom: TabBar(controller: _tab, tabs: const [Tab(text: 'Personal'), Tab(text: 'Employment'), Tab(text: 'Salary')]),
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
      child: TabBarView(controller: _tab, children: [
        // ── Personal tab ──
        SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: _FormCard(children: [
            const _SectionTitle('Personal details'),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(child: _Field('First name *', TextFormField(
                controller: _firstNameCtrl,
                decoration: const InputDecoration(hintText: 'e.g. John'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ))),
              const SizedBox(width: 12),
              Expanded(child: _Field('Last name *', TextFormField(
                controller: _lastNameCtrl,
                decoration: const InputDecoration(hintText: 'e.g. Banda'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ))),
            ]),
            const SizedBox(height: 14),
            _Field('NRC Number *', TextFormField(
              controller: _nrcCtrl,
              decoration: const InputDecoration(hintText: '123456/78/1'),
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            )),
            const SizedBox(height: 14),
            _Field('NAPSA Number', TextFormField(
              controller: _napsaCtrl,
              decoration: const InputDecoration(hintText: 'NAPSA registration number'),
            )),
            const SizedBox(height: 14),
            _Field('Phone number *', TextFormField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(hintText: '+260 97X XXX XXX'),
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            )),
            const SizedBox(height: 14),
            _Field('Email address', TextFormField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(hintText: 'john.banda@company.zm'),
            )),
          ]),
        ),

        // ── Employment tab ──
        SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: _FormCard(children: [
            const _SectionTitle('Employment details'),
            const SizedBox(height: 14),
            _Field('Department *', DropdownButtonFormField<String>(
              value: _departments.contains(_deptCtrl.text) ? _deptCtrl.text : null,
              decoration: const InputDecoration(hintText: 'Select department'),
              items: _departments.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
              onChanged: (v) => _deptCtrl.text = v ?? '',
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            )),
            const SizedBox(height: 14),
            _Field('Position / Job title *', TextFormField(
              controller: _positionCtrl,
              decoration: const InputDecoration(hintText: 'e.g. Sales Manager'),
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            )),
            const SizedBox(height: 14),
            _Field('Status', DropdownButtonFormField<EmploymentStatus>(
              value: _status,
              items: EmploymentStatus.values.map((s) => DropdownMenuItem(value: s, child: Text(s.label))).toList(),
              onChanged: (v) => setState(() => _status = v ?? EmploymentStatus.active),
            )),
            const SizedBox(height: 14),
            _Field('Join date', InkWell(
              onTap: () async {
                final d = await showDatePicker(
                  context: context,
                  initialDate: _joinDate ?? DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                );
                if (d != null) setState(() => _joinDate = d);
              },
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
                  Text(
                    _joinDate != null
                      ? '${_joinDate!.day}/${_joinDate!.month}/${_joinDate!.year}'
                      : 'Select join date',
                    style: TextStyle(color: _joinDate != null ? AppTheme.textPrimary : AppTheme.textMuted, fontSize: 14),
                  ),
                ]),
              ),
            )),
          ]),
        ),

        // ── Salary tab ──
        SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(children: [
            _FormCard(children: [
              const _SectionTitle('Salary components (ZMW/month)'),
              const SizedBox(height: 14),
              _Field('Basic salary *', TextFormField(
                controller: _basicCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(prefixText: 'K ', hintText: '0.00'),
                onChanged: (_) => setState(() {}),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              )),
              const SizedBox(height: 14),
              _Field('Housing allowance', TextFormField(
                controller: _housingCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(prefixText: 'K ', hintText: '0.00'),
                onChanged: (_) => setState(() {}),
              )),
              const SizedBox(height: 14),
              _Field('Transport allowance', TextFormField(
                controller: _transportCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(prefixText: 'K ', hintText: '0.00'),
                onChanged: (_) => setState(() {}),
              )),
            ]),
            const SizedBox(height: 16),

            // Live salary preview
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primary50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
              ),
              child: Column(children: [
                const Text('Salary preview (ZMW)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 12),
                _PayLine('Basic salary',          'K ${_basic.toStringAsFixed(2)}'),
                _PayLine('Housing allowance',     'K ${_housing.toStringAsFixed(2)}'),
                _PayLine('Transport allowance',   'K ${_transport.toStringAsFixed(2)}'),
                const Divider(height: 16),
                _PayLine('Gross salary',          'K ${_gross.toStringAsFixed(2)}', bold: true),
                const SizedBox(height: 8),
                _PayLine('PAYE (ZRA)',             '− K ${_paye.toStringAsFixed(2)}', red: true),
                _PayLine('NAPSA (5%)',             '− K ${_napsa.toStringAsFixed(2)}', red: true),
                const Divider(height: 16),
                _PayLine('NET salary',             'K ${_net.toStringAsFixed(2)}', bold: true, green: true),
              ]),
            ),
          ]),
        ),
      ]),
    ),
  );
}

class _PayLine extends StatelessWidget {
  final String label, value;
  final bool bold, red, green;
  const _PayLine(this.label, this.value, {this.bold = false, this.red = false, this.green = false});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(children: [
      Expanded(child: Text(label, style: TextStyle(fontSize: 13, color: bold ? AppTheme.textPrimary : AppTheme.textSecondary))),
      Text(value, style: TextStyle(
        fontSize: 13, fontWeight: bold ? FontWeight.bold : FontWeight.w500,
        color: green ? AppTheme.primaryColor : red ? AppTheme.errorColor : AppTheme.textPrimary,
      )),
    ]),
  );
}

class _Field extends StatelessWidget {
  final String label; final Widget child;
  const _Field(this.label, this.child);
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
    const SizedBox(height: 6),
    child,
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

