import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../data/datasources/local_database.dart';
import '../../domain/entities/inventory_item.dart';
import '../../domain/entities/app_user.dart';
import 'inventory_form_page.dart';
import 'stock_in_page.dart';
import 'stock_out_page.dart';

class InventoryListPage extends StatefulWidget {
  final AppUser currentUser;
  const InventoryListPage({super.key, required this.currentUser});
  @override
  State<InventoryListPage> createState() => _InventoryListPageState();
}

class _InventoryListPageState extends State<InventoryListPage> {
  List<InventoryItem> _all = [];
  List<InventoryItem> _filtered = [];
  String _search = '';
  String _categoryFilter = 'All';
  String _stockFilter = 'All';

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _all = LocalDatabase.getInventoryItems();
    _applyFilters();
  }

  void _applyFilters() {
    setState(() {
      _filtered = _all.where((item) {
        final matchSearch = _search.isEmpty ||
            item.name.toLowerCase().contains(_search.toLowerCase()) ||
            item.sku.toLowerCase().contains(_search.toLowerCase());
        final matchCat = _categoryFilter == 'All' || item.category == _categoryFilter;
        final matchStock = _stockFilter == 'All' ||
            (_stockFilter == 'Low' && item.needsReorder) ||
            (_stockFilter == 'In Stock' && !item.needsReorder);
        return matchSearch && matchCat && matchStock;
      }).toList();
    });
  }

  List<String> get _categories {
    final cats = _all.map((i) => i.category).toSet().toList()..sort();
    return ['All', ...cats];
  }

  Future<void> _delete(InventoryItem item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete item'),
        content: Text('Delete "${item.name}"? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: AppTheme.errorColor)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await LocalDatabase.deleteInventoryItem(item.id);
      setState(_load);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lowStockCount = _all.where((i) => i.needsReorder).length;
    final totalValue = _all.fold(0.0, (sum, i) => sum + i.stockValue);

    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      body: Column(
        children: [
          // Header summary bar
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  const Expanded(child: Text('Inventory', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
                  if (widget.currentUser.role.canEditInventory) ...[
                    OutlinedButton.icon(
                      onPressed: () async {
                        await Navigator.push(context, MaterialPageRoute(builder: (_) => StockInPage(currentUser: widget.currentUser)));
                        setState(_load);
                      },
                      icon: const Icon(Icons.add_business, size: 16),
                      label: const Text('Stock In'),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: () async {
                        await Navigator.push(context, MaterialPageRoute(builder: (_) => StockOutPage(currentUser: widget.currentUser)));
                        setState(_load);
                      },
                      icon: const Icon(Icons.remove_shopping_cart, size: 16),
                      label: const Text('Stock Out'),
                      style: OutlinedButton.styleFrom(foregroundColor: AppTheme.errorColor, side: const BorderSide(color: AppTheme.errorColor)),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () async {
                        await Navigator.push(context, MaterialPageRoute(builder: (_) => const InventoryFormPage()));
                        setState(_load);
                      },
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Add Item'),
                    ),
                  ],
                ]),
                const SizedBox(height: 16),
                Row(children: [
                  _SummaryChip(label: 'Total items', value: '${_all.length}', color: AppTheme.primaryColor),
                  const SizedBox(width: 12),
                  _SummaryChip(label: 'Low stock', value: '$lowStockCount', color: AppTheme.errorColor),
                  const SizedBox(width: 12),
                  _SummaryChip(
                    label: 'Stock value',
                    value: '${AppConstants.currencySymbol} ${totalValue.toStringAsFixed(0)}',
                    color: AppTheme.infoColor,
                  ),
                ]),
              ],
            ),
          ),

          // Search & filter bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: AppTheme.borderColor, width: 0.5),
                top: BorderSide(color: AppTheme.borderColor, width: 0.5),
              ),
            ),
            child: Row(children: [
              Expanded(
                child: TextField(
                  onChanged: (v) { _search = v; _applyFilters(); },
                  decoration: const InputDecoration(
                    hintText: 'Search by name or SKU…',
                    prefixIcon: Icon(Icons.search, size: 18),
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              DropdownButton<String>(
                value: _categoryFilter,
                underline: const SizedBox(),
                items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 13)))).toList(),
                onChanged: (v) { if (v != null) { _categoryFilter = v; _applyFilters(); } },
              ),
              const SizedBox(width: 12),
              DropdownButton<String>(
                value: _stockFilter,
                underline: const SizedBox(),
                items: ['All', 'In Stock', 'Low'].map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 13)))).toList(),
                onChanged: (v) { if (v != null) { _stockFilter = v; _applyFilters(); } },
              ),
            ]),
          ),

          // List
          Expanded(
            child: _filtered.isEmpty
              ? _EmptyState(
                  icon: Icons.inventory_2_outlined,
                  title: 'No items found',
                  subtitle: _search.isNotEmpty ? 'Try a different search term' : 'Add your first inventory item',
                )
              : RefreshIndicator(
                  onRefresh: () async => setState(_load),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: _filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) => _InventoryCard(
                      item: _filtered[i],
                      canEdit: widget.currentUser.role.canEditInventory,
                      onEdit: () async {
                        await Navigator.push(context, MaterialPageRoute(
                          builder: (_) => InventoryFormPage(item: _filtered[i]),
                        ));
                        setState(_load);
                      },
                      onDelete: () => _delete(_filtered[i]),
                    ),
                  ),
                ),
          ),
        ],
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final String label, value;
  final Color color;
  const _SummaryChip({required this.label, required this.value, required this.color});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: color.withOpacity(0.08),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: color.withOpacity(0.2)),
    ),
    child: Column(children: [
      Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
      Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
    ]),
  );
}

