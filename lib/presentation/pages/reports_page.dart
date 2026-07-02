import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../data/datasources/local_database.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/entities/employee.dart';
import '../../domain/entities/inventory_item.dart';
import '../../domain/entities/project.dart';

class ReportsPage extends StatefulWidget {
  final AppUser currentUser;
  const ReportsPage({super.key, required this.currentUser});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      appBar: AppBar(
        title: const Text('Reports & Analytics'),
        bottom: TabBar(
          controller: _tab,
          tabs: const [
            Tab(text: 'Inventory'),
            Tab(text: 'Financial'),
            Tab(text: 'Employees'),
            Tab(text: 'Projects'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          _InventoryReport(),
          _FinancialReport(),
          _EmployeeReport(),
          _ProjectReport(),
        ],
      ),
    );
  }
}

// ── Inventory tab ─────────────────────────────────────────────────────────────
class _InventoryReport extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final items = LocalDatabase.getInventoryItems();
    final totalValue = items.fold(0.0, (s, i) => s + i.stockValue);
    final lowStock   = items.where((i) => i.needsReorder).length;

    final Map<String, int> byCat = {};
    for (final i in items) {
      byCat[i.category] = (byCat[i.category] ?? 0) + 1;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(children: [
        Row(children: [
          Expanded(child: _KpiCard('Total SKUs', '${items.length}',
              Icons.inventory_2_outlined, AppTheme.primaryColor, AppTheme.primary50)),
          const SizedBox(width: 12),
          Expanded(child: _KpiCard('Low stock', '$lowStock',
              Icons.warning_amber_outlined, AppTheme.errorColor, AppTheme.errorLight)),
          const SizedBox(width: 12),
          Expanded(child: _KpiCard(
            'Stock value',
            '${AppConstants.currencySymbol} ${_fmt(totalValue)}',
            Icons.monetization_on_outlined, AppTheme.infoColor, AppTheme.infoLight)),
        ]),
        const SizedBox(height: 20),
        _ChartCard(
          title: 'Items by category',
          child: byCat.isEmpty
              ? const _NoData()
              : SizedBox(
                  height: 200,
                  child: PieChart(PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 40,
                    sections: byCat.entries.toList().asMap().entries.map((e) {
                      final colors = [
                        AppTheme.primaryColor, AppTheme.infoColor,
                        AppTheme.accentColor, AppTheme.purpleColor,
                        AppTheme.errorColor,
                      ];
                      return PieChartSectionData(
                        color: colors[e.key % colors.length],
                        value: e.value.value.toDouble(),
                        title: e.value.key,
                        titleStyle: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w600),
                        radius: 70,
                      );
                    }).toList(),
                  )),
                ),
        ),
        const SizedBox(height: 16),
        _ChartCard(
          title: 'Top items by stock value',
          child: Column(
            children: (items..sort((a, b) => b.stockValue.compareTo(a.stockValue)))
                .take(5)
                .map((item) => _BarRow(
                      label: item.name,
                      value: item.stockValue,
                      max: items.isEmpty ? 1 : items
                          .map((i) => i.stockValue)
                          .reduce((a, b) => a > b ? a : b),
                      color: AppTheme.primaryColor,
                    ))
                .toList(),
          ),
        ),
      ]),
    );
  }
}

// ── Financial tab ──────────────────────────────────────────────────────────────
class _FinancialReport extends StatelessWidget {
  static const _revenue = [35000.0, 42000.0, 38000.0, 48000.0, 45000.0, 52000.0];
  static const _costs   = [22000.0, 28000.0, 25000.0, 31000.0, 29000.0, 33000.0];
  static const _months  = ['Jan','Feb','Mar','Apr','May','Jun'];

