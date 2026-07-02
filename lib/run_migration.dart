// lib/run_migration.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kinetic_solutions/data/datasources/local_database.dart';
import 'package:kinetic_solutions/utils/migration.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://qdgvhgbvjfoggvfeyrsc.supabase.co',
    anonKey: 'sb_publishable_m4PgcRpCF59uN_GYC_7qXw_OsO88oLP',
  );

  // Initialize Hive (local data)
  await LocalDatabase.init();

  // Run the migration
  await Migration.migrateAll();

  print('✅ Migration finished! You can close this app now.');
}