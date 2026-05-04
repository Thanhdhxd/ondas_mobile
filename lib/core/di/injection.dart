import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:ondas_mobile/core/network/dio_client.dart';
import 'package:ondas_mobile/features/songs/data/datasources/songs_remote_datasource.dart';
import 'package:ondas_mobile/features/songs/data/datasources/songs_remote_datasource_impl.dart';
import 'package:ondas_mobile/features/songs/data/repositories/songs_repository_impl.dart';
import 'package:ondas_mobile/features/songs/domain/repositories/songs_repository.dart';
import 'package:ondas_mobile/features/songs/domain/usecases/get_songs_usecase.dart';
import 'package:ondas_mobile/features/songs/domain/usecases/get_songs_usecase_impl.dart';
import 'package:ondas_mobile/features/songs/presentation/bloc/song_list_bloc.dart';
import 'package:ondas_mobile/features/library/presentation/bloc/library_bloc.dart';
import 'package:ondas_mobile/features/library/presentation/bloc/playlist_detail_bloc.dart';
import 'package:ondas_mobile/features/search/data/datasources/search_remote_datasource.dart';
import 'package:ondas_mobile/features/search/data/datasources/search_remote_datasource_impl.dart';
import 'package:ondas_mobile/features/search/data/repositories/search_repository_impl.dart';
import 'package:ondas_mobile/features/search/domain/repositories/search_repository.dart';
import 'package:ondas_mobile/features/search/domain/usecases/clear_search_history_usecase.dart';
import 'package:ondas_mobile/features/search/domain/usecases/clear_search_history_usecase_impl.dart';
import 'package:ondas_mobile/features/search/domain/usecases/get_search_suggestions_usecase.dart';
import 'package:ondas_mobile/features/search/domain/usecases/get_search_suggestions_usecase_impl.dart';
import 'package:ondas_mobile/features/search/domain/usecases/search_usecase.dart';
import 'package:ondas_mobile/features/search/domain/usecases/search_usecase_impl.dart';
import 'package:ondas_mobile/features/search/presentation/bloc/search_bloc.dart';
import 'package:ondas_mobile/features/favorites/data/datasources/favorites_remote_datasource.dart';
import 'package:ondas_mobile/features/favorites/data/datasources/favorites_remote_datasource_impl.dart';
import 'package:ondas_mobile/features/favorites/data/repositories/favorites_repository_impl.dart';
import 'package:ondas_mobile/features/favorites/domain/repositories/favorites_repository.dart';
import 'package:ondas_mobile/features/favorites/domain/usecases/add_favorite_usecase.dart';
import 'package:ondas_mobile/features/favorites/domain/usecases/add_favorite_usecase_impl.dart';
import 'package:ondas_mobile/features/favorites/domain/usecases/remove_favorite_usecase.dart';
import 'package:ondas_mobile/features/favorites/domain/usecases/remove_favorite_usecase_impl.dart';
import 'package:ondas_mobile/features/favorites/domain/usecases/check_favorite_status_usecase.dart';
import 'package:ondas_mobile/features/favorites/domain/usecases/check_favorite_status_usecase_impl.dart';
import 'package:ondas_mobile/features/favorites/domain/usecases/get_favorites_usecase.dart';
import 'package:ondas_mobile/features/favorites/domain/usecases/get_favorites_usecase_impl.dart';
import 'package:ondas_mobile/features/favorites/presentation/bloc/favorites_bloc.dart';
import 'package:ondas_mobile/features/favorites/presentation/bloc/favorite_toggle_bloc.dart';
import 'package:ondas_mobile/features/playlist/data/datasources/playlist_remote_datasource.dart';
import 'package:ondas_mobile/features/playlist/data/datasources/playlist_remote_datasource_impl.dart';
import 'package:ondas_mobile/features/playlist/data/repositories/playlist_repository_impl.dart';
import 'package:ondas_mobile/features/playlist/domain/repositories/playlist_repository.dart';
import 'package:ondas_mobile/features/playlist/domain/usecases/add_song_to_playlist_usecase.dart';
import 'package:ondas_mobile/features/playlist/domain/usecases/add_song_to_playlist_usecase_impl.dart';
import 'package:ondas_mobile/features/playlist/domain/usecases/create_playlist_usecase.dart';
import 'package:ondas_mobile/features/playlist/domain/usecases/create_playlist_usecase_impl.dart';
import 'package:ondas_mobile/features/playlist/domain/usecases/delete_playlist_usecase.dart';
import 'package:ondas_mobile/features/playlist/domain/usecases/delete_playlist_usecase_impl.dart';
import 'package:ondas_mobile/features/playlist/domain/usecases/get_library_playlists_usecase.dart';
import 'package:ondas_mobile/features/playlist/domain/usecases/get_library_playlists_usecase_impl.dart';
import 'package:ondas_mobile/features/playlist/domain/usecases/get_my_playlists_usecase.dart';
import 'package:ondas_mobile/features/playlist/domain/usecases/get_my_playlists_usecase_impl.dart';
import 'package:ondas_mobile/features/playlist/domain/usecases/get_playlist_detail_usecase.dart';
import 'package:ondas_mobile/features/playlist/domain/usecases/get_playlist_detail_usecase_impl.dart';
import 'package:ondas_mobile/features/playlist/domain/usecases/remove_song_from_playlist_usecase.dart';
import 'package:ondas_mobile/features/playlist/domain/usecases/remove_song_from_playlist_usecase_impl.dart';
import 'package:ondas_mobile/features/playlist/domain/usecases/reorder_playlist_songs_usecase.dart';
import 'package:ondas_mobile/features/playlist/domain/usecases/reorder_playlist_songs_usecase_impl.dart';
import 'package:ondas_mobile/features/playlist/domain/usecases/update_playlist_usecase.dart';
import 'package:ondas_mobile/features/playlist/domain/usecases/update_playlist_usecase_impl.dart';
import 'package:ondas_mobile/features/playlist/presentation/bloc/save_to_playlist_bloc.dart';
import 'package:ondas_mobile/core/network/jwt_interceptor.dart';
import 'package:ondas_mobile/core/storage/secure_storage.dart';
import 'package:ondas_mobile/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:ondas_mobile/features/auth/data/datasources/auth_remote_datasource_impl.dart';
import 'package:ondas_mobile/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:ondas_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:ondas_mobile/features/auth/domain/usecases/forgot_password_usecase.dart';
import 'package:ondas_mobile/features/auth/domain/usecases/forgot_password_usecase_impl.dart';
import 'package:ondas_mobile/features/auth/domain/usecases/login_usecase.dart';
import 'package:ondas_mobile/features/auth/domain/usecases/login_usecase_impl.dart';
import 'package:ondas_mobile/features/auth/domain/usecases/logout_usecase.dart';
import 'package:ondas_mobile/features/auth/domain/usecases/logout_usecase_impl.dart';
import 'package:ondas_mobile/features/auth/domain/usecases/register_usecase.dart';
import 'package:ondas_mobile/features/auth/domain/usecases/register_usecase_impl.dart';
import 'package:ondas_mobile/features/auth/domain/usecases/reset_password_usecase.dart';
import 'package:ondas_mobile/features/auth/domain/usecases/reset_password_usecase_impl.dart';
import 'package:ondas_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ondas_mobile/features/auth/presentation/bloc/forgot_password_bloc.dart';
import 'package:ondas_mobile/features/auth/presentation/bloc/reset_password_bloc.dart';
import 'package:ondas_mobile/features/home/data/datasources/home_remote_datasource.dart';
import 'package:ondas_mobile/features/home/data/datasources/home_remote_datasource_impl.dart';
import 'package:ondas_mobile/features/home/data/repositories/home_repository_impl.dart';
import 'package:ondas_mobile/features/home/domain/repositories/home_repository.dart';
import 'package:ondas_mobile/features/home/domain/usecases/get_home_data_usecase.dart';
import 'package:ondas_mobile/features/home/domain/usecases/get_home_data_usecase_impl.dart';
import 'package:ondas_mobile/features/home/presentation/bloc/home_bloc.dart';
import 'package:ondas_mobile/features/player/data/datasources/play_history_remote_datasource.dart';
import 'package:ondas_mobile/features/player/data/datasources/play_history_remote_datasource_impl.dart';
import 'package:ondas_mobile/features/player/data/repositories/play_history_repository_impl.dart';
import 'package:ondas_mobile/features/player/data/services/audio_player_service_impl.dart';
import 'package:ondas_mobile/features/player/domain/repositories/play_history_repository.dart';
import 'package:ondas_mobile/features/player/domain/usecases/record_play_history_usecase.dart';
import 'package:ondas_mobile/features/player/domain/usecases/record_play_history_usecase_impl.dart';
import 'package:ondas_mobile/features/player/domain/services/audio_player_service.dart';
import 'package:ondas_mobile/features/player/domain/usecases/pause_usecase.dart';
import 'package:ondas_mobile/features/player/domain/usecases/pause_usecase_impl.dart';
import 'package:ondas_mobile/features/player/domain/usecases/play_song_usecase.dart';
import 'package:ondas_mobile/features/player/domain/usecases/play_song_usecase_impl.dart';
import 'package:ondas_mobile/features/player/domain/usecases/resume_usecase.dart';
import 'package:ondas_mobile/features/player/domain/usecases/resume_usecase_impl.dart';
import 'package:ondas_mobile/features/player/domain/usecases/seek_usecase.dart';
import 'package:ondas_mobile/features/player/domain/usecases/seek_usecase_impl.dart';
import 'package:ondas_mobile/features/player/domain/usecases/set_repeat_mode_usecase.dart';
import 'package:ondas_mobile/features/player/domain/usecases/set_repeat_mode_usecase_impl.dart';
import 'package:ondas_mobile/features/player/domain/usecases/set_volume_usecase.dart';
import 'package:ondas_mobile/features/player/domain/usecases/set_volume_usecase_impl.dart';
import 'package:ondas_mobile/features/player/domain/usecases/skip_next_usecase.dart';
import 'package:ondas_mobile/features/player/domain/usecases/skip_next_usecase_impl.dart';
import 'package:ondas_mobile/features/player/domain/usecases/skip_previous_usecase.dart';
import 'package:ondas_mobile/features/player/domain/usecases/skip_previous_usecase_impl.dart';
import 'package:ondas_mobile/features/player/presentation/bloc/player_bloc.dart';
import 'package:ondas_mobile/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:ondas_mobile/features/profile/data/datasources/profile_remote_datasource_impl.dart';
import 'package:ondas_mobile/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:ondas_mobile/features/profile/domain/repositories/profile_repository.dart';
import 'package:ondas_mobile/features/profile/domain/usecases/change_password_usecase.dart';
import 'package:ondas_mobile/features/profile/domain/usecases/change_password_usecase_impl.dart';
import 'package:ondas_mobile/features/profile/domain/usecases/get_profile_usecase.dart';
import 'package:ondas_mobile/features/profile/domain/usecases/get_profile_usecase_impl.dart';
import 'package:ondas_mobile/features/profile/domain/usecases/update_profile_usecase.dart';
import 'package:ondas_mobile/features/profile/domain/usecases/update_profile_usecase_impl.dart';
import 'package:ondas_mobile/features/profile/domain/usecases/upload_avatar_usecase.dart';
import 'package:ondas_mobile/features/profile/domain/usecases/upload_avatar_usecase_impl.dart';
import 'package:ondas_mobile/features/profile/domain/usecases/clear_play_history_usecase.dart';
import 'package:ondas_mobile/features/profile/domain/usecases/clear_play_history_usecase_impl.dart';
import 'package:ondas_mobile/features/profile/domain/usecases/delete_play_history_item_usecase.dart';
import 'package:ondas_mobile/features/profile/domain/usecases/delete_play_history_item_usecase_impl.dart';
import 'package:ondas_mobile/features/profile/domain/usecases/get_play_history_usecase.dart';
import 'package:ondas_mobile/features/profile/domain/usecases/get_play_history_usecase_impl.dart';
import 'package:ondas_mobile/features/profile/presentation/bloc/history_bloc.dart';
import 'package:ondas_mobile/features/profile/presentation/bloc/profile_bloc.dart';

