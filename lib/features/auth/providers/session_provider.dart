import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/storage/token_storage.dart';
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
      name: 'Shanjid Ahmad',
      rank: 'Cpl',
      trade: 'E&I Fitter',
      role: CanteenConstants.roleNcoic,
      bdNo: 'BD/472770',
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

    // 1. Authenticate with backend server API
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.post(
        ApiEndpoints.login,
        data: {
          'loginId': cleanUser,
          'password': cleanPass,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final resData = response.data as Map<String, dynamic>;
        final data = resData['data'] as Map<String, dynamic>?;
        if (data != null) {
          final accessToken = data['accessToken'] as String?;
          final refreshToken = data['refreshToken'] as String?;
          final userJson = data['user'] as Map<String, dynamic>?;

          if (accessToken != null) {
            await ref.read(tokenStorageProvider).saveToken(accessToken);
          }
          if (refreshToken != null) {
            await ref.read(tokenStorageProvider).saveRefreshToken(refreshToken);
          }

          if (userJson != null) {
            final user = SessionUser.fromJson(userJson);
            try {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setString(_prefsKeySession, jsonEncode(user.toJson()));
            } catch (_) {}

            if (_disposed) return true;
            state = SessionState(isAuthenticated: true, user: user, isLoading: false);
            _syncActiveManager(user.role);
            return true;
          }
        }
      }
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 401) {
        if (!_disposed) {
          state = state.copyWith(
            isLoading: false,
            errorMessage: 'Invalid military credentials. Please check your username and password.',
          );
        }
        return false;
      }
      // If server unreachable or error, fallback to offline credentials
    }

    // 2. Offline fallback
    SessionUser? matchedUser;
    final userDigits = cleanUser.replaceAll(RegExp(r'[^0-9]'), '');
    final isNcoicLogin = cleanUser == 'ncoic' ||
        cleanUser == 'shanjid' ||
        userDigits == '472770' ||
        cleanUser == 'bd/472770' ||
        cleanUser == 'bd/ 472770';
    final isNcoicPass = cleanPass == 'ncoic123' ||
        cleanPass == 'NcoicPassword123' ||
        cleanPass == '472770' ||
        cleanPass == 'shanjid123';

    if (isNcoicLogin && isNcoicPass) {
      matchedUser = fixedAccounts[0];
    } else if (cleanUser == 'admin' && (cleanPass == 'admin123' || cleanPass == 'AdminPassword123')) {
      matchedUser = fixedAccounts.firstWhere((a) => a.role == 'ADMIN');
    }

    // Check locally enrolled operators in SharedPreferences
    if (matchedUser == null) {
      try {
        final prefs = await SharedPreferences.getInstance();
        final raw = prefs.getString('rts_canteen_operators_v2');
        if (raw != null) {
          final decoded = jsonDecode(raw) as List;
          for (final item in decoded) {
            final op = SessionUser.fromJson(item as Map<String, dynamic>);
            final opBdDigits = op.bdNo.replaceAll(RegExp(r'[^0-9]'), '');
            if ((op.username.toLowerCase() == cleanUser || (userDigits.isNotEmpty && userDigits == opBdDigits)) &&
                cleanPass.length >= 4) {
              matchedUser = op;
              break;
            }
          }
        }
      } catch (_) {}
    }

    if (matchedUser == null) {
      if (!_disposed) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Invalid military credentials. Try BD No 472770 or ncoic / ncoic123',
        );
      }
      return false;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKeySession, jsonEncode(matchedUser.toJson()));
    } catch (_) {}

    if (!_disposed) {
      state = SessionState(isAuthenticated: true, user: matchedUser, isLoading: false);
      _syncActiveManager(matchedUser.role);
    }
    return true;
  }

  Future<void> logout() async {
    try {
      await ref.read(tokenStorageProvider).clearAuth();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_prefsKeySession);
    } catch (_) {}
    if (!_disposed) {
      state = const SessionState(isAuthenticated: false, user: null, isLoading: false);
    }
  }
}
