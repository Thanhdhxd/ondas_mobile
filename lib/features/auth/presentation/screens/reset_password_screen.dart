import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ondas_mobile/core/theme/app_colors.dart';
import 'package:ondas_mobile/core/theme/app_spacing.dart';
import 'package:ondas_mobile/features/auth/presentation/bloc/reset_password_bloc.dart';
import 'package:ondas_mobile/features/auth/presentation/bloc/reset_password_event.dart';
import 'package:ondas_mobile/features/auth/presentation/bloc/reset_password_state.dart';
import 'package:ondas_mobile/features/auth/presentation/widgets/auth_text_field_widget.dart';
import 'package:ondas_mobile/features/auth/presentation/widgets/ondas_logo_widget.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;

  const ResetPasswordScreen({super.key, required this.email});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _otpController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<ResetPasswordBloc>().add(
            ResetPasswordSubmitted(
              email: widget.email,
              otp: _otpController.text.trim(),
              newPassword: _newPasswordController.text,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ResetPasswordBloc, ResetPasswordState>(
      listener: (context, state) {
        if (state is ResetPasswordSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đặt lại mật khẩu thành công. Vui lòng đăng nhập.'),
              backgroundColor: AppColors.spotifyGreen,
            ),
          );
          context.go('/login');
        } else if (state is ResetPasswordFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.negativeRed,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
        ),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const OndasLogoWidget(subtitle: 'Đặt lại mật khẩu'),
                    const SizedBox(height: AppSpacing.xl),
                    _ResetPasswordDescription(email: widget.email),
                    const SizedBox(height: AppSpacing.xxl),
                    _ResetPasswordForm(
                      formKey: _formKey,
                      otpController: _otpController,
                      newPasswordController: _newPasswordController,
                      confirmPasswordController: _confirmPasswordController,
                      onSubmit: _submit,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ResetPasswordDescription extends StatelessWidget {
  final String email;

  const _ResetPasswordDescription({required this.email});

  @override
  Widget build(BuildContext context) {
    return Text(
      'Nhập mã OTP đã được gửi đến $email và đặt mật khẩu mới.',
      style: const TextStyle(color: AppColors.silver, fontSize: 14, height: 1.5),
      textAlign: TextAlign.center,
    );
  }
}

class _ResetPasswordForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController otpController;
  final TextEditingController newPasswordController;
  final TextEditingController confirmPasswordController;
  final VoidCallback onSubmit;

  const _ResetPasswordForm({
    required this.formKey,
    required this.otpController,
    required this.newPasswordController,
    required this.confirmPasswordController,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AuthTextFieldWidget(
            fieldKey: const Key('resetPasswordScreen_otpField'),
            label: 'Mã OTP',
            hint: '123456',
            controller: otpController,
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Vui lòng nhập mã OTP';
              }
              if (!RegExp(r'^\d{6}$').hasMatch(value.trim())) {
                return 'Mã OTP phải gồm 6 chữ số';
              }
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.base),
          AuthTextFieldWidget(
            fieldKey: const Key('resetPasswordScreen_newPasswordField'),
            label: 'Mật khẩu mới',
            hint: '••••••••',
            controller: newPasswordController,
            obscure: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Vui lòng nhập mật khẩu mới';
              }
              if (value.length < 8) {
                return 'Mật khẩu phải có ít nhất 8 ký tự';
              }
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.base),
          AuthTextFieldWidget(
            fieldKey: const Key('resetPasswordScreen_confirmPasswordField'),
            label: 'Xác nhận mật khẩu',
            hint: '••••••••',
            controller: confirmPasswordController,
            obscure: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Vui lòng xác nhận mật khẩu';
              }
              if (value != newPasswordController.text) {
                return 'Mật khẩu không khớp';
              }
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.xl),
          BlocBuilder<ResetPasswordBloc, ResetPasswordState>(
            builder: (context, state) {
              final isLoading = state is ResetPasswordLoading;
              return ElevatedButton(
                key: const Key('resetPasswordScreen_submitButton'),
                onPressed: isLoading ? null : onSubmit,
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.black,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('ĐẶT LẠI MẬT KHẨU'),
              );
            },
          ),
        ],
      ),
    );
  }
}
