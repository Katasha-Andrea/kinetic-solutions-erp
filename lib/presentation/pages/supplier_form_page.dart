import 'package:flutter/material.dart';
import 'package:kinetic_solutions/core/auth/auth_service.dart';
import 'package:kinetic_solutions/core/theme/app_theme.dart';
import 'package:kinetic_solutions/data/datasources/local_database.dart';
import 'package:kinetic_solutions/domain/entities/supplier.dart';
import '../../domain/entities/app_user.dart';
import '../../presentation/widgets/shared_widgets.dart';
class SupplierFormPage extends StatefulWidget {
  final AppUser currentUser;
  final Supplier? supplier;

  const SupplierFormPage({
    super.key,
    required this.currentUser,
    this.supplier,
  });

  @override
  State<SupplierFormPage> createState() => _SupplierFormPageState();
}

class _SupplierFormPageState extends State<SupplierFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _companyController = TextEditingController();
  final _contactController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _taxIdController = TextEditingController();
  final _categoryController = TextEditingController();
  double? _rating;
  bool _isActive = true;
  bool _isLoading = false;

  final List<String> _categories = [
    'Materials',
    'Services',
    'Equipment',
    'Transport',
    'Consultancy',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.supplier != null) {
      _companyController.text = widget.supplier!.companyName;
      _contactController.text = widget.supplier!.contactPerson;
      _phoneController.text = widget.supplier!.phoneNumber;
      _emailController.text = widget.supplier!.email;
      _addressController.text = widget.supplier!.address;
      _taxIdController.text = widget.supplier!.taxId;
      _categoryController.text = widget.supplier!.category;
      _rating = widget.supplier!.rating;
      _isActive = widget.supplier!.isActive;
    }
  }

  @override
  void dispose() {
    _companyController.dispose();
    _contactController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _taxIdController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final supplier = Supplier(
        id: widget.supplier?.id ?? LocalDatabase.generateId(),
        companyName: _companyController.text.trim(),
        contactPerson: _contactController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        address: _addressController.text.trim(),
        taxId: _taxIdController.text.trim(),
        category: _categoryController.text.trim(),
        rating: _rating,
        totalOrders: widget.supplier?.totalOrders ?? 0,
        totalPurchases: widget.supplier?.totalPurchases ?? 0,
        isActive: _isActive,
        createdAt: widget.supplier?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await LocalDatabase.saveSupplier(supplier);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving supplier: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.supplier != null;
    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Supplier' : 'Add Supplier'),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
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
                      controller: _companyController,
                      decoration: const InputDecoration(
                        labelText: 'Company Name *',
                        prefixIcon: Icon(Icons.business),
                      ),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _contactController,
                      decoration: const InputDecoration(
                        labelText: 'Contact Person *',
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number *',
                        prefixIcon: Icon(Icons.phone),
                      ),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _addressController,
                      decoration: const InputDecoration(
                        labelText: 'Physical Address',
                        prefixIcon: Icon(Icons.location_on),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _taxIdController,
                      decoration: const InputDecoration(
                        labelText: 'TPIN (Tax ID)',
                        prefixIcon: Icon(Icons.receipt),
                      ),
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
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Rating (0-5)'),
                              Slider(
                                value: _rating ?? 0,
                                min: 0,
                                max: 5,
                                divisions: 10,
                                label: _rating?.toStringAsFixed(1) ?? '0.0',
                                onChanged: (val) => setState(() => _rating = val),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        SwitchListTile(
                          title: const Text('Active'),
                          value: _isActive,
                          onChanged: (val) => setState(() => _isActive = val),
                        ),
                      ],
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
                    : const Text('Save Supplier'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
