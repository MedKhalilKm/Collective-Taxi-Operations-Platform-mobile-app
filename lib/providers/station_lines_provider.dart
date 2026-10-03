import 'package:flutter/foundation.dart';
import '../core/network/api_exception.dart';
import '../models/entrance_model.dart';
import '../models/route_model.dart';
import '../models/station_line_vm.dart';
import '../services/entrance_service.dart';
import '../services/route_service.dart';

class StationLinesProvider extends ChangeNotifier {
  final RouteService _routeService = RouteService();
  final EntranceService _entranceService = EntranceService();

  List<StationLineCardVm> _lineCards = [];
  bool _isLoading = false;
  String? _errorMessage;
  bool _isUnauthorized = false;
  String? _warningMessage;

  List<StationLineCardVm> get lineCards => _lineCards;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isUnauthorized => _isUnauthorized;
  String? get warningMessage => _warningMessage;

  void resetUnauthorized() {
    _isUnauthorized = false;
  }

  Future<void> loadStationLines(int stationId) async {
    _isLoading = true;
    _errorMessage = null;
    _warningMessage = null;
    _isUnauthorized = false;
    notifyListeners();

    List<RouteModel> routes = [];
    List<EntranceModel> entrances = [];

    try {
      // Parallel fetch using Future.wait
      final results = await Future.wait([
        _routeService.getRoutesByStation(stationId: stationId, limit: 1000),
        _entranceService.getEntrancesByStation(stationId: stationId, limit: 100).catchError((err) {
          debugPrint('Entrances fetch error (non-fatal): $err');
          if (err is ApiException && err.statusCode == 401) {
            throw err;
          }
          return PaginatedEntrances(entrances: []);
        }),
      ]);

      final paginatedRoutes = results[0] as PaginatedRoutes;
      final paginatedEntrances = results[1] as PaginatedEntrances;

      routes = paginatedRoutes.routes;
      entrances = paginatedEntrances.entrances;

      if (entrances.isEmpty) {
        _warningMessage = 'Live vehicle status unavailable. Showing configured lines.';
      }
    } catch (e) {
      if (e is ApiException && e.statusCode == 401) {
        _isUnauthorized = true;
        _errorMessage = 'Session expired. Please sign in again.';
        _isLoading = false;
        notifyListeners();
        return;
      } else if (e is ApiException) {
        _errorMessage = e.message;
      } else {
        _errorMessage = 'Failed to load station lines. Please check your connection.';
      }
      _isLoading = false;
      notifyListeners();
      return;
    }

    // Combine routes and entrances client-side
    final List<StationLineCardVm> cards = [];
    for (int i = 0; i < routes.length; i++) {
      final route = routes[i];

      // Match entrances by vehicle.routeId == route.id
      final matchingEntrances = entrances.where((e) {
        return e.vehicle != null && e.vehicle!.routeId == route.id;
      }).toList();

      EntranceModel? selectedEntrance;
      if (matchingEntrances.isNotEmpty) {
        selectedEntrance = matchingEntrances.firstWhere(
          (e) => e.status.toLowerCase() != 'departed',
          orElse: () => matchingEntrances.first,
        );
      }

      cards.add(
        StationLineCardVm.fromRouteAndEntrance(
          route: route,
          entrance: selectedEntrance,
          index: i,
        ),
      );
    }

    _lineCards = cards;
    _isLoading = false;
    notifyListeners();
  }
}
