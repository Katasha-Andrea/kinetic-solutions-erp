import 'package:flutter/material.dart';
import 'package:kinetic_solutions/core/auth/auth_service.dart';
import 'package:kinetic_solutions/core/theme/app_theme.dart';
import 'package:kinetic_solutions/data/datasources/local_database.dart';
import 'package:kinetic_solutions/domain/entities/work_order.dart';
import 'package:kinetic_solutions/domain/entities/project.dart';
import 'package:kinetic_solutions/domain/entities/vehicle.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/app_user.dart';
import '../../presentation/widgets/shared_widgets.dart';

class WorkOrderFormPage extends StatefulWidget {
  final AppUser currentUser;
  final WorkOrder? workOrder;

  const WorkOrderFormPage({super.key, required this.currentUser, this.workOrder});

  @override
  State<WorkOrderFormPage> createState() => _WorkOrderFormPageState();
}

class _WorkOrderFormPageState extends State<WorkOrderFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _woNumberController = TextEditingController();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _gpsLatController = TextEditingController();
  final _gpsLonController = TextEditingController();
  final _supervisorController = TextEditingController();
  final _teamMembersController = TextEditingController();
  final _startDateController = TextEditingController();
  final _estimatedHoursController = TextEditingController();
  final _actualHoursController = TextEditingController();
  final _completionPercentController = TextEditingController();

  WOStatus _status = WOStatus.pending;
  WOPriority _priority = WOPriority.medium;
  String? _projectId;
  String? _vehicleId;
  bool _isLoading = false;
  List<Project> _projects = [];
  List<Vehicle> _vehicles = [];

  @override
  void initState() {
    super.initState();
    _loadDropdownData();
    if (widget.workOrder != null) {
      final o = widget.workOrder!;
      _woNumberController.text = o.woNumber;
      _titleController.text = o.title;
      _descriptionController.text = o.description;
      _locationController.text = o.location;
      _gpsLatController.text = o.gpsLat?.toString() ?? '';
      _gpsLonController.text = o.gpsLon?.toString() ?? '';
      _supervisorController.text = o.supervisorName;
      _teamMembersController.text = o.assignedTeamMembers;
      _startDateController.text = DateFormat('yyyy-MM-dd').format(o.startDate);
      _estimatedHoursController.text = o.estimatedHours.toString();
      _actualHoursController.text = o.actualHours.toString();
      _completionPercentController.text = o.completionPercent.toString();
      _status = o.status;
      _priority = o.priority;
      _projectId = o.projectId;
      _vehicleId = o.vehicleId;
    }
  }

  Future<void> _loadDropdownData() async {
    final projects = LocalDatabase.getProjects();
    final vehicles = LocalDatabase.getVehicles();
    setState(() {
      _projects = projects;
      _vehicles = vehicles;
    });
  }

  @override
  void dispose() {
    _woNumberController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _gpsLatController.dispose();
    _gpsLonController.dispose();
    _supervisorController.dispose();
    _teamMembersController.dispose();
    _startDateController.dispose();
    _estimatedHoursController.dispose();
    _actualHoursController.dispose();
    _completionPercentController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final initial = _startDateController.text.isNotEmpty
        ? DateFormat('yyyy-MM-dd').parse(_startDateController.text)
        : DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2030),
    );
    if (date != null) {
      _startDateController.text = DateFormat('yyyy-MM-dd').format(date);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final order = WorkOrder(
        id: widget.workOrder?.id ?? LocalDatabase.generateId(),
        woNumber: _woNumberController.text.trim().toUpperCase(),
        projectId: _projectId!,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        location: _locationController.text.trim(),
        gpsLat: _gpsLatController.text.isNotEmpty ? double.parse(_gpsLatController.text) : null,
        gpsLon: _gpsLonController.text.isNotEmpty ? double.parse(_gpsLonController.text) : null,
        supervisorName: _supervisorController.text.trim(),
        assignedTeamMembers: _teamMembersController.text.trim(),
        vehicleId: _vehicleId,
        status: _status,
        priority: _priority,
        startDate: DateFormat('yyyy-MM-dd').parse(_startDateController.text),
        estimatedHours: double.parse(_estimatedHoursController.text),
        actualHours: double.parse(_actualHoursController.text),
        completionPercent: int.parse(_completionPercentController.text),
        materialUsed: widget.workOrder?.materialUsed ?? [],
        photosBefore: widget.workOrder?.photosBefore ?? [],
        photosAfter: widget.workOrder?.photosAfter ?? [],
        activityLog: widget.workOrder?.activityLog ?? [],
        clientSignature: widget.workOrder?.clientSignature,
        createdAt: widget.workOrder?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await LocalDatabase.saveWorkOrder(order);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving work order: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.workOrder != null;
    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Work Order' : 'Add Work Order'),
        backgroundColor: Colors.orange.shade700,
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
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _woNumberController,
                            decoration: const InputDecoration(
                              labelText: 'WO Number *',
                              prefixIcon: Icon(Icons.confirmation_number),
                            ),
                            validator: (v) => v!.isEmpty ? 'Required' : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _titleController,
                            decoration: const InputDecoration(
                              labelText: 'Title *',
                              prefixIcon: Icon(Icons.title),
                            ),
                            validator: (v) => v!.isEmpty ? 'Required' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        prefixIcon: Icon(Icons.description),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _locationController,
                      decoration: const InputDecoration(
                        labelText: 'Location *',
                        prefixIcon: Icon(Icons.location_on),
                      ),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _gpsLatController,
                            decoration: const InputDecoration(
                              labelText: 'GPS Latitude',
                              prefixIcon: Icon(Icons.gps_fixed),
                            ),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _gpsLonController,
                            decoration: const InputDecoration(
                              labelText: 'GPS Longitude',
                              prefixIcon: Icon(Icons.gps_fixed),
                            ),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              FormCard(
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      value: _projectId,
                      decoration: const InputDecoration(
                        labelText: 'Project *',
                        prefixIcon: Icon(Icons.business_center),
                      ),
                      items: _projects.map((p) {
                        return DropdownMenuItem(
                          value: p.id,
                          child: Text(p.name),
                        );
                      }).toList(),
                      validator: (v) => v == null ? 'Select a project' : null,
                      onChanged: (val) => setState(() => _projectId = val),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _vehicleId,
                      decoration: const InputDecoration(
                        labelText: 'Assigned Vehicle (optional)',
                        prefixIcon: Icon(Icons.directions_car),
                      ),
                      items: [
                        const DropdownMenuItem(value: null, child: Text('None')),
                        ..._vehicles.map((v) {
                          return DropdownMenuItem(
                            value: v.id,
                            child: Text('${v.registrationNumber} - ${v.make} ${v.model}'),
                          );
                        }),
                      ],
                      onChanged: (val) => setState(() => _vehicleId = val),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _supervisorController,
                      decoration: const InputDecoration(
                        labelText: 'Supervisor Name *',
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _teamMembersController,
                      decoration: const InputDecoration(
                        labelText: 'Assigned Team Members (comma separated)',
                        prefixIcon: Icon(Icons.people),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              FormCard(
                child: Column(
                  children: [
                    _buildDatePicker(),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _estimatedHoursController,
                            decoration: const InputDecoration(
                              labelText: 'Est. Hours *',
                              prefixIcon: Icon(Icons.timer),
                            ),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            validator: (v) {
                              if (v!.isEmpty) return 'Required';
                              if (double.tryParse(v) == null) return 'Invalid';
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _actualHoursController,
                            decoration: const InputDecoration(
                              labelText: 'Actual Hours',
                              prefixIcon: Icon(Icons.access_time),
                            ),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _completionPercentController,
                      decoration: const InputDecoration(
                        labelText: 'Completion % (0-100)',
                        prefixIcon: Icon(Icons.percent),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v!.isEmpty) return 'Required';
                        final val = int.tryParse(v);
                        if (val == null || val < 0 || val > 100) return '0-100';
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              FormCard(
                child: Column(
                  children: [
                    DropdownButtonFormField<WOStatus>(
                      value: _status,
                      decoration: const InputDecoration(
                        labelText: 'Status',
                        prefixIcon: Icon(Icons.flag),
                      ),
                      items: WOStatus.values.map((status) {
                        return DropdownMenuItem(
                          value: status,
                          child: Text(status.name),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => _status = val!),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<WOPriority>(
                      value: _priority,
                      decoration: const InputDecoration(
                        labelText: 'Priority',
                        prefixIcon: Icon(Icons.priority_high),
                      ),
                      items: WOPriority.values.map((pri) {
                        return DropdownMenuItem(
                          value: pri,
                          child: Text(pri.name),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => _priority = val!),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _save,
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save Work Order'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDatePicker() {
    return TextFormField(
      controller: _startDateController,
      decoration: InputDecoration(
        labelText: 'Start Date *',
        prefixIcon: const Icon(Icons.calendar_today),
        suffixIcon: IconButton(
          icon: const Icon(Icons.date_range),
          onPressed: _selectDate,
        ),
      ),
      readOnly: true,
      onTap: _selectDate,
      validator: (v) => v!.isEmpty ? 'Required' : null,
    );
  }
}
