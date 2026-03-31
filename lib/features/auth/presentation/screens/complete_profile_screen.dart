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
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_form_bloc.dart';
import '../bloc/auth_form_event.dart';
import '../bloc/auth_form_state.dart';
import '../bloc/auth_state.dart';
import '../widgets/auth_header.dart';
import '../widgets/vehicle_type_selector.dart';
import 'otp_screen.dart';

class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({
    super.key,
    required this.args,
  });

  final CompleteProfileArgs args;

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _emailController = TextEditingController();
  final _inviteCodeController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  int? _selectedVehicleType;

  String? _nameError;
  String? _passwordError;
  String? _confirmPasswordError;
  String? _emailError;
  String? _vehicleTypeError;

  @override
  void initState() {
    super.initState();
    context.read<AuthFormBloc>().add(const AuthFormLoadVehicleTypes());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _emailController.dispose();
    _inviteCodeController.dispose();
    super.dispose();
  }

  void _onRegister() {
    final nameErr = Validators.name(_nameController.text);
    final passErr = Validators.password(_passwordController.text);
    final confirmErr = Validators.confirmPassword(
      _confirmPasswordController.text,
      _passwordController.text,
    );
    final emailErr = Validators.email(_emailController.text);
    final vehicleErr =
        _selectedVehicleType == null ? AppStrings.vehicleTypeRequired : null;

    setState(() {
      _nameError = nameErr;
      _passwordError = passErr;
      _confirmPasswordError = confirmErr;
      _emailError = emailErr;
      _vehicleTypeError = vehicleErr;
    });

    if (nameErr != null ||
        passErr != null ||
        confirmErr != null ||
        emailErr != null ||
        vehicleErr != null) {
      return;
    }

    final email = _emailController.text.trim();

    final inviteCode = _inviteCodeController.text.trim();

    context.read<AuthBloc>().add(AuthRegisterRequested(
          phoneNumber: widget.args.phoneNumber,
          otpCode: widget.args.otpCode,
          password: _passwordController.text,
          confirmPassword: _confirmPasswordController.text,
          name: _nameController.text.trim(),
          vehicleType: _selectedVehicleType!,
          email: email.isEmpty ? null : email,
          referralCode: inviteCode.isEmpty ? null : inviteCode,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          context.go(RouteNames.success);
        } else if (state is AuthUnauthenticated && state.message != null) {
          SekkaMessageDialog.show(context, message: state.message!);
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
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSizes.pagePadding,
                  ),
                  child: Column(
                    children: [
                      SizedBox(height: AppSizes.lg),
                      AuthHeader(
                        title: AppStrings.completeProfile,
                        subtitle: AppStrings.completeProfileSubtitle,
                        showLogo: false,
                      ),
                      SizedBox(height: AppSizes.xxxl),

                      // Name
                      SekkaInputField(
                        controller: _nameController,
                        hint: AppStrings.driverName,
                        prefixIcon: Icons.person_rounded,
                        textInputAction: TextInputAction.next,
                        errorText: _nameError,
                        onChanged: (_) {
                          if (_nameError != null) {
                            setState(() => _nameError = null);
                          }
                        },
                      ),
                      SizedBox(height: AppSizes.lg),

                      // Password
                      SekkaInputField(
                        controller: _passwordController,
                        hint: AppStrings.password,
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

                      // Confirm Password
                      SekkaInputField(
                        controller: _confirmPasswordController,
                        hint: AppStrings.confirmPassword,
                        prefixIcon: Icons.lock_outline_rounded,
                        suffixIcon: _obscureConfirm
                            ? Icons.visibility_off_rounded
                            : Icons.visibility_rounded,
                        onSuffixTap: () => setState(
                          () => _obscureConfirm = !_obscureConfirm,
                        ),
                        obscureText: _obscureConfirm,
                        textInputAction: TextInputAction.next,
                        errorText: _confirmPasswordError,
                        onChanged: (_) {
                          if (_confirmPasswordError != null) {
                            setState(() => _confirmPasswordError = null);
                          }
                        },
                      ),
                      SizedBox(height: AppSizes.lg),

                      // Email (optional)
                      SekkaInputField(
                        controller: _emailController,
                        hint: AppStrings.emailOptional,
                        prefixIcon: Icons.email_rounded,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.done,
                        errorText: _emailError,
                        onChanged: (_) {
                          if (_emailError != null) {
                            setState(() => _emailError = null);
                          }
                        },
                      ),
                      SizedBox(height: AppSizes.lg),

                      // Vehicle Type
                      BlocBuilder<AuthFormBloc, AuthFormState>(
                        buildWhen: (prev, curr) =>
                            prev.vehicleTypes != curr.vehicleTypes,
                        builder: (context, state) {
                          return VehicleTypeSelector(
                            vehicleTypes: state.vehicleTypes,
                            selectedId: _selectedVehicleType,
                            errorText: _vehicleTypeError,
                            onChanged: (value) {
                              setState(() {
                                _selectedVehicleType = value;
                                _vehicleTypeError = null;
                              });
                            },
                          );
                        },
                      ),
                      SizedBox(height: AppSizes.lg),

                      // Invite Code (optional)
                      SekkaInputField(
                        controller: _inviteCodeController,
                        hint: AppStrings.enterInviteCode,
                        label: AppStrings.haveInviteCode,
                        prefixIcon: Icons.card_giftcard_rounded,
                        textInputAction: TextInputAction.done,
                      ),
                      SizedBox(height: AppSizes.xxl),
                    ],
                  ),
                ),
              ),

              // Bottom button
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSizes.pagePadding,
                ),
                child: BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    return SekkaButton(
                      label: AppStrings.createAccount,
                      onPressed: _onRegister,
                      isLoading: state is AuthLoading,
                    );
                  },
                ),
              ),
              SizedBox(height: AppSizes.xxl),
            ],
          ),
        ),
      ),
    );
  }
}
