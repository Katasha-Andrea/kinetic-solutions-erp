// lib/data/services/supabase_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
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

class SupabaseService {
  static final SupabaseClient _client = Supabase.instance.client;

  // ── Helper: Real‑time stream ──
  static Stream<List<T>> _stream<T>(
    String table,
    T Function(Map<String, dynamic>) fromMap, {
    String? filterColumn,
    String? filterValue,
  }) {
    final streamBuilder = _client.from(table).stream(primaryKey: ['id']);
    if (filterColumn != null && filterValue != null) {
      // Apply filter and return directly
      return streamBuilder
          .eq(filterColumn, filterValue)
          .map((maps) => maps.map((map) => fromMap(map)).toList());
    }
    return streamBuilder.map((maps) => maps.map((map) => fromMap(map)).toList());
  }

  // ── Helper: Save (upsert) ──
  static Future<void> _save(String table, String id, Map<String, dynamic> data) {
    return _client.from(table).upsert({
      ...data,
      'id': id,
    });
  }

  // ── Helper: Delete ──
  static Future<void> _delete(String table, String id) {
    return _client.from(table).delete().eq('id', id);
  }

  // ── ============================================================
  // ── USERS ──
  // ── ============================================================
  static Stream<List<AppUser>> getUsersStream() =>
      _stream('users', (map) => AppUser.fromMap(map));
  static Future<void> saveUser(AppUser user) =>
      _save('users', user.id, user.toMap());
  static Future<void> deleteUser(String id) =>
      _delete('users', id);

  // ── ============================================================
  // ── INVENTORY ──
  // ── ============================================================
  static Stream<List<InventoryItem>> getInventoryStream() =>
      _stream('inventory', (map) => InventoryItem.fromMap(map));
  static Future<void> saveInventoryItem(InventoryItem item) =>
      _save('inventory', item.id, item.toMap());
  static Future<void> deleteInventoryItem(String id) =>
      _delete('inventory', id);

  // ── ============================================================
  // ── EMPLOYEES ──
  // ── ============================================================
  static Stream<List<Employee>> getEmployeesStream() =>
      _stream('employees', (map) => Employee.fromMap(map));
  static Future<void> saveEmployee(Employee emp) =>
      _save('employees', emp.id, emp.toMap());
  static Future<void> deleteEmployee(String id) =>
      _delete('employees', id);

  // ── ============================================================
  // ── CUSTOMERS ──
  // ── ============================================================
  static Stream<List<Customer>> getCustomersStream() =>
      _stream('customers', (map) => Customer.fromMap(map));
  static Future<void> saveCustomer(Customer c) =>
      _save('customers', c.id, c.toMap());
  static Future<void> deleteCustomer(String id) =>
      _delete('customers', id);

  // ── ============================================================
  // ── PROJECTS ──
  // ── ============================================================
  static Stream<List<Project>> getProjectsStream() =>
      _stream('projects', (map) => Project.fromMap(map));
  static Future<void> saveProject(Project p) =>
      _save('projects', p.id, p.toMap());
  static Future<void> deleteProject(String id) =>
      _delete('projects', id);

  // ── ============================================================
  // ── TASKS ──
  // ── ============================================================
  static Stream<List<Task>> getTasksStream() =>
      _stream('tasks', (map) => Task.fromMap(map));
  static Stream<List<Task>> getTasksForProjectStream(String projectId) =>
      _stream(
        'tasks',
        (map) => Task.fromMap(map),
        filterColumn: 'projectId',
        filterValue: projectId,
      );
  static Future<void> saveTask(Task t) =>
      _save('tasks', t.id, t.toMap());
  static Future<void> deleteTask(String id) =>
      _delete('tasks', id);

  // ── ============================================================
  // ── MILESTONES ──
  // ── ============================================================
  static Stream<List<Milestone>> getMilestonesStream() =>
      _stream('milestones', (map) => Milestone.fromMap(map));
  static Stream<List<Milestone>> getMilestonesForProjectStream(String projectId) =>
      _stream(
        'milestones',
        (map) => Milestone.fromMap(map),
        filterColumn: 'projectId',
        filterValue: projectId,
      );
  static Future<void> saveMilestone(Milestone m) =>
      _save('milestones', m.id, m.toMap());
  static Future<void> deleteMilestone(String id) =>
      _delete('milestones', id);

