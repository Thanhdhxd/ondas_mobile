import 'package:ondas_mobile/core/constants/api_constants.dart';
import 'package:ondas_mobile/features/profile/domain/entities/user_profile.dart';

class UserProfileModel extends UserProfile {
  const UserProfileModel({
    required super.id,
    required super.email,
    required super.displayName,
    super.avatarUrl,
    required super.role,
    super.lastLoginAt,
    super.createdAt,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String,
      avatarUrl: _normalizeUrl(json['avatarUrl'] as String?),
      role: json['role'] as String,
      lastLoginAt: json['lastLoginAt'] != null
          ? DateTime.tryParse(json['lastLoginAt'] as String)
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
    );
  }

  /// Replaces localhost/127.0.0.1 in URLs returned by the server with the
  /// configured base URL host so images load correctly on physical devices.
  static String? _normalizeUrl(String? url) {
    if (url == null) return null;
    final host = Uri.parse(ApiConstants.baseUrl).host;
    return url
        .replaceAll('localhost', host)
        .replaceAll('127.0.0.1', host);
  }
}
