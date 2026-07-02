import 'package:flutter/material.dart';
import 'package:kinetic_solutions/core/auth/auth_service.dart';
import 'package:kinetic_solutions/core/constants/app_constants.dart';
import 'package:kinetic_solutions/core/theme/app_theme.dart';
import 'package:kinetic_solutions/data/datasources/local_database.dart';
import 'package:kinetic_solutions/domain/entities/quotation.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/app_user.dart';
import '../../presentation/widgets/shared_widgets.dart';

class QuotationFormPage extends StatefulWidget {
  final AppUser currentUser;
  final Quotation? quotation;

  const QuotationFormPage({
    super.key,
    required this.currentUser,
    this.quotation,
  });

  @override
  State<QuotationFormPage> createState() => _QuotationFormPageState();
}

class _QuotationFormPageState extends State<QuotationFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _quotationNumberController = TextEditingController();
  final _clientNameController = TextEditingController();
  final _tenderRefController = TextEditingController();

  List<Map<String, dynamic>> _lineItems = [];
  bool _isVatable = true;
  bool _isLoading = false;
  double _subtotal = 0.0;
  double _vatAmount = 0.0;
  double _total = 0.0;

  @override
  void initState() {
    super.initState();
    if (widget.quotation != null) {
      final q = widget.quotation!;
      _quotationNumberController.text = q.quotationNumber;
      _clientNameController.text = q.clientName;
      _tenderRefController.text = q.tenderReference ?? '';
      _lineItems = List.from(q.lineItems);
      _isVatable = q.isVatable;
      _subtotal = q.subtotal;
      _vatAmount = q.vatAmount;
      _total = q.total;
    }
  }

  @override
  void dispose() {
    _quotationNumberController.dispose();
    _clientNameController.dispose();
    _tenderRefController.dispose();
    super.dispose();
  }

  void _addItem() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Line Item'),
        content: StatefulBuilder(
          builder: (ctx, setStateDialog) {
            final descController = TextEditingController();
            final qtyController = TextEditingController();
            final unitController = TextEditingController();
            final priceController = TextEditingController();

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: descController,
                  decoration: const InputDecoration(labelText: 'Description *'),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: qtyController,
                        decoration: const InputDecoration(labelText: 'Quantity *'),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: unitController,
                        decoration: const InputDecoration(labelText: 'Unit'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: priceController,
                  decoration: const InputDecoration(labelText: 'Unit Price *'),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    final desc = descController.text.trim();
                    final qty = int.tryParse(qtyController.text) ?? 0;
                    final unit = unitController.text.trim().isNotEmpty ? unitController.text.trim() : 'each';
                    final price = double.tryParse(priceController.text) ?? 0;
                    if (desc.isNotEmpty && qty > 0 && price > 0) {
                      setState(() {
                        _lineItems.add({
                          'description': desc,
                          'quantity': qty,
                          'unit': unit,
                          'unitPrice': price,
                          'total': qty * price,
                        });
                        _recalculate();
                      });
                      Navigator.pop(ctx);
                    }
                  },
                  child: const Text('Add Item'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _removeItem(int index) {
    setState(() {
      _lineItems.removeAt(index);
      _recalculate();
    });
  }

  void _recalculate() {
    _subtotal = _lineItems.fold(0.0, (sum, item) => sum + (item['total'] as double));
    if (_isVatable) {
      _vatAmount = _subtotal * AppConstants.vatRate;
    } else {
      _vatAmount = 0.0;
    }
    _total = _subtotal + _vatAmount;
    setState(() {});
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_lineItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one line item')),
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      final quotation = Quotation(
        id: widget.quotation?.id ?? LocalDatabase.generateId(),
        quotationNumber: _quotationNumberController.text.trim().toUpperCase(),
        clientName: _clientNameController.text.trim(),
        tenderReference: _tenderRefController.text.trim().isNotEmpty
            ? _tenderRefController.text.trim()
            : null,
        lineItems: _lineItems,
        subtotal: _subtotal,
        vatAmount: _vatAmount,
        total: _total,
        isVatable: _isVatable,
        createdAt: widget.quotation?.createdAt ?? DateTime.now(),
      );
      await LocalDatabase.saveQuotation(quotation);
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
    final isEdit = widget.quotation != null;
    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Quotation' : 'New Quotation'),
        backgroundColor: Colors.indigo.shade700,
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
                      controller: _quotationNumberController,
                      decoration: const InputDecoration(
                        labelText: 'Quotation Number *',
                        prefixIcon: Icon(Icons.confirmation_number),
                      ),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _clientNameController,
                      decoration: const InputDecoration(
                        labelText: 'Client Name *',
                        prefixIcon: Icon(Icons.business),
                      ),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _tenderRefController,
                      decoration: const InputDecoration(
                        labelText: 'Tender Reference (optional)',
                        prefixIcon: Icon(Icons.link),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('VAT Applicable'),
                      subtitle: const Text('16% VAT will be added'),
                      value: _isVatable,
                      onChanged: (val) {
                        setState(() {
                          _isVatable = val;
                          _recalculate();
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              FormCard(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Line Items', style: TextStyle(fontWeight: FontWeight.bold)),
                        IconButton(
                          icon: const Icon(Icons.add, color: AppTheme.primary500),
                          onPressed: _addItem,
                        ),
                      ],
                    ),
                    ..._lineItems.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final item = entry.value;
                      return ListTile(
                        title: Text(item['description']),
                        subtitle: Text(
                          '${item['quantity']} × ${item['unit']} @ K ${NumberFormat('#,##0.00').format(item['unitPrice'])}',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'K ${NumberFormat('#,##0.00').format(item['total'])}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.delete, color: AppTheme.errorColor),
                              onPressed: () => _removeItem(idx),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    if (_lineItems.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'No items added',
                          style: TextStyle(color: AppTheme.textSecondary),
                        ),
                      ),
                    const Divider(),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Subtotal'),
                          Text('K ${NumberFormat('#,##0.00').format(_subtotal)}'),
                        ],
                      ),
                    ),
                    if (_isVatable)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('VAT (16%)'),
                            Text('K ${NumberFormat('#,##0.00').format(_vatAmount)}'),
                          ],
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text(
                            'K ${NumberFormat('#,##0.00').format(_total)}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                        ],
                      ),
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
                    : const Text('Save Quotation'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
