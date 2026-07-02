import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_constants.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/entities/inventory_item.dart';
import '../../domain/entities/employee.dart';
import '../../domain/entities/customer.dart';
import '../../domain/entities/project.dart';
import '../../domain/entities/task.dart';
import '../../domain/entities/milestone.dart';
import '../../domain/entities/supplier.dart';
import '../../domain/entities/vehicle.dart';
import '../../domain/entities/contract.dart';
import '../../domain/entities/work_order.dart';
import '../../domain/entities/expense.dart';
import '../../domain/entities/asset.dart';
import '../../domain/entities/tender.dart';
import '../../domain/entities/quotation.dart';
import '../../domain/entities/attendance.dart';
import '../../domain/entities/leave_request.dart';
import '../../domain/entities/approval.dart';
import '../../domain/entities/material_issue.dart';
import '../../domain/entities/purchase_order.dart';
import '../../domain/entities/goods_received.dart';
import '../../domain/entities/app_document.dart';
import '../../domain/entities/notification.dart';
import '../../domain/entities/site_diary.dart';
import '../../domain/entities/timesheet.dart';
import '../../domain/entities/invoice.dart';
import '../../domain/entities/payment.dart';
import '../../domain/entities/ppe_issue.dart';
import '../../domain/entities/fuel_log.dart';

class LocalDatabase {
  static const _uuid = Uuid();

  // ── All boxes ──
  static late final Box<Map> _usersBox;
  static late final Box<Map> _invBox;
  static late final Box<Map> _empBox;
  static late final Box<Map> _custBox;
  static late final Box<Map> _projBox;
  static late final Box<Map> _taskBox;
  static late final Box<Map> _milestoneBox;
  static late final Box<Map> _supplierBox;
  static late final Box<Map> _vehicleBox;
  static late final Box<Map> _contractBox;
  static late final Box<Map> _workOrderBox;
  static late final Box<Map> _expenseBox;
  static late final Box<Map> _assetBox;
  static late final Box<Map> _tenderBox;
  static late final Box<Map> _quotationBox;
  static late final Box<Map> _attendanceBox;
  static late final Box<Map> _leaveRequestBox;
  static late final Box<Map> _approvalBox;
  static late final Box<Map> _materialIssueBox;
  static late final Box<Map> _purchaseOrderBox;
  static late final Box<Map> _goodsReceivedBox;
  static late final Box<Map> _documentBox;
  static late final Box<Map> _notificationBox;
  static late final Box<Map> _siteDiaryBox;
  static late final Box<Map> _timesheetBox;
  static late final Box<Map> _invoiceBox;
  static late final Box<Map> _paymentBox;
  static late final Box<Map> _ppeIssueBox;
  static late final Box<Map> _fuelLogBox;

  static String generateId() => _uuid.v4();

  static String _simpleHash(String input) {
    int hash = 0;
    for (final ch in input.codeUnits) {
      hash = (hash << 5) - hash + ch;
      hash &= hash;
    }
    return hash.toString();
  }

