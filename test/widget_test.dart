import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_canteen/main.dart';

void main() {
  testWidgets('App loads RTS Food Canteen ledger dashboard smoke test', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const ProviderScope(
        child: RtsFoodCanteenApp(),
      ),
    );

    await tester.pumpAndSettle();

    // Verify tabs and masthead render
    expect(find.textContaining('FOOD CANTEEN, RTS'), findsOneWidget);
    expect(find.textContaining('RECRUITS MESS LEDGER'), findsOneWidget);
    expect(find.textContaining('PERMANENT STAFF LEDGER'), findsOneWidget);
    expect(find.textContaining('MONTHLY AUDIT'), findsOneWidget);
  });
}
