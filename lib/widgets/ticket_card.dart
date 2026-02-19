import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';

import '../config/asset_paths.dart';
import '../config/theme/app_colors.dart';
import '../models/my_car.dart';
import '../models/ticket.dart';
import 'gradient_background.dart';

/// Branded ticket card widget with dark navy upper half and white lower half.
///
/// Upper section: Valet One logo, animated status badge, location info.
/// Lower section: White with barcode + PIN or contextual status message.
class TicketCard extends StatelessWidget {
  final Ticket ticket;
  final String? locationName;
  final String? locationAddress;
  final bool showPin;
  final MyCar? vehicle;

  const TicketCard({
    super.key,
    required this.ticket,
    this.locationName,
    this.locationAddress,
    this.showPin = true,
    this.vehicle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildUpperSection(context),
            _buildDivider(),
            _buildLowerSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildUpperSection(BuildContext context) {
    final created = ticket.createdAt;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
      color: AppColors.light.secondary,
      child: Column(
        children: [
          // Valet One logo
          Image.asset(
            AssetPaths.valetOneLogo,
            height: 32,
            errorBuilder: (_, __, ___) => const Text(
              'VALET ONE',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Status badge with pulsing live dot
          _AnimatedStatusBadge(
            status: ticket.status,
            label: _statusLabel(ticket.status),
            color: _statusColor(ticket.status),
          ),
          const SizedBox(height: 16),

          // Location name
          if (locationName != null)
            Text(
              locationName!,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

          // Address
          if (locationAddress != null) ...[
            const SizedBox(height: 4),
            Text(
              locationAddress!,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
          ],

          // Time and Date
          if (created != null) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _infoChip(Icons.access_time, _formatTime(created)),
                const SizedBox(width: 16),
                _infoChip(Icons.calendar_today, _formatDate(created)),
              ],
            ),
          ],

          // Vehicle info
          if (vehicle != null && vehicle!.isNotEmpty) ...[
            const SizedBox(height: 10),
            _buildVehicleRow(),
          ],

          // Ticket number (truncated)
          if (ticket.ticketNumber != null) ...[
            const SizedBox(height: 8),
            Text(
              'Ticket ${_shortId(ticket.ticketNumber!)}',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 11,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildVehicleRow() {
    final parts = <String>[];
    final makeModel = [vehicle?.make, vehicle?.model]
        .where((s) => s != null && s.isNotEmpty)
        .join(' ');
    if (makeModel.isNotEmpty) parts.add(makeModel);
    if (vehicle?.color != null && vehicle!.color!.isNotEmpty) {
      parts.add(vehicle!.color!);
    }
    if (vehicle?.plate != null && vehicle!.plate!.isNotEmpty) {
      parts.add(vehicle!.plate!);
    }

    if (parts.isEmpty) return const SizedBox.shrink();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.directions_car_outlined,
          color: Colors.white.withValues(alpha: 0.6),
          size: 14,
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            parts.join(' \u2022 '),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 12,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    // Perforated edge effect — notch color matches gradient background
    return SizedBox(
      height: 16,
      child: Stack(
        children: [
          // Top half navy, bottom half white
          Column(
            children: [
              Expanded(child: Container(color: AppColors.light.secondary)),
              Expanded(child: Container(color: Colors.white)),
            ],
          ),
          // Notch circles match the gradient background
          Positioned(
            left: -8,
            top: 0,
            child: Container(
              width: 16,
              height: 16,
              decoration: const BoxDecoration(
                color: GradientBackground.deepPurple,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            right: -8,
            top: 0,
            child: Container(
              width: 16,
              height: 16,
              decoration: const BoxDecoration(
                color: GradientBackground.deepPurple,
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Dashed line across center
          Center(
            child: Row(
              children: List.generate(
                20,
                (i) => Expanded(
                  child: Container(
                    height: 1,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    color: i.isEven
                        ? Colors.grey.withValues(alpha: 0.3)
                        : Colors.transparent,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLowerSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      color: Colors.white,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Faded watermark
          Positioned.fill(
            child: Center(
              child: Opacity(
                opacity: 0.05,
                child: Image.asset(
                  AssetPaths.valetOneLogoBlack,
                  width: 200,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
            ),
          ),
          // Barcode + PIN (only during Arrival phases)
          Column(
            children: [
              if (!showPin)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    children: [
                      Icon(
                        ticket.status == Ticket.statusDeparture
                            ? Icons.directions_car_rounded
                            : Icons.local_parking_rounded,
                        size: 48,
                        color: AppColors.light.secondary.withValues(alpha: 0.3),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _cardMessage(ticket.status),
                        style: TextStyle(
                          color: AppColors.light.secondaryText,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                )
              else if (ticket.pin != null && ticket.pin!.isNotEmpty) ...[
                BarcodeWidget(
                  barcode: Barcode.code128(),
                  data: ticket.pin!,
                  width: 220,
                  height: 70,
                  drawText: false,
                  color: AppColors.light.secondary,
                ),
                const SizedBox(height: 8),
                Text(
                  ticket.pin!,
                  style: TextStyle(
                    color: AppColors.light.secondary,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 6,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'YOUR PIN',
                  style: TextStyle(
                    color: AppColors.light.secondaryText,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 2,
                  ),
                ),
              ] else
                // Shimmer placeholder while PIN loads
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    children: [
                      // Fake barcode shimmer
                      Container(
                        width: 220,
                        height: 70,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: Colors.grey.shade200,
                        ),
                        child: const _ShimmerEffect(),
                      ),
                      const SizedBox(height: 12),
                      // Fake PIN shimmer
                      Container(
                        width: 140,
                        height: 24,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: Colors.grey.shade200,
                        ),
                        child: const _ShimmerEffect(),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'GENERATING PIN...',
                        style: TextStyle(
                          color: AppColors.light.secondaryText,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white70, size: 14),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(color: Colors.white70, fontSize: 13),
        ),
      ],
    );
  }

  /// Truncates long IDs (UUIDs) to `#...last8chars`.
  String _shortId(String id) {
    if (id.length <= 12) return '#$id';
    return '#...${id.substring(id.length - 8)}';
  }

  Color _statusColor(String status) {
    return switch (status) {
      Ticket.statusArrival => Colors.amber.shade700,
      Ticket.statusProcessingArrival => Colors.blue,
      Ticket.statusParked => Colors.teal,
      Ticket.statusProcessing => Colors.deepOrange,
      Ticket.statusDeparture => Colors.orange,
      Ticket.statusDeparted => Colors.orange.shade800,
      Ticket.statusProcessingDeparture => Colors.deepOrange,
      Ticket.statusCompleted => Colors.green,
      Ticket.statusCancelled => Colors.grey,
      _ => Colors.blue,
    };
  }

  String _statusLabel(String status) {
    return switch (status) {
      Ticket.statusArrival => 'Arriving',
      Ticket.statusProcessingArrival => 'Processing Arrival',
      Ticket.statusParked => 'Parked',
      Ticket.statusProcessing => 'Valet On The Way',
      Ticket.statusDeparture => 'Departing',
      Ticket.statusDeparted => 'On The Way',
      Ticket.statusProcessingDeparture => 'Bringing Your Car',
      Ticket.statusCompleted => 'Completed',
      Ticket.statusCancelled => 'Cancelled',
      _ => status,
    };
  }

  String _cardMessage(String status) {
    return switch (status) {
      Ticket.statusProcessingArrival => 'Your valet is parking your car',
      Ticket.statusParked => 'Your car is safely parked',
      Ticket.statusDeparture => 'Pick up requested',
      _ => 'Your car is safely parked',
    };
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour > 12 ? dt.hour - 12 : dt.hour;
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '${hour == 0 ? 12 : hour}:${dt.minute.toString().padLeft(2, '0')} $period';
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }
}

/// Animated status badge with a pulsing live dot.
class _AnimatedStatusBadge extends StatefulWidget {
  final String status;
  final String label;
  final Color color;

  const _AnimatedStatusBadge({
    required this.status,
    required this.label,
    required this.color,
  });

  @override
  State<_AnimatedStatusBadge> createState() => _AnimatedStatusBadgeState();
}

class _AnimatedStatusBadgeState extends State<_AnimatedStatusBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLive = widget.status != Ticket.statusCompleted &&
        widget.status != Ticket.statusCancelled;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      decoration: BoxDecoration(
        color: widget.color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isLive) ...[
            AnimatedBuilder(
              animation: _animation,
              builder: (_, __) => Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: _animation.value),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withValues(alpha: _animation.value * 0.5),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 6),
          ],
          Text(
            widget.label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Simple shimmer effect for loading placeholders.
class _ShimmerEffect extends StatefulWidget {
  const _ShimmerEffect();

  @override
  State<_ShimmerEffect> createState() => _ShimmerEffectState();
}

class _ShimmerEffectState extends State<_ShimmerEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Colors.grey.shade200,
                Colors.grey.shade100,
                Colors.grey.shade200,
              ],
              stops: [
                (_controller.value - 0.3).clamp(0.0, 1.0),
                _controller.value,
                (_controller.value + 0.3).clamp(0.0, 1.0),
              ],
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcATop,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }
}
