import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/api_exceptions.dart';
import '../../../core/storage/token_storage.dart';
import '../models/auth_state.dart';
import '../models/user_model.dart';

final authNotifierProvider =
    NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    Future.microtask(() => checkInitialAuth());
    return const AuthState();
  }

  ApiClient get _apiClient => ref.read(apiClientProvider);
  TokenStorage get _tokenStorage => ref.read(tokenStorageProvider);

  Future<void> checkInitialAuth() async {
    final hasToken = await _tokenStorage.hasToken();
    if (!hasToken) {
      state = state.copyWith(status: AuthStatus.unauthenticated);
      return;
    }

    final token = await _tokenStorage.getToken();
    final cachedUserMap = await _tokenStorage.getUserData();

    UserModel? user;
    if (cachedUserMap != null) {
      user = UserModel.fromJson(cachedUserMap);
    }

    state = state.copyWith(
      status: AuthStatus.authenticated,
      token: token,
      user: user,
    );

    await fetchProfile();
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);

    try {
      final response = await _apiClient.post(
        ApiEndpoints.login,
        data: {'email': email, 'password': password},
      );

      final data = response['data'];
      final accessToken = data['accessToken'] as String;
      final refreshToken = data['refreshToken'] as String?;
      final userMap = data['user'] as Map<String, dynamic>;

      await _tokenStorage.saveToken(accessToken);
      if (refreshToken != null) {
        await _tokenStorage.saveRefreshToken(refreshToken);
      }
      await _tokenStorage.saveUserData(userMap);

      final user = UserModel(
        id: userMap['userId']?.toString() ?? '',
        email: userMap['email']?.toString() ?? '',
        name: userMap['name']?.toString() ?? userMap['email']?.toString() ?? '',
        role: userMap['role']?.toString() ?? 'USER',
      );

      state = state.copyWith(
        status: AuthStatus.authenticated,
        token: accessToken,
        user: user,
      );
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.message,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'An unexpected error occurred during login.',
      );
      return false;
    }
  }

  Future<void> fetchProfile() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.profile);
      if (response['data'] != null) {
        final profileData = response['data'] as Map<String, dynamic>;
        if (state.user != null) {
          final updatedUser = state.user!.copyWith(
            id: profileData['id']?.toString(),
            role: profileData['role']?.toString(),
          );
          state = state.copyWith(user: updatedUser);
        }
      }
    } catch (_) {
      // Non-critical profile refresh error ignored
    }
  }

  Future<void> logout() async {
    await _tokenStorage.clearAuth();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }
}
