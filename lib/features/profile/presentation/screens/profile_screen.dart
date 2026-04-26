import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ondas_mobile/core/theme/app_colors.dart';
import 'package:ondas_mobile/core/theme/app_spacing.dart';
import 'package:ondas_mobile/features/profile/domain/entities/user_profile.dart';
import 'package:ondas_mobile/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:ondas_mobile/features/profile/presentation/bloc/profile_event.dart';
import 'package:ondas_mobile/features/profile/presentation/bloc/profile_state.dart';
import 'package:ondas_mobile/features/profile/presentation/widgets/change_password_dialog_widget.dart';
import 'package:ondas_mobile/features/profile/presentation/widgets/edit_profile_dialog_widget.dart';
import 'package:ondas_mobile/features/profile/presentation/widgets/profile_header_widget.dart';
import 'package:ondas_mobile/features/profile/presentation/widgets/profile_menu_item_widget.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileLogoutSuccess) {
          context.go('/login');
        } else if (state is ProfileUpdateSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully')),
          );
          context.read<ProfileBloc>().add(const ProfileLoadRequested());
        } else if (state is ProfileAvatarUploadSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Avatar updated successfully')),
          );
          context.read<ProfileBloc>().add(const ProfileLoadRequested());
        } else if (state is ProfilePasswordChangeSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Password changed successfully')),
          );
          context.read<ProfileBloc>().add(const ProfileLoadRequested());
        } else if (state is ProfileFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Profile'),
            backgroundColor: AppColors.nearBlack,
          ),
          body: switch (state) {
            ProfileLoading() => const _LoadingView(),
            ProfileLoaded(:final userProfile) => _ContentView(userProfile: userProfile),
            ProfileUpdateSuccess(:final userProfile) => _ContentView(userProfile: userProfile),
            ProfileAvatarUploadSuccess(:final userProfile) => _ContentView(userProfile: userProfile),
            ProfileFailure(:final message) => _ErrorView(
                message: message,
                onRetry: () =>
                    context.read<ProfileBloc>().add(const ProfileLoadRequested()),
              ),
            _ => const _LoadingView(),
          },
        );
      },
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, style: const TextStyle(color: AppColors.negativeRed)),
          const SizedBox(height: AppSpacing.md),
          ElevatedButton(
            onPressed: onRetry,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

class _ContentView extends StatelessWidget {
  final UserProfile userProfile;

  const _ContentView({required this.userProfile});

  void _showEditProfileDialog(BuildContext context, ProfileBloc bloc) {
    showDialog<void>(
      context: context,
      builder: (_) => EditProfileDialogWidget(
        userProfile: userProfile,
        onSubmit: (displayName) {
          bloc.add(ProfileUpdateRequested(displayName: displayName));
        },
      ),
    );
  }

  Future<void> _pickAndUploadAvatar(BuildContext context, ProfileBloc bloc) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 512,
      maxHeight: 512,
    );
    if (image != null) {
      bloc.add(ProfileAvatarUploadRequested(filePath: image.path));
    }
  }

  void _showChangePasswordDialog(BuildContext context, ProfileBloc bloc) {
    showDialog<void>(
      context: context,
      builder: (_) => ChangePasswordDialogWidget(
        onSubmit: (currentPassword, newPassword) {
          bloc.add(
            ProfileChangePasswordRequested(
              currentPassword: currentPassword,
              newPassword: newPassword,
            ),
          );
        },
      ),
    );
  }

  void _confirmLogout(BuildContext context, ProfileBloc bloc) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.darkSurface,
        title: const Text('Log Out', style: TextStyle(color: AppColors.white)),
        content: const Text(
          'Are you sure you want to log out?',
          style: TextStyle(color: AppColors.silver),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel', style: TextStyle(color: AppColors.silver)),
          ),
          ElevatedButton(
            key: const Key('logoutConfirmDialog_confirmButton'),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.negativeRed),
            onPressed: () {
              Navigator.of(dialogContext).pop();
              bloc.add(const ProfileLogoutRequested());
            },
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<ProfileBloc>();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ProfileHeaderWidget(
            userProfile: userProfile,
            onAvatarTap: () => _pickAndUploadAvatar(context, bloc),
          ),
          const SizedBox(height: AppSpacing.xl),
          _SectionDivider(title: 'Account'),
          ProfileMenuItemWidget(
            key: const Key('profileScreen_editButton'),
            icon: Icons.edit_outlined,
            label: 'Edit Profile',
            onTap: () => _showEditProfileDialog(context, bloc),
          ),
          ProfileMenuItemWidget(
            key: const Key('profileScreen_changePasswordButton'),
            icon: Icons.lock_outline,
            label: 'Change Password',
            onTap: () => _showChangePasswordDialog(context, bloc),
          ),
          const SizedBox(height: AppSpacing.md),
          _SectionDivider(title: 'Session'),
          ProfileMenuItemWidget(
            key: const Key('profileScreen_logoutButton'),
            icon: Icons.logout,
            label: 'Log Out',
            iconColor: AppColors.negativeRed,
            labelColor: AppColors.negativeRed,
            onTap: () => _confirmLogout(context, bloc),
          ),
        ],
      ),
    );
  }
}

class _SectionDivider extends StatelessWidget {
  final String title;

  const _SectionDivider({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.base,
        vertical: AppSpacing.xs,
      ),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.silver,
              letterSpacing: 1.4,
            ),
      ),
    );
  }
}
