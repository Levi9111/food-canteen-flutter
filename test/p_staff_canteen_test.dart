import 'package:flutter_test/flutter_test.dart';
import 'package:food_canteen/features/p_staff_canteen/constants/p_staff_constants.dart';
import 'package:food_canteen/features/p_staff_canteen/models/p_staff_models.dart';
import 'package:food_canteen/features/p_staff_canteen/providers/p_staff_register_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_canteen/features/recruits_canteen/presentation/canteen_main_screen.dart';
import 'package:food_canteen/main.dart';

void main() {
  group('P-Staff Domain & Calculation Tests', () {
    test('PStaffConstants offices and ranks are properly defined', () {
      expect(PStaffConstants.offices, contains('Admin Wing'));
      expect(PStaffConstants.offices, contains('Training Wing (RTS)'));
      expect(PStaffConstants.offices, contains('Station HQ'));
      expect(PStaffConstants.offices, contains('Accounts Section'));
      expect(PStaffConstants.ranks, contains('Sgt'));
      expect(PStaffConstants.ranks, contains('MWO'));
      expect(PStaffConstants.ranks, contains('WO'));
    });

    test('PStaffProfile data structure stores name, rank, bdNo, office', () {
      const profile = PStaffProfile(
        id: 'test_1',
        name: 'Tariqul Islam',
        rank: 'Sgt',
        bdNo: 'BD/48291',
        office: 'Admin Wing',
        preDue: 200.0,
        paid: 100.0,
      );

      expect(profile.name, 'Tariqul Islam');
      expect(profile.rank, 'Sgt');
      expect(profile.bdNo, 'BD/48291');
      expect(profile.office, 'Admin Wing');
      expect(profile.preDue, 200.0);
      expect(profile.paid, 100.0);
    });

    test('Monthly summary calculates preDue + monthlyTotal - paid = netDue', () {
      final now = DateTime.now();
      final key = '${now.year}-${now.month.toString().padLeft(2, '0')}-05_staff_1';
      final expenses = {
        key: DailyStaffExpense(
          staffId: 'staff_1',
          staffName: 'Tariqul Islam',
          bdNo: 'BD/48291',
          rank: 'Sgt',
          office: 'Admin Wing',
          date: DateTime(now.year, now.month, 5),
          amount: 250.0,
          recordedBy: 'NCOIC',
          recordedAt: now,
        ),
      };

      const staff = PStaffProfile(
        id: 'staff_1',
        name: 'Tariqul Islam',
        rank: 'Sgt',
        bdNo: 'BD/48291',
        office: 'Admin Wing',
        preDue: 150.0,
        paid: 100.0,
      );

      final state = PStaffRegisterState(
        staffProfiles: [staff],
        expenses: expenses,
        selectedDate: now,
        selectedOffice: 'ALL OFFICES',
        selectedYear: now.year,
        selectedMonth: now.month,
        activeManager: 'NCOIC',
      );

      final summary = state.getStaffMonthlySummary(staff.id, now.year, now.month);
      expect(summary.totalMonthlySpending, 250.0);
      expect(summary.grandTotal, 400.0); // 150 preDue + 250 monthly
      expect(summary.netDue, 300.0); // 400 - 100 paid
      expect(summary.activeDaysCount, 1);
    });
  });

  group('P-Staff UI Smoke Test', () {
    testWidgets('App displays customer switcher and switches between Recruits and P-Staffs', (tester) async {
      await tester.pumpWidget(const ProviderScope(child: RtsFoodCanteenApp(home: CanteenMainScreen())));
      await tester.pumpAndSettle();

      // Check customer switcher exists
      expect(find.textContaining('RECRUITS'), findsWidgets);
      expect(find.textContaining('P-STAFFS'), findsWidgets);

      // Tap P-Staffs tab
      await tester.tap(find.textContaining('P-STAFFS').first);
      await tester.pumpAndSettle();

      // Verify P-Staff UI loaded
      expect(find.text('OFFICE:'), findsOneWidget);
    });
  });
}
