import 'package:flutter/material.dart';
import 'package:kinetic_solutions/core/auth/auth_service.dart';
import 'package:kinetic_solutions/core/theme/app_theme.dart';
import 'package:kinetic_solutions/data/datasources/local_database.dart';
import 'package:kinetic_solutions/domain/entities/expense.dart';
import 'package:kinetic_solutions/domain/entities/project.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/app_user.dart';
import '../../presentation/widgets/shared_widgets.dart';

class ExpenseFormPage extends StatefulWidget {
  final AppUser currentUser;
  final Expense? expense;

  const ExpenseFormPage({super.key, required this.currentUser, this.expense});

  @override
  State<ExpenseFormPage> createState() => _ExpenseFormPageState();
}

class _ExpenseFormPageState extends State<ExpenseFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _dateController = TextEditingController();
  final _categoryController = TextEditingController();
  ExpenseStatus _status = ExpenseStatus.pending;
  String? _projectId;
  bool _isLoading = false;
  List<Project> _projects = [];

  final List<String> _categories = [
    'Fuel',
    'Travel',
    'Office Supplies',
    'Utilities',
    'Maintenance',
    'Training',
    'Equipment Rental',
    'Subcontractors',
    'Accommodation',
    'Meals',
    'Communication',
    'Insurance',
    'Taxes',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _loadProjects();
    if (widget.expense != null) {
      final e = widget.expense!;
      _descriptionController.text = e.description;
      _amountController.text = e.amount.toString();
      _dateController.text = DateFormat('yyyy-MM-dd').format(e.date);
      _categoryController.text = e.category;
      _status = e.status;
      _projectId = e.projectId;
    }
  }

  Future<void> _loadProjects() async {
    _projects = LocalDatabase.getProjects();
    setState(() {});
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    _dateController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final initial = _dateController.text.isNotEmpty
        ? DateFormat('yyyy-MM-dd').parse(_dateController.text)
        : DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2030),
    );
    if (date != null) {
      _dateController.text = DateFormat('yyyy-MM-dd').format(date);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final expense = Expense(
        id: widget.expense?.id ?? LocalDatabase.generateId(),
        category: _categoryController.text.trim(),
        description: _descriptionController.text.trim(),
        amount: double.parse(_amountController.text),
        date: DateFormat('yyyy-MM-dd').parse(_dateController.text),
        status: _status,
        projectId: _projectId,
        receiptImage: widget.expense?.receiptImage, // preserve if any
      );
      await LocalDatabase.saveExpense(expense);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving expense: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.expense != null;
    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Expense' : 'Add Expense'),
        backgroundColor: AppTheme.infoColor,
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
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description *',
                        prefixIcon: Icon(Icons.description),
                      ),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _amountController,
                      decoration: const InputDecoration(
                        labelText: 'Amount (ZMW) *',
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
                    DropdownButtonFormField<ExpenseStatus>(
                      value: _status,
                      decoration: const InputDecoration(
                        labelText: 'Status',
                        prefixIcon: Icon(Icons.flag),
                      ),
                      items: ExpenseStatus.values.map((status) {
                        return DropdownMenuItem(
                          value: status,
                          child: Text(status.name),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => _status = val!),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _projectId,
                      decoration: const InputDecoration(
                        labelText: 'Linked Project (optional)',
                        prefixIcon: Icon(Icons.business_center),
                      ),
                      items: [
                        const DropdownMenuItem(value: null, child: Text('None')),
                        ..._projects.map((p) {
                          return DropdownMenuItem(
                            value: p.id,
                            child: Text(p.name),
                          );
                        }),
                      ],
                      onChanged: (val) => setState(() => _projectId = val),
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
                    : const Text('Save Expense'),
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
        labelText: 'Date *',
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
