import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mama_app/providers/auth_provider.dart';
import 'package:mama_app/services/health/health_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Patient vitals provider
final patientVitalsProvider = FutureProvider<PatientVitals?>((ref) async {
  final storage = const FlutterSecureStorage();
  final baseUrl = await storage.read(key: 'api_base_url');
  final token = await storage.read(key: 'auth_token');
  
  if (baseUrl == null || token == null) return null;
  
  try {
    final dio = Dio();
    final response = await dio.get(
      '$baseUrl/api/patient/vitals/latest',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    
    return PatientVitals.fromJson(response.data['latestVitals']);
  } catch (e) {
    return null;
  }
});

// Patient alerts provider
final patientAlertsProvider = FutureProvider<List<PatientAlert>>((ref) async {
  final storage = const FlutterSecureStorage();
  final baseUrl = await storage.read(key: 'api_base_url');
  final token = await storage.read(key: 'auth_token');
  
  if (baseUrl == null || token == null) return [];
  
  try {
    final dio = Dio();
    final response = await dio.get(
      '$baseUrl/api/patient/alerts',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    
    final alerts = (response.data['alerts'] as List)
      .map((a) => PatientAlert.fromJson(a))
      .toList();
    return alerts;
  } catch (e) {
    return [];
  }
});

class PatientVitals {
  final PatientVitalReading? bp;
  final PatientVitalReading? spo2;
  final PatientVitalReading? temp;
  final PatientVitalReading? fetalHr;
  final PatientVitalReading? heartRate;
  
  PatientVitals({this.bp, this.spo2, this.temp, this.fetalHr, this.heartRate});
  
  factory PatientVitals.fromJson(Map<String, dynamic> json) {
    return PatientVitals(
      bp: json['bp'] != null ? PatientVitalReading.fromJson(json['bp']) : null,
      spo2: json['spo2'] != null ? PatientVitalReading.fromJson(json['spo2']) : null,
      temp: json['temp'] != null ? PatientVitalReading.fromJson(json['temp']) : null,
      fetalHr: json['fetal_hr'] != null ? PatientVitalReading.fromJson(json['fetal_hr']) : null,
      heartRate: json['heart_rate'] != null ? PatientVitalReading.fromJson(json['heart_rate']) : null,
    );
  }
}

class PatientVitalReading {
  final Map<String, dynamic> values;
  final DateTime recordedAt;
  final String dangerLevel;
  
  PatientVitalReading({required this.values, required this.recordedAt, required this.dangerLevel});
  
  factory PatientVitalReading.fromJson(Map<String, dynamic> json) {
    return PatientVitalReading(
      values: json['values'] as Map<String, dynamic>,
      recordedAt: DateTime.parse(json['recordedAt']),
      dangerLevel: json['dangerLevel'] ?? 'normal',
    );
  }
}

class PatientAlert {
  final String id;
  final String alertType;
  final String? vitalType;
  final String message;
  final String severity;
  final DateTime sentAt;
  final DateTime? readAt;
  
  PatientAlert({
    required this.id,
    required this.alertType,
    this.vitalType,
    required this.message,
    required this.severity,
    required this.sentAt,
    this.readAt,
  });
  
  factory PatientAlert.fromJson(Map<String, dynamic> json) {
    return PatientAlert(
      id: json['id'],
      alertType: json['alert_type'],
      vitalType: json['vital_type'],
      message: json['message'],
      severity: json['severity'],
      sentAt: DateTime.parse(json['sent_at']),
      readAt: json['read_at'] != null ? DateTime.parse(json['read_at']) : null,
    );
  }
  
  bool get isUnread => readAt == null;
}

class PatientHomeScreen extends ConsumerStatefulWidget {
  const PatientHomeScreen({super.key});

  @override
  ConsumerState<PatientHomeScreen> createState() => _PatientHomeScreenState();
}

class _PatientHomeScreenState extends ConsumerState<PatientHomeScreen> {
  bool _isMonitoring = false;
  Timer? _healthKitTimer;
  final PatientHealthService _healthService = PatientHealthService();
  
  @override
  void initState() {
    super.initState();
    _checkHealthKitPermission();
  }
  
  @override
  void dispose() {
    _healthKitTimer?.cancel();
    super.dispose();
  }
  
  Future<void> _checkHealthKitPermission() async {
    final available = await _healthService.isAvailable();
    if (available) {
      final authorized = await _healthService.requestPermissions();
      if (authorized) {
        _startHealthKitSync();
      }
    }
  }
  
  void _startHealthKitSync() {
    // Sync health data every 5 minutes
    _healthKitTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      _syncHealthData();
    });
    // Initial sync
    _syncHealthData();
  }
  
  Future<void> _syncHealthData() async {
    if (!mounted) return;
    
    setState(() => _isMonitoring = true);
    
    try {
      final vitals = await _healthService.fetchRecentVitals();
      
      if (vitals.isNotEmpty) {
        await _submitVitalsToServer(vitals);
        // Refresh UI
        ref.invalidate(patientVitalsProvider);
        ref.invalidate(patientAlertsProvider);
      }
    } catch (e) {
      debugPrint('Health sync error: $e');
    }
    
    if (mounted) {
      setState(() => _isMonitoring = false);
    }
  }
  
  Future<void> _submitVitalsToServer(List<Map<String, dynamic>> vitals) async {
    final storage = const FlutterSecureStorage();
    final baseUrl = await storage.read(key: 'api_base_url');
    final token = await storage.read(key: 'auth_token');
    
    if (baseUrl == null || token == null) return;
    
    final dio = Dio();
    await dio.post(
      '$baseUrl/api/patient/vitals/submit',
      data: {'vitals': vitals},
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider);
    final vitals = ref.watch(patientVitalsProvider);
    final alerts = ref.watch(patientAlertsProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Health'),
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(patientVitalsProvider);
              ref.invalidate(patientAlertsProvider);
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final auth = ref.read(authActionsProvider);
              await auth.logout();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(patientVitalsProvider);
          ref.invalidate(patientAlertsProvider);
          await _syncHealthData();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome card
              user.when(
                data: (u) => _buildWelcomeCard(u),
                loading: () => const SizedBox(),
                error: (_, __) => const SizedBox(),
              ),
              
              const SizedBox(height: 16),
              
              // Apple Watch sync status
              _buildSyncStatusCard(),
              
              const SizedBox(height: 16),
              
              // Alerts section
              alerts.when(
                data: (alertList) => _buildAlertsSection(alertList),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => const SizedBox(),
              ),
              
              const SizedBox(height: 16),
              
              // Vitals grid
              Text(
                'My Vitals',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              
              vitals.when(
                data: (v) => _buildVitalsGrid(v),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => const Text('Failed to load vitals'),
              ),
              
              const SizedBox(height: 24),
              
              // Manual entry button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _showManualEntryDialog(),
                  icon: const Icon(Icons.edit),
                  label: const Text('Enter Vitals Manually'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    foregroundColor: Colors.pink,
                    side: const BorderSide(color: Colors.pink),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Contact health worker
              _buildHealthWorkerCard(),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildWelcomeCard(AppUser? user) {
    if (user == null) return const SizedBox();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.pink.shade400, Colors.pink.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white24,
            child: Icon(Icons.person, size: 30, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello, ${user.name.split(' ').first}!',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                if (user.isPregnant == true) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Week ${user.gestationalWeeks ?? "?"} of pregnancy',
                    style: TextStyle(color: Colors.white.withOpacity(0.9)),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSyncStatusCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _isMonitoring ? Colors.green.shade50 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isMonitoring ? Colors.green.shade200 : Colors.grey.shade300,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.watch,
            color: _isMonitoring ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isMonitoring ? 'Syncing with Apple Watch...' : 'Apple Watch Connected',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _isMonitoring ? Colors.green.shade700 : Colors.grey.shade700,
                  ),
                ),
                Text(
                  'Vitals sync automatically every 5 minutes',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          if (_isMonitoring)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            IconButton(
              icon: const Icon(Icons.sync),
              onPressed: _syncHealthData,
              color: Colors.grey,
            ),
        ],
      ),
    );
  }
  
  Widget _buildAlertsSection(List<PatientAlert> alerts) {
    final unreadAlerts = alerts.where((a) => a.isUnread).toList();
    
    if (unreadAlerts.isEmpty) return const SizedBox();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.warning_amber, color: Colors.orange),
            const SizedBox(width: 8),
            Text(
              'Alerts (${unreadAlerts.length})',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...unreadAlerts.take(3).map((alert) => _buildAlertCard(alert)),
      ],
    );
  }
  
  Widget _buildAlertCard(PatientAlert alert) {
    final color = alert.severity == 'critical' ? Colors.red : Colors.orange;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            alert.severity == 'critical' ? Icons.error : Icons.warning,
            color: color,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert.message,
                  style: TextStyle(color: color.shade700),
                ),
                Text(
                  _formatTime(alert.sentAt),
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildVitalsGrid(PatientVitals? vitals) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.3,
      children: [
        _buildVitalCard(
          'Blood Pressure',
          vitals?.bp != null 
            ? '${vitals!.bp!.values['systolic']?.toInt()}/${vitals.bp!.values['diastolic']?.toInt()}'
            : '--/--',
          'mmHg',
          Icons.favorite,
          vitals?.bp?.dangerLevel ?? 'normal',
          vitals?.bp?.recordedAt,
        ),
        _buildVitalCard(
          'Heart Rate',
          vitals?.heartRate?.values['heartRate']?.toInt().toString() ?? 
            vitals?.bp?.values['heartRate']?.toInt().toString() ?? '--',
          'BPM',
          Icons.monitor_heart,
          vitals?.heartRate?.dangerLevel ?? 'normal',
          vitals?.heartRate?.recordedAt ?? vitals?.bp?.recordedAt,
        ),
        _buildVitalCard(
          'Blood Oxygen',
          vitals?.spo2?.values['spo2']?.toInt().toString() ?? '--',
          '%',
          Icons.air,
          vitals?.spo2?.dangerLevel ?? 'normal',
          vitals?.spo2?.recordedAt,
        ),
        _buildVitalCard(
          'Temperature',
          vitals?.temp?.values['temperature']?.toStringAsFixed(1) ?? '--',
          '°C',
          Icons.thermostat,
          vitals?.temp?.dangerLevel ?? 'normal',
          vitals?.temp?.recordedAt,
        ),
      ],
    );
  }
  
  Widget _buildVitalCard(
    String label,
    String value,
    String unit,
    IconData icon,
    String dangerLevel,
    DateTime? recordedAt,
  ) {
    Color color;
    switch (dangerLevel) {
      case 'danger':
        color = Colors.red;
        break;
      case 'warning':
        color = Colors.orange;
        break;
      default:
        color = Colors.green;
    }
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  unit,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
              ),
            ],
          ),
          if (recordedAt != null)
            Text(
              _formatTime(recordedAt),
              style: TextStyle(fontSize: 10, color: Colors.grey.shade400),
            ),
        ],
      ),
    );
  }
  
  Widget _buildHealthWorkerCard() {
    return FutureBuilder<String?>(
      future: const FlutterSecureStorage().read(key: 'hw_name'),
      builder: (context, snapshot) {
        final hwName = snapshot.data;
        if (hwName == null) return const SizedBox();
        
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.blue.shade100,
                child: const Icon(Icons.medical_services, color: Colors.blue),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Your Health Worker',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    Text(
                      hwName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.phone, color: Colors.blue),
                onPressed: () async {
                  final phone = await const FlutterSecureStorage().read(key: 'hw_phone');
                  if (phone != null) {
                    // Launch phone dialer
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
  
  void _showManualEntryDialog() {
    final systolicController = TextEditingController();
    final diastolicController = TextEditingController();
    final spo2Controller = TextEditingController();
    final tempController = TextEditingController();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter Vitals Manually',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: systolicController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Systolic',
                      suffixText: 'mmHg',
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: diastolicController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Diastolic',
                      suffixText: 'mmHg',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: spo2Controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Blood Oxygen (SpO2)',
                suffixText: '%',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: tempController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Temperature',
                suffixText: '°C',
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final vitals = <Map<String, dynamic>>[];
                  
                  if (systolicController.text.isNotEmpty && diastolicController.text.isNotEmpty) {
                    vitals.add({
                      'vitalType': 'bp',
                      'values': {
                        'systolic': double.parse(systolicController.text),
                        'diastolic': double.parse(diastolicController.text),
                      },
                      'source': 'manual',
                    });
                  }
                  
                  if (spo2Controller.text.isNotEmpty) {
                    vitals.add({
                      'vitalType': 'spo2',
                      'values': {'spo2': double.parse(spo2Controller.text)},
                      'source': 'manual',
                    });
                  }
                  
                  if (tempController.text.isNotEmpty) {
                    vitals.add({
                      'vitalType': 'temp',
                      'values': {'temperature': double.parse(tempController.text)},
                      'source': 'manual',
                    });
                  }
                  
                  if (vitals.isNotEmpty) {
                    await _submitVitalsToServer(vitals);
                    ref.invalidate(patientVitalsProvider);
                    ref.invalidate(patientAlertsProvider);
                  }
                  
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Submit Vitals'),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
  
  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
