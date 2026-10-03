import 'package:flutter/foundation.dart';
import '../config/api_config.dart';
import '../core/network/api_client.dart';
import '../core/network/api_exception.dart';
import '../models/user_model.dart';

class AuthService {
  final ApiClient _apiClient = ApiClient();

  /// Sign In with Email or Username
  Future<UserModel> login({
    required String identifier,
    required String password,
  }) async {
    await _apiClient.init();

    final isEmail = identifier.trim().contains('@');
    final Map<String, dynamic> payload = {
      if (isEmail) 'email': identifier.trim() else 'username': identifier.trim(),
      'password': password,
    };

    try {
      final response = await _apiClient.dio.post(
        ApiConfig.loginEndpoint,
        data: payload,
      );

      final statusCode = response.statusCode ?? 0;
      final data = response.data;

      if (statusCode >= 200 && statusCode < 300 &&
          data is Map<String, dynamic> && data['success'] == true) {
        if (data['data'] != null) {
          return UserModel.fromJson(data['data']);
        }
      }

      // Non-success response
      if (data is Map<String, dynamic>) {
        throw ApiException(
          message: data['message'] ?? 'Login failed. Please try again.',
          statusCode: statusCode,
        );
      }
      throw ApiException(
        message: 'Login failed. Please try again.',
        statusCode: statusCode,
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException.fromDioError(e);
    }
  }

  /// Create Account for Passenger users
  /// MUST always send role as "Passanger" (spelled with single 'a' in 'san')
  Future<UserModel> register({
    required String email,
    required String username,
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String password,
  }) async {
    await _apiClient.init();

    final payload = {
      'email': email.trim(),
      'username': username.trim(),
      'firstName': firstName.trim(),
      'lastName': lastName.trim(),
      'phoneNumber': phoneNumber.trim(),
      'password': password,
      'role': 'Passanger', // Backend strictly requires exact string "Passanger"
      'status': 'active',
      'stationId': null,
    };

    try {
      final response = await _apiClient.dio.post(
        ApiConfig.registerEndpoint,
        data: payload,
      );

      final statusCode = response.statusCode ?? 0;
      final data = response.data;

      if (statusCode >= 200 && statusCode < 300 &&
          data is Map<String, dynamic> && data['success'] == true) {
        if (data['data'] != null) {
          return UserModel.fromJson(data['data']);
        }
      }

      if (statusCode >= 400) {
        throw ApiException.fromResponse(response);
      }

      throw ApiException(
        message: data is Map ? (data['message'] ?? 'Registration failed.') : 'Registration failed.',
        statusCode: statusCode,
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException.fromDioError(e);
    }
  }

  /// Get current session details from /api/auth/me
  Future<UserModel?> getMe() async {
    await _apiClient.init();

    try {
      final response = await _apiClient.dio.get(ApiConfig.meEndpoint);
      final statusCode = response.statusCode ?? 0;
      final data = response.data;

      // 401 means no active session — that's normal on first launch
      if (statusCode == 401) {
        return null;
      }

      if (statusCode >= 200 && statusCode < 300 &&
          data is Map<String, dynamic> && data['success'] == true) {
        if (data['data'] != null) {
          return UserModel.fromJson(data['data']);
        }
      }

      return null;
    } catch (e) {
      debugPrint('Error getting session: $e');
      return null;
    }
  }

  /// Logout current session
  Future<void> logout() async {
    await _apiClient.init();

    try {
      await _apiClient.dio.post(ApiConfig.logoutEndpoint);
    } catch (e) {
      debugPrint('Logout request failed or ignored: $e');
    } finally {
      await _apiClient.clearCookies();
    }
  }

  /// Request Password Reset link
  Future<String> forgotPassword({
    required String email,
    String? redirectTo,
  }) async {
    await _apiClient.init();

    try {
      final response = await _apiClient.dio.post(
        ApiConfig.forgotPasswordEndpoint,
        data: {
          'email': email.trim(),
          'redirectTo': redirectTo ?? 'myapp://reset-password',
        },
      );

      final statusCode = response.statusCode ?? 0;
      final data = response.data;

      if (statusCode >= 200 && statusCode < 300) {
        return data is Map ? (data['message'] ??
            'If this email exists in our system, check your email for the reset link') :
            'If this email exists in our system, check your email for the reset link';
      }

      throw ApiException.fromResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException.fromDioError(e);
    }
  }

  /// Reset Password with Token
  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    await _apiClient.init();

    try {
      final response = await _apiClient.dio.post(
        ApiConfig.resetPasswordEndpoint,
        data: {
          'token': token,
          'newPassword': newPassword,
        },
      );

      final statusCode = response.statusCode ?? 0;
      if (statusCode < 200 || statusCode >= 300) {
        throw ApiException.fromResponse(response);
      }

      final data = response.data;
      if (data is Map && data['success'] != true) {
        throw ApiException(
          message: data['message'] ?? 'Failed to reset password.',
          statusCode: statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException.fromDioError(e);
    }
  }

  /// Change Password for Authenticated User
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _apiClient.init();

    try {
      final response = await _apiClient.dio.patch(
        ApiConfig.changePasswordEndpoint,
        data: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        },
      );

      final statusCode = response.statusCode ?? 0;
      if (statusCode < 200 || statusCode >= 300) {
        throw ApiException.fromResponse(response);
      }

      final data = response.data;
      if (data is Map && data['success'] != true) {
        throw ApiException(
          message: data['message'] ?? 'Failed to change password.',
          statusCode: statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException.fromDioError(e);
    }
  }
}
