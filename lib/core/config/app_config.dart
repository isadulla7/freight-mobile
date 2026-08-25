class AppConfig {
  /// Backend manzili.
  ///
  /// Default: `localhost:8080` — bu USB orqali ulangan Android telefonda ham
  /// ishlaydi, chunki `run-local.sh` skripti `adb reverse tcp:8080 tcp:8080`
  /// buyrug'ini bajaradi (telefon localhost'i kompyuterga yo'naltiriladi).
  /// iOS simulator uchun localhost tabiiy ishlaydi.
  ///
  /// Boshqa manzil kerak bo'lsa:
  ///   flutter run --dart-define=BASE_URL=http://192.168.1.5:8080/api/v1
  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'http://localhost:8080/api/v1',
  );
}
