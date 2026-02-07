import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:photo_view/photo_view.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../config/asset_paths.dart';
import '../../config/theme/app_colors.dart';
import '../../models/location.dart';
import '../../providers/app_state_provider.dart';
import '../../providers/locations_provider.dart';
import '../../widgets/error_state.dart';

/// Screen displaying details for a specific valet location.
///
/// Shows hero image via SliverAppBar, name, address, rating, action buttons,
/// bio/description in a card, favorite toggle, and full-width favorite button.
class SiteDetailsScreen extends ConsumerWidget {
  final String siteId;

  const SiteDetailsScreen({super.key, required this.siteId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locations = ref.watch(locationsProvider);
    final location = locations.where((l) => l.id == siteId).firstOrNull;

    if (location == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Site Details')),
        body: ErrorStateWidget(
          title: 'Location not found',
          message: 'We could not find the requested location.',
          onRetry: () => context.pop(),
          secondaryLabel: 'Go Back',
          onSecondaryAction: () => context.pop(),
        ),
      );
    }

    final theme = Theme.of(context);
    final photos = location.photos;
    final imageUrl = photos.isNotEmpty ? photos.first : null;
    final favorites = ref.watch(favoriteSitesProvider);
    final isFavorite = favorites.contains(siteId);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Hero image app bar — tints dark navy when collapsed
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            backgroundColor: AppColors.light.secondary,
            foregroundColor: Colors.white,
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: CircleAvatar(
                backgroundColor: Colors.black45,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => context.pop(),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: CircleAvatar(
                  backgroundColor: Colors.black45,
                  child: IconButton(
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? theme.colorScheme.primary : Colors.white,
                    ),
                    onPressed: () {
                      ref.read(favoriteSitesProvider.notifier).toggle(siteId);
                    },
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Details',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  shadows: [
                    Shadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
              background: imageUrl != null
                  ? GestureDetector(
                      onTap: () => _showFullScreenPhoto(context, imageUrl),
                      child: CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: theme.colorScheme.surfaceContainerHighest,
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: theme.colorScheme.surfaceContainerHighest,
                          child: Icon(
                            Icons.local_parking,
                            size: 64,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    )
                  : Container(
                      color: theme.colorScheme.surfaceContainerHighest,
                      child: Icon(
                        Icons.local_parking,
                        size: 64,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name + badge
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          location.name,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Primary Site',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Address
                  if (location.address != null)
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 16,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            location.address!,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 8),

                  // Company
                  if (location.company != null)
                    Text(
                      location.company!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  const SizedBox(height: 12),

                  // Rating bar
                  RatingBarIndicator(
                    rating: 4.5,
                    itemBuilder: (context, _) => Icon(
                      Icons.star,
                      color: theme.colorScheme.primary,
                    ),
                    itemCount: 5,
                    itemSize: 24,
                  ),
                  const SizedBox(height: 8),

                  // Price
                  if (location.price != null)
                    Text(
                      'Service: \$${location.price!.toStringAsFixed(2)} ${location.currency ?? 'USD'}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  const SizedBox(height: 20),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () =>
                              _showDisclaimerDialog(context, location),
                          icon: const Icon(Icons.local_parking),
                          label: const Text('Request Valet'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.light.secondary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: location.phone != null
                              ? () => _callLocation(location.phone!)
                              : null,
                          icon: const Icon(Icons.phone),
                          label: const Text('Call'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Bio/description — wrapped in card with watermark
                  if (location.bio != null && location.bio!.isNotEmpty) ...[
                    Card(
                      margin: EdgeInsets.zero,
                      child: Stack(
                        children: [
                          // Faded Valet One watermark
                          Positioned(
                            right: -20,
                            bottom: -10,
                            child: Opacity(
                              opacity: 0.04,
                              child: Image.asset(
                                AssetPaths.valetOneLogoBlack,
                                width: 120,
                                errorBuilder: (_, __, ___) =>
                                    const SizedBox.shrink(),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'About',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  location.bio!,
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),

                  // Full-width Favorite Site button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        ref.read(favoriteSitesProvider.notifier).toggle(siteId);
                      },
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        size: 20,
                      ),
                      label: Text(
                        isFavorite ? 'Remove from Favorites' : 'Favorite Site',
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: isFavorite
                            ? theme.colorScheme.primary
                            : AppColors.light.secondary,
                        side: BorderSide(
                          color: isFavorite
                              ? theme.colorScheme.primary
                              : AppColors.light.secondary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFullScreenPhoto(BuildContext context, String imageUrl) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          backgroundColor: Colors.black,
          body: PhotoView(
            imageProvider: CachedNetworkImageProvider(imageUrl),
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 2,
          ),
        ),
      ),
    );
  }

  void _showDisclaimerDialog(BuildContext context, ValetLocation location) {
    final parentContext = context;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Valet Service'),
        content: Text(
          'You are about to request valet parking at ${location.name}. '
          '${location.price != null ? 'The service fee is \$${location.price!.toStringAsFixed(2)}. ' : ''}'
          'Do you wish to continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              print('[SiteDetails] Navigating to /addCars?id=${location.id}');
              parentContext.push('/addCars?id=${location.id}');
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  Future<void> _callLocation(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}
