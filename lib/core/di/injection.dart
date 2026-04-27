import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:ondas_mobile/core/network/dio_client.dart';
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
import 'package:ondas_mobile/features/player/data/services/audio_player_service_impl.dart';
import 'package:ondas_mobile/features/player/domain/services/audio_player_service.dart';
import 'package:ondas_mobile/features/player/domain/usecases/pause_usecase.dart';
import 'package:ondas_mobile/features/player/domain/usecases/pause_usecase_impl.dart';
import 'package:ondas_mobile/features/player/domain/usecases/play_song_usecase.dart';
import 'package:ondas_mobile/features/player/domain/usecases/play_song_usecase_impl.dart';
import 'package:ondas_mobile/features/player/domain/usecases/resume_usecase.dart';
import 'package:ondas_mobile/features/player/domain/usecases/resume_usecase_impl.dart';
import 'package:ondas_mobile/features/player/domain/usecases/seek_usecase.dart';
import 'package:ondas_mobile/features/player/domain/usecases/seek_usecase_impl.dart';
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
  sl.registerLazySingleton<PlayerBloc>(
    () => PlayerBloc(
      playSongUseCase: sl<PlaySongUseCase>(),
      pauseUseCase: sl<PauseUseCase>(),
      resumeUseCase: sl<ResumeUseCase>(),
      seekUseCase: sl<SeekUseCase>(),
      skipNextUseCase: sl<SkipNextUseCase>(),
      skipPreviousUseCase: sl<SkipPreviousUseCase>(),
      setVolumeUseCase: sl<SetVolumeUseCase>(),
      audioPlayerService: sl<AudioPlayerService>(),
    ),
  );
}
