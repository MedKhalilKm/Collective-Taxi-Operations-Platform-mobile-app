import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/available_vehicles_provider.dart';
import 'providers/seat_reservation_provider.dart';
import 'providers/station_lines_provider.dart';
import 'providers/stations_provider.dart';
import 'screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TaxiCollectifApp());
}

class TaxiCollectifApp extends StatelessWidget {
  const TaxiCollectifApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => StationsProvider()),
        ChangeNotifierProvider(create: (_) => StationLinesProvider()),
        ChangeNotifierProvider(create: (_) => AvailableVehiclesProvider()),
        ChangeNotifierProvider(create: (_) => SeatReservationProvider()),
      ],
      child: MaterialApp(
        title: 'Taxi Collectif',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        home: const SplashScreen(),
      ),
    );
  }
}
