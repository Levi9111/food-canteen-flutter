import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_canteen/main.dart';

void main() {
  testWidgets('App loads cleanly on mobile portrait screen (390 x 844) across all tabs without overflow', (WidgetTester tester) async {
    // Standard mobile phone viewport: iPhone 14 / modern Android (390x844)
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const ProviderScope(
        child: RtsFoodCanteenApp(),
      ),
    );

    await tester.pumpAndSettle();

    // 1. Verify Tab 1: Daily Register
    expect(find.textContaining('FOOD CANTEEN, RTS'), findsAtLeast(1));
    expect(find.text('CURRENT ENTRY'), findsOneWidget);
    expect(find.text('Room 1'), findsOneWidget);

    // 2. Switch to Tab 2: Monthly Matrix
    await tester.tap(find.text('MATRIX'));
    await tester.pumpAndSettle();
    expect(find.text('TOTAL ROOMS TRACKED'), findsOneWidget);

    // 3. Switch to Tab 3: Soft Spreadsheet
    await tester.tap(find.text('SPREADSHEET'));
    await tester.pumpAndSettle();
    expect(find.text('PRINT SPREADSHEET'), findsOneWidget);

    // 4. Switch to Tab 4: Audit & Recon
    await tester.tap(find.text('AUDIT'));
    await tester.pumpAndSettle();
    expect(find.textContaining('OFFICIAL AUDIT STATEMENT'), findsAtLeast(1));
  });

  testWidgets('App loads cleanly on compact 360 x 740 Android phone screen', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(360, 740);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const ProviderScope(
        child: RtsFoodCanteenApp(),
      ),
    );

    await tester.pumpAndSettle();

    // Verify Tab 1: Daily Register on 360px
    expect(find.textContaining('FOOD CANTEEN, RTS'), findsAtLeast(1));
    expect(find.text('Room 1'), findsOneWidget);

    // Toggle from Card View to Table View on mobile
    await tester.tap(find.text('TABLE VIEW'));
    await tester.pumpAndSettle();
    expect(find.text('CARD VIEW'), findsOneWidget);

    // Toggle back to Card View
    await tester.tap(find.text('CARD VIEW'));
    await tester.pumpAndSettle();
    expect(find.text('TABLE VIEW'), findsOneWidget);
  });
}
