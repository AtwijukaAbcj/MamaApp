import 'dart:async';
import 'dart:convert';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mama_app/services/database/database.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart';

// BLE Service UUIDs for common medical devices
class BleUuids {
  // Blood Pressure Service (Bluetooth SIG)
  static const bloodPressure = '1810';
  static const bloodPressureMeasurement = '2a35';
  
  // Pulse Oximeter Service (Bluetooth SIG)
  static const pulseOximeter = '1822';
  static const plxSpotCheck = '2a5e';
  static const plxContinuous = '2a5f';
  
  // Health Thermometer Service
  static const healthThermometer = '1809';
  static const temperatureMeasurement = '2a1c';
  
  // Battery Service
  static const battery = '180f';
  static const batteryLevel = '2a19';
  
  // Generic Wearfit-style devices (custom UUIDs vary)
  static const wearfitService = 'fff0';
  static const wearfitNotify = 'fff1';
  static const wearfitWrite = 'fff2';
}

// Device types we support
enum DeviceType {
  bpMonitor,
  pulseOximeter,
  thermometer,
  fetalDoppler,
  unknown;
  
  String get displayName {
    switch (this) {
      case DeviceType.bpMonitor: return 'Blood Pressure Monitor';
      case DeviceType.pulseOximeter: return 'Pulse Oximeter';
      case DeviceType.thermometer: return 'Thermometer';
      case DeviceType.fetalDoppler: return 'Fetal Doppler';
      case DeviceType.unknown: return 'Unknown Device';
    }
  }
  
  String get code {
    switch (this) {
      case DeviceType.bpMonitor: return 'bp_monitor';
      case DeviceType.pulseOximeter: return 'pulse_oximeter';
      case DeviceType.thermometer: return 'thermometer';
      case DeviceType.fetalDoppler: return 'fetal_doppler';
      case DeviceType.unknown: return 'unknown';
    }
  }
}

// Vital reading from a device
class VitalReading {
  final String vitalType;
  final Map<String, double> values;
  final DateTime recordedAt;
  final String? deviceName;
  final String? deviceHardwareId;
  final String dangerLevel;
  
  VitalReading({
    required this.vitalType,
    required this.values,
    required this.recordedAt,
    this.deviceName,
    this.deviceHardwareId,
    required this.dangerLevel,
  });
  
  Map<String, dynamic> toJson() => {
    'vitalType': vitalType,
    'values': values,
    'recordedAt': recordedAt.toIso8601String(),
    'deviceName': deviceName,
    'deviceHardwareId': deviceHardwareId,
    'dangerLevel': dangerLevel,
  };
}

// Discovered BLE device
class DiscoveredDevice {
  final BluetoothDevice device;
  final String name;
  final DeviceType type;
  final int rssi;
  
  DiscoveredDevice({
    required this.device,
    required this.name,
    required this.type,
    required this.rssi,
  });
}

// BLE Connection state
enum BleConnectionState {
  disconnected,
  connecting,
  connected,
  error,
}

// BLE Service Provider
final bleServiceProvider = Provider<BleService>((ref) {
  final database = ref.watch(databaseProvider);
  return BleService(database);
});

// Scanning state
final bleScanningProvider = StateProvider<bool>((ref) => false);

// Discovered devices
final discoveredDevicesProvider = StateNotifierProvider<DiscoveredDevicesNotifier, List<DiscoveredDevice>>((ref) {
  return DiscoveredDevicesNotifier();
});

class DiscoveredDevicesNotifier extends StateNotifier<List<DiscoveredDevice>> {
  DiscoveredDevicesNotifier() : super([]);
  
  void add(DiscoveredDevice device) {
    // Update existing or add new
    final index = state.indexWhere((d) => d.device.remoteId == device.device.remoteId);
    if (index >= 0) {
      state = [...state]
        ..[index] = device;
    } else {
      state = [...state, device];
    }
  }
  
  void clear() {
    state = [];
  }
}

