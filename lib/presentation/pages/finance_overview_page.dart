import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/app_user.dart';

class FinanceOverviewPage extends StatelessWidget {
  final AppUser currentUser;
  const FinanceOverviewPage({super.key, required this.currentUser});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      appBar: AppBar(
        title: const Text('Finance Overview'),
        backgroundColor: AppTheme.infoColor,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text('Finance module coming soon…'),
      ),
    );
  }
}
