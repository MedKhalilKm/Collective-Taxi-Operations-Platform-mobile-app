import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../models/route_model.dart';
import '../models/station_model.dart';
import '../models/vehicle_departure_vm.dart';
import '../providers/auth_provider.dart';
import '../providers/available_vehicles_provider.dart';
import 'seat_reservation_screen.dart';
import 'sign_in_screen.dart';

class AvailableVehiclesScreen extends StatefulWidget {
  final StationModel station;
  final RouteModel route;

  const AvailableVehiclesScreen({
    super.key,
    required this.station,
    required this.route,
  });

  @override
  State<AvailableVehiclesScreen> createState() => _AvailableVehiclesScreenState();
}

class _AvailableVehiclesScreenState extends State<AvailableVehiclesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AvailableVehiclesProvider>().fetchAvailableVehicles(
            stationId: widget.station.id,
            route: widget.route,
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

  @override
  Widget build(BuildContext context) {
    final vehiclesProvider = context.watch<AvailableVehiclesProvider>();

    if (vehiclesProvider.isUnauthorized) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        vehiclesProvider.resetUnauthorized();
        _handleUnauthorized();
      });
    }

    final routeLineTitle = widget.route.routeNumber > 0
        ? 'Line T-${widget.route.routeNumber} • ${widget.route.firstDestination} to ${widget.route.secondDestination}'
        : 'Line ${widget.route.name} • ${widget.route.firstDestination} to ${widget.route.secondDestination}';

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Top Navigation Bar with Back Button & Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  // Back Button
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
                  // Station Header Title & Subtitle
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.station.name,
                          style: GoogleFonts.inter(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textDark,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Available Vehicles for ${widget.route.name}',
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

            // Main Content Area
            Expanded(
              child: RefreshIndicator(
                color: AppTheme.primaryYellowDark,
                backgroundColor: Colors.white,
                onRefresh: () => vehiclesProvider.fetchAvailableVehicles(
                  stationId: widget.station.id,
                  route: widget.route,
                ),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Route Summary Banner Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
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
                          children: [
                            Container(
                              width: 4,
                              height: 24,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE53935),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                routeLineTitle,
                                style: GoogleFonts.inter(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textDark,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Departures Today Header Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Departures Today',
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textDark,
                            ),
                          ),
                          Text(
                            'Filter by Time',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: AppTheme.textMuted,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Departures List / Content States
                      _buildDeparturesContent(vehiclesProvider),
                      const SizedBox(height: 20),

                      // Safety Notice Footer
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade50.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.amber.shade200.withValues(alpha: 0.8),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.verified_user_outlined,
                              size: 18,
                              color: AppTheme.primaryYellowDark,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'All vehicles are licensed, sanitised and GPS-tracked.',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.amber.shade900,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeparturesContent(AvailableVehiclesProvider provider) {
    if (provider.isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40),
          child: CircularProgressIndicator(
            color: AppTheme.primaryYellowDark,
          ),
        ),
      );
    }

    if (provider.errorMessage != null && provider.departures.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Column(
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 52,
                color: Colors.redAccent,
              ),
              const SizedBox(height: 14),
              Text(
                provider.errorMessage!,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppTheme.textMuted,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => provider.fetchAvailableVehicles(
                  stationId: widget.station.id,
                  route: widget.route,
                ),
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (provider.departures.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Column(
            children: [
              const Icon(
                Icons.directions_car_outlined,
                size: 56,
                color: AppTheme.textHint,
              ),
              const SizedBox(height: 16),
              Text(
                'No vehicles available',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'There are no active vehicle departures for this line right now.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppTheme.textMuted,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: provider.departures.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final vm = provider.departures[index];
        return _buildVehicleCard(vm);
      },
    );
  }

  Widget _buildVehicleCard(VehicleDepartureVm vm) {
    final feeStr = vm.fee.truncateToDouble() == vm.fee
        ? vm.fee.toInt().toString()
        : vm.fee.toString();

    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Departure Time Chip, Vehicle Title & Status Chip
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  vm.departureTime,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                vm.carBrand,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE6F9ED),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  vm.statusLabel,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF27AE60),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Driver Name Subtitle
          Text(
            vm.driverName,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 16),

          // Seat Availability & Price / Reserve Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Seat Availability Indicator Boxes & Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Seat Availability',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppTheme.textMuted,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        // Seat indicator boxes (up to capacity)
                        ...List.generate(vm.capacity.clamp(1, 10), (i) {
                          final isOccupied = i < vm.occupiedSeats;
                          return Container(
                            width: 10,
                            height: 10,
                            margin: const EdgeInsets.only(right: 4),
                            decoration: BoxDecoration(
                              color: isOccupied
                                  ? const Color(0xFFCBD5E1) // Gray occupied
                                  : const Color(0xFF22C55E), // Green available
                              borderRadius: BorderRadius.circular(2),
                            ),
                          );
                        }),
                        const SizedBox(width: 6),
                        Text(
                          '${vm.remainingSeats} left',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textDark,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Price & Reserve Button
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$feeStr DT',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 40,
                    child: ElevatedButton(
                      onPressed: vm.canReserve
                          ? () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => SeatReservationScreen(
                                    station: widget.station,
                                    route: widget.route,
                                    entrance: vm.entrance,
                                    remainingSeats: vm.remainingSeats,
                                    occupiedCount: vm.occupiedSeats,
                                  ),
                                ),
                              );
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text('Reserve'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
