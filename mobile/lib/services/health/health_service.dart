import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health/health.dart';
import 'package:mama_app/services/database/database.dart';
import 'package:mama_app/services/ble/ble_service.dart';

/// Health Service for Apple HealthKit / Apple Watch integration
/// Reads vital signs data collected by Apple Watch

final healthServiceProvider = Provider<HealthService>((ref) {
  final database = ref.watch(databaseProvider);
  return HealthService(database);
});

final healthAvailableProvider = FutureProvider<bool>((ref) async {
  final healthService = ref.watch(healthServiceProvider);
  return healthService.isAvailable();
});

class HealthService {
  final AppDatabase _database;
  final Health _health = Health();
  
  // Data types we want from Apple Watch
  static const List<HealthDataType> _types = [
    HealthDataType.HEART_RATE,
    HealthDataType.BLOOD_OXYGEN,
    HealthDataType.BLOOD_PRESSURE_SYSTOLIC,
    HealthDataType.BLOOD_PRESSURE_DIASTOLIC,
    HealthDataType.BODY_TEMPERATURE,
    HealthDataType.STEPS,
    HealthDataType.SLEEP_ASLEEP,
    HealthDataType.SLEEP_AWAKE,
  ];
  
  HealthService(this._database);
  
  /// Check if HealthKit is available on this device
  Future<bool> isAvailable() async {
    try {
      return await _health.hasPermissions(_types) ?? false;
    } catch (e) {
      return false;
    }
  }
  
  /// Request HealthKit permissions
  Future<bool> requestPermissions() async {
    try {
      // Request health permissions
      final healthPerms = await _health.requestAuthorization(
        _types,
        permissions: _types.map((_) => HealthDataAccess.READ).toList(),
      );
      
      return healthPerms;
    } catch (e) {
      return false;
    }
  }
  
  /// Fetch recent health data from Apple Watch / HealthKit
  Future<List<VitalReading>> fetchRecentReadings({
    Duration lookback = const Duration(hours: 24),
  }) async {
    final readings = <VitalReading>[];
    final now = DateTime.now();
    final startTime = now.subtract(lookback);
    
    try {
      // Get data from HealthKit
      final healthData = await _health.getHealthDataFromTypes(
        types: _types,
        startTime: startTime,
        endTime: now,
      );
      
      // Remove duplicates
      final uniqueData = _health.removeDuplicates(healthData);
      
      // Convert to our VitalReading format
      for (final data in uniqueData) {
        final reading = _convertToVitalReading(data);
        if (reading != null) {
          readings.add(reading);
        }
      }
      
    } catch (e) {
      // HealthKit not available or permission denied
    }
    
    return readings;
  }
  
  /// Fetch the latest heart rate from Apple Watch
  Future<double?> getLatestHeartRate() async {
    try {
      final now = DateTime.now();
      final data = await _health.getHealthDataFromTypes(
        types: [HealthDataType.HEART_RATE],
        startTime: now.subtract(const Duration(minutes: 30)),
        endTime: now,
      );
      
      if (data.isNotEmpty) {
        final latest = data.last;
        return (latest.value as NumericHealthValue).numericValue.toDouble();
      }
    } catch (e) {
      // Ignore
    }
    return null;
  }
  
  /// Fetch the latest SpO2 from Apple Watch
  Future<double?> getLatestSpO2() async {
    try {
      final now = DateTime.now();
      final data = await _health.getHealthDataFromTypes(
        types: [HealthDataType.BLOOD_OXYGEN],
        startTime: now.subtract(const Duration(hours: 2)),
        endTime: now,
      );
      
      if (data.isNotEmpty) {
        final latest = data.last;
        // SpO2 is stored as a percentage (0-1), convert to 0-100
        final value = (latest.value as NumericHealthValue).numericValue.toDouble();
        return value > 1 ? value : value * 100;
      }
    } catch (e) {
      // Ignore
    }
    return null;
  }
  
  /// Fetch blood pressure readings
  Future<Map<String, double>?> getLatestBloodPressure() async {
    try {
      final now = DateTime.now();
      
      final systolicData = await _health.getHealthDataFromTypes(
        types: [HealthDataType.BLOOD_PRESSURE_SYSTOLIC],
        startTime: now.subtract(const Duration(hours: 4)),
        endTime: now,
      );
      
      final diastolicData = await _health.getHealthDataFromTypes(
        types: [HealthDataType.BLOOD_PRESSURE_DIASTOLIC],
        startTime: now.subtract(const Duration(hours: 4)),
        endTime: now,
      );
      
      if (systolicData.isNotEmpty && diastolicData.isNotEmpty) {
        return {
          'systolic': (systolicData.last.value as NumericHealthValue).numericValue.toDouble(),
          'diastolic': (diastolicData.last.value as NumericHealthValue).numericValue.toDouble(),
        };
      }
    } catch (e) {
      // Ignore
    }
    return null;
  }
  
  /// Get sleep data summary (for maternal fatigue assessment)
  Future<Map<String, double>?> getSleepSummary({int days = 7}) async {
    try {
      final now = DateTime.now();
      final startTime = now.subtract(Duration(days: days));
      
      final sleepData = await _health.getHealthDataFromTypes(
        types: [HealthDataType.SLEEP_ASLEEP],
        startTime: startTime,
        endTime: now,
      );
      
      if (sleepData.isNotEmpty) {
        double totalMinutes = 0;
        for (final data in sleepData) {
          totalMinutes += (data.value as NumericHealthValue).numericValue.toDouble();
        }
        
        return {
          'totalHours': totalMinutes / 60,
          'avgHoursPerNight': (totalMinutes / 60) / days,
        };
      }
    } catch (e) {
      // Ignore
    }
    return null;
  }
  
