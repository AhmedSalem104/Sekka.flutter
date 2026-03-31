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
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/sekka_back_button.dart';
import '../../../../core/widgets/sekka_button.dart';
import '../../../../core/widgets/sekka_input_field.dart';
import '../bloc/auth_form_bloc.dart';
import '../bloc/auth_form_event.dart';
import '../bloc/auth_form_state.dart';
import '../widgets/auth_header.dart';
import 'auth_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _phoneController = TextEditingController();
  String? _phoneError;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _onSend() {
    final phone = _phoneController.text.toEnglishNumbers.trim();
    final error = Validators.phone(phone);

    setState(() => _phoneError = error);
    if (error != null) return;

    context.read<AuthFormBloc>().add(AuthFormForgotPassword(phone));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthFormBloc, AuthFormState>(
      listenWhen: (prev, curr) => prev.status != curr.status,
      listener: (context, state) {
        if (state.status == AuthFormStatus.success) {
          context.push(
            RouteNames.otp,
            extra: OtpScreenArgs(
              phoneNumber: _phoneController.text.toEnglishNumbers.trim(),
              purpose: OtpPurpose.forgotPassword,
            ),
          );
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
                          'assets/images/forgot_password.png',
                          height: AppSizes.avatarLg * 3.5,
                          fit: BoxFit.contain,
                        ),
                        SizedBox(height: AppSizes.xxl),
                        AuthHeader(
                          title: AppStrings.forgotPassword,
                          subtitle: AppStrings.forgotPasswordSubtitle,
                          showLogo: false,
                        ),
                        SizedBox(height: AppSizes.xxxl),
                        SekkaInputField(
                          controller: _phoneController,
                          hint: AppStrings.enterPhone,
                          prefixIcon: Icons.phone_rounded,
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.done,
                          textAlign: TextAlign.start,
                          errorText: _phoneError,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'[\d٠-٩\+]'),
                            ),
                            LengthLimitingTextInputFormatter(14),
                          ],
                          onChanged: (_) {
                            if (_phoneError != null) {
                              setState(() => _phoneError = null);
                            }
                          },
                          onSubmitted: (_) => _onSend(),
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
                      label: AppStrings.sendVerificationCode,
                      onPressed: _onSend,
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