// Connected device state
final connectedDeviceProvider = StateProvider<BluetoothDevice?>((ref) => null);

// Latest vital reading stream
final latestVitalProvider = StreamProvider<VitalReading?>((ref) {
  final bleService = ref.watch(bleServiceProvider);
  return bleService.vitalStream;
});

class BleService {
  final AppDatabase _database;
  final _uuid = const Uuid();
  
  final _vitalController = StreamController<VitalReading>.broadcast();
  Stream<VitalReading> get vitalStream => _vitalController.stream;
  
  BluetoothDevice? _connectedDevice;
  StreamSubscription? _characteristicSubscription;
  
  BleService(this._database);
  
  /// Check if Bluetooth is available and on
  Future<bool> isBluetoothReady() async {
    final isSupported = await FlutterBluePlus.isSupported;
    if (!isSupported) return false;
    
    final state = await FlutterBluePlus.adapterState.first;
    return state == BluetoothAdapterState.on;
  }
  
  /// Start scanning for medical devices
  Stream<List<DiscoveredDevice>> startScan({Duration timeout = const Duration(seconds: 10)}) async* {
    final devices = <String, DiscoveredDevice>{};
    
    // Scan for devices with medical service UUIDs
    await FlutterBluePlus.startScan(
      timeout: timeout,
      withServices: [
        Guid(BleUuids.bloodPressure),
        Guid(BleUuids.pulseOximeter),
        Guid(BleUuids.healthThermometer),
      ],
    );
    
    await for (final results in FlutterBluePlus.scanResults) {
      for (final result in results) {
        final deviceType = _identifyDeviceType(result);
        final name = result.device.platformName.isNotEmpty 
            ? result.device.platformName 
            : 'Unknown Device';
        
        devices[result.device.remoteId.str] = DiscoveredDevice(
          device: result.device,
          name: name,
          type: deviceType,
          rssi: result.rssi,
        );
      }
      yield devices.values.toList();
    }
  }
  
  /// Scan for all BLE devices (including generic ones like Wearfit)
  Stream<List<DiscoveredDevice>> startGenericScan({Duration timeout = const Duration(seconds: 15)}) async* {
    final devices = <String, DiscoveredDevice>{};
    
    await FlutterBluePlus.startScan(timeout: timeout);
    
    await for (final results in FlutterBluePlus.scanResults) {
      for (final result in results) {
        // Filter to likely medical devices
        final name = result.device.platformName.toLowerCase();
        if (_isLikelyMedicalDevice(name, result)) {
          final deviceType = _identifyDeviceType(result);
          
          devices[result.device.remoteId.str] = DiscoveredDevice(
            device: result.device,
            name: result.device.platformName.isNotEmpty 
                ? result.device.platformName 
                : result.device.remoteId.str,
            type: deviceType,
            rssi: result.rssi,
          );
        }
      }
      yield devices.values.toList();
    }
  }
  
  /// Stop scanning
  Future<void> stopScan() async {
    await FlutterBluePlus.stopScan();
  }
  
  /// Connect to a device
  Future<bool> connect(BluetoothDevice device) async {
    try {
      await device.connect(timeout: const Duration(seconds: 15));
      _connectedDevice = device;
      
      // Discover services
      final services = await device.discoverServices();
      
      // Set up notifications for vital readings
      await _setupNotifications(device, services);
      
      // Update device in local database
      await _registerDevice(device);
      
      return true;
    } catch (e) {
      print('BLE connect error: $e');
      return false;
    }
  }
  
  /// Disconnect from current device
  Future<void> disconnect() async {
    await _characteristicSubscription?.cancel();
    await _connectedDevice?.disconnect();
    _connectedDevice = null;
  }
  