  VitalReading? _convertToVitalReading(HealthDataPoint data) {
    final numValue = data.value as NumericHealthValue;
    final value = numValue.numericValue.toDouble();
    
    switch (data.type) {
      case HealthDataType.HEART_RATE:
        return VitalReading(
          vitalType: 'heart_rate',
          values: {'heartRate': value},
          recordedAt: data.dateFrom,
          deviceName: 'Apple Watch',
          dangerLevel: _assessHeartRateDanger(value),
        );
        
      case HealthDataType.BLOOD_OXYGEN:
        final spo2 = value > 1 ? value : value * 100;
        return VitalReading(
          vitalType: 'spo2',
          values: {'spo2': spo2},
          recordedAt: data.dateFrom,
          deviceName: 'Apple Watch',
          dangerLevel: _assessSpO2Danger(spo2),
        );
        
      case HealthDataType.BODY_TEMPERATURE:
        return VitalReading(
          vitalType: 'temp',
          values: {'temperature': value},
          recordedAt: data.dateFrom,
          deviceName: 'Apple Watch',
          dangerLevel: _assessTempDanger(value),
        );
        
      default:
        return null;
    }
  }
  
  String _assessHeartRateDanger(double hr) {
    if (hr > 120 || hr < 50) return 'danger';
    if (hr > 100 || hr < 60) return 'warning';
    return 'normal';
  }
  
  String _assessSpO2Danger(double spo2) {
    if (spo2 < 90) return 'danger';
    if (spo2 < 95) return 'warning';
    return 'normal';
  }
  
  String _assessTempDanger(double temp) {
    // Assuming Celsius
    if (temp > 38.5 || temp < 35) return 'danger';
    if (temp > 37.8 || temp < 36) return 'warning';
    return 'normal';
  }
  
  /// Fetch recent vitals formatted for server submission
  /// Returns a list of maps ready to be sent to /api/patient/vitals/submit
  Future<List<Map<String, dynamic>>> fetchRecentVitals() async {
    final vitals = <Map<String, dynamic>>[];
    
    try {
      // Get heart rate
      final heartRate = await getLatestHeartRate();
      if (heartRate != null) {
        vitals.add({
          'vitalType': 'heart_rate',
          'values': {'heartRate': heartRate},
          'source': 'apple_watch',
          'deviceName': 'Apple Watch',
        });
      }
      
      // Get SpO2
      final spo2 = await getLatestSpO2();
      if (spo2 != null) {
        vitals.add({
          'vitalType': 'spo2',
          'values': {'spo2': spo2},
          'source': 'apple_watch',
          'deviceName': 'Apple Watch',
        });
      }
      
      // Get Blood Pressure (if available from paired BLE device)
      final bp = await getLatestBloodPressure();
      if (bp != null) {
        vitals.add({
          'vitalType': 'bp',
          'values': bp,
          'source': 'apple_watch',
          'deviceName': 'Apple Watch',
        });
      }
      
    } catch (e) {
      // HealthKit not available
    }
    
    return vitals;
  }
}

/// Standalone HealthService that doesn't require database
/// Used by PatientHomeScreen
class HealthService {
  final Health _health = Health();
  
  static const List<HealthDataType> _types = [
    HealthDataType.HEART_RATE,
    HealthDataType.BLOOD_OXYGEN,
    HealthDataType.BLOOD_PRESSURE_SYSTOLIC,
    HealthDataType.BLOOD_PRESSURE_DIASTOLIC,
    HealthDataType.BODY_TEMPERATURE,
  ];
  
  Future<bool> isAvailable() async {
    try {
      // Just check if we can use Health API
      return true;
    } catch (e) {
      return false;
    }
  }
  
  Future<bool> requestPermissions() async {
    try {
      return await _health.requestAuthorization(
        _types,
        permissions: _types.map((_) => HealthDataAccess.READ).toList(),
      );
    } catch (e) {
      return false;
    }
  }
  
  Future<List<Map<String, dynamic>>> fetchRecentVitals() async {
    final vitals = <Map<String, dynamic>>[];
    final now = DateTime.now();
    
    try {
      // Get heart rate
      final hrData = await _health.getHealthDataFromTypes(
        types: [HealthDataType.HEART_RATE],
        startTime: now.subtract(const Duration(minutes: 30)),
        endTime: now,
      );
      if (hrData.isNotEmpty) {
        final hr = (hrData.last.value as NumericHealthValue).numericValue.toDouble();
        vitals.add({
          'vitalType': 'heart_rate',
          'values': {'heartRate': hr},
          'source': 'apple_watch',
          'deviceName': 'Apple Watch',
        });
      }
      
      // Get SpO2
      final spo2Data = await _health.getHealthDataFromTypes(
        types: [HealthDataType.BLOOD_OXYGEN],
        startTime: now.subtract(const Duration(hours: 2)),
        endTime: now,
      );
      if (spo2Data.isNotEmpty) {
        var spo2 = (spo2Data.last.value as NumericHealthValue).numericValue.toDouble();
        spo2 = spo2 > 1 ? spo2 : spo2 * 100;
        vitals.add({
          'vitalType': 'spo2',
          'values': {'spo2': spo2},
          'source': 'apple_watch',
          'deviceName': 'Apple Watch',
        });
      }
      
    } catch (e) {
      // HealthKit not available
    }
    
    return vitals;
  }
}
