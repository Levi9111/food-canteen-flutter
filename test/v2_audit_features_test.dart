import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:food_canteen/core/localization/locale_provider.dart';
import 'package:food_canteen/core/theme/theme_provider.dart';
import 'package:food_canteen/features/auth/providers/session_provider.dart';
import 'package:food_canteen/features/recruits_canteen/providers/canteen_structure_provider.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Canteen Structure & Per-Squadron Room Tests', () {
    test('Default structure initializes with 4 squadrons and 16 rooms each', () {
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

    test('Adding and removing squadrons works dynamically', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(canteenStructureProvider.notifier);

      final added = await notifier.addSquadron('Jamuna');
      expect(added, true);
      expect(container.read(canteenStructureProvider).squadrons, contains('Jamuna'));

      // Duplicate add fails
      final duplicate = await notifier.addSquadron('Jamuna');
      expect(duplicate, false);

      final removed = await notifier.removeSquadron('Jamuna');
      expect(removed, true);
      expect(container.read(canteenStructureProvider).squadrons.contains('Jamuna'), false);
    });

    test('Per-squadron room isolation: room added to one squadron is not in another', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(canteenStructureProvider.notifier);

      await notifier.addRoom('Sadruddin', 'Room 17');
      final sadruddinRooms = container.read(canteenStructureProvider).getRoomsForSquadron('Sadruddin');
      final liakotRooms = container.read(canteenStructureProvider).getRoomsForSquadron('Liakot Ali');

      expect(sadruddinRooms, contains('Room 17'));
      expect(liakotRooms.contains('Room 17'), false);
    });
  });

  group('Session & Role-Locking Tests', () {
    test('Fixed credentials login and locked role binding for NCOIC', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final sessionNotifier = container.read(sessionProvider.notifier);

      final success = await sessionNotifier.login(username: 'ncoic', password: 'ncoic123');
      expect(success, true);

      final session = container.read(sessionProvider);
      expect(session.isAuthenticated, true);
      expect(session.user?.role, 'NCOIC');
      expect(session.user?.name, 'Tariqul Islam');
      expect(session.user?.rank, 'Sgt');
    });

    test('Fixed credentials login and locked role binding for JCOIC', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final sessionNotifier = container.read(sessionProvider.notifier);

      final success = await sessionNotifier.login(username: 'jcoic', password: 'jcoic123');
      expect(success, true);

      final session = container.read(sessionProvider);
      expect(session.isAuthenticated, true);
      expect(session.user?.role, 'JCOIC');
      expect(session.user?.name, 'Humayun Kabir');
      expect(session.user?.rank, 'MWO');
    });

    test('Invalid credentials fail login and report error message', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final sessionNotifier = container.read(sessionProvider.notifier);

      final success = await sessionNotifier.login(username: 'fake_user', password: 'wrong_password');
      expect(success, false);

      final session = container.read(sessionProvider);
      expect(session.isAuthenticated, false);
      expect(session.errorMessage, isNotNull);
    });

    test('Logout clears session state', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final sessionNotifier = container.read(sessionProvider.notifier);
      await sessionNotifier.login(username: 'ncoic', password: 'ncoic123');
      expect(container.read(sessionProvider).isAuthenticated, true);

      await sessionNotifier.logout();
      expect(container.read(sessionProvider).isAuthenticated, false);
      expect(container.read(sessionProvider).user, isNull);
    });
  });

  group('Theme & Locale State Tests', () {
    test('ThemeModeNotifier toggles and sets theme mode', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(themeModeProvider.notifier);
      expect(container.read(themeModeProvider), ThemeMode.system);

      notifier.setThemeMode(ThemeMode.dark);
      expect(container.read(themeModeProvider), ThemeMode.dark);

      notifier.toggleTheme();
      expect(container.read(themeModeProvider), ThemeMode.light);
    });

    test('LocaleNotifier switches between English and Bengali UI translations', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final localeNotifier = container.read(localeProvider.notifier);
      expect(container.read(localeProvider), AppLanguage.english);

      // Verify English translation
      expect(AppTranslations.tr('app_title', AppLanguage.english), 'FOOD CANTEEN, RTS');
      expect(AppTranslations.tr('save_price', AppLanguage.english), 'SAVE PRICE IN BOOK');

      // Switch to Bengali
      await localeNotifier.setLanguage(AppLanguage.bengali);
      expect(container.read(localeProvider), AppLanguage.bengali);

      // Verify Bengali translation
      expect(AppTranslations.tr('app_title', AppLanguage.bengali), 'খাদ্য ক্যান্টিন, আরটিএস');
      expect(AppTranslations.tr('save_price', AppLanguage.bengali), 'খাতায় জমা করুন');
    });
  });
}
