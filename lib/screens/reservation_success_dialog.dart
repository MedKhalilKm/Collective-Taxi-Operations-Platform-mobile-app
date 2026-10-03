import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_theme.dart';
import '../models/reservation_model.dart';
import 'main_navigation_screen.dart';

class ReservationSuccessDialog extends StatelessWidget {
  final ReservationModel reservation;
  final double totalPrice;
  final String stationName;
  final String routeName;

  const ReservationSuccessDialog({
    super.key,
    required this.reservation,
    required this.totalPrice,
    required this.stationName,
    required this.routeName,
  });

  @override
  Widget build(BuildContext context) {
    final priceStr = totalPrice.truncateToDouble() == totalPrice
        ? totalPrice.toInt().toString()
        : totalPrice.toStringAsFixed(1);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      elevation: 0,
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Success Check Icon
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFFE6F9ED),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF27AE60), width: 2),
              ),
              child: const Icon(
                Icons.check_rounded,
                size: 44,
                color: Color(0xFF27AE60),
              ),
            ),
            const SizedBox(height: 20),

            Text(
              'Reservation Confirmed!',
              style: GoogleFonts.inter(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Your seats have been reserved successfully.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppTheme.textMuted,
              ),
            ),
            const SizedBox(height: 20),

            // Reservation Summary Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.backgroundColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.inputBorder),
              ),
              child: Column(
                children: [
                  _buildSummaryRow('Reference', reservation.reservationRef),
                  const Divider(height: 16),
                  _buildSummaryRow('Station', stationName),
                  const SizedBox(height: 8),
                  _buildSummaryRow('Line', routeName),
                  const SizedBox(height: 8),
                  _buildSummaryRow(
                    'Seats Reserved',
                    '${reservation.numberOfSeats} ${reservation.numberOfSeats == 1 ? 'seat' : 'seats'}',
                  ),
                  const Divider(height: 16),
                  _buildSummaryRow('Total Paid', '$priceStr DT', isBold: true),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Back to Main Menu Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (_) => const MainNavigationScreen(initialTab: 0),
                    ),
                    (route) => false,
                  );
                },
                child: const Text('Back to Main Menu'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            color: AppTheme.textMuted,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: isBold ? AppTheme.primaryYellowDark : AppTheme.textDark,
          ),
        ),
      ],
    );
  }
}
