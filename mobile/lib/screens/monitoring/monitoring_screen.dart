import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mama_app/services/database/database.dart';
import 'package:mama_app/services/ble/ble_service.dart';
import 'package:mama_app/services/sync/sync_service.dart';
import 'package:mama_app/theme/app_theme.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart' hide Column;

class MonitoringScreen extends ConsumerStatefulWidget {
  final LocalPatient patient;

  const MonitoringScreen({
    super.key,
    required this.patient,
  });

  @override
  ConsumerState<MonitoringScreen> createState() => _MonitoringScreenState();
}

class _MonitoringScreenState extends ConsumerState<MonitoringScreen> {
  String? _sessionId;
  DateTime? _sessionStart;
  final List<VitalReading> _readings = [];
  final Map<String, bool> _symptoms = {
    'severeHeadache': false,
    'vaginalBleeding': false,
    'reducedFetalMovement': false,
    'oedemaFaceHands': false,
    'pallor': false,
  };
  
  bool _isConnectedToDevice = false;
  StreamSubscription? _vitalSubscription;
  
  // Manual entry controllers
  final _systolicController = TextEditingController();
  final _diastolicController = TextEditingController();
  final _spo2Controller = TextEditingController();
  final _heartRateController = TextEditingController();
  final _tempController = TextEditingController();
  final _fetalHrController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _startSession();
    _listenToDeviceReadings();
  }

  @override
  void dispose() {
    _vitalSubscription?.cancel();
    _systolicController.dispose();
    _diastolicController.dispose();
    _spo2Controller.dispose();
    _heartRateController.dispose();
    _tempController.dispose();
    _fetalHrController.dispose();
    super.dispose();
  }

  Future<void> _startSession() async {
    final database = ref.read(databaseProvider);
    _sessionId = const Uuid().v4();
    _sessionStart = DateTime.now();
    
    await database.insertSession(MonitoringSessionsCompanion.insert(
      id: _sessionId!,
      patientId: widget.patient.id,
      startedAt: _sessionStart!,
    ));
  }

  void _listenToDeviceReadings() {
    final bleService = ref.read(bleServiceProvider);
    
    _vitalSubscription = bleService.vitalStream.listen((reading) {
      setState(() {
        _readings.add(reading);
        _isConnectedToDevice = true;
      });
      _saveReading(reading);
    });
  }

  Future<void> _saveReading(VitalReading reading) async {
    final database = ref.read(databaseProvider);
    
    await database.insertReading(ReadingsCompanion.insert(
      id: const Uuid().v4(),
      sessionId: _sessionId!,
      patientId: widget.patient.id,
      vitalType: reading.vitalType,
      valuesJson: jsonEncode(reading.values),
      recordedAt: reading.recordedAt,
      dangerLevel: Value(reading.dangerLevel),
      source: Value(reading.deviceHardwareId != null ? 'device' : 'manual'),
      deviceName: Value(reading.deviceName),
      deviceHardwareId: Value(reading.deviceHardwareId),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final gestationalWeeks = _calculateGestationalWeeks();
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.patient.fullName),
        actions: [
          if (_isConnectedToDevice)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Chip(
                label: Text('BLE Connected'),
                avatar: Icon(Icons.bluetooth_connected, size: 16),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Patient summary card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppTheme.riskColor(widget.patient.latestRiskTier).withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          widget.patient.fullName[0],
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.riskColor(widget.patient.latestRiskTier),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'G${widget.patient.gravida}P${widget.patient.parity}',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          if (gestationalWeeks != null)
                            Text('$gestationalWeeks weeks gestation'),
                          if (widget.patient.latestRiskTier != null)
                            Chip(
                              label: Text(
                                '${widget.patient.latestRiskTier!.toUpperCase()} RISK',
                                style: const TextStyle(color: Colors.white, fontSize: 10),
                              ),
                              backgroundColor: AppTheme.riskColor(widget.patient.latestRiskTier),
                              visualDensity: VisualDensity.compact,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Session timer
            Card(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    const Icon(Icons.timer),
                    const SizedBox(width: 8),
                    Text(
                      'Session: ${_formatDuration(DateTime.now().difference(_sessionStart ?? DateTime.now()))}',
                    ),
                    const Spacer(),
                    Text('${_readings.length} readings'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Live readings from device
            if (_readings.isNotEmpty) ...[
              Text(
                'Latest Readings',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              ..._readings.reversed.take(3).map((r) => _ReadingCard(reading: r)),
              const SizedBox(height: 16),
            ],
            
            // Manual vital entry
            Text(
              'Record Vitals',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            
            // Blood Pressure
            _VitalInputCard(
              title: 'Blood Pressure',
              icon: Icons.favorite,
              color: Colors.red,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _systolicController,
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
                        controller: _diastolicController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Diastolic',
                          suffixText: 'mmHg',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: _addBpReading,
                    icon: const Icon(Icons.add),
                    label: const Text('Add BP'),
                  ),
                ),
              ],
            ),
            
            // SpO2 and Heart Rate
            _VitalInputCard(
              title: 'Oxygen & Heart Rate',
              icon: Icons.air,
              color: Colors.blue,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _spo2Controller,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'SpO2',
                          suffixText: '%',
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: _heartRateController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Heart Rate',
                          suffixText: 'bpm',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: _addSpO2Reading,
                    icon: const Icon(Icons.add),
                    label: const Text('Add SpO2'),
                  ),
                ),
              ],
            ),
            
            // Temperature
            _VitalInputCard(
              title: 'Temperature',
              icon: Icons.thermostat,
              color: Colors.orange,
              children: [
                TextField(
                  controller: _tempController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Temperature',
                    suffixText: '°C',
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: _addTempReading,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Temp'),
                  ),
                ),
              ],
            ),
            
            // Fetal Heart Rate
            _VitalInputCard(
              title: 'Fetal Heart Rate',
              icon: Icons.child_friendly,
              color: Colors.pink,
              children: [
                TextField(
                  controller: _fetalHrController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Fetal HR',
                    suffixText: 'bpm',
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: _addFetalHrReading,
                    icon: const Icon(Icons.add),
                    label: const Text('Add FHR'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Symptoms checklist
            Text(
              'Danger Signs Assessment',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children: [
                  _SymptomTile(
                    title: 'Severe Headache',
                    subtitle: 'Persistent, not relieved by rest',
                    value: _symptoms['severeHeadache']!,
                    onChanged: (v) => setState(() => _symptoms['severeHeadache'] = v),
                  ),
                  _SymptomTile(
                    title: 'Vaginal Bleeding',
                    subtitle: 'Any bleeding during pregnancy',
                    value: _symptoms['vaginalBleeding']!,
                    isDanger: true,
                    onChanged: (v) => setState(() => _symptoms['vaginalBleeding'] = v),
                  ),
                  _SymptomTile(
                    title: 'Reduced Fetal Movement',
                    subtitle: 'Less than 10 movements in 2 hours',
                    value: _symptoms['reducedFetalMovement']!,
                    onChanged: (v) => setState(() => _symptoms['reducedFetalMovement'] = v),
                  ),
                  _SymptomTile(
                    title: 'Swelling (Face/Hands)',
                    subtitle: 'Sudden swelling, not just ankles',
                    value: _symptoms['oedemaFaceHands']!,
                    onChanged: (v) => setState(() => _symptoms['oedemaFaceHands'] = v),
                  ),
                  _SymptomTile(
                    title: 'Pallor',
                    subtitle: 'Pale conjunctiva, palms, or nail beds',
                    value: _symptoms['pallor']!,
                    onChanged: (v) => setState(() => _symptoms['pallor'] = v),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Danger warning
            if (_symptoms.values.any((v) => v) || _readings.any((r) => r.dangerLevel == 'danger'))
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning, color: Colors.red),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'DANGER SIGNS DETECTED - Consider referral',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            
            const SizedBox(height: 24),
            
            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _endSession,
                    icon: const Icon(Icons.check),
                    label: const Text('End Session'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _createReferral,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.local_hospital),
                    label: const Text('Refer'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  int? _calculateGestationalWeeks() {
    if (widget.patient.pregnancyRegisteredAt == null || 
        widget.patient.gestationalWeeksAtRegistration == null) {
      return null;
    }
    
    final weeksSinceReg = DateTime.now()
      .difference(widget.patient.pregnancyRegisteredAt!)
      .inDays ~/ 7;
    
    return widget.patient.gestationalWeeksAtRegistration! + weeksSinceReg;
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes;
    final seconds = d.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void _addBpReading() {
    final systolic = double.tryParse(_systolicController.text);
    final diastolic = double.tryParse(_diastolicController.text);
    
    if (systolic == null || diastolic == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter valid BP values')),
      );
      return;
    }
    
    final dangerLevel = _classifyBp(systolic, diastolic);
    final reading = VitalReading(
      vitalType: 'bp',
      values: {'systolic': systolic, 'diastolic': diastolic},
      recordedAt: DateTime.now(),
      dangerLevel: dangerLevel,
    );
    
    setState(() => _readings.add(reading));
    _saveReading(reading);
    
    _systolicController.clear();
    _diastolicController.clear();
  }

  void _addSpO2Reading() {
    final spo2 = double.tryParse(_spo2Controller.text);
    final hr = double.tryParse(_heartRateController.text);
    
    if (spo2 == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter valid SpO2 value')),
      );
      return;
    }
    
    final dangerLevel = spo2 < 90 ? 'danger' : spo2 < 95 ? 'warning' : 'normal';
    final reading = VitalReading(
      vitalType: 'spo2',
      values: {'spo2': spo2, if (hr != null) 'heartRate': hr},
      recordedAt: DateTime.now(),
      dangerLevel: dangerLevel,
    );
    
    setState(() => _readings.add(reading));
    _saveReading(reading);
    
    _spo2Controller.clear();
    _heartRateController.clear();
  }

  void _addTempReading() {
    final temp = double.tryParse(_tempController.text);
    
    if (temp == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter valid temperature')),
      );
      return;
    }
    
    final dangerLevel = temp >= 38.5 ? 'danger' : temp >= 37.5 ? 'warning' : 'normal';
    final reading = VitalReading(
      vitalType: 'temp',
      values: {'temp': temp},
      recordedAt: DateTime.now(),
      dangerLevel: dangerLevel,
    );
    
    setState(() => _readings.add(reading));
    _saveReading(reading);
    _tempController.clear();
  }

  void _addFetalHrReading() {
    final fhr = double.tryParse(_fetalHrController.text);
    
    if (fhr == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter valid fetal heart rate')),
      );
      return;
    }
    
    final dangerLevel = (fhr < 100 || fhr > 180) ? 'danger' : (fhr < 110 || fhr > 160) ? 'warning' : 'normal';
    final reading = VitalReading(
      vitalType: 'fetal_hr',
      values: {'bpm': fhr},
      recordedAt: DateTime.now(),
      dangerLevel: dangerLevel,
    );
    
    setState(() => _readings.add(reading));
    _saveReading(reading);
    _fetalHrController.clear();
  }

  String _classifyBp(double systolic, double diastolic) {
    if (systolic >= 160 || diastolic >= 110) return 'danger';
    if (systolic >= 140 || diastolic >= 90) return 'warning';
    return 'normal';
  }

  Future<void> _endSession() async {
    final database = ref.read(databaseProvider);
    final syncService = ref.read(syncServiceProvider);
    
    // End the session
    await database.endSession(_sessionId!);
    
    // Try to sync vitals to server
    final vitalsPayload = _readings.map((r) => r.toJson()).toList();
    await syncService.sendVitalsToServer(
      patientId: widget.patient.id,
      vitals: vitalsPayload,
      symptoms: _symptoms,
    );
    
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Session completed with ${_readings.length} readings')),
      );
    }
  }

  Future<void> _createReferral() async {
    final database = ref.read(databaseProvider);
    
    // Determine trigger
    String triggerType = 'manual';
    final triggerDetails = <String, dynamic>{};
    
    if (_readings.any((r) => r.dangerLevel == 'danger')) {
      triggerType = 'danger_sign';
      triggerDetails['vitals'] = _readings
        .where((r) => r.dangerLevel == 'danger')
        .map((r) => r.toJson())
        .toList();
    }
    
    if (_symptoms.values.any((v) => v)) {
      triggerType = 'danger_sign';
      triggerDetails['symptoms'] = _symptoms.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();
    }
    
    await database.insertReferral(ReferralsCompanion.insert(
      id: const Uuid().v4(),
      patientId: widget.patient.id,
      triggerType: triggerType,
      triggerDetailJson: Value(jsonEncode(triggerDetails)),
      vitalsSnapshotJson: Value(jsonEncode(_readings.map((r) => r.toJson()).toList())),
      aiRiskScore: Value(widget.patient.latestRiskScore),
      status: const Value('pending'),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ));
    
    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 8),
              Text('Referral Created'),
            ],
          ),
          content: const Text(
            'The referral has been created and will sync to the facility when connected.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Go back
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }
}

class _ReadingCard extends StatelessWidget {
  final VitalReading reading;

  const _ReadingCard({required this.reading});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 8,
          height: 40,
          decoration: BoxDecoration(
            color: AppTheme.dangerLevelColor(reading.dangerLevel),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        title: Text(_formatVitalType(reading.vitalType)),
        subtitle: Text(_formatValues(reading.values)),
        trailing: Text(
          _formatTime(reading.recordedAt),
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ),
    );
  }

  String _formatVitalType(String type) {
    switch (type) {
      case 'bp': return 'Blood Pressure';
      case 'spo2': return 'SpO2';
      case 'temp': return 'Temperature';
      case 'fetal_hr': return 'Fetal HR';
      default: return type;
    }
  }

  String _formatValues(Map<String, double> values) {
    if (values.containsKey('systolic')) {
      return '${values['systolic']?.toInt()}/${values['diastolic']?.toInt()} mmHg';
    }
    if (values.containsKey('spo2')) {
      final hr = values['heartRate'];
      return '${values['spo2']?.toInt()}%${hr != null ? ' • ${hr.toInt()} bpm' : ''}';
    }
    if (values.containsKey('temp')) {
      return '${values['temp']?.toStringAsFixed(1)}°C';
    }
    if (values.containsKey('bpm')) {
      return '${values['bpm']?.toInt()} bpm';
    }
    return values.toString();
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}

class _VitalInputCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final List<Widget> children;

  const _VitalInputCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _SymptomTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final bool isDanger;
  final ValueChanged<bool> onChanged;

  const _SymptomTile({
    required this.title,
    required this.subtitle,
    required this.value,
    this.isDanger = false,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: Text(
        title,
        style: TextStyle(
          color: value && isDanger ? Colors.red : null,
          fontWeight: value ? FontWeight.bold : null,
        ),
      ),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
      activeColor: isDanger ? Colors.red : null,
    );
  }
}
