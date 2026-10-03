class ReservationSeatRefModel {
  final int id;
  final String reservationRef;
  final int seatNumber;
  final String status;
  final String createdAt;

  ReservationSeatRefModel({
    required this.id,
    required this.reservationRef,
    required this.seatNumber,
    required this.status,
    required this.createdAt,
  });

  factory ReservationSeatRefModel.fromJson(Map<String, dynamic> json) {
    return ReservationSeatRefModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      reservationRef: json['reservationRef']?.toString() ?? '',
      seatNumber: json['seatNumber'] is int
          ? json['seatNumber']
          : int.tryParse(json['seatNumber']?.toString() ?? '0') ?? 0,
      status: json['status']?.toString() ?? 'active',
      createdAt: json['createdAt']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reservationRef': reservationRef,
      'seatNumber': seatNumber,
      'status': status,
      'createdAt': createdAt,
    };
  }
}
