import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../data/datasources/local_database.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/entities/employee.dart';
import '../../domain/entities/inventory_item.dart';
import '../../domain/entities/project.dart';

// ── All pages ──
import 'login_page.dart';
import 'inventory_list_page.dart';
import 'employee_list_page.dart';
import 'project_list_page.dart';
import 'inventory_form_page.dart';
import 'employee_form_page.dart';
import 'project_form_page.dart';
import 'stock_in_page.dart';
import 'stock_out_page.dart';
import 'reports_page.dart';
import 'customer_list_page.dart';
import 'settings_page.dart';
import 'finance_overview_page.dart';
import 'supplier_list_page.dart';
import 'fleet_list_page.dart';
import 'contract_list_page.dart';
import 'expense_list_page.dart';
import 'asset_list_page.dart';
import 'work_order_list_page.dart';
import 'tender_list_page.dart';
import 'purchase_order_page.dart';
import 'goods_received_page.dart';
import 'site_diary_page.dart';
import 'invoice_page.dart';
import 'quotation_page.dart';
import 'document_list_page.dart';
import 'notification_page.dart';
import 'timesheet_page.dart';
import 'hse_page.dart';
import 'project_costing_page.dart';
import 'bi_dashboard_page.dart';
import 'company_documents_page.dart';
import 'payment_page.dart';
import 'ppe_issue_page.dart';
import 'fuel_log_page.dart';
import 'material_issue_page.dart';
import 'approval_list_page.dart';
import 'leave_request_page.dart';
import 'attendance_page.dart';

// ============================================================================
// DASHBOARD PAGE — outer shell
// ============================================================================

class DashboardPage extends StatefulWidget {
  final AppUser currentUser;
  const DashboardPage({super.key, required this.currentUser});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;

  // ── All navigation items ──
  static const List<_NavDef> _navItems = [
    _NavDef(Icons.dashboard_outlined,    Icons.dashboard,    'Dashboard'),
    _NavDef(Icons.inventory_2_outlined,  Icons.inventory_2,  'Inventory'),
    _NavDef(Icons.people_outline,        Icons.people,       'Staff'),
    _NavDef(Icons.business_outlined,     Icons.business,     'Clients'),
    _NavDef(Icons.work_outline,          Icons.work,         'Projects'),
    _NavDef(Icons.receipt_long_outlined, Icons.receipt_long, 'Finance'),
    _NavDef(Icons.bar_chart_outlined,    Icons.bar_chart,    'Reports'),
    _NavDef(Icons.settings_outlined,     Icons.settings,     'Settings'),
    // ── Added modules ──
    _NavDef(Icons.store_outlined,        Icons.store,        'Suppliers'),
    _NavDef(Icons.directions_car_outlined, Icons.directions_car, 'Fleet'),
    _NavDef(Icons.description_outlined,  Icons.description,  'Contracts'),
    _NavDef(Icons.money_off_outlined,    Icons.money_off,    'Expenses'),
    _NavDef(Icons.inventory_2_outlined,  Icons.inventory_2,  'Assets'),
    _NavDef(Icons.assignment_outlined,   Icons.assignment,   'Work Orders'),
    _NavDef(Icons.gavel_outlined,        Icons.gavel,        'Tenders'),
    _NavDef(Icons.shopping_cart_outlined,Icons.shopping_cart,'Purchase Orders'),
    _NavDef(Icons.checklist_outlined,    Icons.checklist,    'Goods Received'),
    _NavDef(Icons.note_outlined,         Icons.note,         'Site Diary'),
    _NavDef(Icons.receipt_outlined,      Icons.receipt,      'Invoices'),
    _NavDef(Icons.description_outlined,  Icons.description,  'Quotations'),
    _NavDef(Icons.folder_outlined,       Icons.folder,       'Documents'),
    _NavDef(Icons.notifications_outlined,Icons.notifications,'Notifications'),
    _NavDef(Icons.timer_outlined,        Icons.timer,        'Timesheets'),
    _NavDef(Icons.health_and_safety_outlined, Icons.health_and_safety, 'HSE'),
    _NavDef(Icons.calculate_outlined,    Icons.calculate,    'Costing'),
    _NavDef(Icons.analytics_outlined,    Icons.analytics,    'BI Dashboard'),
    _NavDef(Icons.business_outlined,     Icons.business,     'Company Docs'),
    _NavDef(Icons.payment_outlined,      Icons.payment,      'Payments'),
    _NavDef(Icons.security_outlined,     Icons.security,     'PPE Issues'),
    _NavDef(Icons.local_gas_station_outlined, Icons.local_gas_station, 'Fuel Logs'),
    _NavDef(Icons.inventory_outlined,    Icons.inventory,    'Material Issues'),
    _NavDef(Icons.verified_outlined,     Icons.verified,     'Approvals'),
    _NavDef(Icons.beach_access_outlined, Icons.beach_access, 'Leave Requests'),
    _NavDef(Icons.event_note_outlined,   Icons.event_note,   'Attendance'),
  ];