  // ── ============================================================
  // ── SUPPLIERS ──
  // ── ============================================================
  static Stream<List<Supplier>> getSuppliersStream() =>
      _stream('suppliers', (map) => Supplier.fromMap(map));
  static Future<void> saveSupplier(Supplier s) =>
      _save('suppliers', s.id, s.toMap());
  static Future<void> deleteSupplier(String id) =>
      _delete('suppliers', id);

  // ── ============================================================
  // ── VEHICLES ──
  // ── ============================================================
  static Stream<List<Vehicle>> getVehiclesStream() =>
      _stream('vehicles', (map) => Vehicle.fromMap(map));
  static Future<void> saveVehicle(Vehicle v) =>
      _save('vehicles', v.id, v.toMap());
  static Future<void> deleteVehicle(String id) =>
      _delete('vehicles', id);

  // ── ============================================================
  // ── CONTRACTS ──
  // ── ============================================================
  static Stream<List<Contract>> getContractsStream() =>
      _stream('contracts', (map) => Contract.fromMap(map));
  static Future<void> saveContract(Contract c) =>
      _save('contracts', c.id, c.toMap());
  static Future<void> deleteContract(String id) =>
      _delete('contracts', id);

  // ── ============================================================
  // ── WORK ORDERS ──
  // ── ============================================================
  static Stream<List<WorkOrder>> getWorkOrdersStream() =>
      _stream('workorders', (map) => WorkOrder.fromMap(map));
  static Stream<List<WorkOrder>> getWorkOrdersForProjectStream(String projectId) =>
      _stream(
        'workorders',
        (map) => WorkOrder.fromMap(map),
        filterColumn: 'projectId',
        filterValue: projectId,
      );
  static Future<void> saveWorkOrder(WorkOrder wo) =>
      _save('workorders', wo.id, wo.toMap());
  static Future<void> deleteWorkOrder(String id) =>
      _delete('workorders', id);

  // ── ============================================================
  // ── EXPENSES ──
  // ── ============================================================
  static Stream<List<Expense>> getExpensesStream() =>
      _stream('expenses', (map) => Expense.fromMap(map));
  static Future<void> saveExpense(Expense e) =>
      _save('expenses', e.id, e.toMap());
  static Future<void> deleteExpense(String id) =>
      _delete('expenses', id);

  // ── ============================================================
  // ── ASSETS ──
  // ── ============================================================
  static Stream<List<Asset>> getAssetsStream() =>
      _stream('assets', (map) => Asset.fromMap(map));
  static Future<void> saveAsset(Asset a) =>
      _save('assets', a.id, a.toMap());
  static Future<void> deleteAsset(String id) =>
      _delete('assets', id);

  // ── ============================================================
  // ── TENDERS ──
  // ── ============================================================
  static Stream<List<Tender>> getTendersStream() =>
      _stream('tenders', (map) => Tender.fromMap(map));
  static Future<void> saveTender(Tender t) =>
      _save('tenders', t.id, t.toMap());
  static Future<void> deleteTender(String id) =>
      _delete('tenders', id);

  // ── ============================================================
  // ── QUOTATIONS ──
  // ── ============================================================
  static Stream<List<Quotation>> getQuotationsStream() =>
      _stream('quotations', (map) => Quotation.fromMap(map));
  static Future<void> saveQuotation(Quotation q) =>
      _save('quotations', q.id, q.toMap());
  static Future<void> deleteQuotation(String id) =>
      _delete('quotations', id);

  // ── ============================================================
  // ── ATTENDANCE ──
  // ── ============================================================
  static Stream<List<Attendance>> getAttendancesStream() =>
      _stream('attendance', (map) => Attendance.fromMap(map));

  // ✅ FIXED: Filter after receiving the stream (no `gte`/`lt` on stream builder)
  static Stream<List<Attendance>> getAttendancesForDateStream(DateTime date) {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    return _client
        .from('attendance')
        .stream(primaryKey: ['id'])
        .map((maps) {
          return maps
              .map((map) => Attendance.fromMap(map))
              .where((att) => att.date.isAfter(start) && att.date.isBefore(end))
              .toList();
        });
  }

