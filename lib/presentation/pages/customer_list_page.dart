import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../data/datasources/local_database.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/entities/customer.dart';
import 'customer_form_page.dart';

class CustomerListPage extends StatefulWidget {
  final AppUser currentUser;
  const CustomerListPage({super.key, required this.currentUser});

  @override
  State<CustomerListPage> createState() => _CustomerListPageState();
}

class _CustomerListPageState extends State<CustomerListPage> {
  List<Customer> _all = [];
  List<Customer> _filtered = [];
  String _search = '';
  CustomerType? _typeFilter;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _all = LocalDatabase.getCustomers();
    _applyFilters();
  }

  void _applyFilters() => setState(() {
    _filtered = _all.where((c) {
      final matchSearch = _search.isEmpty ||
          c.companyName.toLowerCase().contains(_search.toLowerCase()) ||
          c.contactPerson.toLowerCase().contains(_search.toLowerCase()) ||
          c.taxId.toLowerCase().contains(_search.toLowerCase());
      final matchType = _typeFilter == null || c.type == _typeFilter;
      return matchSearch && matchType;
    }).toList();
  });

  Future<void> _delete(Customer c) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Remove client'),
        content: Text('Remove "${c.companyName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove',
                style: TextStyle(color: AppTheme.errorColor)),
          ),
        ],
      ),
    );
    if (ok == true) {
      await LocalDatabase.deleteCustomer(c.id);
      setState(_load);
    }
  }

  @override
  Widget build(BuildContext context) {
    final govCount  = _all.where((c) => c.type == CustomerType.government).length;
    final totalCredit = _all.fold(0.0, (s, c) => s + c.creditLimit);

    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      body: Column(children: [
        // Header
        Container(
          padding: const EdgeInsets.all(20),
          color: AppTheme.surfaceColor,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Expanded(
                child: Text('Clients',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary)),
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  await Navigator.push(context,
                      MaterialPageRoute(
                          builder: (_) => CustomerFormPage(
                              currentUser: widget.currentUser)));
                  setState(_load);
                },
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add client'),
              ),
            ]),
            const SizedBox(height: 16),
            Row(children: [
              _Chip('Total', '${_all.length}', AppTheme.purpleColor),
              const SizedBox(width: 10),
              _Chip('Government', '$govCount', AppTheme.infoColor),
              const SizedBox(width: 10),
              _Chip(
                'Total credit',
                '${AppConstants.currencySymbol} ${_fmt(totalCredit)}',
                AppTheme.primaryColor,
              ),
            ]),
          ]),
        ),

        // Filters
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: const BoxDecoration(
            color: AppTheme.surfaceColor,
            border: Border(
              top: BorderSide(color: AppTheme.borderColor, width: 0.5),
              bottom: BorderSide(color: AppTheme.borderColor, width: 0.5),
            ),
          ),
          child: Row(children: [
            Expanded(
              child: TextField(
                onChanged: (v) {
                  _search = v;
                  _applyFilters();
                },
                decoration: const InputDecoration(
                  hintText: 'Search by name, contact or TPIN…',
                  prefixIcon: Icon(Icons.search, size: 18),
                  isDense: true,
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                ),
              ),
            ),
            const SizedBox(width: 12),
            DropdownButton<CustomerType?>(
              value: _typeFilter,
              underline: const SizedBox(),
              hint: const Text('All types',
                  style: TextStyle(fontSize: 13)),
              items: [
                const DropdownMenuItem(
                    value: null,
                    child: Text('All types',
                        style: TextStyle(fontSize: 13))),
                ...CustomerType.values.map((t) => DropdownMenuItem(
                    value: t,
                    child:
                        Text(t.label, style: const TextStyle(fontSize: 13)))),
              ],
              onChanged: (v) {
                _typeFilter = v;
                _applyFilters();
              },
            ),
          ]),
        ),

        // List
        Expanded(
          child: _filtered.isEmpty
              ? const _Empty(
                  icon: Icons.business_outlined,
                  title: 'No clients found',
                  subtitle: 'Add your first client',
                )
              : RefreshIndicator(
                  onRefresh: () async => setState(_load),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: _filtered.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: 10),
                    itemBuilder: (_, i) => _CustomerCard(
                      customer: _filtered[i],
                      onEdit: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CustomerFormPage(
                              currentUser: widget.currentUser,
                              customer: _filtered[i],
                            ),
                          ),
                        );
                        setState(_load);
                      },
                      onDelete: () => _delete(_filtered[i]),
                    ),
                  ),
                ),
        ),
      ]),
    );
  }

  String _fmt(double v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(0)}k';
    return v.toStringAsFixed(0);
  }
}

