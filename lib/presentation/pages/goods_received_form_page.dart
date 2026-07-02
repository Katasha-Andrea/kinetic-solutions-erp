// lib/presentation/pages/goods_received_form_page.dart
import 'package:flutter/material.dart';
import 'package:kinetic_solutions/core/auth/auth_service.dart';
import 'package:kinetic_solutions/core/theme/app_theme.dart';
import 'package:kinetic_solutions/data/datasources/local_database.dart';
import 'package:kinetic_solutions/domain/entities/goods_received.dart';
import 'package:kinetic_solutions/domain/entities/purchase_order.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/app_user.dart';
import '../../presentation/widgets/shared_widgets.dart';

class GoodsReceivedFormPage extends StatefulWidget {
  final AppUser currentUser;
  final GoodsReceived? grn;

  const GoodsReceivedFormPage({
    super.key,
    required this.currentUser,
    this.grn,
  });

  @override
  State<GoodsReceivedFormPage> createState() => _GoodsReceivedFormPageState();
}

class _GoodsReceivedFormPageState extends State<GoodsReceivedFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _grnNumberController = TextEditingController();
  final _receivedDateController = TextEditingController();
  final _receivedByController = TextEditingController();

  String? _poId;
  String? _poNumber;
  String? _supplierId;
  String? _supplierName;
  List<Map<String, dynamic>> _items = [];
  List<PurchaseOrder> _pos = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadPOs();
    if (widget.grn != null) {
      final g = widget.grn!;
      _grnNumberController.text = g.grnNumber;
      _receivedDateController.text = DateFormat('yyyy-MM-dd').format(g.receivedDate);
      _receivedByController.text = g.receivedBy;
      _poId = g.poId;
      _poNumber = g.poNumber;
      _supplierId = g.supplierId;
      _supplierName = g.supplierName;
      _items = List.from(g.items);
    }
  }

  Future<void> _loadPOs() async {
    final pos = LocalDatabase.getPurchaseOrders()
        .where((p) => p.status == POStatus.sent || p.status == POStatus.delivered)
        .toList();
    setState(() => _pos = pos);
  }

  @override
  void dispose() {
    _grnNumberController.dispose();
    _receivedDateController.dispose();
    _receivedByController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final initial = _receivedDateController.text.isNotEmpty
        ? DateFormat('yyyy-MM-dd').parse(_receivedDateController.text)
        : DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (date != null) {
      _receivedDateController.text = DateFormat('yyyy-MM-dd').format(date);
    }
  }

  void _loadPOItems() {
    if (_poId != null) {
      final po = _pos.firstWhere((p) => p.id == _poId);
      setState(() {
        _poNumber = po.poNumber;
        _supplierId = po.supplierId;
        _supplierName = po.supplierName;
        _items = po.items.map((item) => {
          'itemId': item['itemId'] ?? '',
          'name': item['description'],
          'quantity': item['quantity'],
          'unit': item['unit'] ?? 'each',
          'condition': '',
        }).toList();
      });
    }
  }

  void _updateItemCondition(int index, String condition) {
    setState(() {
      _items[index]['condition'] = condition;
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_poId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select a PO')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final grn = GoodsReceived(
        id: widget.grn?.id ?? LocalDatabase.generateId(),
        grnNumber: _grnNumberController.text.trim().toUpperCase(),
        poId: _poId!,
        poNumber: _poNumber!,
        supplierId: _supplierId!,
        supplierName: _supplierName!,
        receivedDate: DateFormat('yyyy-MM-dd').parse(_receivedDateController.text),
        items: _items,
        receivedBy: _receivedByController.text.trim(),
        status: widget.grn?.status ?? GRNStatus.received,
      );
      await LocalDatabase.saveGoodsReceived(grn);
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
    final isEdit = widget.grn != null;
    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      appBar: AppBar(
        title: Text(isEdit ? 'Edit GRN' : 'New GRN'),
        backgroundColor: Colors.teal,
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
                      controller: _grnNumberController,
                      decoration: const InputDecoration(
                        labelText: 'GRN Number *',
                        prefixIcon: Icon(Icons.confirmation_number),
                      ),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _poId,
                      decoration: const InputDecoration(
                        labelText: 'Purchase Order *',
                        prefixIcon: Icon(Icons.shopping_cart),
                      ),
                      items: _pos.map((p) {
                        return DropdownMenuItem(
                          value: p.id,
                          child: Text('${p.poNumber} - ${p.supplierName}'),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          _poId = val;
                          _loadPOItems();
                        });
                      },
                      validator: (v) => v == null ? 'Select PO' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildDatePicker(),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _receivedByController,
                      decoration: const InputDecoration(
                        labelText: 'Received By *',
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (_items.isNotEmpty)
                FormCard(
                  child: Column(
                    children: [
                      const Text('Items', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      ..._items.asMap().entries.map((entry) {
                        final idx = entry.key;
                        final item = entry.value;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Expanded(flex: 2, child: Text(item['name'])),
                              Expanded(
                                child: Text('Qty: ${item['quantity']}'),
                              ),
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: item['condition'] ?? '',
                                  decoration: const InputDecoration(
                                    labelText: 'Condition',
                                    border: OutlineInputBorder(),
                                  ),
                                  items: const [
                                    DropdownMenuItem(value: 'Good', child: Text('Good')),
                                    DropdownMenuItem(value: 'Damaged', child: Text('Damaged')),
                                    DropdownMenuItem(value: 'Shortage', child: Text('Shortage')),
                                  ],
                                  onChanged: (val) => _updateItemCondition(idx, val ?? ''),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
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
                    : const Text('Save GRN'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDatePicker() {
    return TextFormField(
      controller: _receivedDateController,
      decoration: InputDecoration(
        labelText: 'Received Date *',
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
