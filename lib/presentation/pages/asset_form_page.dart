import 'package:flutter/material.dart';
import 'package:kinetic_solutions/core/auth/auth_service.dart';
import 'package:kinetic_solutions/core/theme/app_theme.dart';
import 'package:kinetic_solutions/data/datasources/local_database.dart';
import 'package:kinetic_solutions/domain/entities/asset.dart';
import 'package:kinetic_solutions/domain/entities/employee.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/app_user.dart';
import '../../presentation/widgets/shared_widgets.dart';

class AssetFormPage extends StatefulWidget {
  final AppUser currentUser;
  final Asset? asset;

  const AssetFormPage({super.key, required this.currentUser, this.asset});

  @override
  State<AssetFormPage> createState() => _AssetFormPageState();
}

class _AssetFormPageState extends State<AssetFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _serialController = TextEditingController();
  final _purchaseCostController = TextEditingController();
  final _currentValueController = TextEditingController();
  final _purchaseDateController = TextEditingController();
  final _warrantyExpiryController = TextEditingController();
  final _depreciationRateController = TextEditingController();

  AssetStatus _status = AssetStatus.active;
  String? _assignedToEmployee;
  bool _isLoading = false;
  List<Employee> _employees = [];

  final List<String> _categories = [
    'Vehicles',
    'IT Equipment',
    'Machinery',
    'Office Furniture',
    'Electrical Equipment',
    'Tools & Equipment',
    'Communication Equipment',
    'Security Equipment',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _loadEmployees();
    if (widget.asset != null) {
      final a = widget.asset!;
      _nameController.text = a.name;
      _categoryController.text = a.category;
      _serialController.text = a.serialNumber;
      _purchaseCostController.text = a.purchaseCost.toString();
      _currentValueController.text = a.currentValue.toString();
      _purchaseDateController.text = DateFormat('yyyy-MM-dd').format(a.purchaseDate);
      _warrantyExpiryController.text = DateFormat('yyyy-MM-dd').format(a.warrantyExpiry);
      _depreciationRateController.text = a.depreciationRate.toString();
      _status = a.status;
      _assignedToEmployee = a.assignedToEmployee;
    }
  }

  Future<void> _loadEmployees() async {
    _employees = LocalDatabase.getEmployees();
    setState(() {});
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _serialController.dispose();
    _purchaseCostController.dispose();
    _currentValueController.dispose();
    _purchaseDateController.dispose();
    _warrantyExpiryController.dispose();
    _depreciationRateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(TextEditingController controller) async {
    final initial = controller.text.isNotEmpty
        ? DateFormat('yyyy-MM-dd').parse(controller.text)
        : DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2030),
    );
    if (date != null) {
      controller.text = DateFormat('yyyy-MM-dd').format(date);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final asset = Asset(
        id: widget.asset?.id ?? LocalDatabase.generateId(),
        name: _nameController.text.trim(),
        category: _categoryController.text.trim(),
        serialNumber: _serialController.text.trim(),
        purchaseCost: double.parse(_purchaseCostController.text),
        currentValue: double.parse(_currentValueController.text),
        purchaseDate: DateFormat('yyyy-MM-dd').parse(_purchaseDateController.text),
        warrantyExpiry: DateFormat('yyyy-MM-dd').parse(_warrantyExpiryController.text),
        assignedToEmployee: _assignedToEmployee,
        status: _status,
        depreciationRate: double.parse(_depreciationRateController.text),
      );
      await LocalDatabase.saveAsset(asset);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving asset: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.asset != null;
    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Asset' : 'Add Asset'),
        backgroundColor: AppTheme.purpleColor,
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
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Asset Name *',
                        prefixIcon: Icon(Icons.inventory_2),
                      ),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    Autocomplete<String>(
                      optionsBuilder: (TextEditingValue value) {
                        if (value.text.isEmpty) return const Iterable<String>.empty();
                        return _categories.where((cat) =>
                            cat.toLowerCase().contains(value.text.toLowerCase()));
                      },
                      onSelected: (value) => _categoryController.text = value,
                      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                        return TextFormField(
                          controller: _categoryController,
                          focusNode: focusNode,
                          decoration: const InputDecoration(
                            labelText: 'Category *',
                            prefixIcon: Icon(Icons.category),
                          ),
                          validator: (v) => v!.isEmpty ? 'Required' : null,
                          onFieldSubmitted: (_) => onFieldSubmitted(),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _serialController,
                      decoration: const InputDecoration(
                        labelText: 'Serial Number *',
                        prefixIcon: Icon(Icons.confirmation_number),
                      ),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              FormCard(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _purchaseCostController,
                            decoration: const InputDecoration(
                              labelText: 'Purchase Cost (ZMW) *',
                              prefixIcon: Icon(Icons.attach_money),
                            ),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            validator: (v) {
                              if (v!.isEmpty) return 'Required';
                              if (double.tryParse(v) == null) return 'Invalid number';
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _currentValueController,
                            decoration: const InputDecoration(
                              labelText: 'Current Value (ZMW) *',
                              prefixIcon: Icon(Icons.trending_down),
                            ),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            validator: (v) {
                              if (v!.isEmpty) return 'Required';
                              if (double.tryParse(v) == null) return 'Invalid number';
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _depreciationRateController,
                            decoration: const InputDecoration(
                              labelText: 'Depreciation Rate (%) *',
                              prefixIcon: Icon(Icons.percent),
                            ),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            validator: (v) {
                              if (v!.isEmpty) return 'Required';
                              if (double.tryParse(v) == null) return 'Invalid number';
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<AssetStatus>(
                            value: _status,
                            decoration: const InputDecoration(
                              labelText: 'Status',
                              prefixIcon: Icon(Icons.flag),
                            ),
                            items: AssetStatus.values.map((status) {
                              return DropdownMenuItem(
                                value: status,
                                child: Text(status.name),
                              );
                            }).toList(),
                            onChanged: (val) => setState(() => _status = val!),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              FormCard(
                child: Column(
                  children: [
                    _buildDatePicker('Purchase Date *', _purchaseDateController),
                    const SizedBox(height: 16),
                    _buildDatePicker('Warranty Expiry *', _warrantyExpiryController),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _assignedToEmployee,
                      decoration: const InputDecoration(
                        labelText: 'Assigned To',
                        prefixIcon: Icon(Icons.person),
                      ),
                      items: [
                        const DropdownMenuItem(value: null, child: Text('Unassigned')),
                        ..._employees.map((e) {
                          return DropdownMenuItem(
                            value: e.id,
                            child: Text(e.fullName),
                          );
                        }),
                      ],
                      onChanged: (val) => setState(() => _assignedToEmployee = val),
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
                    : const Text('Save Asset'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDatePicker(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.calendar_today),
        suffixIcon: IconButton(
          icon: const Icon(Icons.date_range),
          onPressed: () => _selectDate(controller),
        ),
      ),
      readOnly: true,
      onTap: () => _selectDate(controller),
      validator: (v) => v!.isEmpty ? 'Required' : null,
    );
  }
}
