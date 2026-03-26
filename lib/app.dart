import 'package:flutter/material.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/responsive.dart';

class SekkaApp extends StatelessWidget {
  const SekkaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'سِكّة',
      debugShowCheckedModeBanner: false,

      // Themes (Light + Dark)
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,

      // Locales (Arabic primary + English)
      locale: const Locale('ar'),
      supportedLocales: const [
        Locale('ar'),
        Locale('en'),
      ],

      // Router
      routerConfig: appRouter,

      // Initialize Responsive + force RTL
      builder: (context, child) {
        Responsive.init(context);
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        );
      },
    );
  }
}
