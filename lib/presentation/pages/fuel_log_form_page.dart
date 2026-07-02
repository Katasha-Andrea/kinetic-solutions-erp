// lib/presentation/pages/fuel_log_form_page.dart
import 'package:flutter/material.dart';
import 'package:kinetic_solutions/core/auth/auth_service.dart';
import 'package:kinetic_solutions/core/theme/app_theme.dart';
import 'package:kinetic_solutions/data/datasources/local_database.dart';
import 'package:kinetic_solutions/domain/entities/fuel_log.dart';
import 'package:kinetic_solutions/domain/entities/vehicle.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/app_user.dart';
import '../../presentation/widgets/shared_widgets.dart';

class FuelLogFormPage extends StatefulWidget {
  final AppUser currentUser;
  final FuelLog? log;

  const FuelLogFormPage({super.key, required this.currentUser, this.log});

  @override
  State<FuelLogFormPage> createState() => _FuelLogFormPageState();
}

class _FuelLogFormPageState extends State<FuelLogFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _litresController = TextEditingController();
  final _costController = TextEditingController();
  final _mileageController = TextEditingController();
  final _dateController = TextEditingController();

  String? _vehicleId;
  bool _isLoading = false;
  List<Vehicle> _vehicles = [];

  @override
  void initState() {
    super.initState();
    _loadVehicles();
    if (widget.log != null) {
      final l = widget.log!;
      _litresController.text = l.litres.toString();
      _costController.text = l.cost.toString();
      _mileageController.text = l.mileage.toString();
      _dateController.text = DateFormat('yyyy-MM-dd').format(l.date);
      _vehicleId = l.vehicleId;
    }
  }

  Future<void> _loadVehicles() async {
    final vehicles = LocalDatabase.getVehicles().where((v) => v.status != VehicleStatus.sold).toList();
    setState(() => _vehicles = vehicles);
  }

  @override
  void dispose() {
    _litresController.dispose();
    _costController.dispose();
    _mileageController.dispose();
    _dateController.dispose();
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
    if (_vehicleId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Select vehicle')));
      return;
    }
    setState(() => _isLoading = true);
    try {
      final log = FuelLog(
        id: widget.log?.id ?? LocalDatabase.generateId(),
        vehicleId: _vehicleId!,
        date: DateFormat('yyyy-MM-dd').parse(_dateController.text),
        litres: double.parse(_litresController.text),
        cost: double.parse(_costController.text),
        mileage: double.parse(_mileageController.text),
      );
      await LocalDatabase.saveFuelLog(log);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.log != null;
    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Fuel Log' : 'Add Fuel Log'),
        backgroundColor: Colors.amber.shade700,
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
                      value: _vehicleId,
                      decoration: const InputDecoration(labelText: 'Vehicle *', prefixIcon: Icon(Icons.directions_car)),
                      items: _vehicles.map((v) {
                        return DropdownMenuItem(
                          value: v.id,
                          child: Text('${v.registrationNumber} - ${v.make} ${v.model}'),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => _vehicleId = val),
                      validator: (v) => v == null ? 'Select vehicle' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildDatePicker(),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _litresController,
                            decoration: const InputDecoration(labelText: 'Litres *', prefixIcon: Icon(Icons.water)),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            validator: (v) {
                              if (v!.isEmpty) return 'Required';
                              if (double.tryParse(v) == null) return 'Invalid number';
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _costController,
                            decoration: const InputDecoration(labelText: 'Cost (ZMW) *', prefixIcon: Icon(Icons.attach_money)),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            validator: (v) {
                              if (v!.isEmpty) return 'Required';
                              if (double.tryParse(v) == null) return 'Invalid number';
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _mileageController,
                      decoration: const InputDecoration(labelText: 'Current Mileage (km) *', prefixIcon: Icon(Icons.speed)),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (v) {
                        if (v!.isEmpty) return 'Required';
                        if (double.tryParse(v) == null) return 'Invalid number';
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _save,
                child: _isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Save Fuel Log'),
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
