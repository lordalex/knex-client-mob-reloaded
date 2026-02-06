import 'dart:convert';
import 'dart:developer' as developer;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

import '../../models/user_client_profile.dart';
import '../../providers/api_provider.dart';
import '../../providers/app_state_provider.dart';
import '../../providers/profile_provider.dart';
import '../../services/api/endpoints.dart';
import '../../services/schema_service.dart';
import '../../utils/image_utils.dart';
import '../../utils/us_states.dart';
import '../../widgets/app_button.dart';

/// Profile creation/completion screen.
///
/// Dynamic form driven by the OpenAPI schema's required fields. Includes
/// photo capture, phone input with mask, state/city dropdowns, and address.
class ProfileCreateScreen extends ConsumerStatefulWidget {
  const ProfileCreateScreen({super.key});

  @override
  ConsumerState<ProfileCreateScreen> createState() =>
      _ProfileCreateScreenState();
}

class _ProfileCreateScreenState extends ConsumerState<ProfileCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _zipCodeController = TextEditingController();

  final _phoneMask = MaskTextInputFormatter(
    mask: '(###) ###-####',
    filter: {'#': RegExp(r'[0-9]')},
  );

  String? _selectedState;
  String? _selectedCity;
  String _base64Photo = '';
  bool _isLoading = false;
  bool _isLoadingSchema = true;
  List<String> _requiredFields = [];
  UserClientProfile? _existingProfile;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSchemaAndProfile();
    });
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _zipCodeController.dispose();
    super.dispose();
  }

  Future<void> _loadSchemaAndProfile() async {
    final schemaService = SchemaService();
    try {
      final schema = await schemaService.fetchSchema();
      if (schema != null) {
        _requiredFields = schemaService.getRequiredFields(schema);
      }
    } catch (e) {
      developer.log('Schema load failed: $e', name: 'ProfileCreate');
    }

    // Pre-fill from existing profile if available
    final profile = ref.read(userProfileProvider);
    if (profile != null) {
      _existingProfile = profile;
      _firstNameController.text = profile.firstName;
      _lastNameController.text = profile.lastName;
      _phoneController.text = profile.phoneNumber;
      _addressController.text = profile.address ?? '';
      _zipCodeController.text = profile.zipCode ?? '';
      _selectedState = profile.state;
      _selectedCity = profile.city;
      if (profile.photo != null && profile.photo!.isNotEmpty) {
        _base64Photo = profile.photo!;
      }
    }

    if (mounted) {
      setState(() {
        _isLoadingSchema = false;
      });
    }
  }

  bool _isFieldRequired(String fieldName) {
    return _requiredFields.contains(fieldName);
  }

  Future<void> _pickPhoto() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 70,
      );

      if (picked != null) {
        final bytes = await picked.readAsBytes();
        final b64 = ImageUtils.bytesToBase64(bytes);
        setState(() {
          _base64Photo = b64;
        });
        ref.read(base64PhotoProvider.notifier).state = b64;
      }
    } catch (e) {
      developer.log('Photo pick failed: $e', name: 'ProfileCreate');
    }
  }

  Future<void> _submitProfile() async {
    if (!_formKey.currentState!.validate()) return;

    if (_isFieldRequired('photo') && _base64Photo.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add a profile photo.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        if (mounted) context.go('/login');
        return;
      }

      final profile = UserClientProfile(
        id: _existingProfile?.id,
        uid: user.uid,
        email: user.email ?? '',
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        phoneNumber: _phoneMask.getUnmaskedText(),
        photo: _base64Photo.isNotEmpty ? _base64Photo : null,
        address: _addressController.text.trim().isNotEmpty
            ? _addressController.text.trim()
            : null,
        city: _selectedCity,
        state: _selectedState,
        zipCode: _zipCodeController.text.trim().isNotEmpty
            ? _zipCodeController.text.trim()
            : null,
      );

      final apiClient = ref.read(apiClientProvider);
      final isUpdate = _existingProfile?.id != null;

      final endpoint = isUpdate
          ? Endpoints.updateUserClient
          : Endpoints.createUserClient;

      final response = await apiClient.post<UserClientProfile>(
        endpoint,
        data: profile.toJson(),
        fromData: (json) =>
            UserClientProfile.fromJson(json as Map<String, dynamic>),
      );

      if (!mounted) return;

      if (response.isSuccess) {
        final savedProfile = response.data ?? profile;
        ref.read(userProfileProvider.notifier).state = savedProfile;
        ref.read(userProfileCreatedProvider.notifier).state = true;
        context.go('/home');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message ?? 'Failed to save profile.'),
          ),
        );
      }
    } catch (e) {
      developer.log('Profile submit failed: $e', name: 'ProfileCreate');
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
    final theme = Theme.of(context);

    if (_isLoadingSchema) {
      return Scaffold(
        appBar: AppBar(title: const Text('Create Profile')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _existingProfile?.id != null ? 'Complete Profile' : 'Create Profile',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Profile photo
              Center(
                child: GestureDetector(
                  onTap: _pickPhoto,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor:
                        theme.colorScheme.surfaceContainerHighest,
                    backgroundImage: _base64Photo.isNotEmpty
                        ? MemoryImage(base64Decode(_base64Photo))
                        : null,
                    child: _base64Photo.isEmpty
                        ? Icon(
                            Icons.camera_alt,
                            size: 32,
                            color: theme.colorScheme.onSurfaceVariant,
                          )
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: TextButton(
                  onPressed: _pickPhoto,
                  child: const Text('Add Photo'),
                ),
              ),
              const SizedBox(height: 16),

              // First name
              TextFormField(
                controller: _firstNameController,
                decoration: InputDecoration(
                  labelText: 'First Name${_isFieldRequired('firstName') ? ' *' : ''}',
                  border: const OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.words,
                validator: _isFieldRequired('firstName')
                    ? (v) =>
                        v == null || v.trim().isEmpty ? 'Required' : null
                    : null,
              ),
              const SizedBox(height: 16),

              // Last name
              TextFormField(
                controller: _lastNameController,
                decoration: InputDecoration(
                  labelText: 'Last Name${_isFieldRequired('lastName') ? ' *' : ''}',
                  border: const OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.words,
                validator: _isFieldRequired('lastName')
                    ? (v) =>
                        v == null || v.trim().isEmpty ? 'Required' : null
                    : null,
              ),
              const SizedBox(height: 16),

              // Phone
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Phone${_isFieldRequired('phoneNumber') ? ' *' : ''}',
                  border: const OutlineInputBorder(),
                  hintText: '(555) 123-4567',
                ),
                keyboardType: TextInputType.phone,
                inputFormatters: [_phoneMask],
                validator: _isFieldRequired('phoneNumber')
                    ? (v) =>
                        v == null || v.trim().isEmpty ? 'Required' : null
                    : null,
              ),
              const SizedBox(height: 16),

              // Address
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: 'Address${_isFieldRequired('address') ? ' *' : ''}',
                  border: const OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.words,
                validator: _isFieldRequired('address')
                    ? (v) =>
                        v == null || v.trim().isEmpty ? 'Required' : null
                    : null,
              ),
              const SizedBox(height: 16),

              // State dropdown
              DropdownButtonFormField<String>(
                initialValue: _selectedState,
                decoration: InputDecoration(
                  labelText: 'State${_isFieldRequired('state') ? ' *' : ''}',
                  border: const OutlineInputBorder(),
                ),
                isExpanded: true,
                items: usStateNames.map((state) {
                  return DropdownMenuItem(value: state, child: Text(state));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedState = value;
                    _selectedCity = null; // Reset city when state changes
                  });
                },
                validator: _isFieldRequired('state')
                    ? (v) => v == null ? 'Required' : null
                    : null,
              ),
              const SizedBox(height: 16),

              // City dropdown
              DropdownButtonFormField<String>(
                initialValue: _selectedCity,
                decoration: InputDecoration(
                  labelText: 'City${_isFieldRequired('city') ? ' *' : ''}',
                  border: const OutlineInputBorder(),
                ),
                isExpanded: true,
                items: (_selectedState != null
                        ? getCitiesForState(_selectedState!)
                        : <String>[])
                    .map((city) {
                  return DropdownMenuItem(value: city, child: Text(city));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCity = value;
                  });
                },
                validator: _isFieldRequired('city')
                    ? (v) => v == null ? 'Required' : null
                    : null,
              ),
              const SizedBox(height: 16),

              // Zip code
              TextFormField(
                controller: _zipCodeController,
                decoration: InputDecoration(
                  labelText: 'Zip Code${_isFieldRequired('zipCode') ? ' *' : ''}',
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: _isFieldRequired('zipCode')
                    ? (v) =>
                        v == null || v.trim().isEmpty ? 'Required' : null
                    : null,
              ),
              const SizedBox(height: 24),

              // Submit button
              AppButton(
                label: _existingProfile?.id != null
                    ? 'Update Profile'
                    : 'Create Profile',
                isLoading: _isLoading,
                onPressed: _isLoading ? null : _submitProfile,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
