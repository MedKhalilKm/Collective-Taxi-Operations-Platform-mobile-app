import 'entrance_model.dart';
import 'reservation_seat_ref_model.dart';
import 'user_model.dart';

class ReservationModel {
  final int id;
  final String reservationRef;
  final List<String> reservationRefs;
  final List<ReservationSeatRefModel> seatRefs;
  final int numberOfSeats;
  final String createdAt;
  final int entranceId;
  final String? userId;
  final EntranceModel? entrance;
  final UserModel? user;

  ReservationModel({
    required this.id,
    required this.reservationRef,
    this.reservationRefs = const [],
    this.seatRefs = const [],
    required this.numberOfSeats,
    required this.createdAt,
    required this.entranceId,
    this.userId,
    this.entrance,
    this.user,
  });

  factory ReservationModel.fromJson(Map<String, dynamic> json) {
    List<String> parsedRefs = [];
    if (json['reservationRefs'] != null && json['reservationRefs'] is List) {
      parsedRefs = (json['reservationRefs'] as List)
          .map((e) => e.toString())
          .toList();
    }

    List<ReservationSeatRefModel> parsedSeatRefs = [];
    if (json['seatRefs'] != null && json['seatRefs'] is List) {
      parsedSeatRefs = (json['seatRefs'] as List)
          .map((e) => ReservationSeatRefModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    final refMain = json['ReservationRef']?.toString() ??
        json['reservationRef']?.toString() ??
        (parsedRefs.isNotEmpty ? parsedRefs.first : '');

    return ReservationModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      reservationRef: refMain,
      reservationRefs: parsedRefs,
      seatRefs: parsedSeatRefs,
      numberOfSeats: json['numberOfSeats'] is int
          ? json['numberOfSeats']
          : int.tryParse(json['numberOfSeats']?.toString() ?? '1') ?? 1,
      createdAt: json['createdAt']?.toString() ?? '',
      entranceId: json['entranceId'] is int
          ? json['entranceId']
          : int.tryParse(json['entranceId']?.toString() ?? '0') ?? 0,
      userId: json['userId']?.toString(),
      entrance: json['entrance'] != null && json['entrance'] is Map<String, dynamic>
          ? EntranceModel.fromJson(json['entrance'] as Map<String, dynamic>)
          : null,
      user: json['user'] != null && json['user'] is Map<String, dynamic>
          ? UserModel.fromJson(json['user'] as Map<String, dynamic>)
          : null,
    );
  }
}
