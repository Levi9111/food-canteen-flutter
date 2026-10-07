import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_canteen/core/widgets/canteen_calculator_dialog.dart';
import 'package:food_canteen/features/auth/models/session_user.dart';
import 'package:food_canteen/features/auth/providers/operator_management_provider.dart';

void main() {
  group('Canteen Built-in Calculator Widget Tests', () {
    testWidgets('Evaluates arithmetic expression and returns total', (tester) async {
      double? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  result = await showCanteenCalculator(context, initialValue: 0);
                },
                child: const Text('OPEN CALCULATOR'),
              ),
            ),
          ),
        ),
      );

      // Open calculator
      await tester.tap(find.text('OPEN CALCULATOR'));
      await tester.pumpAndSettle();

      expect(find.text('CANTEEN EXPENSE CALCULATOR'), findsOneWidget);

      // Tap 5, 5
      await tester.tap(find.widgetWithText(OutlinedButton, '5'));
      await tester.pump();
      await tester.tap(find.widgetWithText(OutlinedButton, '5'));
      await tester.pump();

      // Tap +
      await tester.tap(find.widgetWithText(OutlinedButton, '+'));
      await tester.pump();

      // Tap 2, 0
      await tester.tap(find.widgetWithText(OutlinedButton, '2'));
      await tester.pump();
      await tester.tap(find.widgetWithText(OutlinedButton, '0'));
      await tester.pump();

      // Tap +
      await tester.tap(find.widgetWithText(OutlinedButton, '+'));
      await tester.pump();

      // Tap 5, 0
      await tester.tap(find.widgetWithText(OutlinedButton, '5'));
      await tester.pump();
      await tester.tap(find.widgetWithText(OutlinedButton, '0'));
      await tester.pump();

      // Tap =
      await tester.tap(find.widgetWithText(OutlinedButton, '='));
      await tester.pumpAndSettle();

      // Should display running total 125 (55 + 20 + 50)
      expect(find.textContaining('125'), findsWidgets);

      // Tap APPLY AMOUNT
      await tester.tap(find.text('APPLY AMOUNT'));
      await tester.pumpAndSettle();

      expect(result, equals(125.0));
    });
  });

  group('Operator Management Military Guard Rules Tests', () {
    test('OperatorManagementState enforces role exclusivity and slot limits', () {
      const stateEmpty = OperatorManagementState(operators: []);
      expect(stateEmpty.hasNcoic, isFalse);
      expect(stateEmpty.hasJcoic, isFalse);
      expect(stateEmpty.isFullyStaffed, isFalse);
      expect(stateEmpty.vacantRole, equals('NCOIC'));

      const stateOnlyNcoic = OperatorManagementState(
        operators: [
          SessionUser(
            id: '1',
            username: 'ncoic',
            name: 'Tariqul',
            rank: 'Sgt',
            role: 'NCOIC',
            bdNo: 'BD/48291',
          ),
        ],
      );
      expect(stateOnlyNcoic.hasNcoic, isTrue);
      expect(stateOnlyNcoic.hasJcoic, isFalse);
      expect(stateOnlyNcoic.isFullyStaffed, isFalse);
      expect(stateOnlyNcoic.vacantRole, equals('JCOIC'));

      const stateBoth = OperatorManagementState(
        operators: [
          SessionUser(
            id: '1',
            username: 'ncoic',
            name: 'Tariqul',
            rank: 'Sgt',
            role: 'NCOIC',
            bdNo: 'BD/48291',
          ),
          SessionUser(
            id: '2',
            username: 'jcoic',
            name: 'Humayun',
            rank: 'MWO',
            role: 'JCOIC',
            bdNo: 'BD/39102',
          ),
        ],
      );
      expect(stateBoth.hasNcoic, isTrue);
      expect(stateBoth.hasJcoic, isTrue);
      expect(stateBoth.isFullyStaffed, isTrue);
      expect(stateBoth.vacantRole, isNull);
    });

    test('Notifier blocks extra operator when already fully staffed', () async {
      final container = ProviderContainer();
      final notifier = container.read(operatorManagementProvider.notifier);

      final success = await notifier.enrollOperator(
        username: 'third_op',
        name: 'Third Operator',
        rank: 'Sgt',
        bdNo: 'BD/99999',
        password: 'password123',
        role: 'NCOIC',
      );

      // Baseline has 2 operators, so enrolling third must be rejected
      final state = container.read(operatorManagementProvider);
      expect(state.isFullyStaffed, isTrue);
      expect(success, isFalse);
      expect(state.errorMessage, contains('Both NCOIC and JCOIC positions are already occupied'));
    });
  });
}
