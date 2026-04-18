import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';

import 'core/theme/app_theme.dart';
import 'core/utils/responsive.dart';
import 'core/widgets/connectivity_banner.dart';
import 'shared/services/focus_mode_service.dart';

class SekkaApp extends StatefulWidget {
  const SekkaApp({
    super.key,
    required this.router,
    required this.themeModeNotifier,
    required this.localeNotifier,
  });

  final GoRouter router;
  final ValueNotifier<ThemeMode> themeModeNotifier;
  final ValueNotifier<Locale> localeNotifier;

  @override
  State<SekkaApp> createState() => _SekkaAppState();
}

class _SekkaAppState extends State<SekkaApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final focusMode = FocusModeService.instance;
    if (!focusMode.isEnabled) return;

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      focusMode.pauseDnd();
    } else if (state == AppLifecycleState.resumed) {
      focusMode.resumeDnd();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: widget.themeModeNotifier,
      builder: (context, themeMode, _) {
        return ValueListenableBuilder<Locale>(
          valueListenable: widget.localeNotifier,
          builder: (context, locale, _) {
            final isRtl = locale.languageCode == 'ar';

            return MaterialApp.router(
              title: 'سِكّة',
              debugShowCheckedModeBanner: false,

              // Themes
              theme: AppTheme.light,
              darkTheme: AppTheme.dark,
              themeMode: themeMode,

              // Localizations
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              locale: locale,
              supportedLocales: const [
                Locale('ar'),
                Locale('en'),
              ],

              // Router
              routerConfig: widget.router,

              // Initialize Responsive + text direction
              builder: (context, child) {
                Responsive.init(context);
                return Directionality(
                  textDirection:
                      isRtl ? TextDirection.rtl : TextDirection.ltr,
                  child: ConnectivityBanner(child: child!),
                );
              },
            );
          },
        );
      },
    );
  }
}
