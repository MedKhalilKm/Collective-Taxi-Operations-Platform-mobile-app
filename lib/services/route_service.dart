import '../config/api_config.dart';
import '../core/network/api_client.dart';
import '../core/network/api_exception.dart';
import '../models/pagination_model.dart';
import '../models/route_model.dart';

class PaginatedRoutes {
  final List<RouteModel> routes;
  final PaginationModel? pagination;

  PaginatedRoutes({
    required this.routes,
    this.pagination,
  });
}

class RouteService {
  final ApiClient _apiClient = ApiClient();

  Future<PaginatedRoutes> getRoutesByStation({
    required int stationId,
    String? search,
    int page = 1,
    int limit = 1000,
  }) async {
    await _apiClient.init();

    final queryParams = <String, dynamic>{
      'stationId': stationId,
      'page': page,
      'limit': limit,
      if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
    };

    try {
      final response = await _apiClient.dio.get(
        ApiConfig.routesEndpoint,
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
        List<RouteModel> routesList = [];
        if (data['data'] != null && data['data'] is List) {
          routesList = (data['data'] as List)
              .map((e) => RouteModel.fromJson(e as Map<String, dynamic>))
              .toList();
        }

        PaginationModel? pagination;
        if (data['pagination'] != null && data['pagination'] is Map) {
          pagination = PaginationModel.fromJson(
            data['pagination'] as Map<String, dynamic>,
          );
        }

        return PaginatedRoutes(
          routes: routesList,
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
