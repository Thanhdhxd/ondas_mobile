import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ondas_mobile/core/localization/str_enum.dart';
import 'package:ondas_mobile/core/localization/translations.dart';
import 'package:ondas_mobile/core/theme/app_colors.dart';
import 'package:ondas_mobile/core/theme/app_spacing.dart';
import 'package:ondas_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ondas_mobile/features/auth/presentation/bloc/auth_event.dart';
import 'package:ondas_mobile/features/auth/presentation/bloc/auth_state.dart';
import 'package:ondas_mobile/features/auth/presentation/widgets/auth_text_field_widget.dart';
import 'package:ondas_mobile/features/auth/presentation/widgets/ondas_logo_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
        LoginSubmitted(
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
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    OndasLogoWidget(subtitle: t(Str.loginSubtitle, lang(context))),
                    const SizedBox(height: AppSpacing.xxxl),
                    _LoginForm(
                      formKey: _formKey,
                      emailController: _emailController,
                      passwordController: _passwordController,
                      onSubmit: _submit,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    const _LoginFooter(),
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

class _LoginForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final VoidCallback onSubmit;

  const _LoginForm({
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final l = lang(context);
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AuthTextFieldWidget(
            fieldKey: const Key('loginScreen_emailField'),
            label: t(Str.loginEmail, l),
            hint: t(Str.loginEmailHint, l),
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return t(Str.loginEmailRequired, l);
              }
              if (!RegExp(
                r'^[\w-.]+@([\w-]+\.)+[\w-]{2,}$',
              ).hasMatch(value.trim())) {
                return t(Str.loginEmailInvalid, l);
              }
              if (value.trim().length < 6) {
                return t(Str.loginEmailTooShort, l);
              }
              if (value.length > 255) {
                return t(Str.loginEmailTooLong, l);
              }
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.base),
          AuthTextFieldWidget(
            fieldKey: const Key('loginScreen_passwordField'),
            label: t(Str.loginPassword, l),
            hint: '••••••••',
            controller: passwordController,
            obscure: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return t(Str.loginPasswordRequired, l);
              }
              if (value.length < 6) {
                return t(Str.loginPasswordTooShort, l);
              }
              if (value.length > 128) {
                return t(Str.loginPasswordTooLong, l);
              }
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.xs),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              key: const Key('loginScreen_forgotPasswordButton'),
              onPressed: () => context.push('/forgot-password'),
              child: Text(
                t(Str.loginForgotPassword, l),
                style: const TextStyle(color: AppColors.white),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.base),
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              final isLoading = state is AuthLoading;
              return ElevatedButton(
                key: const Key('loginScreen_submitButton'),
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
                    : Text(t(Str.loginButton, lang(context))),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _LoginFooter extends StatelessWidget {
  const _LoginFooter();

  @override
  Widget build(BuildContext context) {
    final l = lang(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(t(Str.loginNoAccount, l), style: TextStyle(color: AppColors.silver)),
        TextButton(
          key: const Key('loginScreen_goToRegisterButton'),
          onPressed: () => context.push('/register'),
          child: Text(
            t(Str.loginGoRegister, l),
            style: const TextStyle(
              color: AppColors.spotifyGreen,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
