class AppConstants {
  // App Identity
  static const String appName      = 'Kinetic Solutions Limited';
  static const String appShortName = 'KSL';
  static const String appVersion   = '1.0.0';
  static const String appLocation  = 'Lusaka, Zambia';

  // Zambian Compliance
  static const double vatRate        = 0.16;
  static const String currency       = 'ZMW';
  static const String currencySymbol = 'K';

  // NAPSA
  static const double napsaRate    = 0.05;
  static const double napsaCeiling = 1164.40;

  // NHIMA (added for completeness – ensure you have this)
  static const double nhimaRate    = 0.01;  // 1%

  // PAYE Tax Bands (annual ZMW)
  static const double payeBand1Max = 57600;
  static const double payeBand2Max = 81600;
  static const double payeBand3Max = 111600;
  static const double payeRate2    = 0.25;
  static const double payeRate3    = 0.30;
  static const double payeRate4    = 0.375;

  // ── Hive Box Names (28 boxes) ──
  static const String usersBox          = 'users';
  static const String inventoryBox      = 'inventory';
  static const String employeesBox      = 'employees';
  static const String customersBox      = 'customers';
  static const String projectsBox       = 'projects';
  static const String tasksBox          = 'tasks';
  static const String milestonesBox     = 'milestones';
  static const String suppliersBox      = 'suppliers';
  static const String vehiclesBox       = 'vehicles';
  static const String contractsBox      = 'contracts';
  static const String workOrdersBox     = 'workOrders';
  static const String expensesBox       = 'expenses';
  static const String assetsBox         = 'assets';
  static const String tendersBox        = 'tenders';
  static const String quotationsBox     = 'quotations';
  static const String attendanceBox     = 'attendance';
  static const String leaveRequestsBox  = 'leaveRequests';
  static const String approvalsBox      = 'approvals';
  static const String materialIssuesBox = 'materialIssues';
  static const String purchaseOrdersBox = 'purchaseOrders';
  static const String goodsReceivedBox  = 'goodsReceived';
  static const String documentsBox      = 'documents';
  static const String notificationsBox  = 'notifications';
  static const String siteDiaryBox      = 'siteDiary';
  static const String timesheetsBox     = 'timesheets';
  static const String invoicesBox       = 'invoices';
  static const String paymentsBox       = 'payments';
  static const String ppeIssuesBox      = 'ppeIssues';
  static const String fuelLogsBox       = 'fuelLogs';

  // ── User Roles ──
  static const String roleAdmin   = 'Admin';
  static const String roleManager = 'Manager';
  static const String roleStaff   = 'Staff';
  static const String roleFinance = 'Finance';
  static const String roleViewer  = 'Viewer';
}