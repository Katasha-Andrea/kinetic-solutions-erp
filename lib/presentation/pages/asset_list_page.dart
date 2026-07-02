import 'package:flutter/material.dart';
import 'package:kinetic_solutions/core/auth/auth_service.dart';
import 'package:kinetic_solutions/core/theme/app_theme.dart';
import 'package:kinetic_solutions/data/datasources/local_database.dart';
import 'package:kinetic_solutions/domain/entities/asset.dart';
import 'package:kinetic_solutions/domain/entities/employee.dart';
import 'package:kinetic_solutions/presentation/pages/asset_form_page.dart';
import 'package:kinetic_solutions/presentation/widgets/shared_widgets.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/app_user.dart';

class AssetListPage extends StatefulWidget {
  final AppUser currentUser;

  const AssetListPage({super.key, required this.currentUser});

  @override
  State<AssetListPage> createState() => _AssetListPageState();
}

class _AssetListPageState extends State<AssetListPage> {
  List<Asset> _allAssets = [];
  List<Asset> _filteredAssets = [];
  List<Employee> _employees = [];
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
    final assets = LocalDatabase.getAssets();
    final employees = LocalDatabase.getEmployees();
    setState(() {
      _allAssets = assets;
      _filteredAssets = assets;
      _employees = employees;
      _isLoading = false;
    });
  }

  void _applyFilters() {
    setState(() {
      _filteredAssets = _allAssets.where((a) {
        final matchesSearch = _searchQuery.isEmpty ||
            a.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            a.serialNumber.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            a.category.toLowerCase().contains(_searchQuery.toLowerCase());
        final matchesStatus = _selectedStatus == 'All' || a.status.name == _selectedStatus;
        final matchesCategory = _selectedCategory == 'All' || a.category == _selectedCategory;
        return matchesSearch && matchesStatus && matchesCategory;
      }).toList();
    });
  }

  List<String> get _statusOptions => ['All', ...AssetStatus.values.map((e) => e.name)];
  List<String> get _categoryOptions {
    final set = <String>{};
    for (final a in _allAssets) {
      set.add(a.category);
    }
    return ['All', ...set.toList()..sort()];
  }

  Color _getStatusColor(AssetStatus status) {
    switch (status) {
      case AssetStatus.active:
        return AppTheme.primary500;
      case AssetStatus.maintenance:
        return AppTheme.warningColor;
      case AssetStatus.disposed:
        return AppTheme.errorColor;
      case AssetStatus.transferred:
        return AppTheme.infoColor;
    }
  }

  IconData _getStatusIcon(AssetStatus status) {
    switch (status) {
      case AssetStatus.active:
        return Icons.check_circle;
      case AssetStatus.maintenance:
        return Icons.build;
      case AssetStatus.disposed:
        return Icons.delete_forever;
      case AssetStatus.transferred:
        return Icons.swap_horiz;
    }
  }

  String _getEmployeeName(String? empId) {
    if (empId == null) return 'Unassigned';
    final emp = _employees.firstWhere((e) => e.id == empId, orElse: () => throw Exception("Not found"));
    return emp?.fullName ?? 'Unknown';
  }

  bool _isWarrantyExpired(DateTime expiry) => expiry.isBefore(DateTime.now());

  Future<void> _navigateToForm({Asset? asset}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AssetFormPage(
          currentUser: widget.currentUser,
          asset: asset,
        ),
      ),
    );
    await _loadData();
  }

  Future<void> _deleteAsset(Asset asset) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Asset'),
        content: Text('Delete "${asset.name}"?'),
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
      await LocalDatabase.deleteAsset(asset.id);
      await _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final canEdit = widget.currentUser.role.canEditInventory;
    final totalValue = _allAssets.fold(0.0, (sum, a) => sum + a.currentValue);
    final totalCost = _allAssets.fold(0.0, (sum, a) => sum + a.purchaseCost);
    final depreciation = totalCost - totalValue;
    final activeCount = _allAssets.where((a) => a.status == AssetStatus.active).length;

    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      appBar: AppBar(
        title: const Text('Assets'),
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
          // Stats strip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _buildStatCard('Total', _allAssets.length, AppTheme.purpleColor),
                const SizedBox(width: 12),
                _buildStatCard('Active', activeCount, AppTheme.primary500),
                const SizedBox(width: 12),
                _buildStatCard('Total Value', totalValue, AppTheme.infoColor, isMoney: true),
                const SizedBox(width: 12),
                _buildStatCard('Depreciation', depreciation, AppTheme.warningColor, isMoney: true),
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
                      hintText: 'Search assets...',
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
          // List
          Expanded(
            child: _isLoading
                ? _buildShimmer()
                : _filteredAssets.isEmpty
                    ? const EmptyState(
                        icon: Icons.inventory_2,
                        title: 'No assets found',
                        subtitle: 'Add your first asset',
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredAssets.length,
                        itemBuilder: (ctx, index) {
                          final a = _filteredAssets[index];
                          final warrantyExpired = _isWarrantyExpired(a.warrantyExpiry);
                          final depreciatedValue = a.depreciatedValue;
                          final deprecPercent = a.purchaseCost > 0
                              ? ((a.purchaseCost - depreciatedValue) / a.purchaseCost * 100)
                              : 0;

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: _getStatusColor(a.status).withOpacity(0.15),
                                child: Icon(
                                  _getStatusIcon(a.status),
                                  color: _getStatusColor(a.status),
                                ),
                              ),
                              title: Text(
                                a.name,
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${a.category} • SN: ${a.serialNumber}'),
                                  Text('Assigned: ${_getEmployeeName(a.assignedToEmployee)}'),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      _buildStatusChip(a.status),
                                      if (warrantyExpired)
                                        const Padding(
                                          padding: EdgeInsets.only(left: 4),
                                          child: Icon(Icons.warning, color: AppTheme.errorColor, size: 14),
                                        ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Depr: ${deprecPercent.toStringAsFixed(0)}%',
                                        style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary),
                                      ),
                                    ],
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
                                        'K ${NumberFormat('#,##0.00').format(a.currentValue)}',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                      ),
                                      Text(
                                        'Cost: K ${NumberFormat('#,##0.00').format(a.purchaseCost)}',
                                        style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 8),
                                  if (canEdit)
                                    PopupMenuButton<String>(
                                      onSelected: (value) {
                                        if (value == 'edit') {
                                          _navigateToForm(asset: a);
                                        } else if (value == 'delete') {
                                          _deleteAsset(a);
                                        }
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

  Widget _buildStatusChip(AssetStatus status) {
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