  /// Get battery level from connected device
  Future<int?> getBatteryLevel() async {
    if (_connectedDevice == null) return null;
    
    try {
      final services = await _connectedDevice!.discoverServices();
      final batteryService = services.firstWhere(
        (s) => s.uuid.toString().startsWith(BleUuids.battery),
        orElse: () => throw Exception('No battery service'),
      );
      
      final batteryChar = batteryService.characteristics.firstWhere(
        (c) => c.uuid.toString().startsWith(BleUuids.batteryLevel),
      );
      
      final value = await batteryChar.read();
      return value.isNotEmpty ? value[0] : null;
    } catch (e) {
      return null;
    }
  }
  
  // ============== PRIVATE METHODS ==============
  
  bool _isLikelyMedicalDevice(String name, ScanResult result) {
    // Common medical device name patterns
    final medicalKeywords = [
      'bp', 'blood', 'pressure', 'sphygmo',
      'oximeter', 'spo2', 'pulse', 'oxy',
      'thermo', 'temp',
      'fetal', 'doppler', 'heart',
      'wearfit', 'health', 'medical',
      'omron', 'beurer', 'braun', 'withings',
      'contec', 'wellue', 'viatom',
    ];
    
    for (final keyword in medicalKeywords) {
      if (name.contains(keyword)) return true;
    }
    
    // Check service UUIDs
    final serviceUuids = result.advertisementData.serviceUuids.map((g) => g.toString().toLowerCase());
    final medicalServices = [BleUuids.bloodPressure, BleUuids.pulseOximeter, BleUuids.healthThermometer];
    
    for (final uuid in serviceUuids) {
      for (final medical in medicalServices) {
        if (uuid.contains(medical)) return true;
      }
    }
    
    return false;
  }
  
  DeviceType _identifyDeviceType(ScanResult result) {
    final serviceUuids = result.advertisementData.serviceUuids.map((g) => g.toString().toLowerCase()).toList();
    final name = result.device.platformName.toLowerCase();
    
    // Check by service UUID
    for (final uuid in serviceUuids) {
      if (uuid.contains(BleUuids.bloodPressure)) return DeviceType.bpMonitor;
      if (uuid.contains(BleUuids.pulseOximeter)) return DeviceType.pulseOximeter;
      if (uuid.contains(BleUuids.healthThermometer)) return DeviceType.thermometer;
    }
    
    // Check by name
    if (name.contains('bp') || name.contains('blood') || name.contains('pressure')) {
      return DeviceType.bpMonitor;
    }
    if (name.contains('oximeter') || name.contains('spo2') || name.contains('oxy')) {
      return DeviceType.pulseOximeter;
    }
    if (name.contains('thermo') || name.contains('temp')) {
      return DeviceType.thermometer;
    }
    if (name.contains('fetal') || name.contains('doppler')) {
      return DeviceType.fetalDoppler;
    }
    
    return DeviceType.unknown;
  }
  
  Future<void> _setupNotifications(BluetoothDevice device, List<BluetoothService> services) async {
    for (final service in services) {
      final serviceUuid = service.uuid.toString().toLowerCase();
      
      // Blood Pressure
      if (serviceUuid.contains(BleUuids.bloodPressure)) {
        await _subscribeToCharacteristic(
          service, 
          BleUuids.bloodPressureMeasurement,
          _parseBpReading,
        );
      }
      
      // Pulse Oximeter
      if (serviceUuid.contains(BleUuids.pulseOximeter)) {
        await _subscribeToCharacteristic(
          service,
          BleUuids.plxSpotCheck,
          _parseSpO2Reading,
        );
      }
      
      // Thermometer
      if (serviceUuid.contains(BleUuids.healthThermometer)) {
        await _subscribeToCharacteristic(
          service,
          BleUuids.temperatureMeasurement,
          _parseTemperatureReading,
        );
      }
      
      // Generic Wearfit-style
      if (serviceUuid.contains(BleUuids.wearfitService)) {
        await _subscribeToCharacteristic(
          service,
          BleUuids.wearfitNotify,
          _parseWearfitReading,
        );
      }
    }
  }
  
