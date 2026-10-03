import 'dart:io';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import '../../config/api_config.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  late final Dio dio;
  late CookieJar cookieJar;
  bool _isInitialized = false;

  ApiClient._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: ApiConfig.connectTimeout,
        receiveTimeout: ApiConfig.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        validateStatus: (status) => true,
      ),
    );
  }

  Future<void> init() async {
    if (_isInitialized) return;

    try {
      if (kIsWeb) {
        cookieJar = CookieJar();
      } else {
        final appDocDir = await getApplicationDocumentsDirectory();
        final String cookiePath = '${appDocDir.path}/.cookies/';
        final dir = Directory(cookiePath);
        if (!dir.existsSync()) {
          dir.createSync(recursive: true);
        }
        cookieJar = PersistCookieJar(storage: FileStorage(cookiePath));
      }
    } catch (e) {
      debugPrint('Failed to initialize PersistCookieJar, using CookieJar: $e');
      cookieJar = CookieJar();
    }

    dio.interceptors.add(CookieManager(cookieJar));
    _isInitialized = true;
  }

  void updateBaseUrl(String newUrl) {
    ApiConfig.baseUrl = newUrl;
    dio.options.baseUrl = newUrl;
  }

  Future<void> clearCookies() async {
    await cookieJar.deleteAll();
  }
}
