import 'package:flutter/material.dart';
import 'package:kinetic_solutions/core/auth/auth_service.dart';
import 'package:kinetic_solutions/core/theme/app_theme.dart';
import 'package:kinetic_solutions/data/datasources/local_database.dart';
import 'package:kinetic_solutions/domain/entities/vehicle.dart';
import 'package:kinetic_solutions/presentation/pages/fleet_form_page.dart';
import 'package:kinetic_solutions/presentation/widgets/shared_widgets.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/app_user.dart';

class FleetListPage extends StatefulWidget {
  final AppUser currentUser;

  const FleetListPage({super.key, required this.currentUser});

  @override
  State<FleetListPage> createState() => _FleetListPageState();
}

class _FleetListPageState extends State<FleetListPage> {
  List<Vehicle> _allVehicles = [];
  List<Vehicle> _filteredVehicles = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedStatus = 'All';

  @override
  void initState() {
    super.initState();
    _loadVehicles();
  }

  Future<void> _loadVehicles() async {
    setState(() => _isLoading = true);
    final vehicles = LocalDatabase.getVehicles();
    setState(() {
      _allVehicles = vehicles;
      _filteredVehicles = vehicles;
      _isLoading = false;
    });
  }

  void _applyFilters() {
    setState(() {
      _filteredVehicles = _allVehicles.where((v) {
        final matchesSearch = _searchQuery.isEmpty ||
            v.registrationNumber.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            v.make.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            v.model.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            (v.driverName?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
        final matchesStatus = _selectedStatus == 'All' ||
            v.status.name == _selectedStatus;
        return matchesSearch && matchesStatus;
      }).toList();
    });
  }

  List<String> get _statusOptions => ['All', ...VehicleStatus.values.map((e) => e.name)];

  Color _getStatusColor(VehicleStatus status) {
    switch (status) {
      case VehicleStatus.available:
        return AppTheme.primary500;
      case VehicleStatus.onSite:
        return AppTheme.infoColor;
      case VehicleStatus.underRepair:
        return AppTheme.warningColor;
      case VehicleStatus.sold:
        return AppTheme.errorColor;
    }
  }

  IconData _getStatusIcon(VehicleStatus status) {
    switch (status) {
      case VehicleStatus.available:
        return Icons.check_circle;
      case VehicleStatus.onSite:
        return Icons.location_on;
      case VehicleStatus.underRepair:
        return Icons.build;
      case VehicleStatus.sold:
        return Icons.sell;
    }
  }

  Future<void> _navigateToForm({Vehicle? vehicle}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FleetFormPage(
          currentUser: widget.currentUser,
          vehicle: vehicle,
        ),
      ),
    );
    await _loadVehicles();
  }

  Future<void> _deleteVehicle(Vehicle vehicle) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Vehicle'),
        content: Text('Delete ${vehicle.registrationNumber} (${vehicle.make} ${vehicle.model})?'),
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
      await LocalDatabase.deleteVehicle(vehicle.id);
      await _loadVehicles();
    }
  }

  @override
  Widget build(BuildContext context) {
    final canEdit = widget.currentUser.role.canEditInventory; // or a dedicated fleet permission

    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      appBar: AppBar(
        title: const Text('Fleet Management'),
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
                _buildStatCard('Total', _allVehicles.length, AppTheme.primary500),
                const SizedBox(width: 12),
                _buildStatCard('Available', _allVehicles.where((v) => v.status == VehicleStatus.available).length, AppTheme.primary500),
                const SizedBox(width: 12),
                _buildStatCard('On Site', _allVehicles.where((v) => v.status == VehicleStatus.onSite).length, AppTheme.infoColor),
                const SizedBox(width: 12),
                _buildStatCard('In Repair', _allVehicles.where((v) => v.status == VehicleStatus.underRepair).length, AppTheme.warningColor),
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
                      hintText: 'Search by reg, make, model, driver...',
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
                : _filteredVehicles.isEmpty
                    ? const EmptyState(
                        icon: Icons.directions_car,
                        title: 'No vehicles found',
                        subtitle: 'Add your first vehicle',
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredVehicles.length,
                        itemBuilder: (ctx, index) {
                          final v = _filteredVehicles[index];
                          final isExpired = v.isInsuranceExpired || v.isFitnessExpired || v.isRoadTaxExpired;
                          final hasLowFuel = v.fuelPercentage < 20;
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: _getStatusColor(v.status).withOpacity(0.15),
                                child: Icon(
                                  Icons.directions_car,
                                  color: _getStatusColor(v.status),
                                ),
                              ),
                              title: Text(
                                '${v.make} ${v.model}',
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${v.registrationNumber} • ${v.year} • ${v.type}'),
                                  if (v.driverName != null)
                                    Text('Driver: ${v.driverName}'),
                                  Row(
                                    children: [
                                      _buildStatusChip(v.status),
                                      if (isExpired)
                                        const Padding(
                                          padding: EdgeInsets.only(left: 4),
                                          child: Icon(Icons.warning, color: AppTheme.errorColor, size: 14),
                                        ),
                                      if (hasLowFuel)
                                        const Padding(
                                          padding: EdgeInsets.only(left: 4),
                                          child: Icon(Icons.local_gas_station, color: AppTheme.warningColor, size: 14),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('${v.fuelPercentage.toStringAsFixed(0)}%'),
                                  const SizedBox(width: 8),
                                  if (canEdit)
                                    PopupMenuButton<String>(
                                      onSelected: (value) {
                                        if (value == 'edit') {
                                          _navigateToForm(vehicle: v);
                                        } else if (value == 'delete') {
                                          _deleteVehicle(v);
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

  Widget _buildStatusChip(VehicleStatus status) {
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
            subtitle: SizedBox(height: 32, width: double.infinity),
          ),
        ),
      ),
    );
  }
}
