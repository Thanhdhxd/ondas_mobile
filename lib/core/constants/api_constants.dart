class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'http://192.168.123.4:8080';

  // Auth
  static const String register = '/api/auth/register';
  static const String login = '/api/auth/login';
  static const String refresh = '/api/auth/refresh';
  static const String logout = '/api/auth/logout';
  static const String forgotPassword = '/api/auth/forgot-password';
  static const String resetPassword = '/api/auth/reset-password';

  // Profile
  static const String profile = '/api/profile';
  static const String avatarUpload = '/api/profile/avatar';
  static const String changePassword = '/api/profile/password';

  // Songs
  static const String songs = '/api/songs';
  static String songById(String id) => '/api/songs/$id';

  // Albums
  static const String albums = '/api/albums';
  static String albumById(String id) => '/api/albums/$id';

  // Artists
  static const String artists = '/api/artists';
  static String artistById(String id) => '/api/artists/$id';

  // Genres
  static const String genres = '/api/genres';
  static const String genresSearch = '/api/genres/search';
  static String genreById(int id) => '/api/genres/$id';
}
