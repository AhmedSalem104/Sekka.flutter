import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';

import 'core/theme/app_theme.dart';
import 'core/utils/responsive.dart';
import 'core/widgets/connectivity_banner.dart';

class SekkaApp extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeModeNotifier,
      builder: (context, themeMode, _) {
        return ValueListenableBuilder<Locale>(
          valueListenable: localeNotifier,
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
              routerConfig: router,

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