  // ── Initialisation ────────────────────────────────────────────────────────
  static Future<void> init() async {
    await Hive.initFlutter();
    final futures = [
      Hive.openBox<Map>(AppConstants.usersBox).then((b) => _usersBox = b),
      Hive.openBox<Map>(AppConstants.inventoryBox).then((b) => _invBox = b),
      Hive.openBox<Map>(AppConstants.employeesBox).then((b) => _empBox = b),
      Hive.openBox<Map>(AppConstants.customersBox).then((b) => _custBox = b),
      Hive.openBox<Map>(AppConstants.projectsBox).then((b) => _projBox = b),
      Hive.openBox<Map>(AppConstants.tasksBox).then((b) => _taskBox = b),
      Hive.openBox<Map>(AppConstants.milestonesBox).then((b) => _milestoneBox = b),
      Hive.openBox<Map>(AppConstants.suppliersBox).then((b) => _supplierBox = b),
      Hive.openBox<Map>(AppConstants.vehiclesBox).then((b) => _vehicleBox = b),
      Hive.openBox<Map>(AppConstants.contractsBox).then((b) => _contractBox = b),
      Hive.openBox<Map>(AppConstants.workOrdersBox).then((b) => _workOrderBox = b),
      Hive.openBox<Map>(AppConstants.expensesBox).then((b) => _expenseBox = b),
      Hive.openBox<Map>(AppConstants.assetsBox).then((b) => _assetBox = b),
      Hive.openBox<Map>(AppConstants.tendersBox).then((b) => _tenderBox = b),
      Hive.openBox<Map>(AppConstants.quotationsBox).then((b) => _quotationBox = b),
      Hive.openBox<Map>(AppConstants.attendanceBox).then((b) => _attendanceBox = b),
      Hive.openBox<Map>(AppConstants.leaveRequestsBox).then((b) => _leaveRequestBox = b),
      Hive.openBox<Map>(AppConstants.approvalsBox).then((b) => _approvalBox = b),
      Hive.openBox<Map>(AppConstants.materialIssuesBox).then((b) => _materialIssueBox = b),
      Hive.openBox<Map>(AppConstants.purchaseOrdersBox).then((b) => _purchaseOrderBox = b),
      Hive.openBox<Map>(AppConstants.goodsReceivedBox).then((b) => _goodsReceivedBox = b),
      Hive.openBox<Map>(AppConstants.documentsBox).then((b) => _documentBox = b),
      Hive.openBox<Map>(AppConstants.notificationsBox).then((b) => _notificationBox = b),
      Hive.openBox<Map>(AppConstants.siteDiaryBox).then((b) => _siteDiaryBox = b),
      Hive.openBox<Map>(AppConstants.timesheetsBox).then((b) => _timesheetBox = b),
      Hive.openBox<Map>(AppConstants.invoicesBox).then((b) => _invoiceBox = b),
      Hive.openBox<Map>(AppConstants.paymentsBox).then((b) => _paymentBox = b),
      Hive.openBox<Map>(AppConstants.ppeIssuesBox).then((b) => _ppeIssueBox = b),
      Hive.openBox<Map>(AppConstants.fuelLogsBox).then((b) => _fuelLogBox = b),
    ];
    await Future.wait(futures);
    await _seedDefaultAdmin();
  }

  // ── Auth ──────────────────────────────────────────────────────────────────
  static Future<void> _seedDefaultAdmin() async {
    if (_usersBox.isEmpty) {
      final admin = AppUser(
        id: _uuid.v4(),
        firstName: 'System',
        lastName: 'Admin',
        email: 'admin@kineticsolutions.zm',
        passwordHash: _simpleHash('Admin@123'),
        role: UserRole.admin,
        createdAt: DateTime.now(),
      );
      await _usersBox.put(admin.id, admin.toMap());
    }
  }

  static AppUser? login(String email, String password) {
    final hash = _simpleHash(password);
    for (final raw in _usersBox.values) {
      final user = AppUser.fromMap(Map<String, dynamic>.from(raw));
      if (user.email.toLowerCase() == email.toLowerCase() &&
          user.passwordHash == hash && user.isActive) {
        return user;
      }
    }
    return null;
  }

  static List<AppUser> getUsers() =>
      _usersBox.values.map((r) => AppUser.fromMap(Map<String, dynamic>.from(r))).toList();
  static Future<void> saveUser(AppUser u) => _usersBox.put(u.id, u.toMap());
  static Future<void> deleteUser(String id) => _usersBox.delete(id);

  // ── Inventory ─────────────────────────────────────────────────────────────
  static List<InventoryItem> getInventoryItems() =>
      _invBox.values.map((r) => InventoryItem.fromMap(Map<String, dynamic>.from(r))).toList();
  static Future<void> saveInventoryItem(InventoryItem i) => _invBox.put(i.id, i.toMap());
  static Future<void> deleteInventoryItem(String id) => _invBox.delete(id);

  // ── Employees ─────────────────────────────────────────────────────────────
  static List<Employee> getEmployees() =>
      _empBox.values.map((r) => Employee.fromMap(Map<String, dynamic>.from(r))).toList();
  static Future<void> saveEmployee(Employee e) => _empBox.put(e.id, e.toMap());
  static Future<void> deleteEmployee(String id) => _empBox.delete(id);

  // ── Customers ─────────────────────────────────────────────────────────────
  static List<Customer> getCustomers() =>
      _custBox.values.map((r) => Customer.fromMap(Map<String, dynamic>.from(r))).toList();
  static Future<void> saveCustomer(Customer c) => _custBox.put(c.id, c.toMap());
  static Future<void> deleteCustomer(String id) => _custBox.delete(id);

