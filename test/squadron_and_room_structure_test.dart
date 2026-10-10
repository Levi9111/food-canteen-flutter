import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:food_canteen/features/recruits_canteen/providers/canteen_structure_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Squadron & Room Dynamic Structure Tests', () {
    test('Initializes with default 4 BAF squadrons and 16 rooms each', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state = container.read(canteenStructureProvider);
      expect(state.squadrons.length, 4);
      expect(state.squadrons, contains('Sadruddin'));
      expect(state.squadrons, contains('Liakot Ali'));
      expect(state.squadrons, contains('Nurul Haque'));
      expect(state.squadrons, contains('Mansur Ali'));

      final rooms = state.getRoomsForSquadron('Sadruddin');
      expect(rooms.length, 16);
      expect(rooms.first, 'Room 1');
      expect(rooms.last, 'Room 16');
    });

    test('addRoom adds custom room (e.g. Room 17) to designated squadron', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(canteenStructureProvider.notifier);
      final added = await notifier.addRoom('Sadruddin', 'Room 17');
      expect(added, isTrue);

      final updatedState = container.read(canteenStructureProvider);
      final sadruddinRooms = updatedState.getRoomsForSquadron('Sadruddin');
      expect(sadruddinRooms.length, 17);
      expect(sadruddinRooms, contains('Room 17'));

      // Other squadrons remain unaffected
      final liakotRooms = updatedState.getRoomsForSquadron('Liakot Ali');
      expect(liakotRooms.length, 16);
      expect(liakotRooms.contains('Room 17'), isFalse);
    });

    test('addRoom rejects duplicate room names within the same squadron', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(canteenStructureProvider.notifier);
      final duplicate = await notifier.addRoom('Sadruddin', 'Room 1');
      expect(duplicate, isFalse);

      final state = container.read(canteenStructureProvider);
      expect(state.getRoomsForSquadron('Sadruddin').length, 16);
    });

    test('removeRoom removes specified room from squadron', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(canteenStructureProvider.notifier);
      final removed = await notifier.removeRoom('Sadruddin', 'Room 16');
      expect(removed, isTrue);

      final state = container.read(canteenStructureProvider);
      final rooms = state.getRoomsForSquadron('Sadruddin');
      expect(rooms.length, 15);
      expect(rooms.contains('Room 16'), isFalse);
    });

    test('updateSquadronName renames squadron and preserves its room mappings', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(canteenStructureProvider.notifier);

      // Add a custom room first
      await notifier.addRoom('Sadruddin', 'Room 17');

      // Rename squadron
      final renamed = await notifier.updateSquadronName('Sadruddin', 'Sher-e-Bangla');
      expect(renamed, isTrue);

      final state = container.read(canteenStructureProvider);
      expect(state.squadrons, contains('Sher-e-Bangla'));
      expect(state.squadrons.contains('Sadruddin'), isFalse);

      // Verify rooms migrated with custom additions
      final rooms = state.getRoomsForSquadron('Sher-e-Bangla');
      expect(rooms.length, 17);
      expect(rooms, contains('Room 17'));
    });

    test('updateSquadronName rejects renaming to an existing squadron', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(canteenStructureProvider.notifier);
      final conflict = await notifier.updateSquadronName('Sadruddin', 'Liakot Ali');
      expect(conflict, isFalse);

      final state = container.read(canteenStructureProvider);
      expect(state.squadrons, contains('Sadruddin'));
    });
  });
}
