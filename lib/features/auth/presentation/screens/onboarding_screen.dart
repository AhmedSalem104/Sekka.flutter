import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_animations.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/sekka_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  late final AnimationController _imageController;
  late final AnimationController _textController;
  late final AnimationController _buttonsController;

  late final Animation<double> _imageFade;
  late final Animation<Offset> _imageSlide;
  late final Animation<double> _textFade;
  late final Animation<double> _buttonsFade;

  @override
  void initState() {
    super.initState();

    _imageController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _imageFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _imageController,
        curve: AppAnimations.defaultCurve,
      ),
    );
    _imageSlide = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _imageController,
        curve: AppAnimations.defaultCurve,
      ),
    );

    _textController = AnimationController(
      vsync: this,
      duration: AppAnimations.normal,
    );
    _textFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: AppAnimations.defaultCurve,
      ),
    );

    _buttonsController = AnimationController(
      vsync: this,
      duration: AppAnimations.normal,
    );
    _buttonsFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _buttonsController,
        curve: AppAnimations.defaultCurve,
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _imageController.forward();
      Future.delayed(const Duration(milliseconds: 250), () {
        if (mounted) _textController.forward();
      });
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) _buttonsController.forward();
      });
    });
  }

  @override
  void dispose() {
    _imageController.dispose();
    _textController.dispose();
    _buttonsController.dispose();
    super.dispose();
  }

  Future<void> _onGetStarted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_onboarding', true);
    if (!mounted) return;
    context.go(RouteNames.login);
  }

  void _onTryDemo() {
    _onGetStarted();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSizes.pagePadding),
          child: Column(
            children: [
              SizedBox(height: Responsive.h(40)),

              // Rider image
              Expanded(
                flex: 5,
                child: SlideTransition(
                  position: _imageSlide,
                  child: FadeTransition(
                    opacity: _imageFade,
                    child: Image.asset(
                      'assets/images/onboarding_rider.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),

              SizedBox(height: Responsive.h(24)),

              // Title + Subtitle
              FadeTransition(
                opacity: _textFade,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'طريقك أخضر.. ومكسبك أكبر',
                      style: AppTypography.headlineMedium.copyWith(
                        color: isDark
                            ? AppColors.textHeadlineDark
                            : AppColors.textHeadline,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: Responsive.h(12)),
                    Text(
                      'أوردراتك قريبة، خريطتك دقيقة، وفلوسك بتزيد مع كل مشوار. سِكّة هو اللي شايل عنك التفكير.',
                      style: AppTypography.bodyLarge.copyWith(
                        color: isDark
                            ? AppColors.textBodyDark
                            : AppColors.textCaption,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              SizedBox(height: Responsive.h(32)),

              // Buttons
              FadeTransition(
                opacity: _buttonsFade,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SekkaButton(
                      label: 'يلا نبدأ!',
                      onPressed: _onGetStarted,
                    ),
                    SizedBox(height: Responsive.h(16)),
                    GestureDetector(
                      onTap: _onTryDemo,
                      child: Text(
                        'جرّب بدون تسجيل',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textCaption,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }
}
