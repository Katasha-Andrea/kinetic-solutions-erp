import 'package:cloud_firestore/cloud_firestore.dart';
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

class FirestoreService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── Collection names ──
  static const String usersCollection = 'users';
  static const String inventoryCollection = 'inventory';
  static const String employeesCollection = 'employees';
  static const String customersCollection = 'customers';
  static const String projectsCollection = 'projects';
  static const String tasksCollection = 'tasks';
  static const String milestonesCollection = 'milestones';
  static const String suppliersCollection = 'suppliers';
  static const String vehiclesCollection = 'vehicles';
  static const String contractsCollection = 'contracts';
  static const String workOrdersCollection = 'workOrders';
  static const String expensesCollection = 'expenses';
  static const String assetsCollection = 'assets';
  static const String tendersCollection = 'tenders';
  static const String quotationsCollection = 'quotations';
  static const String attendanceCollection = 'attendance';
  static const String leaveRequestsCollection = 'leaveRequests';
  static const String approvalsCollection = 'approvals';
  static const String materialIssuesCollection = 'materialIssues';
  static const String purchaseOrdersCollection = 'purchaseOrders';
  static const String goodsReceivedCollection = 'goodsReceived';
  static const String documentsCollection = 'documents';
  static const String notificationsCollection = 'notifications';
  static const String siteDiaryCollection = 'siteDiary';
  static const String timesheetsCollection = 'timesheets';
  static const String invoicesCollection = 'invoices';
  static const String paymentsCollection = 'payments';
  static const String ppeIssuesCollection = 'ppeIssues';
  static const String fuelLogsCollection = 'fuelLogs';

  // =========================================================================
  // GENERIC HELPERS
  // =========================================================================
  static String generateId() => _db.collection('dummy').doc().id; // Firestore auto‑ID
  // Or you can keep using uuid and set doc(id) – we'll use Firestore auto‑ID.

  // =========================================================================
  // USERS
  // =========================================================================
  static Stream<List<AppUser>> getUsersStream() {
    return _db.collection(usersCollection).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return AppUser.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }
  static Future<void> saveUser(AppUser user) {
    return _db.collection(usersCollection).doc(user.id).set(user.toMap());
  }
  static Future<void> deleteUser(String id) {
    return _db.collection(usersCollection).doc(id).delete();
  }

  // =========================================================================
  // INVENTORY
  // =========================================================================
  static Stream<List<InventoryItem>> getInventoryStream() {
    return _db.collection(inventoryCollection).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return InventoryItem.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }
  static Future<void> saveInventoryItem(InventoryItem item) {
    return _db.collection(inventoryCollection).doc(item.id).set(item.toMap());
  }
  static Future<void> deleteInventoryItem(String id) {
    return _db.collection(inventoryCollection).doc(id).delete();
  }

  // =========================================================================
  // EMPLOYEES
  // =========================================================================
  static Stream<List<Employee>> getEmployeesStream() {
    return _db.collection(employeesCollection).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Employee.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }
  static Future<void> saveEmployee(Employee emp) {
    return _db.collection(employeesCollection).doc(emp.id).set(emp.toMap());
  }
  static Future<void> deleteEmployee(String id) {
    return _db.collection(employeesCollection).doc(id).delete();
  }

  // =========================================================================
  // CUSTOMERS
  // =========================================================================
  static Stream<List<Customer>> getCustomersStream() {
    return _db.collection(customersCollection).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Customer.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }
  static Future<void> saveCustomer(Customer c) {
    return _db.collection(customersCollection).doc(c.id).set(c.toMap());
  }
  static Future<void> deleteCustomer(String id) {
    return _db.collection(customersCollection).doc(id).delete();
  }

  // =========================================================================
  // PROJECTS
  // =========================================================================
  static Stream<List<Project>> getProjectsStream() {
    return _db.collection(projectsCollection).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Project.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }
  static Future<void> saveProject(Project p) {
    return _db.collection(projectsCollection).doc(p.id).set(p.toMap());
  }
  static Future<void> deleteProject(String id) {
    return _db.collection(projectsCollection).doc(id).delete();
  }

  // =========================================================================
  // TASKS
  // =========================================================================
  static Stream<List<Task>> getTasksStream() {
    return _db.collection(tasksCollection).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Task.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }
  static Stream<List<Task>> getTasksForProjectStream(String projectId) {
    return _db
        .collection(tasksCollection)
        .where('projectId', isEqualTo: projectId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Task.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }
  static Future<void> saveTask(Task t) {
    return _db.collection(tasksCollection).doc(t.id).set(t.toMap());
  }
  static Future<void> deleteTask(String id) {
    return _db.collection(tasksCollection).doc(id).delete();
  }

  // =========================================================================
  // MILESTONES
  // =========================================================================
  static Stream<List<Milestone>> getMilestonesStream() {
    return _db.collection(milestonesCollection).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Milestone.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }
  static Stream<List<Milestone>> getMilestonesForProjectStream(String projectId) {
    return _db
        .collection(milestonesCollection)
        .where('projectId', isEqualTo: projectId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Milestone.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }
  static Future<void> saveMilestone(Milestone m) {
    return _db.collection(milestonesCollection).doc(m.id).set(m.toMap());
  }
  static Future<void> deleteMilestone(String id) {
    return _db.collection(milestonesCollection).doc(id).delete();
  }

  // =========================================================================
  // SUPPLIERS
  // =========================================================================
  static Stream<List<Supplier>> getSuppliersStream() {
    return _db.collection(suppliersCollection).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Supplier.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }
  static Future<void> saveSupplier(Supplier s) {
    return _db.collection(suppliersCollection).doc(s.id).set(s.toMap());
  }
  static Future<void> deleteSupplier(String id) {
    return _db.collection(suppliersCollection).doc(id).delete();
  }

  // =========================================================================
  // VEHICLES
  // =========================================================================
  static Stream<List<Vehicle>> getVehiclesStream() {
    return _db.collection(vehiclesCollection).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Vehicle.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }
  static Future<void> saveVehicle(Vehicle v) {
    return _db.collection(vehiclesCollection).doc(v.id).set(v.toMap());
  }
  static Future<void> deleteVehicle(String id) {
    return _db.collection(vehiclesCollection).doc(id).delete();
  }

  // =========================================================================
  // CONTRACTS
  // =========================================================================
  static Stream<List<Contract>> getContractsStream() {
    return _db.collection(contractsCollection).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Contract.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }
  static Future<void> saveContract(Contract c) {
    return _db.collection(contractsCollection).doc(c.id).set(c.toMap());
  }
  static Future<void> deleteContract(String id) {
    return _db.collection(contractsCollection).doc(id).delete();
  }

  // =========================================================================
  // WORK ORDERS
  // =========================================================================
  static Stream<List<WorkOrder>> getWorkOrdersStream() {
    return _db.collection(workOrdersCollection).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return WorkOrder.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }
  static Stream<List<WorkOrder>> getWorkOrdersForProjectStream(String projectId) {
    return _db
        .collection(workOrdersCollection)
        .where('projectId', isEqualTo: projectId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return WorkOrder.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }
  static Future<void> saveWorkOrder(WorkOrder wo) {
    return _db.collection(workOrdersCollection).doc(wo.id).set(wo.toMap());
  }
  static Future<void> deleteWorkOrder(String id) {
    return _db.collection(workOrdersCollection).doc(id).delete();
  }

  // =========================================================================
  // EXPENSES
  // =========================================================================
  static Stream<List<Expense>> getExpensesStream() {
    return _db.collection(expensesCollection).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Expense.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }
  static Future<void> saveExpense(Expense e) {
    return _db.collection(expensesCollection).doc(e.id).set(e.toMap());
  }
  static Future<void> deleteExpense(String id) {
    return _db.collection(expensesCollection).doc(id).delete();
  }

  // =========================================================================
  // ASSETS
  // =========================================================================
  static Stream<List<Asset>> getAssetsStream() {
    return _db.collection(assetsCollection).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Asset.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }
  static Future<void> saveAsset(Asset a) {
    return _db.collection(assetsCollection).doc(a.id).set(a.toMap());
  }
  static Future<void> deleteAsset(String id) {
    return _db.collection(assetsCollection).doc(id).delete();
  }

  // =========================================================================
  // TENDERS
  // =========================================================================
  static Stream<List<Tender>> getTendersStream() {
    return _db.collection(tendersCollection).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Tender.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }
  static Future<void> saveTender(Tender t) {
    return _db.collection(tendersCollection).doc(t.id).set(t.toMap());
  }
  static Future<void> deleteTender(String id) {
    return _db.collection(tendersCollection).doc(id).delete();
  }

  // =========================================================================
  // QUOTATIONS
  // =========================================================================
  static Stream<List<Quotation>> getQuotationsStream() {
    return _db.collection(quotationsCollection).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Quotation.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }
  static Future<void> saveQuotation(Quotation q) {
    return _db.collection(quotationsCollection).doc(q.id).set(q.toMap());
  }
  static Future<void> deleteQuotation(String id) {
    return _db.collection(quotationsCollection).doc(id).delete();
  }

  // =========================================================================
  // ATTENDANCE
  // =========================================================================
  static Stream<List<Attendance>> getAttendancesStream() {
    return _db.collection(attendanceCollection).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Attendance.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }
  static Stream<List<Attendance>> getAttendancesForDateStream(DateTime date) {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    return _db
        .collection(attendanceCollection)
        .where('date', isGreaterThanOrEqualTo: start.toIso8601String())
        .where('date', isLessThan: end.toIso8601String())
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Attendance.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }
  static Future<void> saveAttendance(Attendance a) {
    return _db.collection(attendanceCollection).doc(a.id).set(a.toMap());
  }
  static Future<void> deleteAttendance(String id) {
    return _db.collection(attendanceCollection).doc(id).delete();
  }

  // =========================================================================
  // LEAVE REQUESTS
  // =========================================================================
  static Stream<List<LeaveRequest>> getLeaveRequestsStream() {
    return _db.collection(leaveRequestsCollection).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return LeaveRequest.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }
  static Stream<List<LeaveRequest>> getLeaveRequestsForEmployeeStream(String empId) {
    return _db
        .collection(leaveRequestsCollection)
        .where('employeeId', isEqualTo: empId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return LeaveRequest.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }
  static Future<void> saveLeaveRequest(LeaveRequest l) {
    return _db.collection(leaveRequestsCollection).doc(l.id).set(l.toMap());
  }
  static Future<void> deleteLeaveRequest(String id) {
    return _db.collection(leaveRequestsCollection).doc(id).delete();
  }

  // =========================================================================
  // APPROVALS
  // =========================================================================
  static Stream<List<Approval>> getApprovalsStream() {
    return _db.collection(approvalsCollection).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Approval.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }
  static Stream<List<Approval>> getApprovalsByStatusStream(ApprovalStatus status) {
    return _db
        .collection(approvalsCollection)
        .where('status', isEqualTo: status.name)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Approval.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }
  static Future<void> saveApproval(Approval a) {
    return _db.collection(approvalsCollection).doc(a.id).set(a.toMap());
  }
  static Future<void> deleteApproval(String id) {
    return _db.collection(approvalsCollection).doc(id).delete();
  }

  // =========================================================================
  // MATERIAL ISSUES
  // =========================================================================
  static Stream<List<MaterialIssue>> getMaterialIssuesStream() {
    return _db.collection(materialIssuesCollection).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return MaterialIssue.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }
  static Stream<List<MaterialIssue>> getMaterialIssuesForProjectStream(String projectId) {
    return _db
        .collection(materialIssuesCollection)
        .where('projectId', isEqualTo: projectId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return MaterialIssue.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }
  static Future<void> saveMaterialIssue(MaterialIssue m) {
    return _db.collection(materialIssuesCollection).doc(m.id).set(m.toMap());
  }
  static Future<void> deleteMaterialIssue(String id) {
    return _db.collection(materialIssuesCollection).doc(id).delete();
  }

  // =========================================================================
  // PURCHASE ORDERS
  // =========================================================================
  static Stream<List<PurchaseOrder>> getPurchaseOrdersStream() {
    return _db.collection(purchaseOrdersCollection).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return PurchaseOrder.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }
  static Future<void> savePurchaseOrder(PurchaseOrder po) {
    return _db.collection(purchaseOrdersCollection).doc(po.id).set(po.toMap());
  }
  static Future<void> deletePurchaseOrder(String id) {
    return _db.collection(purchaseOrdersCollection).doc(id).delete();
  }

  // =========================================================================
  // GOODS RECEIVED
  // =========================================================================
  static Stream<List<GoodsReceived>> getGoodsReceivedStream() {
    return _db.collection(goodsReceivedCollection).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return GoodsReceived.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }
  static Future<void> saveGoodsReceived(GoodsReceived grn) {
    return _db.collection(goodsReceivedCollection).doc(grn.id).set(grn.toMap());
  }
  static Future<void> deleteGoodsReceived(String id) {
    return _db.collection(goodsReceivedCollection).doc(id).delete();
  }

  // =========================================================================
  // DOCUMENTS
  // =========================================================================
  static Stream<List<AppDocument>> getDocumentsStream() {
    return _db.collection(documentsCollection).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return AppDocument.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }
  static Future<void> saveDocument(AppDocument d) {
    return _db.collection(documentsCollection).doc(d.id).set(d.toMap());
  }
  static Future<void> deleteDocument(String id) {
    return _db.collection(documentsCollection).doc(id).delete();
  }

  // =========================================================================
  // NOTIFICATIONS
  // =========================================================================
  static Stream<List<AppNotification>> getNotificationsStream() {
    return _db.collection(notificationsCollection).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return AppNotification.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }
  static Future<void> saveNotification(AppNotification n) {
    return _db.collection(notificationsCollection).doc(n.id).set(n.toMap());
  }
  static Future<void> deleteNotification(String id) {
    return _db.collection(notificationsCollection).doc(id).delete();
  }
  static Future<void> markNotificationRead(String id) async {
    await _db.collection(notificationsCollection).doc(id).update({'isRead': true});
  }

  // =========================================================================
  // SITE DIARY
  // =========================================================================
  static Stream<List<SiteDiary>> getSiteDiariesStream() {
    return _db.collection(siteDiaryCollection).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return SiteDiary.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }
  static Stream<List<SiteDiary>> getSiteDiariesForProjectStream(String projectId) {
    return _db
        .collection(siteDiaryCollection)
        .where('projectId', isEqualTo: projectId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return SiteDiary.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }
  static Future<void> saveSiteDiary(SiteDiary sd) {
    return _db.collection(siteDiaryCollection).doc(sd.id).set(sd.toMap());
  }
  static Future<void> deleteSiteDiary(String id) {
    return _db.collection(siteDiaryCollection).doc(id).delete();
  }

  // =========================================================================
  // TIMESHEETS
  // =========================================================================
  static Stream<List<Timesheet>> getTimesheetsStream() {
    return _db.collection(timesheetsCollection).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Timesheet.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }
  static Stream<List<Timesheet>> getTimesheetsForEmployeeStream(String empId) {
    return _db
        .collection(timesheetsCollection)
        .where('employeeId', isEqualTo: empId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Timesheet.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }
  static Future<void> saveTimesheet(Timesheet ts) {
    return _db.collection(timesheetsCollection).doc(ts.id).set(ts.toMap());
  }
  static Future<void> deleteTimesheet(String id) {
    return _db.collection(timesheetsCollection).doc(id).delete();
  }

  // =========================================================================
  // INVOICES
  // =========================================================================
  static Stream<List<Invoice>> getInvoicesStream() {
    return _db.collection(invoicesCollection).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Invoice.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }
  static Future<void> saveInvoice(Invoice inv) {
    return _db.collection(invoicesCollection).doc(inv.id).set(inv.toMap());
  }
  static Future<void> deleteInvoice(String id) {
    return _db.collection(invoicesCollection).doc(id).delete();
  }

  // =========================================================================
  // PAYMENTS
  // =========================================================================
  static Stream<List<Payment>> getPaymentsStream() {
    return _db.collection(paymentsCollection).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Payment.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }
  static Stream<List<Payment>> getPaymentsForInvoiceStream(String invoiceId) {
    return _db
        .collection(paymentsCollection)
        .where('invoiceId', isEqualTo: invoiceId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Payment.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }
  static Future<void> savePayment(Payment p) {
    return _db.collection(paymentsCollection).doc(p.id).set(p.toMap());
  }
  static Future<void> deletePayment(String id) {
    return _db.collection(paymentsCollection).doc(id).delete();
  }

  // =========================================================================
  // PPE ISSUES
  // =========================================================================
  static Stream<List<PPEIssue>> getPPEIssuesStream() {
    return _db.collection(ppeIssuesCollection).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return PPEIssue.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }
  static Stream<List<PPEIssue>> getPPEIssuesForEmployeeStream(String empId) {
    return _db
        .collection(ppeIssuesCollection)
        .where('employeeId', isEqualTo: empId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return PPEIssue.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }
  static Future<void> savePPEIssue(PPEIssue ppe) {
    return _db.collection(ppeIssuesCollection).doc(ppe.id).set(ppe.toMap());
  }
  static Future<void> deletePPEIssue(String id) {
    return _db.collection(ppeIssuesCollection).doc(id).delete();
  }

  // =========================================================================
  // FUEL LOGS
  // =========================================================================
  static Stream<List<FuelLog>> getFuelLogsStream() {
    return _db.collection(fuelLogsCollection).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return FuelLog.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }
  static Stream<List<FuelLog>> getFuelLogsForVehicleStream(String vehicleId) {
    return _db
        .collection(fuelLogsCollection)
        .where('vehicleId', isEqualTo: vehicleId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return FuelLog.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }
  static Future<void> saveFuelLog(FuelLog fl) {
    return _db.collection(fuelLogsCollection).doc(fl.id).set(fl.toMap());
  }
  static Future<void> deleteFuelLog(String id) {
    return _db.collection(fuelLogsCollection).doc(id).delete();
  }
}