class _Chip extends StatelessWidget {
  final String label, value;
  final Color color;
  const _Chip(this.label, this.value, this.color);
  @override
  Widget build(BuildContext context) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(children: [
          Text(value,
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: color)),
          Text(label,
              style: const TextStyle(
                  fontSize: 11, color: AppTheme.textMuted)),
        ]),
      );
}

class _CustomerCard extends StatelessWidget {
  final Customer customer;
  final VoidCallback onEdit, onDelete;
  const _CustomerCard(
      {required this.customer,
      required this.onEdit,
      required this.onDelete});

  Color get _typeColor {
    switch (customer.type) {
      case CustomerType.government:
        return AppTheme.infoColor;
      case CustomerType.wholesale:
        return AppTheme.primaryColor;
      case CustomerType.ngo:
        return AppTheme.purpleColor;
      case CustomerType.retail:
        return AppTheme.accentColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: AppTheme.borderColor, width: 0.5),
      ),
      child: Row(children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: _typeColor.withOpacity(0.15),
          child: Text(customer.initials,
              style: TextStyle(
                  color: _typeColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14)),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            Row(children: [
              Expanded(
                child: Text(customer.companyName,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _typeColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(customer.type.label,
                    style: TextStyle(
                        fontSize: 10,
                        color: _typeColor,
                        fontWeight: FontWeight.w600)),
              ),
            ]),
            const SizedBox(height: 3),
            Text(
                '${customer.contactPerson}  ·  ${customer.phoneNumber}',
                style: const TextStyle(
                    fontSize: 12, color: AppTheme.textMuted)),
            const SizedBox(height: 8),
            Row(children: [
              if (customer.taxId.isNotEmpty) ...[
                _Stat('TPIN', customer.taxId),
                const SizedBox(width: 16),
              ],
              _Stat(
                'Credit limit',
                '${AppConstants.currencySymbol} ${customer.creditLimit.toStringAsFixed(0)}',
              ),
              const SizedBox(width: 16),
              _Stat(
                'Balance',
                '${AppConstants.currencySymbol} ${customer.currentBalance.toStringAsFixed(0)}',
                highlight: customer.currentBalance > 0,
              ),
            ]),
          ]),
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert,
              size: 18, color: AppTheme.textMuted),
          onSelected: (v) {
            if (v == 'edit') onEdit();
            if (v == 'delete') onDelete();
          },
          itemBuilder: (_) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(children: [
                Icon(Icons.edit_outlined, size: 16),
                SizedBox(width: 8),
                Text('Edit'),
              ]),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(children: [
                Icon(Icons.delete_outline,
                    size: 16, color: AppTheme.errorColor),
                SizedBox(width: 8),
                Text('Remove',
                    style: TextStyle(color: AppTheme.errorColor)),
              ]),
            ),
          ],
        ),
      ]),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label, value;
  final bool highlight;
  const _Stat(this.label, this.value, {this.highlight = false});
  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 10, color: AppTheme.textMuted)),
          Text(value,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: highlight
                      ? AppTheme.warningColor
                      : AppTheme.textPrimary)),
        ],
      );
}

class _Empty extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  const _Empty(
      {required this.icon,
      required this.title,
      required this.subtitle});
  @override
  Widget build(BuildContext context) => Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
          Icon(icon, size: 56, color: AppTheme.textMuted),
          const SizedBox(height: 14),
          Text(title,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary)),
          const SizedBox(height: 4),
          Text(subtitle,
              style: const TextStyle(
                  fontSize: 13, color: AppTheme.textMuted)),
        ]),
      );
}
