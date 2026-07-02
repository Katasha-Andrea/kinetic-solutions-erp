// lib/presentation/pages/ppe_issue_form_page.dart
import 'package:flutter/material.dart';
import 'package:kinetic_solutions/core/auth/auth_service.dart';
import 'package:kinetic_solutions/core/theme/app_theme.dart';
import 'package:kinetic_solutions/data/datasources/local_database.dart';
import 'package:kinetic_solutions/domain/entities/ppe_issue.dart';
import 'package:kinetic_solutions/domain/entities/employee.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/app_user.dart';
import '../../presentation/widgets/shared_widgets.dart';

class PPEIssueFormPage extends StatefulWidget {
  final AppUser currentUser;
  final PPEIssue? issue;

  const PPEIssueFormPage({super.key, required this.currentUser, this.issue});

  @override
  State<PPEIssueFormPage> createState() => _PPEIssueFormPageState();
}

class _PPEIssueFormPageState extends State<PPEIssueFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _ppeTypeController = TextEditingController();
  final _quantityController = TextEditingController();
  final _issueDateController = TextEditingController();
  final _returnDateController = TextEditingController();

  String? _employeeId;
  bool _isLoading = false;
  List<Employee> _employees = [];

  final List<String> _ppeTypes = ['Helmet', 'Boots', 'Vest', 'Gloves', 'Goggles', 'Ear Protection', 'Harness', 'Mask'];

  @override
  void initState() {
    super.initState();
    _loadEmployees();
    if (widget.issue != null) {
      final p = widget.issue!;
      _ppeTypeController.text = p.ppeType;
      _quantityController.text = p.quantity.toString();
      _issueDateController.text = DateFormat('yyyy-MM-dd').format(p.issueDate);
      if (p.returnDate != null) {
        _returnDateController.text = DateFormat('yyyy-MM-dd').format(p.returnDate!);
      }
      _employeeId = p.employeeId;
    }
  }

  Future<void> _loadEmployees() async {
    final emps = LocalDatabase.getEmployees();
    setState(() => _employees = emps);
  }

  @override
  void dispose() {
    _ppeTypeController.dispose();
    _quantityController.dispose();
    _issueDateController.dispose();
    _returnDateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(TextEditingController controller) async {
    final initial = controller.text.isNotEmpty
        ? DateFormat('yyyy-MM-dd').parse(controller.text)
        : DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (date != null) {
      controller.text = DateFormat('yyyy-MM-dd').format(date);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_employeeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Select employee')));
      return;
    }
    setState(() => _isLoading = true);
    try {
      final issue = PPEIssue(
        id: widget.issue?.id ?? LocalDatabase.generateId(),
        employeeId: _employeeId!,
        ppeType: _ppeTypeController.text.trim(),
        quantity: int.parse(_quantityController.text),
        issueDate: DateFormat('yyyy-MM-dd').parse(_issueDateController.text),
        returnDate: _returnDateController.text.isNotEmpty
            ? DateFormat('yyyy-MM-dd').parse(_returnDateController.text)
            : null,
      );
      await LocalDatabase.savePPEIssue(issue);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.issue != null;
    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      appBar: AppBar(
        title: Text(isEdit ? 'Edit PPE Issue' : 'New PPE Issue'),
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
                    DropdownButtonFormField<String>(
                      value: _employeeId,
                      decoration: const InputDecoration(labelText: 'Employee *', prefixIcon: Icon(Icons.person)),
                      items: _employees.map((e) => DropdownMenuItem(value: e.id, child: Text(e.fullName))).toList(),
                      onChanged: (val) => setState(() => _employeeId = val),
                      validator: (v) => v == null ? 'Select employee' : null,
                    ),
                    const SizedBox(height: 16),
                    Autocomplete<String>(
                      optionsBuilder: (TextEditingValue value) {
                        if (value.text.isEmpty) return const Iterable<String>.empty();
                        return _ppeTypes.where((t) => t.toLowerCase().contains(value.text.toLowerCase()));
                      },
                      onSelected: (value) => _ppeTypeController.text = value,
                      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                        return TextFormField(
                          controller: _ppeTypeController,
                          focusNode: focusNode,
                          decoration: const InputDecoration(labelText: 'PPE Type *', prefixIcon: Icon(Icons.security)),
                          validator: (v) => v!.isEmpty ? 'Required' : null,
                          onFieldSubmitted: (_) => onFieldSubmitted(),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _quantityController,
                      decoration: const InputDecoration(labelText: 'Quantity *', prefixIcon: Icon(Icons.numbers)),
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v!.isEmpty) return 'Required';
                        if (int.tryParse(v) == null) return 'Invalid number';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildDatePicker('Issue Date *', _issueDateController),
                    const SizedBox(height: 16),
                    _buildDatePicker('Return Date (optional)', _returnDateController),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _save,
                child: _isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Save PPE Issue'),
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
        suffixIcon: IconButton(icon: const Icon(Icons.date_range), onPressed: () => _selectDate(controller)),
      ),
      readOnly: true,
      onTap: () => _selectDate(controller),
      validator: (v) {
        if (label.contains('*') && (v == null || v.isEmpty)) return 'Required';
        return null;
      },
    );
  }
}
