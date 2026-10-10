import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:food_canteen/features/settings/presentation/settings_screen.dart';
import 'package:food_canteen/features/settings/presentation/squadron_management_screen.dart';
import 'package:food_canteen/features/settings/presentation/user_management_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Settings Dedicated Pages & Warning Tests', () {
    testWidgets('SettingsScreen displays dedicated navigation cards for Squadron and Operator management', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SettingsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('CANTEEN SETTINGS & CONFIGURATION'), findsOneWidget);
      expect(find.text('Squadron & Room Management'), findsOneWidget);
      expect(find.text('Duty In-Charge & Operator Management'), findsOneWidget);
    });

    testWidgets('Tapping Squadron Management card pushes SquadronManagementScreen with critical warnings', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SettingsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Squadron & Room Management'));
      await tester.pumpAndSettle();

      // Verify SquadronManagementScreen is displayed
      expect(find.byType(SquadronManagementScreen), findsOneWidget);
      expect(find.text('SQUADRON & ROOM MANAGEMENT'), findsOneWidget);
      expect(find.textContaining('MILITARY LEDGER STRUCTURE DIRECTIVE'), findsOneWidget);
      expect(find.text('Sadruddin'), findsOneWidget);
    });

    testWidgets('Tapping Duty In-Charge card pushes UserManagementScreen with security warnings', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SettingsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Duty In-Charge & Operator Management'));
      await tester.pumpAndSettle();

      // Verify UserManagementScreen is displayed
      expect(find.byType(UserManagementScreen), findsOneWidget);
      expect(find.text('DUTY APPOINTMENTS & OPERATORS'), findsOneWidget);
      expect(find.textContaining('OFFICIAL APPOINTMENT DISCIPLINE & ACCESS MANDATE'), findsOneWidget);
      expect(find.text('NCO IN-CHARGE (NCOIC)'), findsOneWidget);
    });
  });
}
