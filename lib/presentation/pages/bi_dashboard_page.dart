import 'package:flutter/material.dart';
import 'package:kinetic_solutions/core/auth/auth_service.dart';
import 'package:kinetic_solutions/core/theme/app_theme.dart';
import 'package:kinetic_solutions/data/datasources/local_database.dart';
import 'package:kinetic_solutions/domain/entities/project.dart';
import 'package:kinetic_solutions/domain/entities/contract.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/app_user.dart';

class BIDashboardPage extends StatefulWidget {
  final AppUser currentUser;

  const BIDashboardPage({super.key, required this.currentUser});

  @override
  State<BIDashboardPage> createState() => _BIDashboardPageState();
}

class _BIDashboardPageState extends State<BIDashboardPage> {
  List<Project> _projects = [];
  List<Contract> _contracts = [];
  bool _isLoading = true;

  // Mock revenue/expense data (6 months)
  final List<Map<String, double>> _monthlyData = [
    {'revenue': 450000, 'expenses': 320000},
    {'revenue': 520000, 'expenses': 380000},
    {'revenue': 480000, 'expenses': 350000},
    {'revenue': 610000, 'expenses': 420000},
    {'revenue': 560000, 'expenses': 390000},
    {'revenue': 680000, 'expenses': 450000},
  ];

  final List<String> _months = ['Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final projs = LocalDatabase.getProjects();
    final contracts = LocalDatabase.getContracts();
    setState(() {
      _projects = projs;
      _contracts = contracts;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final totalRevenue = _monthlyData.fold(0.0, (sum, d) => sum + d['revenue']!);
    final totalExpenses = _monthlyData.fold(0.0, (sum, d) => sum + d['expenses']!);
    final profit = totalRevenue - totalExpenses;
    final profitMargin = totalRevenue > 0 ? (profit / totalRevenue * 100) : 0;

    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      appBar: AppBar(
        title: const Text('Business Intelligence'),
        backgroundColor: Colors.indigo.shade700,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // KPI cards
                  Row(
                    children: [
                      _buildKPI('Revenue YTD', totalRevenue, Colors.green, isMoney: true),
                      const SizedBox(width: 12),
                      _buildKPI('Profit Margin', profitMargin, Colors.blue, suffix: '%'),
                      const SizedBox(width: 12),
                      _buildKPI('Cash Flow', profit, profit >= 0 ? Colors.green : Colors.red, isMoney: true),
                      const SizedBox(width: 12),
                      _buildKPI('Outstanding', 142000, Colors.orange, isMoney: true),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Revenue vs Expenses chart
                  Container(
                    height: 250,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: AppTheme.softShadow,
                    ),
                    child: Column(
                      children: [
                        const Text('Revenue vs Expenses (6 months)',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Expanded(
                          child: BarChart(
                            BarChartData(
                              groupsSpace: 20,
                              barGroups: _monthlyData.asMap().entries.map((entry) {
                                final idx = entry.key;
                                final data = entry.value;
                                return BarChartGroupData(
                                  x: idx,
                                  barRods: [
                                    BarChartRodData(
                                      toY: data['revenue']! / 10000,
                                      color: Colors.green,
                                      width: 12,
                                    ),
                                    BarChartRodData(
                                      toY: data['expenses']! / 10000,
                                      color: Colors.red,
                                      width: 12,
                                    ),
                                  ],
                                );
                              }).toList(),
                              titlesData: FlTitlesData(
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, meta) {
                                      final idx = value.toInt();
                                      if (idx >= 0 && idx < _months.length) {
                                        return Text(_months[idx]);
                                      }
                                      return const Text('');
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Project portfolio
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: AppTheme.softShadow,
                    ),
                    child: Column(
                      children: [
                        const Text('Project Portfolio', style: TextStyle(fontWeight: FontWeight.bold)),
                        const Divider(),
                        ..._projects.take(5).map((p) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Text(p.name, style: const TextStyle(fontSize: 12)),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: p.budgetUtilization / 100,
                                      backgroundColor: Colors.grey.shade200,
                                      color: p.budgetUtilization > 90 ? Colors.red : Colors.green,
                                      minHeight: 6,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${p.budgetUtilization.toStringAsFixed(0)}%',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Contract utilization
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: AppTheme.softShadow,
                    ),
                    child: Column(
                      children: [
                        const Text('Contract Utilization', style: TextStyle(fontWeight: FontWeight.bold)),
                        const Divider(),
                        ..._contracts.take(5).map((c) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Text(c.title, style: const TextStyle(fontSize: 12)),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: c.utilization / 100,
                                      backgroundColor: Colors.grey.shade200,
                                      color: c.utilization > 90 ? Colors.red : Colors.green,
                                      minHeight: 6,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${c.utilization.toStringAsFixed(0)}%',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildKPI(String label, dynamic value, Color color, {bool isMoney = false, String suffix = ''}) {
    String display;
    if (isMoney) {
      display = 'K ${NumberFormat('#,##0').format(value)}';
    } else if (value is double) {
      display = value.toStringAsFixed(1) + suffix;
    } else {
      display = value.toString() + suffix;
    }
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(display, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: color)),
            Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
          ],
        ),
      ),
    );
  }
}
