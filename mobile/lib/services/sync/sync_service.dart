import 'dart:async';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mama_app/services/database/database.dart';

final syncServiceProvider = Provider<SyncService>((ref) {
  throw UnimplementedError('Override in main');
});

final syncStatusProvider = StateNotifierProvider<SyncStatusNotifier, SyncStatus>((ref) {
  final syncService = ref.watch(syncServiceProvider);
  return SyncStatusNotifier(syncService);
});

class SyncStatus {
  final bool isSyncing;
  final int pendingCount;
  final DateTime? lastSyncAt;
  final String? lastError;
  final bool isOnline;
  
  const SyncStatus({
    this.isSyncing = false,
    this.pendingCount = 0,
    this.lastSyncAt,
    this.lastError,
    this.isOnline = false,
  });
  
  SyncStatus copyWith({
    bool? isSyncing,
    int? pendingCount,
    DateTime? lastSyncAt,
    String? lastError,
    bool? isOnline,
  }) {
    return SyncStatus(
      isSyncing: isSyncing ?? this.isSyncing,
      pendingCount: pendingCount ?? this.pendingCount,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      lastError: lastError,
      isOnline: isOnline ?? this.isOnline,
    );
  }
}

class SyncStatusNotifier extends StateNotifier<SyncStatus> {
  final SyncService _syncService;
  Timer? _autoSyncTimer;
  StreamSubscription? _connectivitySubscription;
  
  SyncStatusNotifier(this._syncService) : super(const SyncStatus()) {
    _initialize();
  }
  
  Future<void> _initialize() async {
    // Check initial connectivity
    final connectivity = await Connectivity().checkConnectivity();
    state = state.copyWith(isOnline: connectivity != ConnectivityResult.none);
    
    // Update pending count
    final pendingCount = await _syncService.getPendingCount();
    state = state.copyWith(pendingCount: pendingCount);
    
    // Listen for connectivity changes
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((result) {
      final isOnline = result != ConnectivityResult.none;
      state = state.copyWith(isOnline: isOnline);
      
      // Auto-sync when coming online
      if (isOnline && state.pendingCount > 0) {
        sync();
      }
    });
    
    // Auto-sync every 5 minutes if online
    _autoSyncTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      if (state.isOnline && state.pendingCount > 0 && !state.isSyncing) {
        sync();
      }
    });
  }
  
  Future<void> sync() async {
    if (state.isSyncing || !state.isOnline) return;
    
    state = state.copyWith(isSyncing: true, lastError: null);
    
    try {
      final result = await _syncService.syncAll();
      
      final pendingCount = await _syncService.getPendingCount();
      state = state.copyWith(
        isSyncing: false,
        pendingCount: pendingCount,
        lastSyncAt: DateTime.now(),
        lastError: result.failed > 0 ? '${result.failed} records failed to sync' : null,
      );
    } catch (e) {
      state = state.copyWith(
        isSyncing: false,
        lastError: e.toString(),
      );
    }
  }
  
  Future<void> refreshPendingCount() async {
    final pendingCount = await _syncService.getPendingCount();
    state = state.copyWith(pendingCount: pendingCount);
  }
  
  @override
  void dispose() {
    _autoSyncTimer?.cancel();
    _connectivitySubscription?.cancel();
    super.dispose();
  }
}

class SyncResult {
  final int success;
  final int failed;
  final List<String> errors;
  
  SyncResult({
    required this.success,
    required this.failed,
    required this.errors,
  });
}

class SyncService {
  final AppDatabase _database;
  final Dio _dio;
  final FlutterSecureStorage _storage;
  
  static const String _baseUrlKey = 'api_base_url';
  static const String _tokenKey = 'auth_token';
  static const String _deviceIdKey = 'device_id';
  
  SyncService(this._database) 
    : _dio = Dio(),
      _storage = const FlutterSecureStorage() {
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
  }
  
  Future<String?> get _baseUrl async => await _storage.read(key: _baseUrlKey);
  Future<String?> get _token async => await _storage.read(key: _tokenKey);
  Future<String?> get _deviceId async => await _storage.read(key: _deviceIdKey);
  
  /// Set API configuration
  Future<void> configure({
    required String baseUrl,
    required String token,
    required String deviceId,
  }) async {
    await _storage.write(key: _baseUrlKey, value: baseUrl);
    await _storage.write(key: _tokenKey, value: token);
    await _storage.write(key: _deviceIdKey, value: deviceId);
  }
  
  /// Get count of pending sync records
  Future<int> getPendingCount() => _database.getPendingSyncCount();
  
