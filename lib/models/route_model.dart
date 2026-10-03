class RouteModel {
  final int id;
  final String name;
  final int routeNumber;
  final String firstDestination;
  final String secondDestination;
  final double fee;
  final double? altitude;
  final String description;
  final List<int> stationIds;

  RouteModel({
    required this.id,
    required this.name,
    required this.routeNumber,
    required this.firstDestination,
    required this.secondDestination,
    required this.fee,
    this.altitude,
    required this.description,
    this.stationIds = const [],
  });

  factory RouteModel.fromJson(Map<String, dynamic> json) {
    List<int> parsedStationIds = [];
    if (json['stationIds'] != null && json['stationIds'] is List) {
      parsedStationIds = (json['stationIds'] as List)
          .map((e) => int.tryParse(e.toString()) ?? 0)
          .where((id) => id > 0)
          .toList();
    }

    return RouteModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      routeNumber: json['routeNumber'] is int
          ? json['routeNumber']
          : int.tryParse(json['routeNumber']?.toString() ?? '0') ?? 0,
      firstDestination: json['firstDestination']?.toString() ?? '',
      secondDestination: json['secondDestination']?.toString() ?? '',
      fee: (json['fee'] is num)
          ? (json['fee'] as num).toDouble()
          : double.tryParse(json['fee']?.toString() ?? '0.0') ?? 0.0,
      altitude: (json['altitude'] is num)
          ? (json['altitude'] as num).toDouble()
          : double.tryParse(json['altitude']?.toString() ?? ''),
      description: json['description']?.toString() ?? '',
      stationIds: parsedStationIds,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'routeNumber': routeNumber,
      'firstDestination': firstDestination,
      'secondDestination': secondDestination,
      'fee': fee,
      'altitude': altitude,
      'description': description,
      'stationIds': stationIds,
    };
  }
}
