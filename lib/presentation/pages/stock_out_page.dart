import 'package:flutter/material.dart';
import 'package:kinetic_solutions/core/theme/app_theme.dart';
import 'package:kinetic_solutions/data/datasources/local_database.dart';
import 'package:kinetic_solutions/domain/entities/app_user.dart';
import 'package:kinetic_solutions/domain/entities/inventory_item.dart';
import 'package:kinetic_solutions/presentation/widgets/shared_widgets.dart';
import 'package:intl/intl.dart';

class StockOutPage extends StatefulWidget {
  final AppUser currentUser;
  const StockOutPage({super.key, required this.currentUser});

  @override
  State<StockOutPage> createState() => _StockOutPageState();
}

class _StockOutPageState extends State<StockOutPage> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _reasonController = TextEditingController();
  String? _selectedItemId;
  List<InventoryItem> _items = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    setState(() => _isLoading = true);
    _items = LocalDatabase.getInventoryItems();
    setState(() => _isLoading = false);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedItemId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select an item')),
      );
      return;
    }
    final qty = int.parse(_quantityController.text);
    if (qty <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Quantity must be greater than 0')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final item = _items.firstWhere((i) => i.id == _selectedItemId);
      if (item.quantity < qty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Not enough stock. Available: ${item.quantity}')),
        );
        return;
      }
      final updated = item.copyWith(quantity: item.quantity - qty);
      await LocalDatabase.saveInventoryItem(updated);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Dispatched $qty of ${item.name}')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      appBar: AppBar(
        title: const Text('Stock Out — Dispatch goods'),  // FIXED: changed message → title
        backgroundColor: AppTheme.errorColor,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _InfoBanner(  // FIXED: changed title → message
                      icon: Icons.remove_shopping_cart,
                      color: AppTheme.errorColor,
                      bgColor: AppTheme.errorLight,
                      message: 'Record goods leaving your inventory — sales, internal use, or write-offs.',
                    ),
                    const SizedBox(height: 24),
                    FormCard(
                      child: Column(
                        children: [
                          DropdownButtonFormField<String>(
                            value: _selectedItemId,
                            decoration: const InputDecoration(
                              labelText: 'Select Item *',
                              prefixIcon: Icon(Icons.inventory_2),
                            ),
                            items: _items.map((item) {
                              return DropdownMenuItem(
                                value: item.id,
                                child: Text('${item.name} (Available: ${item.quantity})'),
                              );
                            }).toList(),
                            onChanged: (val) => setState(() => _selectedItemId = val),
                            validator: (v) => v == null ? 'Select an item' : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _quantityController,
                            decoration: const InputDecoration(
                              labelText: 'Quantity to Dispatch *',
                              prefixIcon: Icon(Icons.numbers),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Required';
                              if (int.tryParse(v) == null) return 'Must be a number';
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _reasonController,
                            decoration: const InputDecoration(
                              labelText: 'Reason / Destination *',
                              prefixIcon: Icon(Icons.comment),
                            ),
                            validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.errorColor,
                        foregroundColor: Colors.white,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Dispatch Stock'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

// ── Local InfoBanner widget ──
class _InfoBanner extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color bgColor;
  final String message;  // kept as 'message'
  const _InfoBanner({
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: color, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}