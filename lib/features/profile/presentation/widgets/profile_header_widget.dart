import 'package:flutter/material.dart';
import 'package:ondas_mobile/core/theme/app_colors.dart';
import 'package:ondas_mobile/core/theme/app_spacing.dart';
import 'package:ondas_mobile/features/profile/domain/entities/user_profile.dart';

class ProfileHeaderWidget extends StatelessWidget {
  final UserProfile userProfile;
  final VoidCallback? onAvatarTap;

  const ProfileHeaderWidget({
    super.key,
    required this.userProfile,
    this.onAvatarTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        GestureDetector(
          key: const Key('profileScreen_avatarPicker'),
          onTap: onAvatarTap,
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 48,
                backgroundColor: AppColors.midDark,
                child: userProfile.avatarUrl != null
                    ? ClipOval(
                        child: Image.network(
                          userProfile.avatarUrl!,
                          width: 96,
                          height: 96,
                          fit: BoxFit.cover,
                          loadingBuilder: (_, child, progress) {
                            if (progress == null) return child;
                            return const CircularProgressIndicator(strokeWidth: 2);
                          },
                          errorBuilder: (_, error, _) {
                            debugPrint('[Avatar] Failed to load: ${userProfile.avatarUrl} — $error');
                            return const Icon(Icons.person, size: 48, color: AppColors.silver);
                          },
                        ),
                      )
                    : const Icon(Icons.person, size: 48, color: AppColors.silver),
              ),
              if (onAvatarTap != null)
                CircleAvatar(
                  radius: 15,
                  backgroundColor: AppColors.announcementBlue,
                  child: const Icon(Icons.camera_alt, size: 16, color: AppColors.white),
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.base),
        Text(
          userProfile.displayName,
          style: textTheme.titleLarge?.copyWith(
            color: AppColors.white,
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          userProfile.email,
          style: textTheme.bodyMedium?.copyWith(color: AppColors.silver),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xs),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xxs,
          ),
          decoration: BoxDecoration(
            color: AppColors.midDark,
            borderRadius: BorderRadius.circular(9999),
          ),
          child: Text(
            userProfile.role,
            style: textTheme.labelSmall?.copyWith(color: AppColors.silver),
          ),
        ),
      ],
    );
  }
}
