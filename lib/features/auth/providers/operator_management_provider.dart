import 'package:dio/dio.dart';
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
      name: 'Tariqul Islam',
      rank: 'Sgt',
      role: 'NCOIC',
      bdNo: 'BD/48291',
    ),
    SessionUser(
      id: 'mock_jcoic',
      username: 'jcoic',
      name: 'Humayun Kabir',
      rank: 'MWO',
      role: 'JCOIC',
      bdNo: 'BD/39102',
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
      // Default initial baseline if server offline
      final baseline = [
        const SessionUser(
          id: 'mock_ncoic',
          username: 'ncoic',
          name: 'Tariqul Islam',
          rank: 'Sgt',
          role: 'NCOIC',
          bdNo: 'BD/48291',
        ),
        const SessionUser(
          id: 'mock_jcoic',
          username: 'jcoic',
          name: 'Humayun Kabir',
          rank: 'MWO',
          role: 'JCOIC',
          bdNo: 'BD/39102',
        ),
      ];
      state = state.copyWith(
        operators: state.operators.isNotEmpty ? state.operators : baseline,
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
          if (phone != null && phone.trim().isNotEmpty) 'phone': phone.trim(),
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        await fetchOperators();
        state = state.copyWith(
          successMessage: 'New $role operator ($name) enrolled successfully into database.',
        );
        return true;
      }
    } catch (e) {
      String msg = 'Failed to enroll operator.';
      if (e is DioException && e.response?.data is Map<String, dynamic>) {
        final data = e.response!.data as Map<String, dynamic>;
        msg = data['message']?.toString() ?? msg;
      }
      state = state.copyWith(isLoading: false, errorMessage: msg);
      return false;
    }

    // Local fallback if offline
    final newOp = SessionUser(
      id: 'local_${DateTime.now().millisecondsSinceEpoch}',
      username: username.trim().toLowerCase(),
      name: name.trim(),
      rank: rank,
      role: role,
      bdNo: bdNo.trim().toUpperCase(),
    );
    state = state.copyWith(
      operators: [...state.operators, newOp],
      isLoading: false,
      successMessage: 'Operator enrolled locally ($role).',
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
          successMessage: 'Operator removed successfully from database.',
        );
        return true;
      }
    } catch (e) {
      String msg = 'Failed to remove operator.';
      if (e is DioException && e.response?.data is Map<String, dynamic>) {
        final data = e.response!.data as Map<String, dynamic>;
        msg = data['message']?.toString() ?? msg;
      }
      state = state.copyWith(isLoading: false, errorMessage: msg);
      return false;
    }

    // Local fallback if offline
    state = state.copyWith(
      operators: state.operators.where((u) => u.id != id).toList(),
      isLoading: false,
      successMessage: 'Operator removed.',
    );
    return true;
  }
}