class _InventoryCard extends StatelessWidget {
  final InventoryItem item;
  final bool canEdit;
  final VoidCallback onEdit, onDelete;
  const _InventoryCard({required this.item, required this.canEdit, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: item.needsReorder ? AppTheme.errorColor.withOpacity(0.4) : AppTheme.borderColor,
        width: item.needsReorder ? 1 : 0.5,
      ),
    ),
    child: Row(children: [
      // Category icon
      Container(
        width: 44, height: 44,
        decoration: BoxDecoration(
          color: item.needsReorder ? AppTheme.errorLight : AppTheme.primary50,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(Icons.inventory_2_outlined,
          size: 22,
          color: item.needsReorder ? AppTheme.errorColor : AppTheme.primaryColor),
      ),
      const SizedBox(width: 14),
      Expanded(child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(child: Text(item.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600))),
            if (item.needsReorder)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(color: AppTheme.errorLight, borderRadius: BorderRadius.circular(20)),
                child: const Text('Low stock', style: TextStyle(fontSize: 10, color: AppTheme.errorColor, fontWeight: FontWeight.w600)),
              ),
          ]),
          const SizedBox(height: 3),
          Text('SKU: ${item.sku}  ·  ${item.category}',
            style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
          const SizedBox(height: 8),
          Row(children: [
            _ItemStat(label: 'Qty', value: '${item.quantity}'),
            const SizedBox(width: 16),
            _ItemStat(label: 'Unit price', value: '${AppConstants.currencySymbol} ${item.unitPrice.toStringAsFixed(2)}'),
            const SizedBox(width: 16),
            _ItemStat(label: 'Margin', value: '${item.profitMargin.toStringAsFixed(1)}%'),
            if (item.isVatable) ...[
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: AppTheme.infoLight, borderRadius: BorderRadius.circular(6)),
                child: const Text('VAT 16%', style: TextStyle(fontSize: 10, color: AppTheme.infoColor, fontWeight: FontWeight.w500)),
              ),
            ],
          ]),
        ],
      )),
      if (canEdit) PopupMenuButton<String>(
        icon: const Icon(Icons.more_vert, size: 18, color: AppTheme.textMuted),
        onSelected: (v) { if (v == 'edit') onEdit(); else if (v == 'delete') onDelete(); },
        itemBuilder: (_) => [
          const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit_outlined, size: 16), SizedBox(width: 8), Text('Edit')])),
          const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete_outline, size: 16, color: AppTheme.errorColor), SizedBox(width: 8), Text('Delete', style: TextStyle(color: AppTheme.errorColor))])),
        ],
      ),
    ]),
  );
}

class _ItemStat extends StatelessWidget {
  final String label, value;
  const _ItemStat({required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(fontSize: 10, color: AppTheme.textMuted)),
      Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
    ],
  );
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  const _EmptyState({required this.icon, required this.title, required this.subtitle});
  @override
  Widget build(BuildContext context) => Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    Icon(icon, size: 56, color: AppTheme.textMuted),
    const SizedBox(height: 14),
    Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
    const SizedBox(height: 4),
    Text(subtitle, style: const TextStyle(fontSize: 13, color: AppTheme.textMuted)),
  ]));
}
