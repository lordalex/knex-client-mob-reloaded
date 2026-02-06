import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/app_state_provider.dart';

/// Screen for configuring how the location list is displayed.
///
/// Allows the user to set distance unit (metric/imperial), sort field
/// (distance/name/price), and sort order (ascending/descending).
class ListConfigScreen extends ConsumerWidget {
  const ListConfigScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final distanceUnit = ref.watch(distanceUnitProvider);
    final sortBy = ref.watch(sortByProvider);
    final sortAscending = ref.watch(sortAscendingProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('List Settings')),
      body: ListView(
        children: [
          // Distance unit section
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Distance Unit',
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          RadioGroup<String>(
            groupValue: distanceUnit,
            onChanged: (value) {
              if (value != null) {
                ref.read(distanceUnitProvider.notifier).state = value;
              }
            },
            child: const Column(
              children: [
                RadioListTile<String>(
                  title: Text('Kilometers (km)'),
                  value: 'metric',
                ),
                RadioListTile<String>(
                  title: Text('Miles (mi)'),
                  value: 'imperial',
                ),
              ],
            ),
          ),

          const Divider(height: 32),

          // Sort by section
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(
              'Sort By',
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          RadioGroup<String>(
            groupValue: sortBy,
            onChanged: (value) {
              if (value != null) {
                ref.read(sortByProvider.notifier).state = value;
              }
            },
            child: const Column(
              children: [
                RadioListTile<String>(
                  title: Text('Distance'),
                  value: 'distance',
                ),
                RadioListTile<String>(
                  title: Text('Name'),
                  value: 'name',
                ),
                RadioListTile<String>(
                  title: Text('Price'),
                  value: 'price',
                ),
              ],
            ),
          ),

          const Divider(height: 32),

          // Sort order section
          SwitchListTile(
            title: const Text('Ascending Order'),
            subtitle: Text(
              sortAscending ? 'A-Z / Low to High' : 'Z-A / High to Low',
            ),
            value: sortAscending,
            onChanged: (value) {
              ref.read(sortAscendingProvider.notifier).state = value;
            },
          ),
        ],
      ),
    );
  }
}