  @override
  Widget build(BuildContext context) {
    final items    = LocalDatabase.getInventoryItems();
    final totalVat = items
        .where((i) => i.isVatable)
        .fold(0.0, (s, i) => s + i.vatAmount);
    final totalRev = _revenue.reduce((a, b) => a + b).toDouble();
    final totalCost= _costs.reduce((a, b) => a + b).toDouble();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(children: [
        Row(children: [
          Expanded(child: _KpiCard(
            'Total revenue',
            '${AppConstants.currencySymbol} ${_fmt(totalRev)}',
            Icons.trending_up, AppTheme.primaryColor, AppTheme.primary50)),
          const SizedBox(width: 12),
          Expanded(child: _KpiCard(
            'Total costs',
            '${AppConstants.currencySymbol} ${_fmt(totalCost)}',
            Icons.trending_down, AppTheme.errorColor, AppTheme.errorLight)),
          const SizedBox(width: 12),
          Expanded(child: _KpiCard(
            'VAT collected',
            '${AppConstants.currencySymbol} ${totalVat.toStringAsFixed(0)}',
            Icons.receipt_long_outlined, AppTheme.infoColor, AppTheme.infoLight)),
        ]),
        const SizedBox(height: 20),
        _ChartCard(
          title: 'Revenue vs Costs (ZMW)',
          child: SizedBox(
            height: 200,
            child: BarChart(BarChartData(
              alignment: BarChartAlignment.spaceAround,
              barGroups: List.generate(_months.length, (i) => BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(toY: _revenue[i] / 1000, color: AppTheme.primaryColor, width: 10, borderRadius: BorderRadius.circular(4)),
                  BarChartRodData(toY: _costs[i]   / 1000, color: AppTheme.errorColor,   width: 10, borderRadius: BorderRadius.circular(4)),
                ],
              )),
              titlesData: FlTitlesData(
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles:   const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (v, _) => Text(
                    v.toInt() < _months.length ? _months[v.toInt()] : '',
                    style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                )),
                leftTitles: AxisTitles(sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 36,
                  getTitlesWidget: (v, _) => Text('${v.toInt()}k',
                    style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                )),
              ),
              borderData: FlBorderData(show: false),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (_) =>
                    FlLine(color: Colors.grey.shade100, strokeWidth: 1),
              ),
            )),
          ),
        ),
      ]),
    );
  }
}

// ── Employee tab ──────────────────────────────────────────────────────────────
class _EmployeeReport extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final employees = LocalDatabase.getEmployees();
    final active    = employees.where((e) => e.status == EmploymentStatus.active).length;
    final payroll   = employees
        .where((e) => e.status == EmploymentStatus.active)
        .fold(0.0, (s, e) => s + e.netSalary);

    final Map<String, int> byDept = {};
    for (final e in employees) {
      byDept[e.department] = (byDept[e.department] ?? 0) + 1;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(children: [
        Row(children: [
          Expanded(child: _KpiCard('Total staff', '${employees.length}',
              Icons.people_outline, AppTheme.infoColor, AppTheme.infoLight)),
          const SizedBox(width: 12),
          Expanded(child: _KpiCard('Active', '$active',
              Icons.check_circle_outline, AppTheme.primaryColor, AppTheme.primary50)),
          const SizedBox(width: 12),
          Expanded(child: _KpiCard(
            'Net payroll',
            '${AppConstants.currencySymbol} ${_fmt(payroll)}',
            Icons.account_balance_wallet_outlined, AppTheme.purpleColor, AppTheme.purpleLight)),
        ]),
        const SizedBox(height: 20),
        _ChartCard(
          title: 'Staff by department',
          child: byDept.isEmpty
              ? const _NoData()
              : SizedBox(
                  height: 200,
                  child: PieChart(PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 40,
                    sections: byDept.entries.toList().asMap().entries.map((e) {
                      final colors = [
                        AppTheme.infoColor, AppTheme.primaryColor,
                        AppTheme.purpleColor, AppTheme.accentColor,
                        AppTheme.errorColor,
                      ];
                      return PieChartSectionData(
                        color: colors[e.key % colors.length],
                        value: e.value.value.toDouble(),
                        title: '${e.value.key}\n${e.value.value}',
                        titleStyle: const TextStyle(fontSize: 9, color: Colors.white),
                        radius: 70,
                      );
                    }).toList(),
                  )),
                ),
        ),
        const SizedBox(height: 16),
        _ChartCard(
          title: 'Employment status breakdown',
          child: Column(
            children: EmploymentStatus.values.map((status) {
              final count = employees.where((e) => e.status == status).length;
              return _BarRow(
                label: status.label,
                value: count.toDouble(),
                max: employees.isEmpty ? 1 : employees.length.toDouble(),
                color: status == EmploymentStatus.active
                    ? AppTheme.primaryColor
                    : status == EmploymentStatus.onLeave
                        ? AppTheme.accentColor
                        : AppTheme.errorColor,
              );
            }).toList(),
          ),
        ),
      ]),
    );
  }
}

