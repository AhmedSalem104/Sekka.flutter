import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sekka/app.dart';

void main() {
  testWidgets('App launches successfully', (WidgetTester tester) async {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (_, __) => const Scaffold(
            body: Center(child: Text('Test')),
          ),
        ),
      ],
    );
    await tester.pumpWidget(SekkaApp(
      router: router,
      themeModeNotifier: ValueNotifier(ThemeMode.light),
      localeNotifier: ValueNotifier(const Locale('ar')),
    ));
    expect(find.text('Test'), findsOneWidget);
  });
}