  Future<void> _subscribeToCharacteristic(
    BluetoothService service,
    String charUuid,
    VitalReading? Function(List<int> data) parser,
  ) async {
    try {
      final char = service.characteristics.firstWhere(
        (c) => c.uuid.toString().toLowerCase().contains(charUuid),
      );
      
      await char.setNotifyValue(true);
      
      _characteristicSubscription = char.onValueReceived.listen((data) {
        final reading = parser(data);
        if (reading != null) {
          _vitalController.add(reading);
          _saveReading(reading);
        }
      });
    } catch (e) {
      print('Subscribe error for $charUuid: $e');
    }
  }
  
  // Parse Bluetooth SIG Blood Pressure Measurement (0x2A35)
  VitalReading? _parseBpReading(List<int> data) {
    if (data.length < 7) return null;
    
    // Flags byte
    final flags = data[0];
    final kPa = (flags & 0x01) != 0; // 0 = mmHg, 1 = kPa
    
    // IEEE-11073 SFLOAT format
    int offset = 1;
    
    double systolic = _parseSFloat(data, offset);
    offset += 2;
    double diastolic = _parseSFloat(data, offset);
    offset += 2;
    double map = _parseSFloat(data, offset);
    
    // Convert from kPa if needed
    if (kPa) {
      systolic *= 7.50062;
      diastolic *= 7.50062;
    }
    
    final dangerLevel = _classifyBpDanger(systolic, diastolic);
    
    return VitalReading(
      vitalType: 'bp',
      values: {
        'systolic': systolic,
        'diastolic': diastolic,
        'map': map,
      },
      recordedAt: DateTime.now(),
      deviceName: _connectedDevice?.platformName,
      deviceHardwareId: _connectedDevice?.remoteId.str,
      dangerLevel: dangerLevel,
    );
  }
  
  // Parse Bluetooth SIG SpO2 (PLX Spot-Check 0x2A5E)
  VitalReading? _parseSpO2Reading(List<int> data) {
    if (data.length < 4) return null;
    
    // SpO2 and pulse rate as SFLOAT
    final spo2 = _parseSFloat(data, 0);
    final heartRate = _parseSFloat(data, 2);
    
    final dangerLevel = _classifySpO2Danger(spo2);
    
    return VitalReading(
      vitalType: 'spo2',
      values: {
        'spo2': spo2,
        'heartRate': heartRate,
      },
      recordedAt: DateTime.now(),
      deviceName: _connectedDevice?.platformName,
      deviceHardwareId: _connectedDevice?.remoteId.str,
      dangerLevel: dangerLevel,
    );
  }
  
  // Parse Bluetooth SIG Temperature (0x2A1C)
  VitalReading? _parseTemperatureReading(List<int> data) {
    if (data.length < 5) return null;
    
    final flags = data[0];
    final fahrenheit = (flags & 0x01) != 0;
    
    // Temperature is IEEE-11073 FLOAT (4 bytes)
    double temp = _parseFloat(data, 1);
    
    if (fahrenheit) {
      temp = (temp - 32) * 5 / 9; // Convert to Celsius
    }
    
    final dangerLevel = _classifyTempDanger(temp);
    
    return VitalReading(
      vitalType: 'temp',
      values: {'temp': temp},
      recordedAt: DateTime.now(),
      deviceName: _connectedDevice?.platformName,
      deviceHardwareId: _connectedDevice?.remoteId.str,
      dangerLevel: dangerLevel,
    );
  }
  
