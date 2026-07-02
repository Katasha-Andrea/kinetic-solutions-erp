import 'package:flutter/material.dart';
import 'package:kinetic_solutions/core/auth/auth_service.dart';
import 'package:kinetic_solutions/core/theme/app_theme.dart';
import 'package:kinetic_solutions/data/datasources/local_database.dart';
import 'package:kinetic_solutions/domain/entities/app_document.dart';
import 'package:kinetic_solutions/presentation/pages/document_form_page.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/app_user.dart';

class DocumentListPage extends StatefulWidget {
  final AppUser currentUser;

  const DocumentListPage({super.key, required this.currentUser});

  @override
  State<DocumentListPage> createState() => _DocumentListPageState();
}

class _DocumentListPageState extends State<DocumentListPage> {
  List<AppDocument> _allDocuments = [];
  List<AppDocument> _filteredDocuments = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedType = 'All';
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final docs = LocalDatabase.getDocuments();
    setState(() {
      _allDocuments = docs;
      _filteredDocuments = docs;
      _isLoading = false;
    });
  }

  void _applyFilters() {
    setState(() {
      _filteredDocuments = _allDocuments.where((d) {
        final matchesSearch = _searchQuery.isEmpty ||
            d.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            d.fileName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            d.tags.any((t) => t.toLowerCase().contains(_searchQuery.toLowerCase()));
        final matchesType = _selectedType == 'All' || d.type.name == _selectedType;
        final matchesCategory = _selectedCategory == 'All' || d.category == _selectedCategory;
        return matchesSearch && matchesType && matchesCategory;
      }).toList();
    });
  }

  List<String> get _typeOptions {
    final set = <String>{};
    for (final d in _allDocuments) {
      set.add(d.type.name);
    }
    return ['All', ...set.toList()..sort()];
  }

  List<String> get _categoryOptions {
    final set = <String>{};
    for (final d in _allDocuments) {
      set.add(d.category);
    }
    return ['All', ...set.toList()..sort()];
  }

  Color _getTypeColor(DocumentType type) {
    switch (type) {
      case DocumentType.quotation:
        return Colors.indigo;
      case DocumentType.purchaseOrder:
        return Colors.orange;
      case DocumentType.miv:
        return Colors.teal;
      case DocumentType.payslip:
        return Colors.purple;
      case DocumentType.completionCertificate:
        return Colors.green;
      case DocumentType.leaveApproval:
        return Colors.blue;
    }
  }

  IconData _getTypeIcon(DocumentType type) {
    switch (type) {
      case DocumentType.quotation:
        return Icons.description;
      case DocumentType.purchaseOrder:
        return Icons.shopping_cart;
      case DocumentType.miv:
        return Icons.inventory;
      case DocumentType.payslip:
        return Icons.payment;
      case DocumentType.completionCertificate:
        return Icons.verified;
      case DocumentType.leaveApproval:
        return Icons.beach_access;
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  Future<void> _navigateToForm({AppDocument? document}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DocumentFormPage(
          currentUser: widget.currentUser,
          document: document,
        ),
      ),
    );
    await _loadData();
  }

  Future<void> _deleteDocument(AppDocument doc) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Document'),
        content: Text('Delete "${doc.title}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete', style: TextStyle(color: AppTheme.errorColor))),
        ],
      ),
    );
    if (confirmed == true) {
      await LocalDatabase.deleteDocument(doc.id);
      await _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final canEdit = widget.currentUser.role.canEditProjects;
    final total = _allDocuments.length;
    final expired = _allDocuments.where((d) => d.isExpired).length;
    final expiring = _allDocuments.where((d) => !d.isExpired && d.expiryDate.difference(DateTime.now()).inDays <= 30).length;

    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      appBar: AppBar(
        title: const Text('Documents'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        actions: [
          if (canEdit)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _navigateToForm(),
            ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _buildStatCard('Total', total, Colors.blue.shade700),
                const SizedBox(width: 12),
                _buildStatCard('Expiring Soon', expiring, AppTheme.warningColor),
                const SizedBox(width: 12),
                _buildStatCard('Expired', expired, AppTheme.errorColor),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Search by title, filename, tags...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                    ),
                    onChanged: (value) {
                      _searchQuery = value;
                      _applyFilters();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                DropdownButton<String>(
                  value: _selectedType,
                  items: _typeOptions.map((t) {
                    return DropdownMenuItem<String>(value: t, child: Text(t));
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedType = value!;
                      _applyFilters();
                    });
                  },
                ),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: _selectedCategory,
                  items: _categoryOptions.map((c) {
                    return DropdownMenuItem<String>(value: c, child: Text(c));
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value!;
                      _applyFilters();
                    });
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? _buildShimmer()
                : _filteredDocuments.isEmpty
                    ? const Center(child: Text('No documents'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredDocuments.length,
                        itemBuilder: (ctx, i) {
                          final d = _filteredDocuments[i];
                          final isExpired = d.isExpired;
                          final isExpiring = !isExpired && d.expiryDate.difference(DateTime.now()).inDays <= 30;
                          final color = _getTypeColor(d.type);
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: color.withOpacity(0.15),
                                child: Icon(_getTypeIcon(d.type), color: color),
                              ),
                              title: Text(
                                d.title,
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${d.type.name} • ${d.category}'),
                                  Text('${d.fileName} (${_formatFileSize(d.fileSize)})'),
                                  Text('Uploaded: ${DateFormat('dd MMM yyyy').format(d.uploadedAt)}'),
                                  Text(
                                    'Expires: ${DateFormat('dd MMM yyyy').format(d.expiryDate)}',
                                    style: TextStyle(
                                      color: isExpired
                                          ? AppTheme.errorColor
                                          : isExpiring
                                              ? AppTheme.warningColor
                                              : AppTheme.textSecondary,
                                      fontWeight: isExpired || isExpiring ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                  if (d.tags.isNotEmpty)
                                    Wrap(
                                      spacing: 4,
                                      children: d.tags.map((tag) => Chip(
                                        label: Text(tag, style: const TextStyle(fontSize: 10)),
                                        padding: EdgeInsets.zero,
                                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      )).toList(),
                                    ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (isExpired)
                                    const Icon(Icons.warning, color: AppTheme.errorColor),
                                  if (isExpiring && !isExpired)
                                    const Icon(Icons.timer, color: AppTheme.warningColor),
                                  const SizedBox(width: 8),
                                  if (canEdit)
                                    PopupMenuButton(
                                      onSelected: (value) {
                                        if (value == 'edit') _navigateToForm(document: d);
                                        else if (value == 'delete') _deleteDocument(d);
                                      },
                                      itemBuilder: (ctx) => const [
                                        PopupMenuItem(value: 'edit', child: Text('Edit')),
                                        PopupMenuItem(value: 'delete', child: Text('Delete')),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, int value, Color color) {
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

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 6,
        itemBuilder: (ctx, i) => Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: const ListTile(
            leading: CircleAvatar(),
            title: SizedBox(height: 16, width: double.infinity),
            subtitle: SizedBox(height: 80, width: double.infinity),
          ),
        ),
      ),
    );
  }
}
