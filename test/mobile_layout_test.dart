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
    expect(find.text('PREVIOUS DUE'), findsAtLeast(1));
    expect(find.text('MONTH SPENDING'), findsAtLeast(1));

    // 3. Switch to Tab 3: Soft Spreadsheet
    await tester.tap(find.text('SPREADSHEET'));
    await tester.pumpAndSettle();
    expect(find.text('PRINT SPREADSHEET'), findsOneWidget);

    // 4. Switch to Tab 4: Audit & Recon
    await tester.tap(find.text('AUDIT'));
    await tester.pumpAndSettle();
    expect(find.textContaining('OFFICIAL AUDIT STATEMENT'), findsAtLeast(1));
  });

  testWidgets('App loads cleanly on user phone resolution (460 x 1024) without vertical stacking', (WidgetTester tester) async {
    // User's exact Android resolution from screenshot: 460 x 1024
    tester.view.physicalSize = const Size(460, 1024);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const ProviderScope(
        child: RtsFoodCanteenApp(),
      ),
    );

    await tester.pumpAndSettle();

    // Verify Title and tags
    expect(find.text('FOOD CANTEEN, RTS'), findsOneWidget);
    expect(find.text('BAF'), findsOneWidget);
    expect(find.text('RTS CANTEEN'), findsOneWidget);

    // Verify that TabBar is visible and rendered
    expect(find.text('REGISTER'), findsOneWidget);
    expect(find.text('MATRIX'), findsOneWidget);
    expect(find.text('SPREADSHEET'), findsOneWidget);
    expect(find.text('AUDIT'), findsOneWidget);

    // Switch to Matrix
    await tester.tap(find.text('MATRIX'));
    await tester.pumpAndSettle();
    expect(find.text('PREVIOUS DUE'), findsAtLeast(1));

    // Switch to Spreadsheet
    await tester.tap(find.text('SPREADSHEET'));
    await tester.pumpAndSettle();
    expect(find.text('PRINT SPREADSHEET'), findsOneWidget);
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
