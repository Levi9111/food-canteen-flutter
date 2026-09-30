import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_canteen/main.dart';

void main() {
  testWidgets('App loads RTS Food Canteen room register & soft spreadsheet smoke test', (WidgetTester tester) async {
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

    // Verify header, tabs, and entry selector
    expect(find.textContaining('FOOD CANTEEN, RTS'), findsOneWidget);
    expect(find.textContaining('DAILY REGISTER'), findsOneWidget);
    expect(find.textContaining('MONTHLY MATRIX'), findsOneWidget);
    expect(find.textContaining('ROOM SOFT SPREADSHEET'), findsOneWidget);
  });
}
