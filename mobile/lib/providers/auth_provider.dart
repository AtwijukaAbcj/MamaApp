import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';

// User types
enum UserType { healthWorker, patient }

// Auth state - now supports both health workers and patients
final authStateProvider = FutureProvider<AppUser?>((ref) async {
  final storage = const FlutterSecureStorage();
  final token = await storage.read(key: 'auth_token');
  final userId = await storage.read(key: 'user_id');
  final userName = await storage.read(key: 'user_name');
  final userRole = await storage.read(key: 'user_role');
  final userTypeStr = await storage.read(key: 'user_type');
  
  if (token == null || userId == null) return null;
  
  final userType = userTypeStr == 'patient' ? UserType.patient : UserType.healthWorker;
  
  return AppUser(
    id: userId,
    name: userName ?? 'User',
    role: userRole ?? 'health_worker',
    token: token,
    userType: userType,
  );
});

// Auth actions
final authActionsProvider = Provider<AuthActions>((ref) {
  return AuthActions(ref);
});

class AppUser {
  final String id;
  final String name;
  final String role;
  final String token;
  final UserType userType;
  final String? facilityId;
  final String? regionId;
  // Patient-specific fields
  final bool? isPregnant;
  final String? expectedDeliveryDate;
  final int? gestationalWeeks;
  final HealthWorkerInfo? healthWorker;
  
  AppUser({
    required this.id,
    required this.name,
    required this.role,
    required this.token,
    required this.userType,
    this.facilityId,
    this.regionId,
    this.isPregnant,
    this.expectedDeliveryDate,
    this.gestationalWeeks,
    this.healthWorker,
  });
  
  bool get isPatient => userType == UserType.patient;
  bool get isHealthWorker => userType == UserType.healthWorker;
}

class HealthWorkerInfo {
  final String name;
  final String phone;
  
  HealthWorkerInfo({required this.name, required this.phone});
}

// Alias for backwards compatibility
typedef User = AppUser;

class AuthActions {
  final Ref _ref;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final Dio _dio = Dio();
  
  AuthActions(this._ref);
  
  Future<void> configure(String baseUrl) async {
    await _storage.write(key: 'api_base_url', value: baseUrl);
  }
  
  Future<String?> getBaseUrl() async {
    return await _storage.read(key: 'api_base_url');
  }
  
  Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }
  
  /// Login as health worker
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
      await _storage.write(key: 'user_type', value: 'health_worker');
      
      // Generate device ID if not exists
      String? deviceId = await _storage.read(key: 'device_id');
      if (deviceId == null) {
        deviceId = 'mobile_${DateTime.now().millisecondsSinceEpoch}';
        await _storage.write(key: 'device_id', value: deviceId);
      }
      
      // Refresh auth state
      _ref.invalidate(authStateProvider);
      
      return LoginResult.success(userType: UserType.healthWorker);
      
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        return LoginResult.error('Invalid phone or PIN');
      }
      return LoginResult.error('Connection failed. Check your network.');
    }
  }
  
  /// Login as patient
  Future<LoginResult> loginAsPatient({
    required String phone,
    required String pin,
  }) async {
    final baseUrl = await _storage.read(key: 'api_base_url');
    if (baseUrl == null) {
      return LoginResult.error('Server not configured');
    }
    
    try {
      final response = await _dio.post(
        '$baseUrl/api/patient/login',
        data: {
          'phone': phone,
          'pin': pin,
        },
      );
      
      final data = response.data;
      final patient = data['patient'];
      
      // Store credentials
      await _storage.write(key: 'auth_token', value: data['token']);
      await _storage.write(key: 'user_id', value: patient['id']);
      await _storage.write(key: 'user_name', value: patient['fullName']);
      await _storage.write(key: 'user_role', value: 'patient');
      await _storage.write(key: 'user_type', value: 'patient');
      
      // Store patient-specific data
      if (patient['isPregnant'] == true) {
        await _storage.write(key: 'is_pregnant', value: 'true');
      }
      if (patient['expectedDeliveryDate'] != null) {
        await _storage.write(key: 'edd', value: patient['expectedDeliveryDate']);
      }
      if (patient['healthWorker'] != null) {
        await _storage.write(key: 'hw_name', value: patient['healthWorker']['name']);
        await _storage.write(key: 'hw_phone', value: patient['healthWorker']['phone']);
      }
      
      // Refresh auth state
      _ref.invalidate(authStateProvider);
      
      return LoginResult.success(userType: UserType.patient);
      
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        return LoginResult.error('Invalid phone or PIN');
      }
      return LoginResult.error('Connection failed. Check your network.');
    }
  }
  
  /// Register as patient
  Future<LoginResult> registerAsPatient({
    required String phone,
    required String pin,
    required String fullName,
    String? dateOfBirth,
  }) async {
    final baseUrl = await _storage.read(key: 'api_base_url');
    if (baseUrl == null) {
      return LoginResult.error('Server not configured');
    }
    
    try {
      final response = await _dio.post(
        '$baseUrl/api/patient/register',
        data: {
          'phone': phone,
          'pin': pin,
          'fullName': fullName,
          if (dateOfBirth != null) 'dateOfBirth': dateOfBirth,
        },
      );
      
      final data = response.data;
      final patient = data['patient'];
      
      // Store credentials
      await _storage.write(key: 'auth_token', value: data['token']);
      await _storage.write(key: 'user_id', value: patient['id']);
      await _storage.write(key: 'user_name', value: patient['fullName']);
      await _storage.write(key: 'user_role', value: 'patient');
      await _storage.write(key: 'user_type', value: 'patient');
      
      // Refresh auth state
      _ref.invalidate(authStateProvider);
      
      return LoginResult.success(userType: UserType.patient);
      
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        return LoginResult.error('Phone number already registered');
      }
      return LoginResult.error('Registration failed. Please try again.');
    }
  }
  
  Future<void> logout() async {
    await _storage.delete(key: 'auth_token');
    await _storage.delete(key: 'user_id');
    await _storage.delete(key: 'user_name');
    await _storage.delete(key: 'user_role');
    await _storage.delete(key: 'user_type');
    await _storage.delete(key: 'is_pregnant');
    await _storage.delete(key: 'edd');
    await _storage.delete(key: 'hw_name');
    await _storage.delete(key: 'hw_phone');
    
    _ref.invalidate(authStateProvider);
  }
  
  Future<bool> checkAuth() async {
    final token = await _storage.read(key: 'auth_token');
    return token != null;
  }
  
  Future<UserType?> getUserType() async {
    final type = await _storage.read(key: 'user_type');
    if (type == 'patient') return UserType.patient;
    if (type == 'health_worker') return UserType.healthWorker;
    return null;
  }
}

class LoginResult {
  final bool success;
  final String? error;
  final UserType? userType;
  
  LoginResult._({required this.success, this.error, this.userType});
  
  factory LoginResult.success({UserType? userType}) => 
    LoginResult._(success: true, userType: userType);
  factory LoginResult.error(String message) => 
    LoginResult._(success: false, error: message);
}