  // ── Page builder ──
  Widget _buildPage(int index) {
    switch (index) {
      case 0: return _DashboardHome(
                currentUser: widget.currentUser,
                onNavigate: (i) => setState(() => _selectedIndex = i),
              );
      case 1: return InventoryListPage(currentUser: widget.currentUser);
      case 2: return EmployeeListPage(currentUser: widget.currentUser);
      case 3: return CustomerListPage(currentUser: widget.currentUser);
      case 4: return ProjectListPage(currentUser: widget.currentUser);
      case 5: return FinanceOverviewPage(currentUser: widget.currentUser);
      case 6: return ReportsPage(currentUser: widget.currentUser);
      case 7: return SettingsPage(currentUser: widget.currentUser, onLogout: _logout);
      case 8: return SupplierListPage(currentUser: widget.currentUser);
      case 9: return FleetListPage(currentUser: widget.currentUser);
      case 10: return ContractListPage(currentUser: widget.currentUser);
      case 11: return ExpenseListPage(currentUser: widget.currentUser);
      case 12: return AssetListPage(currentUser: widget.currentUser);
      case 13: return WorkOrderListPage(currentUser: widget.currentUser);
      case 14: return TenderListPage(currentUser: widget.currentUser);
      case 15: return PurchaseOrderPage(currentUser: widget.currentUser);
      case 16: return GoodsReceivedPage(currentUser: widget.currentUser);
      case 17: return SiteDiaryPage(currentUser: widget.currentUser);
      case 18: return InvoicePage(currentUser: widget.currentUser);
      case 19: return QuotationPage(currentUser: widget.currentUser);
      case 20: return DocumentListPage(currentUser: widget.currentUser);
      case 21: return NotificationPage(currentUser: widget.currentUser);
      case 22: return TimesheetPage(currentUser: widget.currentUser);
      case 23: return HSEPage(currentUser: widget.currentUser);
      case 24: return ProjectCostingPage(currentUser: widget.currentUser);
      case 25: return BIDashboardPage(currentUser: widget.currentUser);
      case 26: return CompanyDocumentsPage(currentUser: widget.currentUser);
      case 27: return PaymentPage(currentUser: widget.currentUser);
      case 28: return PPEIssuePage(currentUser: widget.currentUser);
      case 29: return FuelLogPage(currentUser: widget.currentUser);
      case 30: return MaterialIssuePage(currentUser: widget.currentUser);
      case 31: return ApprovalListPage(currentUser: widget.currentUser);
      case 32: return LeaveRequestPage(currentUser: widget.currentUser);
      case 33: return AttendancePage(currentUser: widget.currentUser);
      default: return _PlaceholderPage(label: _navItems[index].label);
    }
  }

  void _logout() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 900;
    return Scaffold(
      body: Row(
        children: [
          if (isWide)
            _Sidebar(
              items: _navItems,
              selectedIndex: _selectedIndex,
              currentUser: widget.currentUser,
              onSelect: (i) => setState(() => _selectedIndex = i),
              onLogout: _logout,
            ),
          Expanded(
            child: Column(
              children: [
                _Topbar(
                  title: _navItems[_selectedIndex].label,
                  currentUser: widget.currentUser,
                  showMenuIcon: !isWide,
                ),
                Expanded(child: _buildPage(_selectedIndex)),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: isWide
          ? null
          : _BottomNav(
              items: _navItems.take(5).toList(),
              selectedIndex: _selectedIndex,
              onSelect: (i) => setState(() => _selectedIndex = i),
            ),
    );
  }
}

// ============================================================================
// NAV DEFINITION
// ============================================================================

class _NavDef {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  const _NavDef(this.icon, this.selectedIcon, this.label);
}

// ============================================================================
// SIDEBAR
// ============================================================================

class _Sidebar extends StatelessWidget {
  final List<_NavDef> items;
  final int selectedIndex;
  final AppUser currentUser;
  final ValueChanged<int> onSelect;
  final VoidCallback onLogout;

  const _Sidebar({
    required this.items,
    required this.selectedIndex,
    required this.currentUser,
    required this.onSelect,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 224,
      color: AppTheme.surfaceColor,
      child: Column(
        children: [
          // Logo
          Container(
            padding: const EdgeInsets.fromLTRB(16, 22, 16, 16),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppTheme.borderColor, width: 0.5),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  // Replace with Image.asset('assets/images/logo.png') once logo is added
                  child: const Center(
                    child: Text(
                      'KSL',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Kinetic Solutions',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Limited',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Nav sections
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSection('MAIN',      const [0, 1, 2, 3, 4]),
                  _buildSection('FINANCE',   const [5, 6, 11, 18, 27, 19]),  // Finance, Reports, Expenses, Invoices, Payments, Quotations
                  _buildSection('INVENTORY',  const [8, 9, 12, 15, 16, 30]), // Suppliers, Fleet, Assets, POs, GRNs, Material Issues
                  _buildSection('PROJECTS',   const [13, 14, 17, 24]),       // Work Orders, Tenders, Site Diary, Costing
                  _buildSection('HR & SAFETY', const [21, 22, 23, 28, 32, 33]), // Notifications, Timesheets, HSE, PPE Issues, Leave, Attendance
                  _buildSection('DOCUMENTS',   const [20, 26, 29]),           // Documents, Company Docs, Fuel Logs
                  _buildSection('SYSTEM',      const [7, 25, 31]),            // Settings, BI Dashboard, Approvals
                  _buildSection('ANALYTICS',   const [19, 25]),               // Quotations (already above), BI Dashboard (already above) – skip duplicate? We'll just include BI once.
                ],
              ),
            ),
          ),

          // User footer (unchanged)
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: AppTheme.borderColor, width: 0.5),
              ),
            ),
            child: Column(
              children: [
                _SidebarTile(
                  icon: Icons.logout,
                  selectedIcon: Icons.logout,
                  label: 'Sign out',
                  isSelected: false,
                  onTap: onLogout,
                  overrideColor: AppTheme.errorColor,
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 15,
                        backgroundColor: AppTheme.primaryColor,
                        child: Text(
                          currentUser.initials,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              currentUser.fullName,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.textPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              currentUser.role.label,
                              style: const TextStyle(
                                fontSize: 10,
                                color: AppTheme.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primary50,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          currentUser.role.label,
                          style: const TextStyle(
                            fontSize: 9,
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String label, List<int> indices) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 14, 10, 4),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppTheme.textMuted,
              letterSpacing: 0.8,
            ),
          ),
        ),
        ...indices.map(
          (i) => _SidebarTile(
            icon: items[i].icon,
            selectedIcon: items[i].selectedIcon,
            label: items[i].label,
            isSelected: selectedIndex == i,
            onTap: () => onSelect(i),
          ),
        ),
      ],
    );
  }
}

class _SidebarTile extends StatelessWidget {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? overrideColor;

