// lib/presentation/pages/leave_request_form_page.dart
import 'package:flutter/material.dart';
import 'package:kinetic_solutions/core/auth/auth_service.dart';
import 'package:kinetic_solutions/core/theme/app_theme.dart';
import 'package:kinetic_solutions/data/datasources/local_database.dart';
import 'package:kinetic_solutions/domain/entities/leave_request.dart';
import 'package:kinetic_solutions/domain/entities/employee.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/app_user.dart';
import '../../presentation/widgets/shared_widgets.dart';

class LeaveRequestFormPage extends StatefulWidget {
  final AppUser currentUser;
  final LeaveRequest? request;
  const LeaveRequestFormPage({super.key, required this.currentUser, this.request});

  @override
  State<LeaveRequestFormPage> createState() => _LeaveRequestFormPageState();
}

class _LeaveRequestFormPageState extends State<LeaveRequestFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  LeaveType _type = LeaveType.annual;
  String? _employeeId;
  bool _isLoading = false;
  List<Employee> _employees = [];

  @override
  void initState() {
    super.initState();
    _loadEmployees();
    if (widget.request != null) {
      final r = widget.request!;
      _reasonController.text = r.reason;
      _startDateController.text = DateFormat('yyyy-MM-dd').format(r.startDate);
      _endDateController.text = DateFormat('yyyy-MM-dd').format(r.endDate);
      _type = r.type;
      _employeeId = r.employeeId;
    }
  }

  Future<void> _loadEmployees() async {
    _employees = LocalDatabase.getEmployees();
    setState(() {});
  }

  Future<void> _selectDate(TextEditingController controller) async {
    final initial = controller.text.isNotEmpty ? DateFormat('yyyy-MM-dd').parse(controller.text) : DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (date != null) controller.text = DateFormat('yyyy-MM-dd').format(date);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final request = LeaveRequest(
        id: widget.request?.id ?? LocalDatabase.generateId(),
        employeeId: _employeeId!,
        type: _type,
        startDate: DateFormat('yyyy-MM-dd').parse(_startDateController.text),
        endDate: DateFormat('yyyy-MM-dd').parse(_endDateController.text),
        days: _calculateDays(),
        reason: _reasonController.text.trim(),
        status: widget.request?.status ?? LeaveStatus.pending,
        approvedBy: widget.request?.approvedBy,
        approvedAt: widget.request?.approvedAt,
      );
      await LocalDatabase.saveLeaveRequest(request);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  int _calculateDays() {
    try {
      final start = DateFormat('yyyy-MM-dd').parse(_startDateController.text);
      final end = DateFormat('yyyy-MM-dd').parse(_endDateController.text);
      return end.difference(start).inDays + 1;
    } catch (_) {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.request != null;
    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Leave Request' : 'New Leave Request'),
        backgroundColor: AppTheme.infoColor,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              FormCard(
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      value: _employeeId,
                      decoration: const InputDecoration(labelText: 'Employee *', prefixIcon: Icon(Icons.person)),
                      items: _employees.map((e) => DropdownMenuItem(value: e.id, child: Text(e.fullName))).toList(),
                      validator: (v) => v == null ? 'Select employee' : null,
                      onChanged: (val) => setState(() => _employeeId = val),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<LeaveType>(
                      value: _type,
                      decoration: const InputDecoration(labelText: 'Leave Type *', prefixIcon: Icon(Icons.category)),
                      items: LeaveType.values.map((t) => DropdownMenuItem(value: t, child: Text(t.name))).toList(),
                      onChanged: (val) => setState(() => _type = val!),
                    ),
                    const SizedBox(height: 16),
                    _buildDatePicker('Start Date *', _startDateController),
                    const SizedBox(height: 16),
                    _buildDatePicker('End Date *', _endDateController),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _reasonController,
                      decoration: const InputDecoration(labelText: 'Reason *', prefixIcon: Icon(Icons.comment)),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _save,
                child: _isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Save Request'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDatePicker(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.calendar_today),
        suffixIcon: IconButton(icon: const Icon(Icons.date_range), onPressed: () => _selectDate(controller)),
      ),
      readOnly: true,
      onTap: () => _selectDate(controller),
      validator: (v) => v!.isEmpty ? 'Required' : null,
    );
  }
}
