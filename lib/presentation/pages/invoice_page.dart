import 'package:flutter/material.dart';
import 'package:kinetic_solutions/core/auth/auth_service.dart';
import 'package:kinetic_solutions/core/theme/app_theme.dart';
import 'package:kinetic_solutions/data/datasources/local_database.dart';
import 'package:kinetic_solutions/domain/entities/invoice.dart';
import 'package:kinetic_solutions/domain/entities/customer.dart';
import 'package:kinetic_solutions/presentation/pages/invoice_form_page.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/app_user.dart';

class InvoicePage extends StatefulWidget {
  final AppUser currentUser;

  const InvoicePage({super.key, required this.currentUser});

  @override
  State<InvoicePage> createState() => _InvoicePageState();
}

class _InvoicePageState extends State<InvoicePage> {
  List<Invoice> _allInvoices = [];
  List<Invoice> _filteredInvoices = [];
  List<Customer> _customers = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedStatus = 'All';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final invoices = LocalDatabase.getInvoices();
    final customers = LocalDatabase.getCustomers();
    setState(() {
      _allInvoices = invoices;
      _filteredInvoices = invoices;
      _customers = customers;
      _isLoading = false;
    });
  }

  void _applyFilters() {
    setState(() {
      _filteredInvoices = _allInvoices.where((i) {
        final customer = _customers.firstWhere((c) => c.id == i.customerId, orElse: () => throw Exception("Not found"));
        final customerName = customer?.companyName ?? '';
        final matchesSearch = _searchQuery.isEmpty ||
            i.invoiceNumber.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            customerName.toLowerCase().contains(_searchQuery.toLowerCase());
        final matchesStatus = _selectedStatus == 'All' || i.status.name == _selectedStatus;
        return matchesSearch && matchesStatus;
      }).toList();
    });
  }

  List<String> get _statusOptions => ['All', ...InvoiceStatus.values.map((e) => e.name)];

  Color _getStatusColor(InvoiceStatus status) {
    switch (status) {
      case InvoiceStatus.paid:
        return AppTheme.primary500;
      case InvoiceStatus.sent:
        return AppTheme.infoColor;
      case InvoiceStatus.overdue:
        return AppTheme.errorColor;
      case InvoiceStatus.draft:
        return AppTheme.textMuted;
      case InvoiceStatus.cancelled:
        return AppTheme.textMuted;
    }
  }

  String _getCustomerName(String customerId) {
    final c = _customers.firstWhere((c) => c.id == customerId, orElse: () => throw Exception("Not found"));
    return c?.companyName ?? 'Unknown';
  }

  Future<void> _navigateToForm({Invoice? invoice}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => InvoiceFormPage(
          currentUser: widget.currentUser,
          invoice: invoice,
        ),
      ),
    );
    await _loadData();
  }

  Future<void> _deleteInvoice(Invoice invoice) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Invoice'),
        content: Text('Delete "${invoice.invoiceNumber}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete', style: TextStyle(color: AppTheme.errorColor))),
        ],
      ),
    );
    if (confirmed == true) {
      await LocalDatabase.deleteInvoice(invoice.id);
      await _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final canEdit = widget.currentUser.role.canEditFinance;
    final total = _allInvoices.length;
    final paid = _allInvoices.where((i) => i.status == InvoiceStatus.paid).length;
    final overdue = _allInvoices.where((i) => i.isOverdue).length;
    final totalValue = _allInvoices.fold(0.0, (sum, i) => sum + i.total);

    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      appBar: AppBar(
        title: const Text('Invoices'),
        backgroundColor: Colors.green.shade700,
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
                _buildStatCard('Total', total, Colors.green.shade700),
                const SizedBox(width: 12),
                _buildStatCard('Paid', paid, AppTheme.primary500),
                const SizedBox(width: 12),
                _buildStatCard('Overdue', overdue, AppTheme.errorColor),
                const SizedBox(width: 12),
                _buildStatCard('Value', totalValue, AppTheme.infoColor, isMoney: true),
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
                      hintText: 'Search invoice #, customer...',
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
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? _buildShimmer()
                : _filteredInvoices.isEmpty
                    ? const Center(child: Text('No invoices'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredInvoices.length,
                        itemBuilder: (ctx, i) {
                          final inv = _filteredInvoices[i];
                          final isOverdue = inv.isOverdue;
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: _getStatusColor(inv.status).withOpacity(0.15),
                                child: Icon(Icons.receipt, color: _getStatusColor(inv.status)),
                              ),
                              title: Text(
                                inv.invoiceNumber,
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Customer: ${_getCustomerName(inv.customerId)}'),
                                  Text('Due: ${DateFormat('dd MMM yyyy').format(inv.dueDate)}'),
                                  if (isOverdue)
                                    const Text('OVERDUE', style: TextStyle(color: AppTheme.errorColor, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 4),
                                  _buildStatusChip(inv.status),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'K ${NumberFormat('#,##0.00').format(inv.total)}',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                  ),
                                  const SizedBox(width: 8),
                                  if (canEdit)
                                    PopupMenuButton(
                                      onSelected: (value) {
                                        if (value == 'edit') _navigateToForm(invoice: inv);
                                        else if (value == 'delete') _deleteInvoice(inv);
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

  Widget _buildStatusChip(InvoiceStatus status) {
    return Chip(
      label: Text(status.name),
      backgroundColor: _getStatusColor(status).withOpacity(0.15),
      labelStyle: TextStyle(color: _getStatusColor(status), fontSize: 10),
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
