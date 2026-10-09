import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../models/session_user.dart';

class OperatorManagementState {
  final List<SessionUser> operators;
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;

  const OperatorManagementState({
    this.operators = const [],
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
  });

  bool get hasNcoic => operators.any((u) => u.role == 'NCOIC');
  bool get hasJcoic => operators.any((u) => u.role == 'JCOIC');
  bool get isFullyStaffed => hasNcoic && hasJcoic;
  String? get vacantRole {
    if (!hasNcoic) return 'NCOIC';
    if (!hasJcoic) return 'JCOIC';
    return null;
  }

  OperatorManagementState copyWith({
    List<SessionUser>? operators,
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
  }) {
    return OperatorManagementState(
      operators: operators ?? this.operators,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }
}

final operatorManagementProvider =
    NotifierProvider<OperatorManagementNotifier, OperatorManagementState>(
  OperatorManagementNotifier.new,
);

class OperatorManagementNotifier extends Notifier<OperatorManagementState> {
  static const String _prefsKeyOperators = 'rts_canteen_operators_v2';
  static const String _prefsKeyRemovedRoles = 'rts_canteen_removed_roles_v2';
  bool _disposed = false;

  static const List<SessionUser> defaultBaseline = [
    SessionUser(
      id: 'mock_ncoic',
      username: 'ncoic',
      name: 'Shanjid Ahmad',
      rank: 'Cpl',
      trade: 'E&I Fitter',
      role: 'NCOIC',
      bdNo: 'BD/472770',
    ),
  ];

  @override
  OperatorManagementState build() {
    _disposed = false;
    ref.onDispose(() => _disposed = true);
    _initAndRestore();
    return const OperatorManagementState(
      operators: defaultBaseline,
      isLoading: false,
    );
  }

