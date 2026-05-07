import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../data/services/api_service.dart';
import '../core/constants/app_constants.dart';

// ── Auth State ────────────────────────────────────────────────────────────────

class AuthState {
  final bool isAuthenticated;
  final bool isAdmin;
  final String? token;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.isAuthenticated = false,
    this.isAdmin = false,
    this.token,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isAdmin,
    String? token,
    bool? isLoading,
    String? error,
  }) =>
      AuthState(
        isAuthenticated: isAuthenticated ?? this.isAuthenticated,
        isAdmin: isAdmin ?? this.isAdmin,
        token: token ?? this.token,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );
}

// ── Notifier ──────────────────────────────────────────────────────────────────

class AuthNotifier extends Notifier<AuthState> {
  static const _storage = FlutterSecureStorage();

  @override
  AuthState build() {
    _restoreSession();
    return const AuthState();
  }

  Future<void> _restoreSession() async {
    final token = await _storage.read(key: AppConstants.tokenKey);
    if (token != null && !JwtDecoder.isExpired(token)) {
      final payload = JwtDecoder.decode(token);
      final role = (payload['authorities'] as List?)?.first?.toString() ?? '';
      state = AuthState(
        isAuthenticated: true,
        isAdmin: role.contains('ADMIN'),
        token: token,
      );
    }
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final api = ref.read(apiServiceProvider);
      final token = await api.login(email, password);
      await _persist(token);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _message(e));
      return false;
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phone,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final api = ref.read(apiServiceProvider);
      final token = await api.register(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        phone: phone,
      );
      await _persist(token);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _message(e));
      return false;
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: AppConstants.tokenKey);
    state = const AuthState();
  }

  Future<void> _persist(String token) async {
    await _storage.write(key: AppConstants.tokenKey, value: token);
    final payload = JwtDecoder.decode(token);
    final role = (payload['authorities'] as List?)?.first?.toString() ?? '';
    state = AuthState(
      isAuthenticated: true,
      isAdmin: role.contains('ADMIN'),
      token: token,
    );
  }

  String _message(Object e) {
    if (e is Exception) return e.toString().replaceAll('Exception: ', '');
    return e.toString();
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
