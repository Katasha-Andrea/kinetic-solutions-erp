import 'package:flutter/material.dart';
import 'package:kinetic_solutions/core/theme/app_theme.dart';
import 'package:kinetic_solutions/data/datasources/local_database.dart';
import 'package:kinetic_solutions/domain/entities/tender.dart';
import 'package:kinetic_solutions/domain/entities/app_document.dart';
import 'package:kinetic_solutions/domain/entities/app_user.dart';
import 'package:kinetic_solutions/presentation/pages/tender_form_page.dart';
import 'package:kinetic_solutions/presentation/widgets/shared_widgets.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';

class TenderListPage extends StatefulWidget {
  final AppUser currentUser;
  const TenderListPage({super.key, required this.currentUser});

  @override
  State<TenderListPage> createState() => _TenderListPageState();
}

class _TenderListPageState extends State<TenderListPage> {
  List<Tender> _allTenders = [];
  List<Tender> _filteredTenders = [];
  List<AppDocument> _allDocuments = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedStatus = 'All';
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final tenders = LocalDatabase.getTenders();
    final docs = LocalDatabase.getDocuments();
    setState(() {
      _allTenders = tenders;
      _filteredTenders = tenders;
      _allDocuments = docs;
      _isLoading = false;
    });
  }

  void _applyFilters() {
    setState(() {
      _filteredTenders = _allTenders.where((t) {
        final matchesSearch = _searchQuery.isEmpty ||
            t.tenderNumber.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            t.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            t.issuingOrganization.toLowerCase().contains(_searchQuery.toLowerCase());
        final matchesStatus = _selectedStatus == 'All' || t.status.name == _selectedStatus;
        final matchesCategory = _selectedCategory == 'All' || t.category == _selectedCategory;
        return matchesSearch && matchesStatus && matchesCategory;
      }).toList();
    });
  }

  List<String> get _statusOptions => ['All', ...TenderStatus.values.map((e) => e.name)];
  List<String> get _categoryOptions {
    final set = <String>{};
    for (final t in _allTenders) {
      set.add(t.category);
    }
    return ['All', ...set.toList()..sort()];
  }

  Color _getStatusColor(TenderStatus status) {
    switch (status) {
      case TenderStatus.open: return AppTheme.primary500;
      case TenderStatus.closed: return AppTheme.warningColor;
      case TenderStatus.awarded: return AppTheme.infoColor;
      case TenderStatus.cancelled: return AppTheme.errorColor;
    }
  }

  String _getDaysRemaining(int days) {
    if (days < 0) return 'Expired';
    if (days == 0) return 'Today';
    return '$days days';
  }

  List<AppDocument> _getAttachedDocuments(List<String> docIds) {
    return _allDocuments.where((d) => docIds.contains(d.id)).toList();
  }

  Future<void> _navigateToForm({Tender? tender}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TenderFormPage(
          currentUser: widget.currentUser,
          tender: tender,
        ),
      ),
    );
    await _loadData();
  }

  Future<void> _deleteTender(Tender tender) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Tender'),
        content: Text('Delete "${tender.tenderNumber}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete', style: TextStyle(color: AppTheme.errorColor))),
        ],
      ),
    );
    if (confirmed == true) {
      await LocalDatabase.deleteTender(tender.id);
      await _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final canEdit = widget.currentUser.role.canEditProjects;
    final total = _allTenders.length;
    final open = _allTenders.where((t) => t.status == TenderStatus.open).length;
    final totalValue = _allTenders.fold(0.0, (sum, t) => sum + t.estimatedValue);

    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      appBar: AppBar(
        title: const Text('Tenders'),
        backgroundColor: AppTheme.purpleColor,
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
                _buildStatCard('Total', total, AppTheme.purpleColor),
                const SizedBox(width: 12),
                _buildStatCard('Open', open, AppTheme.primary500),
                const SizedBox(width: 12),
                _buildStatCard('Total Value', totalValue, AppTheme.infoColor, isMoney: true),
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
                      hintText: 'Search tenders...',
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
                  value: _selectedStatus,
                  items: _statusOptions.map((status) {
                    return DropdownMenuItem<String>(
                      value: status,
                      child: Text(status),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedStatus = value!;
                      _applyFilters();
                    });
                  },
                ),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: _selectedCategory,
                  items: _categoryOptions.map((cat) {
                    return DropdownMenuItem<String>(
                      value: cat,
                      child: Text(cat),
                    );
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
                : _filteredTenders.isEmpty
                    ? const EmptyState(
                        icon: Icons.gavel,
                        title: 'No tenders found',
                        subtitle: 'Add your first tender',
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredTenders.length,
                        itemBuilder: (ctx, index) {
                          final t = _filteredTenders[index];
                          final daysRemaining = t.daysRemaining;
                          final isExpiring = daysRemaining <= 7 && daysRemaining >= 0;
                          final attachedDocs = _getAttachedDocuments(t.attachedDocumentIds);
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: _getStatusColor(t.status).withOpacity(0.15),
                                child: Icon(Icons.gavel, color: _getStatusColor(t.status)),
                              ),
                              title: Text(t.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${t.tenderNumber} • ${t.issuingOrganization}'),
                                  Text('Category: ${t.category}'),
                                  Text('Closes: ${DateFormat('dd MMM yyyy').format(t.closingDate)}'),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      _buildStatusChip(t.status),
                                      const SizedBox(width: 8),
                                      Chip(
                                        label: Text('Bid Bond: ${t.bidBondPercentage}%', style: const TextStyle(fontSize: 10)),
                                        backgroundColor: AppTheme.accentLight,
                                      ),
                                      if (isExpiring)
                                        const Padding(
                                          padding: EdgeInsets.only(left: 4),
                                          child: Icon(Icons.warning, color: AppTheme.warningColor, size: 14),
                                        ),
                                    ],
                                  ),
                                  if (attachedDocs.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Wrap(
                                      spacing: 4,
                                      children: attachedDocs.map((doc) => Chip(
                                        label: Text(doc.title, style: const TextStyle(fontSize: 10)),
                                        backgroundColor: AppTheme.primary50,
                                      )).toList(),
                                    ),
                                  ],
                                  const SizedBox(height: 4),
                                  Text(
                                    '${_getDaysRemaining(daysRemaining)} remaining',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: daysRemaining < 0
                                          ? AppTheme.errorColor
                                          : isExpiring
                                              ? AppTheme.warningColor
                                              : AppTheme.textSecondary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'K ${NumberFormat('#,##0.00').format(t.estimatedValue)}',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                      ),
                                      const Text('Est. Value', style: TextStyle(fontSize: 9, color: AppTheme.textSecondary)),
                                    ],
                                  ),
                                  const SizedBox(width: 8),
                                  if (canEdit)
                                    PopupMenuButton<String>(
                                      onSelected: (value) {
                                        if (value == 'edit') _navigateToForm(tender: t);
                                        else if (value == 'delete') _deleteTender(t);
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

  Widget _buildStatCard(String label, dynamic value, Color color, {bool isMoney = false}) {
    String display;
    if (isMoney) {
      display = 'K ${NumberFormat('#,##0.00').format(value)}';
    } else if (value is double && value % 1 != 0) {
      display = value.toStringAsFixed(1);
    } else {
      display = value.toString();
    }
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
            Text(display, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: color)),
            Text(label, style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(TenderStatus status) {
    return Chip(
      label: Text(status.name),
      backgroundColor: _getStatusColor(status).withOpacity(0.15),
      labelStyle: TextStyle(color: _getStatusColor(status), fontWeight: FontWeight.w500, fontSize: 10),
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 6,
        itemBuilder: (ctx, index) => Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: const ListTile(
            leading: CircleAvatar(),
            title: SizedBox(height: 16, width: double.infinity),
            subtitle: SizedBox(height: 48, width: double.infinity),
          ),
        ),
      ),
    );
  }
}