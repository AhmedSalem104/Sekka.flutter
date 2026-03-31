import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/widgets/sekka_message_dialog.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/sekka_back_button.dart';
import '../../../../core/widgets/sekka_button.dart';
import '../../../../core/widgets/sekka_input_field.dart';
import '../bloc/auth_form_bloc.dart';
import '../bloc/auth_form_event.dart';
import '../bloc/auth_form_state.dart';
import '../widgets/auth_header.dart';
import 'otp_screen.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({
    super.key,
    required this.args,
  });

  final ResetPasswordArgs args;

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  String? _passwordError;
  String? _confirmError;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _onReset() {
    final passErr = Validators.password(_passwordController.text);
    final confirmErr = Validators.confirmPassword(
      _confirmController.text,
      _passwordController.text,
    );

    setState(() {
      _passwordError = passErr;
      _confirmError = confirmErr;
    });

    if (passErr != null || confirmErr != null) return;

    context.read<AuthFormBloc>().add(AuthFormResetPassword(
          phoneNumber: widget.args.phoneNumber,
          otpCode: widget.args.otpCode,
          newPassword: _passwordController.text,
          confirmPassword: _confirmController.text,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthFormBloc, AuthFormState>(
      listenWhen: (prev, curr) => prev.status != curr.status,
      listener: (context, state) {
        if (state.status == AuthFormStatus.success) {
          SekkaMessageDialog.show(
            context,
            message: AppStrings.passwordResetSuccess,
            type: SekkaMessageType.success,
          );
          // Go back to auth screen
          context.go(RouteNames.auth);
        } else if (state.status == AuthFormStatus.failure &&
            state.errorMessage != null) {
          SekkaMessageDialog.show(context, message: state.errorMessage!);
          context.read<AuthFormBloc>().add(const AuthFormErrorCleared());
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? AppColors.backgroundDark
            : AppColors.background,
        appBar: AppBar(
          leading: SekkaBackButton(onPressed: () => context.pop()),
        ),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSizes.pagePadding),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(height: AppSizes.lg),
                        Image.asset(
                          'assets/images/reset_password.png',
                          height: AppSizes.avatarLg * 3.5,
                          fit: BoxFit.contain,
                        ),
                        SizedBox(height: AppSizes.xxl),
                        AuthHeader(
                          title: AppStrings.resetPassword,
                          showLogo: false,
                        ),
                        SizedBox(height: AppSizes.xxxl),
                        SekkaInputField(
                          controller: _passwordController,
                          hint: AppStrings.newPassword,
                          prefixIcon: Icons.lock_rounded,
                          suffixIcon: _obscurePassword
                              ? Icons.visibility_off_rounded
                              : Icons.visibility_rounded,
                          onSuffixTap: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.next,
                          errorText: _passwordError,
                          onChanged: (_) {
                            if (_passwordError != null) {
                              setState(() => _passwordError = null);
                            }
                          },
                        ),
                        SizedBox(height: AppSizes.lg),
                        SekkaInputField(
                          controller: _confirmController,
                          hint: AppStrings.confirmNewPassword,
                          prefixIcon: Icons.lock_outline_rounded,
                          suffixIcon: _obscureConfirm
                              ? Icons.visibility_off_rounded
                              : Icons.visibility_rounded,
                          onSuffixTap: () => setState(
                            () => _obscureConfirm = !_obscureConfirm,
                          ),
                          obscureText: _obscureConfirm,
                          textInputAction: TextInputAction.done,
                          errorText: _confirmError,
                          onChanged: (_) {
                            if (_confirmError != null) {
                              setState(() => _confirmError = null);
                            }
                          },
                          onSubmitted: (_) => _onReset(),
                        ),
                      ],
                    ),
                  ),
                ),
                BlocBuilder<AuthFormBloc, AuthFormState>(
                  buildWhen: (prev, curr) =>
                      prev.isLoading != curr.isLoading,
                  builder: (context, state) {
                    return SekkaButton(
                      label: AppStrings.resetPassword,
                      onPressed: _onReset,
                      isLoading: state.isLoading,
                    );
                  },
                ),
                SizedBox(height: AppSizes.xxl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