  const _SidebarTile({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.overrideColor,
  });

  @override
  Widget build(BuildContext context) {
    final Color fg = overrideColor ??
        (isSelected ? AppTheme.primaryColor : AppTheme.textSecondary);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary50 : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? selectedIcon : icon,
              size: 18,
              color: fg,
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: fg,
                fontWeight:
                    isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// TOPBAR (unchanged)
// ============================================================================

class _Topbar extends StatelessWidget {
  final String title;
  final AppUser currentUser;
  final bool showMenuIcon;

  const _Topbar({
    required this.title,
    required this.currentUser,
    required this.showMenuIcon,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 13),
      decoration: const BoxDecoration(
        color: AppTheme.surfaceColor,
        border: Border(
          bottom: BorderSide(color: AppTheme.borderColor, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          if (showMenuIcon) ...[
            const Icon(Icons.menu, size: 20, color: AppTheme.textSecondary),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  '${days[now.weekday - 1]}, ${now.day} '
                  '${months[now.month - 1]} ${now.year}'
                  '  ·  ${AppConstants.appLocation}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),
          _TopIconBtn(icon: Icons.search_outlined),
          const SizedBox(width: 6),
          _NotificationBtn(),
          const SizedBox(width: 6),
          _TopIconBtn(icon: Icons.help_outline),
        ],
      ),
    );
  }
}

class _TopIconBtn extends StatelessWidget {
  final IconData icon;
  const _TopIconBtn({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.borderColor, width: 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, size: 17, color: AppTheme.textSecondary),
    );
  }
}

class _NotificationBtn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            border: Border.all(color: AppTheme.borderColor, width: 0.5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.notifications_outlined,
            size: 17,
            color: AppTheme.textSecondary,
          ),
        ),
        Positioned(
          right: 7,
          top: 7,
          child: Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: AppTheme.errorColor,
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.surfaceColor, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// BOTTOM NAV (mobile / narrow) – unchanged, only first 5
// ============================================================================

class _BottomNav extends StatelessWidget {
  final List<_NavDef> items;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  const _BottomNav({
    required this.items,
    required this.selectedIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: selectedIndex < items.length ? selectedIndex : 0,
      onDestinationSelected: onSelect,
      height: 68,
      backgroundColor: AppTheme.surfaceColor,
      indicatorColor: AppTheme.primary50,
      destinations: items
          .map(
            (d) => NavigationDestination(
              icon: Icon(d.icon),
              selectedIcon:
                  Icon(d.selectedIcon, color: AppTheme.primaryColor),
              label: d.label,
            ),
          )
          .toList(),
    );
  }
}

// ============================================================================
// DASHBOARD HOME (the main content area)
// ============================================================================

class _DashboardHome extends StatefulWidget {
  final AppUser currentUser;
  final ValueChanged<int> onNavigate;

  const _DashboardHome({
    required this.currentUser,
    required this.onNavigate,
  });

  @override
  State<_DashboardHome> createState() => _DashboardHomeState();
}

class _DashboardHomeState extends State<_DashboardHome> {
  bool _loading = true;
  _DashData? _data;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final List<InventoryItem> items = LocalDatabase.getInventoryItems();
    final List<Employee> employees  = LocalDatabase.getEmployees();
    final List<Project> projects    = LocalDatabase.getProjects();
    final customers                 = LocalDatabase.getCustomers();

    setState(() {
      _data = _DashData(
        totalItems:     items.length,
        lowStock:       items.where((i) => i.needsReorder).length,
        stockValue:     items.fold(0.0, (s, i) => s + i.stockValue),
        activeStaff:    employees
            .where((e) => e.status == EmploymentStatus.active)
            .length,
        totalStaff:     employees.length,
        activeProjects: projects
            .where((p) => p.status == ProjectStatus.inProgress)
            .length,
        atRiskProjects: projects.where((p) => p.isAtRisk).length,
        totalClients:   customers.length,
        recentProjects: projects.take(4).toList(),
      );
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const _DashboardShimmer();

    final _DashData d = _data!;

    return RefreshIndicator(
      color: AppTheme.primaryColor,
      onRefresh: () async {
        setState(() => _loading = true);
        await _load();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome
            _WelcomeBanner(currentUser: widget.currentUser),
            const SizedBox(height: 20),

            // Alert
            if (d.lowStock > 0) ...[
              _LowStockAlert(
                count: d.lowStock,
                onTap: () => widget.onNavigate(1),
              ),
              const SizedBox(height: 16),
            ],

            // Stats
            _StatsGrid(data: d, onNavigate: widget.onNavigate),
            const SizedBox(height: 24),

            // Charts row
            const _SectionLabel('Revenue overview'),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 680) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: _RevenueChart(),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: _StockValueCard(
                          stockValue: d.stockValue,
                          totalItems: d.totalItems,
                        ),
                      ),
                    ],
                  );
                }
                return Column(
                  children: [
                    _RevenueChart(),
                    const SizedBox(height: 14),
                    _StockValueCard(
                      stockValue: d.stockValue,
                      totalItems: d.totalItems,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),

            // Projects + activity
            const _SectionLabel('Active projects & activity'),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 680) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _ProjectsList(
                          projects: d.recentProjects,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(child: _ActivityFeed()),
                    ],
                  );
                }
                return Column(
                  children: [
                    _ProjectsList(projects: d.recentProjects),
                    const SizedBox(height: 14),
                    _ActivityFeed(),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),

            // Quick actions (updated to include all modules)
            const _SectionLabel('Quick actions'),
            const SizedBox(height: 12),
            _QuickActions(currentUser: widget.currentUser),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

// ── Data holder ───────────────────────────────────────────────────────────────
class _DashData {
  final int totalItems;
  final int lowStock;
  final double stockValue;
  final int activeStaff;
  final int totalStaff;
  final int activeProjects;
  final int atRiskProjects;
  final int totalClients;
  final List<Project> recentProjects;

  const _DashData({
    required this.totalItems,
    required this.lowStock,
    required this.stockValue,
    required this.activeStaff,
    required this.totalStaff,
    required this.activeProjects,
    required this.atRiskProjects,
    required this.totalClients,
    required this.recentProjects,
  });
}

// ── Section label ─────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppTheme.textPrimary,
      ),
    );
  }
}

