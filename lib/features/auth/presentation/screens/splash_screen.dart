import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_animations.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../shared/network/api_result.dart';
import '../../../../shared/network/dio_client.dart';
import '../../../app_config/app_config_service.dart';
import '../../../app_config/data/repositories/app_config_repository.dart';
import '../../../app_config/presentation/screens/force_update_screen.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: AppAnimations.defaultCurve,
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: AppAnimations.defaultCurve,
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.forward();
    });

    _navigate();
  }

  Future<void> _navigate() async {
    final bloc = context.read<AuthBloc>();
    final configRepo = AppConfigRepository(context.read<DioClient>().dio);
    final config = AppConfigService.instance;

    await Future<void>.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    // ── 1. Load app config (version + features + notices) ──
    await _loadAppConfig(configRepo, config);
    if (!mounted) return;

    // ── 2. Force update check ──
    if (config.needsForceUpdate) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => ForceUpdateScreen(
            updateUrl: config.versionCheck?.updateUrl,
            message: config.versionCheck?.message,
          ),
        ),
      );
      return;
    }

    // ── 3. Onboarding check ──
    final prefs = await SharedPreferences.getInstance();
    final hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;

    if (!mounted) return;

    if (!hasSeenOnboarding) {
      context.go(RouteNames.onboarding);
      return;
    }

    // ── 4. Auth check ──
    bloc.add(const AuthCheckRequested());

    await bloc.stream.firstWhere(
      (state) => state is AuthAuthenticated || state is AuthUnauthenticated,
    );

    if (!mounted) return;

    if (bloc.state is AuthAuthenticated) {
      context.go(RouteNames.main);
      // Show optional update dialog after entering home
      if (config.versionCheck != null &&
          !config.versionCheck!.isUpToDate &&
          !config.versionCheck!.isForceUpdate) {
        _showOptionalUpdateDialog();
      }
      // Show notices
      _showNotices(config);
    } else {
      context.go(RouteNames.auth);
    }
  }

  Future<void> _loadAppConfig(
    AppConfigRepository repo,
    AppConfigService config,
  ) async {
    final results = await (
      repo.checkVersion(),
      repo.getFeatures(),
      repo.getNotices(),
    ).wait;

    final (version, features, notices) = results;

    if (version case ApiSuccess(:final data)) {
      config.setVersionCheck(data);
    }
    if (features case ApiSuccess(:final data)) {
      config.setFeatures(data);
    }
    if (notices case ApiSuccess(:final data)) {
      config.setNotices(data);
    }
  }

  void _showOptionalUpdateDialog() {
    if (!mounted) return;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        ),
        title: Text(
          AppStrings.optionalUpdateTitle,
          style: AppTypography.headlineSmall.copyWith(
            color:
                isDark ? AppColors.textHeadlineDark : AppColors.textHeadline,
          ),
        ),
        content: Text(
          AppStrings.optionalUpdateMessage,
          style: AppTypography.bodyMedium.copyWith(
            color: isDark ? AppColors.textBodyDark : AppColors.textBody,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              AppStrings.later,
              style: AppTypography.titleMedium.copyWith(
                color: isDark
                    ? AppColors.textCaptionDark
                    : AppColors.textCaption,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              final url = AppConfigService.instance.versionCheck?.updateUrl;
              if (url != null) {
                // ignore: avoid ignoring, but launchUrl is fire-and-forget here
              }
            },
            child: Text(
              AppStrings.forceUpdateButton,
              style: AppTypography.titleMedium.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showNotices(AppConfigService config) {
    if (!mounted || config.notices.isEmpty) return;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Show first notice as a dialog
    final notice = config.notices.first;
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        ),
        title: Text(
          notice.title,
          style: AppTypography.headlineSmall.copyWith(
            color:
                isDark ? AppColors.textHeadlineDark : AppColors.textHeadline,
          ),
        ),
        content: Text(
          notice.message,
          style: AppTypography.bodyMedium.copyWith(
            color: isDark ? AppColors.textBodyDark : AppColors.textBody,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              AppStrings.ok,
              style: AppTypography.titleMedium.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final logoAsset =
        isDark ? 'assets/images/logo_dark.png' : 'assets/images/logo.png';

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeAnimation.value,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: child,
              ),
            );
          },
          child: Image.asset(
            logoAsset,
            width: Responsive.w(260),
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
