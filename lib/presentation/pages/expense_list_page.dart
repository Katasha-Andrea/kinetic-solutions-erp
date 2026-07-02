import 'package:flutter/material.dart';
import 'package:kinetic_solutions/core/auth/auth_service.dart';
import 'package:kinetic_solutions/core/theme/app_theme.dart';
import 'package:kinetic_solutions/data/datasources/local_database.dart';
import 'package:kinetic_solutions/domain/entities/expense.dart';
import 'package:kinetic_solutions/domain/entities/project.dart';
import 'package:kinetic_solutions/presentation/pages/expense_form_page.dart';
import 'package:kinetic_solutions/presentation/widgets/shared_widgets.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/app_user.dart';

class ExpenseListPage extends StatefulWidget {
  final AppUser currentUser;

  const ExpenseListPage({super.key, required this.currentUser});

  @override
  State<ExpenseListPage> createState() => _ExpenseListPageState();
}

class _ExpenseListPageState extends State<ExpenseListPage> {
  List<Expense> _allExpenses = [];
  List<Expense> _filteredExpenses = [];
  List<Project> _projects = [];
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
    final expenses = LocalDatabase.getExpenses();
    final projects = LocalDatabase.getProjects();
    setState(() {
      _allExpenses = expenses;
      _filteredExpenses = expenses;
      _projects = projects;
      _isLoading = false;
    });
  }

  void _applyFilters() {
    setState(() {
      _filteredExpenses = _allExpenses.where((e) {
        final matchesSearch = _searchQuery.isEmpty ||
            e.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            e.category.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            (e.projectId != null &&
                _projects.any((p) => p.id == e.projectId && p.name.toLowerCase().contains(_searchQuery.toLowerCase())));
        final matchesStatus = _selectedStatus == 'All' || e.status.name == _selectedStatus;
        final matchesCategory = _selectedCategory == 'All' || e.category == _selectedCategory;
        return matchesSearch && matchesStatus && matchesCategory;
      }).toList();
    });
  }

  List<String> get _statusOptions => ['All', ...ExpenseStatus.values.map((e) => e.name)];
  List<String> get _categoryOptions {
    final set = <String>{};
    for (final e in _allExpenses) {
      set.add(e.category);
    }
    return ['All', ...set.toList()..sort()];
  }

  Color _getStatusColor(ExpenseStatus status) {
    switch (status) {
      case ExpenseStatus.paid:
        return AppTheme.primary500;
      case ExpenseStatus.approved:
        return AppTheme.infoColor;
      case ExpenseStatus.pending:
        return AppTheme.warningColor;
    }
  }

  IconData _getStatusIcon(ExpenseStatus status) {
    switch (status) {
      case ExpenseStatus.paid:
        return Icons.check_circle;
      case ExpenseStatus.approved:
        return Icons.verified;
      case ExpenseStatus.pending:
        return Icons.hourglass_empty;
    }
  }

  String _getProjectName(String? projectId) {
    if (projectId == null) return 'N/A';
    final project = _projects.firstWhere((p) => p.id == projectId, orElse: () => throw Exception("Not found"));
    return project?.name ?? 'Unknown';
  }

  Future<void> _navigateToForm({Expense? expense}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ExpenseFormPage(
          currentUser: widget.currentUser,
          expense: expense,
        ),
      ),
    );
    await _loadData();
  }

  Future<void> _deleteExpense(Expense expense) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Expense'),
        content: Text('Delete expense "${expense.description}"?'),
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
      await LocalDatabase.deleteExpense(expense.id);
      await _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final canEdit = widget.currentUser.role.canEditFinance;
    final total = _allExpenses.fold(0.0, (sum, e) => sum + e.amount);
    final pending = _allExpenses.where((e) => e.status == ExpenseStatus.pending).fold(0.0, (sum, e) => sum + e.amount);
    final approved = _allExpenses.where((e) => e.status == ExpenseStatus.approved).fold(0.0, (sum, e) => sum + e.amount);
    final paid = _allExpenses.where((e) => e.status == ExpenseStatus.paid).fold(0.0, (sum, e) => sum + e.amount);

    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      appBar: AppBar(
        title: const Text('Expenses'),
        backgroundColor: AppTheme.infoColor,
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
                _buildStatCard('Total', total, AppTheme.primary500, isMoney: true),
                const SizedBox(width: 12),
                _buildStatCard('Pending', pending, AppTheme.warningColor, isMoney: true),
                const SizedBox(width: 12),
                _buildStatCard('Approved', approved, AppTheme.infoColor, isMoney: true),
                const SizedBox(width: 12),
                _buildStatCard('Paid', paid, AppTheme.primary500, isMoney: true),
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
                      hintText: 'Search expenses...',
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
                : _filteredExpenses.isEmpty
                    ? const EmptyState(
                        icon: Icons.money_off,
                        title: 'No expenses found',
                        subtitle: 'Add your first expense',
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredExpenses.length,
                        itemBuilder: (ctx, index) {
                          final e = _filteredExpenses[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: _getStatusColor(e.status).withOpacity(0.15),
                                child: Icon(
                                  _getStatusIcon(e.status),
                                  color: _getStatusColor(e.status),
                                ),
                              ),
                              title: Text(
                                e.description,
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${e.category} • ${DateFormat('dd MMM yyyy').format(e.date)}'),
                                  if (e.projectId != null)
                                    Text('Project: ${_getProjectName(e.projectId)}'),
                                  const SizedBox(height: 4),
                                  _buildStatusChip(e.status),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'K ${NumberFormat('#,##0.00').format(e.amount)}',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                  ),
                                  const SizedBox(width: 8),
                                  if (canEdit)
                                    PopupMenuButton<String>(
                                      onSelected: (value) {
                                        if (value == 'edit') {
                                          _navigateToForm(expense: e);
                                        } else if (value == 'delete') {
                                          _deleteExpense(e);
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

  Widget _buildStatCard(String label, double value, Color color, {bool isMoney = false}) {
    String display = isMoney ? 'K ${NumberFormat('#,##0.00').format(value)}' : value.toStringAsFixed(0);
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

  Widget _buildStatusChip(ExpenseStatus status) {
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
