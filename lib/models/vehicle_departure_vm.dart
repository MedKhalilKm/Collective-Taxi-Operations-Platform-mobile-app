import 'entrance_model.dart';
import 'reservation_model.dart';

class VehicleDepartureVm {
  final EntranceModel entrance;
  final String departureTime;
  final String carBrand;
  final String driverName;
  final String statusLabel;
  final int capacity;
  final int occupiedSeats;
  final int remainingSeats;
  final double fee;
  final bool canReserve;

  VehicleDepartureVm({
    required this.entrance,
    required this.departureTime,
    required this.carBrand,
    required this.driverName,
    required this.statusLabel,
    required this.capacity,
    required this.occupiedSeats,
    required this.remainingSeats,
    required this.fee,
    required this.canReserve,
  });

  factory VehicleDepartureVm.fromEntranceAndReservations({
    required EntranceModel entrance,
    required List<ReservationModel> reservations,
    required double routeFee,
  }) {
    // Departure time from entrance.createdAt (HH:mm)
    String formattedTime = '10:00';
    try {
      if (entrance.createdAt.isNotEmpty) {
        final dateTime = DateTime.parse(entrance.createdAt).toLocal();
        final hour = dateTime.hour.toString().padLeft(2, '0');
        final minute = dateTime.minute.toString().padLeft(2, '0');
        formattedTime = '$hour:$minute';
      }
    } catch (_) {
      formattedTime = '10:15';
    }

    // Vehicle Brand
    final brand = entrance.vehicle?.carBrand.trim().isNotEmpty == true
        ? entrance.vehicle!.carBrand
        : 'vehicule';

    // Driver label fallback
    String driverLabel = 'Professional Driver';
    if (entrance.driver != null && entrance.driver!.id.isNotEmpty) {
      driverLabel = 'Driver #${entrance.driver!.cin > 0 ? entrance.driver!.cin : entrance.driver!.id.substring(0, 6)}';
    }

    // Seat capacity & calculation
    final capacity = entrance.vehicle?.capacity ?? 8;
    int activeOccupied = 0;

    for (final res in reservations) {
      if (res.seatRefs.isNotEmpty) {
        activeOccupied += res.seatRefs.where((s) => s.status.toLowerCase() == 'active').length;
      } else {
        activeOccupied += res.numberOfSeats;
      }
    }

    final remaining = (capacity - activeOccupied).clamp(0, capacity);

    // Status mapping
    String status = 'Available';
    final entranceStatusLower = entrance.status.toLowerCase();
    if (entranceStatusLower == 'pending') {
      status = 'Waiting';
    } else {
      status = 'Available';
    }

    final canReserve = remaining > 0 && entranceStatusLower != 'departed';

    return VehicleDepartureVm(
      entrance: entrance,
      departureTime: formattedTime,
      carBrand: brand,
      driverName: driverLabel,
      statusLabel: status,
      capacity: capacity,
      occupiedSeats: activeOccupied,
      remainingSeats: remaining,
      fee: routeFee,
      canReserve: canReserve,
    );
  }
}
