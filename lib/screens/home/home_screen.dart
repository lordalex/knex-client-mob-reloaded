import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../config/app_constants.dart';
import '../../config/asset_paths.dart';
import '../../config/theme/app_colors.dart';
import '../../models/location.dart';
import '../../providers/api_provider.dart';
import '../../providers/app_state_provider.dart';
import '../../providers/flow_manager_provider.dart';
import '../../providers/locations_provider.dart';
import '../../providers/profile_provider.dart';
import '../../services/api/endpoints.dart';
import '../../services/location_service.dart';
import '../../utils/distance.dart';
import '../../widgets/error_state.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/location_card.dart';

/// Main home screen displaying available valet locations.
///
/// On first build, runs the FlowManager check to determine routing
/// (profileCreate, ticket, or home). Then fetches locations, GPS,
/// and displays them in a sorted list.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;
  bool _flowChecked = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _runFlowCheck();
    });
  }

  Future<void> _runFlowCheck() async {
    if (_flowChecked) {
      _loadLocations();
      return;
    }

    final flowResult = await ref.read(flowManagerProvider.future);

    if (!mounted) return;

    if (flowResult == '/profileCreate') {
      context.go('/profileCreate');
      return;
    }
    if (flowResult == '/ticket') {
      context.go('/ticket');
      return;
    }

    _flowChecked = true;
    _loadLocations();
  }

  Future<void> _loadLocations() async {
    debugPrint('[HomeScreen] _loadLocations called');
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final apiClient = ref.read(apiClientProvider);
      final profile = ref.read(userProfileProvider);

      debugPrint('[HomeScreen] Fetching locations for profile id: ${profile?.id}');
      final response = await apiClient.post<List<ValetLocation>>(
        Endpoints.getLocations,
        data: profile?.id != null ? {'userClientId': profile!.id} : null,
        fromData: (json) {
          debugPrint('[HomeScreen] RAW LOCATIONS TYPE: ${json.runtimeType}');
          // Handle {data: [...]} wrapper if present
          dynamic payload = json;
          if (payload is Map<String, dynamic> && payload.containsKey('data')) {
            payload = payload['data'];
          }
          if (payload is List) {
            final locations = payload
                .whereType<Map<String, dynamic>>()
                .map((e) => ValetLocation.fromJson(e))
                .toList();
            debugPrint('[HomeScreen] Parsed ${locations.length} locations');
            return locations;
          }
          return <ValetLocation>[];
        },
      );

      debugPrint('[HomeScreen] Locations response — status: ${response.status}, '
          'isSuccess: ${response.isSuccess}, '
          'hasData: ${response.data != null}, count: ${response.data?.length}, '
          'message: ${response.message}');

      if (!mounted) return;

      if (response.isSuccess && response.data != null) {
        ref.read(locationsProvider.notifier).state = response.data!;
        setState(() {
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = response.message;
        });
      }

      // Fetch GPS in the background (don't block UI)
      _fetchGps();
    } catch (e) {
      debugPrint('[HomeScreen] Failed to load locations: $e');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _fetchGps() async {
    try {
      final locationService = LocationService();
      final gpsResult = await locationService.getCurrentLocation();
      debugPrint('[HomeScreen] GPS result: $gpsResult');
      if (gpsResult != null && mounted) {
        ref.read(userLocationProvider.notifier).state = gpsResult;
      }
    } catch (e) {
      debugPrint('[HomeScreen] GPS failed (non-fatal): $e');
    }
  }

  List<ValetLocation> _sortLocations(List<ValetLocation> locations) {
    final userLoc = ref.read(userLocationProvider);
    final sortBy = ref.read(sortByProvider);
    final ascending = ref.read(sortAscendingProvider);
    final unit = ref.read(distanceUnitProvider) == 'imperial' ? 'mi' : 'km';

    final sorted = List<ValetLocation>.from(locations);

    sorted.sort((a, b) {
      int result;
      switch (sortBy) {
        case 'name':
          result = a.name.toLowerCase().compareTo(b.name.toLowerCase());
        case 'price':
          result = (a.price ?? 0).compareTo(b.price ?? 0);
        case 'distance':
        default:
          if (userLoc == null) {
            result = 0;
          } else {
            final distA = _rawDistance(a, userLoc, unit);
            final distB = _rawDistance(b, userLoc, unit);
            result = distA.compareTo(distB);
          }
      }
      return ascending ? result : -result;
    });

    return sorted;
  }

  double _rawDistance(
    ValetLocation loc,
    (double, double) userLoc,
    String unit,
  ) {
    final lat = loc.latitude ?? AppConstants.defaultLatitude;
    final lng = loc.longitude ?? AppConstants.defaultLongitude;
    final distStr = calculateDistance(userLoc.$1, userLoc.$2, lat, lng, unit);
    return double.tryParse(distStr.split(' ').first) ?? 0;
  }

  String _getDistance(ValetLocation loc) {
    final userLoc = ref.read(userLocationProvider);
    final unit = ref.read(distanceUnitProvider) == 'imperial' ? 'mi' : 'km';

    if (userLoc == null) return '--';

    final lat = loc.latitude ?? AppConstants.defaultLatitude;
    final lng = loc.longitude ?? AppConstants.defaultLongitude;
    return calculateDistance(userLoc.$1, userLoc.$2, lat, lng, unit);
  }

  @override
  Widget build(BuildContext context) {
    // Watch sort/distance providers to rebuild when they change
    ref.watch(sortByProvider);
    ref.watch(sortAscendingProvider);
    ref.watch(distanceUnitProvider);
    ref.watch(userLocationProvider);

    debugPrint('[HomeScreen] build() — isLoading=$_isLoading, hasError=$_hasError');

    if (_isLoading) {
      return const Scaffold(body: LoadingIndicator());
    }

    if (_hasError) {
      return Scaffold(
        body: ErrorStateWidget(
          title: 'Oops!',
          message: _errorMessage ?? 'Failed to load locations.',
          onRetry: _loadLocations,
          onSecondaryAction: () => ref.read(locationsProvider.notifier).state = [],
          secondaryLabel: 'Dismiss',
        ),
      );
    }

    final locations = ref.watch(locationsProvider);
    final sorted = _sortLocations(locations);
    final theme = Theme.of(context);

    final topPadding = MediaQuery.of(context).padding.top;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: RefreshIndicator(
          onRefresh: _loadLocations,
          child: CustomScrollView(
            slivers: [
              // Dark navy header that bleeds into the Dynamic Island / status bar
              SliverToBoxAdapter(
                child: Container(
                  color: AppColors.light.secondary,
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: topPadding + 12,
                      left: 20,
                      right: 20,
                      bottom: 16,
                    ),
                    child: Text(
                      'Request valet?',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),

              // Promo carousel
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: CarouselSlider(
                    options: CarouselOptions(
                      height: 160,
                      autoPlay: true,
                      autoPlayInterval: const Duration(seconds: 5),
                      enlargeCenterPage: true,
                      viewportFraction: 0.85,
                    ),
                    items: _buildBanners(theme),
                  ),
                ),
              ),

              // Section header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Valet locations available near you',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.tune),
                        onPressed: () => context.push('/listConfig'),
                      ),
                    ],
                  ),
                ),
              ),

              // Location list
              if (sorted.isEmpty)
                const SliverFillRemaining(
                  child: Center(
                    child: Text('No locations found nearby.'),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final loc = sorted[index];
                      return LocationCard(
                        location: loc,
                        distance: _getDistance(loc),
                        onTap: () =>
                            context.push('/siteDetails?id=${loc.id}'),
                      );
                    },
                    childCount: sorted.length,
                  ),
                ),

              // Bottom padding
              const SliverPadding(padding: EdgeInsets.only(bottom: 16)),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildBanners(ThemeData theme) {
    final banners = [
      (
        'Request valet?',
        'Find your nearest\npremium valet',
        AppColors.light.secondary,
        AssetPaths.valetOneLogo,
      ),
      (
        'Skip the hassle',
        'Premium parking\nat your fingertips',
        AppColors.light.tertiary,
        AssetPaths.knexLogoWhite,
      ),
      (
        'Tip your valet',
        'Show appreciation\nwith a quick tip',
        const Color(0xFF0A2647),
        AssetPaths.valetOneLogo,
      ),
      (
        'Save favorites',
        'Quick access to\nyour top spots',
        const Color(0xFF144272),
        AssetPaths.knexLogoWhite,
      ),
    ];

    return banners.map((banner) {
      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: banner.$3,
        ),
        child: Stack(
          children: [
            // Faded logo watermark
            Positioned(
              right: -10,
              bottom: -10,
              child: Opacity(
                opacity: 0.1,
                child: Image.asset(
                  banner.$4,
                  width: 140,
                  height: 140,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    banner.$1,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    banner.$2,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }).toList();
  }
}
