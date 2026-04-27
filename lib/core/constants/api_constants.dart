class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'http://$devHost:8080';

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

  // Home
  static const String home = '/api/home';

  // Play History
  static const String playHistory = '/api/play-history';
  static String playHistoryById(int id) => '/api/play-history/$id';

  // Playlists
  static const String playlists = '/api/playlists';
  static String playlistById(String id) => '/api/playlists/$id';
  static String playlistSongs(String id) => '/api/playlists/$id/songs';
  static String playlistSongById(String id, String songId) =>
      '/api/playlists/$id/songs/$songId';

  /// Host của máy tính dev — dùng để thay thế "localhost" trong URL ảnh
  /// trả về từ backend (MinIO/S3), vì device Android không resolve được "localhost".
  static const String devHost = '192.168.123.3';

  /// Chuyển relative path từ API thành absolute URL.
  /// Nếu URL chứa "localhost", thay bằng [devHost] để device có thể truy cập.
  static String? resolveUrl(String? path) {
    if (path == null || path.isEmpty) return null;
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path.replaceFirst('localhost', devHost);
    }
    return '$baseUrl$path';
  }
}
