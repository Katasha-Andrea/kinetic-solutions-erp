// lib/main.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kinetic_solutions/core/theme/app_theme.dart';
import 'package:kinetic_solutions/data/datasources/local_database.dart';
// import 'package:kinetic_solutions/data/services/sync_service.dart';
import 'package:kinetic_solutions/presentation/pages/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://qdgvhgbvjfoggvfeyrsc.supabase.co',
    anonKey: 'sb_publishable_m4PgcRpCF59uN_GYC_7qXw_OsO88oLP',
  );

  // Initialize Hive
  await LocalDatabase.init();

  // Start background sync (optional – you can also call this later)
  // // await SyncService.syncAll();

  runApp(const KineticSolutionsApp());
}

class KineticSolutionsApp extends StatelessWidget {
  const KineticSolutionsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kinetic Solutions ERP',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: const LoginPage(),
    );
  }
}