  // ── Projects ──────────────────────────────────────────────────────────────
  static List<Project> getProjects() =>
      _projBox.values.map((r) => Project.fromMap(Map<String, dynamic>.from(r))).toList();
  static Future<void> saveProject(Project p) => _projBox.put(p.id, p.toMap());
  static Future<void> deleteProject(String id) => _projBox.delete(id);

  // ── Tasks ─────────────────────────────────────────────────────────────────
  static List<Task> getTasks() =>
      _taskBox.values.map((r) => Task.fromMap(Map<String, dynamic>.from(r))).toList();
  static List<Task> getTasksForProject(String projectId) =>
      getTasks().where((t) => t.projectId == projectId).toList();
  static Future<void> saveTask(Task t) => _taskBox.put(t.id, t.toMap());
  static Future<void> deleteTask(String id) => _taskBox.delete(id);

  // ── Milestones ────────────────────────────────────────────────────────────
  static List<Milestone> getMilestones() =>
      _milestoneBox.values.map((r) => Milestone.fromMap(Map<String, dynamic>.from(r))).toList();
  static List<Milestone> getMilestonesForProject(String projectId) =>
      getMilestones().where((m) => m.projectId == projectId).toList();
  static Future<void> saveMilestone(Milestone m) => _milestoneBox.put(m.id, m.toMap());
  static Future<void> deleteMilestone(String id) => _milestoneBox.delete(id);

  // ── Suppliers ─────────────────────────────────────────────────────────────
  static List<Supplier> getSuppliers() =>
      _supplierBox.values.map((r) => Supplier.fromMap(Map<String, dynamic>.from(r))).toList();
  static Future<void> saveSupplier(Supplier s) => _supplierBox.put(s.id, s.toMap());
  static Future<void> deleteSupplier(String id) => _supplierBox.delete(id);

  // ── Vehicles ──────────────────────────────────────────────────────────────
  static List<Vehicle> getVehicles() =>
      _vehicleBox.values.map((r) => Vehicle.fromMap(Map<String, dynamic>.from(r))).toList();
  static Future<void> saveVehicle(Vehicle v) => _vehicleBox.put(v.id, v.toMap());
  static Future<void> deleteVehicle(String id) => _vehicleBox.delete(id);

  // ── Contracts ─────────────────────────────────────────────────────────────
  static List<Contract> getContracts() =>
      _contractBox.values.map((r) => Contract.fromMap(Map<String, dynamic>.from(r))).toList();
  static Future<void> saveContract(Contract c) => _contractBox.put(c.id, c.toMap());
  static Future<void> deleteContract(String id) => _contractBox.delete(id);

  // ── Work Orders ───────────────────────────────────────────────────────────
  static List<WorkOrder> getWorkOrders() =>
      _workOrderBox.values.map((r) => WorkOrder.fromMap(Map<String, dynamic>.from(r))).toList();
  static List<WorkOrder> getWorkOrdersForProject(String projectId) =>
      getWorkOrders().where((wo) => wo.projectId == projectId).toList();
  static Future<void> saveWorkOrder(WorkOrder wo) => _workOrderBox.put(wo.id, wo.toMap());
  static Future<void> deleteWorkOrder(String id) => _workOrderBox.delete(id);

  // ── Expenses ──────────────────────────────────────────────────────────────
  static List<Expense> getExpenses() =>
      _expenseBox.values.map((r) => Expense.fromMap(Map<String, dynamic>.from(r))).toList();
  static Future<void> saveExpense(Expense e) => _expenseBox.put(e.id, e.toMap());
  static Future<void> deleteExpense(String id) => _expenseBox.delete(id);

  // ── Assets ────────────────────────────────────────────────────────────────
  static List<Asset> getAssets() =>
      _assetBox.values.map((r) => Asset.fromMap(Map<String, dynamic>.from(r))).toList();
  static Future<void> saveAsset(Asset a) => _assetBox.put(a.id, a.toMap());
  static Future<void> deleteAsset(String id) => _assetBox.delete(id);

