import 'dart:io' show Platform;

class AppConfig {
  static const String _envBaseUrl = String.fromEnvironment('BASE_URL');

  static final String baseUrl = _envBaseUrl.isNotEmpty
      ? _envBaseUrl
      : Platform.isAndroid
          ? 'http://10.0.2.2:8080/api/v1'
          : 'http://localhost:8080/api/v1';
}
