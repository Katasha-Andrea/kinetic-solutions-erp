import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'data/datasources/local_database.dart';
import 'presentation/pages/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalDatabase.init();
  runApp(const KineticSolutionsApp());
}

class KineticSolutionsApp extends StatelessWidget {
  const KineticSolutionsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kinetic Solutions Limited',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const LoginPage(),
    );
  }
}