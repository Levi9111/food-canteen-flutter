import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:food_canteen/features/recruits_canteen/constants/canteen_constants.dart';
import 'package:food_canteen/features/recruits_canteen/providers/canteen_register_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('CanteenConstants Domain Constraints', () {
    test('Default entry is 54', () {
      expect(CanteenConstants.defaultEntry, '54');
    });

    test('There are exactly 4 hardcoded Squadrons with correct names', () {
      expect(CanteenConstants.squadrons.length, 4);
      expect(CanteenConstants.squadrons, [
        'Sadruddin',
        'Liakot Ali',
        'Nurul Haque',
        'Mansur Ali',
      ]);
    });

    test('There are exactly 16 hardcoded Rooms (Room 1 to Room 16)', () {
      expect(CanteenConstants.rooms.length, 16);
      expect(CanteenConstants.rooms.first, 'Room 1');
      expect(CanteenConstants.rooms.last, 'Room 16');
      for (int i = 1; i <= 16; i++) {
        expect(CanteenConstants.rooms.contains('Room $i'), isTrue);
      }
    });

    test('Managers are NCOIC and JCOIC', () {
      expect(CanteenConstants.roleNcoic, 'NCOIC');
      expect(CanteenConstants.roleJcoic, 'JCOIC');
      expect(CanteenConstants.managerRoles, ['NCOIC', 'JCOIC']);
    });
  });

  group('CanteenRegisterNotifier Business Logic & Calculations', () {
    test('Daily room expense recording and monthly totals calculation', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(canteenRegisterProvider.notifier);
      // Wait for initial demo load to complete
      await Future.delayed(const Duration(milliseconds: 50));

      // Use a new isolated entry '99' to test clean calculations
      notifier.addNewEntry('99');
      notifier.setActiveEntry('99');

      final today = DateTime(2026, 9, 15);
      notifier.setSelectedDate(today);
      notifier.setSelectedSquadron('Sadruddin');

      // Record spending for Room 1, Sadruddin Sqn
      await notifier.recordRoomExpense(
        room: 'Room 1',
        amount: 450.0,
        date: today,
        itemsDescription: 'Biscuits, Tea, Bananas',
        representativeName: 'Recruit Kamal',
      );

      // Record spending for Room 2, Sadruddin Sqn on same day
      await notifier.recordRoomExpense(
        room: 'Room 2',
        amount: 600.0,
        date: today,
        itemsDescription: 'Snacks & Juice',
        representativeName: 'Recruit Rahim',
      );

      // Record spending for Room 1 on a different day in the same month
      final anotherDay = DateTime(2026, 9, 20);
      notifier.setSelectedDate(anotherDay);
      await notifier.recordRoomExpense(
        room: 'Room 1',
        amount: 350.0,
        date: anotherDay,
        itemsDescription: 'Evening Refreshments',
        representativeName: 'Recruit Kamal',
      );

      final state = container.read(canteenRegisterProvider);

      // 1. Verify Squadron day total on 2026-09-15: Room 1 (450) + Room 2 (600) = 1050
      final dayTotal = state.getSquadronDayTotal('99', 'Sadruddin', today);
      expect(dayTotal, 1050.0);

      // 2. Verify Room 1 Month Total for September 2026: 450 + 350 = 800
      final room1MonthTotal = state.getRoomMonthTotal('99', 'Sadruddin', 'Room 1', 2026, 9);
      expect(room1MonthTotal, 800.0);

      // 3. Verify Room 2 Month Total for September 2026: 600
      final room2MonthTotal = state.getRoomMonthTotal('99', 'Sadruddin', 'Room 2', 2026, 9);
      expect(room2MonthTotal, 600.0);

      // 4. Verify Squadron Month Total for September 2026: Room 1 (800) + Room 2 (600) = 1400
      final sqnMonthTotal = state.getSquadronMonthTotal('99', 'Sadruddin', 2026, 9);
      expect(sqnMonthTotal, 1400.0);
    });

    test('Room soft spreadsheet generator produces full month of days and matches totals', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(canteenRegisterProvider.notifier);
      await Future.delayed(const Duration(milliseconds: 50));

      // Use isolated entry '98'
      notifier.addNewEntry('98');
      notifier.setActiveEntry('98');

      final testDate = DateTime(2026, 9, 10);
      notifier.setSelectedDate(testDate);
      notifier.setSelectedSquadron('Nurul Haque');

      await notifier.recordRoomExpense(
        room: 'Room 5',
        amount: 1250.0,
        date: testDate,
        itemsDescription: 'Tea, Milk, Snacks',
        representativeName: 'Recruit Tarek',
      );

      final summary = container.read(canteenRegisterProvider).getRoomMonthlySummary('98', 'Nurul Haque', 'Room 5', 2026, 9);

      // September has 30 days
      expect(summary.days.length, 30);
      expect(summary.room, 'Room 5');
      expect(summary.squadron, 'Nurul Haque');
      expect(summary.entry, '98');
      expect(summary.year, 2026);
      expect(summary.month, 9);

      // Verify the recorded day has the amount and particulars
      final day10Record = summary.days[9]; // index 9 is day 10
      expect(day10Record.dayNumber, 10);
      expect(day10Record.amount, 1250.0);
      expect(day10Record.itemsDescription, 'Tea, Milk, Snacks');
      expect(day10Record.representativeName, 'Recruit Tarek');

      // Verify other unrecorded days are 0.0
      expect(summary.days[0].amount, 0.0);
      expect(summary.days[15].amount, 0.0);

      // Grand total calculation in summary
      expect(summary.totalMonthlySpending, 1250.0);
    });

    test('Dynamic Entry Creation and Switching', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(canteenRegisterProvider.notifier);
      await Future.delayed(const Duration(milliseconds: 50));

      expect(container.read(canteenRegisterProvider).activeEntry, '54');
      expect(container.read(canteenRegisterProvider).allEntries.contains('54'), isTrue);

      // Add dynamic new entry batch 55
      notifier.addNewEntry('55');
      expect(container.read(canteenRegisterProvider).activeEntry, '55');
      expect(container.read(canteenRegisterProvider).allEntries.contains('55'), isTrue);

      // Switch back to 54
      notifier.setActiveEntry('54');
      expect(container.read(canteenRegisterProvider).activeEntry, '54');
    });

    test('Manager Duty In-Charge Switching', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(canteenRegisterProvider.notifier);
      expect(container.read(canteenRegisterProvider).activeManager, 'NCOIC');

      notifier.setActiveManager('JCOIC');
      expect(container.read(canteenRegisterProvider).activeManager, 'JCOIC');

      notifier.setActiveManager('NCOIC');
      expect(container.read(canteenRegisterProvider).activeManager, 'NCOIC');
    });

    test('Pricing Management Accounting Calculations (Pre Due, Paid, Grand Total, Net Due)', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(canteenRegisterProvider.notifier);
      await Future.delayed(const Duration(milliseconds: 50));

      notifier.addNewEntry('97');
      notifier.setActiveEntry('97');
      notifier.setSelectedSquadron('Mansur Ali');

      // Set Pre Due = 420.0
      await notifier.updateRoomPreDue('Room 3', 420.0);
      // Set Paid = 300.0
      await notifier.updateRoomPaid('Room 3', 300.0);

      // Record daily expense of 500.0
      final date = DateTime(2026, 9, 5);
      await notifier.recordRoomExpense(
        room: 'Room 3',
        amount: 500.0,
        date: date,
      );

      final summary = container.read(canteenRegisterProvider).getRoomMonthlySummary('97', 'Mansur Ali', 'Room 3', 2026, 9);

      expect(summary.preDue, 420.0);
      expect(summary.totalMonthlySpending, 500.0);
      expect(summary.grandTotal, 920.0); // 420 + 500
      expect(summary.paid, 300.0);
      expect(summary.netDue, 620.0); // 920 - 300
    });
  });
}
