import 'package:flutter/material.dart';
import 'package:kinetic_solutions/core/auth/auth_service.dart';
import 'package:kinetic_solutions/core/theme/app_theme.dart';
import 'package:kinetic_solutions/data/datasources/local_database.dart';
import 'package:kinetic_solutions/domain/entities/purchase_order.dart';
import 'package:kinetic_solutions/domain/entities/supplier.dart';
import 'package:kinetic_solutions/presentation/pages/purchase_order_form_page.dart';
import 'package:kinetic_solutions/presentation/widgets/shared_widgets.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/app_user.dart';

class PurchaseOrderPage extends StatefulWidget {
  final AppUser currentUser;

  const PurchaseOrderPage({super.key, required this.currentUser});

  @override
  State<PurchaseOrderPage> createState() => _PurchaseOrderPageState();
}

class _PurchaseOrderPageState extends State<PurchaseOrderPage> {
  List<PurchaseOrder> _allOrders = [];
  List<PurchaseOrder> _filteredOrders = [];
  List<Supplier> _suppliers = [];
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
    final orders = LocalDatabase.getPurchaseOrders();
    final suppliers = LocalDatabase.getSuppliers();
    setState(() {
      _allOrders = orders;
      _filteredOrders = orders;
      _suppliers = suppliers;
      _isLoading = false;
    });
  }

  void _applyFilters() {
    setState(() {
      _filteredOrders = _allOrders.where((o) {
        final matchesSearch = _searchQuery.isEmpty ||
            o.poNumber.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            o.supplierName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            o.requestedBy.toLowerCase().contains(_searchQuery.toLowerCase());
        final matchesStatus = _selectedStatus == 'All' || o.status.name == _selectedStatus;
        return matchesSearch && matchesStatus;
      }).toList();
    });
  }

  List<String> get _statusOptions => ['All', ...POStatus.values.map((e) => e.name)];

  Color _getStatusColor(POStatus status) {
    switch (status) {
      case POStatus.draft:
        return AppTheme.textMuted;
      case POStatus.pendingApproval:
        return AppTheme.warningColor;
      case POStatus.approved:
        return AppTheme.infoColor;
      case POStatus.sent:
        return AppTheme.primary500;
      case POStatus.delivered:
        return AppTheme.purpleColor;
      case POStatus.cancelled:
        return AppTheme.errorColor;
    }
  }

  Future<void> _navigateToForm({PurchaseOrder? order}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PurchaseOrderFormPage(
          currentUser: widget.currentUser,
          order: order,
        ),
      ),
    );
    await _loadData();
  }

  Future<void> _deleteOrder(PurchaseOrder order) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Purchase Order'),
        content: Text('Delete "${order.poNumber}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: AppTheme.errorColor)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await LocalDatabase.deletePurchaseOrder(order.id);
      await _loadData();
    }
  }

  Future<void> _updateStatus(PurchaseOrder order, POStatus newStatus) async {
    final updated = PurchaseOrder(
      id: order.id,
      poNumber: order.poNumber,
      supplierId: order.supplierId,
      supplierName: order.supplierName,
      orderDate: order.orderDate,
      total: order.total,
      status: newStatus,
      items: order.items,
      requestedBy: order.requestedBy,
      createdAt: order.createdAt,
    );
    await LocalDatabase.savePurchaseOrder(updated);
    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final canEdit = widget.currentUser.role.canEditInventory;
    final total = _allOrders.length;
    final pending = _allOrders.where((o) => o.status == POStatus.pendingApproval).length;
    final totalValue = _allOrders.fold(0.0, (sum, o) => sum + o.total);

    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      appBar: AppBar(
        title: const Text('Purchase Orders'),
        backgroundColor: Colors.orange.shade700,
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
          // Stats strip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _buildStatCard('Total', total, AppTheme.primary500),
                const SizedBox(width: 12),
                _buildStatCard('Pending', pending, AppTheme.warningColor),
                const SizedBox(width: 12),
                _buildStatCard('Total Value', totalValue, AppTheme.infoColor, isMoney: true),
              ],
            ),
          ),
          // Search and filters
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Search PO #, supplier...',
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
          // List
          Expanded(
            child: _isLoading
                ? _buildShimmer()
                : _filteredOrders.isEmpty
                    ? const EmptyState(
                        icon: Icons.shopping_cart,
                        title: 'No purchase orders found',
                        subtitle: 'Create your first PO',
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredOrders.length,
                        itemBuilder: (ctx, index) {
                          final o = _filteredOrders[index];
                          final itemCount = o.items.length;
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: _getStatusColor(o.status).withOpacity(0.15),
                                child: Icon(
                                  Icons.shopping_cart,
                                  color: _getStatusColor(o.status),
                                ),
                              ),
                              title: Text(
                                o.poNumber,
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Supplier: ${o.supplierName}'),
                                  Text('Requested by: ${o.requestedBy} • ${o.items.length} items'),
                                  Text('Date: ${DateFormat('dd MMM yyyy').format(o.orderDate)}'),
                                  const SizedBox(height: 4),
                                  _buildStatusChip(o.status),
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
                                        'K ${NumberFormat('#,##0.00').format(o.total)}',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 8),
                                  if (canEdit)
                                    PopupMenuButton<String>(
                                      onSelected: (value) {
                                        if (value == 'edit') {
                                          _navigateToForm(order: o);
                                        } else if (value == 'delete') {
                                          _deleteOrder(o);
                                        } else if (value == 'approve') {
                                          _updateStatus(o, POStatus.approved);
                                        } else if (value == 'send') {
                                          _updateStatus(o, POStatus.sent);
                                        } else if (value == 'deliver') {
                                          _updateStatus(o, POStatus.delivered);
                                        } else if (value == 'cancel') {
                                          _updateStatus(o, POStatus.cancelled);
                                        }
                                      },
                                      itemBuilder: (ctx) {
                                        final items = <PopupMenuItem<String>>[];
                                        if (o.status == POStatus.draft) {
                                          items.add(const PopupMenuItem(value: 'approve', child: Text('Approve')));
                                        }
                                        if (o.status == POStatus.approved) {
                                          items.add(const PopupMenuItem(value: 'send', child: Text('Send to Supplier')));
                                        }
                                        if (o.status == POStatus.sent) {
                                          items.add(const PopupMenuItem(value: 'deliver', child: Text('Mark Delivered')));
                                        }
                                        if (o.status != POStatus.cancelled && o.status != POStatus.delivered) {
                                          items.add(const PopupMenuItem(value: 'cancel', child: Text('Cancel')));
                                        }
                                        items.add(const PopupMenuItem(value: 'edit', child: Text('Edit')));
                                        items.add(const PopupMenuItem(value: 'delete', child: Text('Delete')));
                                        return items;
                                      },
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
            Text(
              display,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: color),
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(POStatus status) {
    return Chip(
      label: Text(status.name),
      backgroundColor: _getStatusColor(status).withOpacity(0.15),
      labelStyle: TextStyle(
        color: _getStatusColor(status),
        fontWeight: FontWeight.w500,
        fontSize: 10,
      ),
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
