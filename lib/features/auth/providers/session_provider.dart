import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../recruits_canteen/constants/canteen_constants.dart';
import '../../recruits_canteen/providers/canteen_register_provider.dart';
import '../../p_staff_canteen/providers/p_staff_register_provider.dart';
import '../models/session_user.dart';

class SessionState {
  final bool isAuthenticated;
  final SessionUser? user;
  final bool isLoading;
  final String? errorMessage;

  const SessionState({
    this.isAuthenticated = false,
    this.user,
    this.isLoading = false,
    this.errorMessage,
  });

  SessionState copyWith({
    bool? isAuthenticated,
    SessionUser? user,
    bool? isLoading,
    String? errorMessage,
  }) {
    return SessionState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

final sessionProvider = NotifierProvider<SessionNotifier, SessionState>(
  SessionNotifier.new,
);

class SessionNotifier extends Notifier<SessionState> {
  static const String _prefsKeySession = 'rts_canteen_session_v2';
  bool _disposed = false;

  static const List<SessionUser> fixedAccounts = [
    SessionUser(
      username: 'ncoic',
      name: 'Tariqul Islam',
      rank: 'Sgt',
      role: CanteenConstants.roleNcoic,
      bdNo: 'BD/48291',
    ),
    SessionUser(
      username: 'jcoic',
      name: 'Humayun Kabir',
      rank: 'MWO',
      role: CanteenConstants.roleJcoic,
      bdNo: 'BD/39102',
    ),
    SessionUser(
      username: 'admin',
      name: 'Officer Commanding',
      rank: 'Sqn Ldr',
      role: 'ADMIN',
      bdNo: 'BD/90001',
    ),
  ];

  @override
  SessionState build() {
    _disposed = false;
    ref.onDispose(() => _disposed = true);
    _restoreSession();
    return const SessionState(isLoading: true);
  }

  Future<void> _restoreSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_disposed) return;
      final jsonStr = prefs.getString(_prefsKeySession);
      if (jsonStr != null) {
        final decoded = jsonDecode(jsonStr) as Map<String, dynamic>;
        final user = SessionUser.fromJson(decoded);
        if (_disposed) return;
        state = SessionState(isAuthenticated: true, user: user, isLoading: false);
        _syncActiveManager(user.role);
        return;
      }
    } catch (_) {}
    if (!_disposed) {
      state = const SessionState(isAuthenticated: false, isLoading: false);
    }
  }

  void _syncActiveManager(String role) {
    if (_disposed) return;
    final managerRole = role == CanteenConstants.roleJcoic
        ? CanteenConstants.roleJcoic
        : CanteenConstants.roleNcoic;
    ref.read(canteenRegisterProvider.notifier).setActiveManager(managerRole);
    ref.read(pStaffRegisterProvider.notifier).setActiveManager(managerRole);
  }

  Future<bool> login({
    required String username,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final cleanUser = username.trim().toLowerCase();
    final cleanPass = password.trim();

    // Check fixed credentials
    SessionUser? matchedUser;
    if (cleanUser == 'ncoic' && (cleanPass == 'ncoic123' || cleanPass == 'NcoicPassword123')) {
      matchedUser = fixedAccounts[0];
    } else if (cleanUser == 'jcoic' && (cleanPass == 'jcoic123' || cleanPass == 'JcoicPassword123')) {
      matchedUser = fixedAccounts[1];
    } else if (cleanUser == 'admin' && (cleanPass == 'admin123' || cleanPass == 'AdminPassword123')) {
      matchedUser = fixedAccounts[2];
    }

    if (matchedUser == null) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Invalid military credentials. Try ncoic / ncoic123 or jcoic / jcoic123',
      );
      return false;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKeySession, jsonEncode(matchedUser.toJson()));
    } catch (_) {}

    state = SessionState(isAuthenticated: true, user: matchedUser, isLoading: false);
    _syncActiveManager(matchedUser.role);
    return true;
  }

  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_prefsKeySession);
    } catch (_) {}
    state = const SessionState(isAuthenticated: false, user: null, isLoading: false);
  }
}
