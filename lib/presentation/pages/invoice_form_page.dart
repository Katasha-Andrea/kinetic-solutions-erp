import 'package:flutter/material.dart';
import 'package:kinetic_solutions/core/auth/auth_service.dart';
import 'package:kinetic_solutions/core/theme/app_theme.dart';
import 'package:kinetic_solutions/data/datasources/local_database.dart';
import 'package:kinetic_solutions/domain/entities/invoice.dart';
import 'package:kinetic_solutions/domain/entities/customer.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/app_user.dart';
import '../../presentation/widgets/shared_widgets.dart';

class InvoiceFormPage extends StatefulWidget {
  final AppUser currentUser;
  final Invoice? invoice;

  const InvoiceFormPage({
    super.key,
    required this.currentUser,
    this.invoice,
  });

  @override
  State<InvoiceFormPage> createState() => _InvoiceFormPageState();
}

class _InvoiceFormPageState extends State<InvoiceFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _invoiceNumberController = TextEditingController();
  final _totalController = TextEditingController();
  final _dueDateController = TextEditingController();

  String? _customerId;
  InvoiceStatus _status = InvoiceStatus.sent;
  bool _isLoading = false;
  List<Customer> _customers = [];

  @override
  void initState() {
    super.initState();
    _loadCustomers();
    if (widget.invoice != null) {
      final inv = widget.invoice!;
      _invoiceNumberController.text = inv.invoiceNumber;
      _totalController.text = inv.total.toString();
      _dueDateController.text = DateFormat('yyyy-MM-dd').format(inv.dueDate);
      _customerId = inv.customerId;
      _status = inv.status;
    }
  }

  Future<void> _loadCustomers() async {
    final customers = LocalDatabase.getCustomers();
    setState(() => _customers = customers);
  }

  @override
  void dispose() {
    _invoiceNumberController.dispose();
    _totalController.dispose();
    _dueDateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final initial = _dueDateController.text.isNotEmpty
        ? DateFormat('yyyy-MM-dd').parse(_dueDateController.text)
        : DateTime.now().add(const Duration(days: 30));
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (date != null) {
      _dueDateController.text = DateFormat('yyyy-MM-dd').format(date);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_customerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select a customer')),
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      final invoice = Invoice(
        id: widget.invoice?.id ?? LocalDatabase.generateId(),
        invoiceNumber: _invoiceNumberController.text.trim().toUpperCase(),
        customerId: _customerId!,
        total: double.parse(_totalController.text),
        status: _status,
        dueDate: DateFormat('yyyy-MM-dd').parse(_dueDateController.text),
        createdAt: widget.invoice?.createdAt ?? DateTime.now(),
      );
      await LocalDatabase.saveInvoice(invoice);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.invoice != null;
    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Invoice' : 'New Invoice'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              FormCard(
                child: Column(
                  children: [
                    TextFormField(
                      controller: _invoiceNumberController,
                      decoration: const InputDecoration(
                        labelText: 'Invoice Number *',
                        prefixIcon: Icon(Icons.confirmation_number),
                      ),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _customerId,
                      decoration: const InputDecoration(
                        labelText: 'Customer *',
                        prefixIcon: Icon(Icons.business),
                      ),
                      items: _customers.map((c) {
                        return DropdownMenuItem(
                          value: c.id,
                          child: Text(c.companyName),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => _customerId = val),
                      validator: (v) => v == null ? 'Select customer' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _totalController,
                      decoration: const InputDecoration(
                        labelText: 'Total Amount (ZMW) *',
                        prefixIcon: Icon(Icons.attach_money),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (v) {
                        if (v!.isEmpty) return 'Required';
                        if (double.tryParse(v) == null) return 'Invalid number';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildDatePicker(),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<InvoiceStatus>(
                      value: _status,
                      decoration: const InputDecoration(
                        labelText: 'Status',
                        prefixIcon: Icon(Icons.flag),
                      ),
                      items: InvoiceStatus.values.map((s) {
                        return DropdownMenuItem(
                          value: s,
                          child: Text(s.name),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => _status = val!),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _save,
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save Invoice'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDatePicker() {
    return TextFormField(
      controller: _dueDateController,
      decoration: InputDecoration(
        labelText: 'Due Date *',
        prefixIcon: const Icon(Icons.calendar_today),
        suffixIcon: IconButton(
          icon: const Icon(Icons.date_range),
          onPressed: _selectDate,
        ),
      ),
      readOnly: true,
      onTap: _selectDate,
      validator: (v) => v!.isEmpty ? 'Required' : null,
    );
  }
}
