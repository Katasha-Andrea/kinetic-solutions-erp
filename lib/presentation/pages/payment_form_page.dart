// lib/presentation/pages/payment_form_page.dart
import 'package:flutter/material.dart';
import 'package:kinetic_solutions/core/auth/auth_service.dart';
import 'package:kinetic_solutions/core/theme/app_theme.dart';
import 'package:kinetic_solutions/data/datasources/local_database.dart';
import 'package:kinetic_solutions/domain/entities/payment.dart';
import 'package:kinetic_solutions/domain/entities/invoice.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/app_user.dart';
import '../../presentation/widgets/shared_widgets.dart';

class PaymentFormPage extends StatefulWidget {
  final AppUser currentUser;
  final Payment? payment;

  const PaymentFormPage({super.key, required this.currentUser, this.payment});

  @override
  State<PaymentFormPage> createState() => _PaymentFormPageState();
}

class _PaymentFormPageState extends State<PaymentFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _dateController = TextEditingController();

  String? _invoiceId;
  PaymentMethod _method = PaymentMethod.cash;
  bool _isLoading = false;
  List<Invoice> _invoices = [];

  @override
  void initState() {
    super.initState();
    _loadInvoices();
    if (widget.payment != null) {
      final p = widget.payment!;
      _amountController.text = p.amount.toString();
      _dateController.text = DateFormat('yyyy-MM-dd').format(p.paymentDate);
      _invoiceId = p.invoiceId;
      _method = p.method;
    }
  }

  Future<void> _loadInvoices() async {
    final invoices = LocalDatabase.getInvoices().where((i) => i.status != InvoiceStatus.paid).toList();
    setState(() => _invoices = invoices);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final initial = _dateController.text.isNotEmpty
        ? DateFormat('yyyy-MM-dd').parse(_dateController.text)
        : DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (date != null) {
      _dateController.text = DateFormat('yyyy-MM-dd').format(date);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_invoiceId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Select invoice')));
      return;
    }
    setState(() => _isLoading = true);
    try {
      final payment = Payment(
        id: widget.payment?.id ?? LocalDatabase.generateId(),
        invoiceId: _invoiceId!,
        amount: double.parse(_amountController.text),
        method: _method,
        paymentDate: DateFormat('yyyy-MM-dd').parse(_dateController.text),
      );
      await LocalDatabase.savePayment(payment);

      // Update invoice status to paid if fully paid (simplified)
      final invoice = _invoices.firstWhere((i) => i.id == _invoiceId);
      if (payment.amount >= invoice.total) {
        final updated = Invoice(
          id: invoice.id,
          invoiceNumber: invoice.invoiceNumber,
          customerId: invoice.customerId,
          total: invoice.total,
          status: InvoiceStatus.paid,
          dueDate: invoice.dueDate,
          createdAt: invoice.createdAt,
        );
        await LocalDatabase.saveInvoice(updated);
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.payment != null;
    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Payment' : 'Add Payment'),
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
                    DropdownButtonFormField<String>(
                      value: _invoiceId,
                      decoration: const InputDecoration(labelText: 'Invoice *', prefixIcon: Icon(Icons.receipt)),
                      items: _invoices.map((i) {
                        return DropdownMenuItem(
                          value: i.id,
                          child: Text('${i.invoiceNumber} - K ${NumberFormat('#,##0.00').format(i.total)}'),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => _invoiceId = val),
                      validator: (v) => v == null ? 'Select invoice' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _amountController,
                      decoration: const InputDecoration(labelText: 'Amount (ZMW) *', prefixIcon: Icon(Icons.attach_money)),
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
                    DropdownButtonFormField<PaymentMethod>(
                      value: _method,
                      decoration: const InputDecoration(labelText: 'Payment Method', prefixIcon: Icon(Icons.payment)),
                      items: PaymentMethod.values.map((m) {
                        return DropdownMenuItem(value: m, child: Text(m.name));
                      }).toList(),
                      onChanged: (val) => setState(() => _method = val!),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _save,
                child: _isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Save Payment'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDatePicker() {
    return TextFormField(
      controller: _dateController,
      decoration: InputDecoration(
        labelText: 'Payment Date *',
        prefixIcon: const Icon(Icons.calendar_today),
        suffixIcon: IconButton(icon: const Icon(Icons.date_range), onPressed: _selectDate),
      ),
      readOnly: true,
      onTap: _selectDate,
      validator: (v) => v!.isEmpty ? 'Required' : null,
    );
  }
}
