class AppConfig {
  /// Sobrescribible con `--dart-define=API_URL=http://10.0.2.2:3000`.
  static const apiUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'https://projecto1programacionavanzada.onrender.com',
  );

  /// Render (plan gratuito) puede tardar ~50 s en despertar.
  static const requestTimeout = Duration(seconds: 60);

  static const syncInterval = Duration(minutes: 5);
}
