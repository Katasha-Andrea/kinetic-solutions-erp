// lib/presentation/pages/attendance_page.dart
import 'package:flutter/material.dart';
import 'package:kinetic_solutions/core/auth/auth_service.dart';
import 'package:kinetic_solutions/core/theme/app_theme.dart';
import 'package:kinetic_solutions/data/datasources/local_database.dart';
import 'package:kinetic_solutions/domain/entities/attendance.dart';
import 'package:kinetic_solutions/domain/entities/employee.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/app_user.dart';

class AttendancePage extends StatefulWidget {
  final AppUser currentUser;
  const AttendancePage({super.key, required this.currentUser});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  List<Attendance> _attendances = [];
  List<Employee> _employees = [];
  bool _isLoading = true;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final atts = LocalDatabase.getAttendancesForDate(_selectedDate);
    final emps = LocalDatabase.getEmployees();
    setState(() {
      _attendances = atts;
      _employees = emps;
      _isLoading = false;
    });
  }

  Future<void> _clockIn(Employee employee) async {
    final existing = _attendances.firstWhere(
      (a) => a.employeeId == employee.id && a.clockOut == null,
      orElse: () => throw Exception("Not found"),
    );
    if (existing != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Already clocked in')),
      );
      return;
    }
    final now = DateTime.now();
    final isLate = now.hour >= 8 && now.minute > 0; // after 08:00
    final att = Attendance(
      id: LocalDatabase.generateId(),
      employeeId: employee.id,
      employeeName: employee.fullName,
      date: _selectedDate,
      clockIn: now,
      clockOut: null,
      hoursWorked: 0,
      isLate: isLate,
      status: isLate ? AttendanceStatus.late : AttendanceStatus.present,
    );
    await LocalDatabase.saveAttendance(att);
    await _loadData();
  }

  Future<void> _clockOut(Attendance att) async {
    final now = DateTime.now();
    final hours = now.difference(att.clockIn!).inHours.toDouble();
    final updated = Attendance(
      id: att.id,
      employeeId: att.employeeId,
      employeeName: att.employeeName,
      date: att.date,
      clockIn: att.clockIn,
      clockOut: now,
      hoursWorked: hours,
      isLate: att.isLate,
      status: att.status,
    );
    await LocalDatabase.saveAttendance(updated);
    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final todayStr = DateFormat('dd MMM yyyy').format(_selectedDate);
    final present = _attendances.where((a) => a.clockOut != null).length;
    final active = _employees.where((e) => e.status == EmploymentStatus.active).length;

    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      appBar: AppBar(
        title: const Text('Attendance'),
        backgroundColor: AppTheme.purpleColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
              );
              if (date != null) {
                setState(() {
                  _selectedDate = date;
                  _loadData();
                });
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildStat('Present', present, AppTheme.primary500),
                const SizedBox(width: 12),
                _buildStat('Active Staff', active, AppTheme.infoColor),
                const SizedBox(width: 12),
                _buildStat('Total', _attendances.length, AppTheme.purpleColor),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text('Date: $todayStr', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _employees.isEmpty
                    ? const Center(child: Text('No employees'))
                    : ListView.builder(
                        itemCount: _employees.length,
                        itemBuilder: (ctx, i) {
                          final emp = _employees[i];
                          final att = _attendances.firstWhere(
                            (a) => a.employeeId == emp.id,
                            orElse: () => throw Exception("Not found"),
                          );
                          final isClockedIn = att != null && att.clockOut == null;
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: AppTheme.primary50,
                                child: Text(emp.initials),
                              ),
                              title: Text(emp.fullName),
                              subtitle: Text(
                                att != null
                                    ? 'In: ${DateFormat('HH:mm').format(att.clockIn!)}${att.clockOut != null ? ' Out: ${DateFormat('HH:mm').format(att.clockOut!)} (${att.hoursWorked.toStringAsFixed(1)}h)' : ''}'
                                    : 'Not clocked in',
                              ),
                              trailing: att == null
                                  ? ElevatedButton(
                                      onPressed: () => _clockIn(emp),
                                      child: const Text('Clock In'),
                                    )
                                  : isClockedIn
                                      ? ElevatedButton(
                                          onPressed: () => _clockOut(att!),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppTheme.errorColor,
                                            foregroundColor: Colors.white,
                                          ),
                                          child: const Text('Clock Out'),
                                        )
                                      : const Icon(Icons.check_circle, color: AppTheme.primary500),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, int value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value.toString(), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color)),
            Text(label, style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
          ],
        ),
      ),
    );
  }
}
