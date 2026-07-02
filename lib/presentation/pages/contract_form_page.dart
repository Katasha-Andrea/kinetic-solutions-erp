import 'package:flutter/material.dart';
import 'package:kinetic_solutions/core/auth/auth_service.dart';
import 'package:kinetic_solutions/core/theme/app_theme.dart';
import 'package:kinetic_solutions/data/datasources/local_database.dart';
import 'package:kinetic_solutions/domain/entities/contract.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/app_user.dart';
import '../../presentation/widgets/shared_widgets.dart';

class ContractFormPage extends StatefulWidget {
  final AppUser currentUser;
  final Contract? contract;

  const ContractFormPage({super.key, required this.currentUser, this.contract});

  @override
  State<ContractFormPage> createState() => _ContractFormPageState();
}

class _ContractFormPageState extends State<ContractFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _contractNumberController = TextEditingController();
  final _titleController = TextEditingController();
  final _clientController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  final _maxValueController = TextEditingController();
  final _usedValueController = TextEditingController();
  final _performanceBondController = TextEditingController();

  ContractStatus _status = ContractStatus.active;
  ContractType _type = ContractType.framework;
  List<String> _variationOrders = [];
  List<String> _linkedProjects = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.contract != null) {
      final c = widget.contract!;
      _contractNumberController.text = c.contractNumber;
      _titleController.text = c.title;
      _clientController.text = c.clientName;
      _startDateController.text = DateFormat('yyyy-MM-dd').format(c.startDate);
      _endDateController.text = DateFormat('yyyy-MM-dd').format(c.endDate);
      _maxValueController.text = c.maximumValue.toString();
      _usedValueController.text = c.usedValue.toString();
      _performanceBondController.text = c.performanceBond?.toString() ?? '';
      _status = c.status;
      _type = c.type;
      _variationOrders = List.from(c.variationOrders);
      _linkedProjects = List.from(c.linkedProjects);
    }
  }

  @override
  void dispose() {
    _contractNumberController.dispose();
    _titleController.dispose();
    _clientController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _maxValueController.dispose();
    _usedValueController.dispose();
    _performanceBondController.dispose();
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
      final contract = Contract(
        id: widget.contract?.id ?? LocalDatabase.generateId(),
        contractNumber: _contractNumberController.text.trim().toUpperCase(),
        title: _titleController.text.trim(),
        clientName: _clientController.text.trim(),
        startDate: DateFormat('yyyy-MM-dd').parse(_startDateController.text),
        endDate: DateFormat('yyyy-MM-dd').parse(_endDateController.text),
        maximumValue: double.parse(_maxValueController.text),
        usedValue: double.tryParse(_usedValueController.text) ?? 0.0,
        status: _status,
        type: _type,
        performanceBond: _performanceBondController.text.isNotEmpty
            ? double.parse(_performanceBondController.text)
            : null,
        variationOrders: _variationOrders,
        linkedProjects: _linkedProjects,
        createdAt: widget.contract?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await LocalDatabase.saveContract(contract);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving contract: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.contract != null;
    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Contract' : 'Add Contract'),
        backgroundColor: AppTheme.primaryColor,
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
                      controller: _contractNumberController,
                      decoration: const InputDecoration(
                        labelText: 'Contract Number *',
                        prefixIcon: Icon(Icons.confirmation_number),
                      ),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Contract Title *',
                        prefixIcon: Icon(Icons.title),
                      ),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _clientController,
                      decoration: const InputDecoration(
                        labelText: 'Client Name *',
                        prefixIcon: Icon(Icons.business),
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
                    _buildDatePicker('Start Date *', _startDateController),
                    const SizedBox(height: 16),
                    _buildDatePicker('End Date *', _endDateController),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _maxValueController,
                            decoration: const InputDecoration(
                              labelText: 'Max Value (ZMW) *',
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
                            controller: _usedValueController,
                            decoration: const InputDecoration(
                              labelText: 'Used Value (ZMW)',
                              prefixIcon: Icon(Icons.trending_up),
                            ),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _performanceBondController,
                      decoration: const InputDecoration(
                        labelText: 'Performance Bond (ZMW)',
                        prefixIcon: Icon(Icons.security),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              FormCard(
                child: Column(
                  children: [
                    DropdownButtonFormField<ContractStatus>(
                      value: _status,
                      decoration: const InputDecoration(
                        labelText: 'Status',
                        prefixIcon: Icon(Icons.flag),
                      ),
                      items: ContractStatus.values.map((status) {
                        return DropdownMenuItem(
                          value: status,
                          child: Text(status.name),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => _status = val!),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<ContractType>(
                      value: _type,
                      decoration: const InputDecoration(
                        labelText: 'Contract Type',
                        prefixIcon: Icon(Icons.category),
                      ),
                      items: ContractType.values.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(type.name),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => _type = val!),
                    ),
                  ],
                ),
              ),
              // Note: variationOrders and linkedProjects could be expanded with add/remove UI.
              // For simplicity, we keep them as placeholders. You can add a more advanced UI later.
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _save,
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save Contract'),
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
