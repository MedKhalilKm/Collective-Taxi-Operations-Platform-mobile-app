import 'route_model.dart';

class StationModel {
  final int id;
  final String name;
  final String governorate;
  final String city;
  final double latitude;
  final double longitude;
  final double? altitude;
  final String creationDate;
  final double gpsRadius;
  final List<int> routeIds;
  final List<RouteModel> routes;

  StationModel({
    required this.id,
    required this.name,
    required this.governorate,
    required this.city,
    required this.latitude,
    required this.longitude,
    this.altitude,
    required this.creationDate,
    required this.gpsRadius,
    this.routeIds = const [],
    this.routes = const [],
  });

  factory StationModel.fromJson(Map<String, dynamic> json) {
    List<int> parsedRouteIds = [];
    if (json['routeIds'] != null && json['routeIds'] is List) {
      parsedRouteIds = (json['routeIds'] as List)
          .map((e) => int.tryParse(e.toString()) ?? 0)
          .where((id) => id > 0)
          .toList();
    }

    List<RouteModel> parsedRoutes = [];
    if (json['routes'] != null && json['routes'] is List) {
      parsedRoutes = (json['routes'] as List)
          .map((e) => RouteModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return StationModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      governorate: json['governorate']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      latitude: (json['latitude'] is num)
          ? (json['latitude'] as num).toDouble()
          : double.tryParse(json['latitude']?.toString() ?? '0.0') ?? 0.0,
      longitude: (json['longitude'] is num)
          ? (json['longitude'] as num).toDouble()
          : double.tryParse(json['longitude']?.toString() ?? '0.0') ?? 0.0,
      altitude: (json['altitude'] is num)
          ? (json['altitude'] as num).toDouble()
          : double.tryParse(json['altitude']?.toString() ?? ''),
      creationDate: json['creationDate']?.toString() ?? '',
      gpsRadius: (json['gpsRadius'] is num)
          ? (json['gpsRadius'] as num).toDouble()
          : double.tryParse(json['gpsRadius']?.toString() ?? '100.0') ?? 100.0,
      routeIds: parsedRouteIds,
      routes: parsedRoutes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'governorate': governorate,
      'city': city,
      'latitude': latitude,
      'longitude': longitude,
      'altitude': altitude,
      'creationDate': creationDate,
      'gpsRadius': gpsRadius,
      'routeIds': routeIds,
      'routes': routes.map((r) => r.toJson()).toList(),
    };
  }
}
