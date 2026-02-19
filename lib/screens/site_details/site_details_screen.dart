import 'package:flutter/material.dart';
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
/// Hero image with photo gallery, info chips, sticky "Request Valet" CTA,
/// About section, and call button.
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
      // Sticky bottom CTA
      bottomNavigationBar: _StickyBottomBar(
        location: location,
        onRequestValet: () => _showDisclaimerSheet(context, location),
        onCall: location.phone != null
            ? () => _callLocation(location.phone!)
            : null,
      ),
      body: CustomScrollView(
        slivers: [
          // Clean hero image — no title overlay
          SliverAppBar(
            expandedHeight: 280,
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
                      color: isFavorite ? Colors.redAccent : Colors.white,
                    ),
                    onPressed: () {
                      ref.read(favoriteSitesProvider.notifier).toggle(siteId);
                    },
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: imageUrl != null
                  ? GestureDetector(
                      onTap: () => _showFullScreenPhoto(context, imageUrl),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, progress) {
                              if (progress == null) return child;
                              return Container(
                                color: theme.colorScheme.surfaceContainerHighest,
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            },
                            errorBuilder: (_, __, ___) =>
                                _imagePlaceholder(theme),
                          ),
                          // Bottom gradient for edge blending
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            height: 80,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withValues(alpha: 0.4),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // Photo count badge
                          if (photos.length > 1)
                            Positioned(
                              bottom: 12,
                              right: 16,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.photo_library,
                                        color: Colors.white, size: 14),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${photos.length} photos',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    )
                  : _imagePlaceholder(theme),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name + price
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          location.name,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (location.price != null) ...[
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.light.secondary,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '\$${location.price!.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Info chips row
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (location.address != null)
                        _InfoChip(
                          icon: Icons.location_on_outlined,
                          label: location.address!,
                        ),
                      if (location.company != null)
                        _InfoChip(
                          icon: Icons.business_outlined,
                          label: location.company!,
                        ),
                      if (location.phone != null)
                        _InfoChip(
                          icon: Icons.phone_outlined,
                          label: location.phone!,
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Photo gallery (horizontal scroll) if multiple photos
                  if (photos.length > 1) ...[
                    Text(
                      'Photos',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 100,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: photos.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () =>
                                _showFullScreenPhoto(context, photos[index]),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                photos[index],
                                width: 130,
                                height: 100,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  width: 130,
                                  height: 100,
                                  color: theme
                                      .colorScheme.surfaceContainerHighest,
                                  child: const Icon(Icons.broken_image),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // About section
                  if (location.bio != null && location.bio!.isNotEmpty) ...[
                    Card(
                      margin: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Stack(
                        children: [
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
                                Row(
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      size: 18,
                                      color: AppColors.light.secondary,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'About',
                                      style:
                                          theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  location.bio!,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    height: 1.5,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Bottom spacing for sticky bar
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _imagePlaceholder(ThemeData theme) {
    return Container(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Center(
        child: Icon(
          Icons.local_parking_rounded,
          size: 64,
          color: theme.colorScheme.onSurfaceVariant,
        ),
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
            imageProvider: NetworkImage(imageUrl),
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 2,
          ),
        ),
      ),
    );
  }

  void _showDisclaimerSheet(BuildContext context, ValetLocation location) {
    final parentContext = context;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        final theme = Theme.of(sheetContext);
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(sheetContext).padding.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Icon(
                Icons.local_parking_rounded,
                size: 48,
                color: AppColors.light.secondary,
              ),
              const SizedBox(height: 12),
              Text(
                'Request Valet Service',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                location.name,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),

              // Price breakdown
              if (location.price != null)
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Service Fee',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        '\$${location.price!.toStringAsFixed(2)} ${location.currency ?? 'USD'}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 20),

              // Continue button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(sheetContext);
                    parentContext.push('/addCars?id=${location.id}');
                  },
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
                  child: const Text('Continue'),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.pop(sheetContext),
                child: const Text('Cancel'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _callLocation(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}

/// Info chip showing an icon + label in a subtle pill.
class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.light.secondaryText),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.light.secondaryText,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// Sticky bottom bar with "Request Valet" CTA and optional call button.
class _StickyBottomBar extends StatelessWidget {
  final ValetLocation location;
  final VoidCallback onRequestValet;
  final VoidCallback? onCall;

  const _StickyBottomBar({
    required this.location,
    required this.onRequestValet,
    this.onCall,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, bottomPadding + 12),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (onCall != null) ...[
            SizedBox(
              height: 50,
              width: 50,
              child: OutlinedButton(
                onPressed: onCall,
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Icon(Icons.phone),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: onRequestValet,
                icon: const Icon(Icons.local_parking_rounded),
                label: const Text('Request Valet'),
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
              ),
            ),
          ),
        ],
      ),
    );
  }
}
