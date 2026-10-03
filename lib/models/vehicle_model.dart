class VehicleModel {
  final int id;
  final int registrationNumber;
  final int seriesNumber;
  final String carBrand;
  final int capacity;
  final String status;
  final String chassisNumber;
  final String insuranceExpiry;
  final String registrationDate;
  final String inspectionExpiry;
  final int? routeId;

  VehicleModel({
    required this.id,
    required this.registrationNumber,
    required this.seriesNumber,
    required this.carBrand,
    required this.capacity,
    required this.status,
    required this.chassisNumber,
    required this.insuranceExpiry,
    required this.registrationDate,
    required this.inspectionExpiry,
    this.routeId,
  });

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      registrationNumber: json['registrationNumber'] is int
          ? json['registrationNumber']
          : int.tryParse(json['registrationNumber']?.toString() ?? '0') ?? 0,
      seriesNumber: json['seriesNumber'] is int
          ? json['seriesNumber']
          : int.tryParse(json['seriesNumber']?.toString() ?? '0') ?? 0,
      carBrand: json['carBrand']?.toString() ?? '',
      capacity: json['capacity'] is int
          ? json['capacity']
          : int.tryParse(json['capacity']?.toString() ?? '8') ?? 8,
      status: json['status']?.toString() ?? 'active',
      chassisNumber: json['chassisNumber']?.toString() ?? '',
      insuranceExpiry: json['insuranceExpiry']?.toString() ?? '',
      registrationDate: json['registrationDate']?.toString() ?? '',
      inspectionExpiry: json['inspectionExpiry']?.toString() ?? '',
      routeId: json['routeId'] is int
          ? json['routeId']
          : int.tryParse(json['routeId']?.toString() ?? ''),
    );
  }
}
