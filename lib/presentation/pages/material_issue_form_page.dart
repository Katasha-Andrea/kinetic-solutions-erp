// lib/presentation/pages/material_issue_form_page.dart
import 'package:flutter/material.dart';
import 'package:kinetic_solutions/core/auth/auth_service.dart';
import 'package:kinetic_solutions/core/theme/app_theme.dart';
import 'package:kinetic_solutions/data/datasources/local_database.dart';
import 'package:kinetic_solutions/domain/entities/material_issue.dart';
import 'package:kinetic_solutions/domain/entities/project.dart';
import 'package:kinetic_solutions/domain/entities/inventory_item.dart';
import '../../domain/entities/app_user.dart';
import '../../presentation/widgets/shared_widgets.dart';

class MaterialIssueFormPage extends StatefulWidget {
  final AppUser currentUser;
  final MaterialIssue? issue;
  const MaterialIssueFormPage({super.key, required this.currentUser, this.issue});

  @override
  State<MaterialIssueFormPage> createState() => _MaterialIssueFormPageState();
}

class _MaterialIssueFormPageState extends State<MaterialIssueFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _issueNumberController = TextEditingController();
  final _requestedByController = TextEditingController();
  final _issuedByController = TextEditingController();
  String? _projectId;
  List<Map<String, dynamic>> _items = [];
  bool _isLoading = false;
  List<Project> _projects = [];
  List<InventoryItem> _inventory = [];

  @override
  void initState() {
    super.initState();
    _loadData();
    if (widget.issue != null) {
      final i = widget.issue!;
      _issueNumberController.text = i.issueNumber;
      _requestedByController.text = i.requestedBy;
      _issuedByController.text = i.issuedBy;
      _projectId = i.projectId;
      _items = List.from(i.items);
    }
  }

  Future<void> _loadData() async {
    final projs = LocalDatabase.getProjects();
    final inv = LocalDatabase.getInventoryItems();
    setState(() {
      _projects = projs;
      _inventory = inv;
    });
  }

  void _addItem() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Item'),
        content: StatefulBuilder(
          builder: (ctx, setStateDialog) {
            String? selectedId;
            int qty = 1;
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedId,
                  items: _inventory.map((i) => DropdownMenuItem(value: i.id, child: Text('${i.name} (${i.quantity} in stock)'))).toList(),
                  onChanged: (val) => setStateDialog(() => selectedId = val),
                  decoration: const InputDecoration(labelText: 'Item'),
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Quantity'),
                  keyboardType: TextInputType.number,
                  onChanged: (v) => qty = int.tryParse(v) ?? 1,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    if (selectedId != null && qty > 0) {
                      final item = _inventory.firstWhere((i) => i.id == selectedId);
                      setState(() {
                        _items.add({
                          'itemId': item.id,
                          'name': item.name,
                          'quantity': qty,
                          'unit': 'each',
                        });
                      });
                      Navigator.pop(ctx);
                    }
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_projectId == null) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Select project'))); return; }
    if (_items.isEmpty) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Add at least one item'))); return; }
    setState(() => _isLoading = true);
    try {
      final issue = MaterialIssue(
        id: widget.issue?.id ?? LocalDatabase.generateId(),
        issueNumber: _issueNumberController.text.trim(),
        projectId: _projectId!,
        projectName: _projects.firstWhere((p) => p.id == _projectId).name,
        requestedBy: _requestedByController.text.trim(),
        issuedBy: _issuedByController.text.trim(),
        items: _items,
        status: widget.issue?.status ?? MIVStatus.issued,
        createdAt: widget.issue?.createdAt ?? DateTime.now(),
      );
      await LocalDatabase.saveMaterialIssue(issue);
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
        title: Text(isEdit ? 'Edit MIV' : 'New MIV'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
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
                      controller: _issueNumberController,
                      decoration: const InputDecoration(labelText: 'MIV Number *', prefixIcon: Icon(Icons.confirmation_number)),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _projectId,
                      decoration: const InputDecoration(labelText: 'Project *', prefixIcon: Icon(Icons.business_center)),
                      items: _projects.map((p) => DropdownMenuItem(value: p.id, child: Text(p.name))).toList(),
                      onChanged: (val) => setState(() => _projectId = val),
                      validator: (v) => v == null ? 'Select project' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _requestedByController,
                      decoration: const InputDecoration(labelText: 'Requested By *', prefixIcon: Icon(Icons.person)),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _issuedByController,
                      decoration: const InputDecoration(labelText: 'Issued By *', prefixIcon: Icon(Icons.person_outline)),
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Items', style: TextStyle(fontWeight: FontWeight.bold)),
                        IconButton(
                          icon: const Icon(Icons.add, color: AppTheme.primary500),
                          onPressed: _addItem,
                        ),
                      ],
                    ),
                    ..._items.map((item) => ListTile(
                      title: Text(item['name']),
                      trailing: Text('Qty: ${item['quantity']}'),
                      leading: IconButton(
                        icon: const Icon(Icons.delete, color: AppTheme.errorColor),
                        onPressed: () => setState(() => _items.remove(item)),
                      ),
                    )).toList(),
                    if (_items.isEmpty) const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('No items added', style: TextStyle(color: AppTheme.textSecondary)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _save,
                child: _isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Save MIV'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
