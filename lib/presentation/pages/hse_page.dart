import 'package:flutter/material.dart';
import '../../domain/entities/app_user.dart';
import 'package:kinetic_solutions/core/auth/auth_service.dart';
import 'package:kinetic_solutions/core/theme/app_theme.dart';
import 'package:kinetic_solutions/data/datasources/local_database.dart';
import 'package:kinetic_solutions/domain/entities/employee.dart';
import 'package:kinetic_solutions/domain/entities/ppe_issue.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/app_user.dart';
class HSEPage extends StatefulWidget {
  final AppUser currentUser;

  const HSEPage({super.key, required this.currentUser});

  @override
  State<HSEPage> createState() => _HSEPageState();
}

class _HSEPageState extends State<HSEPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _incidents = [];
  List<Map<String, dynamic>> _toolboxTalks = [];
  List<Map<String, dynamic>> _riskAssessments = [];
  List<PPEIssue> _ppeIssues = [];
  List<Employee> _employees = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final emps = LocalDatabase.getEmployees();
    final ppe = LocalDatabase.getPPEIssues();
    setState(() {
      _employees = emps;
      _ppeIssues = ppe;
      // Sample data (in real app, these would come from their own boxes)
      _incidents = [
        {'date': DateTime.now().subtract(const Duration(days: 2)), 'type': 'Near Miss', 'severity': 'Low', 'description': 'Trip hazard identified', 'status': 'Closed'},
        {'date': DateTime.now().subtract(const Duration(days: 15)), 'type': 'Injury', 'severity': 'High', 'description': 'Lifting injury', 'status': 'Open'},
      ];
      _toolboxTalks = [
        {'date': DateTime.now().subtract(const Duration(days: 5)), 'topic': 'Safe Lifting', 'presenter': 'John Mwansa', 'attendees': 12},
        {'date': DateTime.now().subtract(const Duration(days: 12)), 'topic': 'Fire Safety', 'presenter': 'Grace Mulenga', 'attendees': 8},
      ];
      _riskAssessments = [
        {'activity': 'Working at Height', 'risk': 'High', 'control': 'Harness & lanyard', 'status': 'Approved'},
        {'activity': 'Electrical Work', 'risk': 'Critical', 'control': 'Lock-out/tag-out', 'status': 'Review'},
      ];
      _isLoading = false;
    });
  }

  int get ltiFreeDays => 47; // simulated

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      appBar: AppBar(
        title: const Text('Health & Safety'),
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Incidents'),
            Tab(text: 'Toolbox Talks'),
            Tab(text: 'Risk Assessment'),
            Tab(text: 'PPE'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildIncidentsTab(),
          _buildToolboxTab(),
          _buildRiskTab(),
          _buildPPETab(),
        ],
      ),
    );
  }

  Widget _buildIncidentsTab() {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    _buildKPI('LTI Free Days', ltiFreeDays, Colors.green),
                    const SizedBox(width: 12),
                    _buildKPI('Incidents', _incidents.length, Colors.red),
                    const SizedBox(width: 12),
                    _buildKPI('Open', _incidents.where((i) => i['status'] == 'Open').length, Colors.orange),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _incidents.length,
                  itemBuilder: (ctx, i) {
                    final inc = _incidents[i];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: inc['severity'] == 'Critical' ? AppTheme.errorColor : inc['severity'] == 'High' ? Colors.orange : Colors.green,
                          child: const Icon(Icons.warning, color: Colors.white),
                        ),
                        title: Text('${inc['type']} - ${DateFormat('dd MMM yyyy').format(inc['date'])}'),
                        subtitle: Text(inc['description']),
                        trailing: Chip(
                          label: Text(inc['status']),
                          backgroundColor: inc['status'] == 'Open' ? Colors.red.shade100 : Colors.green.shade100,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
  }

  Widget _buildToolboxTab() {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    _buildKPI('Total Talks', _toolboxTalks.length, Colors.blue),
                    const SizedBox(width: 12),
                    _buildKPI('Attendees', _toolboxTalks.fold(0, (sum, t) => sum + (t['attendees'] as int)), Colors.purple),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _toolboxTalks.length,
                  itemBuilder: (ctx, i) {
                    final t = _toolboxTalks[i];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: const Icon(Icons.group, color: Colors.blue),
                        title: Text(t['topic']),
                        subtitle: Text('Presented by ${t['presenter']} • ${t['attendees']} attendees'),
                        trailing: Text(DateFormat('dd MMM yyyy').format(t['date'])),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
  }

  Widget _buildRiskTab() {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _riskAssessments.length,
            itemBuilder: (ctx, i) {
              final r = _riskAssessments[i];
              final color = r['risk'] == 'Critical' ? AppTheme.errorColor : r['risk'] == 'High' ? Colors.orange : Colors.green;
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(backgroundColor: color.withOpacity(0.2), child: Icon(Icons.assessment, color: color)),
                  title: Text(r['activity']),
                  subtitle: Text('Control: ${r['control']}'),
                  trailing: Chip(
                    label: Text(r['status']),
                    backgroundColor: r['status'] == 'Approved' ? Colors.green.shade100 : Colors.orange.shade100,
                  ),
                ),
              );
            },
          );
  }

  Widget _buildPPETab() {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    _buildKPI('Total Issued', _ppeIssues.length, Colors.teal),
                    const SizedBox(width: 12),
                    _buildKPI('Active', _ppeIssues.where((p) => p.returnDate == null).length, Colors.green),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _ppeIssues.length,
                  itemBuilder: (ctx, i) {
                    final p = _ppeIssues[i];
                    // Use try-catch to find employee
                    String employeeName;
                    try {
                      employeeName = _employees.firstWhere((e) => e.id == p.employeeId).fullName;
                    } catch (_) {
                      employeeName = 'Unknown';
                    }
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: p.returnDate == null ? Colors.green.shade100 : Colors.grey.shade200,
                          child: Icon(Icons.security, color: p.returnDate == null ? Colors.green : Colors.grey),
                        ),
                        title: Text('${p.ppeType} x${p.quantity}'),
                        subtitle: Text('$employeeName • Issued: ${DateFormat('dd MMM yyyy').format(p.issueDate)}'),
                        trailing: p.returnDate != null
                            ? Chip(
                                label: const Text('Returned'),
                                backgroundColor: Colors.grey.shade200,
                              )
                            : Chip(
                                label: const Text('Active'),
                                backgroundColor: Colors.green.withOpacity(0.2), // Fixed: removed const and used withOpacity
                              ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
  }

  Widget _buildKPI(String label, dynamic value, Color color) {
    String display = value is double ? value.toStringAsFixed(1) : value.toString();
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