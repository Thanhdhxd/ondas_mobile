import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ondas_mobile/features/auth/domain/usecases/logout_usecase.dart';
import 'package:ondas_mobile/features/profile/domain/usecases/change_password_usecase.dart';
import 'package:ondas_mobile/features/profile/domain/usecases/get_profile_usecase.dart';
import 'package:ondas_mobile/features/profile/domain/usecases/update_profile_usecase.dart';
import 'package:ondas_mobile/features/profile/domain/usecases/upload_avatar_usecase.dart';
import 'package:ondas_mobile/features/profile/presentation/bloc/profile_event.dart';
import 'package:ondas_mobile/features/profile/presentation/bloc/profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetProfileUseCase _getProfileUseCase;
  final UpdateProfileUseCase _updateProfileUseCase;
  final UploadAvatarUseCase _uploadAvatarUseCase;
  final ChangePasswordUseCase _changePasswordUseCase;
  final LogoutUseCase _logoutUseCase;

  ProfileBloc({
    required GetProfileUseCase getProfileUseCase,
    required UpdateProfileUseCase updateProfileUseCase,
    required UploadAvatarUseCase uploadAvatarUseCase,
    required ChangePasswordUseCase changePasswordUseCase,
    required LogoutUseCase logoutUseCase,
  })  : _getProfileUseCase = getProfileUseCase,
        _updateProfileUseCase = updateProfileUseCase,
        _uploadAvatarUseCase = uploadAvatarUseCase,
        _changePasswordUseCase = changePasswordUseCase,
        _logoutUseCase = logoutUseCase,
        super(const ProfileInitial()) {
    on<ProfileLoadRequested>(_onLoadRequested);
    on<ProfileUpdateRequested>(_onUpdateRequested);
    on<ProfileAvatarUploadRequested>(_onAvatarUploadRequested);
    on<ProfileChangePasswordRequested>(_onChangePasswordRequested);
    on<ProfileLogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onLoadRequested(
    ProfileLoadRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());
    final result = await _getProfileUseCase();
    result.fold(
      (failure) => emit(ProfileFailure(failure.message)),
      (profile) => emit(ProfileLoaded(profile)),
    );
  }

  Future<void> _onUpdateRequested(
    ProfileUpdateRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());
    final result = await _updateProfileUseCase(
      UpdateProfileParams(displayName: event.displayName),
    );
    result.fold(
      (failure) => emit(ProfileFailure(failure.message)),
      (profile) => emit(ProfileUpdateSuccess(profile)),
    );
  }

  Future<void> _onAvatarUploadRequested(
    ProfileAvatarUploadRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());
    final result = await _uploadAvatarUseCase(
      UploadAvatarParams(filePath: event.filePath),
    );
    result.fold(
      (failure) => emit(ProfileFailure(failure.message)),
      (profile) => emit(ProfileAvatarUploadSuccess(profile)),
    );
  }

  Future<void> _onChangePasswordRequested(
    ProfileChangePasswordRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());
    final result = await _changePasswordUseCase(
      ChangePasswordParams(
        currentPassword: event.currentPassword,
        newPassword: event.newPassword,
      ),
    );
    result.fold(
      (failure) => emit(ProfileFailure(failure.message)),
      (_) => emit(const ProfilePasswordChangeSuccess()),
    );
  }

  Future<void> _onLogoutRequested(
    ProfileLogoutRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());
    final result = await _logoutUseCase();
    result.fold(
      (failure) => emit(ProfileFailure(failure.message)),
      (_) => emit(const ProfileLogoutSuccess()),
    );
  }
}