  static Future<void> saveAttendance(Attendance a) =>
      _save('attendance', a.id, a.toMap());
  static Future<void> deleteAttendance(String id) =>
      _delete('attendance', id);

  // ── ============================================================
  // ── LEAVE REQUESTS ──
  // ── ============================================================
  static Stream<List<LeaveRequest>> getLeaveRequestsStream() =>
      _stream('leaverequests', (map) => LeaveRequest.fromMap(map));
  static Stream<List<LeaveRequest>> getLeaveRequestsForEmployeeStream(String empId) =>
      _stream(
        'leaverequests',
        (map) => LeaveRequest.fromMap(map),
        filterColumn: 'employeeId',
        filterValue: empId,
      );
  static Future<void> saveLeaveRequest(LeaveRequest l) =>
      _save('leaverequests', l.id, l.toMap());
  static Future<void> deleteLeaveRequest(String id) =>
      _delete('leaverequests', id);

  // ── ============================================================
  // ── APPROVALS ──
  // ── ============================================================
  static Stream<List<Approval>> getApprovalsStream() =>
      _stream('approvals', (map) => Approval.fromMap(map));
  static Stream<List<Approval>> getApprovalsByStatusStream(ApprovalStatus status) =>
      _stream(
        'approvals',
        (map) => Approval.fromMap(map),
        filterColumn: 'status',
        filterValue: status.name,
      );
  static Future<void> saveApproval(Approval a) =>
      _save('approvals', a.id, a.toMap());
  static Future<void> deleteApproval(String id) =>
      _delete('approvals', id);

  // ── ============================================================
  // ── MATERIAL ISSUES ──
  // ── ============================================================
  static Stream<List<MaterialIssue>> getMaterialIssuesStream() =>
      _stream('materialissues', (map) => MaterialIssue.fromMap(map));
  static Stream<List<MaterialIssue>> getMaterialIssuesForProjectStream(String projectId) =>
      _stream(
        'materialissues',
        (map) => MaterialIssue.fromMap(map),
        filterColumn: 'projectId',
        filterValue: projectId,
      );
  static Future<void> saveMaterialIssue(MaterialIssue m) =>
      _save('materialissues', m.id, m.toMap());
  static Future<void> deleteMaterialIssue(String id) =>
      _delete('materialissues', id);

  // ── ============================================================
  // ── PURCHASE ORDERS ──
  // ── ============================================================
  static Stream<List<PurchaseOrder>> getPurchaseOrdersStream() =>
      _stream('purchaseorders', (map) => PurchaseOrder.fromMap(map));
  static Future<void> savePurchaseOrder(PurchaseOrder po) =>
      _save('purchaseorders', po.id, po.toMap());
  static Future<void> deletePurchaseOrder(String id) =>
      _delete('purchaseorders', id);

  // ── ============================================================
  // ── GOODS RECEIVED ──
  // ── ============================================================
  static Stream<List<GoodsReceived>> getGoodsReceivedStream() =>
      _stream('goodsreceived', (map) => GoodsReceived.fromMap(map));
  static Future<void> saveGoodsReceived(GoodsReceived grn) =>
      _save('goodsreceived', grn.id, grn.toMap());
  static Future<void> deleteGoodsReceived(String id) =>
      _delete('goodsreceived', id);

  // ── ============================================================
  // ── DOCUMENTS ──
  // ── ============================================================
  static Stream<List<AppDocument>> getDocumentsStream() =>
      _stream('documents', (map) => AppDocument.fromMap(map));
  static Future<void> saveDocument(AppDocument d) =>
      _save('documents', d.id, d.toMap());
  static Future<void> deleteDocument(String id) =>
      _delete('documents', id);

  // ── ============================================================
  // ── NOTIFICATIONS ──
  // ── ============================================================
  static Stream<List<AppNotification>> getNotificationsStream() =>
      _stream('notifications', (map) => AppNotification.fromMap(map));
  static Future<void> saveNotification(AppNotification n) =>
      _save('notifications', n.id, n.toMap());
  static Future<void> deleteNotification(String id) =>
      _delete('notifications', id);
  static Future<void> markNotificationRead(String id) async {
    await _client.from('notifications').update({'isRead': true}).eq('id', id);
  }