  // Parse generic Wearfit-style readings
  VitalReading? _parseWearfitReading(List<int> data) {
    // Wearfit protocols vary, this is a common pattern
    if (data.length < 4) return null;
    
    final command = data[0];
    
    // Blood pressure response (common format)
    if (command == 0x05 && data.length >= 5) {
      final systolic = data[2].toDouble();
      final diastolic = data[3].toDouble();
      final heartRate = data[4].toDouble();
      
      return VitalReading(
        vitalType: 'bp',
        values: {
          'systolic': systolic,
          'diastolic': diastolic,
          'heartRate': heartRate,
        },
        recordedAt: DateTime.now(),
        deviceName: _connectedDevice?.platformName,
        deviceHardwareId: _connectedDevice?.remoteId.str,
        dangerLevel: _classifyBpDanger(systolic, diastolic),
      );
    }
    
    // SpO2 response
    if (command == 0x06 && data.length >= 4) {
      final spo2 = data[2].toDouble();
      final heartRate = data[3].toDouble();
      
      return VitalReading(
        vitalType: 'spo2',
        values: {
          'spo2': spo2,
          'heartRate': heartRate,
        },
        recordedAt: DateTime.now(),
        deviceName: _connectedDevice?.platformName,
        deviceHardwareId: _connectedDevice?.remoteId.str,
        dangerLevel: _classifySpO2Danger(spo2),
      );
    }
    
    return null;
  }
  
  // IEEE-11073 SFLOAT parser (2 bytes)
  double _parseSFloat(List<int> data, int offset) {
    final b0 = data[offset];
    final b1 = data[offset + 1];
    
    int mantissa = ((b1 & 0x0F) << 8) | b0;
    int exponent = (b1 >> 4) & 0x0F;
    
    // Handle sign extension
    if (mantissa >= 0x0800) mantissa = mantissa - 0x1000;
    if (exponent >= 0x08) exponent = exponent - 0x10;
    
    return mantissa * pow(10, exponent);
  }
  
  // IEEE-11073 FLOAT parser (4 bytes)
  double _parseFloat(List<int> data, int offset) {
    final b0 = data[offset];
    final b1 = data[offset + 1];
    final b2 = data[offset + 2];
    final b3 = data[offset + 3];
    
    int mantissa = (b2 << 16) | (b1 << 8) | b0;
    int exponent = b3;
    
    if (mantissa >= 0x800000) mantissa = mantissa - 0x1000000;
    if (exponent >= 0x80) exponent = exponent - 0x100;
    
    return mantissa * pow(10, exponent);
  }
  
  double pow(double base, int exp) {
    if (exp == 0) return 1;
    if (exp > 0) {
      double result = 1;
      for (int i = 0; i < exp; i++) result *= base;
      return result;
    } else {
      double result = 1;
      for (int i = 0; i < -exp; i++) result /= base;
      return result;
    }
  }
  
  // Danger classification
  String _classifyBpDanger(double systolic, double diastolic) {
    if (systolic >= 160 || diastolic >= 110) return 'danger';
    if (systolic >= 140 || diastolic >= 90) return 'warning';
    return 'normal';
  }
  
  String _classifySpO2Danger(double spo2) {
    if (spo2 < 90) return 'danger';
    if (spo2 < 95) return 'warning';
    return 'normal';
  }
  
  String _classifyTempDanger(double temp) {
    if (temp >= 38.5 || temp < 35) return 'danger';
    if (temp >= 37.5 || temp < 36) return 'warning';
    return 'normal';
  }
  
  Future<void> _registerDevice(BluetoothDevice device) async {
    final existing = await _database.getDeviceByHardwareId(device.remoteId.str);
    
    if (existing == null) {
      final deviceType = DeviceType.unknown; // Will be updated after connecting
      
      await _database.insertDevice(DevicesCompanion.insert(
        id: _uuid.v4(),
        deviceHardwareId: device.remoteId.str,
        deviceName: device.platformName.isNotEmpty ? device.platformName : 'Unknown Device',
        deviceType: deviceType.code,
        createdAt: DateTime.now(),
      ));
    } else {
      // Update last seen
      await _database.updateDeviceBattery(device.remoteId.str, await getBatteryLevel() ?? existing.batteryLevel ?? 100);
    }
  }
  
  Future<void> _saveReading(VitalReading reading) async {
    // This will be called from the monitoring screen to save to a session
  }
  
  void dispose() {
    _characteristicSubscription?.cancel();
    _vitalController.close();
  }
}
