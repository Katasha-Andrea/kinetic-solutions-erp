// lib/utils/migration.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kinetic_solutions/data/datasources/local_database.dart';
import 'package:kinetic_solutions/domain/entities/app_user.dart';
import 'package:kinetic_solutions/domain/entities/inventory_item.dart';
import 'package:kinetic_solutions/domain/entities/employee.dart';
import 'package:kinetic_solutions/domain/entities/customer.dart';
import 'package:kinetic_solutions/domain/entities/project.dart';
import 'package:kinetic_solutions/domain/entities/task.dart';
import 'package:kinetic_solutions/domain/entities/milestone.dart';
import 'package:kinetic_solutions/domain/entities/supplier.dart';
import 'package:kinetic_solutions/domain/entities/vehicle.dart';
import 'package:kinetic_solutions/domain/entities/contract.dart';
import 'package:kinetic_solutions/domain/entities/work_order.dart';
import 'package:kinetic_solutions/domain/entities/expense.dart';
import 'package:kinetic_solutions/domain/entities/asset.dart';
import 'package:kinetic_solutions/domain/entities/tender.dart';
import 'package:kinetic_solutions/domain/entities/quotation.dart';
import 'package:kinetic_solutions/domain/entities/attendance.dart';
import 'package:kinetic_solutions/domain/entities/leave_request.dart';
import 'package:kinetic_solutions/domain/entities/approval.dart';
import 'package:kinetic_solutions/domain/entities/material_issue.dart';
import 'package:kinetic_solutions/domain/entities/purchase_order.dart';
import 'package:kinetic_solutions/domain/entities/goods_received.dart';
import 'package:kinetic_solutions/domain/entities/app_document.dart';
import 'package:kinetic_solutions/domain/entities/notification.dart';
import 'package:kinetic_solutions/domain/entities/site_diary.dart';
import 'package:kinetic_solutions/domain/entities/timesheet.dart';
import 'package:kinetic_solutions/domain/entities/invoice.dart';
import 'package:kinetic_solutions/domain/entities/payment.dart';
import 'package:kinetic_solutions/domain/entities/ppe_issue.dart';
import 'package:kinetic_solutions/domain/entities/fuel_log.dart';

class Migration {
  static final SupabaseClient _client = Supabase.instance.client;