// ── Project tab ───────────────────────────────────────────────────────────────
class _ProjectReport extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final projects   = LocalDatabase.getProjects();
    final active     = projects.where((p) => p.status == ProjectStatus.inProgress).length;
    final totalBudget= projects.fold(0.0, (s, p) => s + p.budget);
    final totalSpent = projects.fold(0.0, (s, p) => s + p.spent);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(children: [
        Row(children: [
          Expanded(child: _KpiCard('Total projects', '${projects.length}',
              Icons.work_outline, AppTheme.accentColor, AppTheme.accentLight)),
          const SizedBox(width: 12),
          Expanded(child: _KpiCard('Active', '$active',
              Icons.play_circle_outline, AppTheme.primaryColor, AppTheme.primary50)),
          const SizedBox(width: 12),
          Expanded(child: _KpiCard(
            'Budget util.',
            totalBudget > 0 ? '${(totalSpent / totalBudget * 100).toStringAsFixed(1)}%' : '0%',
            Icons.pie_chart_outline, AppTheme.infoColor, AppTheme.infoLight)),
        ]),
        const SizedBox(height: 20),
        _ChartCard(
          title: 'Budget utilisation by project',
          child: projects.isEmpty
              ? const _NoData()
              : Column(
                  children: projects.take(6).map((p) => _BarRow(
                    label: p.name,
                    value: p.budgetUtilization,
                    max: 100,
                    color: p.budgetUtilization > 90
                        ? AppTheme.errorColor
                        : p.budgetUtilization > 70
                            ? AppTheme.accentColor
                            : AppTheme.primaryColor,
                    suffix: '%',
                  )).toList(),
                ),
        ),
        const SizedBox(height: 16),
        _ChartCard(
          title: 'Projects by status',
          child: Column(
            children: ProjectStatus.values.map((status) {
              final count = projects.where((p) => p.status == status).length;
              return _BarRow(
                label: status.label,
                value: count.toDouble(),
                max: projects.isEmpty ? 1 : projects.length.toDouble(),
                color: status == ProjectStatus.inProgress
                    ? AppTheme.primaryColor
                    : status == ProjectStatus.completed
                        ? AppTheme.primary700
                        : status == ProjectStatus.onHold
                            ? AppTheme.accentColor
                            : AppTheme.errorColor,
              );
            }).toList(),
          ),
        ),
      ]),
    );
  }
}

// ── Shared report widgets ─────────────────────────────────────────────────────
class _KpiCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color, bgColor;
  const _KpiCard(this.label, this.value, this.icon, this.color, this.bgColor);
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.borderColor, width: 0.5),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(height: 10),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
        ]),
      );
}

class _ChartCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _ChartCard({required this.title, required this.child});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.borderColor, width: 0.5),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
          const SizedBox(height: 16),
          child,
        ]),
      );
}

class _BarRow extends StatelessWidget {
  final String label;
  final double value, max;
  final Color color;
  final String suffix;
  const _BarRow({required this.label, required this.value, required this.max, required this.color, this.suffix = ''});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(children: [
          SizedBox(
            width: 110,
            child: Text(label,
                style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                overflow: TextOverflow.ellipsis),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: max > 0 ? (value / max).clamp(0.0, 1.0) : 0,
                minHeight: 8,
                backgroundColor: AppTheme.bgColor,
                color: color,
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 44,
            child: Text(
              '${value.toStringAsFixed(0)}$suffix',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
              textAlign: TextAlign.right,
            ),
          ),
        ]),
      );
}

class _NoData extends StatelessWidget {
  const _NoData();
  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.all(20),
        child: Center(
          child: Text('No data yet',
              style: TextStyle(color: AppTheme.textMuted, fontSize: 13)),
        ),
      );
}

String _fmt(double v) {
  if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
  if (v >= 1000) return '${(v / 1000).toStringAsFixed(0)}k';
  return v.toStringAsFixed(0);
}
