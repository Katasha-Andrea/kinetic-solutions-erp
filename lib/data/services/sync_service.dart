// lib/data/services/sync_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kinetic_solutions/data/datasources/local_database.dart';
import 'package:kinetic_solutions/data/services/supabase_service.dart';
import 'package:kinetic_solutions/domain/entities/inventory_item.dart';
import 'package:kinetic_solutions/domain/entities/employee.dart';
// ... import all other entities

class SyncService {
  static final SupabaseClient _client = Supabase.instance.client;

  /// Call this once at app startup to sync all collections.
  static Future<void> syncAll() async {
    await _syncCollection<InventoryItem>(
      localGetter: LocalDatabase.getInventoryItems,
      localSaver: LocalDatabase.saveInventoryItem,
      localDeleter: LocalDatabase.deleteInventoryItem,
      stream: SupabaseService.getInventoryStream(),
      entityName: 'Inventory',
    );
    await _syncCollection<Employee>(
      localGetter: LocalDatabase.getEmployees,
      localSaver: LocalDatabase.saveEmployee,
      localDeleter: LocalDatabase.deleteEmployee,
      stream: SupabaseService.getEmployeesStream(),
      entityName: 'Employees',
    );
    // Add all other collections here...
    // Use the same pattern.
  }

  static Future<void> _syncCollection<T>({
    required List<T> Function() localGetter,
    required Future<void> Function(T) localSaver,
    required Future<void> Function(String) localDeleter,
    required Stream<List<T>> stream,
    required String entityName,
  }) async {
    // Initial load: if local is empty, pull from cloud.
    final localItems = localGetter();
    if (localItems.isEmpty) {
      print('📥 Loading $entityName from Supabase into Hive...');
      final cloudItems = await stream.first;
      for (final item in cloudItems) {
        await localSaver(item);
      }
    }

    // Subscribe to real‑time updates and sync to Hive.
    stream.listen((cloudItems) {
      final localIds = localGetter().map((e) => _getId(e)).toSet();
      final cloudIds = cloudItems.map((e) => _getId(e)).toSet();

      // Add/update items
      for (final item in cloudItems) {
        _saveIfChanged(item, localSaver);
      }

      // Delete items not in cloud
      for (final id in localIds.difference(cloudIds)) {
        localDeleter(id);
      }
    }, onError: (e) {
      print('⚠️ Sync error for $entityName: $e');
    });
  }

  static String _getId(dynamic item) => (item as dynamic).id as String;

  static Future<void> _saveIfChanged<T>(T cloudItem, Future<void> Function(T) localSaver) async {
    // Simple: just save – we could add a hash check to avoid unnecessary writes.
    await localSaver(cloudItem);
  }
}