final sl = GetIt.instance;

Future<void> setupDependencies() async {
  // ── Storage ──────────────────────────────────────────────────────────────
  sl.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
    ),
  );
  sl.registerLazySingleton<SecureStorage>(
    () => SecureStorage(sl<FlutterSecureStorage>()),
  );

  // ── Network ───────────────────────────────────────────────────────────────
  sl.registerLazySingleton<JwtInterceptor>(
    () => JwtInterceptor(sl<SecureStorage>()),
  );
  sl.registerLazySingleton<DioClient>(
    () => DioClient(sl<JwtInterceptor>()),
  );

  // ── Repositories ─────────────────────────────────────────────────────────
  sl.registerLazySingleton<AuthRemoteDatasource>(
    () => AuthRemoteDatasourceImpl(sl<DioClient>()),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl<AuthRemoteDatasource>(), sl<SecureStorage>()),
  );

  // ── Use Cases ─────────────────────────────────────────────────────────────
  sl.registerLazySingleton<LoginUseCase>(
    () => LoginUseCaseImpl(sl<AuthRepository>()),
  );
  sl.registerLazySingleton<RegisterUseCase>(
    () => RegisterUseCaseImpl(sl<AuthRepository>()),
  );
  sl.registerLazySingleton<ForgotPasswordUseCase>(
    () => ForgotPasswordUseCaseImpl(sl<AuthRepository>()),
  );
  sl.registerLazySingleton<ResetPasswordUseCase>(
    () => ResetPasswordUseCaseImpl(sl<AuthRepository>()),
  );

  // ── BLoCs ─────────────────────────────────────────────────────────────────
  sl.registerFactory<AuthBloc>(
    () => AuthBloc(
      loginUseCase: sl<LoginUseCase>(),
      registerUseCase: sl<RegisterUseCase>(),
    ),
  );
  sl.registerFactory<ForgotPasswordBloc>(
    () => ForgotPasswordBloc(forgotPasswordUseCase: sl<ForgotPasswordUseCase>()),
  );
  sl.registerFactory<ResetPasswordBloc>(
    () => ResetPasswordBloc(resetPasswordUseCase: sl<ResetPasswordUseCase>()),
  );

  // ── Profile ───────────────────────────────────────────────────────────────
  sl.registerLazySingleton<ProfileRemoteDatasource>(
    () => ProfileRemoteDatasourceImpl(sl<DioClient>()),
  );
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(sl<ProfileRemoteDatasource>()),
  );
  sl.registerLazySingleton<GetProfileUseCase>(
    () => GetProfileUseCaseImpl(sl<ProfileRepository>()),
  );
  sl.registerLazySingleton<UpdateProfileUseCase>(
    () => UpdateProfileUseCaseImpl(sl<ProfileRepository>()),
  );
  sl.registerLazySingleton<UploadAvatarUseCase>(
    () => UploadAvatarUseCaseImpl(sl<ProfileRepository>()),
  );
  sl.registerLazySingleton<ChangePasswordUseCase>(
    () => ChangePasswordUseCaseImpl(sl<ProfileRepository>()),
  );
  sl.registerLazySingleton<LogoutUseCase>(
    () => LogoutUseCaseImpl(sl<AuthRepository>()),
  );
  sl.registerFactory<ProfileBloc>(
    () => ProfileBloc(
      getProfileUseCase: sl<GetProfileUseCase>(),
      updateProfileUseCase: sl<UpdateProfileUseCase>(),
      uploadAvatarUseCase: sl<UploadAvatarUseCase>(),
      changePasswordUseCase: sl<ChangePasswordUseCase>(),
      logoutUseCase: sl<LogoutUseCase>(),
    ),
  );
  sl.registerLazySingleton<GetPlayHistoryUseCase>(
    () => GetPlayHistoryUseCaseImpl(sl<ProfileRepository>()),
  );
  sl.registerLazySingleton<DeletePlayHistoryItemUseCase>(
    () => DeletePlayHistoryItemUseCaseImpl(sl<ProfileRepository>()),
  );
  sl.registerLazySingleton<ClearPlayHistoryUseCase>(
    () => ClearPlayHistoryUseCaseImpl(sl<ProfileRepository>()),
  );
  sl.registerFactory<HistoryBloc>(
    () => HistoryBloc(
      getPlayHistoryUseCase: sl<GetPlayHistoryUseCase>(),
      deletePlayHistoryItemUseCase: sl<DeletePlayHistoryItemUseCase>(),
      clearPlayHistoryUseCase: sl<ClearPlayHistoryUseCase>(),
    ),
  );

  // ── Home ──────────────────────────────────────────────────────────────────
  sl.registerLazySingleton<HomeRemoteDatasource>(
    () => HomeRemoteDatasourceImpl(sl<DioClient>()),
  );
  sl.registerLazySingleton<HomeRepository>(
    () => HomeRepositoryImpl(sl<HomeRemoteDatasource>()),
  );
  sl.registerLazySingleton<GetHomeDataUseCase>(
    () => GetHomeDataUseCaseImpl(sl<HomeRepository>()),
  );
  sl.registerFactory<HomeBloc>(
    () => HomeBloc(getHomeDataUseCase: sl<GetHomeDataUseCase>()),
  );

  // ── Player ────────────────────────────────────────────────────────────────
  sl.registerLazySingleton<AudioPlayerService>(
    () => AudioPlayerServiceImpl(),
  );
  sl.registerLazySingleton<PlaySongUseCase>(
    () => PlaySongUseCaseImpl(sl<AudioPlayerService>()),
  );
  sl.registerLazySingleton<PauseUseCase>(
    () => PauseUseCaseImpl(sl<AudioPlayerService>()),
  );
  sl.registerLazySingleton<ResumeUseCase>(
    () => ResumeUseCaseImpl(sl<AudioPlayerService>()),
  );
  sl.registerLazySingleton<SeekUseCase>(
    () => SeekUseCaseImpl(sl<AudioPlayerService>()),
  );
  sl.registerLazySingleton<SkipNextUseCase>(
    () => SkipNextUseCaseImpl(sl<AudioPlayerService>()),
  );
  sl.registerLazySingleton<SkipPreviousUseCase>(
    () => SkipPreviousUseCaseImpl(sl<AudioPlayerService>()),
  );
  sl.registerLazySingleton<SetVolumeUseCase>(
    () => SetVolumeUseCaseImpl(sl<AudioPlayerService>()),
  );
  sl.registerLazySingleton<SetRepeatModeUseCase>(
    () => SetRepeatModeUseCaseImpl(sl<AudioPlayerService>()),
  );
  sl.registerLazySingleton<PlayHistoryRemoteDatasource>(
    () => PlayHistoryRemoteDatasourceImpl(sl<DioClient>()),
  );
  sl.registerLazySingleton<PlayHistoryRepository>(
    () => PlayHistoryRepositoryImpl(sl<PlayHistoryRemoteDatasource>()),
  );
  sl.registerLazySingleton<RecordPlayHistoryUseCase>(
    () => RecordPlayHistoryUseCaseImpl(sl<PlayHistoryRepository>()),
  );
  sl.registerLazySingleton<PlayerBloc>(
    () => PlayerBloc(
      playSongUseCase: sl<PlaySongUseCase>(),
      pauseUseCase: sl<PauseUseCase>(),
      resumeUseCase: sl<ResumeUseCase>(),
      seekUseCase: sl<SeekUseCase>(),
      skipNextUseCase: sl<SkipNextUseCase>(),
      skipPreviousUseCase: sl<SkipPreviousUseCase>(),
      setVolumeUseCase: sl<SetVolumeUseCase>(),
      setRepeatModeUseCase: sl<SetRepeatModeUseCase>(),
      audioPlayerService: sl<AudioPlayerService>(),
      recordPlayHistoryUseCase: sl<RecordPlayHistoryUseCase>(),
    ),
  );

  // ── Playlist ──────────────────────────────────────────────────────────────
  sl.registerLazySingleton<PlaylistRemoteDatasource>(
    () => PlaylistRemoteDatasourceImpl(sl<DioClient>()),
  );
  sl.registerLazySingleton<PlaylistRepository>(
    () => PlaylistRepositoryImpl(sl<PlaylistRemoteDatasource>()),
  );
  sl.registerLazySingleton<GetMyPlaylistsUseCase>(
    () => GetMyPlaylistsUseCaseImpl(sl<PlaylistRepository>()),
  );
  sl.registerLazySingleton<AddSongToPlaylistUseCase>(
    () => AddSongToPlaylistUseCaseImpl(sl<PlaylistRepository>()),
  );
  sl.registerLazySingleton<RemoveSongFromPlaylistUseCase>(
    () => RemoveSongFromPlaylistUseCaseImpl(sl<PlaylistRepository>()),
  );
  sl.registerLazySingleton<CreatePlaylistUseCase>(
    () => CreatePlaylistUseCaseImpl(sl<PlaylistRepository>()),
  );
  sl.registerFactory<SaveToPlaylistBloc>(
    () => SaveToPlaylistBloc(
      getMyPlaylistsUseCase: sl<GetMyPlaylistsUseCase>(),
      addSongToPlaylistUseCase: sl<AddSongToPlaylistUseCase>(),
      removeSongFromPlaylistUseCase: sl<RemoveSongFromPlaylistUseCase>(),
      createPlaylistUseCase: sl<CreatePlaylistUseCase>(),
    ),
  );

  // ── Library ───────────────────────────────────────────────────────────────
  sl.registerLazySingleton<GetLibraryPlaylistsUseCase>(
    () => GetLibraryPlaylistsUseCaseImpl(sl<PlaylistRepository>()),
  );
  sl.registerLazySingleton<GetPlaylistDetailUseCase>(
    () => GetPlaylistDetailUseCaseImpl(sl<PlaylistRepository>()),
  );
  sl.registerLazySingleton<UpdatePlaylistUseCase>(
    () => UpdatePlaylistUseCaseImpl(sl<PlaylistRepository>()),
  );
  sl.registerLazySingleton<DeletePlaylistUseCase>(
    () => DeletePlaylistUseCaseImpl(sl<PlaylistRepository>()),
  );
  sl.registerLazySingleton<ReorderPlaylistSongsUseCase>(
    () => ReorderPlaylistSongsUseCaseImpl(sl<PlaylistRepository>()),
  );
  sl.registerFactory<LibraryBloc>(
    () => LibraryBloc(
      getLibraryPlaylistsUseCase: sl<GetLibraryPlaylistsUseCase>(),
      createPlaylistUseCase: sl<CreatePlaylistUseCase>(),
      deletePlaylistUseCase: sl<DeletePlaylistUseCase>(),
    ),
  );
  sl.registerFactory<PlaylistDetailBloc>(
    () => PlaylistDetailBloc(
      getPlaylistDetailUseCase: sl<GetPlaylistDetailUseCase>(),
      removeSongFromPlaylistUseCase: sl<RemoveSongFromPlaylistUseCase>(),
      reorderPlaylistSongsUseCase: sl<ReorderPlaylistSongsUseCase>(),
      updatePlaylistUseCase: sl<UpdatePlaylistUseCase>(),
    ),
  );

  // ── Search ────────────────────────────────────────────────────────────────
  sl.registerLazySingleton<SearchRemoteDatasource>(
    () => SearchRemoteDatasourceImpl(sl<DioClient>()),
  );
  sl.registerLazySingleton<SearchRepository>(
    () => SearchRepositoryImpl(sl<SearchRemoteDatasource>()),
  );
  sl.registerLazySingleton<SearchUseCase>(
    () => SearchUseCaseImpl(sl<SearchRepository>()),
  );
  sl.registerLazySingleton<GetSearchSuggestionsUseCase>(
    () => GetSearchSuggestionsUseCaseImpl(sl<SearchRepository>()),
  );
  sl.registerLazySingleton<ClearSearchHistoryUseCase>(
    () => ClearSearchHistoryUseCaseImpl(sl<SearchRepository>()),
  );
  sl.registerFactory<SearchBloc>(
    () => SearchBloc(
      searchUseCase: sl<SearchUseCase>(),
      getSuggestionsUseCase: sl<GetSearchSuggestionsUseCase>(),
      clearHistoryUseCase: sl<ClearSearchHistoryUseCase>(),
    ),
  );

  // ── Favorites ─────────────────────────────────────────────────────────────
  sl.registerLazySingleton<FavoritesRemoteDatasource>(
    () => FavoritesRemoteDatasourceImpl(sl<DioClient>()),
  );
  sl.registerLazySingleton<FavoritesRepository>(
    () => FavoritesRepositoryImpl(sl<FavoritesRemoteDatasource>()),
  );
  sl.registerLazySingleton<AddFavoriteUseCase>(
    () => AddFavoriteUseCaseImpl(sl<FavoritesRepository>()),
  );
  sl.registerLazySingleton<RemoveFavoriteUseCase>(
    () => RemoveFavoriteUseCaseImpl(sl<FavoritesRepository>()),
  );
  sl.registerLazySingleton<CheckFavoriteStatusUseCase>(
    () => CheckFavoriteStatusUseCaseImpl(sl<FavoritesRepository>()),
  );
  sl.registerLazySingleton<GetFavoritesUseCase>(
    () => GetFavoritesUseCaseImpl(sl<FavoritesRepository>()),
  );
  sl.registerFactory<FavoritesBloc>(
    () => FavoritesBloc(
      getFavoritesUseCase: sl<GetFavoritesUseCase>(),
      removeFavoriteUseCase: sl<RemoveFavoriteUseCase>(),
    ),
  );
  sl.registerFactory<FavoriteToggleBloc>(
    () => FavoriteToggleBloc(
      checkFavoriteStatusUseCase: sl<CheckFavoriteStatusUseCase>(),
      addFavoriteUseCase: sl<AddFavoriteUseCase>(),
      removeFavoriteUseCase: sl<RemoveFavoriteUseCase>(),
    ),
  );

  // ── Songs ─────────────────────────────────────────────────────────────────
  sl.registerLazySingleton<SongsRemoteDatasource>(
    () => SongsRemoteDatasourceImpl(sl<DioClient>()),
  );
  sl.registerLazySingleton<SongsRepository>(
    () => SongsRepositoryImpl(sl<SongsRemoteDatasource>()),
  );
  sl.registerLazySingleton<GetSongsUseCase>(
    () => GetSongsUseCaseImpl(sl<SongsRepository>()),
  );
  sl.registerFactory<SongListBloc>(
    () => SongListBloc(getSongsUseCase: sl<GetSongsUseCase>()),
  );
}
