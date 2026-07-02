import 'package:flutter/material.dart';
import 'package:kinetic_solutions/core/auth/auth_service.dart';
import 'package:kinetic_solutions/core/theme/app_theme.dart';
import 'package:kinetic_solutions/data/datasources/local_database.dart';
import 'package:kinetic_solutions/domain/entities/quotation.dart';
import 'package:kinetic_solutions/presentation/pages/quotation_form_page.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/app_user.dart';

class QuotationPage extends StatefulWidget {
  final AppUser currentUser;

  const QuotationPage({super.key, required this.currentUser});

  @override
  State<QuotationPage> createState() => _QuotationPageState();
}

class _QuotationPageState extends State<QuotationPage> {
  List<Quotation> _allQuotations = [];
  List<Quotation> _filteredQuotations = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final qs = LocalDatabase.getQuotations();
    setState(() {
      _allQuotations = qs;
      _filteredQuotations = qs;
      _isLoading = false;
    });
  }

  void _applyFilters() {
    setState(() {
      _filteredQuotations = _allQuotations.where((q) {
        return _searchQuery.isEmpty ||
            q.quotationNumber.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            q.clientName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            (q.tenderReference?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
      }).toList();
    });
  }

  Future<void> _navigateToForm({Quotation? quotation}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuotationFormPage(
          currentUser: widget.currentUser,
          quotation: quotation,
        ),
      ),
    );
    await _loadData();
  }

  Future<void> _deleteQuotation(Quotation q) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Quotation'),
        content: Text('Delete "${q.quotationNumber}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete', style: TextStyle(color: AppTheme.errorColor))),
        ],
      ),
    );
    if (confirmed == true) {
      await LocalDatabase.deleteQuotation(q.id);
      await _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final canEdit = widget.currentUser.role.canEditInventory;
    final total = _allQuotations.length;
    final totalValue = _allQuotations.fold(0.0, (sum, q) => sum + q.total);

    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      appBar: AppBar(
        title: const Text('Quotations'),
        backgroundColor: Colors.indigo.shade700,
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
                _buildStatCard('Total', total, Colors.indigo.shade700),
                const SizedBox(width: 12),
                _buildStatCard('Total Value', totalValue, AppTheme.infoColor, isMoney: true),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search quotations...',
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
          Expanded(
            child: _isLoading
                ? _buildShimmer()
                : _filteredQuotations.isEmpty
                    ? const Center(child: Text('No quotations'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredQuotations.length,
                        itemBuilder: (ctx, i) {
                          final q = _filteredQuotations[i];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: AppTheme.primary50,
                                child: const Icon(Icons.description, color: AppTheme.primary500),
                              ),
                              title: Text(
                                q.quotationNumber,
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Client: ${q.clientName}'),
                                  if (q.tenderReference != null)
                                    Text('Tender: ${q.tenderReference}'),
                                  Text('Items: ${q.lineItems.length}'),
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
                                        'K ${NumberFormat('#,##0.00').format(q.total)}',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                      ),
                                      if (q.isVatable)
                                        const Text('incl. VAT', style: TextStyle(fontSize: 9, color: AppTheme.textSecondary)),
                                    ],
                                  ),
                                  const SizedBox(width: 8),
                                  if (canEdit)
                                    PopupMenuButton(
                                      onSelected: (value) {
                                        if (value == 'edit') _navigateToForm(quotation: q);
                                        else if (value == 'delete') _deleteQuotation(q);
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
    String display = isMoney ? 'K ${NumberFormat('#,##0.00').format(value)}' : value.toString();
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
            subtitle: SizedBox(height: 48, width: double.infinity),
          ),
        ),
      ),
    );
  }
}