  // ── Tenders ───────────────────────────────────────────────────────────────
  static List<Tender> getTenders() =>
      _tenderBox.values.map((r) => Tender.fromMap(Map<String, dynamic>.from(r))).toList();
  static Future<void> saveTender(Tender t) => _tenderBox.put(t.id, t.toMap());
  static Future<void> deleteTender(String id) => _tenderBox.delete(id);

  // ── Quotations ────────────────────────────────────────────────────────────
  static List<Quotation> getQuotations() =>
      _quotationBox.values.map((r) => Quotation.fromMap(Map<String, dynamic>.from(r))).toList();
  static Future<void> saveQuotation(Quotation q) => _quotationBox.put(q.id, q.toMap());
  static Future<void> deleteQuotation(String id) => _quotationBox.delete(id);

  // ── Attendance ────────────────────────────────────────────────────────────
  static List<Attendance> getAttendances() =>
      _attendanceBox.values.map((r) => Attendance.fromMap(Map<String, dynamic>.from(r))).toList();
  static List<Attendance> getAttendancesForDate(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    return getAttendances().where((a) =>
        a.date.year == d.year &&
        a.date.month == d.month &&
        a.date.day == d.day).toList();
  }
  static Future<void> saveAttendance(Attendance a) => _attendanceBox.put(a.id, a.toMap());
  static Future<void> deleteAttendance(String id) => _attendanceBox.delete(id);

  // ── Leave Requests ────────────────────────────────────────────────────────
  static List<LeaveRequest> getLeaveRequests() =>
      _leaveRequestBox.values.map((r) => LeaveRequest.fromMap(Map<String, dynamic>.from(r))).toList();
  static List<LeaveRequest> getLeaveRequestsForEmployee(String empId) =>
      getLeaveRequests().where((l) => l.employeeId == empId).toList();
  static Future<void> saveLeaveRequest(LeaveRequest l) => _leaveRequestBox.put(l.id, l.toMap());
  static Future<void> deleteLeaveRequest(String id) => _leaveRequestBox.delete(id);

  // ── Approvals ─────────────────────────────────────────────────────────────
  static List<Approval> getApprovals() =>
      _approvalBox.values.map((r) => Approval.fromMap(Map<String, dynamic>.from(r))).toList();
  static List<Approval> getApprovalsByStatus(ApprovalStatus status) =>
      getApprovals().where((a) => a.status == status).toList();
  static Future<void> saveApproval(Approval a) => _approvalBox.put(a.id, a.toMap());
  static Future<void> deleteApproval(String id) => _approvalBox.delete(id);

  // ── Material Issues ──────────────────────────────────────────────────────
  static List<MaterialIssue> getMaterialIssues() =>
      _materialIssueBox.values.map((r) => MaterialIssue.fromMap(Map<String, dynamic>.from(r))).toList();
  static List<MaterialIssue> getMaterialIssuesForProject(String projectId) =>
      getMaterialIssues().where((m) => m.projectId == projectId).toList();
  static Future<void> saveMaterialIssue(MaterialIssue m) => _materialIssueBox.put(m.id, m.toMap());
  static Future<void> deleteMaterialIssue(String id) => _materialIssueBox.delete(id);

  // ── Purchase Orders ──────────────────────────────────────────────────────
  static List<PurchaseOrder> getPurchaseOrders() =>
      _purchaseOrderBox.values.map((r) => PurchaseOrder.fromMap(Map<String, dynamic>.from(r))).toList();
  static Future<void> savePurchaseOrder(PurchaseOrder po) => _purchaseOrderBox.put(po.id, po.toMap());
  static Future<void> deletePurchaseOrder(String id) => _purchaseOrderBox.delete(id);

  // ── Goods Received ───────────────────────────────────────────────────────
  static List<GoodsReceived> getGoodsReceived() =>
      _goodsReceivedBox.values.map((r) => GoodsReceived.fromMap(Map<String, dynamic>.from(r))).toList();
  static Future<void> saveGoodsReceived(GoodsReceived grn) => _goodsReceivedBox.put(grn.id, grn.toMap());
  static Future<void> deleteGoodsReceived(String id) => _goodsReceivedBox.delete(id);

  // ── Documents ─────────────────────────────────────────────────────────────
  static List<AppDocument> getDocuments() =>
      _documentBox.values.map((r) => AppDocument.fromMap(Map<String, dynamic>.from(r))).toList();
  static Future<void> saveDocument(AppDocument d) => _documentBox.put(d.id, d.toMap());
  static Future<void> deleteDocument(String id) => _documentBox.delete(id);

