import 'package:flutter/material.dart';
import 'package:kinetic_solutions/core/auth/auth_service.dart';
import 'package:kinetic_solutions/core/theme/app_theme.dart';
import 'package:kinetic_solutions/data/datasources/local_database.dart';
import 'package:kinetic_solutions/domain/entities/supplier.dart';
import 'package:kinetic_solutions/presentation/pages/supplier_form_page.dart';
import 'package:kinetic_solutions/presentation/widgets/shared_widgets.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/app_user.dart';

class SupplierListPage extends StatefulWidget {
  final AppUser currentUser;

  const SupplierListPage({super.key, required this.currentUser});

  @override
  State<SupplierListPage> createState() => _SupplierListPageState();
}

class _SupplierListPageState extends State<SupplierListPage> {
  List<Supplier> _allSuppliers = [];
  List<Supplier> _filteredSuppliers = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    _loadSuppliers();
  }

  Future<void> _loadSuppliers() async {
    setState(() => _isLoading = true);
    final suppliers = LocalDatabase.getSuppliers();
    setState(() {
      _allSuppliers = suppliers;
      _filteredSuppliers = suppliers;
      _isLoading = false;
    });
  }

  void _applyFilters() {
    setState(() {
      _filteredSuppliers = _allSuppliers.where((supplier) {
        final matchesSearch = _searchQuery.isEmpty ||
            supplier.companyName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            supplier.contactPerson.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            supplier.phoneNumber.contains(_searchQuery);
        final matchesCategory = _selectedCategory == 'All' ||
            supplier.category == _selectedCategory;
        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  List<String> get _categories {
    final set = <String>{};
    for (final s in _allSuppliers) {
      set.add(s.category);
    }
    return ['All', ...set.toList()..sort()];
  }

  Future<void> _navigateToForm({Supplier? supplier}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SupplierFormPage(
          currentUser: widget.currentUser,
          supplier: supplier,
        ),
      ),
    );
    await _loadSuppliers();
  }

  Future<void> _deleteSupplier(Supplier supplier) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Supplier'),
        content: Text('Are you sure you want to delete "${supplier.companyName}"?'),
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
      await LocalDatabase.deleteSupplier(supplier.id);
      await _loadSuppliers();
    }
  }

  @override
  Widget build(BuildContext context) {
    final canEdit = widget.currentUser.role.canEditInventory; // Reuse inventory permission, or we could add a specific supplier permission

    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      appBar: AppBar(
        title: const Text('Suppliers'),
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
                _buildStatCard('Total', _allSuppliers.length, AppTheme.primary500),
                const SizedBox(width: 12),
                _buildStatCard('Active', _allSuppliers.where((s) => s.isActive).length, AppTheme.infoColor),
                const SizedBox(width: 12),
                _buildStatCard('Categories', _categories.length - 1, AppTheme.purpleColor),
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
                      hintText: 'Search suppliers...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                        borderSide: BorderSide(color: AppTheme.borderColor),
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
                  value: _selectedCategory,
                  items: _categories.map((cat) {
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
                : _filteredSuppliers.isEmpty
                    ? const EmptyState(
                        icon: Icons.store,
                        title: 'No suppliers found',
                        subtitle: 'Add your first supplier',
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredSuppliers.length,
                        itemBuilder: (ctx, index) {
                          final supplier = _filteredSuppliers[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: AppTheme.primary50,
                                child: Text(
                                  supplier.companyName.substring(0, 1).toUpperCase(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryColor,
                                  ),
                                ),
                              ),
                              title: Text(
                                supplier.companyName,
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${supplier.contactPerson} • ${supplier.phoneNumber}'),
                                  if (supplier.rating != null)
                                    Row(
                                      children: [
                                        ...List.generate(
                                          supplier.rating!.floor(),
                                          (_) => const Icon(Icons.star, size: 16, color: Colors.amber),
                                        ),
                                        if (supplier.rating! % 1 >= 0.5)
                                          const Icon(Icons.star_half, size: 16, color: Colors.amber),
                                      ],
                                    ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Chip(
                                    label: Text(supplier.category),
                                    backgroundColor: AppTheme.infoLight,
                                    labelStyle: const TextStyle(fontSize: 10),
                                  ),
                                  if (!supplier.isActive)
                                    const Padding(
                                      padding: EdgeInsets.only(left: 4),
                                      child: Icon(Icons.block, color: AppTheme.errorColor, size: 16),
                                    ),
                                  if (canEdit)
                                    PopupMenuButton<String>(
                                      onSelected: (value) {
                                        if (value == 'edit') {
                                          _navigateToForm(supplier: supplier);
                                        } else if (value == 'delete') {
                                          _deleteSupplier(supplier);
                                        }
                                      },
                                      itemBuilder: (ctx) => [
                                        const PopupMenuItem(value: 'edit', child: Text('Edit')),
                                        const PopupMenuItem(value: 'delete', child: Text('Delete')),
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
            Text(
              value.toString(),
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color),
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

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 8,
        itemBuilder: (ctx, index) => Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: const ListTile(
            leading: CircleAvatar(),
            title: SizedBox(height: 16, width: double.infinity),
            subtitle: SizedBox(height: 24, width: double.infinity),
          ),
        ),
      ),
    );
  }
}
