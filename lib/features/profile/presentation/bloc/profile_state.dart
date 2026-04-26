import 'package:equatable/equatable.dart';
import 'package:ondas_mobile/features/profile/domain/entities/user_profile.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

class ProfileLoaded extends ProfileState {
  final UserProfile userProfile;

  const ProfileLoaded(this.userProfile);

  @override
  List<Object?> get props => [userProfile];
}

class ProfileUpdateSuccess extends ProfileState {
  final UserProfile userProfile;

  const ProfileUpdateSuccess(this.userProfile);

  @override
  List<Object?> get props => [userProfile];
}

class ProfileAvatarUploadSuccess extends ProfileState {
  final UserProfile userProfile;

  const ProfileAvatarUploadSuccess(this.userProfile);

  @override
  List<Object?> get props => [userProfile];
}

class ProfilePasswordChangeSuccess extends ProfileState {
  const ProfilePasswordChangeSuccess();
}

class ProfileLogoutSuccess extends ProfileState {
  const ProfileLogoutSuccess();
}

class ProfileFailure extends ProfileState {
  final String message;

  const ProfileFailure(this.message);

  @override
  List<Object?> get props => [message];
}