  // ── Notifications ─────────────────────────────────────────────────────────
  static List<AppNotification> getNotifications() =>
      _notificationBox.values.map((r) => AppNotification.fromMap(Map<String, dynamic>.from(r))).toList();
  static Future<void> saveNotification(AppNotification n) => _notificationBox.put(n.id, n.toMap());
  static Future<void> deleteNotification(String id) => _notificationBox.delete(id);
  static Future<void> markNotificationRead(String id) async {
    final n = getNotifications().firstWhere((e) => e.id == id);
    final updated = AppNotification(
      id: n.id,
      title: n.title,
      message: n.message,
      type: n.type,
      isRead: true,
      createdAt: n.createdAt,
    );
    await saveNotification(updated);
  }

  // ── Site Diary ────────────────────────────────────────────────────────────
  static List<SiteDiary> getSiteDiaries() =>
      _siteDiaryBox.values.map((r) => SiteDiary.fromMap(Map<String, dynamic>.from(r))).toList();
  static List<SiteDiary> getSiteDiariesForProject(String projectId) =>
      getSiteDiaries().where((s) => s.projectId == projectId).toList();
  static Future<void> saveSiteDiary(SiteDiary sd) => _siteDiaryBox.put(sd.id, sd.toMap());
  static Future<void> deleteSiteDiary(String id) => _siteDiaryBox.delete(id);

  // ── Timesheets ────────────────────────────────────────────────────────────
  static List<Timesheet> getTimesheets() =>
      _timesheetBox.values.map((r) => Timesheet.fromMap(Map<String, dynamic>.from(r))).toList();
  static List<Timesheet> getTimesheetsForEmployee(String empId) =>
      getTimesheets().where((t) => t.employeeId == empId).toList();
  static Future<void> saveTimesheet(Timesheet ts) => _timesheetBox.put(ts.id, ts.toMap());
  static Future<void> deleteTimesheet(String id) => _timesheetBox.delete(id);

  // ── Invoices ──────────────────────────────────────────────────────────────
  static List<Invoice> getInvoices() =>
      _invoiceBox.values.map((r) => Invoice.fromMap(Map<String, dynamic>.from(r))).toList();
  static Future<void> saveInvoice(Invoice inv) => _invoiceBox.put(inv.id, inv.toMap());
  static Future<void> deleteInvoice(String id) => _invoiceBox.delete(id);

  // ── Payments ──────────────────────────────────────────────────────────────
  static List<Payment> getPayments() =>
      _paymentBox.values.map((r) => Payment.fromMap(Map<String, dynamic>.from(r))).toList();
  static List<Payment> getPaymentsForInvoice(String invoiceId) =>
      getPayments().where((p) => p.invoiceId == invoiceId).toList();
  static Future<void> savePayment(Payment p) => _paymentBox.put(p.id, p.toMap());
  static Future<void> deletePayment(String id) => _paymentBox.delete(id);

  // ── PPE Issues ────────────────────────────────────────────────────────────
  static List<PPEIssue> getPPEIssues() =>
      _ppeIssueBox.values.map((r) => PPEIssue.fromMap(Map<String, dynamic>.from(r))).toList();
  static List<PPEIssue> getPPEIssuesForEmployee(String empId) =>
      getPPEIssues().where((p) => p.employeeId == empId).toList();
  static Future<void> savePPEIssue(PPEIssue ppe) => _ppeIssueBox.put(ppe.id, ppe.toMap());
  static Future<void> deletePPEIssue(String id) => _ppeIssueBox.delete(id);

  // ── Fuel Logs ─────────────────────────────────────────────────────────────
  static List<FuelLog> getFuelLogs() =>
      _fuelLogBox.values.map((r) => FuelLog.fromMap(Map<String, dynamic>.from(r))).toList();
  static List<FuelLog> getFuelLogsForVehicle(String vehicleId) =>
      getFuelLogs().where((f) => f.vehicleId == vehicleId).toList();
  static Future<void> saveFuelLog(FuelLog fl) => _fuelLogBox.put(fl.id, fl.toMap());
  static Future<void> deleteFuelLog(String id) => _fuelLogBox.delete(id);
}