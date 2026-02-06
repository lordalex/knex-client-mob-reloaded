import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/my_car.dart';
import '../../models/ticket.dart';
import '../../models/vehicle.dart';
import '../../providers/api_provider.dart';
import '../../providers/app_state_provider.dart';
import '../../providers/profile_provider.dart';
import '../../providers/ticket_provider.dart';
import '../../services/api/endpoints.dart';
import '../../utils/us_states.dart';
import '../../widgets/app_button.dart';

/// Vehicle entry screen for requesting valet service.
///
/// Allows the user to enter vehicle details (make, model, color, plate, state),
/// optionally pre-fills from saved MyCar, creates the vehicle via API, then
/// creates a ticket for the selected location.
class AddCarsScreen extends ConsumerStatefulWidget {
  final String siteId;

  const AddCarsScreen({super.key, this.siteId = ''});

  @override
  ConsumerState<AddCarsScreen> createState() => _AddCarsScreenState();
}

class _AddCarsScreenState extends ConsumerState<AddCarsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _makeController = TextEditingController();
  final _modelController = TextEditingController();
  final _colorController = TextEditingController();
  final _plateController = TextEditingController();
  final _notesController = TextEditingController();
  String? _selectedState;
  bool _isLoading = false;
  bool _saveAsDefault = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _prefillFromSavedCar();
    });
  }

  void _prefillFromSavedCar() {
    final myCar = ref.read(myCarProvider);
    if (myCar.isNotEmpty) {
      var make = myCar.make ?? '';
      var model = myCar.model ?? '';

      // Migrate old combined format: make was null, model held "Make Model"
      if (make.isEmpty && model.contains(' ')) {
        final parts = model.split(' ');
        make = parts.first;
        model = parts.sublist(1).join(' ');
      }

      _makeController.text = make;
      _modelController.text = model;
      _colorController.text = myCar.color ?? '';
      _plateController.text = myCar.plate ?? '';
      _notesController.text = myCar.notes ?? '';
      if (myCar.state != null) {
        setState(() => _selectedState = myCar.state);
      }
    }
  }

  @override
  void dispose() {
    _makeController.dispose();
    _modelController.dispose();
    _colorController.dispose();
    _plateController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final apiClient = ref.read(apiClientProvider);
      final profile = ref.read(userProfileProvider);

      if (profile?.id == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile not found. Please sign in again.')),
          );
        }
        return;
      }

      // 1. Create vehicle
      final vehicle = Vehicle(
        userClientId: profile!.id,
        vehicleMake: _makeController.text.trim(),
        vehicleModel: _modelController.text.trim(),
        color: _colorController.text.trim(),
        licensePlate: _plateController.text.trim().toUpperCase(),
      );

      print('[AddCars] Creating vehicle: ${vehicle.toJson()}');
      final vehicleResponse = await apiClient.post<Vehicle>(
        Endpoints.createVehicle,
        data: vehicle.toJson(),
        fromData: (json) {
          final raw = json is List ? json.first : json;
          print('[AddCars] Vehicle response data: $raw');
          return Vehicle.fromJson(raw as Map<String, dynamic>);
        },
      );

      if (!mounted) return;

      print('[AddCars] Vehicle response — isSuccess: ${vehicleResponse.isSuccess}, '
          'hasData: ${vehicleResponse.data != null}, message: ${vehicleResponse.message}');

      if (vehicleResponse.isError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(vehicleResponse.message ?? 'Failed to create vehicle.'),
          ),
        );
        setState(() => _isLoading = false);
        return;
      }

      final createdVehicle = vehicleResponse.data ?? vehicle;
      print('[AddCars] Created vehicle id: ${createdVehicle.id}');

      // 2. Save as default car
      if (_saveAsDefault) {
        ref.read(myCarProvider.notifier).setCar(MyCar(
          make: createdVehicle.vehicleMake,
          model: createdVehicle.vehicleModel,
          color: createdVehicle.color,
          plate: createdVehicle.licensePlate,
          state: _selectedState,
          notes: _notesController.text.trim(),
        ));
      }

      // 3. Generate PIN and ticket
      final ticketData = {
        'email': profile.email,
        'vehicle': createdVehicle.id ?? '',
        'location': widget.siteId,
        if (_notesController.text.trim().isNotEmpty)
          'notes': _notesController.text.trim(),
      };
      print('[AddCars] ========== GENERATE PIN & TICKET ==========');
      print('[AddCars] Endpoint: ${Endpoints.generatePINandTicket}');
      print('[AddCars] Payload: $ticketData');

      // This endpoint returns {"pin": "..."} directly (no status/data envelope).
      // We extract the pin, then fetch the full ticket via getLatestTicket.
      final pinResponse = await apiClient.post<String>(
        Endpoints.generatePINandTicket,
        data: ticketData,
        fromData: (json) {
          // Response is the raw Map {"pin": "..."} since there's no envelope.
          print('[AddCars] PIN raw response: $json');
          if (json is Map<String, dynamic>) {
            return json['pin'] as String? ?? '';
          }
          return json.toString();
        },
      );

      if (!mounted) return;

      print('[AddCars] PIN response — isSuccess: ${pinResponse.isSuccess}, '
          'pin: ${pinResponse.data}, message: ${pinResponse.message}');

      final pin = pinResponse.data ?? '';
      if (pin.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to generate ticket PIN.')),
          );
        }
        return;
      }

      // Build ticket from known data — the backend only returns the PIN.
      final ticket = Ticket(
        pin: pin,
        userClientId: profile.id ?? '',
        vehicleId: createdVehicle.id ?? '',
        locationId: widget.siteId,
        status: 'Arrived',
        notes: _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : null,
      );

      print('[AddCars] Built ticket from known data: '
          'pin=$pin, vehicleId=${ticket.vehicleId}, '
          'locationId=${ticket.locationId}, status=${ticket.status}');

      if (!mounted) return;

      ref.read(activeTicketProvider.notifier).state = ticket;
      context.go('/ticket');
    } catch (e) {
      developer.log('AddCars submit error: $e', name: 'AddCarsScreen');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vehicle Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _makeController,
                decoration: const InputDecoration(
                  labelText: 'Make *',
                  hintText: 'e.g. Toyota',
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _modelController,
                decoration: const InputDecoration(
                  labelText: 'Model *',
                  hintText: 'e.g. Camry',
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _colorController,
                decoration: const InputDecoration(
                  labelText: 'Color *',
                  hintText: 'e.g. White',
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _plateController,
                decoration: const InputDecoration(
                  labelText: 'License Plate *',
                  hintText: 'e.g. ABC1234',
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.characters,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                initialValue: _selectedState,
                decoration: const InputDecoration(
                  labelText: 'State',
                  border: OutlineInputBorder(),
                ),
                isExpanded: true,
                items: usStateNames.map((state) {
                  return DropdownMenuItem(value: state, child: Text(state));
                }).toList(),
                onChanged: (value) => _selectedState = value,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                  hintText: 'Special instructions for the valet',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 16),

              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Save as my default car'),
                value: _saveAsDefault,
                onChanged: (v) => setState(() => _saveAsDefault = v),
              ),
              const SizedBox(height: 24),

              AppButton(
                label: 'Request Valet',
                isLoading: _isLoading,
                onPressed: _isLoading ? null : _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
