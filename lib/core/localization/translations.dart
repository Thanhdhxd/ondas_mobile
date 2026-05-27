import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'str_enum.dart';
import 'language_cubit.dart';

const Map<Str, String> _vi = {
  // Common
  Str.successOk: 'Thành công',
  Str.offlineMessage: 'Bạn đang ngoại tuyến. Vui lòng kiểm tra kết nối mạng.',

  // Auth / Permission
  Str.errorUnauthorized: 'Không có quyền truy cập',
  Str.errorUnauthorizedInvalidCredentials: 'Tên đăng nhập hoặc mật khẩu không đúng',
  Str.errorUnauthorizedInvalidToken: 'Phiên đăng nhập đã hết hạn',
  Str.errorAccountLocked: 'Tài khoản đã bị khóa',
  Str.errorAuthCurrentPasswordInvalid: 'Mật khẩu hiện tại không đúng',
  Str.errorForbidden: 'Bị từ chối truy cập',
  Str.errorForbiddenPlaylistAccess: 'Không có quyền truy cập playlist này',

  // Not found
  Str.errorNotFound: 'Không tìm thấy dữ liệu',
  Str.errorNotFoundUser: 'Không tìm thấy người dùng',
  Str.errorNotFoundSong: 'Không tìm thấy bài hát',
  Str.errorNotFoundArtist: 'Không tìm thấy nghệ sĩ',
  Str.errorNotFoundAlbum: 'Không tìm thấy album',
  Str.errorNotFoundGenre: 'Không tìm thấy thể loại',
  Str.errorNotFoundPlayHistory: 'Không tìm thấy lịch sử phát',
  Str.errorNotFoundPlaylist: 'Không tìm thấy playlist',
  Str.errorNotFoundPlaylistSong: 'Không tìm thấy bài hát trong playlist',
  Str.errorNotFoundSystemPlaylist: 'Không tìm thấy playlist hệ thống',
  Str.errorNotFoundSystemPlaylistSong: 'Không tìm thấy bài hát trong playlist hệ thống',
  Str.errorNotFoundFavorite: 'Không tìm thấy trong mục yêu thích',
  Str.errorNotFoundLyrics: 'Không tìm thấy lời bài hát',
  Str.errorNotFoundTag: 'Không tìm thấy thẻ (tag)',

  // Conflict
  Str.errorConflict: 'Dữ liệu bị xung đột',
  Str.errorConflictEmailExists: 'Email đã tồn tại',
  Str.errorConflictFavoriteExists: 'Mục này đã có trong danh sách yêu thích',
  Str.errorConflictPlaylistSongExists: 'Bài hát đã có trong playlist',
  Str.errorConflictSystemPlaylistSongExists: 'Bài hát đã có trong playlist hệ thống',
  Str.errorConflictLyricsExists: 'Lời bài hát đã tồn tại',
  Str.errorConflictSlugExists: 'Đường dẫn (slug) đã tồn tại',

  // Bad request / Business rule
  Str.errorBadRequest: 'Yêu cầu không hợp lệ',
  Str.errorBadRequestInvalidBody: 'Dữ liệu gửi lên không đúng định dạng',
  Str.errorBadRequestTypeMismatch: 'Sai kiểu dữ liệu',
  Str.errorQueryRequired: 'Thiếu tham số tìm kiếm',
  Str.errorSongAudioRequired: 'Bắt buộc phải có file âm thanh bài hát',
  Str.errorSongAudioSourceNotFound: 'Không tìm thấy nguồn phát âm thanh',
  Str.errorTagIdsRequired: 'Bắt buộc phải có danh sách thẻ (tag ID)',
  Str.errorPlaylistVisibilityInvalid: 'Trạng thái hiển thị playlist không hợp lệ',
  Str.errorPlaylistNameRequired: 'Tên playlist không được để trống',
  Str.errorPlaylistNameTooLong: 'Tên playlist quá dài',
  Str.errorTagNameExists: 'Tên thẻ (tag) đã tồn tại',
  Str.errorTagNameRequired: 'Tên thẻ không được để trống',
  Str.errorTagTypeRequired: 'Loại thẻ không được để trống',
  Str.errorTagTypeInvalid: 'Loại thẻ không hợp lệ',
  Str.errorPlaylistReorderInvalid: 'Sắp xếp playlist không hợp lệ',
  Str.errorSystemPlaylistReorderInvalid: 'Sắp xếp playlist hệ thống không hợp lệ',
  Str.errorLyricsSyncedInvalid: 'Định dạng lời bài hát đồng bộ không hợp lệ',

  // System / Storage
  Str.errorStorageOperationFailed: 'Lỗi khi lưu trữ file',
  Str.errorInternal: 'Lỗi hệ thống',

  // Validation codes
  Str.validationNotBlank: 'Không được để trống',
  Str.validationNotNull: 'Bắt buộc phải có giá trị',
  Str.validationNotEmpty: 'Danh sách không được rỗng',
  Str.validationSizeMin: 'Kích thước nhỏ hơn mức cho phép',
  Str.validationSizeMax: 'Kích thước vượt quá mức cho phép',
  Str.validationSizeRange: 'Kích thước không nằm trong khoảng cho phép',
  Str.validationEmail: 'Email không đúng định dạng',
  Str.validationPattern: 'Dữ liệu không đúng định dạng',
  Str.validationPositiveOrZero: 'Giá trị phải lớn hơn hoặc bằng 0',
  Str.validationInvalidFormat: 'Định dạng không hợp lệ',
  Str.validationTypeMismatch: 'Sai kiểu dữ liệu',
  Str.validationRequired: 'Trường này là bắt buộc',

  // Fallback
  Str.unknownError: 'Lỗi không xác định',

  // ── UI strings ─────────────────────────────────────────────────────────────

  // Common UI
  Str.retry: 'Thử lại',
  Str.cancel: 'Hủy',
  Str.confirm: 'Xác nhận',
  Str.languageEnglish: 'Tiếng Anh',
  Str.languageVietnamese: 'Tiếng Việt',
  Str.navHome: 'Trang chủ',
  Str.navSearch: 'Tìm kiếm',
  Str.navLibrary: 'Thư viện',
  Str.navProfile: 'Cá nhân',

  // Login screen
  Str.loginSubtitle: 'Đăng nhập vào Ondas',
  Str.loginEmail: 'Email',
  Str.loginEmailHint: 'email@example.com',
  Str.loginEmailRequired: 'Vui lòng nhập email',
  Str.loginEmailInvalid: 'Email không hợp lệ',
  Str.loginEmailTooShort: 'Email phải có ít nhất 6 ký tự',
  Str.loginEmailTooLong: 'Email tối đa 255 ký tự',
  Str.loginPassword: 'Mật khẩu',
  Str.loginPasswordRequired: 'Vui lòng nhập mật khẩu',
  Str.loginPasswordTooShort: 'Mật khẩu phải có ít nhất 6 ký tự',
  Str.loginPasswordTooLong: 'Mật khẩu tối đa 128 ký tự',
  Str.loginForgotPassword: 'Quên mật khẩu?',
  Str.loginButton: 'ĐĂNG NHẬP',
  Str.loginNoAccount: 'Chưa có tài khoản?',
  Str.loginGoRegister: 'Đăng ký',

  // Register screen
  Str.registerTitle: 'Tạo tài khoản Ondas',
  Str.registerSubtitle: 'Miễn phí. Không giới hạn.',
  Str.registerFullName: 'Họ và tên',
  Str.registerFullNameHint: 'Nguyễn Văn A',
  Str.registerFullNameRequired: 'Vui lòng nhập họ và tên',
  Str.registerFullNameTooShort: 'Họ và tên phải có ít nhất 2 ký tự',
  Str.registerEmailRequired: 'Vui lòng nhập email',
  Str.registerEmailInvalid: 'Email không hợp lệ',
  Str.registerPasswordRequired: 'Vui lòng nhập mật khẩu',
  Str.registerPasswordTooShort: 'Mật khẩu phải có ít nhất 6 ký tự',
  Str.registerConfirmPassword: 'Xác nhận mật khẩu',
  Str.registerConfirmPasswordRequired: 'Vui lòng xác nhận mật khẩu',
  Str.registerPasswordMismatch: 'Mật khẩu không khớp',
  Str.registerButton: 'TẠO TÀI KHOẢN',
  Str.registerHasAccount: 'Đã có tài khoản?',
  Str.registerGoLogin: 'Đăng nhập',

  // Forgot password screen
  Str.forgotPasswordSubtitle: 'Quên mật khẩu',
  Str.forgotPasswordDescription: 'Nhập email đã đăng ký, chúng tôi sẽ gửi mã OTP để đặt lại mật khẩu.',
  Str.forgotPasswordEmailRequired: 'Vui lòng nhập email',
  Str.forgotPasswordEmailInvalid: 'Email không hợp lệ',
  Str.forgotPasswordSendOtp: 'GỬI MÃ OTP',
  Str.forgotPasswordRemembered: 'Đã nhớ mật khẩu?',
  Str.forgotPasswordGoLogin: 'Đăng nhập',

  // Reset password screen
  Str.resetPasswordSubtitle: 'Đặt lại mật khẩu',
  Str.resetPasswordOtpLabel: 'Mã OTP',
  Str.resetPasswordOtpRequired: 'Vui lòng nhập mã OTP',
  Str.resetPasswordOtpInvalid: 'Mã OTP phải có 6 chữ số',
  Str.resetPasswordNewLabel: 'Mật khẩu mới',
  Str.resetPasswordNewRequired: 'Vui lòng nhập mật khẩu mới',
  Str.resetPasswordNewTooShort: 'Mật khẩu phải có ít nhất 8 ký tự',
  Str.resetPasswordConfirmLabel: 'Xác nhận mật khẩu',
  Str.resetPasswordConfirmRequired: 'Vui lòng xác nhận mật khẩu',
  Str.resetPasswordMismatch: 'Mật khẩu không khớp',
  Str.resetPasswordButton: 'ĐẶT LẠI MẬT KHẨU',
  Str.resetPasswordSuccess: 'Đặt lại mật khẩu thành công. Vui lòng đăng nhập lại.',

  // Profile screen
  Str.profileTitle: 'Trang cá nhân',
  Str.profileUpdateSuccess: 'Cập nhật thông tin thành công',
  Str.profileAvatarSuccess: 'Cập nhật ảnh đại diện thành công',
  Str.profilePasswordSuccess: 'Đổi mật khẩu thành công',
  Str.profileSectionAccount: 'Tài khoản',
  Str.profileSectionActivity: 'Hoạt động',
  Str.profileSectionSession: 'Phiên đăng nhập',
  Str.profileEditButton: 'Chỉnh sửa hồ sơ',
  Str.profileChangePassword: 'Đổi mật khẩu',
  Str.profileLanguage: 'Ngôn ngữ',
  Str.profileListeningHistory: 'Lịch sử nghe nhạc',
  Str.profileLogout: 'Đăng xuất',
  Str.profileLogoutTitle: 'Đăng xuất',
  Str.profileLogoutConfirm: 'Bạn có chắc muốn đăng xuất không?',
  Str.profileLogoutButton: 'Đăng xuất',

  // History screen
  Str.historyTitle: 'Lịch sử nghe nhạc',
  Str.historyEmpty: 'Chưa có lịch sử nghe nhạc',
  Str.historyClearAll: 'Xóa tất cả',
  Str.historyClearTitle: 'Xóa toàn bộ lịch sử?',
  Str.historyClearConfirm: 'Hành động này không thể hoàn tác.',
  Str.historyClearButton: 'Xóa tất cả',
  Str.historyCleared: 'Đã xóa lịch sử',

  // Home screen
  Str.homeScreenTrending: 'Thịnh hành',
  Str.homeScreenFeaturedArtists: 'Nghệ sĩ nổi bật',
  Str.homeScreenNewReleases: 'Mới phát hành',

  // Library screen
  Str.libraryTitle: 'Thư viện',
  Str.libraryFavoriteTab: 'Yêu thích',
  Str.libraryPlaylistTab: 'Playlist',
  Str.libraryCreatePlaylist: 'Tạo playlist mới',
  Str.libraryMyPlaylists: 'Playlist của bạn',
  Str.libraryEmptyPlaylists: 'Chưa có playlist. Hãy tạo playlist mới!',
  Str.librarySystemPlaylists: 'Playlist hệ thống',
  Str.libraryEmptySystemPlaylists: 'Chưa có playlist hệ thống.',
  Str.libraryLoadError: 'Không thể tải playlist',

  // Favorites
  Str.favoritesLoadError: 'Không thể tải danh sách yêu thích',
  Str.favoritesEmptyTitle: 'Chưa có bài hát yêu thích',
  Str.favoritesEmptySubtitle: 'Nhấn biểu tượng ♥ để thêm bài hát',

  // Search screen
  Str.searchHint: 'Tìm bài hát, nghệ sĩ, album...',
  Str.searchRecent: 'Tìm kiếm gần đây',
  Str.searchClearAll: 'Xóa tất cả',
  Str.searchTrending: 'Xu hướng',
  Str.searchBrowseTags: 'Khám phá theo thẻ',
  Str.searchTrendingSongs: 'Bài hát xu hướng',
  Str.searchExploreGenres: 'Khám phá theo thể loại',
  Str.searchSectionSongs: 'Bài hát',
  Str.searchSectionArtists: 'Nghệ sĩ',
  Str.searchSectionAlbums: 'Album',
  Str.searchNoResults: 'Không tìm thấy kết quả',
  Str.searchTryDifferentKeyword: 'Thử từ khóa khác',
  Str.searchArtistLabel: 'Nghệ sĩ',
  Str.searchAlbumLabel: 'Album',

  // Player screen
  Str.playerTabPlaying: 'Đang phát',
  Str.playerTabLyrics: 'Lời bài hát',
  Str.playerTabQueue: 'Danh sách phát',
  Str.playerNowPlaying: 'Đang phát',
  Str.playerNoSongPlaying: 'Không có bài hát đang phát',
  Str.playerQueueEmpty: 'Danh sách phát trống',
  Str.playerLyricsEmptyTitle: 'Chưa có lời bài hát',
  Str.playerLyricsEmptySubtitle: 'Lời bài hát sẽ hiển thị ở đây',
  Str.playerLyricsLoading: 'Đang tải lời bài hát...',
  Str.playerLyricsError: 'Không thể tải lời bài hát',
};

