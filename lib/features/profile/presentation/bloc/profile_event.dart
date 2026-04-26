import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class ProfileLoadRequested extends ProfileEvent {
  const ProfileLoadRequested();
}

class ProfileUpdateRequested extends ProfileEvent {
  final String displayName;

  const ProfileUpdateRequested({required this.displayName});

  @override
  List<Object?> get props => [displayName];
}

class ProfileAvatarUploadRequested extends ProfileEvent {
  final String filePath;

  const ProfileAvatarUploadRequested({required this.filePath});

  @override
  List<Object?> get props => [filePath];
}

class ProfileChangePasswordRequested extends ProfileEvent {
  final String currentPassword;
  final String newPassword;

  const ProfileChangePasswordRequested({
    required this.currentPassword,
    required this.newPassword,
  });

  @override
  List<Object?> get props => [currentPassword, newPassword];
}

class ProfileLogoutRequested extends ProfileEvent {
  const ProfileLogoutRequested();
}
