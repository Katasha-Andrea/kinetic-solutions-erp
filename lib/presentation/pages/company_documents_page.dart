import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:kinetic_solutions/core/theme/app_theme.dart';
import 'package:kinetic_solutions/data/datasources/local_database.dart';
import 'package:kinetic_solutions/domain/entities/app_document.dart';
import 'package:kinetic_solutions/domain/entities/app_user.dart';
import 'package:intl/intl.dart';

class CompanyDocumentsPage extends StatefulWidget {
  final AppUser currentUser;
  const CompanyDocumentsPage({super.key, required this.currentUser});

  @override
  State<CompanyDocumentsPage> createState() => _CompanyDocumentsPageState();
}

class _CompanyDocumentsPageState extends State<CompanyDocumentsPage> {
  List<AppDocument> _documents = [];
  bool _isLoading = true;

  final List<Map<String, dynamic>> _tenderDocs = [
    {'name': 'Company Profile', 'required': true},
    {'name': 'PACRA Registration', 'required': true},
    {'name': 'ZRA Tax Clearance', 'required': true},
    {'name': 'NAPSA Compliance', 'required': true},
    {'name': 'Certificate of Incorporation', 'required': true},
    {'name': 'VAT Registration', 'required': true},
    {'name': 'NHIMA Registration', 'required': false},
    {'name': 'ZPPA Registration', 'required': false},
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final docs = LocalDatabase.getDocuments();
    setState(() {
      _documents = docs.where((d) => d.category == 'Company' || d.category == 'Tender').toList();
      _isLoading = false;
    });
  }

  bool _isDocUploaded(String name) {
    return _documents.any((d) => d.title.toLowerCase().contains(name.toLowerCase()));
  }

  DateTime? _getDocExpiry(String name) {
    for (final doc in _documents) {
      if (doc.title.toLowerCase().contains(name.toLowerCase())) {
        return doc.expiryDate;
      }
    }
    return null;
  }

  Color _getStatusColor(String name) {
    if (!_isDocUploaded(name)) return Colors.grey;
    final expiry = _getDocExpiry(name);
    if (expiry == null) return Colors.green;
    if (expiry.isBefore(DateTime.now())) return Colors.red;
    if (expiry.difference(DateTime.now()).inDays <= 30) return Colors.orange;
    return Colors.green;
  }

  String _getStatusText(String name) {
    if (!_isDocUploaded(name)) return 'Not Uploaded';
    final expiry = _getDocExpiry(name);
    if (expiry == null) return 'Verified';
    if (expiry.isBefore(DateTime.now())) return 'Expired';
    if (expiry.difference(DateTime.now()).inDays <= 30) return 'Expiring Soon';
    return 'Verified';
  }

  Future<void> _uploadDocument() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.any,
    );

    if (result == null) return;

    final file = result.files.single;
    final fileName = file.name;
    final fileSize = file.size;
    final fileBytes = file.bytes;

    String fileUrl = '';
    if (fileBytes != null) {
      fileUrl = 'data:application/octet-stream;base64,${base64Encode(fileBytes)}';
    }

    final document = await _showDocumentDetailsDialog(fileName, fileSize, fileUrl);
    if (document != null) {
      await LocalDatabase.saveDocument(document);
      await _loadData();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Uploaded: ${document.title}')),
      );
    }
  }

  Future<AppDocument?> _showDocumentDetailsDialog(
    String fileName,
    int fileSize,
    String fileUrl,
  ) async {
    final titleController = TextEditingController(text: fileName.split('.').first);
    final categoryController = TextEditingController(text: 'Tender');
    final expiryDateController = TextEditingController();
    final tagsController = TextEditingController();

    return showDialog<AppDocument>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Document Details'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title *'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: categoryController.text,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: ['Tender', 'Company', 'HR', 'Project', 'Other']
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (val) => categoryController.text = val!,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: expiryDateController,
                  decoration: InputDecoration(
                    labelText: 'Expiry Date (YYYY-MM-DD)',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: ctx,
                          initialDate: DateTime.now().add(const Duration(days: 365)),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2030),
                        );
                        if (date != null) {
                          expiryDateController.text = DateFormat('yyyy-MM-dd').format(date);
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: tagsController,
                  decoration: const InputDecoration(
                    labelText: 'Tags (comma separated)',
                    hintText: 'e.g., tender, procurement',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(content: Text('Title is required')),
                  );
                  return;
                }
                final tags = tagsController.text
                    .split(',')
                    .map((t) => t.trim())
                    .where((t) => t.isNotEmpty)
                    .toList();
                final expiry = expiryDateController.text.isNotEmpty
                    ? DateFormat('yyyy-MM-dd').parse(expiryDateController.text)
                    : DateTime.now().add(const Duration(days: 365));

                final doc = AppDocument(
                  id: LocalDatabase.generateId(),
                  title: titleController.text.trim(),
                  type: DocumentType.quotation,
                  category: categoryController.text.trim(),
                  fileName: fileName,
                  fileUrl: fileUrl,
                  fileSize: fileSize,
                  uploadedBy: widget.currentUser.id,
                  uploadedAt: DateTime.now(),
                  expiryDate: expiry,
                  tags: tags,
                );
                Navigator.pop(ctx, doc);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final total = _tenderDocs.length;
    final uploaded = _tenderDocs.where((d) => _isDocUploaded(d['name'])).length;
    final valid = _tenderDocs.where((d) {
      final expiry = _getDocExpiry(d['name']);
      return _isDocUploaded(d['name']) && (expiry == null || !expiry.isBefore(DateTime.now()));
    }).length;

    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      appBar: AppBar(
        title: const Text('Company Documents'),
        backgroundColor: Colors.indigo.shade700,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _uploadDocument,
        child: const Icon(Icons.upload_file),
        tooltip: 'Upload new document',
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: AppTheme.softShadow,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Kinetic Solutions Limited',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text('TPIN: TPIN-100123456'),
                        Text('VAT: VAT-100123456'),
                        Text('Plot 123, Kafue Road, Lusaka, Zambia'),
                        Text('+260 977 123456 • info@kineticsolutions.co.zm'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildStat('Total Documents', total, Colors.indigo),
                      const SizedBox(width: 12),
                      _buildStat('Uploaded', uploaded, Colors.green),
                      const SizedBox(width: 12),
                      _buildStat('Valid', valid, Colors.blue),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: AppTheme.softShadow,
                    ),
                    child: Column(
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(16),
                          child: Text('Tender Readiness Checklist',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                        const Divider(),
                        ..._tenderDocs.asMap().entries.map((entry) {
                          final index = entry.key;
                          final doc = entry.value;
                          final status = _getStatusText(doc['name']);
                          final color = _getStatusColor(doc['name']);
                          return ListTile(
                            key: ValueKey('doc_$index'),
                            leading: Icon(
                              doc['required'] ? Icons.verified : Icons.help,
                              color: color,
                            ),
                            title: Text(doc['name']),
                            subtitle: Text(doc['required'] ? 'Required' : 'Recommended'),
                            trailing: Chip(
                              label: Text(status),
                              backgroundColor: color.withOpacity(0.15),
                              labelStyle: TextStyle(color: color, fontSize: 10),
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildStat(String label, int value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value.toString(), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color)),
            Text(label, style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
          ],
        ),
      ),
    );
  }
}