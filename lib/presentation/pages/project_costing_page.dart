import 'package:flutter/material.dart';
import 'package:kinetic_solutions/core/auth/auth_service.dart';
import 'package:kinetic_solutions/core/theme/app_theme.dart';
import 'package:kinetic_solutions/data/datasources/local_database.dart';
import 'package:kinetic_solutions/domain/entities/project.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/app_user.dart';

class ProjectCostingPage extends StatefulWidget {
  final AppUser currentUser;

  const ProjectCostingPage({super.key, required this.currentUser});

  @override
  State<ProjectCostingPage> createState() => _ProjectCostingPageState();
}

class _ProjectCostingPageState extends State<ProjectCostingPage> {
  List<Project> _projects = [];
  Project? _selectedProject;
  bool _isLoading = true;

  // Mock cost breakdown data (in reality, these would come from expenses/POs)
  final Map<String, double> _budget = {
    'Labour': 120000,
    'Materials': 85000,
    'Fuel': 25000,
    'Accommodation': 18000,
    'Transport': 15000,
    'Equipment': 42000,
    'Subcontractors': 65000,
    'Other': 12000,
  };

  final Map<String, double> _actual = {
    'Labour': 115000,
    'Materials': 82000,
    'Fuel': 27000,
    'Accommodation': 16000,
    'Transport': 14000,
    'Equipment': 45000,
    'Subcontractors': 60000,
    'Other': 10000,
  };

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final projs = LocalDatabase.getProjects();
    setState(() {
      _projects = projs;
      if (_projects.isNotEmpty) _selectedProject = _projects.first;
      _isLoading = false;
    });
  }

  double get totalBudget => _budget.values.fold(0.0, (sum, v) => sum + v);
  double get totalActual => _actual.values.fold(0.0, (sum, v) => sum + v);
  double get variance => totalBudget - totalActual;
  double get variancePercent => totalBudget > 0 ? (variance / totalBudget * 100) : 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      appBar: AppBar(
        title: const Text('Project Costing'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _projects.isEmpty
              ? const Center(child: Text('No projects available'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      DropdownButtonFormField<Project>(
                        value: _selectedProject,
                        decoration: const InputDecoration(
                          labelText: 'Select Project',
                          border: OutlineInputBorder(),
                        ),
                        items: _projects.map((p) {
                          return DropdownMenuItem(value: p, child: Text(p.name));
                        }).toList(),
                        onChanged: (val) => setState(() => _selectedProject = val),
                      ),
                      const SizedBox(height: 16),
                      // Summary cards
                      Row(
                        children: [
                          _buildSummaryCard('Budget', totalBudget, Colors.blue),
                          const SizedBox(width: 12),
                          _buildSummaryCard('Actual', totalActual, Colors.orange),
                          const SizedBox(width: 12),
                          _buildSummaryCard(
                            'Variance',
                            variance,
                            variance >= 0 ? Colors.green : Colors.red,
                            isMoney: true,
                            suffix: variance >= 0 ? ' under' : ' over',
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Variance percentage indicator
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: AppTheme.softShadow,
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Variance: ${variancePercent.toStringAsFixed(1)}%',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: variance >= 0 ? Colors.green : Colors.red,
                              ),
                            ),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: variancePercent.abs() / 100,
                                backgroundColor: Colors.grey.shade200,
                                color: variance >= 0 ? Colors.green : Colors.red,
                                minHeight: 8,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Cost breakdown
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: AppTheme.softShadow,
                        ),
                        child: Column(
                          children: [
                            const Padding(
                              padding: EdgeInsets.all(16),
                              child: Text('Cost Breakdown', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            ),
                            const Divider(),
                            ..._budget.keys.map((category) {
                              final budget = _budget[category] ?? 0;
                              final actual = _actual[category] ?? 0;
                              final diff = budget - actual;
                              final color = diff >= 0 ? Colors.green : Colors.red;
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          flex: 3,
                                          child: Text(category, style: const TextStyle(fontWeight: FontWeight.w500)),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Text('K ${NumberFormat('#,##0').format(budget)}', textAlign: TextAlign.right),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Text('K ${NumberFormat('#,##0').format(actual)}', textAlign: TextAlign.right),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: Text(
                                            diff >= 0 ? 'K ${NumberFormat('#,##0').format(diff)}' : '-K ${NumberFormat('#,##0').format(diff.abs())}',
                                            textAlign: TextAlign.right,
                                            style: TextStyle(color: color, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Divider(height: 4),
                                  ],
                                ),
                              );
                            }).toList(),
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  const Text('Total', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  const Spacer(),
                                  Text('K ${NumberFormat('#,##0').format(totalBudget)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                  const SizedBox(width: 16),
                                  Text('K ${NumberFormat('#,##0').format(totalActual)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                  const SizedBox(width: 16),
                                  Text(
                                    variance >= 0 ? 'K ${NumberFormat('#,##0').format(variance)}' : '-K ${NumberFormat('#,##0').format(variance.abs())}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: variance >= 0 ? Colors.green : Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Pie chart visualization
                      Container(
                        height: 250,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: AppTheme.softShadow,
                        ),
                        child: PieChart(
                          PieChartData(
                            sections: _budget.entries.map((entry) {
                              return PieChartSectionData(
                                value: entry.value,
                                title: entry.key,
                                color: _getColor(entry.key),
                                radius: 60,
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildSummaryCard(String label, double value, Color color, {bool isMoney = true, String suffix = ''}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: AppTheme.softShadow,
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
            const SizedBox(height: 4),
            Text(
              isMoney ? 'K ${NumberFormat('#,##0').format(value)}$suffix' : value.toString(),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
      ),
    );
  }

  Color _getColor(String category) {
    final colors = [
      Colors.blue,
      Colors.orange,
      Colors.green,
      Colors.red,
      Colors.purple,
      Colors.teal,
      Colors.indigo,
      Colors.pink,
    ];
    final index = category.hashCode % colors.length;
    return colors[index];
  }
}
