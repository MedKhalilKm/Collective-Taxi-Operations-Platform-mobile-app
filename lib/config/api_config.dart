class ApiConfig {
  // Default Base URL for Android Emulator pointing to host machine
  // For iOS Simulator, use 'http://localhost:3000'
  // For physical devices, replace with server IP e.g. 'http://192.168.1.50:3000'
  static String baseUrl = 'http://10.0.2.2:3000';

  // Endpoints
  static const String loginEndpoint = '/api/auth/login';
  static const String registerEndpoint = '/api/users';
  static const String meEndpoint = '/api/auth/me';
  static const String logoutEndpoint = '/api/auth/logout';
  static const String changePasswordEndpoint = '/api/auth/change-password';
  static const String forgotPasswordEndpoint = '/api/auth/forgot-password';
  static const String resetPasswordEndpoint = '/api/auth/reset-password';
  static const String stationsEndpoint = '/api/stations';
  static const String routesEndpoint = '/api/routes';
  static const String entrancesEndpoint = '/api/entrances';
  static const String reservationsEndpoint = '/api/reservations';

  // Timeout durations
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
}
