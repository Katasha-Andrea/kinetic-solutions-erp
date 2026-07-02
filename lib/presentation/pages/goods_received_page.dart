// lib/presentation/pages/goods_received_page.dart
import 'package:flutter/material.dart';
import 'package:kinetic_solutions/core/auth/auth_service.dart';
import 'package:kinetic_solutions/core/theme/app_theme.dart';
import 'package:kinetic_solutions/data/datasources/local_database.dart';
import 'package:kinetic_solutions/domain/entities/goods_received.dart';
import 'package:kinetic_solutions/domain/entities/purchase_order.dart';
import 'package:kinetic_solutions/presentation/pages/goods_received_form_page.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/app_user.dart';

class GoodsReceivedPage extends StatefulWidget {
  final AppUser currentUser;

  const GoodsReceivedPage({super.key, required this.currentUser});

  @override
  State<GoodsReceivedPage> createState() => _GoodsReceivedPageState();
}

class _GoodsReceivedPageState extends State<GoodsReceivedPage> {
  List<GoodsReceived> _allGRNs = [];
  List<GoodsReceived> _filteredGRNs = [];
  List<PurchaseOrder> _pos = [];
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
    final grns = LocalDatabase.getGoodsReceived();
    final pos = LocalDatabase.getPurchaseOrders();
    setState(() {
      _allGRNs = grns;
      _filteredGRNs = grns;
      _pos = pos;
      _isLoading = false;
    });
  }

  void _applyFilters() {
    setState(() {
      _filteredGRNs = _allGRNs.where((g) {
        final matchesSearch = _searchQuery.isEmpty ||
            g.grnNumber.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            g.supplierName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            g.poNumber.toLowerCase().contains(_searchQuery.toLowerCase());
        final matchesStatus = _selectedStatus == 'All' || g.status.name == _selectedStatus;
        return matchesSearch && matchesStatus;
      }).toList();
    });
  }

  List<String> get _statusOptions => ['All', ...GRNStatus.values.map((e) => e.name)];

  Color _getStatusColor(GRNStatus status) {
    return status == GRNStatus.received ? AppTheme.warningColor : AppTheme.primary500;
  }

  Future<void> _navigateToForm({GoodsReceived? grn}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GoodsReceivedFormPage(
          currentUser: widget.currentUser,
          grn: grn,
        ),
      ),
    );
    await _loadData();
  }

  Future<void> _deleteGRN(GoodsReceived grn) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete GRN'),
        content: Text('Delete "${grn.grnNumber}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete', style: TextStyle(color: AppTheme.errorColor))),
        ],
      ),
    );
    if (confirmed == true) {
      await LocalDatabase.deleteGoodsReceived(grn.id);
      await _loadData();
    }
  }

  Future<void> _acceptGRN(GoodsReceived grn) async {
    final updated = GoodsReceived(
      id: grn.id,
      grnNumber: grn.grnNumber,
      poId: grn.poId,
      poNumber: grn.poNumber,
      supplierId: grn.supplierId,
      supplierName: grn.supplierName,
      receivedDate: grn.receivedDate,
      items: grn.items,
      receivedBy: grn.receivedBy,
      status: GRNStatus.accepted,
    );
    await LocalDatabase.saveGoodsReceived(updated);
    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final canEdit = widget.currentUser.role.canEditInventory;
    final total = _allGRNs.length;
    final accepted = _allGRNs.where((g) => g.status == GRNStatus.accepted).length;

    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      appBar: AppBar(
        title: const Text('Goods Received'),
        backgroundColor: Colors.teal,
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
                _buildStatCard('Total', total, Colors.teal),
                const SizedBox(width: 12),
                _buildStatCard('Accepted', accepted, AppTheme.primary500),
                const SizedBox(width: 12),
                _buildStatCard('Pending', total - accepted, AppTheme.warningColor),
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
                      hintText: 'Search GRN #, supplier, PO...',
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
                : _filteredGRNs.isEmpty
                    ? const Center(child: Text('No GRNs found'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredGRNs.length,
                        itemBuilder: (ctx, i) {
                          final g = _filteredGRNs[i];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: _getStatusColor(g.status).withOpacity(0.15),
                                child: Icon(Icons.checklist, color: _getStatusColor(g.status)),
                              ),
                              title: Text(g.grnNumber, style: const TextStyle(fontWeight: FontWeight.w600)),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Supplier: ${g.supplierName} • PO: ${g.poNumber}'),
                                  Text('Received: ${DateFormat('dd MMM yyyy').format(g.receivedDate)}'),
                                  Text('Items: ${g.items.length}'),
                                  const SizedBox(height: 4),
                                  _buildStatusChip(g.status),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (g.status == GRNStatus.received && canEdit)
                                    IconButton(
                                      icon: const Icon(Icons.check_circle, color: AppTheme.primary500),
                                      onPressed: () => _acceptGRN(g),
                                    ),
                                  if (canEdit)
                                    PopupMenuButton(
                                      onSelected: (value) {
                                        if (value == 'edit') _navigateToForm(grn: g);
                                        else if (value == 'delete') _deleteGRN(g);
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

  Widget _buildStatusChip(GRNStatus status) {
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
