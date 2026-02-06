import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/app_state_provider.dart';
import '../../providers/locations_provider.dart';
import '../../utils/distance.dart';
import '../../widgets/location_card.dart';

/// Screen displaying the user's favorite valet locations.
///
/// Filters the global locations list by the IDs stored in
/// [favoriteSitesProvider]. Each card navigates to the site details screen.
class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoriteIds = ref.watch(favoriteSitesProvider);
    final allLocations = ref.watch(locationsProvider);
    final userLocation = ref.watch(userLocationProvider);
    final distanceUnit = ref.watch(distanceUnitProvider) == 'metric' ? 'km' : 'mi';

    final favorites = allLocations
        .where((loc) => favoriteIds.contains(loc.id))
        .toList();

    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Favorites')),
      body: favorites.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 64,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No favorite locations yet',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap the heart icon on a location to save it here.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final loc = favorites[index];
                final distance = (userLocation != null &&
                        loc.latitude != null &&
                        loc.longitude != null)
                    ? calculateDistance(
                        userLocation.$1,
                        userLocation.$2,
                        loc.latitude!,
                        loc.longitude!,
                        distanceUnit,
                      )
                    : '--';
                return LocationCard(
                  location: loc,
                  distance: distance,
                  onTap: () => context.push('/siteDetails?id=${loc.id}'),
                );
              },
            ),
    );
  }
}
