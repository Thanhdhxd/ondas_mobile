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
}
