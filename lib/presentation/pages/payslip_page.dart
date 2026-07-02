import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../domain/entities/employee.dart';
import '../../domain/entities/app_user.dart';

class PayslipPage extends StatelessWidget {
  final Employee employee;
  const PayslipPage({super.key, required this.employee});

  @override
  Widget build(BuildContext context) {
    final now   = DateTime.now();
    const months = ['January','February','March','April','May','June',
      'July','August','September','October','November','December'];

    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      appBar: AppBar(
        title: Text('Payslip — ${employee.firstName}'),
        actions: [
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.download_outlined, size: 16),
            label: const Text('Export'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('PAYSLIP', style: TextStyle(color: Colors.white, fontSize: 11, letterSpacing: 2, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Text(employee.fullName,
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('${employee.position}  ·  ${employee.department}',
                  style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 13)),
              const SizedBox(height: 12),
              Text('${months[now.month - 1]} ${now.year}',
                  style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13)),
            ]),
          ),
          const SizedBox(height: 16),

          // Earnings
          _PayCard(
            title: 'Earnings',
            color: AppTheme.primaryColor,
            rows: [
              _PayRow('Basic salary', employee.basicSalary),
              _PayRow('Housing allowance', employee.housingAllowance),
              _PayRow('Transport allowance', employee.transportAllowance),
            ],
            total: _PayRow('Gross salary', employee.grossSalary, bold: true),
          ),
          const SizedBox(height: 12),

          // Deductions
          _PayCard(
            title: 'Deductions',
            color: AppTheme.errorColor,
            rows: [
              _PayRow('PAYE (ZRA)', employee.payeMonthly, negative: true),
              _PayRow('NAPSA (5%)', employee.napsaContribution, negative: true),
            ],
            total: _PayRow(
              'Total deductions',
              employee.payeMonthly + employee.napsaContribution,
              bold: true,
              negative: true,
            ),
          ),
          const SizedBox(height: 16),

          // Net salary
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.primary50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('NET SALARY',
                  style: TextStyle(
                      fontSize: 11, letterSpacing: 2,
                      fontWeight: FontWeight.w600, color: AppTheme.primaryColor)),
              const SizedBox(height: 8),
              Text(
                '${AppConstants.currencySymbol} ${employee.netSalary.toStringAsFixed(2)}',
                style: const TextStyle(
                    fontSize: 32, fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor),
              ),
              const SizedBox(height: 4),
              Text('${months[now.month - 1]} ${now.year}',
                  style: const TextStyle(fontSize: 13, color: AppTheme.textMuted)),
            ]),
          ),
          const SizedBox(height: 16),

          // Employee details
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.borderColor, width: 0.5),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Employee details',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              _Detail('NRC', employee.nrc.isEmpty ? '—' : employee.nrc),
              _Detail('NAPSA No.', employee.napsaNumber.isEmpty ? '—' : employee.napsaNumber),
              _Detail('Department', employee.department),
              _Detail('Status', employee.status.label),
            ]),
          ),
          const SizedBox(height: 40),
        ]),
      ),
    );
  }
}

class _PayCard extends StatelessWidget {
  final String title;
  final Color color;
  final List<_PayRow> rows;
  final _PayRow total;
  const _PayCard({required this.title, required this.color, required this.rows, required this.total});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.borderColor, width: 0.5),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: color)),
          const SizedBox(height: 12),
          ...rows.map((r) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(children: [
              Expanded(child: Text(r.label, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary))),
              Text(
                '${r.negative ? '−' : ''}${AppConstants.currencySymbol} ${r.amount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 13,
                  color: r.negative ? AppTheme.errorColor : AppTheme.textPrimary,
                ),
              ),
            ]),
          )),
          const Divider(height: 20),
          Row(children: [
            Expanded(child: Text(total.label,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold))),
            Text(
              '${total.negative ? '−' : ''}${AppConstants.currencySymbol} ${total.amount.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.bold,
                color: total.negative ? AppTheme.errorColor : color,
              ),
            ),
          ]),
        ]),
      );
}

class _PayRow {
  final String label;
  final double amount;
  final bool bold, negative;
  const _PayRow(this.label, this.amount, {this.bold = false, this.negative = false});
}

class _Detail extends StatelessWidget {
  final String label, value;
  const _Detail(this.label, this.value);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(children: [
          SizedBox(
            width: 100,
            child: Text(label, style: const TextStyle(fontSize: 13, color: AppTheme.textMuted)),
          ),
          Expanded(child: Text(value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
        ]),
      );
}
