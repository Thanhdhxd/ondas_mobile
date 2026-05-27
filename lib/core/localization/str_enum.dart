enum Str {
  // Common
  successOk,
  offlineMessage,

  // Auth / Permission
  errorUnauthorized,
  errorUnauthorizedInvalidCredentials,
  errorUnauthorizedInvalidToken,
  errorAccountLocked,
  errorAuthCurrentPasswordInvalid,
  errorForbidden,
  errorForbiddenPlaylistAccess,

  // Not found
  errorNotFound,
  errorNotFoundUser,
  errorNotFoundSong,
  errorNotFoundArtist,
  errorNotFoundAlbum,
  errorNotFoundGenre,
  errorNotFoundPlayHistory,
  errorNotFoundPlaylist,
  errorNotFoundPlaylistSong,
  errorNotFoundSystemPlaylist,
  errorNotFoundSystemPlaylistSong,
  errorNotFoundFavorite,
  errorNotFoundLyrics,
  errorNotFoundTag,

  // Conflict
  errorConflict,
  errorConflictEmailExists,
  errorConflictFavoriteExists,
  errorConflictPlaylistSongExists,
  errorConflictSystemPlaylistSongExists,
  errorConflictLyricsExists,
  errorConflictSlugExists,

  // Bad request / Business rule
  errorBadRequest,
  errorBadRequestInvalidBody,
  errorBadRequestTypeMismatch,
  errorQueryRequired,
  errorSongAudioRequired,
  errorSongAudioSourceNotFound,
  errorTagIdsRequired,
  errorPlaylistVisibilityInvalid,
  errorPlaylistNameRequired,
  errorPlaylistNameTooLong,
  errorTagNameExists,
  errorTagNameRequired,
  errorTagTypeRequired,
  errorTagTypeInvalid,
  errorPlaylistReorderInvalid,
  errorSystemPlaylistReorderInvalid,
  errorLyricsSyncedInvalid,

  // System / Storage
  errorStorageOperationFailed,
  errorInternal,

  // Validation codes
  validationNotBlank,
  validationNotNull,
  validationNotEmpty,
  validationSizeMin,
  validationSizeMax,
  validationSizeRange,
  validationEmail,
  validationPattern,
  validationPositiveOrZero,
  validationInvalidFormat,
  validationTypeMismatch,
  validationRequired,

  // Fallback
  unknownError,

  // ── UI strings ─────────────────────────────────────────────────────────────

  // Common UI
  retry,
  cancel,
  confirm,
  languageEnglish,
  languageVietnamese,
  navHome,
  navSearch,
  navLibrary,
  navProfile,

  // Login screen
  loginSubtitle,
  loginEmail,
  loginEmailHint,
  loginEmailRequired,
  loginEmailInvalid,
  loginEmailTooShort,
  loginEmailTooLong,
  loginPassword,
  loginPasswordRequired,
  loginPasswordTooShort,
  loginPasswordTooLong,
  loginForgotPassword,
  loginButton,
  loginNoAccount,
  loginGoRegister,

  // Register screen
  registerTitle,
  registerSubtitle,
  registerFullName,
  registerFullNameHint,
  registerFullNameRequired,
  registerFullNameTooShort,
  registerEmailRequired,
  registerEmailInvalid,
  registerPasswordRequired,
  registerPasswordTooShort,
  registerConfirmPassword,
  registerConfirmPasswordRequired,
  registerPasswordMismatch,
  registerButton,
  registerHasAccount,
  registerGoLogin,

  // Forgot password screen
  forgotPasswordSubtitle,
  forgotPasswordDescription,
  forgotPasswordEmailRequired,
  forgotPasswordEmailInvalid,
  forgotPasswordSendOtp,
  forgotPasswordRemembered,
  forgotPasswordGoLogin,

  // Reset password screen
  resetPasswordSubtitle,
  resetPasswordOtpLabel,
  resetPasswordOtpRequired,
  resetPasswordOtpInvalid,
  resetPasswordNewLabel,
  resetPasswordNewRequired,
  resetPasswordNewTooShort,
  resetPasswordConfirmLabel,
  resetPasswordConfirmRequired,
  resetPasswordMismatch,
  resetPasswordButton,
  resetPasswordSuccess,

  // Profile screen
  profileTitle,
  profileUpdateSuccess,
  profileAvatarSuccess,
  profilePasswordSuccess,
  profileSectionAccount,
  profileSectionActivity,
  profileSectionSession,
  profileEditButton,
  profileChangePassword,
  profileLanguage,
  profileListeningHistory,
  profileLogout,
  profileLogoutTitle,
  profileLogoutConfirm,
  profileLogoutButton,

  // History screen
  historyTitle,
  historyEmpty,
  historyClearAll,
  historyClearTitle,
  historyClearConfirm,
  historyClearButton,
  historyCleared,

  // Home screen
  homeScreenTrending,
  homeScreenFeaturedArtists,
  homeScreenNewReleases,

  // Library screen
  libraryTitle,
  libraryFavoriteTab,
  libraryPlaylistTab,
  libraryCreatePlaylist,
  libraryMyPlaylists,
  libraryEmptyPlaylists,
  librarySystemPlaylists,
  libraryEmptySystemPlaylists,
  libraryLoadError,

  // Favorites
  favoritesLoadError,
  favoritesEmptyTitle,
  favoritesEmptySubtitle,

  // Search screen
  searchHint,
  searchRecent,
  searchClearAll,
  searchTrending,
  searchBrowseTags,
  searchTrendingSongs,
  searchExploreGenres,
  searchSectionSongs,
  searchSectionArtists,
  searchSectionAlbums,
  searchNoResults,
  searchTryDifferentKeyword,
  searchArtistLabel,
  searchAlbumLabel,

  // Player screen
  playerTabPlaying,
  playerTabLyrics,
  playerTabQueue,
  playerNowPlaying,
  playerNoSongPlaying,
  playerQueueEmpty,
  playerLyricsEmptyTitle,
  playerLyricsEmptySubtitle,
  playerLyricsLoading,
  playerLyricsError,
}

extension StrExtension on Str {
  /// Helper để convert từ String backend trả về sang Enum
  /// Ví dụ: "error.not_found.song" -> Str.errorNotFoundSong
  static Str fromCode(String code) {
    // Chuyển dấu '.' và '_' thành dạng camelCase
    // Ví dụ: error.not_found -> error_not_found -> errorNotFound
    final parts = code.split(RegExp(r'[._]'));
    if (parts.isEmpty) return Str.unknownError;

    var camelCase = parts[0];
    for (var i = 1; i < parts.length; i++) {
      if (parts[i].isNotEmpty) {
        camelCase += parts[i][0].toUpperCase() + parts[i].substring(1);
      }
    }

    return Str.values.firstWhere(
      (e) => e.name == camelCase,
      orElse: () => Str.unknownError,
    );
  }
}
