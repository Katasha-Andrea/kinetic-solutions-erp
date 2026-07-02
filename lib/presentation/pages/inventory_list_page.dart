// lib/presentation/pages/inventory_list_page.dart
import 'package:flutter/material.dart';
import 'package:kinetic_solutions/core/theme/app_theme.dart';
import 'package:kinetic_solutions/data/services/supabase_service.dart';
import 'package:kinetic_solutions/domain/entities/app_user.dart';
import 'package:kinetic_solutions/domain/entities/inventory_item.dart';
import 'package:kinetic_solutions/presentation/pages/inventory_form_page.dart';
import 'package:kinetic_solutions/presentation/widgets/shared_widgets.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';

class InventoryListPage extends StatelessWidget {
  final AppUser currentUser;
  const InventoryListPage({super.key, required this.currentUser});

  @override
  Widget build(BuildContext context) {
    final canEdit = currentUser.role.canEditInventory;

    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      appBar: AppBar(
        title: const Text('Inventory'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          if (canEdit)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => InventoryFormPage(currentUser: currentUser),
                  ),
                );
              },
            ),
        ],
      ),
      body: StreamBuilder<List<InventoryItem>>(
        stream: SupabaseService.getInventoryStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final items = snapshot.data!;
          final totalItems = items.length;
          final totalValue = items.fold(0.0, (sum, i) => sum + i.stockValue);
          final lowStockCount = items.where((i) => i.needsReorder).length;

          return Column(
            children: [
              // Stats strip
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    _buildStat('Items', totalItems, AppTheme.primary500),
                    const SizedBox(width: 12),
                    _buildStat('Value', totalValue, AppTheme.infoColor, isMoney: true),
                    const SizedBox(width: 12),
                    _buildStat('Low Stock', lowStockCount, AppTheme.errorColor),
                  ],
                ),
              ),
              Expanded(
                child: items.isEmpty
                    ? const EmptyState(
                        icon: Icons.inventory_2,
                        title: 'No items',
                        subtitle: 'Add your first inventory item',
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: items.length,
                        itemBuilder: (ctx, index) {
                          final item = items[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: item.needsReorder
                                    ? AppTheme.errorLight
                                    : AppTheme.primary50,
                                child: Icon(
                                  item.needsReorder
                                      ? Icons.warning_amber_rounded
                                      : Icons.inventory_2,
                                  color: item.needsReorder
                                      ? AppTheme.errorColor
                                      : AppTheme.primaryColor,
                                ),
                              ),
                              title: Text(
                                item.name,
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('SKU: ${item.sku}'),
                                  Text('Qty: ${item.quantity} | Reorder: ${item.reorderLevel}'),
                                  Text(
                                    'K ${NumberFormat('#,##0.00').format(item.unitPrice)}',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (item.needsReorder)
                                    const Icon(Icons.warning,
                                        color: AppTheme.errorColor),
                                  const SizedBox(width: 8),
                                  if (canEdit)
                                    PopupMenuButton<String>(
                                      onSelected: (value) {
                                        if (value == 'edit') {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => InventoryFormPage(
                                                currentUser: currentUser,
                                                item: item,
                                              ),
                                            ),
                                          );
                                        } else if (value == 'delete') {
                                          _showDeleteDialog(context, item);
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
          );
        },
      ),
    );
  }

  Widget _buildStat(String label, dynamic value, Color color, {bool isMoney = false}) {
    String display = isMoney
        ? 'K ${NumberFormat('#,##0.00').format(value)}'
        : value.toString();
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
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color),
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

  void _showDeleteDialog(BuildContext context, InventoryItem item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Item'),
        content: Text('Delete "${item.name}"?'),
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
    if (confirm == true) {
      await SupabaseService.deleteInventoryItem(item.id);
    }
  }
}