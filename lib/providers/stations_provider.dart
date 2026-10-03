import 'dart:async';
import 'package:flutter/foundation.dart';
import '../core/network/api_exception.dart';
import '../models/station_model.dart';
import '../services/station_service.dart';

class StationsProvider extends ChangeNotifier {
  final StationService _stationService = StationService();

  List<StationModel> _stations = [];
  bool _isLoading = false;
  bool _isSearching = false;
  String? _errorMessage;
  bool _isUnauthorized = false;
  String _searchQuery = '';
  Timer? _debounceTimer;

  List<StationModel> get stations => _stations;
  bool get isLoading => _isLoading;
  bool get isSearching => _isSearching;
  String? get errorMessage => _errorMessage;
  bool get isUnauthorized => _isUnauthorized;
  String get searchQuery => _searchQuery;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  void resetUnauthorized() {
    _isUnauthorized = false;
  }

  /// Called when user types in the search field with ~300ms debounce
  void onSearchChanged(String query) {
    _searchQuery = query;
    _debounceTimer?.cancel();

    if (query.trim().isEmpty) {
      _isSearching = false;
      fetchStations(search: '');
      return;
    }

    _isSearching = true;
    notifyListeners();

    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      fetchStations(search: query, isSearchCall: true);
    });
  }

  Future<void> fetchStations({String? search, bool isSearchCall = false}) async {
    final query = search ?? _searchQuery;

    if (!isSearchCall) {
      _isLoading = true;
    }
    _errorMessage = null;
    _isUnauthorized = false;
    notifyListeners();

    try {
      final result = await _stationService.getStations(
        search: query,
        page: 1,
        limit: 100,
      );
      _stations = result.stations;
    } catch (e) {
      if (e is ApiException && e.statusCode == 401) {
        _isUnauthorized = true;
        _errorMessage = 'Session expired. Please sign in again.';
      } else if (e is ApiException) {
        _errorMessage = e.message;
      } else {
        _errorMessage = 'Failed to load stations. Please check your connection.';
      }
    } finally {
      _isLoading = false;
      _isSearching = false;
      notifyListeners();
    }
  }
}
