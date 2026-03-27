import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/widgets/sekka_message_dialog.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/sekka_back_button.dart';
import '../../../../core/widgets/sekka_button.dart';
import '../bloc/auth_form_bloc.dart';
import '../bloc/auth_form_event.dart';
import '../bloc/auth_form_state.dart';
import '../widgets/auth_header.dart';
import '../widgets/countdown_timer_text.dart';
import '../widgets/otp_input_box.dart';
import 'auth_screen.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({
    super.key,
    required this.args,
  });

  final OtpScreenArgs args;

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _otpKey = GlobalKey<OtpInputBoxState>();
  String _otpCode = '';
  String? _otpError;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Start the timer when screen opens
    context.read<AuthFormBloc>().add(const AuthFormTimerStarted());
  }

  void _onOtpCompleted(String code) {
    setState(() {
      _otpCode = code;
      _otpError = null;
    });
  }

  void _onVerify() {
    final error = Validators.otp(_otpCode);
    if (error != null) {
      setState(() => _otpError = error);
      return;
    }

    setState(() => _isSubmitting = true);

    switch (widget.args.purpose) {
      case OtpPurpose.register:
        context.push(
          RouteNames.completeProfile,
          extra: CompleteProfileArgs(
            phoneNumber: widget.args.phoneNumber,
            otpCode: _otpCode,
          ),
        );
        setState(() => _isSubmitting = false);
      case OtpPurpose.forgotPassword:
        context.push(
          RouteNames.resetPassword,
          extra: ResetPasswordArgs(
            phoneNumber: widget.args.phoneNumber,
            otpCode: _otpCode,
          ),
        );
        setState(() => _isSubmitting = false);
    }
  }

  void _onResend() {
    _otpKey.currentState?.clear();
    setState(() {
      _otpCode = '';
      _otpError = null;
    });
    context
        .read<AuthFormBloc>()
        .add(AuthFormResendOtp(widget.args.phoneNumber));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthFormBloc, AuthFormState>(
      listenWhen: (prev, curr) =>
          prev.status != curr.status && curr.status == AuthFormStatus.failure,
      listener: (context, state) {
        if (state.errorMessage != null) {
          SekkaMessageDialog.show(context, message: state.errorMessage!);
          context.read<AuthFormBloc>().add(const AuthFormErrorCleared());
        }
      },
      child: Scaffold(
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
                          'assets/images/otp_verification.png',
                          height: AppSizes.avatarLg * 3,
                          fit: BoxFit.contain,
                        ),
                        SizedBox(height: AppSizes.xxl),
                        AuthHeader(
                          title: AppStrings.otpVerification,
                          subtitle:
                              '${AppStrings.otpSentTo}\n${widget.args.phoneNumber}',
                          showLogo: false,
                        ),
                        SizedBox(height: AppSizes.xxxl),
                        OtpInputBox(
                          key: _otpKey,
                          onCompleted: _onOtpCompleted,
                          hasError: _otpError != null,
                        ),
                        if (_otpError != null) ...[
                          SizedBox(height: AppSizes.sm),
                          Text(
                            _otpError!,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                              fontSize: 12,
                            ),
                          ),
                        ],
                        SizedBox(height: AppSizes.xxl),
                        BlocBuilder<AuthFormBloc, AuthFormState>(
                          buildWhen: (prev, curr) =>
                              prev.otpCountdownSeconds !=
                                  curr.otpCountdownSeconds ||
                              prev.canResendOtp != curr.canResendOtp,
                          builder: (context, state) {
                            return CountdownTimerText(
                              secondsRemaining: state.otpCountdownSeconds,
                              canResend: state.canResendOtp,
                              onResend: _onResend,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                SekkaButton(
                  label: AppStrings.next,
                  onPressed: _onVerify,
                  isLoading: _isSubmitting,
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

class CompleteProfileArgs {
  const CompleteProfileArgs({
    required this.phoneNumber,
    required this.otpCode,
  });

  final String phoneNumber;
  final String otpCode;
}

class ResetPasswordArgs {
  const ResetPasswordArgs({
    required this.phoneNumber,
    required this.otpCode,
  });

  final String phoneNumber;
  final String otpCode;
}
