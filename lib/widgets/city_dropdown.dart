import 'package:flutter/material.dart';

/// Placeholder city dropdown widget.
///
/// Will be replaced in Phase 3 with a styled [DropdownButton2] that
/// filters the locations list by city/region.
class CityDropdown extends StatelessWidget {
  final String? selectedCity;
  final List<String> cities;
  final ValueChanged<String?>? onChanged;

  const CityDropdown({
    super.key,
    this.selectedCity,
    this.cities = const [],
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: selectedCity,
      hint: const Text('Select City'),
      isExpanded: true,
      items: cities
          .map((city) => DropdownMenuItem(value: city, child: Text(city)))
          .toList(),
      onChanged: onChanged,
    );
  }
}
