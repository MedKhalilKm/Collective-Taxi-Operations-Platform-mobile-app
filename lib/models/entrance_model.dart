import 'driver_model.dart';
import 'station_model.dart';
import 'vehicle_model.dart';

class EntranceModel {
  final int id;
  final String createdAt;
  final String status;
  final int vehicleId;
  final int stationId;
  final String driverId;
  final VehicleModel? vehicle;
  final StationModel? station;
  final DriverModel? driver;

  EntranceModel({
    required this.id,
    required this.createdAt,
    required this.status,
    required this.vehicleId,
    required this.stationId,
    required this.driverId,
    this.vehicle,
    this.station,
    this.driver,
  });

  factory EntranceModel.fromJson(Map<String, dynamic> json) {
    return EntranceModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      createdAt: json['createdAt']?.toString() ?? '',
      status: json['status']?.toString() ?? 'waiting',
      vehicleId: json['vehicleId'] is int
          ? json['vehicleId']
          : int.tryParse(json['vehicleId']?.toString() ?? '0') ?? 0,
      stationId: json['stationId'] is int
          ? json['stationId']
          : int.tryParse(json['stationId']?.toString() ?? '0') ?? 0,
      driverId: json['driverId']?.toString() ?? '',
      vehicle: json['vehicle'] != null && json['vehicle'] is Map<String, dynamic>
          ? VehicleModel.fromJson(json['vehicle'] as Map<String, dynamic>)
          : null,
      station: json['station'] != null && json['station'] is Map<String, dynamic>
          ? StationModel.fromJson(json['station'] as Map<String, dynamic>)
          : null,
      driver: json['driver'] != null && json['driver'] is Map<String, dynamic>
          ? DriverModel.fromJson(json['driver'] as Map<String, dynamic>)
          : null,
    );
  }
}
