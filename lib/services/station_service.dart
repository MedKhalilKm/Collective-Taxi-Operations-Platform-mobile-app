import '../config/api_config.dart';
import '../core/network/api_client.dart';
import '../core/network/api_exception.dart';
import '../models/pagination_model.dart';
import '../models/station_model.dart';

class PaginatedStations {
  final List<StationModel> stations;
  final PaginationModel? pagination;

  PaginatedStations({
    required this.stations,
    this.pagination,
  });
}

class StationService {
  final ApiClient _apiClient = ApiClient();

  Future<PaginatedStations> getStations({
    String? search,
    String? governorate,
    String? city,
    int page = 1,
    int limit = 100,
  }) async {
    await _apiClient.init();

    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
      if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
      if (governorate != null && governorate.trim().isNotEmpty)
        'governorate': governorate.trim(),
      if (city != null && city.trim().isNotEmpty) 'city': city.trim(),
    };

    try {
      final response = await _apiClient.dio.get(
        ApiConfig.stationsEndpoint,
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
        List<StationModel> stationsList = [];
        if (data['data'] != null && data['data'] is List) {
          stationsList = (data['data'] as List)
              .map((e) => StationModel.fromJson(e as Map<String, dynamic>))
              .toList();
        }

        PaginationModel? pagination;
        if (data['pagination'] != null && data['pagination'] is Map) {
          pagination = PaginationModel.fromJson(
            data['pagination'] as Map<String, dynamic>,
          );
        }

        return PaginatedStations(
          stations: stationsList,
          pagination: pagination,
        );
      }

      throw ApiException.fromResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException.fromDioError(e);
    }
  }
}
