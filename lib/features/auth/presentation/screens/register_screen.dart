import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ondas_mobile/core/theme/app_colors.dart';
import 'package:ondas_mobile/core/theme/app_spacing.dart';
import 'package:ondas_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ondas_mobile/features/auth/presentation/bloc/auth_event.dart';
import 'package:ondas_mobile/features/auth/presentation/bloc/auth_state.dart';
import 'package:ondas_mobile/features/auth/presentation/widgets/auth_text_field_widget.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
            RegisterSubmitted(
              fullName: _fullNameController.text.trim(),
              email: _emailController.text.trim(),
              password: _passwordController.text,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          context.go('/home');
        } else if (state is AuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.negativeRed,
            ),
          );
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppSpacing.xxxl),
                _RegisterHeader(),
                const SizedBox(height: AppSpacing.xxl),
                _RegisterForm(
                  formKey: _formKey,
                  fullNameController: _fullNameController,
                  emailController: _emailController,
                  passwordController: _passwordController,
                  confirmPasswordController: _confirmPasswordController,
                  onSubmit: _submit,
                ),
                const SizedBox(height: AppSpacing.xl),
                _RegisterFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RegisterHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Icon(
          Icons.music_note_rounded,
          size: 64,
          color: AppColors.spotifyGreen,
        ),
        const SizedBox(height: AppSpacing.base),
        Text(
          'Tạo tài khoản Ondas',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.w700,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Miễn phí. Không giới hạn.',
          style: TextStyle(color: AppColors.silver),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _RegisterForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController fullNameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final VoidCallback onSubmit;

  const _RegisterForm({
    required this.formKey,
    required this.fullNameController,
    required this.emailController,
    required this.passwordController,
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
            fieldKey: const Key('registerScreen_fullNameField'),
            label: 'Họ và tên',
            hint: 'Nguyễn Văn A',
            controller: fullNameController,
            keyboardType: TextInputType.name,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Vui lòng nhập họ và tên';
              }
              if (value.trim().length < 2) {
                return 'Họ và tên phải có ít nhất 2 ký tự';
              }
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.base),
          AuthTextFieldWidget(
            fieldKey: const Key('registerScreen_emailField'),
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
          const SizedBox(height: AppSpacing.base),
          AuthTextFieldWidget(
            fieldKey: const Key('registerScreen_passwordField'),
            label: 'Mật khẩu',
            hint: '••••••••',
            controller: passwordController,
            obscure: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Vui lòng nhập mật khẩu';
              }
              if (value.length < 6) {
                return 'Mật khẩu phải có ít nhất 6 ký tự';
              }
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.base),
          AuthTextFieldWidget(
            fieldKey: const Key('registerScreen_confirmPasswordField'),
            label: 'Xác nhận mật khẩu',
            hint: '••••••••',
            controller: confirmPasswordController,
            obscure: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Vui lòng xác nhận mật khẩu';
              }
              if (value != passwordController.text) {
                return 'Mật khẩu không khớp';
              }
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.xl),
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              final isLoading = state is AuthLoading;
              return ElevatedButton(
                key: const Key('registerScreen_submitButton'),
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
                    : const Text('TẠO TÀI KHOẢN'),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _RegisterFooter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Đã có tài khoản?',
          style: TextStyle(color: AppColors.silver),
        ),
        TextButton(
          key: const Key('registerScreen_goToLoginButton'),
          onPressed: () => context.pop(),
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
