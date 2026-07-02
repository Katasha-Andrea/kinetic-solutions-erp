import 'package:flutter/material.dart';
import 'package:kinetic_solutions/core/auth/auth_service.dart';
import 'package:kinetic_solutions/core/theme/app_theme.dart';
import 'package:kinetic_solutions/data/datasources/local_database.dart';
import 'package:kinetic_solutions/domain/entities/vehicle.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/app_user.dart';
import '../../presentation/widgets/shared_widgets.dart';

class FleetFormPage extends StatefulWidget {
  final AppUser currentUser;
  final Vehicle? vehicle;

  const FleetFormPage({super.key, required this.currentUser, this.vehicle});

  @override
  State<FleetFormPage> createState() => _FleetFormPageState();
}

class _FleetFormPageState extends State<FleetFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _regController = TextEditingController();
  final _makeController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _typeController = TextEditingController();
  final _driverController = TextEditingController();
  final _projectController = TextEditingController();
  final _locationController = TextEditingController();
  final _mileageController = TextEditingController();
  final _fuelTankController = TextEditingController();
  final _fuelLevelController = TextEditingController();
  final _insuranceExpiryController = TextEditingController();
  final _fitnessExpiryController = TextEditingController();
  final _roadTaxExpiryController = TextEditingController();
  final _avgConsumptionController = TextEditingController();

  VehicleStatus _status = VehicleStatus.available;
  bool _isLoading = false;

  final List<String> _vehicleTypes = ['Truck', 'Car', 'Excavator', 'Bulldozer', 'Crane', 'Pickup', 'Bus', 'Motorcycle', 'Other'];

  @override
  void initState() {
    super.initState();
    if (widget.vehicle != null) {
      final v = widget.vehicle!;
      _regController.text = v.registrationNumber;
      _makeController.text = v.make;
      _modelController.text = v.model;
      _yearController.text = v.year;
      _typeController.text = v.type;
      _driverController.text = v.driverName ?? '';
      _projectController.text = v.currentProject ?? '';
      _locationController.text = v.location ?? '';
      _mileageController.text = v.mileage.toString();
      _fuelTankController.text = v.fuelTankCapacity.toString();
      _fuelLevelController.text = v.currentFuelLevel.toString();
      _insuranceExpiryController.text = DateFormat('yyyy-MM-dd').format(v.insuranceExpiry);
      _fitnessExpiryController.text = DateFormat('yyyy-MM-dd').format(v.fitnessExpiry);
      _roadTaxExpiryController.text = DateFormat('yyyy-MM-dd').format(v.roadTaxExpiry);
      _avgConsumptionController.text = v.averageFuelConsumption?.toString() ?? '';
      _status = v.status;
    }
  }

  @override
  void dispose() {
    _regController.dispose();
    _makeController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _typeController.dispose();
    _driverController.dispose();
    _projectController.dispose();
    _locationController.dispose();
    _mileageController.dispose();
    _fuelTankController.dispose();
    _fuelLevelController.dispose();
    _insuranceExpiryController.dispose();
    _fitnessExpiryController.dispose();
    _roadTaxExpiryController.dispose();
    _avgConsumptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(TextEditingController controller) async {
    final initial = controller.text.isNotEmpty
        ? DateFormat('yyyy-MM-dd').parse(controller.text)
        : DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2030),
    );
    if (date != null) {
      controller.text = DateFormat('yyyy-MM-dd').format(date);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final vehicle = Vehicle(
        id: widget.vehicle?.id ?? LocalDatabase.generateId(),
        registrationNumber: _regController.text.trim().toUpperCase(),
        make: _makeController.text.trim(),
        model: _modelController.text.trim(),
        year: _yearController.text.trim(),
        type: _typeController.text.trim(),
        driverName: _driverController.text.trim().isEmpty ? null : _driverController.text.trim(),
        currentProject: _projectController.text.trim().isEmpty ? null : _projectController.text.trim(),
        location: _locationController.text.trim().isEmpty ? null : _locationController.text.trim(),
        status: _status,
        mileage: double.tryParse(_mileageController.text) ?? 0,
        fuelTankCapacity: double.tryParse(_fuelTankController.text) ?? 0,
        currentFuelLevel: double.tryParse(_fuelLevelController.text) ?? 0,
        insuranceExpiry: DateFormat('yyyy-MM-dd').parse(_insuranceExpiryController.text),
        fitnessExpiry: DateFormat('yyyy-MM-dd').parse(_fitnessExpiryController.text),
        roadTaxExpiry: DateFormat('yyyy-MM-dd').parse(_roadTaxExpiryController.text),
        averageFuelConsumption: _avgConsumptionController.text.isNotEmpty
            ? double.tryParse(_avgConsumptionController.text)
            : null,
        serviceHistory: widget.vehicle?.serviceHistory ?? [],
        createdAt: widget.vehicle?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await LocalDatabase.saveVehicle(vehicle);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving vehicle: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.vehicle != null;
    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Vehicle' : 'Add Vehicle'),
        backgroundColor: AppTheme.primaryColor,
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
                    // Basic info
                    TextFormField(
                      controller: _regController,
                      decoration: const InputDecoration(
                        labelText: 'Registration Number *',
                        prefixIcon: Icon(Icons.confirmation_number),
                      ),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _makeController,
                            decoration: const InputDecoration(
                              labelText: 'Make *',
                              prefixIcon: Icon(Icons.branding_watermark),
                            ),
                            validator: (v) => v!.isEmpty ? 'Required' : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _modelController,
                            decoration: const InputDecoration(
                              labelText: 'Model *',
                            ),
                            validator: (v) => v!.isEmpty ? 'Required' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _yearController,
                            decoration: const InputDecoration(
                              labelText: 'Year *',
                              prefixIcon: Icon(Icons.calendar_today),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (v) => v!.isEmpty ? 'Required' : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Autocomplete<String>(
                            optionsBuilder: (TextEditingValue value) {
                              if (value.text.isEmpty) return const Iterable<String>.empty();
                              return _vehicleTypes.where((type) =>
                                  type.toLowerCase().contains(value.text.toLowerCase()));
                            },
                            onSelected: (value) => _typeController.text = value,
                            fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                              return TextFormField(
                                controller: _typeController,
                                focusNode: focusNode,
                                decoration: const InputDecoration(
                                  labelText: 'Type *',
                                  prefixIcon: Icon(Icons.category),
                                ),
                                validator: (v) => v!.isEmpty ? 'Required' : null,
                                onFieldSubmitted: (_) => onFieldSubmitted(),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _driverController,
                      decoration: const InputDecoration(
                        labelText: 'Assigned Driver',
                        prefixIcon: Icon(Icons.person),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _projectController,
                      decoration: const InputDecoration(
                        labelText: 'Current Project',
                        prefixIcon: Icon(Icons.business_center),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _locationController,
                      decoration: const InputDecoration(
                        labelText: 'Current Location',
                        prefixIcon: Icon(Icons.location_on),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<VehicleStatus>(
                      value: _status,
                      decoration: const InputDecoration(
                        labelText: 'Status',
                        prefixIcon: Icon(Icons.flag),
                      ),
                      items: VehicleStatus.values.map((status) {
                        return DropdownMenuItem(
                          value: status,
                          child: Text(status.name),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => _status = val!),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              FormCard(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _mileageController,
                            decoration: const InputDecoration(
                              labelText: 'Mileage (km)',
                              prefixIcon: Icon(Icons.speed),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _avgConsumptionController,
                            decoration: const InputDecoration(
                              labelText: 'Avg Consumption (km/l)',
                              prefixIcon: Icon(Icons.local_gas_station),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _fuelTankController,
                            decoration: const InputDecoration(
                              labelText: 'Tank Capacity (L)',
                              prefixIcon: Icon(Icons.straighten),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _fuelLevelController,
                            decoration: const InputDecoration(
                              labelText: 'Current Fuel (L)',
                              prefixIcon: Icon(Icons.local_gas_station),
                            ),
                            keyboardType: TextInputType.number,
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
                    _buildDatePicker('Insurance Expiry', _insuranceExpiryController),
                    const SizedBox(height: 16),
                    _buildDatePicker('Fitness Expiry', _fitnessExpiryController),
                    const SizedBox(height: 16),
                    _buildDatePicker('Road Tax Expiry', _roadTaxExpiryController),
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
                    : const Text('Save Vehicle'),
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
        prefixIcon: const Icon(Icons.date_range),
        suffixIcon: IconButton(
          icon: const Icon(Icons.calendar_today),
          onPressed: () => _selectDate(controller),
        ),
      ),
      readOnly: true,
      onTap: () => _selectDate(controller),
      validator: (v) => v!.isEmpty ? 'Required' : null,
    );
  }
}
