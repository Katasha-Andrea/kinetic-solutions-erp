import 'package:flutter/material.dart';
import 'package:kinetic_solutions/core/auth/auth_service.dart';
import 'package:kinetic_solutions/core/theme/app_theme.dart';
import 'package:kinetic_solutions/data/datasources/local_database.dart';
import 'package:kinetic_solutions/domain/entities/site_diary.dart';
import 'package:kinetic_solutions/domain/entities/project.dart';
import 'package:kinetic_solutions/domain/entities/work_order.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/app_user.dart';
import '../../presentation/widgets/shared_widgets.dart';

class SiteDiaryFormPage extends StatefulWidget {
  final AppUser currentUser;
  final SiteDiary? diary;

  const SiteDiaryFormPage({
    super.key,
    required this.currentUser,
    this.diary,
  });

  @override
  State<SiteDiaryFormPage> createState() => _SiteDiaryFormPageState();
}

class _SiteDiaryFormPageState extends State<SiteDiaryFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _woNumberController = TextEditingController();
  final _dateController = TextEditingController();
  final _weatherController = TextEditingController();
  final _temperatureController = TextEditingController();
  final _workCompletedController = TextEditingController();
  final _issuesController = TextEditingController();
  final _safetyController = TextEditingController();
  final _visitorsController = TextEditingController();
  final _supervisorController = TextEditingController();

  String? _projectId;
  List<String> _workersPresent = [];
  List<Map<String, dynamic>> _equipmentUsed = [];
  List<Map<String, dynamic>> _materialsUsed = [];
  bool _isSubmitted = false;
  bool _isLoading = false;
  List<Project> _projects = [];
  List<WorkOrder> _workOrders = [];

  @override
  void initState() {
    super.initState();
    _loadData();
    if (widget.diary != null) {
      final d = widget.diary!;
      _woNumberController.text = d.woNumber;
      _dateController.text = DateFormat('yyyy-MM-dd').format(d.date);
      _weatherController.text = d.weather;
      _temperatureController.text = d.temperature;
      _workCompletedController.text = d.workCompleted;
      _issuesController.text = d.issuesEncountered;
      _safetyController.text = d.safetyIncidents;
      _visitorsController.text = d.visitors;
      _supervisorController.text = d.supervisorName;
      _projectId = d.projectId;
      _workersPresent = List.from(d.workersPresent);
      _equipmentUsed = List.from(d.equipmentUsed);
      _materialsUsed = List.from(d.materialsUsed);
      _isSubmitted = d.isSubmitted;
    }
  }

  Future<void> _loadData() async {
    final projects = LocalDatabase.getProjects();
    final workOrders = LocalDatabase.getWorkOrders();
    setState(() {
      _projects = projects;
      _workOrders = workOrders;
    });
  }

  @override
  void dispose() {
    _woNumberController.dispose();
    _dateController.dispose();
    _weatherController.dispose();
    _temperatureController.dispose();
    _workCompletedController.dispose();
    _issuesController.dispose();
    _safetyController.dispose();
    _visitorsController.dispose();
    _supervisorController.dispose();
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

  void _addWorker() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Worker'),
        content: TextField(
          onSubmitted: (val) {
            if (val.isNotEmpty) {
              setState(() => _workersPresent.add(val));
              Navigator.pop(ctx);
            }
          },
          decoration: const InputDecoration(labelText: 'Worker Name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _addEquipment() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Equipment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Equipment Name'),
              onChanged: (val) => _tempName = val,
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Hours Used'),
              keyboardType: TextInputType.number,
              onChanged: (val) => _tempHours = val,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (_tempName.isNotEmpty && _tempHours.isNotEmpty) {
                setState(() {
                  _equipmentUsed.add({
                    'name': _tempName,
                    'hours': double.tryParse(_tempHours) ?? 0,
                  });
                  _tempName = '';
                  _tempHours = '';
                });
                Navigator.pop(ctx);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  String _tempName = '';
  String _tempHours = '';

  void _addMaterial() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Material'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Material Name'),
              onChanged: (val) => _tempMatName = val,
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Quantity'),
              keyboardType: TextInputType.number,
              onChanged: (val) => _tempMatQty = val,
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Unit'),
              onChanged: (val) => _tempMatUnit = val,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (_tempMatName.isNotEmpty && _tempMatQty.isNotEmpty) {
                setState(() {
                  _materialsUsed.add({
                    'name': _tempMatName,
                    'quantity': _tempMatQty,
                    'unit': _tempMatUnit.isNotEmpty ? _tempMatUnit : 'each',
                  });
                  _tempMatName = '';
                  _tempMatQty = '';
                  _tempMatUnit = '';
                });
                Navigator.pop(ctx);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  String _tempMatName = '';
  String _tempMatQty = '';
  String _tempMatUnit = '';

  Future<void> _save({bool submit = false}) async {
    if (!_formKey.currentState!.validate()) return;
    if (_projectId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select a project')),
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      final diary = SiteDiary(
        id: widget.diary?.id ?? LocalDatabase.generateId(),
        projectId: _projectId!,
        woNumber: _woNumberController.text.trim(),
        date: DateFormat('yyyy-MM-dd').parse(_dateController.text),
        weather: _weatherController.text.trim(),
        temperature: _temperatureController.text.trim(),
        workersPresent: _workersPresent,
        equipmentUsed: _equipmentUsed,
        materialsUsed: _materialsUsed,
        workCompleted: _workCompletedController.text.trim(),
        issuesEncountered: _issuesController.text.trim(),
        safetyIncidents: _safetyController.text.trim(),
        visitors: _visitorsController.text.trim(),
        supervisorName: _supervisorController.text.trim(),
        isSubmitted: submit || _isSubmitted,
      );
      await LocalDatabase.saveSiteDiary(diary);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.diary != null;
    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Site Diary' : 'New Site Diary'),
        backgroundColor: Colors.brown.shade700,
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
                      onChanged: (val) => setState(() => _projectId = val),
                      validator: (v) => v == null ? 'Select project' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _woNumberController,
                      decoration: const InputDecoration(
                        labelText: 'Work Order Number *',
                        prefixIcon: Icon(Icons.confirmation_number),
                      ),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildDatePicker(),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _weatherController,
                            decoration: const InputDecoration(
                              labelText: 'Weather',
                              prefixIcon: Icon(Icons.wb_sunny),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _temperatureController,
                            decoration: const InputDecoration(
                              labelText: 'Temperature (°C)',
                              prefixIcon: Icon(Icons.thermostat),
                            ),
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
                    TextFormField(
                      controller: _workCompletedController,
                      decoration: const InputDecoration(
                        labelText: 'Work Completed',
                        prefixIcon: Icon(Icons.construction),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _issuesController,
                      decoration: const InputDecoration(
                        labelText: 'Issues Encountered',
                        prefixIcon: Icon(Icons.warning),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _safetyController,
                      decoration: const InputDecoration(
                        labelText: 'Safety Incidents',
                        prefixIcon: Icon(Icons.security),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _visitorsController,
                      decoration: const InputDecoration(
                        labelText: 'Visitors',
                        prefixIcon: Icon(Icons.people),
                      ),
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
                  ],
                ),
              ),
              const SizedBox(height: 16),
              FormCard(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Workers Present', style: TextStyle(fontWeight: FontWeight.bold)),
                        IconButton(
                          icon: const Icon(Icons.add, color: AppTheme.primary500),
                          onPressed: _addWorker,
                        ),
                      ],
                    ),
                    Wrap(
                      spacing: 8,
                      children: _workersPresent.map((w) => Chip(
                        label: Text(w),
                        onDeleted: () => setState(() => _workersPresent.remove(w)),
                      )).toList(),
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Equipment Used', style: TextStyle(fontWeight: FontWeight.bold)),
                        IconButton(
                          icon: const Icon(Icons.add, color: AppTheme.primary500),
                          onPressed: _addEquipment,
                        ),
                      ],
                    ),
                    ..._equipmentUsed.map((e) => ListTile(
                      title: Text(e['name']),
                      trailing: Text('${e['hours']}h'),
                      leading: IconButton(
                        icon: const Icon(Icons.delete, color: AppTheme.errorColor),
                        onPressed: () => setState(() => _equipmentUsed.remove(e)),
                      ),
                    )),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Materials Used', style: TextStyle(fontWeight: FontWeight.bold)),
                        IconButton(
                          icon: const Icon(Icons.add, color: AppTheme.primary500),
                          onPressed: _addMaterial,
                        ),
                      ],
                    ),
                    ..._materialsUsed.map((m) => ListTile(
                      title: Text(m['name']),
                      subtitle: Text('${m['quantity']} ${m['unit']}'),
                      leading: IconButton(
                        icon: const Icon(Icons.delete, color: AppTheme.errorColor),
                        onPressed: () => setState(() => _materialsUsed.remove(m)),
                      ),
                    )),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : () => _save(submit: false),
                      child: const Text('Save Draft'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : () => _save(submit: true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary500,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Submit'),
                    ),
                  ),
                ],
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
