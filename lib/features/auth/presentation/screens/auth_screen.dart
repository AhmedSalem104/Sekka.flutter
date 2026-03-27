import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/extensions/string_extensions.dart';
import '../../../../core/widgets/sekka_message_dialog.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/sekka_button.dart';
import '../../../../core/widgets/sekka_input_field.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_form_bloc.dart';
import '../bloc/auth_form_event.dart';
import '../bloc/auth_form_state.dart';
import '../bloc/auth_state.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_tab_bar.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _signUpPhoneController = TextEditingController();

  bool _obscurePassword = true;
  String? _phoneError;
  String? _passwordError;
  String? _signUpPhoneError;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    _signUpPhoneController.dispose();
    super.dispose();
  }

  void _onLogin() {
    final phone = _phoneController.text.toEnglishNumbers.trim();
    final password = _passwordController.text;

    final phoneErr = Validators.phone(phone);
    final passErr = Validators.password(password);

    setState(() {
      _phoneError = phoneErr;
      _passwordError = passErr;
    });

    if (phoneErr != null || passErr != null) return;

    context.read<AuthBloc>().add(AuthLoginRequested(
          phoneNumber: phone,
          password: password,
        ));
  }

  void _onSendOtp() {
    final phone = _signUpPhoneController.text.toEnglishNumbers.trim();
    final phoneErr = Validators.phone(phone);

    setState(() => _signUpPhoneError = phoneErr);
    if (phoneErr != null) return;

    context.read<AuthFormBloc>().add(AuthFormSendOtp(phone));
  }

  void _onForgotPassword() {
    context.push(RouteNames.forgotPassword);
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthAuthenticated) {
              context.go(RouteNames.main);
            } else if (state is AuthUnauthenticated && state.message != null) {
              SekkaMessageDialog.show(context, message: state.message!);
            }
          },
        ),
        BlocListener<AuthFormBloc, AuthFormState>(
          listenWhen: (prev, curr) => prev.status != curr.status,
          listener: (context, state) {
            if (state.status == AuthFormStatus.success &&
                state.activeTab == 1) {
              // OTP sent successfully — navigate to OTP screen
              context.push(
                RouteNames.otp,
                extra: OtpScreenArgs(
                  phoneNumber: _signUpPhoneController.text.toEnglishNumbers.trim(),
                  purpose: OtpPurpose.register,
                ),
              );
            } else if (state.status == AuthFormStatus.failure &&
                state.errorMessage != null) {
              SekkaMessageDialog.show(context, message: state.errorMessage!);
              context.read<AuthFormBloc>().add(const AuthFormErrorCleared());
            }
          },
        ),
      ],
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: AppSizes.pagePadding),
            child: BlocBuilder<AuthFormBloc, AuthFormState>(
              buildWhen: (prev, curr) => prev.activeTab != curr.activeTab,
              builder: (context, formState) {
                return Column(
                  children: [
                    SizedBox(height: AppSizes.xxl),
                    const AuthHeader(
                      title: AppStrings.welcome,
                      subtitle: AppStrings.welcomeSubtitle,
                    ),
                    SizedBox(height: AppSizes.xxxl),
                    AuthTabBar(
                      tabs: const [AppStrings.login, AppStrings.signUp],
                      selectedIndex: formState.activeTab,
                      onTabChanged: (index) {
                        context
                            .read<AuthFormBloc>()
                            .add(AuthFormTabChanged(index));
                      },
                    ),
                    SizedBox(height: AppSizes.xxl),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: formState.activeTab == 0
                          ? _buildLoginForm()
                          : _buildSignUpForm(),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Column(
      key: const ValueKey('login'),
      children: [
        SekkaInputField(
          controller: _phoneController,
          hint: AppStrings.enterPhone,
          prefixIcon: Icons.phone_rounded,
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.next,
          textAlign: TextAlign.start,
          errorText: _phoneError,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[\d٠-٩\+]')),
            LengthLimitingTextInputFormatter(14),
          ],
          onChanged: (_) {
            if (_phoneError != null) setState(() => _phoneError = null);
          },
        ),
        SizedBox(height: AppSizes.lg),
        SekkaInputField(
          controller: _passwordController,
          hint: AppStrings.enterPassword,
          prefixIcon: Icons.lock_rounded,
          suffixIcon: _obscurePassword
              ? Icons.visibility_off_rounded
              : Icons.visibility_rounded,
          onSuffixTap: () =>
              setState(() => _obscurePassword = !_obscurePassword),
          obscureText: _obscurePassword,
          textInputAction: TextInputAction.done,
          errorText: _passwordError,
          onChanged: (_) {
            if (_passwordError != null) setState(() => _passwordError = null);
          },
          onSubmitted: (_) => _onLogin(),
        ),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: TextButton(
            onPressed: _onForgotPassword,
            child: Text(
              AppStrings.forgotPassword,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
        ),
        SizedBox(height: AppSizes.lg),
        BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            return SekkaButton(
              label: AppStrings.login,
              onPressed: _onLogin,
              isLoading: state is AuthLoading,
            );
          },
        ),
        SizedBox(height: AppSizes.xxl),
      ],
    );
  }

  Widget _buildSignUpForm() {
    return Column(
      key: const ValueKey('signup'),
      children: [
        SekkaInputField(
          controller: _signUpPhoneController,
          hint: AppStrings.enterPhone,
          prefixIcon: Icons.phone_rounded,
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.done,
          textAlign: TextAlign.start,
          errorText: _signUpPhoneError,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[\d٠-٩\+]')),
            LengthLimitingTextInputFormatter(14),
          ],
          onChanged: (_) {
            if (_signUpPhoneError != null) {
              setState(() => _signUpPhoneError = null);
            }
          },
          onSubmitted: (_) => _onSendOtp(),
        ),
        SizedBox(height: AppSizes.xxl),
        BlocBuilder<AuthFormBloc, AuthFormState>(
          buildWhen: (prev, curr) => prev.isLoading != curr.isLoading,
          builder: (context, state) {
            return SekkaButton(
              label: AppStrings.sendVerificationCode,
              onPressed: _onSendOtp,
              isLoading: state.isLoading,
            );
          },
        ),
        SizedBox(height: AppSizes.xxl),
      ],
    );
  }
}

// ── Data classes for navigation ──

enum OtpPurpose { register, forgotPassword }

class OtpScreenArgs {
  const OtpScreenArgs({
    required this.phoneNumber,
    required this.purpose,
  });

  final String phoneNumber;
  final OtpPurpose purpose;
}
