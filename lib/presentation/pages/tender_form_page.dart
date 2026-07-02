import 'package:flutter/material.dart';
import 'package:kinetic_solutions/core/theme/app_theme.dart';
import 'package:kinetic_solutions/data/datasources/local_database.dart';
import 'package:kinetic_solutions/domain/entities/tender.dart';
import 'package:kinetic_solutions/domain/entities/app_user.dart';
import 'package:kinetic_solutions/presentation/widgets/document_picker.dart';
import 'package:kinetic_solutions/presentation/widgets/shared_widgets.dart';
import 'package:intl/intl.dart';

class TenderFormPage extends StatefulWidget {
  final AppUser currentUser;
  final Tender? tender;
  const TenderFormPage({super.key, required this.currentUser, this.tender});

  @override
  State<TenderFormPage> createState() => _TenderFormPageState();
}

class _TenderFormPageState extends State<TenderFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _tenderNumberController = TextEditingController();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _issuingOrgController = TextEditingController();
  final _closingDateController = TextEditingController();
  final _siteVisitDateController = TextEditingController();
  final _estimatedValueController = TextEditingController();
  final _bidBondPercentController = TextEditingController();
  final _validityDaysController = TextEditingController();
  final _contactInfoController = TextEditingController();
  final _categoryController = TextEditingController();

  TenderStatus _status = TenderStatus.open;
  List<String> _attachedDocumentIds = [];
  bool _isLoading = false;

  final List<String> _categories = ['Works', 'Goods', 'Services', 'Consultancy', 'Maintenance', 'IT'];

  @override
  void initState() {
    super.initState();
    if (widget.tender != null) {
      final t = widget.tender!;
      _tenderNumberController.text = t.tenderNumber;
      _titleController.text = t.title;
      _descriptionController.text = t.description;
      _issuingOrgController.text = t.issuingOrganization;
      _closingDateController.text = DateFormat('yyyy-MM-dd').format(t.closingDate);
      _siteVisitDateController.text = t.siteVisitDate != null
          ? DateFormat('yyyy-MM-dd').format(t.siteVisitDate!)
          : '';
      _estimatedValueController.text = t.estimatedValue.toString();
      _bidBondPercentController.text = t.bidBondPercentage.toString();
      _validityDaysController.text = t.validityDays.toString();
      _contactInfoController.text = t.contactInfo;
      _categoryController.text = t.category;
      _status = t.status;
      _attachedDocumentIds = List.from(t.attachedDocumentIds);
    }
  }

  @override
  void dispose() {
    _tenderNumberController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _issuingOrgController.dispose();
    _closingDateController.dispose();
    _siteVisitDateController.dispose();
    _estimatedValueController.dispose();
    _bidBondPercentController.dispose();
    _validityDaysController.dispose();
    _contactInfoController.dispose();
    _categoryController.dispose();
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
      final tender = Tender(
        id: widget.tender?.id ?? LocalDatabase.generateId(),
        tenderNumber: _tenderNumberController.text.trim().toUpperCase(),
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        issuingOrganization: _issuingOrgController.text.trim(),
        closingDate: DateFormat('yyyy-MM-dd').parse(_closingDateController.text),
        siteVisitDate: _siteVisitDateController.text.isNotEmpty
            ? DateFormat('yyyy-MM-dd').parse(_siteVisitDateController.text)
            : null,
        estimatedValue: double.parse(_estimatedValueController.text),
        bidBondPercentage: double.parse(_bidBondPercentController.text),
        validityDays: int.parse(_validityDaysController.text),
        requirements: widget.tender?.requirements ?? [],
        contactInfo: _contactInfoController.text.trim(),
        category: _categoryController.text.trim(),
        status: _status,
        attachedDocumentIds: _attachedDocumentIds,
      );
      await LocalDatabase.saveTender(tender);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving tender: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.tender != null;
    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Tender' : 'Add Tender'),
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
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _tenderNumberController,
                            decoration: const InputDecoration(
                              labelText: 'Tender Number *',
                              prefixIcon: Icon(Icons.confirmation_number),
                            ),
                            validator: (v) => v!.isEmpty ? 'Required' : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _titleController,
                            decoration: const InputDecoration(
                              labelText: 'Title *',
                              prefixIcon: Icon(Icons.title),
                            ),
                            validator: (v) => v!.isEmpty ? 'Required' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        prefixIcon: Icon(Icons.description),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _issuingOrgController,
                      decoration: const InputDecoration(
                        labelText: 'Issuing Organization *',
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
                    _buildDatePicker('Closing Date *', _closingDateController),
                    const SizedBox(height: 16),
                    _buildDatePicker('Site Visit Date (optional)', _siteVisitDateController),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _estimatedValueController,
                            decoration: const InputDecoration(
                              labelText: 'Estimated Value (ZMW) *',
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
                            controller: _bidBondPercentController,
                            decoration: const InputDecoration(
                              labelText: 'Bid Bond % *',
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
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _validityDaysController,
                      decoration: const InputDecoration(
                        labelText: 'Validity Period (days) *',
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v!.isEmpty) return 'Required';
                        if (int.tryParse(v) == null) return 'Invalid number';
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
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
                      controller: _contactInfoController,
                      decoration: const InputDecoration(
                        labelText: 'Contact Information *',
                        prefixIcon: Icon(Icons.contact_mail),
                      ),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<TenderStatus>(
                      value: _status,
                      decoration: const InputDecoration(
                        labelText: 'Status',
                        prefixIcon: Icon(Icons.flag),
                      ),
                      items: TenderStatus.values.map((status) {
                        return DropdownMenuItem(
                          value: status,
                          child: Text(status.name),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => _status = val!),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              FormCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Attach Documents', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 8),
                    DocumentPicker(
                      selectedIds: _attachedDocumentIds,
                      onChanged: (ids) => setState(() => _attachedDocumentIds = ids),
                      categoryFilter: 'Tender',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _save,
                child: _isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Save Tender'),
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
      validator: (v) {
        if (label.contains('*') && (v == null || v.isEmpty)) {
          return 'Required';
        }
        return null;
      },
    );
  }
}