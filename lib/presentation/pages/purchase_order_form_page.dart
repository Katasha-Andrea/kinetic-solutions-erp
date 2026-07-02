import 'package:flutter/material.dart';
import 'package:kinetic_solutions/core/auth/auth_service.dart';
import 'package:kinetic_solutions/core/theme/app_theme.dart';
import 'package:kinetic_solutions/data/datasources/local_database.dart';
import 'package:kinetic_solutions/domain/entities/purchase_order.dart';
import 'package:kinetic_solutions/domain/entities/supplier.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/app_user.dart';
import '../../presentation/widgets/shared_widgets.dart';

class PurchaseOrderFormPage extends StatefulWidget {
  final AppUser currentUser;
  final PurchaseOrder? order;

  const PurchaseOrderFormPage({
    super.key,
    required this.currentUser,
    this.order,
  });

  @override
  State<PurchaseOrderFormPage> createState() => _PurchaseOrderFormPageState();
}

class _PurchaseOrderFormPageState extends State<PurchaseOrderFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _poNumberController = TextEditingController();
  final _orderDateController = TextEditingController();
  final _totalController = TextEditingController();

  String? _supplierId;
  String? _supplierName;
  List<Map<String, dynamic>> _items = [];
  List<Supplier> _suppliers = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSuppliers();
    if (widget.order != null) {
      final o = widget.order!;
      _poNumberController.text = o.poNumber;
      _orderDateController.text = DateFormat('yyyy-MM-dd').format(o.orderDate);
      _totalController.text = o.total.toString();
      _supplierId = o.supplierId;
      _supplierName = o.supplierName;
      _items = List.from(o.items);
    }
  }

  Future<void> _loadSuppliers() async {
    final suppliers = LocalDatabase.getSuppliers();
    setState(() {
      _suppliers = suppliers.where((s) => s.isActive).toList();
    });
  }

  @override
  void dispose() {
    _poNumberController.dispose();
    _orderDateController.dispose();
    _totalController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final initial = _orderDateController.text.isNotEmpty
        ? DateFormat('yyyy-MM-dd').parse(_orderDateController.text)
        : DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (date != null) {
      _orderDateController.text = DateFormat('yyyy-MM-dd').format(date);
    }
  }

  void _addItem() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Item'),
        content: StatefulBuilder(
          builder: (ctx, setStateDialog) {
            final descriptionController = TextEditingController();
            final quantityController = TextEditingController();
            final unitPriceController = TextEditingController();

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Description *'),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: quantityController,
                        decoration: const InputDecoration(labelText: 'Quantity *'),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: unitPriceController,
                        decoration: const InputDecoration(labelText: 'Unit Price *'),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    final desc = descriptionController.text.trim();
                    final qty = int.tryParse(quantityController.text) ?? 0;
                    final price = double.tryParse(unitPriceController.text) ?? 0;
                    if (desc.isNotEmpty && qty > 0 && price > 0) {
                      setState(() {
                        _items.add({
                          'description': desc,
                          'quantity': qty,
                          'unitPrice': price,
                          'total': qty * price,
                        });
                        _recalculateTotal();
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
      _items.removeAt(index);
      _recalculateTotal();
    });
  }

  void _recalculateTotal() {
    final total = _items.fold(0.0, (sum, item) => sum + (item['total'] as double));
    _totalController.text = total.toStringAsFixed(2);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_supplierId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a supplier')),
      );
      return;
    }
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one item')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final order = PurchaseOrder(
        id: widget.order?.id ?? LocalDatabase.generateId(),
        poNumber: _poNumberController.text.trim().toUpperCase(),
        supplierId: _supplierId!,
        supplierName: _supplierName!,
        orderDate: DateFormat('yyyy-MM-dd').parse(_orderDateController.text),
        total: double.parse(_totalController.text),
        status: widget.order?.status ?? POStatus.draft,
        items: _items,
        requestedBy: widget.currentUser.fullName,
        createdAt: widget.order?.createdAt ?? DateTime.now(),
      );
      await LocalDatabase.savePurchaseOrder(order);
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
    final isEdit = widget.order != null;
    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Purchase Order' : 'New Purchase Order'),
        backgroundColor: Colors.orange.shade700,
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
                      controller: _poNumberController,
                      decoration: const InputDecoration(
                        labelText: 'PO Number *',
                        prefixIcon: Icon(Icons.confirmation_number),
                      ),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _supplierId,
                      decoration: const InputDecoration(
                        labelText: 'Supplier *',
                        prefixIcon: Icon(Icons.business),
                      ),
                      items: _suppliers.map((s) {
                        return DropdownMenuItem(
                          value: s.id,
                          child: Text(s.companyName),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          _supplierId = val;
                          _supplierName = _suppliers.firstWhere((s) => s.id == val).companyName;
                        });
                      },
                      validator: (v) => v == null ? 'Select supplier' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildDatePicker(),
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
                        const Text('Items', style: TextStyle(fontWeight: FontWeight.bold)),
                        IconButton(
                          icon: const Icon(Icons.add, color: AppTheme.primary500),
                          onPressed: _addItem,
                        ),
                      ],
                    ),
                    ..._items.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final item = entry.value;
                      return ListTile(
                        title: Text(item['description']),
                        subtitle: Text('${item['quantity']} × K ${NumberFormat('#,##0.00').format(item['unitPrice'])}'),
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
                    if (_items.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'No items added',
                          style: TextStyle(color: AppTheme.textSecondary),
                        ),
                      ),
                    const Divider(),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text(
                            'K ${_totalController.text}',
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
                    : const Text('Save Purchase Order'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDatePicker() {
    return TextFormField(
      controller: _orderDateController,
      decoration: InputDecoration(
        labelText: 'Order Date *',
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
