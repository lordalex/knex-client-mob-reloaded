import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';

import '../config/asset_paths.dart';
import '../config/theme/app_colors.dart';
import '../models/ticket.dart';

/// Branded ticket card widget with dark navy upper half and white lower half.
///
/// Upper section: Valet One logo, location name, address, time/date in white.
/// Lower section: White with faded Valet One watermark, barcode, PIN.
class TicketCard extends StatelessWidget {
  final Ticket ticket;
  final String? locationName;
  final String? locationAddress;

  const TicketCard({
    super.key,
    required this.ticket,
    this.locationName,
    this.locationAddress,
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

          // Status badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: _statusColor(ticket.status),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _statusLabel(ticket.status),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
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

          // Ticket number
          if (ticket.ticketNumber != null) ...[
            const SizedBox(height: 8),
            Text(
              'Ticket #${ticket.ticketNumber}',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDivider() {
    // Perforated edge effect
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
          // Notch circles
          Positioned(
            left: -8,
            top: 0,
            child: Container(
              width: 16,
              height: 16,
              decoration: const BoxDecoration(
                color: Color(0xFF2D1B69), // matches gradient
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
                color: Color(0xFF2D1B69),
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
          // Barcode + PIN
          Column(
            children: [
              if (ticket.pin != null && ticket.pin!.isNotEmpty) ...[
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
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    'Awaiting PIN...',
                    style: TextStyle(
                      color: AppColors.light.secondaryText,
                      fontSize: 16,
                    ),
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

  Color _statusColor(String status) {
    return switch (status) {
      Ticket.statusArrival => Colors.amber.shade700,
      Ticket.statusProcessingArrival => Colors.blue,
      Ticket.statusParked => Colors.teal,
      Ticket.statusDeparture => Colors.orange,
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
      Ticket.statusDeparture => 'Departing',
      Ticket.statusProcessingDeparture => 'Bringing Your Car',
      Ticket.statusCompleted => 'Completed',
      Ticket.statusCancelled => 'Cancelled',
      _ => status,
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
