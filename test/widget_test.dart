import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_canteen/core/constants/app_constants.dart';
import 'package:food_canteen/main.dart';

void main() {
  testWidgets('App loads welcome screen smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: FoodCanteenApp(),
      ),
    );

    expect(find.text(AppConstants.appName), findsOneWidget);
  });
}
