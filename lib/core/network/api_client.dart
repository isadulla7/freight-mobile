import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../config/app_config.dart';

class ApiClient {
  static final String _baseUrl = AppConfig.baseUrl;
  static const _tokenKey = 'access_token';
  static const _refreshKey = 'refresh_token';

  /// Endpointlar, ularda 401 kelsa token yangilash mantiqan noto'g'ri —
  /// bu login oqimining o'zi.
  static const _authPaths = {
    '/auth/otp/request',
    '/auth/otp/verify',
    '/auth/refresh',
  };

  final Dio dio;
  final FlutterSecureStorage _storage;

  /// Sessiya tiklab bo'lmaydigan darajada yaroqsiz bo'lganda chaqiriladi
  /// (refresh token ham ishlamadi). `main.dart` buni AuthBloc'ga ulaydi.
  void Function()? onAuthFailure;

  /// Bir vaqtda faqat bitta refresh ketishini ta'minlaydi — aks holda
  /// parallel so'rovlar refresh tokenni bir necha marta almashtirib,
  /// backend'ning reuse-detection mexanizmini ishga tushiradi.
  Future<bool>? _refreshInFlight;

  ApiClient({Dio? dio, FlutterSecureStorage? storage})
      : dio = dio ?? Dio(),
        _storage = storage ?? const FlutterSecureStorage() {
    this.dio.options = BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
    );

    this.dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: _onRequest,
        onError: _onError,
      ),
    );
  }

  Future<void> _onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.read(key: _tokenKey);
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  Future<void> _onError(
    DioException error,
    ErrorInterceptorHandler handler,
  ) async {
    final path = error.requestOptions.path;
    final isAuthPath = _authPaths.any(path.endsWith);

    if (error.response?.statusCode == 401 && !isAuthPath) {
      final refreshed = await _refreshToken();
      if (refreshed) {
        try {
          final retryResponse = await _retry(error.requestOptions);
          return handler.resolve(retryResponse);
        } on DioException catch (retryError) {
          return handler.next(retryError);
        }
      }
    }
    handler.next(error);
  }

  /// Bir nechta parallel chaqiruv bitta refreshni baham ko'radi.
  Future<bool> _refreshToken() {
    return _refreshInFlight ??= _performRefresh().whenComplete(() {
      _refreshInFlight = null;
    });
  }

  Future<bool> _performRefresh() async {
    try {
      final refreshToken = await _storage.read(key: _refreshKey);
      if (refreshToken == null) {
        onAuthFailure?.call();
        return false;
      }

      final response = await Dio().post(
        '$_baseUrl/auth/refresh',
        data: {'refreshToken': refreshToken},
      );

      final data = response.data as Map<String, dynamic>;
      await _storage.write(key: _tokenKey, value: data['accessToken'] as String);
      await _storage.write(key: _refreshKey, value: data['refreshToken'] as String);
      return true;
    } catch (_) {
      await clearTokens();
      // Sessiya tiklanmadi — foydalanuvchini login ekraniga qaytarish kerak.
      onAuthFailure?.call();
      return false;
    }
  }

  Future<Response<dynamic>> _retry(RequestOptions options) async {
    final token = await _storage.read(key: _tokenKey);
    options.headers['Authorization'] = 'Bearer $token';
    return dio.fetch(options);
  }

  Future<void> saveTokens(String accessToken, String refreshToken) async {
    await _storage.write(key: _tokenKey, value: accessToken);
    await _storage.write(key: _refreshKey, value: refreshToken);
  }

  Future<void> clearTokens() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _refreshKey);
  }

  Future<bool> hasToken() async {
    final token = await _storage.read(key: _tokenKey);
    return token != null;
  }
}
