import '../config/api_config.dart';
import '../core/network/api_client.dart';
import '../core/network/api_exception.dart';
import '../models/pagination_model.dart';
import '../models/reservation_model.dart';

class PaginatedReservations {
  final List<ReservationModel> reservations;
  final PaginationModel? pagination;

  PaginatedReservations({
    required this.reservations,
    this.pagination,
  });
}

class ReservationService {
  final ApiClient _apiClient = ApiClient();

  /// Get active reservations for a given entrance to compute remaining seats
  Future<PaginatedReservations> getReservationsByEntrance({
    required int entranceId,
    int page = 1,
    int limit = 100,
  }) async {
    await _apiClient.init();

    final queryParams = <String, dynamic>{
      'entranceId': entranceId,
      'page': page,
      'limit': limit,
    };

    try {
      final response = await _apiClient.dio.get(
        ApiConfig.reservationsEndpoint,
        queryParameters: queryParams,
      );

      final statusCode = response.statusCode ?? 0;
      if (statusCode == 401) {
        throw ApiException(
          message: 'Unauthorized access',
          statusCode: 401,
        );
      }

      final data = response.data;
      if (statusCode >= 200 && statusCode < 300 &&
          data is Map<String, dynamic> && data['success'] == true) {
        List<ReservationModel> reservationsList = [];
        if (data['data'] != null && data['data'] is List) {
          reservationsList = (data['data'] as List)
              .map((e) => ReservationModel.fromJson(e as Map<String, dynamic>))
              .toList();
        }

        PaginationModel? pagination;
        if (data['pagination'] != null && data['pagination'] is Map) {
          pagination = PaginationModel.fromJson(
            data['pagination'] as Map<String, dynamic>,
          );
        }

        return PaginatedReservations(
          reservations: reservationsList,
          pagination: pagination,
        );
      }

      throw ApiException.fromResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException.fromDioError(e);
    }
  }

  /// Create a new reservation for an entrance
  /// Note: The backend accepts ONLY entranceId and numberOfSeats.
  Future<ReservationModel> createReservation({
    required int entranceId,
    required int numberOfSeats,
  }) async {
    await _apiClient.init();

    final payload = {
      'entranceId': entranceId,
      'numberOfSeats': numberOfSeats,
    };

    try {
      final response = await _apiClient.dio.post(
        ApiConfig.reservationsEndpoint,
        data: payload,
      );

      final statusCode = response.statusCode ?? 0;
      final data = response.data;

      if (statusCode == 401) {
        throw ApiException(
          message: 'Session expired. Please sign in to create a reservation.',
          statusCode: 401,
        );
      }
      if (statusCode == 404) {
        throw ApiException(
          message: 'This departure is no longer available.',
          statusCode: 404,
        );
      }
      if (statusCode == 409) {
        throw ApiException(
          message: 'Could not generate a unique reservation reference. Please try again.',
          statusCode: 409,
        );
      }

      if (statusCode >= 200 && statusCode < 300 &&
          data is Map<String, dynamic> && data['success'] == true) {
        if (data['data'] != null && data['data'] is Map<String, dynamic>) {
          return ReservationModel.fromJson(data['data'] as Map<String, dynamic>);
        }
      }

      if (statusCode >= 400) {
        throw ApiException.fromResponse(response);
      }

      throw ApiException(
        message: data is Map ? (data['message'] ?? 'Failed to create reservation') : 'Failed to create reservation',
        statusCode: statusCode,
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException.fromDioError(e);
    }
  }
}
