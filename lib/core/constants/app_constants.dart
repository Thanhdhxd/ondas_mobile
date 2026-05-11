class AppConstants {
  AppConstants._();

  static const String appName = 'Ondas';
  static const String appVersion = '1.0.0';

  // Pagination defaults
  static const int defaultPageSize = 20;
  static const int defaultPage = 0;

  // Storage keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';

  // Token
  static const String bearerPrefix = 'Bearer ';

  // Player notification channel
  static const String playerNotificationChannelId = 'ondas_mobile.player';
  static const String playerNotificationChannelName = 'Ondas Playback';
  static const String playerNotificationChannelDescription =
      'Playback controls for Ondas music';
}