  static Future<void> migrateAll() async {
    print('🚀 Starting migration from Hive to Supabase...\n');

    await _migrateCollection<AppUser>(
      boxName: 'Users',
      getter: LocalDatabase.getUsers,
      save: (user) => _client.from('users').upsert(user.toMap()),
      name: (user) => user.fullName,
    );

    await _migrateCollection<InventoryItem>(
      boxName: 'Inventory',
      getter: LocalDatabase.getInventoryItems,
      save: (item) => _client.from('inventory').upsert(item.toMap()),
      name: (item) => item.name,
    );

    await _migrateCollection<Employee>(
      boxName: 'Employees',
      getter: LocalDatabase.getEmployees,
      save: (emp) => _client.from('employees').upsert(emp.toMap()),
      name: (emp) => emp.fullName,
    );

    await _migrateCollection<Customer>(
      boxName: 'Customers',
      getter: LocalDatabase.getCustomers,
      save: (c) => _client.from('customers').upsert(c.toMap()),
      name: (c) => c.companyName,
    );

    await _migrateCollection<Project>(
      boxName: 'Projects',
      getter: LocalDatabase.getProjects,
      save: (p) => _client.from('projects').upsert(p.toMap()),
      name: (p) => p.name,
    );

    await _migrateCollection<Task>(
      boxName: 'Tasks',
      getter: LocalDatabase.getTasks,
      save: (t) => _client.from('tasks').upsert(t.toMap()),
      name: (t) => t.title,
    );

    await _migrateCollection<Milestone>(
      boxName: 'Milestones',
      getter: LocalDatabase.getMilestones,
      save: (m) => _client.from('milestones').upsert(m.toMap()),
      name: (m) => m.title,
    );

    await _migrateCollection<Supplier>(
      boxName: 'Suppliers',
      getter: LocalDatabase.getSuppliers,
      save: (s) => _client.from('suppliers').upsert(s.toMap()),
      name: (s) => s.companyName,
    );

    await _migrateCollection<Vehicle>(
      boxName: 'Vehicles',
      getter: LocalDatabase.getVehicles,
      save: (v) => _client.from('vehicles').upsert(v.toMap()),
      name: (v) => '${v.make} ${v.model} (${v.registrationNumber})',
    );

    await _migrateCollection<Contract>(
      boxName: 'Contracts',
      getter: LocalDatabase.getContracts,
      save: (c) => _client.from('contracts').upsert(c.toMap()),
      name: (c) => c.title,
    );

    await _migrateCollection<WorkOrder>(
      boxName: 'Work Orders',
      getter: LocalDatabase.getWorkOrders,
      save: (wo) => _client.from('workOrders').upsert(wo.toMap()),
      name: (wo) => wo.woNumber,
    );

    await _migrateCollection<Expense>(
      boxName: 'Expenses',
      getter: LocalDatabase.getExpenses,
      save: (e) => _client.from('expenses').upsert(e.toMap()),
      name: (e) => e.description,
    );

    await _migrateCollection<Asset>(
      boxName: 'Assets',
      getter: LocalDatabase.getAssets,
      save: (a) => _client.from('assets').upsert(a.toMap()),
      name: (a) => a.name,
    );

    await _migrateCollection<Tender>(
      boxName: 'Tenders',
      getter: LocalDatabase.getTenders,
      save: (t) => _client.from('tenders').upsert(t.toMap()),
      name: (t) => t.tenderNumber,
    );

    await _migrateCollection<Quotation>(
      boxName: 'Quotations',
      getter: LocalDatabase.getQuotations,
      save: (q) => _client.from('quotations').upsert(q.toMap()),
      name: (q) => q.quotationNumber,
    );

    await _migrateCollection<Attendance>(
      boxName: 'Attendance',
      getter: LocalDatabase.getAttendances,
      save: (a) => _client.from('attendance').upsert(a.toMap()),
      name: (a) => '${a.employeeName} - ${a.date.toIso8601String()}',
    );

    await _migrateCollection<LeaveRequest>(
      boxName: 'Leave Requests',
      getter: LocalDatabase.getLeaveRequests,
      save: (l) => _client.from('leaveRequests').upsert(l.toMap()),
      name: (l) => '${l.type.name} - ${l.startDate.toIso8601String()}',
    );

    await _migrateCollection<Approval>(
      boxName: 'Approvals',
      getter: LocalDatabase.getApprovals,
      save: (a) => _client.from('approvals').upsert(a.toMap()),
      name: (a) => a.title,
    );

    await _migrateCollection<MaterialIssue>(
      boxName: 'Material Issues',
      getter: LocalDatabase.getMaterialIssues,
      save: (m) => _client.from('materialIssues').upsert(m.toMap()),
      name: (m) => m.issueNumber,
    );

    await _migrateCollection<PurchaseOrder>(
      boxName: 'Purchase Orders',
      getter: LocalDatabase.getPurchaseOrders,
      save: (po) => _client.from('purchaseOrders').upsert(po.toMap()),
      name: (po) => po.poNumber,
    );

    await _migrateCollection<GoodsReceived>(
      boxName: 'Goods Received',
      getter: LocalDatabase.getGoodsReceived,
      save: (grn) => _client.from('goodsReceived').upsert(grn.toMap()),
      name: (grn) => grn.grnNumber,
    );

    await _migrateCollection<AppDocument>(
      boxName: 'Documents',
      getter: LocalDatabase.getDocuments,
      save: (d) => _client.from('documents').upsert(d.toMap()),
      name: (d) => d.title,
    );

    await _migrateCollection<AppNotification>(
      boxName: 'Notifications',
      getter: LocalDatabase.getNotifications,
      save: (n) => _client.from('notifications').upsert(n.toMap()),
      name: (n) => n.title,
    );

    await _migrateCollection<SiteDiary>(
      boxName: 'Site Diaries',
      getter: LocalDatabase.getSiteDiaries,
      save: (sd) => _client.from('siteDiary').upsert(sd.toMap()),
      name: (sd) => 'WO ${sd.woNumber} - ${sd.date.toIso8601String()}',
    );

    await _migrateCollection<Timesheet>(
      boxName: 'Timesheets',
      getter: LocalDatabase.getTimesheets,
      save: (ts) => _client.from('timesheets').upsert(ts.toMap()),
      name: (ts) => '${ts.employeeId} - ${ts.date.toIso8601String()}',
    );

    await _migrateCollection<Invoice>(
      boxName: 'Invoices',
      getter: LocalDatabase.getInvoices,
      save: (inv) => _client.from('invoices').upsert(inv.toMap()),
      name: (inv) => inv.invoiceNumber,
    );

    await _migrateCollection<Payment>(
      boxName: 'Payments',
      getter: LocalDatabase.getPayments,
      save: (p) => _client.from('payments').upsert(p.toMap()),
      name: (p) => 'Invoice ${p.invoiceId} - ${p.paymentDate.toIso8601String()}',
    );

    await _migrateCollection<PPEIssue>(
      boxName: 'PPE Issues',
      getter: LocalDatabase.getPPEIssues,
      save: (ppe) => _client.from('ppeIssues').upsert(ppe.toMap()),
      name: (ppe) => '${ppe.ppeType} - ${ppe.issueDate.toIso8601String()}',
    );

    await _migrateCollection<FuelLog>(
      boxName: 'Fuel Logs',
      getter: LocalDatabase.getFuelLogs,
      save: (fl) => _client.from('fuelLogs').upsert(fl.toMap()),
      name: (fl) => '${fl.vehicleId} - ${fl.date.toIso8601String()}',
    );

    print('\n✅ Migration complete!');
  }

  /// Generic migration helper – uses upsert to avoid duplicates.
  static Future<void> _migrateCollection<T>({
    required String boxName,
    required List<T> Function() getter,
    required Future<void> Function(T item) save,
    required String Function(T item) name,
  }) async {
    final items = getter();
    if (items.isEmpty) {
      print('⚠️  No items found in "$boxName" — skipping.');
      return;
    }
    print('📦 Migrating $boxName (${items.length} items)...');
    int migratedCount = 0;
    for (final item in items) {
      try {
        await save(item);
        migratedCount++;
        print('   ✅ Migrated: ${name(item)}');
      } catch (e) {
        print('   ❌ Failed: ${name(item)} – $e');
      }
    }
    print('   ✅ Migrated $migratedCount items to $boxName.');
  }
}