import '../config/api_config.dart';
import '../core/network/api_client.dart';
import '../core/network/api_exception.dart';
import '../models/entrance_model.dart';
import '../models/pagination_model.dart';

class PaginatedEntrances {
  final List<EntranceModel> entrances;
  final PaginationModel? pagination;

  PaginatedEntrances({
    required this.entrances,
    this.pagination,
  });
}

class EntranceService {
  final ApiClient _apiClient = ApiClient();

  Future<PaginatedEntrances> getEntrancesByStation({
    required int stationId,
    String? status,
    int page = 1,
    int limit = 100,
  }) async {
    await _apiClient.init();

    final queryParams = <String, dynamic>{
      'stationId': stationId,
      'page': page,
      'limit': limit,
      if (status != null && status.trim().isNotEmpty) 'status': status.trim(),
    };

    try {
      final response = await _apiClient.dio.get(
        ApiConfig.entrancesEndpoint,
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
        List<EntranceModel> entrancesList = [];
        if (data['data'] != null && data['data'] is List) {
          entrancesList = (data['data'] as List)
              .map((e) => EntranceModel.fromJson(e as Map<String, dynamic>))
              .toList();
        }

        PaginationModel? pagination;
        if (data['pagination'] != null && data['pagination'] is Map) {
          pagination = PaginationModel.fromJson(
            data['pagination'] as Map<String, dynamic>,
          );
        }

        return PaginatedEntrances(
          entrances: entrancesList,
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
