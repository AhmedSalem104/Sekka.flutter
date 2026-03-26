import 'package:flutter_test/flutter_test.dart';
import 'package:sekka/app.dart';

void main() {
  testWidgets('App launches successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const SekkaApp());
    // App should render without errors
    expect(find.text('Splash'), findsOneWidget);
  });
}
