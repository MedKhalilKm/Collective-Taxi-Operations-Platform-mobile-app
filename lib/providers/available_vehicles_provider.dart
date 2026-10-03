import 'package:flutter/foundation.dart';
import '../core/network/api_exception.dart';
import '../models/route_model.dart';
import '../models/vehicle_departure_vm.dart';
import '../services/entrance_service.dart';
import '../services/reservation_service.dart';

class AvailableVehiclesProvider extends ChangeNotifier {
  final EntranceService _entranceService = EntranceService();
  final ReservationService _reservationService = ReservationService();

  List<VehicleDepartureVm> _departures = [];
  bool _isLoading = false;
  String? _errorMessage;
  bool _isUnauthorized = false;

  List<VehicleDepartureVm> get departures => _departures;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isUnauthorized => _isUnauthorized;

  void resetUnauthorized() {
    _isUnauthorized = false;
  }

  Future<void> fetchAvailableVehicles({
    required int stationId,
    required RouteModel route,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _isUnauthorized = false;
    notifyListeners();

    try {
      // 1. Fetch entrances for station
      final entrancesResult = await _entranceService.getEntrancesByStation(
        stationId: stationId,
        limit: 100,
      );

      // 2. Filter client-side by routeId and non-departed status
      final filteredEntrances = entrancesResult.entrances.where((e) {
        final matchesRoute = e.vehicle != null && e.vehicle!.routeId == route.id;
        final notDeparted = e.status.toLowerCase() != 'departed';
        return matchesRoute && notDeparted;
      }).toList();

      // 3. Sort chronologically by createdAt ascending
      filteredEntrances.sort((a, b) {
        try {
          final dtA = DateTime.parse(a.createdAt);
          final dtB = DateTime.parse(b.createdAt);
          return dtA.compareTo(dtB);
        } catch (_) {
          return 0;
        }
      });

      // 4. Fetch reservations for each entrance to calculate remaining seats
      final List<VehicleDepartureVm> vmList = [];
      for (final entrance in filteredEntrances) {
        try {
          final reservationsResult = await _reservationService.getReservationsByEntrance(
            entranceId: entrance.id,
          );
          vmList.add(
            VehicleDepartureVm.fromEntranceAndReservations(
              entrance: entrance,
              reservations: reservationsResult.reservations,
              routeFee: route.fee,
            ),
          );
        } catch (resErr) {
          debugPrint('Reservations fetch error for entrance #${entrance.id}: $resErr');
          vmList.add(
            VehicleDepartureVm.fromEntranceAndReservations(
              entrance: entrance,
              reservations: [],
              routeFee: route.fee,
            ),
          );
        }
      }

      _departures = vmList;
    } catch (e) {
      if (e is ApiException && e.statusCode == 401) {
        _isUnauthorized = true;
        _errorMessage = 'Session expired. Please sign in again.';
      } else if (e is ApiException) {
        _errorMessage = e.message;
      } else {
        _errorMessage = 'Failed to load departures. Please check your connection.';
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
