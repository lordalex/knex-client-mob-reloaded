import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../config/asset_paths.dart';
import '../../config/theme/app_colors.dart';
import '../../models/my_car.dart';
import '../../models/ticket.dart';
import '../../models/vehicle.dart';
import '../../providers/api_provider.dart';
import '../../providers/app_state_provider.dart';
import '../../providers/profile_provider.dart';
import '../../providers/ticket_provider.dart';
import '../../services/api/endpoints.dart';
import '../../utils/us_states.dart';

/// Vehicle entry screen for requesting valet service.
///
/// Allows the user to enter vehicle details (make & model, color, plate),
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
  final _makeModelController = TextEditingController();
  final _colorController = TextEditingController();
  final _plateController = TextEditingController();
  final _notesController = TextEditingController();
  String? _selectedState;
  bool _isLoading = false;
  bool _saveAsDefault = true;
  bool _showOptionalFields = false;

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
      final make = myCar.make ?? '';
      final model = myCar.model ?? '';
      _makeModelController.text = '$make${model.isNotEmpty ? ' $model' : ''}'.trim();
      _colorController.text = myCar.color ?? '';
      _plateController.text = myCar.plate ?? '';
      _notesController.text = myCar.notes ?? '';
      if (myCar.state != null) {
        setState(() {
          _selectedState = myCar.state;
          // Show optional fields if they have data
          if (myCar.state != null || (myCar.notes ?? '').isNotEmpty) {
            _showOptionalFields = true;
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _makeModelController.dispose();
    _colorController.dispose();
    _plateController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  /// Split "Make Model" into separate make/model parts for the API.
  (String make, String model) _parseMakeModel() {
    final text = _makeModelController.text.trim();
    final parts = text.split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return (parts.first, parts.sublist(1).join(' '));
    }
    return (text, '');
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

      final (make, model) = _parseMakeModel();

      // 1. Create vehicle
      final vehicle = Vehicle(
        userClientId: profile!.id,
        vehicleMake: make,
        vehicleModel: model,
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
          make: make,
          model: model,
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

      final pinResponse = await apiClient.post<String>(
        Endpoints.generatePINandTicket,
        data: ticketData,
        fromData: (json) {
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
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      body: Column(
        children: [
          // Branded dark navy header
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(16, topPadding + 8, 16, 20),
            decoration: BoxDecoration(
              color: AppColors.light.secondary,
            ),
            child: Column(
              children: [
                // Back button row
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => context.pop(),
                    ),
                    const Expanded(
                      child: Text(
                        'Vehicle Details',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48), // Balance the back button
                  ],
                ),
              ],
            ),
          ),

          // KNEX logo between header and form
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Image.asset(
              AssetPaths.knexLogo,
              height: 36,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
          ),

          // Form
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Make & Model (combined)
                    TextFormField(
                      controller: _makeModelController,
                      decoration: const InputDecoration(
                        labelText: 'Make and model',
                        hintText: 'e.g. Toyota Camry',
                        prefixIcon: Icon(Icons.directions_car_outlined),
                      ),
                      textCapitalization: TextCapitalization.words,
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),

                    // Color
                    TextFormField(
                      controller: _colorController,
                      decoration: const InputDecoration(
                        labelText: 'Color',
                        hintText: 'e.g. White',
                        prefixIcon: Icon(Icons.palette_outlined),
                      ),
                      textCapitalization: TextCapitalization.words,
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),

                    // Plate
                    TextFormField(
                      controller: _plateController,
                      decoration: const InputDecoration(
                        labelText: 'License Plate',
                        hintText: 'e.g. ABC1234',
                        prefixIcon: Icon(Icons.badge_outlined),
                      ),
                      textCapitalization: TextCapitalization.characters,
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),

                    // Optional fields expander
                    InkWell(
                      onTap: () => setState(
                        () => _showOptionalFields = !_showOptionalFields,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            Icon(
                              _showOptionalFields
                                  ? Icons.expand_less
                                  : Icons.expand_more,
                              color: AppColors.light.secondaryText,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Additional details',
                              style: TextStyle(
                                color: AppColors.light.secondaryText,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Collapsible optional fields
                    AnimatedSize(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      child: _showOptionalFields
                          ? Column(
                              children: [
                                const SizedBox(height: 8),
                                DropdownButtonFormField<String>(
                                  initialValue: _selectedState,
                                  decoration: const InputDecoration(
                                    labelText: 'State',
                                    prefixIcon: Icon(Icons.map_outlined),
                                  ),
                                  isExpanded: true,
                                  items: usStateNames.map((state) {
                                    return DropdownMenuItem(
                                      value: state,
                                      child: Text(state),
                                    );
                                  }).toList(),
                                  onChanged: (value) =>
                                      _selectedState = value,
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _notesController,
                                  decoration: const InputDecoration(
                                    labelText: 'Notes (optional)',
                                    hintText:
                                        'Special instructions for the valet',
                                    prefixIcon: Icon(Icons.note_outlined),
                                  ),
                                  maxLines: 2,
                                  textCapitalization:
                                      TextCapitalization.sentences,
                                ),
                              ],
                            )
                          : const SizedBox.shrink(),
                    ),
                    const SizedBox(height: 16),

                    // Save as default toggle
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Save as my default car'),
                      value: _saveAsDefault,
                      onChanged: (v) => setState(() => _saveAsDefault = v),
                    ),
                    const SizedBox(height: 24),

                    // Submit button — dark navy
                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.light.secondary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Save Info'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
