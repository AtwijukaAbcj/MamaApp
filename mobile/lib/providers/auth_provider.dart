import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';

// Auth state
final authStateProvider = FutureProvider<User?>((ref) async {
  final storage = const FlutterSecureStorage();
  final token = await storage.read(key: 'auth_token');
  final userId = await storage.read(key: 'user_id');
  final userName = await storage.read(key: 'user_name');
  final userRole = await storage.read(key: 'user_role');
  
  if (token == null || userId == null) return null;
  
  return User(
    id: userId,
    name: userName ?? 'Health Worker',
    role: userRole ?? 'health_worker',
    token: token,
  );
});

// Auth actions
final authActionsProvider = Provider<AuthActions>((ref) {
  return AuthActions(ref);
});

class User {
  final String id;
  final String name;
  final String role;
  final String token;
  final String? facilityId;
  final String? regionId;
  
  User({
    required this.id,
    required this.name,
    required this.role,
    required this.token,
    this.facilityId,
    this.regionId,
  });
}

class AuthActions {
  final Ref _ref;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final Dio _dio = Dio();
  
  AuthActions(this._ref);
  
  Future<void> configure(String baseUrl) async {
    await _storage.write(key: 'api_base_url', value: baseUrl);
  }
  
  Future<LoginResult> login({
    required String phone,
    required String pin,
  }) async {
    final baseUrl = await _storage.read(key: 'api_base_url');
    if (baseUrl == null) {
      return LoginResult.error('Server not configured');
    }
    
    try {
      final response = await _dio.post(
        '$baseUrl/api/auth/login',
        data: {
          'phone': phone,
          'pin': pin,
        },
      );
      
      final data = response.data;
      
      // Store credentials
      await _storage.write(key: 'auth_token', value: data['token']);
      await _storage.write(key: 'user_id', value: data['user']['id']);
      await _storage.write(key: 'user_name', value: data['user']['fullName']);
      await _storage.write(key: 'user_role', value: data['user']['role']);
      
      // Generate device ID if not exists
      String? deviceId = await _storage.read(key: 'device_id');
      if (deviceId == null) {
        deviceId = 'mobile_${DateTime.now().millisecondsSinceEpoch}';
        await _storage.write(key: 'device_id', value: deviceId);
      }
      
      // Refresh auth state
      _ref.invalidate(authStateProvider);
      
      return LoginResult.success();
      
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        return LoginResult.error('Invalid phone or PIN');
      }
      return LoginResult.error('Connection failed. Check your network.');
    }
  }
  
  Future<void> logout() async {
    await _storage.delete(key: 'auth_token');
    await _storage.delete(key: 'user_id');
    await _storage.delete(key: 'user_name');
    await _storage.delete(key: 'user_role');
    
    _ref.invalidate(authStateProvider);
  }
  
  Future<bool> checkAuth() async {
    final token = await _storage.read(key: 'auth_token');
    return token != null;
  }
}

class LoginResult {
  final bool success;
  final String? error;
  
  LoginResult._({required this.success, this.error});
  
  factory LoginResult.success() => LoginResult._(success: true);
  factory LoginResult.error(String message) => LoginResult._(success: false, error: message);
}
