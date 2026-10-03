import 'dart:math';
import 'package:flutter/foundation.dart';
import '../core/network/api_exception.dart';
import '../models/reservation_model.dart';
import '../services/reservation_service.dart';

class SeatReservationProvider extends ChangeNotifier {
  final ReservationService _reservationService = ReservationService();

  int _capacity = 8;
  int _occupiedCount = 0;
  int _remainingSeats = 8;
  int _numberOfSeats = 1;
  final Set<int> _selectedSeatNumbers = {};
  double _pricePerSeat = 0.0;

  bool _isSubmitting = false;
  String? _errorMessage;
  bool _isUnauthorized = false;
  ReservationModel? _createdReservation;

  int get capacity => _capacity;
  int get occupiedCount => _occupiedCount;
  int get remainingSeats => _remainingSeats;
  int get numberOfSeats => _numberOfSeats;
  Set<int> get selectedSeatNumbers => Set.unmodifiable(_selectedSeatNumbers);
  double get pricePerSeat => _pricePerSeat;
  double get totalPrice => _numberOfSeats * _pricePerSeat;
  int get maxAllowedSeats => min(4, _remainingSeats);

  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;
  bool get isUnauthorized => _isUnauthorized;
  ReservationModel? get createdReservation => _createdReservation;

  void resetUnauthorized() {
    _isUnauthorized = false;
  }

  void init({
    required int capacity,
    required int occupiedCount,
    required double pricePerSeat,
  }) {
    _capacity = capacity > 0 ? capacity : 8;
    _occupiedCount = occupiedCount;
    _remainingSeats = max(0, _capacity - _occupiedCount);
    _pricePerSeat = pricePerSeat;
    _errorMessage = null;
    _createdReservation = null;
    _isUnauthorized = false;

    _numberOfSeats = _remainingSeats > 0 ? 1 : 0;
    _selectedSeatNumbers.clear();

    if (_numberOfSeats > 0) {
      final firstAvailable = _occupiedCount + 1;
      if (firstAvailable <= _capacity) {
        _selectedSeatNumbers.add(firstAvailable);
      }
    }
  }

  /// Toggle visual seat selection in grid
  void toggleSeatSelection(int seatNumber) {
    // Cannot select occupied seats
    if (seatNumber <= _occupiedCount) return;

    if (_selectedSeatNumbers.contains(seatNumber)) {
      // Don't allow unselecting down to 0
      if (_selectedSeatNumbers.length > 1) {
        _selectedSeatNumbers.remove(seatNumber);
      }
    } else {
      if (_selectedSeatNumbers.length < maxAllowedSeats) {
        _selectedSeatNumbers.add(seatNumber);
      }
    }

    _numberOfSeats = _selectedSeatNumbers.length;
    notifyListeners();
  }

  /// Update seat count via stepper control
  void setSeatCount(int count) {
    if (count < 1 || count > maxAllowedSeats) return;

    _numberOfSeats = count;
    _selectedSeatNumbers.clear();

    // Fill first `count` available slots
    for (int i = 1; i <= count; i++) {
      final seatNum = _occupiedCount + i;
      if (seatNum <= _capacity) {
        _selectedSeatNumbers.add(seatNum);
      }
    }
    notifyListeners();
  }

  /// Submit reservation to backend POST /api/reservations
  /// Note: The backend reserves by count (numberOfSeats) only.
  Future<bool> submitReservation({required int entranceId}) async {
    if (_numberOfSeats < 1) {
      _errorMessage = 'Please select at least 1 seat.';
      notifyListeners();
      return false;
    }

    if (_numberOfSeats > _remainingSeats) {
      _errorMessage = 'Only $_remainingSeats seats are available.';
      notifyListeners();
      return false;
    }

    _isSubmitting = true;
    _errorMessage = null;
    _isUnauthorized = false;
    notifyListeners();

    try {
      final reservation = await _reservationService.createReservation(
        entranceId: entranceId,
        numberOfSeats: _numberOfSeats,
      );

      _createdReservation = reservation;
      _isSubmitting = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isSubmitting = false;
      if (e is ApiException && e.statusCode == 401) {
        _isUnauthorized = true;
        _errorMessage = 'Session expired. Please sign in again.';
      } else if (e is ApiException) {
        _errorMessage = e.message;
      } else {
        _errorMessage = 'Failed to create reservation. Please try again.';
      }
      notifyListeners();
      return false;
    }
  }
}
