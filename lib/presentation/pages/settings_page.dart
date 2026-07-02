import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../domain/entities/app_user.dart';
import 'login_page.dart';

class SettingsPage extends StatelessWidget {
  final AppUser currentUser;
  final VoidCallback onLogout;

  const SettingsPage({
    super.key,
    required this.currentUser,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Profile card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white.withOpacity(0.2),
                child: Text(
                  currentUser.initials,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(currentUser.fullName,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(currentUser.email,
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.85),
                            fontSize: 13)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        currentUser.role.label,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ]),
          ),
          const SizedBox(height: 20),

          // App info
          _Section(
            title: 'Application',
            items: [
              _SettingTile(
                icon: Icons.info_outline,
                label: 'App name',
                value: AppConstants.appName,
              ),
              _SettingTile(
                icon: Icons.tag,
                label: 'Version',
                value: AppConstants.appVersion,
              ),
              _SettingTile(
                icon: Icons.location_on_outlined,
                label: 'Location',
                value: AppConstants.appLocation,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Zambian compliance
          _Section(
            title: 'Zambian Compliance',
            items: [
              _SettingTile(
                icon: Icons.percent,
                label: 'VAT Rate',
                value: '${(AppConstants.vatRate * 100).toStringAsFixed(0)}% (ZRA standard)',
              ),
              _SettingTile(
                icon: Icons.account_balance_outlined,
                label: 'NAPSA Rate',
                value: '${(AppConstants.napsaRate * 100).toStringAsFixed(0)}% (ceiling: ${AppConstants.currencySymbol} ${AppConstants.napsaCeiling})',
              ),
              _SettingTile(
                icon: Icons.trending_up,
                label: 'PAYE Bands',
                value: '0% / 25% / 30% / 37.5%',
              ),
              _SettingTile(
                icon: Icons.attach_money,
                label: 'Currency',
                value: '${AppConstants.currency} (${AppConstants.currencySymbol})',
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Permissions
          _Section(
            title: 'Your permissions',
            items: [
              _PermTile('Manage inventory', currentUser.role.canEditInventory),
              _PermTile('Manage employees', currentUser.role.canEditEmployees),
              _PermTile('Manage finance',   currentUser.role.canEditFinance),
              _PermTile('Manage projects',  currentUser.role.canEditProjects),
              _PermTile('View reports',     currentUser.role.canViewReports),
              _PermTile('Manage users',     currentUser.role.canManageUsers),
            ],
          ),
          const SizedBox(height: 24),

          // Sign out
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                onLogout();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                  (_) => false,
                );
              },
              icon: const Icon(Icons.logout, color: AppTheme.errorColor),
              label: const Text('Sign out',
                  style: TextStyle(color: AppTheme.errorColor)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppTheme.errorColor),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 40),
        ]),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> items;
  const _Section({required this.title, required this.items});
  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textMuted,
                  letterSpacing: 0.5)),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.borderColor, width: 0.5),
            ),
            child: Column(
              children: items.asMap().entries.map((e) => Column(children: [
                e.value,
                if (e.key < items.length - 1)
                  const Divider(height: 1, indent: 48),
              ])).toList(),
            ),
          ),
        ],
      );
}

class _SettingTile extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _SettingTile(
      {required this.icon, required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(children: [
          Icon(icon, size: 18, color: AppTheme.textMuted),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label,
                style: const TextStyle(
                    fontSize: 14, color: AppTheme.textPrimary)),
          ),
          Text(value,
              style: const TextStyle(
                  fontSize: 13, color: AppTheme.textSecondary)),
        ]),
      );
}

class _PermTile extends StatelessWidget {
  final String label;
  final bool granted;
  const _PermTile(this.label, this.granted);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(children: [
          Icon(
            granted ? Icons.check_circle_outline : Icons.cancel_outlined,
            size: 18,
            color: granted ? AppTheme.primaryColor : AppTheme.errorColor,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label,
                style: const TextStyle(
                    fontSize: 14, color: AppTheme.textPrimary)),
          ),
          Text(
            granted ? 'Allowed' : 'Restricted',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: granted ? AppTheme.primaryColor : AppTheme.errorColor,
            ),
          ),
        ]),
      );
}
