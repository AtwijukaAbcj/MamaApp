import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'database.g.dart';

// Provider
final databaseProvider = Provider<AppDatabase>((ref) {
  throw UnimplementedError('Override in main');
});

// ============== TABLES ==============

@DataClassName('LocalPatient')
class Patients extends Table {
  TextColumn get id => text()();
  TextColumn get fullName => text()();
  TextColumn get phone => text().nullable()();
  IntColumn get age => integer().nullable()();
  IntColumn get gravida => integer().withDefault(const Constant(0))();
  IntColumn get parity => integer().withDefault(const Constant(0))();
  BoolColumn get isPregnant => boolean().withDefault(const Constant(false))();
  IntColumn get gestationalWeeksAtRegistration => integer().nullable()();
  DateTimeColumn get pregnancyRegisteredAt => dateTime().nullable()();
  TextColumn get expectedDeliveryDate => text().nullable()();
  BoolColumn get priorStillbirth => boolean().withDefault(const Constant(false))();
  BoolColumn get priorCsection => boolean().withDefault(const Constant(false))();
  BoolColumn get priorPreeclampsia => boolean().withDefault(const Constant(false))();
  BoolColumn get hivPositive => boolean().withDefault(const Constant(false))();
  BoolColumn get diabetes => boolean().withDefault(const Constant(false))();
  BoolColumn get anaemia => boolean().withDefault(const Constant(false))();
  BoolColumn get multiplePregnancy => boolean().withDefault(const Constant(false))();
  TextColumn get nearestFacilityId => text().nullable()();
  TextColumn get latestRiskTier => text().nullable()();
  RealColumn get latestRiskScore => real().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();
  
  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('LocalDevice')
class Devices extends Table {
  TextColumn get id => text()();
  TextColumn get deviceHardwareId => text()();
  TextColumn get deviceName => text()();
  TextColumn get deviceType => text()(); // bp_monitor, pulse_oximeter, fetal_doppler
  TextColumn get assignedPatientId => text().nullable()();
  TextColumn get status => text().withDefault(const Constant('active'))();
  IntColumn get batteryLevel => integer().nullable()();
  DateTimeColumn get lastSeenAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();
  
  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('LocalSession')
class MonitoringSessions extends Table {
  TextColumn get id => text()();
  TextColumn get patientId => text()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get endedAt => dateTime().nullable()();
  RealColumn get locationLat => real().nullable()();
  RealColumn get locationLng => real().nullable()();
  TextColumn get deviceId => text().nullable()();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();
  
  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('LocalReading')
class Readings extends Table {
  TextColumn get id => text()();
  TextColumn get sessionId => text()();
  TextColumn get patientId => text()();
  TextColumn get vitalType => text()(); // bp, spo2, temp, fetal_hr, fundal_height, weight
  TextColumn get valuesJson => text()();
  DateTimeColumn get recordedAt => dateTime()();
  TextColumn get dangerLevel => text().withDefault(const Constant('normal'))();
  TextColumn get source => text().withDefault(const Constant('manual'))();
  TextColumn get deviceName => text().nullable()();
  TextColumn get deviceHardwareId => text().nullable()();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();
  
  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('LocalRiskScore')
class RiskScores extends Table {
  TextColumn get id => text()();
  TextColumn get patientId => text()();
  TextColumn get sessionId => text().nullable()();
  RealColumn get riskScore => real()();
  TextColumn get riskTier => text()(); // low, medium, high
  TextColumn get topFactorsJson => text().nullable()();
  DateTimeColumn get scoredAt => dateTime()();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();
  
  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('LocalReferral')
class Referrals extends Table {
  TextColumn get id => text()();
  TextColumn get patientId => text()();
  TextColumn get triggerType => text()(); // danger_sign, high_risk, manual
  TextColumn get triggerDetailJson => text().nullable()();
  TextColumn get vitalsSnapshotJson => text().nullable()();
  RealColumn get aiRiskScore => real().nullable()();
  TextColumn get facilityId => text().nullable()();
  TextColumn get status => text().withDefault(const Constant('pending'))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();
  
  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('LocalFacility')
class Facilities extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get facilityType => text()();
  TextColumn get address => text().nullable()();
  TextColumn get phone => text().nullable()();
  RealColumn get latitude => real().nullable()();
  RealColumn get longitude => real().nullable()();
  
  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('LocalSyncOutbox')
class SyncOutbox extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get syncTableName => text()();
  TextColumn get recordId => text()();
  TextColumn get operation => text()(); // insert, update, delete
  TextColumn get payloadJson => text()();
  DateTimeColumn get createdAt => dateTime()();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  TextColumn get lastError => text().nullable()();
}

// ============== DATABASE ==============

@DriftDatabase(tables: [
  Patients,
  Devices,
  MonitoringSessions,
  Readings,
  RiskScores,
  Referrals,
  Facilities,
  SyncOutbox,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  
  @override
  int get schemaVersion => 1;
  
  // ============== PATIENT OPERATIONS ==============
  
  Future<List<LocalPatient>> getAllPatients() => select(patients).get();
  
  Future<List<LocalPatient>> getPregnantPatients() =>
    (select(patients)..where((p) => p.isPregnant.equals(true))).get();
  
  Future<List<LocalPatient>> getHighRiskPatients() =>
    (select(patients)..where((p) => p.latestRiskTier.equals('high'))).get();
  
  Future<LocalPatient?> getPatientById(String id) =>
    (select(patients)..where((p) => p.id.equals(id))).getSingleOrNull();
  
  Future<LocalPatient?> getPatientByDeviceId(String deviceHardwareId) async {
    final device = await (select(devices)
      ..where((d) => d.deviceHardwareId.equals(deviceHardwareId))
      ..where((d) => d.assignedPatientId.isNotNull()))
      .getSingleOrNull();
    
    if (device?.assignedPatientId == null) return null;
    return getPatientById(device!.assignedPatientId!);
  }
  
  Future<int> insertPatient(PatientsCompanion patient) =>
    into(patients).insert(patient, mode: InsertMode.insertOrReplace);
  
  Future<int> updatePatient(LocalPatient patient) =>
    (update(patients)..where((p) => p.id.equals(patient.id))).write(
      PatientsCompanion(
        latestRiskTier: Value(patient.latestRiskTier),
        latestRiskScore: Value(patient.latestRiskScore),
        updatedAt: Value(DateTime.now()),
        synced: const Value(false),
      ),
    );
  
  // ============== DEVICE OPERATIONS ==============
  
  Future<List<LocalDevice>> getAllDevices() => select(devices).get();
  
  Future<LocalDevice?> getDeviceByHardwareId(String hardwareId) =>
    (select(devices)..where((d) => d.deviceHardwareId.equals(hardwareId)))
      .getSingleOrNull();
  
  Future<List<LocalDevice>> getDevicesForPatient(String patientId) =>
    (select(devices)..where((d) => d.assignedPatientId.equals(patientId))).get();
  
  Future<int> insertDevice(DevicesCompanion device) =>
    into(devices).insert(device, mode: InsertMode.insertOrReplace);
  
  Future<void> assignDeviceToPatient(String deviceId, String patientId) =>
    (update(devices)..where((d) => d.id.equals(deviceId))).write(
      DevicesCompanion(
        assignedPatientId: Value(patientId),
        synced: const Value(false),
      ),
    );
  
  Future<void> updateDeviceBattery(String hardwareId, int level) =>
    (update(devices)..where((d) => d.deviceHardwareId.equals(hardwareId))).write(
      DevicesCompanion(
        batteryLevel: Value(level),
        lastSeenAt: Value(DateTime.now()),
      ),
    );
  
  // ============== READING OPERATIONS ==============
  
  Future<List<LocalReading>> getReadingsForPatient(String patientId, {int limit = 50}) =>
    (select(readings)
      ..where((r) => r.patientId.equals(patientId))
      ..orderBy([(r) => OrderingTerm.desc(r.recordedAt)])
      ..limit(limit))
      .get();
  
  Future<List<LocalReading>> getReadingsForSession(String sessionId) =>
    (select(readings)..where((r) => r.sessionId.equals(sessionId))).get();
  
  Future<int> insertReading(ReadingsCompanion reading) async {
    final result = await into(readings).insert(reading, mode: InsertMode.insertOrReplace);
    
    // Add to outbox for sync
    await into(syncOutbox).insert(SyncOutboxCompanion.insert(
      syncTableName: 'readings',
      recordId: reading.id.value,
      operation: 'insert',
      payloadJson: _readingToJson(reading),
      createdAt: DateTime.now(),
    ));
    
    return result;
  }
  
  // ============== SESSION OPERATIONS ==============
  
  Future<LocalSession?> getSessionById(String id) =>
    (select(monitoringSessions)..where((s) => s.id.equals(id))).getSingleOrNull();
  
  Future<int> insertSession(MonitoringSessionsCompanion session) async {
    final result = await into(monitoringSessions).insert(session, mode: InsertMode.insertOrReplace);
    
    await into(syncOutbox).insert(SyncOutboxCompanion.insert(
      syncTableName: 'monitoring_sessions',
      recordId: session.id.value,
      operation: 'insert',
      payloadJson: _sessionToJson(session),
      createdAt: DateTime.now(),
    ));
    
    return result;
  }
  
  Future<void> endSession(String sessionId) async {
    final endTime = DateTime.now();
    await (update(monitoringSessions)..where((s) => s.id.equals(sessionId))).write(
      MonitoringSessionsCompanion(
        endedAt: Value(endTime),
        synced: const Value(false),
      ),
    );
  }
  
  // ============== REFERRAL OPERATIONS ==============
  
  Future<List<LocalReferral>> getPendingReferrals() =>
    (select(referrals)..where((r) => r.status.equals('pending'))).get();
  
  Future<int> insertReferral(ReferralsCompanion referral) async {
    final result = await into(referrals).insert(referral, mode: InsertMode.insertOrReplace);
    
    await into(syncOutbox).insert(SyncOutboxCompanion.insert(
      syncTableName: 'referrals',
      recordId: referral.id.value,
      operation: 'insert',
      payloadJson: _referralToJson(referral),
      createdAt: DateTime.now(),
    ));
    
    return result;
  }
  
  // ============== SYNC OUTBOX ==============
  
  Future<List<LocalSyncOutbox>> getPendingSyncRecords({int limit = 100}) =>
    (select(syncOutbox)
      ..orderBy([(s) => OrderingTerm.asc(s.createdAt)])
      ..limit(limit))
      .get();
  
  Future<void> markRecordSynced(int outboxId) =>
    (delete(syncOutbox)..where((s) => s.id.equals(outboxId))).go();
  
  Future<void> markSyncFailed(int outboxId, String error) =>
    (update(syncOutbox)..where((s) => s.id.equals(outboxId))).write(
      SyncOutboxCompanion(
        retryCount: const Value.absent(), // Will be incremented manually
        lastError: Value(error),
      ),
    );
  
  Future<int> getPendingSyncCount() async {
    final count = await (selectOnly(syncOutbox)..addColumns([syncOutbox.id.count()])).getSingle();
    return count.read(syncOutbox.id.count()) ?? 0;
  }
  
  // ============== HELPERS ==============
  
  String _readingToJson(ReadingsCompanion r) {
    return '{"id":"${r.id.value}","sessionId":"${r.sessionId.value}","patientId":"${r.patientId.value}",'
           '"vitalType":"${r.vitalType.value}","values":${r.valuesJson.value},'
           '"recordedAt":"${r.recordedAt.value.toIso8601String()}",'
           '"dangerLevel":"${r.dangerLevel.value}","source":"${r.source.value}",'
           '"deviceName":${r.deviceName.value != null ? '"${r.deviceName.value}"' : 'null'}}';
  }
  
  String _sessionToJson(MonitoringSessionsCompanion s) {
    return '{"id":"${s.id.value}","patientId":"${s.patientId.value}",'
           '"startedAt":"${s.startedAt.value.toIso8601String()}",'
           '"locationLat":${s.locationLat.value},"locationLng":${s.locationLng.value},'
           '"deviceId":${s.deviceId.value != null ? '"${s.deviceId.value}"' : 'null'}}';
  }
  
  String _referralToJson(ReferralsCompanion r) {
    return '{"id":"${r.id.value}","patientId":"${r.patientId.value}",'
           '"triggerType":"${r.triggerType.value}",'
           '"triggerDetail":${r.triggerDetailJson.value ?? 'null'},'
           '"vitalsSnapshot":${r.vitalsSnapshotJson.value ?? 'null'},'
           '"aiRiskScore":${r.aiRiskScore.value},'
           '"facilityId":${r.facilityId.value != null ? '"${r.facilityId.value}"' : 'null'},'
           '"status":"${r.status.value}","createdAt":"${r.createdAt.value.toIso8601String()}"}';
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'mama_app.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
