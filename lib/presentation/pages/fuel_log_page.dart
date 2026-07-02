// lib/presentation/pages/fuel_log_page.dart
import 'package:flutter/material.dart';
import 'package:kinetic_solutions/core/auth/auth_service.dart';
import 'package:kinetic_solutions/core/theme/app_theme.dart';
import 'package:kinetic_solutions/data/datasources/local_database.dart';
import 'package:kinetic_solutions/domain/entities/fuel_log.dart';
import 'package:kinetic_solutions/domain/entities/vehicle.dart';
import 'package:kinetic_solutions/presentation/pages/fuel_log_form_page.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/app_user.dart';

class FuelLogPage extends StatefulWidget {
  final AppUser currentUser;

  const FuelLogPage({super.key, required this.currentUser});

  @override
  State<FuelLogPage> createState() => _FuelLogPageState();
}

class _FuelLogPageState extends State<FuelLogPage> {
  List<FuelLog> _logs = [];
  List<Vehicle> _vehicles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final logs = LocalDatabase.getFuelLogs();
    final vehicles = LocalDatabase.getVehicles();
    setState(() {
      _logs = logs..sort((a, b) => b.date.compareTo(a.date));
      _vehicles = vehicles;
      _isLoading = false;
    });
  }

  String _getVehicleReg(String id) {
    final v = _vehicles.firstWhere((v) => v.id == id, orElse: () => throw Exception("Not found"));
    return v?.registrationNumber ?? 'Unknown';
  }

  Future<void> _navigateToForm({FuelLog? log}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => FuelLogFormPage(currentUser: widget.currentUser, log: log)),
    );
    await _loadData();
  }

  Future<void> _deleteLog(FuelLog log) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Fuel Log'),
        content: Text('Delete fuel log for ${_getVehicleReg(log.vehicleId)}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete', style: TextStyle(color: AppTheme.errorColor))),
        ],
      ),
    );
    if (confirmed == true) {
      await LocalDatabase.deleteFuelLog(log.id);
      await _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final canEdit = widget.currentUser.role.canEditInventory;
    final total = _logs.length;
    final totalLitres = _logs.fold(0.0, (sum, l) => sum + l.litres);
    final totalCost = _logs.fold(0.0, (sum, l) => sum + l.cost);

    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      appBar: AppBar(
        title: const Text('Fuel Logs'),
        backgroundColor: Colors.amber.shade700,
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
                _buildStat('Total Records', total, Colors.amber.shade700),
                const SizedBox(width: 12),
                _buildStat('Total Litres', totalLitres, Colors.blue),
                const SizedBox(width: 12),
                _buildStat('Total Cost', totalCost, Colors.green, isMoney: true),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _logs.isEmpty
                    ? const Center(child: Text('No fuel logs'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _logs.length,
                        itemBuilder: (ctx, i) {
                          final l = _logs[i];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.amber.shade100,
                                child: const Icon(Icons.local_gas_station, color: Colors.amber),
                              ),
                              title: Text(_getVehicleReg(l.vehicleId)),
                              subtitle: Text(
                                '${l.litres}L • ${DateFormat('dd MMM yyyy').format(l.date)} • ${l.mileage}km',
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'K ${NumberFormat('#,##0.00').format(l.cost)}',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                  ),
                                  const SizedBox(width: 8),
                                  if (canEdit)
                                    PopupMenuButton(
                                      onSelected: (value) {
                                        if (value == 'edit') _navigateToForm(log: l);
                                        else if (value == 'delete') _deleteLog(l);
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

  Widget _buildStat(String label, dynamic value, Color color, {bool isMoney = false}) {
    String display = isMoney ? 'K ${NumberFormat('#,##0.00').format(value)}' : value is double ? value.toStringAsFixed(1) : value.toString();
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
            Text(display, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color)),
            Text(label, style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
          ],
        ),
      ),
    );
  }
}
