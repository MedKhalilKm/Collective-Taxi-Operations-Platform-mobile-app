class DriverModel {
  final String id;
  final int cin;
  final String professionalIdCard;
  final String professionalCardExpiry;
  final int drivingLicence;
  final String drivingLicenceExpiry;

  DriverModel({
    required this.id,
    required this.cin,
    required this.professionalIdCard,
    required this.professionalCardExpiry,
    required this.drivingLicence,
    required this.drivingLicenceExpiry,
  });

  factory DriverModel.fromJson(Map<String, dynamic> json) {
    return DriverModel(
      id: json['id']?.toString() ?? '',
      cin: json['cin'] is int
          ? json['cin']
          : int.tryParse(json['cin']?.toString() ?? '0') ?? 0,
      professionalIdCard: json['professionalIdCard']?.toString() ?? '',
      professionalCardExpiry: json['professionalCardExpiry']?.toString() ?? '',
      drivingLicence: json['drivingLicence'] is int
          ? json['drivingLicence']
          : int.tryParse(json['drivingLicence']?.toString() ?? '0') ?? 0,
      drivingLicenceExpiry: json['drivingLicenceExpiry']?.toString() ?? '',
    );
  }
}
