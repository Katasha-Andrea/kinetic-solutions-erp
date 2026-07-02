import 'package:flutter/material.dart';
import 'package:kinetic_solutions/core/auth/auth_service.dart';
import 'package:kinetic_solutions/core/theme/app_theme.dart';
import 'package:kinetic_solutions/data/datasources/local_database.dart';
import 'package:kinetic_solutions/domain/entities/work_order.dart';
import 'package:kinetic_solutions/domain/entities/project.dart';
import 'package:kinetic_solutions/domain/entities/vehicle.dart';
import 'package:kinetic_solutions/presentation/pages/work_order_form_page.dart';
import 'package:kinetic_solutions/presentation/widgets/shared_widgets.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/app_user.dart';

class WorkOrderListPage extends StatefulWidget {
  final AppUser currentUser;

  const WorkOrderListPage({super.key, required this.currentUser});

  @override
  State<WorkOrderListPage> createState() => _WorkOrderListPageState();
}

class _WorkOrderListPageState extends State<WorkOrderListPage> {
  List<WorkOrder> _allOrders = [];
  List<WorkOrder> _filteredOrders = [];
  List<Project> _projects = [];
  List<Vehicle> _vehicles = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedStatus = 'All';
  String _selectedPriority = 'All';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final orders = LocalDatabase.getWorkOrders();
    final projects = LocalDatabase.getProjects();
    final vehicles = LocalDatabase.getVehicles();
    setState(() {
      _allOrders = orders;
      _filteredOrders = orders;
      _projects = projects;
      _vehicles = vehicles;
      _isLoading = false;
    });
  }

  void _applyFilters() {
    setState(() {
      _filteredOrders = _allOrders.where((o) {
        final matchesSearch = _searchQuery.isEmpty ||
            o.woNumber.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            o.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            o.location.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            o.supervisorName.toLowerCase().contains(_searchQuery.toLowerCase());
        final matchesStatus = _selectedStatus == 'All' || o.status.name == _selectedStatus;
        final matchesPriority = _selectedPriority == 'All' || o.priority.name == _selectedPriority;
        return matchesSearch && matchesStatus && matchesPriority;
      }).toList();
    });
  }

  List<String> get _statusOptions => ['All', ...WOStatus.values.map((e) => e.name)];
  List<String> get _priorityOptions => ['All', ...WOPriority.values.map((e) => e.name)];

  Color _getStatusColor(WOStatus status) {
    switch (status) {
      case WOStatus.pending:
        return AppTheme.warningColor;
      case WOStatus.assigned:
        return AppTheme.infoColor;
      case WOStatus.inProgress:
        return AppTheme.primary500;
      case WOStatus.completed:
        return AppTheme.primary500;
      case WOStatus.onHold:
        return AppTheme.warningColor;
      case WOStatus.cancelled:
        return AppTheme.errorColor;
    }
  }

  Color _getPriorityColor(WOPriority priority) {
    switch (priority) {
      case WOPriority.critical:
        return AppTheme.errorColor;
      case WOPriority.high:
        return AppTheme.warningColor;
      case WOPriority.medium:
        return AppTheme.infoColor;
      case WOPriority.low:
        return AppTheme.textMuted;
    }
  }

  String _getProjectName(String? projectId) {
    if (projectId == null) return 'N/A';
    final p = _projects.firstWhere((p) => p.id == projectId, orElse: () => throw Exception("Not found"));
    return p?.name ?? 'Unknown';
  }

  String _getVehicleReg(String? vehicleId) {
    if (vehicleId == null) return 'None';
    final v = _vehicles.firstWhere((v) => v.id == vehicleId, orElse: () => throw Exception("Not found"));
    return v?.registrationNumber ?? 'Unknown';
  }

  Future<void> _navigateToForm({WorkOrder? order}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WorkOrderFormPage(
          currentUser: widget.currentUser,
          workOrder: order,
        ),
      ),
    );
    await _loadData();
  }

  Future<void> _deleteOrder(WorkOrder order) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Work Order'),
        content: Text('Delete "${order.woNumber}"?'),
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
      await LocalDatabase.deleteWorkOrder(order.id);
      await _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final canEdit = widget.currentUser.role.canEditProjects;
    final total = _allOrders.length;
    final inProgress = _allOrders.where((o) => o.status == WOStatus.inProgress).length;
    final completed = _allOrders.where((o) => o.status == WOStatus.completed).length;
    final pending = _allOrders.where((o) => o.status == WOStatus.pending).length;

    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      appBar: AppBar(
        title: const Text('Work Orders'),
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
                _buildStatCard('In Progress', inProgress, AppTheme.infoColor),
                const SizedBox(width: 12),
                _buildStatCard('Completed', completed, AppTheme.primary500),
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
                      hintText: 'Search by WO #, title, location...',
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
                  value: _selectedPriority,
                  items: _priorityOptions.map((pri) {
                    return DropdownMenuItem<String>(
                      value: pri,
                      child: Text(pri),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedPriority = value!;
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
                        icon: Icons.assignment,
                        title: 'No work orders found',
                        subtitle: 'Create your first work order',
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredOrders.length,
                        itemBuilder: (ctx, index) {
                          final o = _filteredOrders[index];
                          final progress = o.completionPercent;
                          final isOverdue = o.status != WOStatus.completed &&
                              o.startDate.isBefore(DateTime.now().subtract(const Duration(days: 7)));

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: _getStatusColor(o.status).withOpacity(0.15),
                                child: Icon(
                                  Icons.assignment,
                                  color: _getStatusColor(o.status),
                                ),
                              ),
                              title: Text(
                                '${o.woNumber} - ${o.title}',
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Project: ${_getProjectName(o.projectId)}'),
                                  Text('Location: ${o.location} • Supervisor: ${o.supervisorName}'),
                                  if (o.vehicleId != null)
                                    Text('Vehicle: ${_getVehicleReg(o.vehicleId)}'),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      _buildStatusChip(o.status),
                                      const SizedBox(width: 8),
                                      _buildPriorityChip(o.priority),
                                      if (isOverdue)
                                        const Padding(
                                          padding: EdgeInsets.only(left: 4),
                                          child: Icon(Icons.warning, color: AppTheme.errorColor, size: 14),
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
                                            const Text('Progress', style: TextStyle(fontSize: 10)),
                                            ClipRRect(
                                              borderRadius: BorderRadius.circular(4),
                                              child: LinearProgressIndicator(
                                                value: progress / 100,
                                                backgroundColor: AppTheme.borderColor,
                                                color: progress >= 100
                                                    ? AppTheme.primary500
                                                    : progress > 50
                                                        ? AppTheme.infoColor
                                                        : AppTheme.warningColor,
                                                minHeight: 6,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '$progress%',
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
                                    '${o.actualHours}/${o.estimatedHours}h',
                                    style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                                  ),
                                  const SizedBox(width: 8),
                                  if (canEdit)
                                    PopupMenuButton<String>(
                                      onSelected: (value) {
                                        if (value == 'edit') {
                                          _navigateToForm(order: o);
                                        } else if (value == 'delete') {
                                          _deleteOrder(o);
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

  Widget _buildStatusChip(WOStatus status) {
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

  Widget _buildPriorityChip(WOPriority priority) {
    return Chip(
      label: Text(priority.name),
      backgroundColor: _getPriorityColor(priority).withOpacity(0.15),
      labelStyle: TextStyle(
        color: _getPriorityColor(priority),
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
            subtitle: SizedBox(height: 56, width: double.infinity),
          ),
        ),
      ),
    );
  }
}
