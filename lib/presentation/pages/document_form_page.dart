import 'package:flutter/material.dart';
import 'package:kinetic_solutions/core/auth/auth_service.dart';
import 'package:kinetic_solutions/core/theme/app_theme.dart';
import 'package:kinetic_solutions/data/datasources/local_database.dart';
import 'package:kinetic_solutions/domain/entities/app_document.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/app_user.dart';
import '../../presentation/widgets/shared_widgets.dart';

class DocumentFormPage extends StatefulWidget {
  final AppUser currentUser;
  final AppDocument? document;

  const DocumentFormPage({
    super.key,
    required this.currentUser,
    this.document,
  });

  @override
  State<DocumentFormPage> createState() => _DocumentFormPageState();
}

class _DocumentFormPageState extends State<DocumentFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _fileNameController = TextEditingController();
  final _fileUrlController = TextEditingController();
  final _fileSizeController = TextEditingController();
  final _categoryController = TextEditingController();
  final _expiryDateController = TextEditingController();
  final _tagsController = TextEditingController();

  DocumentType _type = DocumentType.quotation;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.document != null) {
      final d = widget.document!;
      _titleController.text = d.title;
      _fileNameController.text = d.fileName;
      _fileUrlController.text = d.fileUrl;
      _fileSizeController.text = d.fileSize.toString();
      _categoryController.text = d.category;
      _expiryDateController.text = DateFormat('yyyy-MM-dd').format(d.expiryDate);
      _type = d.type;
      _tagsController.text = d.tags.join(', ');
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _fileNameController.dispose();
    _fileUrlController.dispose();
    _fileSizeController.dispose();
    _categoryController.dispose();
    _expiryDateController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final initial = _expiryDateController.text.isNotEmpty
        ? DateFormat('yyyy-MM-dd').parse(_expiryDateController.text)
        : DateTime.now().add(const Duration(days: 365));
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (date != null) {
      _expiryDateController.text = DateFormat('yyyy-MM-dd').format(date);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final tags = _tagsController.text.split(',')
          .map((t) => t.trim())
          .where((t) => t.isNotEmpty)
          .toList();

      final document = AppDocument(
        id: widget.document?.id ?? LocalDatabase.generateId(),
        title: _titleController.text.trim(),
        type: _type,
        category: _categoryController.text.trim(),
        fileName: _fileNameController.text.trim(),
        fileUrl: _fileUrlController.text.trim(),
        fileSize: int.parse(_fileSizeController.text),
        uploadedBy: widget.currentUser.id,
        uploadedAt: widget.document?.uploadedAt ?? DateTime.now(),
        expiryDate: DateFormat('yyyy-MM-dd').parse(_expiryDateController.text),
        tags: tags,
      );
      await LocalDatabase.saveDocument(document);
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
    final isEdit = widget.document != null;
    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Document' : 'Add Document'),
        backgroundColor: Colors.blue.shade700,
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
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Title *',
                        prefixIcon: Icon(Icons.title),
                      ),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<DocumentType>(
                      value: _type,
                      decoration: const InputDecoration(
                        labelText: 'Document Type *',
                        prefixIcon: Icon(Icons.category),
                      ),
                      items: DocumentType.values.map((t) {
                        return DropdownMenuItem(
                          value: t,
                          child: Text(t.name),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => _type = val!),
                      validator: (v) => v == null ? 'Select type' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _categoryController,
                      decoration: const InputDecoration(
                        labelText: 'Category * (e.g., Procurement, HR, Projects)',
                        prefixIcon: Icon(Icons.folder),
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
                    TextFormField(
                      controller: _fileNameController,
                      decoration: const InputDecoration(
                        labelText: 'File Name *',
                        prefixIcon: Icon(Icons.file_present),
                      ),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _fileUrlController,
                      decoration: const InputDecoration(
                        labelText: 'File Path / URL *',
                        prefixIcon: Icon(Icons.link),
                      ),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _fileSizeController,
                      decoration: const InputDecoration(
                        labelText: 'File Size (bytes) *',
                        prefixIcon: Icon(Icons.storage),
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
                    _buildDatePicker(),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _tagsController,
                      decoration: const InputDecoration(
                        labelText: 'Tags (comma separated)',
                        prefixIcon: Icon(Icons.label),
                        hintText: 'e.g., tender, procurement, 2025',
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
                    : const Text('Save Document'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDatePicker() {
    return TextFormField(
      controller: _expiryDateController,
      decoration: InputDecoration(
        labelText: 'Expiry Date *',
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
