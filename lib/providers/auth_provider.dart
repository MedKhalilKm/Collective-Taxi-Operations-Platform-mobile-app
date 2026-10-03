import 'package:flutter/foundation.dart';
import '../core/network/api_exception.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

enum AuthStatus {
  initial,
  authenticating,
  authenticated,
  unauthenticated,
}

enum RegisterResult {
  successAndLoggedIn,
  successLoginFailed,
  failed,
}

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  AuthStatus _status = AuthStatus.initial;
  UserModel? _currentUser;
  String? _errorMessage;
  bool _isLoading = false;

  AuthStatus get status => _status;
  UserModel? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;

  bool get isAuthenticated => _status == AuthStatus.authenticated && _currentUser != null;

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Initialize session check on app startup
  Future<void> checkSession() async {
    _status = AuthStatus.authenticating;
    _isLoading = true;
    notifyListeners();

    try {
      final user = await _authService.getMe();
      if (user != null) {
        _currentUser = user;
        _status = AuthStatus.authenticated;
      } else {
        _currentUser = null;
        _status = AuthStatus.unauthenticated;
      }
    } catch (e) {
      _currentUser = null;
      _status = AuthStatus.unauthenticated;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Sign In action
  Future<bool> login({
    required String identifier,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _authService.login(
        identifier: identifier,
        password: password,
      );
      _currentUser = user;
      _status = AuthStatus.authenticated;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      if (e is ApiException) {
        _errorMessage = e.message;
      } else {
        _errorMessage = 'Login failed. Please check your credentials.';
      }
      notifyListeners();
      return false;
    }
  }

  /// Register new passenger account and perform auto-login
  Future<RegisterResult> register({
    required String email,
    required String username,
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Step 1: Create user account with role "Passanger"
      await _authService.register(
        email: email,
        username: username,
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
        password: password,
      );

      // Step 2: Auto-login after successful account creation
      try {
        final loggedInUser = await _authService.login(
          identifier: email,
          password: password,
        );
        _currentUser = loggedInUser;
        _status = AuthStatus.authenticated;
        _isLoading = false;
        notifyListeners();
        return RegisterResult.successAndLoggedIn;
      } catch (loginErr) {
        debugPrint('Auto-login failed after registration: $loginErr');
        _isLoading = false;
        _status = AuthStatus.unauthenticated;
        notifyListeners();
        return RegisterResult.successLoginFailed;
      }
    } catch (e) {
      _isLoading = false;
      if (e is ApiException) {
        _errorMessage = e.message;
      } else {
        _errorMessage = 'Registration failed. Please try again.';
      }
      notifyListeners();
      return RegisterResult.failed;
    }
  }

  /// Logout current session
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.logout();
    } catch (e) {
      debugPrint('Error during logout: $e');
    } finally {
      _currentUser = null;
      _status = AuthStatus.unauthenticated;
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Request Forgot Password reset email
  Future<String?> forgotPassword(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final msg = await _authService.forgotPassword(email: email);
      _isLoading = false;
      notifyListeners();
      return msg;
    } catch (e) {
      _isLoading = false;
      if (e is ApiException) {
        _errorMessage = e.message;
      } else {
        _errorMessage = 'Request failed. Please try again.';
      }
      notifyListeners();
      return null;
    }
  }
}
