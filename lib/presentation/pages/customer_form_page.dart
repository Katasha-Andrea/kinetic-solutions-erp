import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../data/datasources/local_database.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/entities/customer.dart';
import '../../presentation/widgets/shared_widgets.dart';

class CustomerFormPage extends StatefulWidget {
  final AppUser currentUser;
  final Customer? customer;
  const CustomerFormPage(
      {super.key, required this.currentUser, this.customer});

  @override
  State<CustomerFormPage> createState() => _CustomerFormPageState();
}

class _CustomerFormPageState extends State<CustomerFormPage> {
  final _formKey       = GlobalKey<FormState>();
  final _companyCtrl   = TextEditingController();
  final _contactCtrl   = TextEditingController();
  final _phoneCtrl     = TextEditingController();
  final _emailCtrl     = TextEditingController();
  final _addressCtrl   = TextEditingController();
  final _tpinCtrl      = TextEditingController();
  final _creditCtrl    = TextEditingController();

  CustomerType _type   = CustomerType.retail;
  bool _loading        = false;

  bool get _isEdit => widget.customer != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      final c = widget.customer!;
      _companyCtrl.text = c.companyName;
      _contactCtrl.text = c.contactPerson;
      _phoneCtrl.text   = c.phoneNumber;
      _emailCtrl.text   = c.email;
      _addressCtrl.text = c.address;
      _tpinCtrl.text    = c.taxId;
      _creditCtrl.text  = c.creditLimit.toStringAsFixed(2);
      _type             = c.type;
    }
  }

  @override
  void dispose() {
    for (final c in [
      _companyCtrl, _contactCtrl, _phoneCtrl, _emailCtrl,
      _addressCtrl, _tpinCtrl, _creditCtrl,
    ]) c.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final customer = Customer(
      id:             _isEdit ? widget.customer!.id : LocalDatabase.generateId(),
      companyName:    _companyCtrl.text.trim(),
      contactPerson:  _contactCtrl.text.trim(),
      phoneNumber:    _phoneCtrl.text.trim(),
      email:          _emailCtrl.text.trim(),
      address:        _addressCtrl.text.trim(),
      taxId:          _tpinCtrl.text.trim(),
      type:           _type,
      creditLimit:    double.tryParse(_creditCtrl.text) ?? 0,
      currentBalance: _isEdit ? widget.customer!.currentBalance : 0,
      createdAt:      _isEdit ? widget.customer!.createdAt : DateTime.now(),
    );
    await LocalDatabase.saveCustomer(customer);
    if (mounted) {
      setState(() => _loading = false);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppTheme.bgColor,
        appBar: AppBar(
          title: Text(_isEdit ? 'Edit client' : 'Add client'),
          actions: [
            TextButton(
              onPressed: _loading ? null : _save,
              child: _loading
                  ? const SizedBox(
                      width: 18, height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Save',
                      style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(children: [
              _Card(children: [
                const _Title('Company details'),
                const SizedBox(height: 14),
                _F('Company name *',
                    TextFormField(
                      controller: _companyCtrl,
                      decoration: const InputDecoration(
                          hintText: 'e.g. ZESCO Limited'),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Required' : null,
                    )),
                const SizedBox(height: 14),
                _F('Contact person *',
                    TextFormField(
                      controller: _contactCtrl,
                      decoration: const InputDecoration(
                          hintText: 'Primary contact name'),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Required' : null,
                    )),
                const SizedBox(height: 14),
                Row(children: [
                  Expanded(
                    child: _F('Phone number *',
                        TextFormField(
                          controller: _phoneCtrl,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                              hintText: '+260 97X XXX XXX'),
                          validator: (v) =>
                              v == null || v.isEmpty ? 'Required' : null,
                        )),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _F('Email',
                        TextFormField(
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                              hintText: 'contact@company.zm'),
                        )),
                  ),
                ]),
                const SizedBox(height: 14),
                _F('Address',
                    TextFormField(
                      controller: _addressCtrl,
                      maxLines: 2,
                      decoration: const InputDecoration(
                          hintText: 'Physical / postal address'),
                    )),
              ]),
              const SizedBox(height: 16),
              _Card(children: [
                const _Title('Compliance & finance'),
                const SizedBox(height: 14),
                _F('TPIN number',
                    TextFormField(
                      controller: _tpinCtrl,
                      decoration: const InputDecoration(
                          hintText: 'Taxpayer Identification Number'),
                    )),
                const SizedBox(height: 14),
                _F('Client type',
                    DropdownButtonFormField<CustomerType>(
                      value: _type,
                      items: CustomerType.values
                          .map((t) => DropdownMenuItem(
                              value: t, child: Text(t.label)))
                          .toList(),
                      onChanged: (v) =>
                          setState(() => _type = v ?? CustomerType.retail),
                    )),
                const SizedBox(height: 14),
                _F('Credit limit (ZMW)',
                    TextFormField(
                      controller: _creditCtrl,
                      keyboardType: TextInputType.number,
                      decoration:
                          const InputDecoration(prefixText: 'K '),
                    )),
              ]),
              const SizedBox(height: 30),
            ]),
          ),
        ),
      );
}

class _Card extends StatelessWidget {
  final List<Widget> children;
  const _Card({required this.children});
  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.borderColor, width: 0.5),
        ),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children),
      );
}

class _Title extends StatelessWidget {
  final String text;
  const _Title(this.text);
  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppTheme.textPrimary));
}

class _F extends StatelessWidget {
  final String label;
  final Widget child;
  const _F(this.label, this.child);
  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textPrimary)),
          const SizedBox(height: 6),
          child,
        ],
      );
}
