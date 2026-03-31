import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mama_app/services/database/database.dart';
import 'package:mama_app/services/ble/ble_service.dart';
import 'package:mama_app/services/sync/sync_service.dart';
import 'package:mama_app/screens/monitoring/monitoring_screen.dart';
import 'package:mama_app/theme/app_theme.dart';

/// Quick Monitor Screen - auto-detects patient from connected device
/// or allows selecting a patient for monitoring
class QuickMonitorScreen extends ConsumerStatefulWidget {
  const QuickMonitorScreen({super.key});

  @override
  ConsumerState<QuickMonitorScreen> createState() => _QuickMonitorScreenState();
}

class _QuickMonitorScreenState extends ConsumerState<QuickMonitorScreen> {
  LocalPatient? _detectedPatient;
  VitalReading? _latestReading;
  bool _isListening = false;
  StreamSubscription? _vitalSubscription;

  @override
  void initState() {
    super.initState();
    _startListening();
  }

  @override
  void dispose() {
    _vitalSubscription?.cancel();
    super.dispose();
  }

  void _startListening() {
    setState(() => _isListening = true);
    
    final bleService = ref.read(bleServiceProvider);
    
    _vitalSubscription = bleService.vitalStream.listen((reading) async {
      setState(() => _latestReading = reading);
      
      // Try to auto-detect patient from device
      if (reading.deviceHardwareId != null && _detectedPatient == null) {
        final database = ref.read(databaseProvider);
        final patient = await database.getPatientByDeviceId(reading.deviceHardwareId!);
        
        if (patient != null && mounted) {
          setState(() => _detectedPatient = patient);
          
          // Prompt to start full monitoring session
          _showPatientDetectedDialog(patient, reading);
        }
      }
    });
  }

  void _showPatientDetectedDialog(LocalPatient patient, VitalReading reading) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Patient Detected'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppTheme.riskColor(patient.latestRiskTier).withOpacity(0.2),
                  child: Text(
                    patient.fullName[0],
                    style: TextStyle(
                      color: AppTheme.riskColor(patient.latestRiskTier),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        patient.fullName,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text('G${patient.gravida}P${patient.parity}'),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Device reading detected. Start monitoring session?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Not Now'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => MonitoringScreen(patient: patient),
                ),
              );
            },
            child: const Text('Start Session'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final syncStatus = ref.watch(syncStatusProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quick Monitor'),
        actions: [
          // Connection indicator
          Padding(
            padding: const EdgeInsets.all(8),
            child: Chip(
              avatar: Icon(
                syncStatus.isOnline ? Icons.cloud_done : Icons.cloud_off,
                size: 16,
              ),
              label: Text(syncStatus.isOnline ? 'Online' : 'Offline'),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // BLE Status card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(
                      _isListening ? Icons.bluetooth_searching : Icons.bluetooth_disabled,
                      size: 48,
                      color: _isListening ? Colors.blue : Colors.grey,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isListening 
                        ? 'Listening for device readings...'
                        : 'Connect a device to start',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Device readings will automatically appear here',
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Latest reading
            if (_latestReading != null) ...[
              Text(
                'Latest Reading',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              _LiveReadingCard(reading: _latestReading!),
              const SizedBox(height: 16),
            ],
            
            // Detected patient
            if (_detectedPatient != null) ...[
              Text(
                'Detected Patient',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppTheme.riskColor(_detectedPatient!.latestRiskTier).withOpacity(0.2),
                    child: Text(
                      _detectedPatient!.fullName[0],
                      style: TextStyle(
                        color: AppTheme.riskColor(_detectedPatient!.latestRiskTier),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(_detectedPatient!.fullName),
                  subtitle: Text('G${_detectedPatient!.gravida}P${_detectedPatient!.parity}'),
                  trailing: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MonitoringScreen(patient: _detectedPatient!),
                        ),
                      );
                    },
                    child: const Text('Monitor'),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            // Or select patient manually
            Text(
              'Or Select Patient',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            _PatientQuickSelect(
              onPatientSelected: (patient) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MonitoringScreen(patient: patient),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _LiveReadingCard extends StatelessWidget {
  final VitalReading reading;

  const _LiveReadingCard({required this.reading});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: reading.dangerLevel == 'danger' 
        ? Colors.red.shade50
        : reading.dangerLevel == 'warning'
          ? Colors.orange.shade50
          : Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatVitalType(reading.vitalType),
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.dangerLevelColor(reading.dangerLevel),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    reading.dangerLevel.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _formatValue(reading),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.dangerLevelColor(reading.dangerLevel),
              ),
            ),
            const SizedBox(height: 8),
            if (reading.deviceName != null)
              Text(
                'From: ${reading.deviceName}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
          ],
        ),
      ),
    );
  }

  String _formatVitalType(String type) {
    switch (type) {
      case 'bp': return 'Blood Pressure';
      case 'spo2': return 'Oxygen Saturation';
      case 'temp': return 'Temperature';
      case 'fetal_hr': return 'Fetal Heart Rate';
      default: return type;
    }
  }

  String _formatValue(VitalReading reading) {
    switch (reading.vitalType) {
      case 'bp':
        return '${reading.values['systolic']?.toInt()}/${reading.values['diastolic']?.toInt()} mmHg';
      case 'spo2':
        return '${reading.values['spo2']?.toInt()}%';
      case 'temp':
        return '${reading.values['temp']?.toStringAsFixed(1)}°C';
      case 'fetal_hr':
        return '${reading.values['bpm']?.toInt()} bpm';
      default:
        return reading.values.toString();
    }
  }
}

class _PatientQuickSelect extends ConsumerWidget {
  final void Function(LocalPatient) onPatientSelected;

  const _PatientQuickSelect({required this.onPatientSelected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final database = ref.watch(databaseProvider);
    
    return FutureBuilder<List<LocalPatient>>(
      future: database.getPregnantPatients(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        final patients = snapshot.data ?? [];
        
        if (patients.isEmpty) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('No pregnant patients registered'),
            ),
          );
        }
        
        // Show first 5 patients for quick selection
        return Column(
          children: patients.take(5).map((patient) => Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AppTheme.riskColor(patient.latestRiskTier).withOpacity(0.2),
                child: Text(
                  patient.fullName[0],
                  style: TextStyle(
                    color: AppTheme.riskColor(patient.latestRiskTier),
                  ),
                ),
              ),
              title: Text(patient.fullName),
              subtitle: Text('G${patient.gravida}P${patient.parity}'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => onPatientSelected(patient),
            ),
          )).toList(),
        );
      },
    );
  }
}