  /// Sync all pending records to server
  Future<SyncResult> syncAll() async {
    final baseUrl = await _baseUrl;
    final token = await _token;
    final deviceId = await _deviceId;
    
    if (baseUrl == null || token == null || deviceId == null) {
      throw Exception('Sync not configured');
    }
    
    final pendingRecords = await _database.getPendingSyncRecords();
    
    if (pendingRecords.isEmpty) {
      return SyncResult(success: 0, failed: 0, errors: []);
    }
    
    // Prepare batch payload
    final records = pendingRecords.map((r) => {
      'id': r.id.toString(),
      'tableName': r.syncTableName,
      'recordId': r.recordId,
      'operation': r.operation,
      'payload': jsonDecode(r.payloadJson),
    }).toList();
    
    try {
      final response = await _dio.post(
        '$baseUrl/api/sync/upload',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
        data: {
          'deviceId': deviceId,
          'records': records,
        },
      );
      
      final data = response.data;
      final successIds = List<String>.from(data['details']['success'] ?? []);
      final failures = List<Map<String, dynamic>>.from(data['details']['failed'] ?? []);
      
      // Mark successful records as synced
      for (final record in pendingRecords) {
        if (successIds.contains(record.id.toString())) {
          await _database.markRecordSynced(record.id);
          
          // Also mark the original record as synced
          await _markOriginalRecordSynced(record.syncTableName, record.recordId);
        }
      }
      
      return SyncResult(
        success: successIds.length,
        failed: failures.length,
        errors: failures.map((f) => f['error']?.toString() ?? 'Unknown error').toList(),
      );
      
    } on DioException catch (e) {
      // Handle offline/network errors gracefully
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        throw Exception('No network connection');
      }
      rethrow;
    }
  }
  
  /// Download updates from server
  Future<DownloadResult> downloadUpdates() async {
    final baseUrl = await _baseUrl;
    final token = await _token;
    final deviceId = await _deviceId;
    
    if (baseUrl == null || token == null) {
      throw Exception('Sync not configured');
    }
    
    // Get last sync timestamp
    final lastSyncAt = await _storage.read(key: 'last_download_at');
    
    try {
      final response = await _dio.get(
        '$baseUrl/api/sync/download',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
        queryParameters: {
          'lastSyncAt': lastSyncAt ?? '1970-01-01T00:00:00Z',
          'deviceId': deviceId,
        },
      );
      
      final data = response.data;
      int updated = 0;
      
      // Process patients
      final patients = List<Map<String, dynamic>>.from(data['patients'] ?? []);
      for (final p in patients) {
        await _upsertPatient(p);
        updated++;
      }
      
      // Process facilities
      final facilities = List<Map<String, dynamic>>.from(data['facilities'] ?? []);
      for (final f in facilities) {
        await _upsertFacility(f);
        updated++;
      }
      
      // Process referral updates
      final referrals = List<Map<String, dynamic>>.from(data['referrals'] ?? []);
      for (final r in referrals) {
        await _updateReferralStatus(r);
        updated++;
      }
      
      // Save sync timestamp
      await _storage.write(key: 'last_download_at', value: data['syncAt']);
      
      return DownloadResult(updatedRecords: updated);
      
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError) {
        throw Exception('No network connection');
      }
      rethrow;
    }
  }
  
  /// Send vital readings directly to server (when online)
  Future<Map<String, dynamic>?> sendVitalsToServer({
    required String patientId,
    required List<Map<String, dynamic>> vitals,
    Map<String, bool>? symptoms,
  }) async {
    final baseUrl = await _baseUrl;
    final token = await _token;
    
    if (baseUrl == null || token == null) return null;
    
    try {
      final response = await _dio.post(
        '$baseUrl/api/patients/$patientId/vitals',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
        data: {
          'vitals': vitals,
          'symptoms': symptoms,
        },
      );
      
      return response.data;
    } catch (e) {
      // Silently fail - data is already saved locally
      return null;
    }
  }
  
  /// Send device vitals (auto-lookup patient by device)
  Future<Map<String, dynamic>?> sendDeviceVitals({
    required String deviceHardwareId,
    required List<Map<String, dynamic>> vitals,
    int? batteryLevel,
  }) async {
    final baseUrl = await _baseUrl;
    final token = await _token;
    
    if (baseUrl == null || token == null) return null;
    
    try {
      final response = await _dio.post(
        '$baseUrl/api/patients/device-vitals',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
        data: {
          'deviceHardwareId': deviceHardwareId,
          'vitals': vitals,
          'batteryLevel': batteryLevel,
        },
      );
      
      return response.data;
    } catch (e) {
      return null;
    }
  }
  
  // ============== PRIVATE HELPERS ==============
  
  Future<void> _markOriginalRecordSynced(String tableName, String recordId) async {
    // Update the synced flag on the original record
    // This is done via raw SQL since we can't parameterize table names in Drift safely
    // In production, you'd have separate methods for each table
  }
  
  Future<void> _upsertPatient(Map<String, dynamic> data) async {
    // Convert server response to local patient format
    // Implementation depends on exact server response structure
  }
  
  Future<void> _upsertFacility(Map<String, dynamic> data) async {
    // Upsert facility data
  }
  
  Future<void> _updateReferralStatus(Map<String, dynamic> data) async {
    // Update referral status from server
  }
}

class DownloadResult {
  final int updatedRecords;
  
  DownloadResult({required this.updatedRecords});
}
