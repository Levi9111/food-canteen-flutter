import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_canteen/features/recruits_canteen/presentation/canteen_main_screen.dart';
import 'package:food_canteen/main.dart';

void main() {
  testWidgets('App loads RTS Food Canteen room register & bottom nav smoke test', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const ProviderScope(
        child: RtsFoodCanteenApp(
          home: CanteenMainScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify header, bottom navigation bar items, and entry badge
    expect(find.textContaining('FOOD CANTEEN, RTS'), findsAtLeast(1));
    expect(find.text('REGISTER'), findsAtLeast(1));
    expect(find.text('MATRIX'), findsAtLeast(1));
    expect(find.text('AUDIT'), findsAtLeast(1));
  });
}