const Map<Str, String> _en = {
  // Common
  Str.successOk: 'Success',
  Str.offlineMessage: 'You are offline. Please check your network connection.',

  // Auth / Permission
  Str.errorUnauthorized: 'Unauthorized',
  Str.errorUnauthorizedInvalidCredentials: 'Invalid username or password',
  Str.errorUnauthorizedInvalidToken: 'Session expired',
  Str.errorAccountLocked: 'Account is locked',
  Str.errorAuthCurrentPasswordInvalid: 'Current password is not correct',
  Str.errorForbidden: 'Access denied',
  Str.errorForbiddenPlaylistAccess: 'No permission to access this playlist',

  // Not found
  Str.errorNotFound: 'Data not found',
  Str.errorNotFoundUser: 'User not found',
  Str.errorNotFoundSong: 'Song not found',
  Str.errorNotFoundArtist: 'Artist not found',
  Str.errorNotFoundAlbum: 'Album not found',
  Str.errorNotFoundGenre: 'Genre not found',
  Str.errorNotFoundPlayHistory: 'Play history not found',
  Str.errorNotFoundPlaylist: 'Playlist not found',
  Str.errorNotFoundPlaylistSong: 'Song not found in playlist',
  Str.errorNotFoundSystemPlaylist: 'System playlist not found',
  Str.errorNotFoundSystemPlaylistSong: 'Song not found in system playlist',
  Str.errorNotFoundFavorite: 'Not found in favorites',
  Str.errorNotFoundLyrics: 'Lyrics not found',
  Str.errorNotFoundTag: 'Tag not found',

  // Conflict
  Str.errorConflict: 'Data conflict',
  Str.errorConflictEmailExists: 'Email already exists',
  Str.errorConflictFavoriteExists: 'Item already in favorites',
  Str.errorConflictPlaylistSongExists: 'Song already in playlist',
  Str.errorConflictSystemPlaylistSongExists: 'Song already in system playlist',
  Str.errorConflictLyricsExists: 'Lyrics already exist',
  Str.errorConflictSlugExists: 'Slug already exists',

  // Bad request / Business rule
  Str.errorBadRequest: 'Bad request',
  Str.errorBadRequestInvalidBody: 'Invalid request body format',
  Str.errorBadRequestTypeMismatch: 'Type mismatch',
  Str.errorQueryRequired: 'Search query is required',
  Str.errorSongAudioRequired: 'Song audio file is required',
  Str.errorSongAudioSourceNotFound: 'Audio source not found',
  Str.errorTagIdsRequired: 'Tag IDs are required',
  Str.errorPlaylistVisibilityInvalid: 'Invalid playlist visibility',
  Str.errorPlaylistNameRequired: 'Playlist name is required',
  Str.errorPlaylistNameTooLong: 'Playlist name is too long',
  Str.errorTagNameExists: 'Tag name already exists',
  Str.errorTagNameRequired: 'Tag name is required',
  Str.errorTagTypeRequired: 'Tag type is required',
  Str.errorTagTypeInvalid: 'Invalid tag type',
  Str.errorPlaylistReorderInvalid: 'Invalid playlist reorder',
  Str.errorSystemPlaylistReorderInvalid: 'Invalid system playlist reorder',
  Str.errorLyricsSyncedInvalid: 'Invalid synced lyrics format',

  // System / Storage
  Str.errorStorageOperationFailed: 'Storage operation failed',
  Str.errorInternal: 'Internal server error',

  // Validation codes
  Str.validationNotBlank: 'Must not be blank',
  Str.validationNotNull: 'Must not be null',
  Str.validationNotEmpty: 'Must not be empty',
  Str.validationSizeMin: 'Size is below minimum allowed',
  Str.validationSizeMax: 'Size exceeds maximum allowed',
  Str.validationSizeRange: 'Size is not within allowed range',
  Str.validationEmail: 'Invalid email format',
  Str.validationPattern: 'Invalid data format',
  Str.validationPositiveOrZero: 'Must be positive or zero',
  Str.validationInvalidFormat: 'Invalid format',
  Str.validationTypeMismatch: 'Type mismatch',
  Str.validationRequired: 'This field is required',

  // Fallback
  Str.unknownError: 'Unknown error',

  // ── UI strings ─────────────────────────────────────────────────────────────

  // Common UI
  Str.retry: 'Retry',
  Str.cancel: 'Cancel',
  Str.confirm: 'Confirm',
  Str.languageEnglish: 'English',
  Str.languageVietnamese: 'Vietnamese',
  Str.navHome: 'Home',
  Str.navSearch: 'Search',
  Str.navLibrary: 'Library',
  Str.navProfile: 'Profile',

  // Login screen
  Str.loginSubtitle: 'Log in to Ondas',
  Str.loginEmail: 'Email',
  Str.loginEmailHint: 'email@example.com',
  Str.loginEmailRequired: 'Please enter your email',
  Str.loginEmailInvalid: 'Invalid email',
  Str.loginEmailTooShort: 'Email must be at least 6 characters',
  Str.loginEmailTooLong: 'Email must be at most 255 characters',
  Str.loginPassword: 'Password',
  Str.loginPasswordRequired: 'Please enter your password',
  Str.loginPasswordTooShort: 'Password must be at least 6 characters',
  Str.loginPasswordTooLong: 'Password must be at most 128 characters',
  Str.loginForgotPassword: 'Forgot password?',
  Str.loginButton: 'LOG IN',
  Str.loginNoAccount: "Don't have an account?",
  Str.loginGoRegister: 'Register',

  // Register screen
  Str.registerTitle: 'Create an Ondas account',
  Str.registerSubtitle: 'Free. Unlimited.',
  Str.registerFullName: 'Full Name',
  Str.registerFullNameHint: 'John Doe',
  Str.registerFullNameRequired: 'Please enter your full name',
  Str.registerFullNameTooShort: 'Full name must be at least 2 characters',
  Str.registerEmailRequired: 'Please enter your email',
  Str.registerEmailInvalid: 'Invalid email',
  Str.registerPasswordRequired: 'Please enter your password',
  Str.registerPasswordTooShort: 'Password must be at least 6 characters',
  Str.registerConfirmPassword: 'Confirm Password',
  Str.registerConfirmPasswordRequired: 'Please confirm your password',
  Str.registerPasswordMismatch: 'Passwords do not match',
  Str.registerButton: 'CREATE ACCOUNT',
  Str.registerHasAccount: 'Already have an account?',
  Str.registerGoLogin: 'Log in',

  // Forgot password screen
  Str.forgotPasswordSubtitle: 'Forgot Password',
  Str.forgotPasswordDescription: 'Enter your registered email, we will send an OTP to reset your password.',
  Str.forgotPasswordEmailRequired: 'Please enter your email',
  Str.forgotPasswordEmailInvalid: 'Invalid email',
  Str.forgotPasswordSendOtp: 'SEND OTP',
  Str.forgotPasswordRemembered: 'Remembered your password?',
  Str.forgotPasswordGoLogin: 'Log in',

  // Reset password screen
  Str.resetPasswordSubtitle: 'Reset Password',
  Str.resetPasswordOtpLabel: 'OTP Code',
  Str.resetPasswordOtpRequired: 'Please enter the OTP code',
  Str.resetPasswordOtpInvalid: 'OTP must be 6 digits',
  Str.resetPasswordNewLabel: 'New Password',
  Str.resetPasswordNewRequired: 'Please enter your new password',
  Str.resetPasswordNewTooShort: 'Password must be at least 8 characters',
  Str.resetPasswordConfirmLabel: 'Confirm Password',
  Str.resetPasswordConfirmRequired: 'Please confirm your password',
  Str.resetPasswordMismatch: 'Passwords do not match',
  Str.resetPasswordButton: 'RESET PASSWORD',
  Str.resetPasswordSuccess: 'Password reset successful. Please log in.',

  // Profile screen
  Str.profileTitle: 'Profile',
  Str.profileUpdateSuccess: 'Profile updated successfully',
  Str.profileAvatarSuccess: 'Avatar updated successfully',
  Str.profilePasswordSuccess: 'Password changed successfully',
  Str.profileSectionAccount: 'Account',
  Str.profileSectionActivity: 'Activity',
  Str.profileSectionSession: 'Session',
  Str.profileEditButton: 'Edit Profile',
  Str.profileChangePassword: 'Change Password',
  Str.profileLanguage: 'Language',
  Str.profileListeningHistory: 'Listening History',
  Str.profileLogout: 'Log Out',
  Str.profileLogoutTitle: 'Log Out',
  Str.profileLogoutConfirm: 'Are you sure you want to log out?',
  Str.profileLogoutButton: 'Log Out',

  // History screen
  Str.historyTitle: 'Listening History',
  Str.historyEmpty: 'No listening history yet',
  Str.historyClearAll: 'Clear All',
  Str.historyClearTitle: 'Clear all history?',
  Str.historyClearConfirm: 'This action cannot be undone.',
  Str.historyClearButton: 'Clear All',
  Str.historyCleared: 'History cleared',

  // Home screen
  Str.homeScreenTrending: 'Trending',
  Str.homeScreenFeaturedArtists: 'Featured Artists',
  Str.homeScreenNewReleases: 'New Releases',

  // Library screen
  Str.libraryTitle: 'Library',
  Str.libraryFavoriteTab: 'Favorite',
  Str.libraryPlaylistTab: 'Playlist',
  Str.libraryCreatePlaylist: 'Create New Playlist',
  Str.libraryMyPlaylists: 'My Playlists',
  Str.libraryEmptyPlaylists: 'No playlists available. Create a new playlist!',
  Str.librarySystemPlaylists: 'System Playlists',
  Str.libraryEmptySystemPlaylists: 'No system playlists yet.',
  Str.libraryLoadError: 'Unable to load playlists',

  // Favorites
  Str.favoritesLoadError: 'Unable to load favorites',
  Str.favoritesEmptyTitle: 'No favorite songs yet',
  Str.favoritesEmptySubtitle: 'Tap the ♥ icon to add songs',

  // Search screen
  Str.searchHint: 'Search songs, artists, albums...',
  Str.searchRecent: 'Recent searches',
  Str.searchClearAll: 'Clear all',
  Str.searchTrending: 'Trending',
  Str.searchBrowseTags: 'Browse by tags',
  Str.searchTrendingSongs: 'Trending songs',
  Str.searchExploreGenres: 'Explore by genre',
  Str.searchSectionSongs: 'Songs',
  Str.searchSectionArtists: 'Artists',
  Str.searchSectionAlbums: 'Albums',
  Str.searchNoResults: 'No results found',
  Str.searchTryDifferentKeyword: 'Try a different keyword',
  Str.searchArtistLabel: 'Artist',
  Str.searchAlbumLabel: 'Album',

  // Player screen
  Str.playerTabPlaying: 'Playing',
  Str.playerTabLyrics: 'Lyrics',
  Str.playerTabQueue: 'Queue',
  Str.playerNowPlaying: 'Now Playing',
  Str.playerNoSongPlaying: 'No song playing',
  Str.playerQueueEmpty: 'Queue is empty',
  Str.playerLyricsEmptyTitle: 'Lyrics not available',
  Str.playerLyricsEmptySubtitle: 'Lyrics will appear here',
  Str.playerLyricsLoading: 'Loading lyrics...',
  Str.playerLyricsError: 'Unable to load lyrics',
};

/// Trả về chuỗi đúng ngôn ngữ, fallback về tiếng Anh nếu thiếu
String t(Str key, String lang) {
  if (lang == 'vi') {
    return _vi[key] ?? _en[key] ?? key.name;
  }
  return _en[key] ?? key.name;
}

/// Helper lấy ngôn ngữ hiện tại từ context (không cần truyền tay)
String lang(BuildContext context) {
  return context.read<LanguageCubit>().state;
}
