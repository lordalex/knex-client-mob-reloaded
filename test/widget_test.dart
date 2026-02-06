import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:knex_client/app.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: KnexApp()),
    );
    // Verify the app builds without errors.
    expect(find.text('Login'), findsOneWidget);
  });
}
