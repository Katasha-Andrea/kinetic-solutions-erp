// lib/presentation/pages/timesheet_form_page.dart
import 'package:flutter/material.dart';
import 'package:kinetic_solutions/core/auth/auth_service.dart';
import 'package:kinetic_solutions/core/theme/app_theme.dart';
import 'package:kinetic_solutions/data/datasources/local_database.dart';
import 'package:kinetic_solutions/domain/entities/timesheet.dart';
import 'package:kinetic_solutions/domain/entities/employee.dart';
import 'package:kinetic_solutions/domain/entities/project.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/app_user.dart';
import '../../presentation/widgets/shared_widgets.dart';
class TimesheetFormPage extends StatefulWidget {
  final AppUser currentUser;
  final Timesheet? timesheet;

  const TimesheetFormPage({super.key, required this.currentUser, this.timesheet});

  @override
  State<TimesheetFormPage> createState() => _TimesheetFormPageState();
}

class _TimesheetFormPageState extends State<TimesheetFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController();
  final _hoursController = TextEditingController();
  final _taskController = TextEditingController();

  String? _employeeId;
  String? _projectId;
  bool _isLoading = false;
  List<Employee> _employees = [];
  List<Project> _projects = [];

  @override
  void initState() {
    super.initState();
    _loadData();
    if (widget.timesheet != null) {
      final t = widget.timesheet!;
      _dateController.text = DateFormat('yyyy-MM-dd').format(t.date);
      _hoursController.text = t.hours.toString();
      _taskController.text = t.task;
      _employeeId = t.employeeId;
      _projectId = t.projectId;
    }
  }

  Future<void> _loadData() async {
    final emps = LocalDatabase.getEmployees();
    final projs = LocalDatabase.getProjects();
    setState(() {
      _employees = emps;
      _projects = projs;
    });
  }

  @override
  void dispose() {
    _dateController.dispose();
    _hoursController.dispose();
    _taskController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final initial = _dateController.text.isNotEmpty
        ? DateFormat('yyyy-MM-dd').parse(_dateController.text)
        : DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (date != null) {
      _dateController.text = DateFormat('yyyy-MM-dd').format(date);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_employeeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Select employee')));
      return;
    }
    if (_projectId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Select project')));
      return;
    }
    setState(() => _isLoading = true);
    try {
      final ts = Timesheet(
        id: widget.timesheet?.id ?? LocalDatabase.generateId(),
        employeeId: _employeeId!,
        projectId: _projectId!,
        date: DateFormat('yyyy-MM-dd').parse(_dateController.text),
        hours: double.parse(_hoursController.text),
        task: _taskController.text.trim(),
      );
      await LocalDatabase.saveTimesheet(ts);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.timesheet != null;
    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Timesheet' : 'Add Timesheet'),
        backgroundColor: Colors.purple.shade700,
        foregroundColor: Colors.white,
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              ),
            ),
        ],
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
                      onChanged: (val) => setState(() => _employeeId = val),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _projectId,
                      decoration: const InputDecoration(labelText: 'Project *', prefixIcon: Icon(Icons.business_center)),
                      items: _projects.map((p) => DropdownMenuItem(value: p.id, child: Text(p.name))).toList(),
                      onChanged: (val) => setState(() => _projectId = val),
                    ),
                    const SizedBox(height: 16),
                    _buildDatePicker(),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _hoursController,
                      decoration: const InputDecoration(labelText: 'Hours *', prefixIcon: Icon(Icons.timer)),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (v) {
                        if (v!.isEmpty) return 'Required';
                        if (double.tryParse(v) == null) return 'Invalid number';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _taskController,
                      decoration: const InputDecoration(labelText: 'Task Description *', prefixIcon: Icon(Icons.description)),
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
                    : const Text('Save Timesheet'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDatePicker() {
    return TextFormField(
      controller: _dateController,
      decoration: InputDecoration(
        labelText: 'Date *',
        prefixIcon: const Icon(Icons.calendar_today),
        suffixIcon: IconButton(icon: const Icon(Icons.date_range), onPressed: _selectDate),
      ),
      readOnly: true,
      onTap: _selectDate,
      validator: (v) => v!.isEmpty ? 'Required' : null,
    );
  }
}