  Future<void> _initAndRestore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_disposed) return;
      final raw = prefs.getString(_prefsKeyOperators);
      if (raw != null) {
        final decoded = jsonDecode(raw) as List;
        final list = decoded
            .map((e) => SessionUser.fromJson(e as Map<String, dynamic>))
            .where((u) => u.role == 'NCOIC' || u.role == 'JCOIC')
            .toList();
        if (!_disposed && list.isNotEmpty) {
          state = state.copyWith(operators: list);
        }
      }
    } catch (_) {}
  }

  Future<void> _saveLocalState(List<SessionUser> ops) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = ops.map((u) => u.toJson()).toList();
      await prefs.setString(_prefsKeyOperators, jsonEncode(jsonList));
    } catch (_) {}
  }

  Future<void> fetchOperators() async {
    state = state.copyWith(isLoading: true, errorMessage: null, successMessage: null);
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get(ApiEndpoints.users);
      if (_disposed) return;

      if (response.statusCode == 200 && response.data != null) {
        final resData = response.data as Map<String, dynamic>;
        final list = resData['data'] as List?;
        if (list != null) {
          final prefs = await SharedPreferences.getInstance();
          final removedRoles = prefs.getStringList(_prefsKeyRemovedRoles) ?? [];

          final users = list
              .map((u) => SessionUser.fromJson(u as Map<String, dynamic>))
              .where((u) =>
                  (u.role == 'NCOIC' || u.role == 'JCOIC') &&
                  !removedRoles.contains(u.role))
              .toList();

          // Ensure NCOIC Shanjid Ahmad is present if no NCOIC exists
          if (!users.any((u) => u.role == 'NCOIC')) {
            users.insert(0, defaultBaseline.first);
          }

          if (_disposed) return;
          state = state.copyWith(operators: users, isLoading: false);
          await _saveLocalState(users);
          return;
        }
      }
    } catch (e) {
      // Fallback: If offline or initial mock state
      if (_disposed) return;
    }

    if (!_disposed) {
      state = state.copyWith(
        operators: state.operators.isNotEmpty ? state.operators : defaultBaseline,
        isLoading: false,
      );
    }
  }

  Future<bool> enrollOperator({
    required String username,
    required String name,
    required String rank,
    required String bdNo,
    required String password,
    required String role,
    String? trade,
    String? phone,
  }) async {
    if (state.isFullyStaffed) {
      state = state.copyWith(
        errorMessage: 'Both NCOIC and JCOIC positions are already occupied. Maximum limit reached.',
      );
      return false;
    }

    if (role != 'NCOIC' && role != 'JCOIC') {
      state = state.copyWith(
        errorMessage: 'Only NCOIC or JCOIC role can be assigned.',
      );
      return false;
    }

    state = state.copyWith(isLoading: true, errorMessage: null, successMessage: null);

    // Clear any tombstone for this role
    try {
      final prefs = await SharedPreferences.getInstance();
      final removedRoles = prefs.getStringList(_prefsKeyRemovedRoles) ?? [];
      removedRoles.remove(role);
      await prefs.setStringList(_prefsKeyRemovedRoles, removedRoles);
    } catch (_) {}

    try {
      final dio = ref.read(dioProvider);
      final response = await dio.post(
        ApiEndpoints.users,
        data: {
          'username': username.trim().toLowerCase(),
          'name': name.trim(),
          'rank': rank,
          'bdNo': bdNo.trim().toUpperCase(),
          'password': password.trim(),
          'role': role,
          if (trade != null && trade.trim().isNotEmpty) 'trade': trade.trim(),
          if (phone != null && phone.trim().isNotEmpty) 'phone': phone.trim(),
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        await fetchOperators();
        state = state.copyWith(
          successMessage: 'New $role operator ($name) enrolled successfully.',
        );
        return true;
      }
    } catch (_) {
      // If server is offline, fallback to local registration
    }

    // Local fallback if offline
    final newOp = SessionUser(
      id: 'local_${DateTime.now().millisecondsSinceEpoch}',
      username: username.trim().toLowerCase(),
      name: name.trim(),
      rank: rank,
      role: role,
      bdNo: bdNo.trim().toUpperCase(),
      trade: trade?.trim(),
    );
    final updated = [...state.operators.where((u) => u.role != role), newOp];
    state = state.copyWith(
      operators: updated,
      isLoading: false,
      successMessage: 'Operator enrolled ($role: $name).',
    );
    await _saveLocalState(updated);
    return true;
  }

  Future<bool> removeOperator(String id) async {
    state = state.copyWith(isLoading: true, errorMessage: null, successMessage: null);

    // Identify target operator
    final target = state.operators.where((u) =>
        u.id == id ||
        u.username.toLowerCase() == id.toLowerCase() ||
        u.role == id).firstOrNull;

    if (target != null) {
      // Record role in removed roles so server fetch does not resurrect it
      try {
        final prefs = await SharedPreferences.getInstance();
        final removedRoles = prefs.getStringList(_prefsKeyRemovedRoles) ?? [];
        if (!removedRoles.contains(target.role)) {
          removedRoles.add(target.role);
          await prefs.setStringList(_prefsKeyRemovedRoles, removedRoles);
        }
      } catch (_) {}

      // If id is a valid Mongo ObjectId, attempt server deletion
      final isMongoId = target.id != null && RegExp(r'^[0-9a-fA-F]{24}$').hasMatch(target.id!);
      if (isMongoId) {
        try {
          final dio = ref.read(dioProvider);
          await dio.delete(ApiEndpoints.deleteUser(target.id!));
        } catch (_) {}
      }
    }

    // Immediate local removal
    final remaining = state.operators
        .where((u) =>
            u.id != id &&
            u.username.toLowerCase() != id.toLowerCase() &&
            u.role != id &&
            (target == null || u.role != target.role))
        .toList();

    state = state.copyWith(
      operators: remaining,
      isLoading: false,
      successMessage: '${target?.role ?? 'Operator'} appointment removed successfully.',
    );
    await _saveLocalState(remaining);
    return true;
  }
}
