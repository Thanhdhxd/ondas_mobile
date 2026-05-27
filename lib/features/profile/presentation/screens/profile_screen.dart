import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ondas_mobile/core/localization/language_cubit.dart';
import 'package:ondas_mobile/core/localization/str_enum.dart';
import 'package:ondas_mobile/core/localization/translations.dart';
import 'package:ondas_mobile/core/theme/app_colors.dart';
import 'package:ondas_mobile/core/theme/app_spacing.dart';
import 'package:ondas_mobile/core/widgets/reconnect_listener.dart';
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
            SnackBar(content: Text(t(Str.profileUpdateSuccess, lang(context)))),
          );
          context.read<ProfileBloc>().add(const ProfileLoadRequested());
        } else if (state is ProfileAvatarUploadSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(t(Str.profileAvatarSuccess, lang(context)))),
          );
          context.read<ProfileBloc>().add(const ProfileLoadRequested());
        } else if (state is ProfilePasswordChangeSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(t(Str.profilePasswordSuccess, lang(context)))),
          );
          context.read<ProfileBloc>().add(const ProfileLoadRequested());
        } else if (state is ProfileFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        final l = context.watch<LanguageCubit>().state;
        return ReconnectListener(
          shouldReconnect: () =>
              context.read<ProfileBloc>().state is ProfileFailure,
          onReconnect: () =>
              context.read<ProfileBloc>().add(const ProfileLoadRequested()),
          child: Scaffold(
            appBar: AppBar(
              title: Text(t(Str.profileTitle, l)),
              backgroundColor: AppColors.nearBlack,
            ),
            body: switch (state) {
              ProfileLoading() => const _LoadingView(),
              ProfileLoaded(:final userProfile) =>
                _ContentView(userProfile: userProfile, langCode: l),
              ProfileUpdateSuccess(:final userProfile) =>
                _ContentView(userProfile: userProfile, langCode: l),
              ProfileAvatarUploadSuccess(:final userProfile) =>
                _ContentView(userProfile: userProfile, langCode: l),
              ProfileFailure(:final message) => _ErrorView(
                message: message,
                langCode: l,
                onRetry: () => context
                    .read<ProfileBloc>()
                    .add(const ProfileLoadRequested()),
              ),
              _ => const _LoadingView(),
            },
          ),
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
  final String langCode;
  final VoidCallback onRetry;

  const _ErrorView({
    required this.message,
    required this.langCode,
    required this.onRetry,
  });

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
            child: Text(t(Str.retry, langCode)),
          ),
        ],
      ),
    );
  }
}

class _ContentView extends StatelessWidget {
  final UserProfile userProfile;
  final String langCode;

  const _ContentView({required this.userProfile, required this.langCode});

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
        title: Text(
          t(Str.profileLogoutTitle, langCode),
          style: const TextStyle(color: AppColors.white),
        ),
        content: Text(
          t(Str.profileLogoutConfirm, langCode),
          style: const TextStyle(color: AppColors.silver),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(
              t(Str.cancel, langCode),
              style: const TextStyle(color: AppColors.silver),
            ),
          ),
          ElevatedButton(
            key: const Key('logoutConfirmDialog_confirmButton'),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.negativeRed),
            onPressed: () {
              Navigator.of(dialogContext).pop();
              bloc.add(const ProfileLogoutRequested());
            },
            child: Text(t(Str.profileLogoutButton, langCode)),
          ),
        ],
      ),
    );
  }

  void _showLanguageSheet(BuildContext context, String currentLang) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.darkSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        final textTheme = Theme.of(sheetContext).textTheme;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: AppSpacing.sm),
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.midDark,
                    borderRadius: BorderRadius.circular(9999),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  t(Str.profileLanguage, currentLang),
                  style: textTheme.titleMedium?.copyWith(color: AppColors.white),
                ),
                const SizedBox(height: AppSpacing.sm),
                _LanguageOptionTile(
                  key: const Key('profileLanguageSheet_vi'),
                  label: t(Str.languageVietnamese, currentLang),
                  selected: currentLang == 'vi',
                  onTap: () {
                    sheetContext.read<LanguageCubit>().setLanguage('vi');
                    Navigator.of(sheetContext).pop();
                  },
                ),
                _LanguageOptionTile(
                  key: const Key('profileLanguageSheet_en'),
                  label: t(Str.languageEnglish, currentLang),
                  selected: currentLang == 'en',
                  onTap: () {
                    sheetContext.read<LanguageCubit>().setLanguage('en');
                    Navigator.of(sheetContext).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<ProfileBloc>();
    final l = langCode;
    final textTheme = Theme.of(context).textTheme;
    final languageName = l == 'vi'
        ? t(Str.languageVietnamese, l)
        : t(Str.languageEnglish, l);

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
          _SectionDivider(title: t(Str.profileSectionAccount, l)),
          ProfileMenuItemWidget(
            key: const Key('profileScreen_editButton'),
            icon: Icons.edit_outlined,
            label: t(Str.profileEditButton, l),
            onTap: () => _showEditProfileDialog(context, bloc),
          ),
          ProfileMenuItemWidget(
            key: const Key('profileScreen_changePasswordButton'),
            icon: Icons.lock_outline,
            label: t(Str.profileChangePassword, l),
            onTap: () => _showChangePasswordDialog(context, bloc),
          ),
          ProfileMenuItemWidget(
            key: const Key('profileScreen_languageButton'),
            icon: Icons.language,
            label: t(Str.profileLanguage, l),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  languageName,
                  style: textTheme.bodyMedium?.copyWith(color: AppColors.silver),
                ),
                const SizedBox(width: AppSpacing.xs),
                const Icon(Icons.expand_more, color: AppColors.silver),
              ],
            ),
            showChevron: false,
            onTap: () => _showLanguageSheet(context, l),
          ),
          const SizedBox(height: AppSpacing.md),
          _SectionDivider(title: t(Str.profileSectionActivity, l)),
          ProfileMenuItemWidget(
            key: const Key('profileScreen_historyButton'),
            icon: Icons.history,
            label: t(Str.profileListeningHistory, l),
            onTap: () => context.push('/history'),
          ),
          const SizedBox(height: AppSpacing.md),
          _SectionDivider(title: t(Str.profileSectionSession, l)),
          ProfileMenuItemWidget(
            key: const Key('profileScreen_logoutButton'),
            icon: Icons.logout,
            label: t(Str.profileLogout, l),
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

class _LanguageOptionTile extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _LanguageOptionTile({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return ListTile(
      onTap: onTap,
      leading: Icon(
        selected ? Icons.check_circle : Icons.radio_button_unchecked,
        color: selected ? AppColors.announcementBlue : AppColors.silver,
      ),
      title: Text(
        label,
        style: textTheme.bodyLarge?.copyWith(color: AppColors.white),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
    );
  }
}