// ============================================================================
// WELCOME BANNER (unchanged)
// ============================================================================

class _WelcomeBanner extends StatelessWidget {
  final AppUser currentUser;
  const _WelcomeBanner({required this.currentUser});

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.white.withOpacity(0.2),
            child: Text(
              currentUser.initials,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$_greeting, ${currentUser.firstName}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Your business at a glance  ·  ${AppConstants.appLocation}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              currentUser.role.label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// LOW STOCK ALERT (unchanged)
// ============================================================================

class _LowStockAlert extends StatefulWidget {
  final int count;
  final VoidCallback onTap;
  const _LowStockAlert({required this.count, required this.onTap});

  @override
  State<_LowStockAlert> createState() => _LowStockAlertState();
}

class _LowStockAlertState extends State<_LowStockAlert> {
  bool _dismissed = false;

  @override
  Widget build(BuildContext context) {
    if (_dismissed) return const SizedBox.shrink();
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.warningLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.warningColor.withOpacity(0.35),
            width: 0.5,
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.warning_amber_outlined,
              color: AppTheme.warningColor,
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '${widget.count} item${widget.count > 1 ? 's are' : ' is'} '
                'below reorder level — tap to view',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppTheme.warningColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            GestureDetector(
              onTap: () => setState(() => _dismissed = true),
              child: const Icon(
                Icons.close,
                size: 16,
                color: AppTheme.warningColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// STATS GRID (unchanged)
// ============================================================================

class _StatsGrid extends StatelessWidget {
  final _DashData data;
  final ValueChanged<int> onNavigate;

  const _StatsGrid({required this.data, required this.onNavigate});

  String _fmtValue(double v) {
    if (v >= 1000000) return '${AppConstants.currencySymbol} ${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000)    return '${AppConstants.currencySymbol} ${(v / 1000).toStringAsFixed(0)}k';
    return '${AppConstants.currencySymbol} ${v.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    final List<_StatCardData> cards = [
      _StatCardData(
        label: 'Stock items',
        value: '${data.totalItems}',
        icon: Icons.inventory_2_outlined,
        color: AppTheme.primaryColor,
        bgColor: AppTheme.primary50,
        delta: '${data.lowStock} low stock',
        deltaOk: data.lowStock == 0,
        onTap: () => onNavigate(1),
      ),
      _StatCardData(
        label: 'Active staff',
        value: '${data.activeStaff}',
        icon: Icons.people_outline,
        color: AppTheme.infoColor,
        bgColor: AppTheme.infoLight,
        delta: '${data.totalStaff} total',
        deltaOk: true,
        onTap: () => onNavigate(2),
      ),
      _StatCardData(
        label: 'Active projects',
        value: '${data.activeProjects}',
        icon: Icons.work_outline,
        color: AppTheme.accentColor,
        bgColor: AppTheme.accentLight,
        delta: '${data.atRiskProjects} at risk',
        deltaOk: data.atRiskProjects == 0,
        onTap: () => onNavigate(4),
      ),
      _StatCardData(
        label: 'Clients',
        value: '${data.totalClients}',
        icon: Icons.business_outlined,
        color: AppTheme.purpleColor,
        bgColor: AppTheme.purpleLight,
        delta: '+3 this quarter',
        deltaOk: true,
        onTap: () => onNavigate(3),
      ),
      _StatCardData(
        label: 'Stock value',
        value: _fmtValue(data.stockValue),
        icon: Icons.monetization_on_outlined,
        color: AppTheme.primaryColor,
        bgColor: AppTheme.primary50,
        delta: 'current valuation',
        deltaOk: true,
        onTap: () => onNavigate(1),
      ),
      _StatCardData(
        label: 'Low stock items',
        value: '${data.lowStock}',
        icon: Icons.warning_amber_outlined,
        color: data.lowStock > 0 ? AppTheme.errorColor : AppTheme.primaryColor,
        bgColor: data.lowStock > 0 ? AppTheme.errorLight : AppTheme.primary50,
        delta: data.lowStock > 0 ? 'needs restocking' : 'all stocked',
        deltaOk: data.lowStock == 0,
        onTap: () => onNavigate(1),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final int cols = constraints.maxWidth > 600 ? 3 : 2;
        final double aspect = constraints.maxWidth > 600 ? 1.55 : 1.3;
        return GridView.count(
          crossAxisCount: cols,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: aspect,
          children: cards.map((c) => _StatCard(data: c)).toList(),
        );
      },
    );
  }
}

class _StatCardData {
  final String label;
  final String value;
  final String delta;
  final IconData icon;
  final Color color;
  final Color bgColor;
  final bool deltaOk;
  final VoidCallback onTap;

  const _StatCardData({
    required this.label,
    required this.value,
    required this.delta,
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.deltaOk,
    required this.onTap,
  });
}

class _StatCard extends StatelessWidget {
  final _StatCardData data;
  const _StatCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: data.onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.borderColor, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: data.bgColor,
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(data.icon, size: 18, color: data.color),
            ),
            const Spacer(),
            Text(
              data.value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: data.color,
                height: 1,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 3),
            Text(
              data.label,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(
                  data.deltaOk
                      ? Icons.trending_up_rounded
                      : Icons.warning_rounded,
                  size: 12,
                  color: data.deltaOk
                      ? AppTheme.primary700
                      : AppTheme.errorColor,
                ),
                const SizedBox(width: 3),
                Expanded(
                  child: Text(
                    data.delta,
                    style: TextStyle(
                      fontSize: 11,
                      color: data.deltaOk
                          ? AppTheme.primary700
                          : AppTheme.errorColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// REVENUE CHART (unchanged)
// ============================================================================

class _RevenueChart extends StatelessWidget {
  static const List<FlSpot> _spots = [
    FlSpot(0, 35),
    FlSpot(1, 42),
    FlSpot(2, 38),
    FlSpot(3, 48),
    FlSpot(4, 45),
    FlSpot(5, 52),
  ];
  static const List<String> _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderColor, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Monthly revenue',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'ZMW (thousands) · Jan–Jun 2025',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primary50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  '+12.5% YoY',
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 150,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 10,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: Colors.grey.shade100,
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, _) {
                        final int idx = value.toInt();
                        if (idx >= 0 && idx < _months.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              _months[idx],
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppTheme.textMuted,
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 36,
                      getTitlesWidget: (value, _) => Text(
                        '${value.toInt()}k',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: 5,
                minY: 0,
                maxY: 60,
                lineBarsData: [
                  LineChartBarData(
                    spots: _spots,
                    isCurved: true,
                    color: AppTheme.primaryColor,
                    barWidth: 2.5,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (_, __, ___, ____) =>
                          FlDotCirclePainter(
                        radius: 3,
                        color: AppTheme.primaryColor,
                        strokeWidth: 0,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primaryColor.withOpacity(0.12),
                          AppTheme.primaryColor.withOpacity(0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// STOCK VALUE CARD (unchanged)
// ============================================================================

class _StockValueCard extends StatelessWidget {
  final double stockValue;
  final int totalItems;

  const _StockValueCard({
    required this.stockValue,
    required this.totalItems,
  });

  String _fmt(double v) {
    if (v >= 1000000) {
      return '${AppConstants.currencySymbol} ${(v / 1000000).toStringAsFixed(2)}M';
    }
    if (v >= 1000) {
      return '${AppConstants.currencySymbol} ${(v / 1000).toStringAsFixed(1)}k';
    }
    return '${AppConstants.currencySymbol} ${v.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderColor, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Total stock value',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Current inventory valuation',
            style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
          ),
          const SizedBox(height: 20),
          Text(
            _fmt(stockValue),
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'across $totalItems SKUs',
            style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primary50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.inventory_2_outlined,
                  size: 16,
                  color: AppTheme.primaryColor,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Tap Inventory to manage stock',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// PROJECTS LIST (unchanged)
// ============================================================================

class _ProjectsList extends StatelessWidget {
  final List<Project> projects;
  const _ProjectsList({required this.projects});

  @override
  Widget build(BuildContext context) {
    final int atRiskCount = projects.where((p) => p.isAtRisk).length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderColor, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Active projects',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              if (atRiskCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.accentLight,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$atRiskCount at risk',
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppTheme.warningColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (projects.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: Text(
                  'No active projects',
                  style: TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 13,
                  ),
                ),
              ),
            )
          else
            ...projects.asMap().entries.map((entry) {
              final Project p = entry.value;
              final double util = p.budgetUtilization.clamp(0.0, 100.0);

              Color barColor     = AppTheme.primaryColor;
              Color statusColor  = AppTheme.primaryColor;
              Color statusBg     = AppTheme.primary50;
              String statusLabel = 'On track';

              if (p.isOverdue) {
                barColor    = AppTheme.errorColor;
                statusColor = AppTheme.errorColor;
                statusBg    = AppTheme.errorLight;
                statusLabel = 'Overdue';
              } else if (p.isAtRisk) {
                barColor    = AppTheme.accentColor;
                statusColor = AppTheme.warningColor;
                statusBg    = AppTheme.accentLight;
                statusLabel = 'At risk';
              }

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    p.name,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: AppTheme.textPrimary,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    '${p.category}  ·  ${p.clientName}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppTheme.textMuted,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: statusBg,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                statusLabel,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: statusColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(3),
                                child: LinearProgressIndicator(
                                  value: util / 100,
                                  minHeight: 5,
                                  backgroundColor: AppTheme.bgColor,
                                  color: barColor,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${util.toStringAsFixed(0)}%',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (entry.key < projects.length - 1)
                    Divider(height: 1, color: Colors.grey.shade100),
                ],
              );
            }),
        ],
      ),
    );
  }
}

// ============================================================================
// ACTIVITY FEED (unchanged)
// ============================================================================

class _ActivityFeed extends StatelessWidget {
  static const List<_ActivityItem> _items = [
    _ActivityItem(
      icon: Icons.assignment_outlined,
      color: AppTheme.infoColor,
      bgColor: AppTheme.infoLight,
      title: 'Work order updated',
      desc: 'Kasama line installation 65% complete',
      time: '2h ago',
    ),
    _ActivityItem(
      icon: Icons.local_shipping_outlined,
      color: AppTheme.primaryColor,
      bgColor: AppTheme.primary50,
      title: 'Fleet alert',
      desc: 'GRZ 1234 insurance expiring soon',
      time: '5h ago',
    ),
    _ActivityItem(
      icon: Icons.warning_amber_outlined,
      color: AppTheme.errorColor,
      bgColor: AppTheme.errorLight,
      title: 'Low stock alert',
      desc: 'Cooking Oil below reorder level',
      time: '1d ago',
    ),
    _ActivityItem(
      icon: Icons.handshake_outlined,
      color: AppTheme.accentColor,
      bgColor: AppTheme.accentLight,
      title: 'Contract milestone',
      desc: 'ZESCO framework — 31% utilised',
      time: '2d ago',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderColor, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent activity',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          ..._items.asMap().entries.map((entry) {
            final _ActivityItem a = entry.value;
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: a.bgColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(a.icon, size: 15, color: a.color),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              a.title,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.textPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              a.desc,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppTheme.textMuted,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Text(
                        a.time,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                if (entry.key < _items.length - 1)
                  Divider(height: 1, color: Colors.grey.shade100),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _ActivityItem {
  final IconData icon;
  final Color color;
  final Color bgColor;
  final String title;
  final String desc;
  final String time;

  const _ActivityItem({
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.title,
    required this.desc,
    required this.time,
  });
}

// ============================================================================
// QUICK ACTIONS — fully expanded with all modules
// ============================================================================

class _QuickActions extends StatelessWidget {
  final AppUser currentUser;
  const _QuickActions({required this.currentUser});

  @override
  Widget build(BuildContext context) {
    // Build the list of actions, but only show those the user has permission for.
    final List<_ActionItem> actions = [];

    // Always show if user has appropriate permissions (or all if no restrictions)
    // We'll include all, but you can gate them with permission checks.
    actions.addAll([
      _ActionItem(
        label: 'Inventory',
        icon: Icons.inventory_2_outlined,
        color: AppTheme.primaryColor,
        bgColor: AppTheme.primary50,
        page: InventoryListPage(currentUser: currentUser),
        index: 1,
      ),
      _ActionItem(
        label: 'Add Stock',
        icon: Icons.add_shopping_cart_outlined,
        color: AppTheme.primary700,
        bgColor: AppTheme.primary50,
        page: const InventoryFormPage(),
        index: 1,
      ),
      _ActionItem(
        label: 'Stock In',
        icon: Icons.add_business_outlined,
        color: AppTheme.primary700,
        bgColor: AppTheme.primary50,
        page: StockInPage(currentUser: currentUser),
        index: 1,
      ),
      _ActionItem(
        label: 'Stock Out',
        icon: Icons.remove_shopping_cart_outlined,
        color: AppTheme.errorColor,
        bgColor: AppTheme.errorLight,
        page: StockOutPage(currentUser: currentUser),
        index: 1,
      ),
      _ActionItem(
        label: 'Suppliers',
        icon: Icons.store_outlined,
        color: AppTheme.purpleColor,
        bgColor: AppTheme.purpleLight,
        page: SupplierListPage(currentUser: currentUser),
        index: 8,
      ),
      _ActionItem(
        label: 'Fleet',
        icon: Icons.directions_car_outlined,
        color: Colors.teal,
        bgColor: Colors.teal.shade50,
        page: FleetListPage(currentUser: currentUser),
        index: 9,
      ),
      _ActionItem(
        label: 'Staff',
        icon: Icons.people_outline,
        color: AppTheme.infoColor,
        bgColor: AppTheme.infoLight,
        page: EmployeeListPage(currentUser: currentUser),
        index: 2,
      ),
      _ActionItem(
        label: 'Add Staff',
        icon: Icons.person_add_outlined,
        color: AppTheme.accentColor,
        bgColor: AppTheme.accentLight,
        page: const EmployeeFormPage(),
        index: 2,
      ),
      _ActionItem(
        label: 'Clients',
        icon: Icons.business_outlined,
        color: AppTheme.purpleColor,
        bgColor: AppTheme.purpleLight,
        page: CustomerListPage(currentUser: currentUser),
        index: 3,
      ),
      _ActionItem(
        label: 'Projects',
        icon: Icons.work_outline,
        color: AppTheme.accentColor,
        bgColor: AppTheme.accentLight,
        page: ProjectListPage(currentUser: currentUser),
        index: 4,
      ),
      _ActionItem(
        label: 'New Project',
        icon: Icons.add_task_outlined,
        color: AppTheme.purpleColor,
        bgColor: AppTheme.purpleLight,
        page: const ProjectFormPage(),
        index: 4,
      ),
      _ActionItem(
        label: 'Work Orders',
        icon: Icons.assignment_outlined,
        color: AppTheme.infoColor,
        bgColor: AppTheme.infoLight,
        page: WorkOrderListPage(currentUser: currentUser),
        index: 13,
      ),
      _ActionItem(
        label: 'Tenders',
        icon: Icons.gavel_outlined,
        color: AppTheme.purpleColor,
        bgColor: AppTheme.purpleLight,
        page: TenderListPage(currentUser: currentUser),
        index: 14,
      ),
      _ActionItem(
        label: 'Contracts',
        icon: Icons.handshake_outlined,
        color: AppTheme.purpleColor,
        bgColor: AppTheme.purpleLight,
        page: ContractListPage(currentUser: currentUser),
        index: 10,
      ),
      _ActionItem(
        label: 'Purchase Orders',
        icon: Icons.shopping_cart_outlined,
        color: Colors.orange,
        bgColor: Colors.orange.shade50,
        page: PurchaseOrderPage(currentUser: currentUser),
        index: 15,
      ),
      _ActionItem(
        label: 'Goods Received',
        icon: Icons.checklist_outlined,
        color: Colors.teal,
        bgColor: Colors.teal.shade50,
        page: GoodsReceivedPage(currentUser: currentUser),
        index: 16,
      ),
      _ActionItem(
        label: 'Material Issues',
        icon: Icons.inventory_outlined,
        color: Colors.deepPurple,
        bgColor: Colors.deepPurple.shade50,
        page: MaterialIssuePage(currentUser: currentUser),
        index: 30,
      ),
      _ActionItem(
        label: 'Finance',
        icon: Icons.account_balance_outlined,
        color: AppTheme.infoColor,
        bgColor: AppTheme.infoLight,
        page: FinanceOverviewPage(currentUser: currentUser),
        index: 5,
      ),
      _ActionItem(
        label: 'Expenses',
        icon: Icons.money_off_outlined,
        color: AppTheme.infoColor,
        bgColor: AppTheme.infoLight,
        page: ExpenseListPage(currentUser: currentUser),
        index: 11,
      ),
      _ActionItem(
        label: 'Invoices',
        icon: Icons.receipt_outlined,
        color: Colors.green,
        bgColor: Colors.green.shade50,
        page: InvoicePage(currentUser: currentUser),
        index: 18,
      ),
      _ActionItem(
        label: 'Payments',
        icon: Icons.payment_outlined,
        color: Colors.green,
        bgColor: Colors.green.shade50,
        page: PaymentPage(currentUser: currentUser),
        index: 27,
      ),
      _ActionItem(
        label: 'Quotations',
        icon: Icons.description_outlined,
        color: Colors.indigo,
        bgColor: Colors.indigo.shade50,
        page: QuotationPage(currentUser: currentUser),
        index: 19,
      ),
      _ActionItem(
        label: 'Assets',
        icon: Icons.inventory_2_outlined,
        color: AppTheme.purpleColor,
        bgColor: AppTheme.purpleLight,
        page: AssetListPage(currentUser: currentUser),
        index: 12,
      ),
      _ActionItem(
        label: 'Documents',
        icon: Icons.folder_outlined,
        color: Colors.blue,
        bgColor: Colors.blue.shade50,
        page: DocumentListPage(currentUser: currentUser),
        index: 20,
      ),
      _ActionItem(
        label: 'Company Docs',
        icon: Icons.business_outlined,
        color: Colors.indigo,
        bgColor: Colors.indigo.shade50,
        page: CompanyDocumentsPage(currentUser: currentUser),
        index: 26,
      ),
      _ActionItem(
        label: 'Site Diary',
        icon: Icons.note_outlined,
        color: Colors.brown,
        bgColor: Colors.brown.shade50,
        page: SiteDiaryPage(currentUser: currentUser),
        index: 17,
      ),
      _ActionItem(
        label: 'Attendance',
        icon: Icons.event_note_outlined,
        color: AppTheme.purpleColor,
        bgColor: AppTheme.purpleLight,
        page: AttendancePage(currentUser: currentUser),
        index: 33,
      ),
      _ActionItem(
        label: 'Leave',
        icon: Icons.beach_access_outlined,
        color: AppTheme.infoColor,
        bgColor: AppTheme.infoLight,
        page: LeaveRequestPage(currentUser: currentUser),
        index: 32,
      ),
      _ActionItem(
        label: 'Timesheets',
        icon: Icons.timer_outlined,
        color: Colors.purple,
        bgColor: Colors.purple.shade50,
        page: TimesheetPage(currentUser: currentUser),
        index: 22,
      ),
      _ActionItem(
        label: 'HSE',
        icon: Icons.health_and_safety_outlined,
        color: Colors.red,
        bgColor: Colors.red.shade50,
        page: HSEPage(currentUser: currentUser),
        index: 23,
      ),
      _ActionItem(
        label: 'PPE Issues',
        icon: Icons.security_outlined,
        color: Colors.orange,
        bgColor: Colors.orange.shade50,
        page: PPEIssuePage(currentUser: currentUser),
        index: 28,
      ),
      _ActionItem(
        label: 'Fuel Logs',
        icon: Icons.local_gas_station_outlined,
        color: Colors.amber,
        bgColor: Colors.amber.shade50,
        page: FuelLogPage(currentUser: currentUser),
        index: 29,
      ),
      _ActionItem(
        label: 'Costing',
        icon: Icons.calculate_outlined,
        color: Colors.blue,
        bgColor: Colors.blue.shade50,
        page: ProjectCostingPage(currentUser: currentUser),
        index: 24,
      ),
      _ActionItem(
        label: 'BI Dashboard',
        icon: Icons.analytics_outlined,
        color: Colors.indigo,
        bgColor: Colors.indigo.shade50,
        page: BIDashboardPage(currentUser: currentUser),
        index: 25,
      ),
      _ActionItem(
        label: 'Approvals',
        icon: Icons.verified_outlined,
        color: AppTheme.accentColor,
        bgColor: AppTheme.accentLight,
        page: ApprovalListPage(currentUser: currentUser),
        index: 31,
      ),
      _ActionItem(
        label: 'Reports',
        icon: Icons.bar_chart_outlined,
        color: AppTheme.textSecondary,
        bgColor: AppTheme.bgColor,
        page: ReportsPage(currentUser: currentUser),
        index: 6,
      ),
      _ActionItem(
        label: 'Settings',
        icon: Icons.settings_outlined,
        color: AppTheme.textSecondary,
        bgColor: AppTheme.bgColor,
        page: SettingsPage(currentUser: currentUser, onLogout: () {}), // onLogout handled elsewhere
        index: 7,
      ),
    ]);

    // Limit to 20 actions to keep UI tidy (you can adjust)
    final displayed = actions.take(20).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderColor, width: 0.5),
      ),
      child: SizedBox(
        height: 86,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: displayed.length,
          separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemBuilder: (context, index) {
            final _ActionItem a = displayed[index];
            return GestureDetector(
              onTap: () {
                if (a.page != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => a.page!),
                  );
                }
              },
              child: Opacity(
                opacity: a.page != null ? 1.0 : 0.5,
                child: Container(
                  width: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppTheme.borderColor,
                      width: 0.5,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: a.bgColor,
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: Icon(a.icon, size: 18, color: a.color),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        a.label,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ActionItem {
  final String label;
  final IconData icon;
  final Color color;
  final Color bgColor;
  final Widget? page;
  final int index; // for navigation, but we use direct navigation for quick actions

  const _ActionItem({
    required this.label,
    required this.icon,
    required this.color,
    required this.bgColor,
    this.page,
    this.index = 0,
  });
}

// ============================================================================
// SHIMMER LOADING SKELETON (unchanged)
// ============================================================================

class _DashboardShimmer extends StatelessWidget {
  const _DashboardShimmer();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.grey.shade50,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ShimmerBox(height: 80, radius: 16),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.55,
              physics: const NeverScrollableScrollPhysics(),
              children: List.generate(
                6,
                (_) => _ShimmerBox(radius: 12),
              ),
            ),
            const SizedBox(height: 20),
            _ShimmerBox(height: 200, radius: 12),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(child: _ShimmerBox(height: 200, radius: 12)),
                const SizedBox(width: 14),
                Expanded(child: _ShimmerBox(height: 200, radius: 12)),
              ],
            ),
            const SizedBox(height: 14),
            _ShimmerBox(height: 100, radius: 12),
          ],
        ),
      ),
    );
  }
}

class _ShimmerBox extends StatelessWidget {
  final double? height;
  final double radius;
  const _ShimmerBox({this.height, this.radius = 8});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

// ============================================================================
// PLACEHOLDER — unbuilt pages
// ============================================================================

class _PlaceholderPage extends StatelessWidget {
  final String label;
  const _PlaceholderPage({required this.label});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.construction_outlined,
            size: 52,
            color: AppTheme.textMuted,
          ),
          const SizedBox(height: 14),
          Text(
            label,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'This module is coming soon',
            style: TextStyle(
              fontSize: 13,
              color: AppTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
