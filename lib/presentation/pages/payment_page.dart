// lib/presentation/pages/payment_page.dart
import 'package:flutter/material.dart';
import 'package:kinetic_solutions/core/auth/auth_service.dart';
import 'package:kinetic_solutions/core/theme/app_theme.dart';
import 'package:kinetic_solutions/data/datasources/local_database.dart';
import 'package:kinetic_solutions/domain/entities/payment.dart';
import 'package:kinetic_solutions/domain/entities/invoice.dart';
import 'package:kinetic_solutions/presentation/pages/payment_form_page.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/app_user.dart';

class PaymentPage extends StatefulWidget {
  final AppUser currentUser;

  const PaymentPage({super.key, required this.currentUser});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  List<Payment> _payments = [];
  List<Invoice> _invoices = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final payments = LocalDatabase.getPayments();
    final invoices = LocalDatabase.getInvoices();
    setState(() {
      _payments = payments..sort((a, b) => b.paymentDate.compareTo(a.paymentDate));
      _invoices = invoices;
      _isLoading = false;
    });
  }

  String _getInvoiceNumber(String invoiceId) {
    final inv = _invoices.firstWhere((i) => i.id == invoiceId, orElse: () => throw Exception("Not found"));
    return inv?.invoiceNumber ?? 'Unknown';
  }

  Color _getMethodColor(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cash: return Colors.green;
      case PaymentMethod.bankTransfer: return Colors.blue;
      case PaymentMethod.mobileMoney: return Colors.orange;
      case PaymentMethod.cheque: return Colors.purple;
      case PaymentMethod.other: return Colors.grey;
    }
  }

  Future<void> _navigateToForm({Payment? payment}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PaymentFormPage(currentUser: widget.currentUser, payment: payment)),
    );
    await _loadData();
  }

  Future<void> _deletePayment(Payment p) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Payment'),
        content: Text('Delete payment of K ${NumberFormat('#,##0.00').format(p.amount)}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete', style: TextStyle(color: AppTheme.errorColor))),
        ],
      ),
    );
    if (confirmed == true) {
      await LocalDatabase.deletePayment(p.id);
      await _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final canEdit = widget.currentUser.role.canEditFinance;
    final total = _payments.length;
    final totalAmount = _payments.fold(0.0, (sum, p) => sum + p.amount);

    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      appBar: AppBar(
        title: const Text('Payments'),
        backgroundColor: Colors.green.shade700,
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
                _buildStat('Total Payments', total, Colors.green.shade700),
                const SizedBox(width: 12),
                _buildStat('Total Amount', totalAmount, Colors.blue, isMoney: true),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _payments.isEmpty
                    ? const Center(child: Text('No payments'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _payments.length,
                        itemBuilder: (ctx, i) {
                          final p = _payments[i];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: _getMethodColor(p.method).withOpacity(0.2),
                                child: Icon(Icons.payment, color: _getMethodColor(p.method)),
                              ),
                              title: Text('Invoice: ${_getInvoiceNumber(p.invoiceId)}'),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Method: ${p.method.name} • ${DateFormat('dd MMM yyyy').format(p.paymentDate)}'),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'K ${NumberFormat('#,##0.00').format(p.amount)}',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                  ),
                                  const SizedBox(width: 8),
                                  if (canEdit)
                                    PopupMenuButton(
                                      onSelected: (value) {
                                        if (value == 'edit') _navigateToForm(payment: p);
                                        else if (value == 'delete') _deletePayment(p);
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
    String display = isMoney ? 'K ${NumberFormat('#,##0.00').format(value)}' : value.toString();
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
