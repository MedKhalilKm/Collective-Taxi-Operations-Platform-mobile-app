import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../models/entrance_model.dart';
import '../models/route_model.dart';
import '../models/station_model.dart';
import '../providers/auth_provider.dart';
import '../providers/seat_reservation_provider.dart';
import 'reservation_success_dialog.dart';
import 'sign_in_screen.dart';

class SeatReservationScreen extends StatefulWidget {
  final StationModel station;
  final RouteModel route;
  final EntranceModel entrance;
  final int remainingSeats;
  final int occupiedCount;

  const SeatReservationScreen({
    super.key,
    required this.station,
    required this.route,
    required this.entrance,
    required this.remainingSeats,
    required this.occupiedCount,
  });

  @override
  State<SeatReservationScreen> createState() => _SeatReservationScreenState();
}

class _SeatReservationScreenState extends State<SeatReservationScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final capacity = widget.entrance.vehicle?.capacity ?? 8;
      context.read<SeatReservationProvider>().init(
            capacity: capacity,
            occupiedCount: widget.occupiedCount,
            pricePerSeat: widget.route.fee,
          );
    });
  }

  void _handleUnauthorized() {
    context.read<AuthProvider>().logout();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const SignInScreen()),
      (route) => false,
    );
  }

  void _handleContinue() async {
    final seatProvider = context.read<SeatReservationProvider>();

    final success = await seatProvider.submitReservation(
      entranceId: widget.entrance.id,
    );

    if (!mounted) return;

    if (success && seatProvider.createdReservation != null) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => ReservationSuccessDialog(
          reservation: seatProvider.createdReservation!,
          totalPrice: seatProvider.totalPrice,
          stationName: widget.station.name,
          routeName: widget.route.name,
        ),
      );
    } else {
      final err = seatProvider.errorMessage ?? 'Reservation failed';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(err),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  String _formatTime(String rawDate) {
    try {
      final dt = DateTime.parse(rawDate).toLocal();
      final h = dt.hour.toString().padLeft(2, '0');
      final m = dt.minute.toString().padLeft(2, '0');
      return '$h:$m';
    } catch (_) {
      return '10:15';
    }
  }

  @override
  Widget build(BuildContext context) {
    final seatProvider = context.watch<SeatReservationProvider>();

    if (seatProvider.isUnauthorized) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        seatProvider.resetUnauthorized();
        _handleUnauthorized();
      });
    }

    final carBrand = widget.entrance.vehicle?.carBrand.trim().isNotEmpty == true
        ? widget.entrance.vehicle!.carBrand
        : 'Comfort Minivan';

    String driverLabel = 'Mohamed Ali';
    if (widget.entrance.driver != null && widget.entrance.driver!.id.isNotEmpty) {
      driverLabel = 'Driver #${widget.entrance.driver!.cin > 0 ? widget.entrance.driver!.cin : widget.entrance.driver!.id.substring(0, 6)}';
    }

    final departureTimeStr = _formatTime(widget.entrance.createdAt);
    final feeStr = widget.route.fee.truncateToDouble() == widget.route.fee
        ? widget.route.fee.toInt().toString()
        : widget.route.fee.toString();

    final totalPriceStr = seatProvider.totalPrice.truncateToDouble() == seatProvider.totalPrice
        ? seatProvider.totalPrice.toInt().toString()
        : seatProvider.totalPrice.toStringAsFixed(1);

    // Selected Seats Label (e.g. "Seat 1, Seat 3")
    final sortedSelected = seatProvider.selectedSeatNumbers.toList()..sort();
    final selectedSeatsText = sortedSelected.isNotEmpty
        ? sortedSelected.map((s) => 'Seat $s').join(', ')
        : 'None';

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Top Navigation Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: AppTheme.textDark,
                        size: 20,
                      ),
                      padding: EdgeInsets.zero,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Select Seats',
                          style: GoogleFonts.inter(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textDark,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$carBrand • $driverLabel',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: AppTheme.textMuted,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Scrollable Content Body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Trip Summary Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${widget.route.firstDestination} → ${widget.route.secondDestination} Express',
                                style: GoogleFonts.inter(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textDark,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Departure: Today • $departureTimeStr',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: AppTheme.textMuted,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '$feeStr DT / Seat',
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Choose your Seat(s) Section Title
                    Text(
                      'Choose your Seat(s)',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Minivan Seat Grid Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Legend Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildLegendItem(
                                color: Colors.white,
                                borderColor: AppTheme.inputBorder,
                                label: 'Available',
                              ),
                              const SizedBox(width: 16),
                              _buildLegendItem(
                                color: const Color(0xFFCBD5E1),
                                label: 'Occupied',
                              ),
                              const SizedBox(width: 16),
                              _buildLegendItem(
                                color: AppTheme.primaryYellow,
                                label: 'Selected',
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Minivan Seat Grid Layout
                          _buildMinivanGrid(seatProvider),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Number of Places Stepper Card & Pricing Summary
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Stepper Control Row
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Number of Places',
                                      style: GoogleFonts.inter(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.textDark,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Up to 4 seats per booking',
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        color: AppTheme.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Stepper Controls
                              Row(
                                children: [
                                  IconButton.filledTonal(
                                    onPressed: seatProvider.numberOfSeats > 1
                                        ? () => seatProvider.setSeatCount(
                                              seatProvider.numberOfSeats - 1,
                                            )
                                        : null,
                                    icon: const Icon(Icons.remove),
                                    style: IconButton.styleFrom(
                                      backgroundColor: const Color(0xFFF1F5F9),
                                      foregroundColor: AppTheme.textDark,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    child: Text(
                                      '${seatProvider.numberOfSeats}',
                                      style: GoogleFonts.inter(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.textDark,
                                      ),
                                    ),
                                  ),
                                  IconButton.filled(
                                    onPressed: seatProvider.numberOfSeats <
                                            seatProvider.maxAllowedSeats
                                        ? () => seatProvider.setSeatCount(
                                              seatProvider.numberOfSeats + 1,
                                            )
                                        : null,
                                    icon: const Icon(Icons.add),
                                    style: IconButton.styleFrom(
                                      backgroundColor: AppTheme.primaryYellow,
                                      foregroundColor: AppTheme.textDark,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          const Divider(height: 28),

                          // Selected Seats & Total Price Summary Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Selected Seats',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: AppTheme.textMuted,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    selectedSeatsText,
                                    style: GoogleFonts.inter(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.textDark,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'Total Price',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: AppTheme.textMuted,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '$totalPriceStr DT',
                                    style: GoogleFonts.inter(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.textDark,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Bottom CTA Button: Continue to Payment / Confirm
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: seatProvider.isSubmitting ? null : _handleContinue,
                  icon: seatProvider.isSubmitting
                      ? const SizedBox.shrink()
                      : const Icon(Icons.payment_rounded, size: 20),
                  label: seatProvider.isSubmitting
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: AppTheme.textDark,
                          ),
                        )
                      : const Text('Continue to Payment'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem({
    required Color color,
    Color? borderColor,
    required String label,
  }) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: borderColor != null
                ? Border.all(color: borderColor, width: 1.5)
                : null,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: AppTheme.textMuted,
          ),
        ),
      ],
    );
  }

  Widget _buildMinivanGrid(SeatReservationProvider provider) {
    final cap = provider.capacity;

    return Column(
      children: [
        // Front Row: Driver (Left) | Seat 1 (Right)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Driver Seat Box
            _buildDriverBox(),

            // Seat 1
            if (cap >= 1) _buildSeatBox(provider, 1, 'S1'),
          ],
        ),

        const SizedBox(height: 14),

        // AISLE Divider Text
        Text(
          'AISLE',
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            color: AppTheme.textHint,
          ),
        ),

        const SizedBox(height: 14),

        // Row 2: Seat 2 & Seat 3
        if (cap >= 3)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSeatBox(provider, 2, '2'),
              _buildSeatBox(provider, 3, '3'),
            ],
          ),

        if (cap >= 3) const SizedBox(height: 12),

        // Row 3: Seat 4 & Seat 5
        if (cap >= 5)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSeatBox(provider, 4, '4'),
              _buildSeatBox(provider, 5, '5'),
            ],
          ),

        if (cap >= 5) const SizedBox(height: 12),

        // Row 4: Seat 6, Seat 7, Seat 8
        if (cap >= 8)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildSeatBox(provider, 6, '6'),
              _buildSeatBox(provider, 7, '7'),
              _buildSeatBox(provider, 8, '8'),
            ],
          ),
      ],
    );
  }

  Widget _buildDriverBox() {
    return Column(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFCBD5E1)),
          ),
          child: const Icon(
            Icons.cancel_outlined,
            size: 20,
            color: AppTheme.textHint,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Driver',
          style: GoogleFonts.inter(
            fontSize: 10,
            color: AppTheme.textHint,
          ),
        ),
      ],
    );
  }

  Widget _buildSeatBox(
    SeatReservationProvider provider,
    int seatNumber,
    String label,
  ) {
    final isOccupied = seatNumber <= provider.occupiedCount;
    final isSelected = provider.selectedSeatNumbers.contains(seatNumber);

    Color bgColor = Colors.white;
    Color borderCol = AppTheme.inputBorder;
    Color textColor = AppTheme.textDark;

    if (isOccupied) {
      bgColor = const Color(0xFFCBD5E1);
      borderCol = const Color(0xFF94A3B8);
      textColor = const Color(0xFF64748B);
    } else if (isSelected) {
      bgColor = AppTheme.primaryYellow;
      borderCol = AppTheme.primaryYellowDark;
      textColor = AppTheme.textDark;
    }

    return GestureDetector(
      onTap: isOccupied ? null : () => provider.toggleSeatSelection(seatNumber),
      child: Column(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: borderCol, width: 1.5),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppTheme.primaryYellow.withValues(alpha: 0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'S$seatNumber',
            style: GoogleFonts.inter(
              fontSize: 10,
              color: AppTheme.textHint,
            ),
          ),
        ],
      ),
    );
  }
}
