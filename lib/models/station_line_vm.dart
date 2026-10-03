import 'package:flutter/material.dart';
import 'entrance_model.dart';
import 'route_model.dart';

class StationLineCardVm {
  final int routeId;
  final int? entranceId;
  final String title;
  final String subtitle;
  final double fee;
  final String statusLabel;
  final Color statusTextColor;
  final Color statusBgColor;
  final Color accentColor;
  final RouteModel route;
  final EntranceModel? entrance;

  StationLineCardVm({
    required this.routeId,
    this.entranceId,
    required this.title,
    required this.subtitle,
    required this.fee,
    required this.statusLabel,
    required this.statusTextColor,
    required this.statusBgColor,
    required this.accentColor,
    required this.route,
    this.entrance,
  });

  static const List<Color> accentColors = [
    Color(0xFFE53935), // Red
    Color(0xFF1E88E5), // Blue
    Color(0xFFFB8C00), // Amber/Yellow
    Color(0xFF8E24AA), // Purple
    Color(0xFF43A047), // Green
  ];

  factory StationLineCardVm.fromRouteAndEntrance({
    required RouteModel route,
    required EntranceModel? entrance,
    required int index,
  }) {
    final title = route.name.trim().isNotEmpty
        ? route.name
        : '${route.firstDestination} - ${route.secondDestination}';

    final feeStr = route.fee.truncateToDouble() == route.fee
        ? route.fee.toInt().toString()
        : route.fee.toString();

    String subtitleText;
    final desc = route.description.trim();
    if (desc.startsWith('Towards')) {
      subtitleText = '$desc • $feeStr DT';
    } else if (desc.isNotEmpty) {
      subtitleText = 'Towards $desc • $feeStr DT';
    } else if (route.secondDestination.isNotEmpty) {
      subtitleText = 'Towards ${route.secondDestination} • $feeStr DT';
    } else {
      subtitleText = '$feeStr DT';
    }

    String label = 'Waiting';
    Color textColor = const Color(0xFF27AE60);
    Color bgColor = const Color(0xFFE6F9ED);

    if (entrance != null) {
      final statusLower = entrance.status.toLowerCase();
      if (statusLower == 'ready') {
        label = 'Available';
        textColor = const Color(0xFF27AE60);
        bgColor = const Color(0xFFE6F9ED);
      } else if (statusLower == 'departed') {
        label = 'Leaving';
        textColor = const Color(0xFFD32F2F);
        bgColor = const Color(0xFFFDF0EA);
      } else {
        label = 'Waiting';
        textColor = const Color(0xFF27AE60);
        bgColor = const Color(0xFFE6F9ED);
      }
    }

    final accent = accentColors[index % accentColors.length];

    return StationLineCardVm(
      routeId: route.id,
      entranceId: entrance?.id,
      title: title,
      subtitle: subtitleText,
      fee: route.fee,
      statusLabel: label,
      statusTextColor: textColor,
      statusBgColor: bgColor,
      accentColor: accent,
      route: route,
      entrance: entrance,
    );
  }
}