  // ── ============================================================
  // ── SITE DIARY ──
  // ── ============================================================
  static Stream<List<SiteDiary>> getSiteDiariesStream() =>
      _stream('sitediary', (map) => SiteDiary.fromMap(map));
  static Stream<List<SiteDiary>> getSiteDiariesForProjectStream(String projectId) =>
      _stream(
        'sitediary',
        (map) => SiteDiary.fromMap(map),
        filterColumn: 'projectId',
        filterValue: projectId,
      );
  static Future<void> saveSiteDiary(SiteDiary sd) =>
      _save('sitediary', sd.id, sd.toMap());
  static Future<void> deleteSiteDiary(String id) =>
      _delete('sitediary', id);

  // ── ============================================================
  // ── TIMESHEETS ──
  // ── ============================================================
  static Stream<List<Timesheet>> getTimesheetsStream() =>
      _stream('timesheets', (map) => Timesheet.fromMap(map));
  static Stream<List<Timesheet>> getTimesheetsForEmployeeStream(String empId) =>
      _stream(
        'timesheets',
        (map) => Timesheet.fromMap(map),
        filterColumn: 'employeeId',
        filterValue: empId,
      );
  static Future<void> saveTimesheet(Timesheet ts) =>
      _save('timesheets', ts.id, ts.toMap());
  static Future<void> deleteTimesheet(String id) =>
      _delete('timesheets', id);

  // ── ============================================================
  // ── INVOICES ──
  // ── ============================================================
  static Stream<List<Invoice>> getInvoicesStream() =>
      _stream('invoices', (map) => Invoice.fromMap(map));
  static Future<void> saveInvoice(Invoice inv) =>
      _save('invoices', inv.id, inv.toMap());
  static Future<void> deleteInvoice(String id) =>
      _delete('invoices', id);

  // ── ============================================================
  // ── PAYMENTS ──
  // ── ============================================================
  static Stream<List<Payment>> getPaymentsStream() =>
      _stream('payments', (map) => Payment.fromMap(map));
  static Stream<List<Payment>> getPaymentsForInvoiceStream(String invoiceId) =>
      _stream(
        'payments',
        (map) => Payment.fromMap(map),
        filterColumn: 'invoiceId',
        filterValue: invoiceId,
      );
  static Future<void> savePayment(Payment p) =>
      _save('payments', p.id, p.toMap());
  static Future<void> deletePayment(String id) =>
      _delete('payments', id);

  // ── ============================================================
  // ── PPE ISSUES ──
  // ── ============================================================
  static Stream<List<PPEIssue>> getPPEIssuesStream() =>
      _stream('ppeissues', (map) => PPEIssue.fromMap(map));
  static Stream<List<PPEIssue>> getPPEIssuesForEmployeeStream(String empId) =>
      _stream(
        'ppeissues',
        (map) => PPEIssue.fromMap(map),
        filterColumn: 'employeeId',
        filterValue: empId,
      );
  static Future<void> savePPEIssue(PPEIssue ppe) =>
      _save('ppeissues', ppe.id, ppe.toMap());
  static Future<void> deletePPEIssue(String id) =>
      _delete('ppeissues', id);

  // ── ============================================================
  // ── FUEL LOGS ──
  // ── ============================================================
  static Stream<List<FuelLog>> getFuelLogsStream() =>
      _stream('fuellogs', (map) => FuelLog.fromMap(map));
  static Stream<List<FuelLog>> getFuelLogsForVehicleStream(String vehicleId) =>
      _stream(
        'fuellogs',
        (map) => FuelLog.fromMap(map),
        filterColumn: 'vehicleId',
        filterValue: vehicleId,
      );
  static Future<void> saveFuelLog(FuelLog fl) =>
      _save('fuellogs', fl.id, fl.toMap());
  static Future<void> deleteFuelLog(String id) =>
      _delete('fuellogs', id);
}