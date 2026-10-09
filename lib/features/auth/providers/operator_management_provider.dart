import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    return const OperatorManagementState(
      operators: defaultBaseline,
      isLoading: false,
    );
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
          final users = list
              .map((u) => SessionUser.fromJson(u as Map<String, dynamic>))
              .where((u) => u.role == 'NCOIC' || u.role == 'JCOIC')
              .toList();

          if (_disposed) return;
          state = state.copyWith(operators: users, isLoading: false);
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
    state = state.copyWith(
      operators: [...state.operators, newOp],
      isLoading: false,
      successMessage: 'Operator enrolled ($role: $name).',
    );
    return true;
  }

  Future<bool> removeOperator(String id) async {
    state = state.copyWith(isLoading: true, errorMessage: null, successMessage: null);
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.delete(ApiEndpoints.deleteUser(id));

      if (response.statusCode == 200) {
        await fetchOperators();
        state = state.copyWith(
          successMessage: 'Operator removed successfully.',
        );
        return true;
      }
    } catch (_) {
      // If server is offline or user was mock, gracefully fallback to local removal
    }

    // Local fallback removal
    final remaining = state.operators
        .where((u) => u.id != id && u.username.toLowerCase() != id.toLowerCase() && u.role != id)
        .toList();
    state = state.copyWith(
      operators: remaining,
      isLoading: false,
      successMessage: 'Operator removed successfully.',
    );
    return true;
  }
}
