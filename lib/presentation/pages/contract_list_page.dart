import 'package:flutter/material.dart';
import 'package:kinetic_solutions/core/auth/auth_service.dart';
import 'package:kinetic_solutions/core/theme/app_theme.dart';
import 'package:kinetic_solutions/data/datasources/local_database.dart';
import 'package:kinetic_solutions/domain/entities/contract.dart';
import 'package:kinetic_solutions/presentation/pages/contract_form_page.dart';
import 'package:kinetic_solutions/presentation/widgets/shared_widgets.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/app_user.dart';

class ContractListPage extends StatefulWidget {
  final AppUser currentUser;

  const ContractListPage({super.key, required this.currentUser});

  @override
  State<ContractListPage> createState() => _ContractListPageState();
}

class _ContractListPageState extends State<ContractListPage> {
  List<Contract> _allContracts = [];
  List<Contract> _filteredContracts = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedStatus = 'All';
  String _selectedType = 'All';

  @override
  void initState() {
    super.initState();
    _loadContracts();
  }

  Future<void> _loadContracts() async {
    setState(() => _isLoading = true);
    final contracts = LocalDatabase.getContracts();
    setState(() {
      _allContracts = contracts;
      _filteredContracts = contracts;
      _isLoading = false;
    });
  }

  void _applyFilters() {
    setState(() {
      _filteredContracts = _allContracts.where((c) {
        final matchesSearch = _searchQuery.isEmpty ||
            c.contractNumber.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            c.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            c.clientName.toLowerCase().contains(_searchQuery.toLowerCase());
        final matchesStatus = _selectedStatus == 'All' || c.status.name == _selectedStatus;
        final matchesType = _selectedType == 'All' || c.type.name == _selectedType;
        return matchesSearch && matchesStatus && matchesType;
      }).toList();
    });
  }

  List<String> get _statusOptions => ['All', ...ContractStatus.values.map((e) => e.name)];
  List<String> get _typeOptions => ['All', ...ContractType.values.map((e) => e.name)];

  Color _getStatusColor(ContractStatus status) {
    switch (status) {
      case ContractStatus.active:
        return AppTheme.primary500;
      case ContractStatus.expiring:
        return AppTheme.warningColor;
      case ContractStatus.expired:
        return AppTheme.errorColor;
      case ContractStatus.completed:
        return AppTheme.infoColor;
      case ContractStatus.terminated:
        return AppTheme.textMuted;
    }
  }

  Future<void> _navigateToForm({Contract? contract}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ContractFormPage(
          currentUser: widget.currentUser,
          contract: contract,
        ),
      ),
    );
    await _loadContracts();
  }

  Future<void> _deleteContract(Contract contract) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Contract'),
        content: Text('Delete ${contract.contractNumber}?'),
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
      await LocalDatabase.deleteContract(contract.id);
      await _loadContracts();
    }
  }

  @override
  Widget build(BuildContext context) {
    final canEdit = widget.currentUser.role.canEditProjects; // reuse project permission
    final totalValue = _allContracts.fold(0.0, (sum, c) => sum + c.maximumValue);
    final usedValue = _allContracts.fold(0.0, (sum, c) => sum + c.usedValue);
    final activeCount = _allContracts.where((c) => c.status == ContractStatus.active).length;

    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      appBar: AppBar(
        title: const Text('Contracts'),
        backgroundColor: AppTheme.primaryColor,
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
                _buildStatCard('Total', _allContracts.length, AppTheme.primary500),
                const SizedBox(width: 12),
                _buildStatCard('Active', activeCount, AppTheme.primary500),
                const SizedBox(width: 12),
                _buildStatCard('Total Value', totalValue, AppTheme.infoColor, isMoney: true),
                const SizedBox(width: 12),
                _buildStatCard('Used', (totalValue > 0) ? (usedValue / totalValue * 100).round() : 0,
                    AppTheme.warningColor, suffix: '%'),
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
                      hintText: 'Search contracts...',
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
                  value: _selectedType,
                  items: _typeOptions.map((type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedType = value!;
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
                : _filteredContracts.isEmpty
                    ? const EmptyState(
                        icon: Icons.description,
                        title: 'No contracts found',
                        subtitle: 'Add your first contract',
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredContracts.length,
                        itemBuilder: (ctx, index) {
                          final c = _filteredContracts[index];
                          final isExpiring = c.status == ContractStatus.expiring;
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: _getStatusColor(c.status).withOpacity(0.15),
                                child: Icon(
                                  Icons.description,
                                  color: _getStatusColor(c.status),
                                ),
                              ),
                              title: Text(
                                c.title,
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${c.contractNumber} • ${c.clientName}'),
                                  Text('${DateFormat('dd MMM yyyy').format(c.startDate)} → ${DateFormat('dd MMM yyyy').format(c.endDate)}'),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      _buildStatusChip(c.status),
                                      const SizedBox(width: 8),
                                      _buildTypeChip(c.type),
                                      if (isExpiring)
                                        const Padding(
                                          padding: EdgeInsets.only(left: 4),
                                          child: Icon(Icons.warning, color: AppTheme.warningColor, size: 14),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text('Utilization', style: TextStyle(fontSize: 10)),
                                            ClipRRect(
                                              borderRadius: BorderRadius.circular(4),
                                              child: LinearProgressIndicator(
                                                value: c.utilization / 100,
                                                backgroundColor: AppTheme.borderColor,
                                                color: c.utilization > 90 ? AppTheme.errorColor
                                                    : c.utilization > 75 ? AppTheme.warningColor
                                                    : AppTheme.primary500,
                                                minHeight: 6,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '${c.utilization.toStringAsFixed(0)}%',
                                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'K ${NumberFormat('#,##0.00').format(c.remaining)}',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                  ),
                                  const SizedBox(width: 8),
                                  if (canEdit)
                                    PopupMenuButton<String>(
                                      onSelected: (value) {
                                        if (value == 'edit') {
                                          _navigateToForm(contract: c);
                                        } else if (value == 'delete') {
                                          _deleteContract(c);
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

  Widget _buildStatCard(String label, dynamic value, Color color, {bool isMoney = false, String suffix = ''}) {
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
              '$display$suffix',
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

  Widget _buildStatusChip(ContractStatus status) {
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

  Widget _buildTypeChip(ContractType type) {
    return Chip(
      label: Text(type.name),
      backgroundColor: AppTheme.purpleLight,
      labelStyle: const TextStyle(
        color: AppTheme.purpleColor,
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
