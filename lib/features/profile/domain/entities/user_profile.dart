import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  final String id;
  final String email;
  final String displayName;
  final String? avatarUrl;
  final String role;
  final DateTime? lastLoginAt;
  final DateTime? createdAt;

  const UserProfile({
    required this.id,
    required this.email,
    required this.displayName,
    this.avatarUrl,
    required this.role,
    this.lastLoginAt,
    this.createdAt,
  });

  @override
  List<Object?> get props => [id, email, displayName, avatarUrl, role, lastLoginAt, createdAt];
}
