import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ondas_mobile/core/theme/app_colors.dart';
import 'package:ondas_mobile/core/theme/app_spacing.dart';
import 'package:ondas_mobile/features/auth/presentation/bloc/forgot_password_bloc.dart';
import 'package:ondas_mobile/features/auth/presentation/bloc/forgot_password_event.dart';
import 'package:ondas_mobile/features/auth/presentation/bloc/forgot_password_state.dart';
import 'package:ondas_mobile/features/auth/presentation/widgets/auth_text_field_widget.dart';
import 'package:ondas_mobile/features/auth/presentation/widgets/ondas_logo_widget.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<ForgotPasswordBloc>().add(
            ForgotPasswordSubmitted(email: _emailController.text.trim()),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ForgotPasswordBloc, ForgotPasswordState>(
      listener: (context, state) {
        if (state is ForgotPasswordSuccess) {
          context.go('/reset-password', extra: _emailController.text.trim());
        } else if (state is ForgotPasswordFailure) {
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
                    const OndasLogoWidget(subtitle: 'Quên mật khẩu'),
                    const SizedBox(height: AppSpacing.xl),
                    const _ForgotPasswordDescription(),
                    const SizedBox(height: AppSpacing.xxl),
                    _ForgotPasswordForm(
                      formKey: _formKey,
                      emailController: _emailController,
                      onSubmit: _submit,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    _ForgotPasswordFooter(),
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

class _ForgotPasswordDescription extends StatelessWidget {
  const _ForgotPasswordDescription();

  @override
  Widget build(BuildContext context) {
    return Text(
      'Nhập email đã đăng ký, chúng tôi sẽ gửi mã OTP để đặt lại mật khẩu.',
      style: TextStyle(color: AppColors.silver, fontSize: 14, height: 1.5),
      textAlign: TextAlign.center,
    );
  }
}

class _ForgotPasswordForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final VoidCallback onSubmit;

  const _ForgotPasswordForm({
    required this.formKey,
    required this.emailController,
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
            fieldKey: const Key('forgotPasswordScreen_emailField'),
            label: 'Email',
            hint: 'email@example.com',
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Vui lòng nhập email';
              }
              if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,}$')
                  .hasMatch(value.trim())) {
                return 'Email không hợp lệ';
              }
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.xl),
          BlocBuilder<ForgotPasswordBloc, ForgotPasswordState>(
            builder: (context, state) {
              final isLoading = state is ForgotPasswordLoading;
              return ElevatedButton(
                key: const Key('forgotPasswordScreen_submitButton'),
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
                    : const Text('GỬI MÃ OTP'),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ForgotPasswordFooter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Đã nhớ mật khẩu?',
          style: TextStyle(color: AppColors.silver),
        ),
        TextButton(
          key: const Key('forgotPasswordScreen_goToLoginButton'),
          onPressed: () => context.go('/login'),
          child: const Text(
            'Đăng nhập',
            style: TextStyle(
              color: AppColors.spotifyGreen,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
