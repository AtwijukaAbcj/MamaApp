// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $PatientsTable extends Patients
    with TableInfo<$PatientsTable, LocalPatient> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PatientsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _fullNameMeta =
      const VerificationMeta('fullName');
  @override
  late final GeneratedColumn<String> fullName = GeneratedColumn<String>(
      'full_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
      'phone', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _ageMeta = const VerificationMeta('age');
  @override
  late final GeneratedColumn<int> age = GeneratedColumn<int>(
      'age', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _gravidaMeta =
      const VerificationMeta('gravida');
  @override
  late final GeneratedColumn<int> gravida = GeneratedColumn<int>(
      'gravida', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _parityMeta = const VerificationMeta('parity');
  @override
  late final GeneratedColumn<int> parity = GeneratedColumn<int>(
      'parity', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _isPregnantMeta =
      const VerificationMeta('isPregnant');
  @override
  late final GeneratedColumn<bool> isPregnant = GeneratedColumn<bool>(
      'is_pregnant', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_pregnant" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _gestationalWeeksAtRegistrationMeta =
      const VerificationMeta('gestationalWeeksAtRegistration');
  @override
  late final GeneratedColumn<int> gestationalWeeksAtRegistration =
      GeneratedColumn<int>(
          'gestational_weeks_at_registration', aliasedName, true,
          type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _pregnancyRegisteredAtMeta =
      const VerificationMeta('pregnancyRegisteredAt');
  @override
  late final GeneratedColumn<DateTime> pregnancyRegisteredAt =
      GeneratedColumn<DateTime>('pregnancy_registered_at', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _expectedDeliveryDateMeta =
      const VerificationMeta('expectedDeliveryDate');
  @override
  late final GeneratedColumn<String> expectedDeliveryDate =
      GeneratedColumn<String>('expected_delivery_date', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _priorStillbirthMeta =
      const VerificationMeta('priorStillbirth');
  @override
  late final GeneratedColumn<bool> priorStillbirth = GeneratedColumn<bool>(
      'prior_stillbirth', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("prior_stillbirth" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _priorCsectionMeta =
      const VerificationMeta('priorCsection');
  @override
  late final GeneratedColumn<bool> priorCsection = GeneratedColumn<bool>(
      'prior_csection', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("prior_csection" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _priorPreeclampsiaMeta =
      const VerificationMeta('priorPreeclampsia');
  @override
  late final GeneratedColumn<bool> priorPreeclampsia = GeneratedColumn<bool>(
      'prior_preeclampsia', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("prior_preeclampsia" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _hivPositiveMeta =
      const VerificationMeta('hivPositive');
  @override
  late final GeneratedColumn<bool> hivPositive = GeneratedColumn<bool>(
      'hiv_positive', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("hiv_positive" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _diabetesMeta =
      const VerificationMeta('diabetes');
  @override
  late final GeneratedColumn<bool> diabetes = GeneratedColumn<bool>(
      'diabetes', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("diabetes" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _anaemiaMeta =
      const VerificationMeta('anaemia');
  @override
  late final GeneratedColumn<bool> anaemia = GeneratedColumn<bool>(
      'anaemia', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("anaemia" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _multiplePregnancyMeta =
      const VerificationMeta('multiplePregnancy');
  @override
  late final GeneratedColumn<bool> multiplePregnancy = GeneratedColumn<bool>(
      'multiple_pregnancy', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("multiple_pregnancy" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _nearestFacilityIdMeta =
      const VerificationMeta('nearestFacilityId');
  @override
  late final GeneratedColumn<String> nearestFacilityId =
      GeneratedColumn<String>('nearest_facility_id', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _latestRiskTierMeta =
      const VerificationMeta('latestRiskTier');
  @override
  late final GeneratedColumn<String> latestRiskTier = GeneratedColumn<String>(
      'latest_risk_tier', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _latestRiskScoreMeta =
      const VerificationMeta('latestRiskScore');
  @override
  late final GeneratedColumn<double> latestRiskScore = GeneratedColumn<double>(
      'latest_risk_score', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
      'synced', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("synced" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        fullName,
        phone,
        age,
        gravida,
        parity,
        isPregnant,
        gestationalWeeksAtRegistration,
        pregnancyRegisteredAt,
        expectedDeliveryDate,
        priorStillbirth,
        priorCsection,
        priorPreeclampsia,
        hivPositive,
        diabetes,
        anaemia,
        multiplePregnancy,
        nearestFacilityId,
        latestRiskTier,
        latestRiskScore,
        createdAt,
        updatedAt,
        synced
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'patients';
  @override
  VerificationContext validateIntegrity(Insertable<LocalPatient> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('full_name')) {
      context.handle(_fullNameMeta,
          fullName.isAcceptableOrUnknown(data['full_name']!, _fullNameMeta));
    } else if (isInserting) {
      context.missing(_fullNameMeta);
    }
    if (data.containsKey('phone')) {
      context.handle(
          _phoneMeta, phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta));
    }
    if (data.containsKey('age')) {
      context.handle(
          _ageMeta, age.isAcceptableOrUnknown(data['age']!, _ageMeta));
    }
    if (data.containsKey('gravida')) {
      context.handle(_gravidaMeta,
          gravida.isAcceptableOrUnknown(data['gravida']!, _gravidaMeta));
    }
    if (data.containsKey('parity')) {
      context.handle(_parityMeta,
          parity.isAcceptableOrUnknown(data['parity']!, _parityMeta));
    }
    if (data.containsKey('is_pregnant')) {
      context.handle(
          _isPregnantMeta,
          isPregnant.isAcceptableOrUnknown(
              data['is_pregnant']!, _isPregnantMeta));
    }
    if (data.containsKey('gestational_weeks_at_registration')) {
      context.handle(
          _gestationalWeeksAtRegistrationMeta,
          gestationalWeeksAtRegistration.isAcceptableOrUnknown(
              data['gestational_weeks_at_registration']!,
              _gestationalWeeksAtRegistrationMeta));
    }
    if (data.containsKey('pregnancy_registered_at')) {
      context.handle(
          _pregnancyRegisteredAtMeta,
          pregnancyRegisteredAt.isAcceptableOrUnknown(
              data['pregnancy_registered_at']!, _pregnancyRegisteredAtMeta));
    }
    if (data.containsKey('expected_delivery_date')) {
      context.handle(
          _expectedDeliveryDateMeta,
          expectedDeliveryDate.isAcceptableOrUnknown(
              data['expected_delivery_date']!, _expectedDeliveryDateMeta));
    }
    if (data.containsKey('prior_stillbirth')) {
      context.handle(
          _priorStillbirthMeta,
          priorStillbirth.isAcceptableOrUnknown(
              data['prior_stillbirth']!, _priorStillbirthMeta));
    }
    if (data.containsKey('prior_csection')) {
      context.handle(
          _priorCsectionMeta,
          priorCsection.isAcceptableOrUnknown(
              data['prior_csection']!, _priorCsectionMeta));
    }
    if (data.containsKey('prior_preeclampsia')) {
      context.handle(
          _priorPreeclampsiaMeta,
          priorPreeclampsia.isAcceptableOrUnknown(
              data['prior_preeclampsia']!, _priorPreeclampsiaMeta));
    }
    if (data.containsKey('hiv_positive')) {
      context.handle(
          _hivPositiveMeta,
          hivPositive.isAcceptableOrUnknown(
              data['hiv_positive']!, _hivPositiveMeta));
    }
    if (data.containsKey('diabetes')) {
      context.handle(_diabetesMeta,
          diabetes.isAcceptableOrUnknown(data['diabetes']!, _diabetesMeta));
    }
    if (data.containsKey('anaemia')) {
      context.handle(_anaemiaMeta,
          anaemia.isAcceptableOrUnknown(data['anaemia']!, _anaemiaMeta));
    }
    if (data.containsKey('multiple_pregnancy')) {
      context.handle(
          _multiplePregnancyMeta,
          multiplePregnancy.isAcceptableOrUnknown(
              data['multiple_pregnancy']!, _multiplePregnancyMeta));
    }
    if (data.containsKey('nearest_facility_id')) {
      context.handle(
          _nearestFacilityIdMeta,
          nearestFacilityId.isAcceptableOrUnknown(
              data['nearest_facility_id']!, _nearestFacilityIdMeta));
    }
    if (data.containsKey('latest_risk_tier')) {
      context.handle(
          _latestRiskTierMeta,
          latestRiskTier.isAcceptableOrUnknown(
              data['latest_risk_tier']!, _latestRiskTierMeta));
    }
    if (data.containsKey('latest_risk_score')) {
      context.handle(
          _latestRiskScoreMeta,
          latestRiskScore.isAcceptableOrUnknown(
              data['latest_risk_score']!, _latestRiskScoreMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('synced')) {
      context.handle(_syncedMeta,
          synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalPatient map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalPatient(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      fullName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}full_name'])!,
      phone: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}phone']),
      age: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}age']),
      gravida: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}gravida'])!,
      parity: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}parity'])!,
      isPregnant: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_pregnant'])!,
      gestationalWeeksAtRegistration: attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}gestational_weeks_at_registration']),
      pregnancyRegisteredAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime,
          data['${effectivePrefix}pregnancy_registered_at']),
      expectedDeliveryDate: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}expected_delivery_date']),
      priorStillbirth: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}prior_stillbirth'])!,
      priorCsection: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}prior_csection'])!,
      priorPreeclampsia: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}prior_preeclampsia'])!,
      hivPositive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}hiv_positive'])!,
      diabetes: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}diabetes'])!,
      anaemia: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}anaemia'])!,
      multiplePregnancy: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}multiple_pregnancy'])!,
      nearestFacilityId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}nearest_facility_id']),
      latestRiskTier: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}latest_risk_tier']),
      latestRiskScore: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}latest_risk_score']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      synced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}synced'])!,
    );
  }

  @override
  $PatientsTable createAlias(String alias) {
    return $PatientsTable(attachedDatabase, alias);
  }
}

class LocalPatient extends DataClass implements Insertable<LocalPatient> {
  final String id;
  final String fullName;
  final String? phone;
  final int? age;
  final int gravida;
  final int parity;
  final bool isPregnant;
  final int? gestationalWeeksAtRegistration;
  final DateTime? pregnancyRegisteredAt;
  final String? expectedDeliveryDate;
  final bool priorStillbirth;
  final bool priorCsection;
  final bool priorPreeclampsia;
  final bool hivPositive;
  final bool diabetes;
  final bool anaemia;
  final bool multiplePregnancy;
  final String? nearestFacilityId;
  final String? latestRiskTier;
  final double? latestRiskScore;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool synced;
  const LocalPatient(
      {required this.id,
      required this.fullName,
      this.phone,
      this.age,
      required this.gravida,
      required this.parity,
      required this.isPregnant,
      this.gestationalWeeksAtRegistration,
      this.pregnancyRegisteredAt,
      this.expectedDeliveryDate,
      required this.priorStillbirth,
      required this.priorCsection,
      required this.priorPreeclampsia,
      required this.hivPositive,
      required this.diabetes,
      required this.anaemia,
      required this.multiplePregnancy,
      this.nearestFacilityId,
      this.latestRiskTier,
      this.latestRiskScore,
      required this.createdAt,
      required this.updatedAt,
      required this.synced});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['full_name'] = Variable<String>(fullName);
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    if (!nullToAbsent || age != null) {
      map['age'] = Variable<int>(age);
    }
    map['gravida'] = Variable<int>(gravida);
    map['parity'] = Variable<int>(parity);
    map['is_pregnant'] = Variable<bool>(isPregnant);
    if (!nullToAbsent || gestationalWeeksAtRegistration != null) {
      map['gestational_weeks_at_registration'] =
          Variable<int>(gestationalWeeksAtRegistration);
    }
    if (!nullToAbsent || pregnancyRegisteredAt != null) {
      map['pregnancy_registered_at'] =
          Variable<DateTime>(pregnancyRegisteredAt);
    }
    if (!nullToAbsent || expectedDeliveryDate != null) {
      map['expected_delivery_date'] = Variable<String>(expectedDeliveryDate);
    }
    map['prior_stillbirth'] = Variable<bool>(priorStillbirth);
    map['prior_csection'] = Variable<bool>(priorCsection);
    map['prior_preeclampsia'] = Variable<bool>(priorPreeclampsia);
    map['hiv_positive'] = Variable<bool>(hivPositive);
    map['diabetes'] = Variable<bool>(diabetes);
    map['anaemia'] = Variable<bool>(anaemia);
    map['multiple_pregnancy'] = Variable<bool>(multiplePregnancy);
    if (!nullToAbsent || nearestFacilityId != null) {
      map['nearest_facility_id'] = Variable<String>(nearestFacilityId);
    }
    if (!nullToAbsent || latestRiskTier != null) {
      map['latest_risk_tier'] = Variable<String>(latestRiskTier);
    }
    if (!nullToAbsent || latestRiskScore != null) {
      map['latest_risk_score'] = Variable<double>(latestRiskScore);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['synced'] = Variable<bool>(synced);
    return map;
  }

  PatientsCompanion toCompanion(bool nullToAbsent) {
    return PatientsCompanion(
      id: Value(id),
      fullName: Value(fullName),
      phone:
          phone == null && nullToAbsent ? const Value.absent() : Value(phone),
      age: age == null && nullToAbsent ? const Value.absent() : Value(age),
      gravida: Value(gravida),
      parity: Value(parity),
      isPregnant: Value(isPregnant),
      gestationalWeeksAtRegistration:
          gestationalWeeksAtRegistration == null && nullToAbsent
              ? const Value.absent()
              : Value(gestationalWeeksAtRegistration),
      pregnancyRegisteredAt: pregnancyRegisteredAt == null && nullToAbsent
          ? const Value.absent()
          : Value(pregnancyRegisteredAt),
      expectedDeliveryDate: expectedDeliveryDate == null && nullToAbsent
          ? const Value.absent()
          : Value(expectedDeliveryDate),
      priorStillbirth: Value(priorStillbirth),
      priorCsection: Value(priorCsection),
      priorPreeclampsia: Value(priorPreeclampsia),
      hivPositive: Value(hivPositive),
      diabetes: Value(diabetes),
      anaemia: Value(anaemia),
      multiplePregnancy: Value(multiplePregnancy),
      nearestFacilityId: nearestFacilityId == null && nullToAbsent
          ? const Value.absent()
          : Value(nearestFacilityId),
      latestRiskTier: latestRiskTier == null && nullToAbsent
          ? const Value.absent()
          : Value(latestRiskTier),
      latestRiskScore: latestRiskScore == null && nullToAbsent
          ? const Value.absent()
          : Value(latestRiskScore),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      synced: Value(synced),
    );
  }

  factory LocalPatient.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalPatient(
      id: serializer.fromJson<String>(json['id']),
      fullName: serializer.fromJson<String>(json['fullName']),
      phone: serializer.fromJson<String?>(json['phone']),
      age: serializer.fromJson<int?>(json['age']),
      gravida: serializer.fromJson<int>(json['gravida']),
      parity: serializer.fromJson<int>(json['parity']),
      isPregnant: serializer.fromJson<bool>(json['isPregnant']),
      gestationalWeeksAtRegistration:
          serializer.fromJson<int?>(json['gestationalWeeksAtRegistration']),
      pregnancyRegisteredAt:
          serializer.fromJson<DateTime?>(json['pregnancyRegisteredAt']),
      expectedDeliveryDate:
          serializer.fromJson<String?>(json['expectedDeliveryDate']),
      priorStillbirth: serializer.fromJson<bool>(json['priorStillbirth']),
      priorCsection: serializer.fromJson<bool>(json['priorCsection']),
      priorPreeclampsia: serializer.fromJson<bool>(json['priorPreeclampsia']),
      hivPositive: serializer.fromJson<bool>(json['hivPositive']),
      diabetes: serializer.fromJson<bool>(json['diabetes']),
      anaemia: serializer.fromJson<bool>(json['anaemia']),
      multiplePregnancy: serializer.fromJson<bool>(json['multiplePregnancy']),
      nearestFacilityId:
          serializer.fromJson<String?>(json['nearestFacilityId']),
      latestRiskTier: serializer.fromJson<String?>(json['latestRiskTier']),
      latestRiskScore: serializer.fromJson<double?>(json['latestRiskScore']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      synced: serializer.fromJson<bool>(json['synced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'fullName': serializer.toJson<String>(fullName),
      'phone': serializer.toJson<String?>(phone),
      'age': serializer.toJson<int?>(age),
      'gravida': serializer.toJson<int>(gravida),
      'parity': serializer.toJson<int>(parity),
      'isPregnant': serializer.toJson<bool>(isPregnant),
      'gestationalWeeksAtRegistration':
          serializer.toJson<int?>(gestationalWeeksAtRegistration),
      'pregnancyRegisteredAt':
          serializer.toJson<DateTime?>(pregnancyRegisteredAt),
      'expectedDeliveryDate': serializer.toJson<String?>(expectedDeliveryDate),
      'priorStillbirth': serializer.toJson<bool>(priorStillbirth),
      'priorCsection': serializer.toJson<bool>(priorCsection),
      'priorPreeclampsia': serializer.toJson<bool>(priorPreeclampsia),
      'hivPositive': serializer.toJson<bool>(hivPositive),
      'diabetes': serializer.toJson<bool>(diabetes),
      'anaemia': serializer.toJson<bool>(anaemia),
      'multiplePregnancy': serializer.toJson<bool>(multiplePregnancy),
      'nearestFacilityId': serializer.toJson<String?>(nearestFacilityId),
      'latestRiskTier': serializer.toJson<String?>(latestRiskTier),
      'latestRiskScore': serializer.toJson<double?>(latestRiskScore),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'synced': serializer.toJson<bool>(synced),
    };
  }

  LocalPatient copyWith(
          {String? id,
          String? fullName,
          Value<String?> phone = const Value.absent(),
          Value<int?> age = const Value.absent(),
          int? gravida,
          int? parity,
          bool? isPregnant,
          Value<int?> gestationalWeeksAtRegistration = const Value.absent(),
          Value<DateTime?> pregnancyRegisteredAt = const Value.absent(),
          Value<String?> expectedDeliveryDate = const Value.absent(),
          bool? priorStillbirth,
          bool? priorCsection,
          bool? priorPreeclampsia,
          bool? hivPositive,
          bool? diabetes,
          bool? anaemia,
          bool? multiplePregnancy,
          Value<String?> nearestFacilityId = const Value.absent(),
          Value<String?> latestRiskTier = const Value.absent(),
          Value<double?> latestRiskScore = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt,
          bool? synced}) =>
      LocalPatient(
        id: id ?? this.id,
        fullName: fullName ?? this.fullName,
        phone: phone.present ? phone.value : this.phone,
        age: age.present ? age.value : this.age,
        gravida: gravida ?? this.gravida,
        parity: parity ?? this.parity,
        isPregnant: isPregnant ?? this.isPregnant,
        gestationalWeeksAtRegistration: gestationalWeeksAtRegistration.present
            ? gestationalWeeksAtRegistration.value
            : this.gestationalWeeksAtRegistration,
        pregnancyRegisteredAt: pregnancyRegisteredAt.present
            ? pregnancyRegisteredAt.value
            : this.pregnancyRegisteredAt,
        expectedDeliveryDate: expectedDeliveryDate.present
            ? expectedDeliveryDate.value
            : this.expectedDeliveryDate,
        priorStillbirth: priorStillbirth ?? this.priorStillbirth,
        priorCsection: priorCsection ?? this.priorCsection,
        priorPreeclampsia: priorPreeclampsia ?? this.priorPreeclampsia,
        hivPositive: hivPositive ?? this.hivPositive,
        diabetes: diabetes ?? this.diabetes,
        anaemia: anaemia ?? this.anaemia,
        multiplePregnancy: multiplePregnancy ?? this.multiplePregnancy,
        nearestFacilityId: nearestFacilityId.present
            ? nearestFacilityId.value
            : this.nearestFacilityId,
        latestRiskTier:
            latestRiskTier.present ? latestRiskTier.value : this.latestRiskTier,
        latestRiskScore: latestRiskScore.present
            ? latestRiskScore.value
            : this.latestRiskScore,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        synced: synced ?? this.synced,
      );
  LocalPatient copyWithCompanion(PatientsCompanion data) {
    return LocalPatient(
      id: data.id.present ? data.id.value : this.id,
      fullName: data.fullName.present ? data.fullName.value : this.fullName,
      phone: data.phone.present ? data.phone.value : this.phone,
      age: data.age.present ? data.age.value : this.age,
      gravida: data.gravida.present ? data.gravida.value : this.gravida,
      parity: data.parity.present ? data.parity.value : this.parity,
      isPregnant:
          data.isPregnant.present ? data.isPregnant.value : this.isPregnant,
      gestationalWeeksAtRegistration:
          data.gestationalWeeksAtRegistration.present
              ? data.gestationalWeeksAtRegistration.value
              : this.gestationalWeeksAtRegistration,
      pregnancyRegisteredAt: data.pregnancyRegisteredAt.present
          ? data.pregnancyRegisteredAt.value
          : this.pregnancyRegisteredAt,
      expectedDeliveryDate: data.expectedDeliveryDate.present
          ? data.expectedDeliveryDate.value
          : this.expectedDeliveryDate,
      priorStillbirth: data.priorStillbirth.present
          ? data.priorStillbirth.value
          : this.priorStillbirth,
      priorCsection: data.priorCsection.present
          ? data.priorCsection.value
          : this.priorCsection,
      priorPreeclampsia: data.priorPreeclampsia.present
          ? data.priorPreeclampsia.value
          : this.priorPreeclampsia,
      hivPositive:
          data.hivPositive.present ? data.hivPositive.value : this.hivPositive,
      diabetes: data.diabetes.present ? data.diabetes.value : this.diabetes,
      anaemia: data.anaemia.present ? data.anaemia.value : this.anaemia,
      multiplePregnancy: data.multiplePregnancy.present
          ? data.multiplePregnancy.value
          : this.multiplePregnancy,
      nearestFacilityId: data.nearestFacilityId.present
          ? data.nearestFacilityId.value
          : this.nearestFacilityId,
      latestRiskTier: data.latestRiskTier.present
          ? data.latestRiskTier.value
          : this.latestRiskTier,
      latestRiskScore: data.latestRiskScore.present
          ? data.latestRiskScore.value
          : this.latestRiskScore,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      synced: data.synced.present ? data.synced.value : this.synced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalPatient(')
          ..write('id: $id, ')
          ..write('fullName: $fullName, ')
          ..write('phone: $phone, ')
          ..write('age: $age, ')
          ..write('gravida: $gravida, ')
          ..write('parity: $parity, ')
          ..write('isPregnant: $isPregnant, ')
          ..write(
              'gestationalWeeksAtRegistration: $gestationalWeeksAtRegistration, ')
          ..write('pregnancyRegisteredAt: $pregnancyRegisteredAt, ')
          ..write('expectedDeliveryDate: $expectedDeliveryDate, ')
          ..write('priorStillbirth: $priorStillbirth, ')
          ..write('priorCsection: $priorCsection, ')
          ..write('priorPreeclampsia: $priorPreeclampsia, ')
          ..write('hivPositive: $hivPositive, ')
          ..write('diabetes: $diabetes, ')
          ..write('anaemia: $anaemia, ')
          ..write('multiplePregnancy: $multiplePregnancy, ')
          ..write('nearestFacilityId: $nearestFacilityId, ')
          ..write('latestRiskTier: $latestRiskTier, ')
          ..write('latestRiskScore: $latestRiskScore, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('synced: $synced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
        id,
        fullName,
        phone,
        age,
        gravida,
        parity,
        isPregnant,
        gestationalWeeksAtRegistration,
        pregnancyRegisteredAt,
        expectedDeliveryDate,
        priorStillbirth,
        priorCsection,
        priorPreeclampsia,
        hivPositive,
        diabetes,
        anaemia,
        multiplePregnancy,
        nearestFacilityId,
        latestRiskTier,
        latestRiskScore,
        createdAt,
        updatedAt,
        synced
      ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalPatient &&
          other.id == this.id &&
          other.fullName == this.fullName &&
          other.phone == this.phone &&
          other.age == this.age &&
          other.gravida == this.gravida &&
          other.parity == this.parity &&
          other.isPregnant == this.isPregnant &&
          other.gestationalWeeksAtRegistration ==
              this.gestationalWeeksAtRegistration &&
          other.pregnancyRegisteredAt == this.pregnancyRegisteredAt &&
          other.expectedDeliveryDate == this.expectedDeliveryDate &&
          other.priorStillbirth == this.priorStillbirth &&
          other.priorCsection == this.priorCsection &&
          other.priorPreeclampsia == this.priorPreeclampsia &&
          other.hivPositive == this.hivPositive &&
          other.diabetes == this.diabetes &&
          other.anaemia == this.anaemia &&
          other.multiplePregnancy == this.multiplePregnancy &&
          other.nearestFacilityId == this.nearestFacilityId &&
          other.latestRiskTier == this.latestRiskTier &&
          other.latestRiskScore == this.latestRiskScore &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.synced == this.synced);
}

class PatientsCompanion extends UpdateCompanion<LocalPatient> {
  final Value<String> id;
  final Value<String> fullName;
  final Value<String?> phone;
  final Value<int?> age;
  final Value<int> gravida;
  final Value<int> parity;
  final Value<bool> isPregnant;
  final Value<int?> gestationalWeeksAtRegistration;
  final Value<DateTime?> pregnancyRegisteredAt;
  final Value<String?> expectedDeliveryDate;
  final Value<bool> priorStillbirth;
  final Value<bool> priorCsection;
  final Value<bool> priorPreeclampsia;
  final Value<bool> hivPositive;
  final Value<bool> diabetes;
  final Value<bool> anaemia;
  final Value<bool> multiplePregnancy;
  final Value<String?> nearestFacilityId;
  final Value<String?> latestRiskTier;
  final Value<double?> latestRiskScore;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> synced;
  final Value<int> rowid;
  const PatientsCompanion({
    this.id = const Value.absent(),
    this.fullName = const Value.absent(),
    this.phone = const Value.absent(),
    this.age = const Value.absent(),
    this.gravida = const Value.absent(),
    this.parity = const Value.absent(),
    this.isPregnant = const Value.absent(),
    this.gestationalWeeksAtRegistration = const Value.absent(),
    this.pregnancyRegisteredAt = const Value.absent(),
    this.expectedDeliveryDate = const Value.absent(),
    this.priorStillbirth = const Value.absent(),
    this.priorCsection = const Value.absent(),
    this.priorPreeclampsia = const Value.absent(),
    this.hivPositive = const Value.absent(),
    this.diabetes = const Value.absent(),
    this.anaemia = const Value.absent(),
    this.multiplePregnancy = const Value.absent(),
    this.nearestFacilityId = const Value.absent(),
    this.latestRiskTier = const Value.absent(),
    this.latestRiskScore = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PatientsCompanion.insert({
    required String id,
    required String fullName,
    this.phone = const Value.absent(),
    this.age = const Value.absent(),
    this.gravida = const Value.absent(),
    this.parity = const Value.absent(),
    this.isPregnant = const Value.absent(),
    this.gestationalWeeksAtRegistration = const Value.absent(),
    this.pregnancyRegisteredAt = const Value.absent(),
    this.expectedDeliveryDate = const Value.absent(),
    this.priorStillbirth = const Value.absent(),
    this.priorCsection = const Value.absent(),
    this.priorPreeclampsia = const Value.absent(),
    this.hivPositive = const Value.absent(),
    this.diabetes = const Value.absent(),
    this.anaemia = const Value.absent(),
    this.multiplePregnancy = const Value.absent(),
    this.nearestFacilityId = const Value.absent(),
    this.latestRiskTier = const Value.absent(),
    this.latestRiskScore = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        fullName = Value(fullName),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<LocalPatient> custom({
    Expression<String>? id,
    Expression<String>? fullName,
    Expression<String>? phone,
    Expression<int>? age,
    Expression<int>? gravida,
    Expression<int>? parity,
    Expression<bool>? isPregnant,
    Expression<int>? gestationalWeeksAtRegistration,
    Expression<DateTime>? pregnancyRegisteredAt,
    Expression<String>? expectedDeliveryDate,
    Expression<bool>? priorStillbirth,
    Expression<bool>? priorCsection,
    Expression<bool>? priorPreeclampsia,
    Expression<bool>? hivPositive,
    Expression<bool>? diabetes,
    Expression<bool>? anaemia,
    Expression<bool>? multiplePregnancy,
    Expression<String>? nearestFacilityId,
    Expression<String>? latestRiskTier,
    Expression<double>? latestRiskScore,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? synced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (fullName != null) 'full_name': fullName,
      if (phone != null) 'phone': phone,
      if (age != null) 'age': age,
      if (gravida != null) 'gravida': gravida,
      if (parity != null) 'parity': parity,
      if (isPregnant != null) 'is_pregnant': isPregnant,
      if (gestationalWeeksAtRegistration != null)
        'gestational_weeks_at_registration': gestationalWeeksAtRegistration,
      if (pregnancyRegisteredAt != null)
        'pregnancy_registered_at': pregnancyRegisteredAt,
      if (expectedDeliveryDate != null)
        'expected_delivery_date': expectedDeliveryDate,
      if (priorStillbirth != null) 'prior_stillbirth': priorStillbirth,
      if (priorCsection != null) 'prior_csection': priorCsection,
      if (priorPreeclampsia != null) 'prior_preeclampsia': priorPreeclampsia,
      if (hivPositive != null) 'hiv_positive': hivPositive,
      if (diabetes != null) 'diabetes': diabetes,
      if (anaemia != null) 'anaemia': anaemia,
      if (multiplePregnancy != null) 'multiple_pregnancy': multiplePregnancy,
      if (nearestFacilityId != null) 'nearest_facility_id': nearestFacilityId,
      if (latestRiskTier != null) 'latest_risk_tier': latestRiskTier,
      if (latestRiskScore != null) 'latest_risk_score': latestRiskScore,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (synced != null) 'synced': synced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PatientsCompanion copyWith(
      {Value<String>? id,
      Value<String>? fullName,
      Value<String?>? phone,
      Value<int?>? age,
      Value<int>? gravida,
      Value<int>? parity,
      Value<bool>? isPregnant,
      Value<int?>? gestationalWeeksAtRegistration,
      Value<DateTime?>? pregnancyRegisteredAt,
      Value<String?>? expectedDeliveryDate,
      Value<bool>? priorStillbirth,
      Value<bool>? priorCsection,
      Value<bool>? priorPreeclampsia,
      Value<bool>? hivPositive,
      Value<bool>? diabetes,
      Value<bool>? anaemia,
      Value<bool>? multiplePregnancy,
      Value<String?>? nearestFacilityId,
      Value<String?>? latestRiskTier,
      Value<double?>? latestRiskScore,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<bool>? synced,
      Value<int>? rowid}) {
    return PatientsCompanion(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      age: age ?? this.age,
      gravida: gravida ?? this.gravida,
      parity: parity ?? this.parity,
      isPregnant: isPregnant ?? this.isPregnant,
      gestationalWeeksAtRegistration:
          gestationalWeeksAtRegistration ?? this.gestationalWeeksAtRegistration,
      pregnancyRegisteredAt:
          pregnancyRegisteredAt ?? this.pregnancyRegisteredAt,
      expectedDeliveryDate: expectedDeliveryDate ?? this.expectedDeliveryDate,
      priorStillbirth: priorStillbirth ?? this.priorStillbirth,
      priorCsection: priorCsection ?? this.priorCsection,
      priorPreeclampsia: priorPreeclampsia ?? this.priorPreeclampsia,
      hivPositive: hivPositive ?? this.hivPositive,
      diabetes: diabetes ?? this.diabetes,
      anaemia: anaemia ?? this.anaemia,
      multiplePregnancy: multiplePregnancy ?? this.multiplePregnancy,
      nearestFacilityId: nearestFacilityId ?? this.nearestFacilityId,
      latestRiskTier: latestRiskTier ?? this.latestRiskTier,
      latestRiskScore: latestRiskScore ?? this.latestRiskScore,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      synced: synced ?? this.synced,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (fullName.present) {
      map['full_name'] = Variable<String>(fullName.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (age.present) {
      map['age'] = Variable<int>(age.value);
    }
    if (gravida.present) {
      map['gravida'] = Variable<int>(gravida.value);
    }
    if (parity.present) {
      map['parity'] = Variable<int>(parity.value);
    }
    if (isPregnant.present) {
      map['is_pregnant'] = Variable<bool>(isPregnant.value);
    }
    if (gestationalWeeksAtRegistration.present) {
      map['gestational_weeks_at_registration'] =
          Variable<int>(gestationalWeeksAtRegistration.value);
    }
    if (pregnancyRegisteredAt.present) {
      map['pregnancy_registered_at'] =
          Variable<DateTime>(pregnancyRegisteredAt.value);
    }
    if (expectedDeliveryDate.present) {
      map['expected_delivery_date'] =
          Variable<String>(expectedDeliveryDate.value);
    }
    if (priorStillbirth.present) {
      map['prior_stillbirth'] = Variable<bool>(priorStillbirth.value);
    }
    if (priorCsection.present) {
      map['prior_csection'] = Variable<bool>(priorCsection.value);
    }
    if (priorPreeclampsia.present) {
      map['prior_preeclampsia'] = Variable<bool>(priorPreeclampsia.value);
    }
    if (hivPositive.present) {
      map['hiv_positive'] = Variable<bool>(hivPositive.value);
    }
    if (diabetes.present) {
      map['diabetes'] = Variable<bool>(diabetes.value);
    }
    if (anaemia.present) {
      map['anaemia'] = Variable<bool>(anaemia.value);
    }
    if (multiplePregnancy.present) {
      map['multiple_pregnancy'] = Variable<bool>(multiplePregnancy.value);
    }
    if (nearestFacilityId.present) {
      map['nearest_facility_id'] = Variable<String>(nearestFacilityId.value);
    }
    if (latestRiskTier.present) {
      map['latest_risk_tier'] = Variable<String>(latestRiskTier.value);
    }
    if (latestRiskScore.present) {
      map['latest_risk_score'] = Variable<double>(latestRiskScore.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PatientsCompanion(')
          ..write('id: $id, ')
          ..write('fullName: $fullName, ')
          ..write('phone: $phone, ')
          ..write('age: $age, ')
          ..write('gravida: $gravida, ')
          ..write('parity: $parity, ')
          ..write('isPregnant: $isPregnant, ')
          ..write(
              'gestationalWeeksAtRegistration: $gestationalWeeksAtRegistration, ')
          ..write('pregnancyRegisteredAt: $pregnancyRegisteredAt, ')
          ..write('expectedDeliveryDate: $expectedDeliveryDate, ')
          ..write('priorStillbirth: $priorStillbirth, ')
          ..write('priorCsection: $priorCsection, ')
          ..write('priorPreeclampsia: $priorPreeclampsia, ')
          ..write('hivPositive: $hivPositive, ')
          ..write('diabetes: $diabetes, ')
          ..write('anaemia: $anaemia, ')
          ..write('multiplePregnancy: $multiplePregnancy, ')
          ..write('nearestFacilityId: $nearestFacilityId, ')
          ..write('latestRiskTier: $latestRiskTier, ')
          ..write('latestRiskScore: $latestRiskScore, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('synced: $synced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DevicesTable extends Devices with TableInfo<$DevicesTable, LocalDevice> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DevicesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _deviceHardwareIdMeta =
      const VerificationMeta('deviceHardwareId');
  @override
  late final GeneratedColumn<String> deviceHardwareId = GeneratedColumn<String>(
      'device_hardware_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _deviceNameMeta =
      const VerificationMeta('deviceName');
  @override
  late final GeneratedColumn<String> deviceName = GeneratedColumn<String>(
      'device_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _deviceTypeMeta =
      const VerificationMeta('deviceType');
  @override
  late final GeneratedColumn<String> deviceType = GeneratedColumn<String>(
      'device_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _assignedPatientIdMeta =
      const VerificationMeta('assignedPatientId');
  @override
  late final GeneratedColumn<String> assignedPatientId =
      GeneratedColumn<String>('assigned_patient_id', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('active'));
  static const VerificationMeta _batteryLevelMeta =
      const VerificationMeta('batteryLevel');
  @override
  late final GeneratedColumn<int> batteryLevel = GeneratedColumn<int>(
      'battery_level', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _lastSeenAtMeta =
      const VerificationMeta('lastSeenAt');
  @override
  late final GeneratedColumn<DateTime> lastSeenAt = GeneratedColumn<DateTime>(
      'last_seen_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
      'synced', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("synced" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        deviceHardwareId,
        deviceName,
        deviceType,
        assignedPatientId,
        status,
        batteryLevel,
        lastSeenAt,
        createdAt,
        synced
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'devices';
  @override
  VerificationContext validateIntegrity(Insertable<LocalDevice> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('device_hardware_id')) {
      context.handle(
          _deviceHardwareIdMeta,
          deviceHardwareId.isAcceptableOrUnknown(
              data['device_hardware_id']!, _deviceHardwareIdMeta));
    } else if (isInserting) {
      context.missing(_deviceHardwareIdMeta);
    }
    if (data.containsKey('device_name')) {
      context.handle(
          _deviceNameMeta,
          deviceName.isAcceptableOrUnknown(
              data['device_name']!, _deviceNameMeta));
    } else if (isInserting) {
      context.missing(_deviceNameMeta);
    }
    if (data.containsKey('device_type')) {
      context.handle(
          _deviceTypeMeta,
          deviceType.isAcceptableOrUnknown(
              data['device_type']!, _deviceTypeMeta));
    } else if (isInserting) {
      context.missing(_deviceTypeMeta);
    }
    if (data.containsKey('assigned_patient_id')) {
      context.handle(
          _assignedPatientIdMeta,
          assignedPatientId.isAcceptableOrUnknown(
              data['assigned_patient_id']!, _assignedPatientIdMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('battery_level')) {
      context.handle(
          _batteryLevelMeta,
          batteryLevel.isAcceptableOrUnknown(
              data['battery_level']!, _batteryLevelMeta));
    }
    if (data.containsKey('last_seen_at')) {
      context.handle(
          _lastSeenAtMeta,
          lastSeenAt.isAcceptableOrUnknown(
              data['last_seen_at']!, _lastSeenAtMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('synced')) {
      context.handle(_syncedMeta,
          synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalDevice map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalDevice(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      deviceHardwareId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}device_hardware_id'])!,
      deviceName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}device_name'])!,
      deviceType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}device_type'])!,
      assignedPatientId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}assigned_patient_id']),
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      batteryLevel: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}battery_level']),
      lastSeenAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}last_seen_at']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      synced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}synced'])!,
    );
  }

  @override
  $DevicesTable createAlias(String alias) {
    return $DevicesTable(attachedDatabase, alias);
  }
}

class LocalDevice extends DataClass implements Insertable<LocalDevice> {
  final String id;
  final String deviceHardwareId;
  final String deviceName;
  final String deviceType;
  final String? assignedPatientId;
  final String status;
  final int? batteryLevel;
  final DateTime? lastSeenAt;
  final DateTime createdAt;
  final bool synced;
  const LocalDevice(
      {required this.id,
      required this.deviceHardwareId,
      required this.deviceName,
      required this.deviceType,
      this.assignedPatientId,
      required this.status,
      this.batteryLevel,
      this.lastSeenAt,
      required this.createdAt,
      required this.synced});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['device_hardware_id'] = Variable<String>(deviceHardwareId);
    map['device_name'] = Variable<String>(deviceName);
    map['device_type'] = Variable<String>(deviceType);
    if (!nullToAbsent || assignedPatientId != null) {
      map['assigned_patient_id'] = Variable<String>(assignedPatientId);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || batteryLevel != null) {
      map['battery_level'] = Variable<int>(batteryLevel);
    }
    if (!nullToAbsent || lastSeenAt != null) {
      map['last_seen_at'] = Variable<DateTime>(lastSeenAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['synced'] = Variable<bool>(synced);
    return map;
  }

  DevicesCompanion toCompanion(bool nullToAbsent) {
    return DevicesCompanion(
      id: Value(id),
      deviceHardwareId: Value(deviceHardwareId),
      deviceName: Value(deviceName),
      deviceType: Value(deviceType),
      assignedPatientId: assignedPatientId == null && nullToAbsent
          ? const Value.absent()
          : Value(assignedPatientId),
      status: Value(status),
      batteryLevel: batteryLevel == null && nullToAbsent
          ? const Value.absent()
          : Value(batteryLevel),
      lastSeenAt: lastSeenAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSeenAt),
      createdAt: Value(createdAt),
      synced: Value(synced),
    );
  }

  factory LocalDevice.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalDevice(
      id: serializer.fromJson<String>(json['id']),
      deviceHardwareId: serializer.fromJson<String>(json['deviceHardwareId']),
      deviceName: serializer.fromJson<String>(json['deviceName']),
      deviceType: serializer.fromJson<String>(json['deviceType']),
      assignedPatientId:
          serializer.fromJson<String?>(json['assignedPatientId']),
      status: serializer.fromJson<String>(json['status']),
      batteryLevel: serializer.fromJson<int?>(json['batteryLevel']),
      lastSeenAt: serializer.fromJson<DateTime?>(json['lastSeenAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      synced: serializer.fromJson<bool>(json['synced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'deviceHardwareId': serializer.toJson<String>(deviceHardwareId),
      'deviceName': serializer.toJson<String>(deviceName),
      'deviceType': serializer.toJson<String>(deviceType),
      'assignedPatientId': serializer.toJson<String?>(assignedPatientId),
      'status': serializer.toJson<String>(status),
      'batteryLevel': serializer.toJson<int?>(batteryLevel),
      'lastSeenAt': serializer.toJson<DateTime?>(lastSeenAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'synced': serializer.toJson<bool>(synced),
    };
  }

  LocalDevice copyWith(
          {String? id,
          String? deviceHardwareId,
          String? deviceName,
          String? deviceType,
          Value<String?> assignedPatientId = const Value.absent(),
          String? status,
          Value<int?> batteryLevel = const Value.absent(),
          Value<DateTime?> lastSeenAt = const Value.absent(),
          DateTime? createdAt,
          bool? synced}) =>
      LocalDevice(
        id: id ?? this.id,
        deviceHardwareId: deviceHardwareId ?? this.deviceHardwareId,
        deviceName: deviceName ?? this.deviceName,
        deviceType: deviceType ?? this.deviceType,
        assignedPatientId: assignedPatientId.present
            ? assignedPatientId.value
            : this.assignedPatientId,
        status: status ?? this.status,
        batteryLevel:
            batteryLevel.present ? batteryLevel.value : this.batteryLevel,
        lastSeenAt: lastSeenAt.present ? lastSeenAt.value : this.lastSeenAt,
        createdAt: createdAt ?? this.createdAt,
        synced: synced ?? this.synced,
      );
  LocalDevice copyWithCompanion(DevicesCompanion data) {
    return LocalDevice(
      id: data.id.present ? data.id.value : this.id,
      deviceHardwareId: data.deviceHardwareId.present
          ? data.deviceHardwareId.value
          : this.deviceHardwareId,
      deviceName:
          data.deviceName.present ? data.deviceName.value : this.deviceName,
      deviceType:
          data.deviceType.present ? data.deviceType.value : this.deviceType,
      assignedPatientId: data.assignedPatientId.present
          ? data.assignedPatientId.value
          : this.assignedPatientId,
      status: data.status.present ? data.status.value : this.status,
      batteryLevel: data.batteryLevel.present
          ? data.batteryLevel.value
          : this.batteryLevel,
      lastSeenAt:
          data.lastSeenAt.present ? data.lastSeenAt.value : this.lastSeenAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      synced: data.synced.present ? data.synced.value : this.synced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalDevice(')
          ..write('id: $id, ')
          ..write('deviceHardwareId: $deviceHardwareId, ')
          ..write('deviceName: $deviceName, ')
          ..write('deviceType: $deviceType, ')
          ..write('assignedPatientId: $assignedPatientId, ')
          ..write('status: $status, ')
          ..write('batteryLevel: $batteryLevel, ')
          ..write('lastSeenAt: $lastSeenAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('synced: $synced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, deviceHardwareId, deviceName, deviceType,
      assignedPatientId, status, batteryLevel, lastSeenAt, createdAt, synced);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalDevice &&
          other.id == this.id &&
          other.deviceHardwareId == this.deviceHardwareId &&
          other.deviceName == this.deviceName &&
          other.deviceType == this.deviceType &&
          other.assignedPatientId == this.assignedPatientId &&
          other.status == this.status &&
          other.batteryLevel == this.batteryLevel &&
          other.lastSeenAt == this.lastSeenAt &&
          other.createdAt == this.createdAt &&
          other.synced == this.synced);
}

class DevicesCompanion extends UpdateCompanion<LocalDevice> {
  final Value<String> id;
  final Value<String> deviceHardwareId;
  final Value<String> deviceName;
  final Value<String> deviceType;
  final Value<String?> assignedPatientId;
  final Value<String> status;
  final Value<int?> batteryLevel;
  final Value<DateTime?> lastSeenAt;
  final Value<DateTime> createdAt;
  final Value<bool> synced;
  final Value<int> rowid;
  const DevicesCompanion({
    this.id = const Value.absent(),
    this.deviceHardwareId = const Value.absent(),
    this.deviceName = const Value.absent(),
    this.deviceType = const Value.absent(),
    this.assignedPatientId = const Value.absent(),
    this.status = const Value.absent(),
    this.batteryLevel = const Value.absent(),
    this.lastSeenAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DevicesCompanion.insert({
    required String id,
    required String deviceHardwareId,
    required String deviceName,
    required String deviceType,
    this.assignedPatientId = const Value.absent(),
    this.status = const Value.absent(),
    this.batteryLevel = const Value.absent(),
    this.lastSeenAt = const Value.absent(),
    required DateTime createdAt,
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        deviceHardwareId = Value(deviceHardwareId),
        deviceName = Value(deviceName),
        deviceType = Value(deviceType),
        createdAt = Value(createdAt);
  static Insertable<LocalDevice> custom({
    Expression<String>? id,
    Expression<String>? deviceHardwareId,
    Expression<String>? deviceName,
    Expression<String>? deviceType,
    Expression<String>? assignedPatientId,
    Expression<String>? status,
    Expression<int>? batteryLevel,
    Expression<DateTime>? lastSeenAt,
    Expression<DateTime>? createdAt,
    Expression<bool>? synced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (deviceHardwareId != null) 'device_hardware_id': deviceHardwareId,
      if (deviceName != null) 'device_name': deviceName,
      if (deviceType != null) 'device_type': deviceType,
      if (assignedPatientId != null) 'assigned_patient_id': assignedPatientId,
      if (status != null) 'status': status,
      if (batteryLevel != null) 'battery_level': batteryLevel,
      if (lastSeenAt != null) 'last_seen_at': lastSeenAt,
      if (createdAt != null) 'created_at': createdAt,
      if (synced != null) 'synced': synced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DevicesCompanion copyWith(
      {Value<String>? id,
      Value<String>? deviceHardwareId,
      Value<String>? deviceName,
      Value<String>? deviceType,
      Value<String?>? assignedPatientId,
      Value<String>? status,
      Value<int?>? batteryLevel,
      Value<DateTime?>? lastSeenAt,
      Value<DateTime>? createdAt,
      Value<bool>? synced,
      Value<int>? rowid}) {
    return DevicesCompanion(
      id: id ?? this.id,
      deviceHardwareId: deviceHardwareId ?? this.deviceHardwareId,
      deviceName: deviceName ?? this.deviceName,
      deviceType: deviceType ?? this.deviceType,
      assignedPatientId: assignedPatientId ?? this.assignedPatientId,
      status: status ?? this.status,
      batteryLevel: batteryLevel ?? this.batteryLevel,
      lastSeenAt: lastSeenAt ?? this.lastSeenAt,
      createdAt: createdAt ?? this.createdAt,
      synced: synced ?? this.synced,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (deviceHardwareId.present) {
      map['device_hardware_id'] = Variable<String>(deviceHardwareId.value);
    }
    if (deviceName.present) {
      map['device_name'] = Variable<String>(deviceName.value);
    }
    if (deviceType.present) {
      map['device_type'] = Variable<String>(deviceType.value);
    }
    if (assignedPatientId.present) {
      map['assigned_patient_id'] = Variable<String>(assignedPatientId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (batteryLevel.present) {
      map['battery_level'] = Variable<int>(batteryLevel.value);
    }
    if (lastSeenAt.present) {
      map['last_seen_at'] = Variable<DateTime>(lastSeenAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DevicesCompanion(')
          ..write('id: $id, ')
          ..write('deviceHardwareId: $deviceHardwareId, ')
          ..write('deviceName: $deviceName, ')
          ..write('deviceType: $deviceType, ')
          ..write('assignedPatientId: $assignedPatientId, ')
          ..write('status: $status, ')
          ..write('batteryLevel: $batteryLevel, ')
          ..write('lastSeenAt: $lastSeenAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('synced: $synced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MonitoringSessionsTable extends MonitoringSessions
    with TableInfo<$MonitoringSessionsTable, LocalSession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MonitoringSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _patientIdMeta =
      const VerificationMeta('patientId');
  @override
  late final GeneratedColumn<String> patientId = GeneratedColumn<String>(
      'patient_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _startedAtMeta =
      const VerificationMeta('startedAt');
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
      'started_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _endedAtMeta =
      const VerificationMeta('endedAt');
  @override
  late final GeneratedColumn<DateTime> endedAt = GeneratedColumn<DateTime>(
      'ended_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _locationLatMeta =
      const VerificationMeta('locationLat');
  @override
  late final GeneratedColumn<double> locationLat = GeneratedColumn<double>(
      'location_lat', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _locationLngMeta =
      const VerificationMeta('locationLng');
  @override
  late final GeneratedColumn<double> locationLng = GeneratedColumn<double>(
      'location_lng', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _deviceIdMeta =
      const VerificationMeta('deviceId');
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
      'device_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
      'synced', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("synced" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        patientId,
        startedAt,
        endedAt,
        locationLat,
        locationLng,
        deviceId,
        synced
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'monitoring_sessions';
  @override
  VerificationContext validateIntegrity(Insertable<LocalSession> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('patient_id')) {
      context.handle(_patientIdMeta,
          patientId.isAcceptableOrUnknown(data['patient_id']!, _patientIdMeta));
    } else if (isInserting) {
      context.missing(_patientIdMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(_startedAtMeta,
          startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta));
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('ended_at')) {
      context.handle(_endedAtMeta,
          endedAt.isAcceptableOrUnknown(data['ended_at']!, _endedAtMeta));
    }
    if (data.containsKey('location_lat')) {
      context.handle(
          _locationLatMeta,
          locationLat.isAcceptableOrUnknown(
              data['location_lat']!, _locationLatMeta));
    }
    if (data.containsKey('location_lng')) {
      context.handle(
          _locationLngMeta,
          locationLng.isAcceptableOrUnknown(
              data['location_lng']!, _locationLngMeta));
    }
    if (data.containsKey('device_id')) {
      context.handle(_deviceIdMeta,
          deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta));
    }
    if (data.containsKey('synced')) {
      context.handle(_syncedMeta,
          synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalSession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalSession(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      patientId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}patient_id'])!,
      startedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}started_at'])!,
      endedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}ended_at']),
      locationLat: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}location_lat']),
      locationLng: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}location_lng']),
      deviceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}device_id']),
      synced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}synced'])!,
    );
  }

  @override
  $MonitoringSessionsTable createAlias(String alias) {
    return $MonitoringSessionsTable(attachedDatabase, alias);
  }
}

class LocalSession extends DataClass implements Insertable<LocalSession> {
  final String id;
  final String patientId;
  final DateTime startedAt;
  final DateTime? endedAt;
  final double? locationLat;
  final double? locationLng;
  final String? deviceId;
  final bool synced;
  const LocalSession(
      {required this.id,
      required this.patientId,
      required this.startedAt,
      this.endedAt,
      this.locationLat,
      this.locationLng,
      this.deviceId,
      required this.synced});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['patient_id'] = Variable<String>(patientId);
    map['started_at'] = Variable<DateTime>(startedAt);
    if (!nullToAbsent || endedAt != null) {
      map['ended_at'] = Variable<DateTime>(endedAt);
    }
    if (!nullToAbsent || locationLat != null) {
      map['location_lat'] = Variable<double>(locationLat);
    }
    if (!nullToAbsent || locationLng != null) {
      map['location_lng'] = Variable<double>(locationLng);
    }
    if (!nullToAbsent || deviceId != null) {
      map['device_id'] = Variable<String>(deviceId);
    }
    map['synced'] = Variable<bool>(synced);
    return map;
  }

  MonitoringSessionsCompanion toCompanion(bool nullToAbsent) {
    return MonitoringSessionsCompanion(
      id: Value(id),
      patientId: Value(patientId),
      startedAt: Value(startedAt),
      endedAt: endedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(endedAt),
      locationLat: locationLat == null && nullToAbsent
          ? const Value.absent()
          : Value(locationLat),
      locationLng: locationLng == null && nullToAbsent
          ? const Value.absent()
          : Value(locationLng),
      deviceId: deviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(deviceId),
      synced: Value(synced),
    );
  }

  factory LocalSession.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalSession(
      id: serializer.fromJson<String>(json['id']),
      patientId: serializer.fromJson<String>(json['patientId']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      endedAt: serializer.fromJson<DateTime?>(json['endedAt']),
      locationLat: serializer.fromJson<double?>(json['locationLat']),
      locationLng: serializer.fromJson<double?>(json['locationLng']),
      deviceId: serializer.fromJson<String?>(json['deviceId']),
      synced: serializer.fromJson<bool>(json['synced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'patientId': serializer.toJson<String>(patientId),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'endedAt': serializer.toJson<DateTime?>(endedAt),
      'locationLat': serializer.toJson<double?>(locationLat),
      'locationLng': serializer.toJson<double?>(locationLng),
      'deviceId': serializer.toJson<String?>(deviceId),
      'synced': serializer.toJson<bool>(synced),
    };
  }

  LocalSession copyWith(
          {String? id,
          String? patientId,
          DateTime? startedAt,
          Value<DateTime?> endedAt = const Value.absent(),
          Value<double?> locationLat = const Value.absent(),
          Value<double?> locationLng = const Value.absent(),
          Value<String?> deviceId = const Value.absent(),
          bool? synced}) =>
      LocalSession(
        id: id ?? this.id,
        patientId: patientId ?? this.patientId,
        startedAt: startedAt ?? this.startedAt,
        endedAt: endedAt.present ? endedAt.value : this.endedAt,
        locationLat: locationLat.present ? locationLat.value : this.locationLat,
        locationLng: locationLng.present ? locationLng.value : this.locationLng,
        deviceId: deviceId.present ? deviceId.value : this.deviceId,
        synced: synced ?? this.synced,
      );
  LocalSession copyWithCompanion(MonitoringSessionsCompanion data) {
    return LocalSession(
      id: data.id.present ? data.id.value : this.id,
      patientId: data.patientId.present ? data.patientId.value : this.patientId,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      endedAt: data.endedAt.present ? data.endedAt.value : this.endedAt,
      locationLat:
          data.locationLat.present ? data.locationLat.value : this.locationLat,
      locationLng:
          data.locationLng.present ? data.locationLng.value : this.locationLng,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      synced: data.synced.present ? data.synced.value : this.synced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalSession(')
          ..write('id: $id, ')
          ..write('patientId: $patientId, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('locationLat: $locationLat, ')
          ..write('locationLng: $locationLng, ')
          ..write('deviceId: $deviceId, ')
          ..write('synced: $synced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, patientId, startedAt, endedAt,
      locationLat, locationLng, deviceId, synced);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalSession &&
          other.id == this.id &&
          other.patientId == this.patientId &&
          other.startedAt == this.startedAt &&
          other.endedAt == this.endedAt &&
          other.locationLat == this.locationLat &&
          other.locationLng == this.locationLng &&
          other.deviceId == this.deviceId &&
          other.synced == this.synced);
}

class MonitoringSessionsCompanion extends UpdateCompanion<LocalSession> {
  final Value<String> id;
  final Value<String> patientId;
  final Value<DateTime> startedAt;
  final Value<DateTime?> endedAt;
  final Value<double?> locationLat;
  final Value<double?> locationLng;
  final Value<String?> deviceId;
  final Value<bool> synced;
  final Value<int> rowid;
  const MonitoringSessionsCompanion({
    this.id = const Value.absent(),
    this.patientId = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.locationLat = const Value.absent(),
    this.locationLng = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MonitoringSessionsCompanion.insert({
    required String id,
    required String patientId,
    required DateTime startedAt,
    this.endedAt = const Value.absent(),
    this.locationLat = const Value.absent(),
    this.locationLng = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        patientId = Value(patientId),
        startedAt = Value(startedAt);
  static Insertable<LocalSession> custom({
    Expression<String>? id,
    Expression<String>? patientId,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? endedAt,
    Expression<double>? locationLat,
    Expression<double>? locationLng,
    Expression<String>? deviceId,
    Expression<bool>? synced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (patientId != null) 'patient_id': patientId,
      if (startedAt != null) 'started_at': startedAt,
      if (endedAt != null) 'ended_at': endedAt,
      if (locationLat != null) 'location_lat': locationLat,
      if (locationLng != null) 'location_lng': locationLng,
      if (deviceId != null) 'device_id': deviceId,
      if (synced != null) 'synced': synced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MonitoringSessionsCompanion copyWith(
      {Value<String>? id,
      Value<String>? patientId,
      Value<DateTime>? startedAt,
      Value<DateTime?>? endedAt,
      Value<double?>? locationLat,
      Value<double?>? locationLng,
      Value<String?>? deviceId,
      Value<bool>? synced,
      Value<int>? rowid}) {
    return MonitoringSessionsCompanion(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      locationLat: locationLat ?? this.locationLat,
      locationLng: locationLng ?? this.locationLng,
      deviceId: deviceId ?? this.deviceId,
      synced: synced ?? this.synced,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (patientId.present) {
      map['patient_id'] = Variable<String>(patientId.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (endedAt.present) {
      map['ended_at'] = Variable<DateTime>(endedAt.value);
    }
    if (locationLat.present) {
      map['location_lat'] = Variable<double>(locationLat.value);
    }
    if (locationLng.present) {
      map['location_lng'] = Variable<double>(locationLng.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MonitoringSessionsCompanion(')
          ..write('id: $id, ')
          ..write('patientId: $patientId, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('locationLat: $locationLat, ')
          ..write('locationLng: $locationLng, ')
          ..write('deviceId: $deviceId, ')
          ..write('synced: $synced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReadingsTable extends Readings
    with TableInfo<$ReadingsTable, LocalReading> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReadingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sessionIdMeta =
      const VerificationMeta('sessionId');
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
      'session_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _patientIdMeta =
      const VerificationMeta('patientId');
  @override
  late final GeneratedColumn<String> patientId = GeneratedColumn<String>(
      'patient_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _vitalTypeMeta =
      const VerificationMeta('vitalType');
  @override
  late final GeneratedColumn<String> vitalType = GeneratedColumn<String>(
      'vital_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _valuesJsonMeta =
      const VerificationMeta('valuesJson');
  @override
  late final GeneratedColumn<String> valuesJson = GeneratedColumn<String>(
      'values_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _recordedAtMeta =
      const VerificationMeta('recordedAt');
  @override
  late final GeneratedColumn<DateTime> recordedAt = GeneratedColumn<DateTime>(
      'recorded_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _dangerLevelMeta =
      const VerificationMeta('dangerLevel');
  @override
  late final GeneratedColumn<String> dangerLevel = GeneratedColumn<String>(
      'danger_level', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('normal'));
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
      'source', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('manual'));
  static const VerificationMeta _deviceNameMeta =
      const VerificationMeta('deviceName');
  @override
  late final GeneratedColumn<String> deviceName = GeneratedColumn<String>(
      'device_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _deviceHardwareIdMeta =
      const VerificationMeta('deviceHardwareId');
  @override
  late final GeneratedColumn<String> deviceHardwareId = GeneratedColumn<String>(
      'device_hardware_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
      'synced', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("synced" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        sessionId,
        patientId,
        vitalType,
        valuesJson,
        recordedAt,
        dangerLevel,
        source,
        deviceName,
        deviceHardwareId,
        synced
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'readings';
  @override
  VerificationContext validateIntegrity(Insertable<LocalReading> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('session_id')) {
      context.handle(_sessionIdMeta,
          sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta));
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('patient_id')) {
      context.handle(_patientIdMeta,
          patientId.isAcceptableOrUnknown(data['patient_id']!, _patientIdMeta));
    } else if (isInserting) {
      context.missing(_patientIdMeta);
    }
    if (data.containsKey('vital_type')) {
      context.handle(_vitalTypeMeta,
          vitalType.isAcceptableOrUnknown(data['vital_type']!, _vitalTypeMeta));
    } else if (isInserting) {
      context.missing(_vitalTypeMeta);
    }
    if (data.containsKey('values_json')) {
      context.handle(
          _valuesJsonMeta,
          valuesJson.isAcceptableOrUnknown(
              data['values_json']!, _valuesJsonMeta));
    } else if (isInserting) {
      context.missing(_valuesJsonMeta);
    }
    if (data.containsKey('recorded_at')) {
      context.handle(
          _recordedAtMeta,
          recordedAt.isAcceptableOrUnknown(
              data['recorded_at']!, _recordedAtMeta));
    } else if (isInserting) {
      context.missing(_recordedAtMeta);
    }
    if (data.containsKey('danger_level')) {
      context.handle(
          _dangerLevelMeta,
          dangerLevel.isAcceptableOrUnknown(
              data['danger_level']!, _dangerLevelMeta));
    }
    if (data.containsKey('source')) {
      context.handle(_sourceMeta,
          source.isAcceptableOrUnknown(data['source']!, _sourceMeta));
    }
    if (data.containsKey('device_name')) {
      context.handle(
          _deviceNameMeta,
          deviceName.isAcceptableOrUnknown(
              data['device_name']!, _deviceNameMeta));
    }
    if (data.containsKey('device_hardware_id')) {
      context.handle(
          _deviceHardwareIdMeta,
          deviceHardwareId.isAcceptableOrUnknown(
              data['device_hardware_id']!, _deviceHardwareIdMeta));
    }
    if (data.containsKey('synced')) {
      context.handle(_syncedMeta,
          synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalReading map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalReading(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      sessionId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}session_id'])!,
      patientId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}patient_id'])!,
      vitalType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}vital_type'])!,
      valuesJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}values_json'])!,
      recordedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}recorded_at'])!,
      dangerLevel: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}danger_level'])!,
      source: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source'])!,
      deviceName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}device_name']),
      deviceHardwareId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}device_hardware_id']),
      synced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}synced'])!,
    );
  }

  @override
  $ReadingsTable createAlias(String alias) {
    return $ReadingsTable(attachedDatabase, alias);
  }
}

class LocalReading extends DataClass implements Insertable<LocalReading> {
  final String id;
  final String sessionId;
  final String patientId;
  final String vitalType;
  final String valuesJson;
  final DateTime recordedAt;
  final String dangerLevel;
  final String source;
  final String? deviceName;
  final String? deviceHardwareId;
  final bool synced;
  const LocalReading(
      {required this.id,
      required this.sessionId,
      required this.patientId,
      required this.vitalType,
      required this.valuesJson,
      required this.recordedAt,
      required this.dangerLevel,
      required this.source,
      this.deviceName,
      this.deviceHardwareId,
      required this.synced});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['session_id'] = Variable<String>(sessionId);
    map['patient_id'] = Variable<String>(patientId);
    map['vital_type'] = Variable<String>(vitalType);
    map['values_json'] = Variable<String>(valuesJson);
    map['recorded_at'] = Variable<DateTime>(recordedAt);
    map['danger_level'] = Variable<String>(dangerLevel);
    map['source'] = Variable<String>(source);
    if (!nullToAbsent || deviceName != null) {
      map['device_name'] = Variable<String>(deviceName);
    }
    if (!nullToAbsent || deviceHardwareId != null) {
      map['device_hardware_id'] = Variable<String>(deviceHardwareId);
    }
    map['synced'] = Variable<bool>(synced);
    return map;
  }

  ReadingsCompanion toCompanion(bool nullToAbsent) {
    return ReadingsCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      patientId: Value(patientId),
      vitalType: Value(vitalType),
      valuesJson: Value(valuesJson),
      recordedAt: Value(recordedAt),
      dangerLevel: Value(dangerLevel),
      source: Value(source),
      deviceName: deviceName == null && nullToAbsent
          ? const Value.absent()
          : Value(deviceName),
      deviceHardwareId: deviceHardwareId == null && nullToAbsent
          ? const Value.absent()
          : Value(deviceHardwareId),
      synced: Value(synced),
    );
  }

  factory LocalReading.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalReading(
      id: serializer.fromJson<String>(json['id']),
      sessionId: serializer.fromJson<String>(json['sessionId']),
      patientId: serializer.fromJson<String>(json['patientId']),
      vitalType: serializer.fromJson<String>(json['vitalType']),
      valuesJson: serializer.fromJson<String>(json['valuesJson']),
      recordedAt: serializer.fromJson<DateTime>(json['recordedAt']),
      dangerLevel: serializer.fromJson<String>(json['dangerLevel']),
      source: serializer.fromJson<String>(json['source']),
      deviceName: serializer.fromJson<String?>(json['deviceName']),
      deviceHardwareId: serializer.fromJson<String?>(json['deviceHardwareId']),
      synced: serializer.fromJson<bool>(json['synced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sessionId': serializer.toJson<String>(sessionId),
      'patientId': serializer.toJson<String>(patientId),
      'vitalType': serializer.toJson<String>(vitalType),
      'valuesJson': serializer.toJson<String>(valuesJson),
      'recordedAt': serializer.toJson<DateTime>(recordedAt),
      'dangerLevel': serializer.toJson<String>(dangerLevel),
      'source': serializer.toJson<String>(source),
      'deviceName': serializer.toJson<String?>(deviceName),
      'deviceHardwareId': serializer.toJson<String?>(deviceHardwareId),
      'synced': serializer.toJson<bool>(synced),
    };
  }

  LocalReading copyWith(
          {String? id,
          String? sessionId,
          String? patientId,
          String? vitalType,
          String? valuesJson,
          DateTime? recordedAt,
          String? dangerLevel,
          String? source,
          Value<String?> deviceName = const Value.absent(),
          Value<String?> deviceHardwareId = const Value.absent(),
          bool? synced}) =>
      LocalReading(
        id: id ?? this.id,
        sessionId: sessionId ?? this.sessionId,
        patientId: patientId ?? this.patientId,
        vitalType: vitalType ?? this.vitalType,
        valuesJson: valuesJson ?? this.valuesJson,
        recordedAt: recordedAt ?? this.recordedAt,
        dangerLevel: dangerLevel ?? this.dangerLevel,
        source: source ?? this.source,
        deviceName: deviceName.present ? deviceName.value : this.deviceName,
        deviceHardwareId: deviceHardwareId.present
            ? deviceHardwareId.value
            : this.deviceHardwareId,
        synced: synced ?? this.synced,
      );
  LocalReading copyWithCompanion(ReadingsCompanion data) {
    return LocalReading(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      patientId: data.patientId.present ? data.patientId.value : this.patientId,
      vitalType: data.vitalType.present ? data.vitalType.value : this.vitalType,
      valuesJson:
          data.valuesJson.present ? data.valuesJson.value : this.valuesJson,
      recordedAt:
          data.recordedAt.present ? data.recordedAt.value : this.recordedAt,
      dangerLevel:
          data.dangerLevel.present ? data.dangerLevel.value : this.dangerLevel,
      source: data.source.present ? data.source.value : this.source,
      deviceName:
          data.deviceName.present ? data.deviceName.value : this.deviceName,
      deviceHardwareId: data.deviceHardwareId.present
          ? data.deviceHardwareId.value
          : this.deviceHardwareId,
      synced: data.synced.present ? data.synced.value : this.synced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalReading(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('patientId: $patientId, ')
          ..write('vitalType: $vitalType, ')
          ..write('valuesJson: $valuesJson, ')
          ..write('recordedAt: $recordedAt, ')
          ..write('dangerLevel: $dangerLevel, ')
          ..write('source: $source, ')
          ..write('deviceName: $deviceName, ')
          ..write('deviceHardwareId: $deviceHardwareId, ')
          ..write('synced: $synced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      sessionId,
      patientId,
      vitalType,
      valuesJson,
      recordedAt,
      dangerLevel,
      source,
      deviceName,
      deviceHardwareId,
      synced);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalReading &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.patientId == this.patientId &&
          other.vitalType == this.vitalType &&
          other.valuesJson == this.valuesJson &&
          other.recordedAt == this.recordedAt &&
          other.dangerLevel == this.dangerLevel &&
          other.source == this.source &&
          other.deviceName == this.deviceName &&
          other.deviceHardwareId == this.deviceHardwareId &&
          other.synced == this.synced);
}

class ReadingsCompanion extends UpdateCompanion<LocalReading> {
  final Value<String> id;
  final Value<String> sessionId;
  final Value<String> patientId;
  final Value<String> vitalType;
  final Value<String> valuesJson;
  final Value<DateTime> recordedAt;
  final Value<String> dangerLevel;
  final Value<String> source;
  final Value<String?> deviceName;
  final Value<String?> deviceHardwareId;
  final Value<bool> synced;
  final Value<int> rowid;
  const ReadingsCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.patientId = const Value.absent(),
    this.vitalType = const Value.absent(),
    this.valuesJson = const Value.absent(),
    this.recordedAt = const Value.absent(),
    this.dangerLevel = const Value.absent(),
    this.source = const Value.absent(),
    this.deviceName = const Value.absent(),
    this.deviceHardwareId = const Value.absent(),
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReadingsCompanion.insert({
    required String id,
    required String sessionId,
    required String patientId,
    required String vitalType,
    required String valuesJson,
    required DateTime recordedAt,
    this.dangerLevel = const Value.absent(),
    this.source = const Value.absent(),
    this.deviceName = const Value.absent(),
    this.deviceHardwareId = const Value.absent(),
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        sessionId = Value(sessionId),
        patientId = Value(patientId),
        vitalType = Value(vitalType),
        valuesJson = Value(valuesJson),
        recordedAt = Value(recordedAt);
  static Insertable<LocalReading> custom({
    Expression<String>? id,
    Expression<String>? sessionId,
    Expression<String>? patientId,
    Expression<String>? vitalType,
    Expression<String>? valuesJson,
    Expression<DateTime>? recordedAt,
    Expression<String>? dangerLevel,
    Expression<String>? source,
    Expression<String>? deviceName,
    Expression<String>? deviceHardwareId,
    Expression<bool>? synced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (patientId != null) 'patient_id': patientId,
      if (vitalType != null) 'vital_type': vitalType,
      if (valuesJson != null) 'values_json': valuesJson,
      if (recordedAt != null) 'recorded_at': recordedAt,
      if (dangerLevel != null) 'danger_level': dangerLevel,
      if (source != null) 'source': source,
      if (deviceName != null) 'device_name': deviceName,
      if (deviceHardwareId != null) 'device_hardware_id': deviceHardwareId,
      if (synced != null) 'synced': synced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReadingsCompanion copyWith(
      {Value<String>? id,
      Value<String>? sessionId,
      Value<String>? patientId,
      Value<String>? vitalType,
      Value<String>? valuesJson,
      Value<DateTime>? recordedAt,
      Value<String>? dangerLevel,
      Value<String>? source,
      Value<String?>? deviceName,
      Value<String?>? deviceHardwareId,
      Value<bool>? synced,
      Value<int>? rowid}) {
    return ReadingsCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      patientId: patientId ?? this.patientId,
      vitalType: vitalType ?? this.vitalType,
      valuesJson: valuesJson ?? this.valuesJson,
      recordedAt: recordedAt ?? this.recordedAt,
      dangerLevel: dangerLevel ?? this.dangerLevel,
      source: source ?? this.source,
      deviceName: deviceName ?? this.deviceName,
      deviceHardwareId: deviceHardwareId ?? this.deviceHardwareId,
      synced: synced ?? this.synced,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (patientId.present) {
      map['patient_id'] = Variable<String>(patientId.value);
    }
    if (vitalType.present) {
      map['vital_type'] = Variable<String>(vitalType.value);
    }
    if (valuesJson.present) {
      map['values_json'] = Variable<String>(valuesJson.value);
    }
    if (recordedAt.present) {
      map['recorded_at'] = Variable<DateTime>(recordedAt.value);
    }
    if (dangerLevel.present) {
      map['danger_level'] = Variable<String>(dangerLevel.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (deviceName.present) {
      map['device_name'] = Variable<String>(deviceName.value);
    }
    if (deviceHardwareId.present) {
      map['device_hardware_id'] = Variable<String>(deviceHardwareId.value);
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReadingsCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('patientId: $patientId, ')
          ..write('vitalType: $vitalType, ')
          ..write('valuesJson: $valuesJson, ')
          ..write('recordedAt: $recordedAt, ')
          ..write('dangerLevel: $dangerLevel, ')
          ..write('source: $source, ')
          ..write('deviceName: $deviceName, ')
          ..write('deviceHardwareId: $deviceHardwareId, ')
          ..write('synced: $synced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RiskScoresTable extends RiskScores
    with TableInfo<$RiskScoresTable, LocalRiskScore> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RiskScoresTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _patientIdMeta =
      const VerificationMeta('patientId');
  @override
  late final GeneratedColumn<String> patientId = GeneratedColumn<String>(
      'patient_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sessionIdMeta =
      const VerificationMeta('sessionId');
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
      'session_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _riskScoreMeta =
      const VerificationMeta('riskScore');
  @override
  late final GeneratedColumn<double> riskScore = GeneratedColumn<double>(
      'risk_score', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _riskTierMeta =
      const VerificationMeta('riskTier');
  @override
  late final GeneratedColumn<String> riskTier = GeneratedColumn<String>(
      'risk_tier', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _topFactorsJsonMeta =
      const VerificationMeta('topFactorsJson');
  @override
  late final GeneratedColumn<String> topFactorsJson = GeneratedColumn<String>(
      'top_factors_json', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _scoredAtMeta =
      const VerificationMeta('scoredAt');
  @override
  late final GeneratedColumn<DateTime> scoredAt = GeneratedColumn<DateTime>(
      'scored_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
      'synced', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("synced" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        patientId,
        sessionId,
        riskScore,
        riskTier,
        topFactorsJson,
        scoredAt,
        synced
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'risk_scores';
  @override
  VerificationContext validateIntegrity(Insertable<LocalRiskScore> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('patient_id')) {
      context.handle(_patientIdMeta,
          patientId.isAcceptableOrUnknown(data['patient_id']!, _patientIdMeta));
    } else if (isInserting) {
      context.missing(_patientIdMeta);
    }
    if (data.containsKey('session_id')) {
      context.handle(_sessionIdMeta,
          sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta));
    }
    if (data.containsKey('risk_score')) {
      context.handle(_riskScoreMeta,
          riskScore.isAcceptableOrUnknown(data['risk_score']!, _riskScoreMeta));
    } else if (isInserting) {
      context.missing(_riskScoreMeta);
    }
    if (data.containsKey('risk_tier')) {
      context.handle(_riskTierMeta,
          riskTier.isAcceptableOrUnknown(data['risk_tier']!, _riskTierMeta));
    } else if (isInserting) {
      context.missing(_riskTierMeta);
    }
    if (data.containsKey('top_factors_json')) {
      context.handle(
          _topFactorsJsonMeta,
          topFactorsJson.isAcceptableOrUnknown(
              data['top_factors_json']!, _topFactorsJsonMeta));
    }
    if (data.containsKey('scored_at')) {
      context.handle(_scoredAtMeta,
          scoredAt.isAcceptableOrUnknown(data['scored_at']!, _scoredAtMeta));
    } else if (isInserting) {
      context.missing(_scoredAtMeta);
    }
    if (data.containsKey('synced')) {
      context.handle(_syncedMeta,
          synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalRiskScore map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalRiskScore(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      patientId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}patient_id'])!,
      sessionId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}session_id']),
      riskScore: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}risk_score'])!,
      riskTier: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}risk_tier'])!,
      topFactorsJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}top_factors_json']),
      scoredAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}scored_at'])!,
      synced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}synced'])!,
    );
  }

  @override
  $RiskScoresTable createAlias(String alias) {
    return $RiskScoresTable(attachedDatabase, alias);
  }
}

class LocalRiskScore extends DataClass implements Insertable<LocalRiskScore> {
  final String id;
  final String patientId;
  final String? sessionId;
  final double riskScore;
  final String riskTier;
  final String? topFactorsJson;
  final DateTime scoredAt;
  final bool synced;
  const LocalRiskScore(
      {required this.id,
      required this.patientId,
      this.sessionId,
      required this.riskScore,
      required this.riskTier,
      this.topFactorsJson,
      required this.scoredAt,
      required this.synced});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['patient_id'] = Variable<String>(patientId);
    if (!nullToAbsent || sessionId != null) {
      map['session_id'] = Variable<String>(sessionId);
    }
    map['risk_score'] = Variable<double>(riskScore);
    map['risk_tier'] = Variable<String>(riskTier);
    if (!nullToAbsent || topFactorsJson != null) {
      map['top_factors_json'] = Variable<String>(topFactorsJson);
    }
    map['scored_at'] = Variable<DateTime>(scoredAt);
    map['synced'] = Variable<bool>(synced);
    return map;
  }

  RiskScoresCompanion toCompanion(bool nullToAbsent) {
    return RiskScoresCompanion(
      id: Value(id),
      patientId: Value(patientId),
      sessionId: sessionId == null && nullToAbsent
          ? const Value.absent()
          : Value(sessionId),
      riskScore: Value(riskScore),
      riskTier: Value(riskTier),
      topFactorsJson: topFactorsJson == null && nullToAbsent
          ? const Value.absent()
          : Value(topFactorsJson),
      scoredAt: Value(scoredAt),
      synced: Value(synced),
    );
  }

  factory LocalRiskScore.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalRiskScore(
      id: serializer.fromJson<String>(json['id']),
      patientId: serializer.fromJson<String>(json['patientId']),
      sessionId: serializer.fromJson<String?>(json['sessionId']),
      riskScore: serializer.fromJson<double>(json['riskScore']),
      riskTier: serializer.fromJson<String>(json['riskTier']),
      topFactorsJson: serializer.fromJson<String?>(json['topFactorsJson']),
      scoredAt: serializer.fromJson<DateTime>(json['scoredAt']),
      synced: serializer.fromJson<bool>(json['synced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'patientId': serializer.toJson<String>(patientId),
      'sessionId': serializer.toJson<String?>(sessionId),
      'riskScore': serializer.toJson<double>(riskScore),
      'riskTier': serializer.toJson<String>(riskTier),
      'topFactorsJson': serializer.toJson<String?>(topFactorsJson),
      'scoredAt': serializer.toJson<DateTime>(scoredAt),
      'synced': serializer.toJson<bool>(synced),
    };
  }

  LocalRiskScore copyWith(
          {String? id,
          String? patientId,
          Value<String?> sessionId = const Value.absent(),
          double? riskScore,
          String? riskTier,
          Value<String?> topFactorsJson = const Value.absent(),
          DateTime? scoredAt,
          bool? synced}) =>
      LocalRiskScore(
        id: id ?? this.id,
        patientId: patientId ?? this.patientId,
        sessionId: sessionId.present ? sessionId.value : this.sessionId,
        riskScore: riskScore ?? this.riskScore,
        riskTier: riskTier ?? this.riskTier,
        topFactorsJson:
            topFactorsJson.present ? topFactorsJson.value : this.topFactorsJson,
        scoredAt: scoredAt ?? this.scoredAt,
        synced: synced ?? this.synced,
      );
  LocalRiskScore copyWithCompanion(RiskScoresCompanion data) {
    return LocalRiskScore(
      id: data.id.present ? data.id.value : this.id,
      patientId: data.patientId.present ? data.patientId.value : this.patientId,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      riskScore: data.riskScore.present ? data.riskScore.value : this.riskScore,
      riskTier: data.riskTier.present ? data.riskTier.value : this.riskTier,
      topFactorsJson: data.topFactorsJson.present
          ? data.topFactorsJson.value
          : this.topFactorsJson,
      scoredAt: data.scoredAt.present ? data.scoredAt.value : this.scoredAt,
      synced: data.synced.present ? data.synced.value : this.synced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalRiskScore(')
          ..write('id: $id, ')
          ..write('patientId: $patientId, ')
          ..write('sessionId: $sessionId, ')
          ..write('riskScore: $riskScore, ')
          ..write('riskTier: $riskTier, ')
          ..write('topFactorsJson: $topFactorsJson, ')
          ..write('scoredAt: $scoredAt, ')
          ..write('synced: $synced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, patientId, sessionId, riskScore, riskTier,
      topFactorsJson, scoredAt, synced);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalRiskScore &&
          other.id == this.id &&
          other.patientId == this.patientId &&
          other.sessionId == this.sessionId &&
          other.riskScore == this.riskScore &&
          other.riskTier == this.riskTier &&
          other.topFactorsJson == this.topFactorsJson &&
          other.scoredAt == this.scoredAt &&
          other.synced == this.synced);
}

class RiskScoresCompanion extends UpdateCompanion<LocalRiskScore> {
  final Value<String> id;
  final Value<String> patientId;
  final Value<String?> sessionId;
  final Value<double> riskScore;
  final Value<String> riskTier;
  final Value<String?> topFactorsJson;
  final Value<DateTime> scoredAt;
  final Value<bool> synced;
  final Value<int> rowid;
  const RiskScoresCompanion({
    this.id = const Value.absent(),
    this.patientId = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.riskScore = const Value.absent(),
    this.riskTier = const Value.absent(),
    this.topFactorsJson = const Value.absent(),
    this.scoredAt = const Value.absent(),
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RiskScoresCompanion.insert({
    required String id,
    required String patientId,
    this.sessionId = const Value.absent(),
    required double riskScore,
    required String riskTier,
    this.topFactorsJson = const Value.absent(),
    required DateTime scoredAt,
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        patientId = Value(patientId),
        riskScore = Value(riskScore),
        riskTier = Value(riskTier),
        scoredAt = Value(scoredAt);
  static Insertable<LocalRiskScore> custom({
    Expression<String>? id,
    Expression<String>? patientId,
    Expression<String>? sessionId,
    Expression<double>? riskScore,
    Expression<String>? riskTier,
    Expression<String>? topFactorsJson,
    Expression<DateTime>? scoredAt,
    Expression<bool>? synced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (patientId != null) 'patient_id': patientId,
      if (sessionId != null) 'session_id': sessionId,
      if (riskScore != null) 'risk_score': riskScore,
      if (riskTier != null) 'risk_tier': riskTier,
      if (topFactorsJson != null) 'top_factors_json': topFactorsJson,
      if (scoredAt != null) 'scored_at': scoredAt,
      if (synced != null) 'synced': synced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RiskScoresCompanion copyWith(
      {Value<String>? id,
      Value<String>? patientId,
      Value<String?>? sessionId,
      Value<double>? riskScore,
      Value<String>? riskTier,
      Value<String?>? topFactorsJson,
      Value<DateTime>? scoredAt,
      Value<bool>? synced,
      Value<int>? rowid}) {
    return RiskScoresCompanion(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      sessionId: sessionId ?? this.sessionId,
      riskScore: riskScore ?? this.riskScore,
      riskTier: riskTier ?? this.riskTier,
      topFactorsJson: topFactorsJson ?? this.topFactorsJson,
      scoredAt: scoredAt ?? this.scoredAt,
      synced: synced ?? this.synced,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (patientId.present) {
      map['patient_id'] = Variable<String>(patientId.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (riskScore.present) {
      map['risk_score'] = Variable<double>(riskScore.value);
    }
    if (riskTier.present) {
      map['risk_tier'] = Variable<String>(riskTier.value);
    }
    if (topFactorsJson.present) {
      map['top_factors_json'] = Variable<String>(topFactorsJson.value);
    }
    if (scoredAt.present) {
      map['scored_at'] = Variable<DateTime>(scoredAt.value);
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RiskScoresCompanion(')
          ..write('id: $id, ')
          ..write('patientId: $patientId, ')
          ..write('sessionId: $sessionId, ')
          ..write('riskScore: $riskScore, ')
          ..write('riskTier: $riskTier, ')
          ..write('topFactorsJson: $topFactorsJson, ')
          ..write('scoredAt: $scoredAt, ')
          ..write('synced: $synced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReferralsTable extends Referrals
    with TableInfo<$ReferralsTable, LocalReferral> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReferralsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _patientIdMeta =
      const VerificationMeta('patientId');
  @override
  late final GeneratedColumn<String> patientId = GeneratedColumn<String>(
      'patient_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _triggerTypeMeta =
      const VerificationMeta('triggerType');
  @override
  late final GeneratedColumn<String> triggerType = GeneratedColumn<String>(
      'trigger_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _triggerDetailJsonMeta =
      const VerificationMeta('triggerDetailJson');
  @override
  late final GeneratedColumn<String> triggerDetailJson =
      GeneratedColumn<String>('trigger_detail_json', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _vitalsSnapshotJsonMeta =
      const VerificationMeta('vitalsSnapshotJson');
  @override
  late final GeneratedColumn<String> vitalsSnapshotJson =
      GeneratedColumn<String>('vitals_snapshot_json', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _aiRiskScoreMeta =
      const VerificationMeta('aiRiskScore');
  @override
  late final GeneratedColumn<double> aiRiskScore = GeneratedColumn<double>(
      'ai_risk_score', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _facilityIdMeta =
      const VerificationMeta('facilityId');
  @override
  late final GeneratedColumn<String> facilityId = GeneratedColumn<String>(
      'facility_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
      'synced', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("synced" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        patientId,
        triggerType,
        triggerDetailJson,
        vitalsSnapshotJson,
        aiRiskScore,
        facilityId,
        status,
        createdAt,
        updatedAt,
        synced
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'referrals';
  @override
  VerificationContext validateIntegrity(Insertable<LocalReferral> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('patient_id')) {
      context.handle(_patientIdMeta,
          patientId.isAcceptableOrUnknown(data['patient_id']!, _patientIdMeta));
    } else if (isInserting) {
      context.missing(_patientIdMeta);
    }
    if (data.containsKey('trigger_type')) {
      context.handle(
          _triggerTypeMeta,
          triggerType.isAcceptableOrUnknown(
              data['trigger_type']!, _triggerTypeMeta));
    } else if (isInserting) {
      context.missing(_triggerTypeMeta);
    }
    if (data.containsKey('trigger_detail_json')) {
      context.handle(
          _triggerDetailJsonMeta,
          triggerDetailJson.isAcceptableOrUnknown(
              data['trigger_detail_json']!, _triggerDetailJsonMeta));
    }
    if (data.containsKey('vitals_snapshot_json')) {
      context.handle(
          _vitalsSnapshotJsonMeta,
          vitalsSnapshotJson.isAcceptableOrUnknown(
              data['vitals_snapshot_json']!, _vitalsSnapshotJsonMeta));
    }
    if (data.containsKey('ai_risk_score')) {
      context.handle(
          _aiRiskScoreMeta,
          aiRiskScore.isAcceptableOrUnknown(
              data['ai_risk_score']!, _aiRiskScoreMeta));
    }
    if (data.containsKey('facility_id')) {
      context.handle(
          _facilityIdMeta,
          facilityId.isAcceptableOrUnknown(
              data['facility_id']!, _facilityIdMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('synced')) {
      context.handle(_syncedMeta,
          synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalReferral map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalReferral(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      patientId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}patient_id'])!,
      triggerType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}trigger_type'])!,
      triggerDetailJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}trigger_detail_json']),
      vitalsSnapshotJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}vitals_snapshot_json']),
      aiRiskScore: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}ai_risk_score']),
      facilityId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}facility_id']),
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      synced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}synced'])!,
    );
  }

  @override
  $ReferralsTable createAlias(String alias) {
    return $ReferralsTable(attachedDatabase, alias);
  }
}

class LocalReferral extends DataClass implements Insertable<LocalReferral> {
  final String id;
  final String patientId;
  final String triggerType;
  final String? triggerDetailJson;
  final String? vitalsSnapshotJson;
  final double? aiRiskScore;
  final String? facilityId;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool synced;
  const LocalReferral(
      {required this.id,
      required this.patientId,
      required this.triggerType,
      this.triggerDetailJson,
      this.vitalsSnapshotJson,
      this.aiRiskScore,
      this.facilityId,
      required this.status,
      required this.createdAt,
      required this.updatedAt,
      required this.synced});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['patient_id'] = Variable<String>(patientId);
    map['trigger_type'] = Variable<String>(triggerType);
    if (!nullToAbsent || triggerDetailJson != null) {
      map['trigger_detail_json'] = Variable<String>(triggerDetailJson);
    }
    if (!nullToAbsent || vitalsSnapshotJson != null) {
      map['vitals_snapshot_json'] = Variable<String>(vitalsSnapshotJson);
    }
    if (!nullToAbsent || aiRiskScore != null) {
      map['ai_risk_score'] = Variable<double>(aiRiskScore);
    }
    if (!nullToAbsent || facilityId != null) {
      map['facility_id'] = Variable<String>(facilityId);
    }
    map['status'] = Variable<String>(status);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['synced'] = Variable<bool>(synced);
    return map;
  }

  ReferralsCompanion toCompanion(bool nullToAbsent) {
    return ReferralsCompanion(
      id: Value(id),
      patientId: Value(patientId),
      triggerType: Value(triggerType),
      triggerDetailJson: triggerDetailJson == null && nullToAbsent
          ? const Value.absent()
          : Value(triggerDetailJson),
      vitalsSnapshotJson: vitalsSnapshotJson == null && nullToAbsent
          ? const Value.absent()
          : Value(vitalsSnapshotJson),
      aiRiskScore: aiRiskScore == null && nullToAbsent
          ? const Value.absent()
          : Value(aiRiskScore),
      facilityId: facilityId == null && nullToAbsent
          ? const Value.absent()
          : Value(facilityId),
      status: Value(status),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      synced: Value(synced),
    );
  }

  factory LocalReferral.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalReferral(
      id: serializer.fromJson<String>(json['id']),
      patientId: serializer.fromJson<String>(json['patientId']),
      triggerType: serializer.fromJson<String>(json['triggerType']),
      triggerDetailJson:
          serializer.fromJson<String?>(json['triggerDetailJson']),
      vitalsSnapshotJson:
          serializer.fromJson<String?>(json['vitalsSnapshotJson']),
      aiRiskScore: serializer.fromJson<double?>(json['aiRiskScore']),
      facilityId: serializer.fromJson<String?>(json['facilityId']),
      status: serializer.fromJson<String>(json['status']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      synced: serializer.fromJson<bool>(json['synced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'patientId': serializer.toJson<String>(patientId),
      'triggerType': serializer.toJson<String>(triggerType),
      'triggerDetailJson': serializer.toJson<String?>(triggerDetailJson),
      'vitalsSnapshotJson': serializer.toJson<String?>(vitalsSnapshotJson),
      'aiRiskScore': serializer.toJson<double?>(aiRiskScore),
      'facilityId': serializer.toJson<String?>(facilityId),
      'status': serializer.toJson<String>(status),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'synced': serializer.toJson<bool>(synced),
    };
  }

  LocalReferral copyWith(
          {String? id,
          String? patientId,
          String? triggerType,
          Value<String?> triggerDetailJson = const Value.absent(),
          Value<String?> vitalsSnapshotJson = const Value.absent(),
          Value<double?> aiRiskScore = const Value.absent(),
          Value<String?> facilityId = const Value.absent(),
          String? status,
          DateTime? createdAt,
          DateTime? updatedAt,
          bool? synced}) =>
      LocalReferral(
        id: id ?? this.id,
        patientId: patientId ?? this.patientId,
        triggerType: triggerType ?? this.triggerType,
        triggerDetailJson: triggerDetailJson.present
            ? triggerDetailJson.value
            : this.triggerDetailJson,
        vitalsSnapshotJson: vitalsSnapshotJson.present
            ? vitalsSnapshotJson.value
            : this.vitalsSnapshotJson,
        aiRiskScore: aiRiskScore.present ? aiRiskScore.value : this.aiRiskScore,
        facilityId: facilityId.present ? facilityId.value : this.facilityId,
        status: status ?? this.status,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        synced: synced ?? this.synced,
      );
  LocalReferral copyWithCompanion(ReferralsCompanion data) {
    return LocalReferral(
      id: data.id.present ? data.id.value : this.id,
      patientId: data.patientId.present ? data.patientId.value : this.patientId,
      triggerType:
          data.triggerType.present ? data.triggerType.value : this.triggerType,
      triggerDetailJson: data.triggerDetailJson.present
          ? data.triggerDetailJson.value
          : this.triggerDetailJson,
      vitalsSnapshotJson: data.vitalsSnapshotJson.present
          ? data.vitalsSnapshotJson.value
          : this.vitalsSnapshotJson,
      aiRiskScore:
          data.aiRiskScore.present ? data.aiRiskScore.value : this.aiRiskScore,
      facilityId:
          data.facilityId.present ? data.facilityId.value : this.facilityId,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      synced: data.synced.present ? data.synced.value : this.synced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalReferral(')
          ..write('id: $id, ')
          ..write('patientId: $patientId, ')
          ..write('triggerType: $triggerType, ')
          ..write('triggerDetailJson: $triggerDetailJson, ')
          ..write('vitalsSnapshotJson: $vitalsSnapshotJson, ')
          ..write('aiRiskScore: $aiRiskScore, ')
          ..write('facilityId: $facilityId, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('synced: $synced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      patientId,
      triggerType,
      triggerDetailJson,
      vitalsSnapshotJson,
      aiRiskScore,
      facilityId,
      status,
      createdAt,
      updatedAt,
      synced);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalReferral &&
          other.id == this.id &&
          other.patientId == this.patientId &&
          other.triggerType == this.triggerType &&
          other.triggerDetailJson == this.triggerDetailJson &&
          other.vitalsSnapshotJson == this.vitalsSnapshotJson &&
          other.aiRiskScore == this.aiRiskScore &&
          other.facilityId == this.facilityId &&
          other.status == this.status &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.synced == this.synced);
}

class ReferralsCompanion extends UpdateCompanion<LocalReferral> {
  final Value<String> id;
  final Value<String> patientId;
  final Value<String> triggerType;
  final Value<String?> triggerDetailJson;
  final Value<String?> vitalsSnapshotJson;
  final Value<double?> aiRiskScore;
  final Value<String?> facilityId;
  final Value<String> status;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> synced;
  final Value<int> rowid;
  const ReferralsCompanion({
    this.id = const Value.absent(),
    this.patientId = const Value.absent(),
    this.triggerType = const Value.absent(),
    this.triggerDetailJson = const Value.absent(),
    this.vitalsSnapshotJson = const Value.absent(),
    this.aiRiskScore = const Value.absent(),
    this.facilityId = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReferralsCompanion.insert({
    required String id,
    required String patientId,
    required String triggerType,
    this.triggerDetailJson = const Value.absent(),
    this.vitalsSnapshotJson = const Value.absent(),
    this.aiRiskScore = const Value.absent(),
    this.facilityId = const Value.absent(),
    this.status = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        patientId = Value(patientId),
        triggerType = Value(triggerType),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<LocalReferral> custom({
    Expression<String>? id,
    Expression<String>? patientId,
    Expression<String>? triggerType,
    Expression<String>? triggerDetailJson,
    Expression<String>? vitalsSnapshotJson,
    Expression<double>? aiRiskScore,
    Expression<String>? facilityId,
    Expression<String>? status,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? synced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (patientId != null) 'patient_id': patientId,
      if (triggerType != null) 'trigger_type': triggerType,
      if (triggerDetailJson != null) 'trigger_detail_json': triggerDetailJson,
      if (vitalsSnapshotJson != null)
        'vitals_snapshot_json': vitalsSnapshotJson,
      if (aiRiskScore != null) 'ai_risk_score': aiRiskScore,
      if (facilityId != null) 'facility_id': facilityId,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (synced != null) 'synced': synced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReferralsCompanion copyWith(
      {Value<String>? id,
      Value<String>? patientId,
      Value<String>? triggerType,
      Value<String?>? triggerDetailJson,
      Value<String?>? vitalsSnapshotJson,
      Value<double?>? aiRiskScore,
      Value<String?>? facilityId,
      Value<String>? status,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<bool>? synced,
      Value<int>? rowid}) {
    return ReferralsCompanion(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      triggerType: triggerType ?? this.triggerType,
      triggerDetailJson: triggerDetailJson ?? this.triggerDetailJson,
      vitalsSnapshotJson: vitalsSnapshotJson ?? this.vitalsSnapshotJson,
      aiRiskScore: aiRiskScore ?? this.aiRiskScore,
      facilityId: facilityId ?? this.facilityId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      synced: synced ?? this.synced,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (patientId.present) {
      map['patient_id'] = Variable<String>(patientId.value);
    }
    if (triggerType.present) {
      map['trigger_type'] = Variable<String>(triggerType.value);
    }
    if (triggerDetailJson.present) {
      map['trigger_detail_json'] = Variable<String>(triggerDetailJson.value);
    }
    if (vitalsSnapshotJson.present) {
      map['vitals_snapshot_json'] = Variable<String>(vitalsSnapshotJson.value);
    }
    if (aiRiskScore.present) {
      map['ai_risk_score'] = Variable<double>(aiRiskScore.value);
    }
    if (facilityId.present) {
      map['facility_id'] = Variable<String>(facilityId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReferralsCompanion(')
          ..write('id: $id, ')
          ..write('patientId: $patientId, ')
          ..write('triggerType: $triggerType, ')
          ..write('triggerDetailJson: $triggerDetailJson, ')
          ..write('vitalsSnapshotJson: $vitalsSnapshotJson, ')
          ..write('aiRiskScore: $aiRiskScore, ')
          ..write('facilityId: $facilityId, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('synced: $synced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FacilitiesTable extends Facilities
    with TableInfo<$FacilitiesTable, LocalFacility> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FacilitiesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _facilityTypeMeta =
      const VerificationMeta('facilityType');
  @override
  late final GeneratedColumn<String> facilityType = GeneratedColumn<String>(
      'facility_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _addressMeta =
      const VerificationMeta('address');
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
      'address', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
      'phone', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _latitudeMeta =
      const VerificationMeta('latitude');
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
      'latitude', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _longitudeMeta =
      const VerificationMeta('longitude');
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
      'longitude', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, facilityType, address, phone, latitude, longitude];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'facilities';
  @override
  VerificationContext validateIntegrity(Insertable<LocalFacility> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('facility_type')) {
      context.handle(
          _facilityTypeMeta,
          facilityType.isAcceptableOrUnknown(
              data['facility_type']!, _facilityTypeMeta));
    } else if (isInserting) {
      context.missing(_facilityTypeMeta);
    }
    if (data.containsKey('address')) {
      context.handle(_addressMeta,
          address.isAcceptableOrUnknown(data['address']!, _addressMeta));
    }
    if (data.containsKey('phone')) {
      context.handle(
          _phoneMeta, phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta));
    }
    if (data.containsKey('latitude')) {
      context.handle(_latitudeMeta,
          latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta));
    }
    if (data.containsKey('longitude')) {
      context.handle(_longitudeMeta,
          longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalFacility map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalFacility(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      facilityType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}facility_type'])!,
      address: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}address']),
      phone: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}phone']),
      latitude: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}latitude']),
      longitude: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}longitude']),
    );
  }

  @override
  $FacilitiesTable createAlias(String alias) {
    return $FacilitiesTable(attachedDatabase, alias);
  }
}

class LocalFacility extends DataClass implements Insertable<LocalFacility> {
  final String id;
  final String name;
  final String facilityType;
  final String? address;
  final String? phone;
  final double? latitude;
  final double? longitude;
  const LocalFacility(
      {required this.id,
      required this.name,
      required this.facilityType,
      this.address,
      this.phone,
      this.latitude,
      this.longitude});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['facility_type'] = Variable<String>(facilityType);
    if (!nullToAbsent || address != null) {
      map['address'] = Variable<String>(address);
    }
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    if (!nullToAbsent || latitude != null) {
      map['latitude'] = Variable<double>(latitude);
    }
    if (!nullToAbsent || longitude != null) {
      map['longitude'] = Variable<double>(longitude);
    }
    return map;
  }

  FacilitiesCompanion toCompanion(bool nullToAbsent) {
    return FacilitiesCompanion(
      id: Value(id),
      name: Value(name),
      facilityType: Value(facilityType),
      address: address == null && nullToAbsent
          ? const Value.absent()
          : Value(address),
      phone:
          phone == null && nullToAbsent ? const Value.absent() : Value(phone),
      latitude: latitude == null && nullToAbsent
          ? const Value.absent()
          : Value(latitude),
      longitude: longitude == null && nullToAbsent
          ? const Value.absent()
          : Value(longitude),
    );
  }

  factory LocalFacility.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalFacility(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      facilityType: serializer.fromJson<String>(json['facilityType']),
      address: serializer.fromJson<String?>(json['address']),
      phone: serializer.fromJson<String?>(json['phone']),
      latitude: serializer.fromJson<double?>(json['latitude']),
      longitude: serializer.fromJson<double?>(json['longitude']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'facilityType': serializer.toJson<String>(facilityType),
      'address': serializer.toJson<String?>(address),
      'phone': serializer.toJson<String?>(phone),
      'latitude': serializer.toJson<double?>(latitude),
      'longitude': serializer.toJson<double?>(longitude),
    };
  }

  LocalFacility copyWith(
          {String? id,
          String? name,
          String? facilityType,
          Value<String?> address = const Value.absent(),
          Value<String?> phone = const Value.absent(),
          Value<double?> latitude = const Value.absent(),
          Value<double?> longitude = const Value.absent()}) =>
      LocalFacility(
        id: id ?? this.id,
        name: name ?? this.name,
        facilityType: facilityType ?? this.facilityType,
        address: address.present ? address.value : this.address,
        phone: phone.present ? phone.value : this.phone,
        latitude: latitude.present ? latitude.value : this.latitude,
        longitude: longitude.present ? longitude.value : this.longitude,
      );
  LocalFacility copyWithCompanion(FacilitiesCompanion data) {
    return LocalFacility(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      facilityType: data.facilityType.present
          ? data.facilityType.value
          : this.facilityType,
      address: data.address.present ? data.address.value : this.address,
      phone: data.phone.present ? data.phone.value : this.phone,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalFacility(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('facilityType: $facilityType, ')
          ..write('address: $address, ')
          ..write('phone: $phone, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, facilityType, address, phone, latitude, longitude);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalFacility &&
          other.id == this.id &&
          other.name == this.name &&
          other.facilityType == this.facilityType &&
          other.address == this.address &&
          other.phone == this.phone &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude);
}

class FacilitiesCompanion extends UpdateCompanion<LocalFacility> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> facilityType;
  final Value<String?> address;
  final Value<String?> phone;
  final Value<double?> latitude;
  final Value<double?> longitude;
  final Value<int> rowid;
  const FacilitiesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.facilityType = const Value.absent(),
    this.address = const Value.absent(),
    this.phone = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FacilitiesCompanion.insert({
    required String id,
    required String name,
    required String facilityType,
    this.address = const Value.absent(),
    this.phone = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        facilityType = Value(facilityType);
  static Insertable<LocalFacility> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? facilityType,
    Expression<String>? address,
    Expression<String>? phone,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (facilityType != null) 'facility_type': facilityType,
      if (address != null) 'address': address,
      if (phone != null) 'phone': phone,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FacilitiesCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String>? facilityType,
      Value<String?>? address,
      Value<String?>? phone,
      Value<double?>? latitude,
      Value<double?>? longitude,
      Value<int>? rowid}) {
    return FacilitiesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      facilityType: facilityType ?? this.facilityType,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (facilityType.present) {
      map['facility_type'] = Variable<String>(facilityType.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FacilitiesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('facilityType: $facilityType, ')
          ..write('address: $address, ')
          ..write('phone: $phone, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncOutboxTable extends SyncOutbox
    with TableInfo<$SyncOutboxTable, LocalSyncOutbox> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncOutboxTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _syncTableNameMeta =
      const VerificationMeta('syncTableName');
  @override
  late final GeneratedColumn<String> syncTableName = GeneratedColumn<String>(
      'sync_table_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _recordIdMeta =
      const VerificationMeta('recordId');
  @override
  late final GeneratedColumn<String> recordId = GeneratedColumn<String>(
      'record_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _operationMeta =
      const VerificationMeta('operation');
  @override
  late final GeneratedColumn<String> operation = GeneratedColumn<String>(
      'operation', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _payloadJsonMeta =
      const VerificationMeta('payloadJson');
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
      'payload_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _retryCountMeta =
      const VerificationMeta('retryCount');
  @override
  late final GeneratedColumn<int> retryCount = GeneratedColumn<int>(
      'retry_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _lastErrorMeta =
      const VerificationMeta('lastError');
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
      'last_error', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        syncTableName,
        recordId,
        operation,
        payloadJson,
        createdAt,
        retryCount,
        lastError
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_outbox';
  @override
  VerificationContext validateIntegrity(Insertable<LocalSyncOutbox> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('sync_table_name')) {
      context.handle(
          _syncTableNameMeta,
          syncTableName.isAcceptableOrUnknown(
              data['sync_table_name']!, _syncTableNameMeta));
    } else if (isInserting) {
      context.missing(_syncTableNameMeta);
    }
    if (data.containsKey('record_id')) {
      context.handle(_recordIdMeta,
          recordId.isAcceptableOrUnknown(data['record_id']!, _recordIdMeta));
    } else if (isInserting) {
      context.missing(_recordIdMeta);
    }
    if (data.containsKey('operation')) {
      context.handle(_operationMeta,
          operation.isAcceptableOrUnknown(data['operation']!, _operationMeta));
    } else if (isInserting) {
      context.missing(_operationMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
          _payloadJsonMeta,
          payloadJson.isAcceptableOrUnknown(
              data['payload_json']!, _payloadJsonMeta));
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('retry_count')) {
      context.handle(
          _retryCountMeta,
          retryCount.isAcceptableOrUnknown(
              data['retry_count']!, _retryCountMeta));
    }
    if (data.containsKey('last_error')) {
      context.handle(_lastErrorMeta,
          lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalSyncOutbox map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalSyncOutbox(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      syncTableName: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}sync_table_name'])!,
      recordId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}record_id'])!,
      operation: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}operation'])!,
      payloadJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payload_json'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      retryCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}retry_count'])!,
      lastError: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}last_error']),
    );
  }

  @override
  $SyncOutboxTable createAlias(String alias) {
    return $SyncOutboxTable(attachedDatabase, alias);
  }
}

class LocalSyncOutbox extends DataClass implements Insertable<LocalSyncOutbox> {
  final int id;
  final String syncTableName;
  final String recordId;
  final String operation;
  final String payloadJson;
  final DateTime createdAt;
  final int retryCount;
  final String? lastError;
  const LocalSyncOutbox(
      {required this.id,
      required this.syncTableName,
      required this.recordId,
      required this.operation,
      required this.payloadJson,
      required this.createdAt,
      required this.retryCount,
      this.lastError});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['sync_table_name'] = Variable<String>(syncTableName);
    map['record_id'] = Variable<String>(recordId);
    map['operation'] = Variable<String>(operation);
    map['payload_json'] = Variable<String>(payloadJson);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['retry_count'] = Variable<int>(retryCount);
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    return map;
  }

  SyncOutboxCompanion toCompanion(bool nullToAbsent) {
    return SyncOutboxCompanion(
      id: Value(id),
      syncTableName: Value(syncTableName),
      recordId: Value(recordId),
      operation: Value(operation),
      payloadJson: Value(payloadJson),
      createdAt: Value(createdAt),
      retryCount: Value(retryCount),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
    );
  }

  factory LocalSyncOutbox.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalSyncOutbox(
      id: serializer.fromJson<int>(json['id']),
      syncTableName: serializer.fromJson<String>(json['syncTableName']),
      recordId: serializer.fromJson<String>(json['recordId']),
      operation: serializer.fromJson<String>(json['operation']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      retryCount: serializer.fromJson<int>(json['retryCount']),
      lastError: serializer.fromJson<String?>(json['lastError']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'syncTableName': serializer.toJson<String>(syncTableName),
      'recordId': serializer.toJson<String>(recordId),
      'operation': serializer.toJson<String>(operation),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'retryCount': serializer.toJson<int>(retryCount),
      'lastError': serializer.toJson<String?>(lastError),
    };
  }

  LocalSyncOutbox copyWith(
          {int? id,
          String? syncTableName,
          String? recordId,
          String? operation,
          String? payloadJson,
          DateTime? createdAt,
          int? retryCount,
          Value<String?> lastError = const Value.absent()}) =>
      LocalSyncOutbox(
        id: id ?? this.id,
        syncTableName: syncTableName ?? this.syncTableName,
        recordId: recordId ?? this.recordId,
        operation: operation ?? this.operation,
        payloadJson: payloadJson ?? this.payloadJson,
        createdAt: createdAt ?? this.createdAt,
        retryCount: retryCount ?? this.retryCount,
        lastError: lastError.present ? lastError.value : this.lastError,
      );
  LocalSyncOutbox copyWithCompanion(SyncOutboxCompanion data) {
    return LocalSyncOutbox(
      id: data.id.present ? data.id.value : this.id,
      syncTableName: data.syncTableName.present
          ? data.syncTableName.value
          : this.syncTableName,
      recordId: data.recordId.present ? data.recordId.value : this.recordId,
      operation: data.operation.present ? data.operation.value : this.operation,
      payloadJson:
          data.payloadJson.present ? data.payloadJson.value : this.payloadJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      retryCount:
          data.retryCount.present ? data.retryCount.value : this.retryCount,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalSyncOutbox(')
          ..write('id: $id, ')
          ..write('syncTableName: $syncTableName, ')
          ..write('recordId: $recordId, ')
          ..write('operation: $operation, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('retryCount: $retryCount, ')
          ..write('lastError: $lastError')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, syncTableName, recordId, operation,
      payloadJson, createdAt, retryCount, lastError);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalSyncOutbox &&
          other.id == this.id &&
          other.syncTableName == this.syncTableName &&
          other.recordId == this.recordId &&
          other.operation == this.operation &&
          other.payloadJson == this.payloadJson &&
          other.createdAt == this.createdAt &&
          other.retryCount == this.retryCount &&
          other.lastError == this.lastError);
}

class SyncOutboxCompanion extends UpdateCompanion<LocalSyncOutbox> {
  final Value<int> id;
  final Value<String> syncTableName;
  final Value<String> recordId;
  final Value<String> operation;
  final Value<String> payloadJson;
  final Value<DateTime> createdAt;
  final Value<int> retryCount;
  final Value<String?> lastError;
  const SyncOutboxCompanion({
    this.id = const Value.absent(),
    this.syncTableName = const Value.absent(),
    this.recordId = const Value.absent(),
    this.operation = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.lastError = const Value.absent(),
  });
  SyncOutboxCompanion.insert({
    this.id = const Value.absent(),
    required String syncTableName,
    required String recordId,
    required String operation,
    required String payloadJson,
    required DateTime createdAt,
    this.retryCount = const Value.absent(),
    this.lastError = const Value.absent(),
  })  : syncTableName = Value(syncTableName),
        recordId = Value(recordId),
        operation = Value(operation),
        payloadJson = Value(payloadJson),
        createdAt = Value(createdAt);
  static Insertable<LocalSyncOutbox> custom({
    Expression<int>? id,
    Expression<String>? syncTableName,
    Expression<String>? recordId,
    Expression<String>? operation,
    Expression<String>? payloadJson,
    Expression<DateTime>? createdAt,
    Expression<int>? retryCount,
    Expression<String>? lastError,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (syncTableName != null) 'sync_table_name': syncTableName,
      if (recordId != null) 'record_id': recordId,
      if (operation != null) 'operation': operation,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (createdAt != null) 'created_at': createdAt,
      if (retryCount != null) 'retry_count': retryCount,
      if (lastError != null) 'last_error': lastError,
    });
  }

  SyncOutboxCompanion copyWith(
      {Value<int>? id,
      Value<String>? syncTableName,
      Value<String>? recordId,
      Value<String>? operation,
      Value<String>? payloadJson,
      Value<DateTime>? createdAt,
      Value<int>? retryCount,
      Value<String?>? lastError}) {
    return SyncOutboxCompanion(
      id: id ?? this.id,
      syncTableName: syncTableName ?? this.syncTableName,
      recordId: recordId ?? this.recordId,
      operation: operation ?? this.operation,
      payloadJson: payloadJson ?? this.payloadJson,
      createdAt: createdAt ?? this.createdAt,
      retryCount: retryCount ?? this.retryCount,
      lastError: lastError ?? this.lastError,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (syncTableName.present) {
      map['sync_table_name'] = Variable<String>(syncTableName.value);
    }
    if (recordId.present) {
      map['record_id'] = Variable<String>(recordId.value);
    }
    if (operation.present) {
      map['operation'] = Variable<String>(operation.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (retryCount.present) {
      map['retry_count'] = Variable<int>(retryCount.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncOutboxCompanion(')
          ..write('id: $id, ')
          ..write('syncTableName: $syncTableName, ')
          ..write('recordId: $recordId, ')
          ..write('operation: $operation, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('retryCount: $retryCount, ')
          ..write('lastError: $lastError')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $PatientsTable patients = $PatientsTable(this);
  late final $DevicesTable devices = $DevicesTable(this);
  late final $MonitoringSessionsTable monitoringSessions =
      $MonitoringSessionsTable(this);
  late final $ReadingsTable readings = $ReadingsTable(this);
  late final $RiskScoresTable riskScores = $RiskScoresTable(this);
  late final $ReferralsTable referrals = $ReferralsTable(this);
  late final $FacilitiesTable facilities = $FacilitiesTable(this);
  late final $SyncOutboxTable syncOutbox = $SyncOutboxTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        patients,
        devices,
        monitoringSessions,
        readings,
        riskScores,
        referrals,
        facilities,
        syncOutbox
      ];
}

typedef $$PatientsTableCreateCompanionBuilder = PatientsCompanion Function({
  required String id,
  required String fullName,
  Value<String?> phone,
  Value<int?> age,
  Value<int> gravida,
  Value<int> parity,
  Value<bool> isPregnant,
  Value<int?> gestationalWeeksAtRegistration,
  Value<DateTime?> pregnancyRegisteredAt,
  Value<String?> expectedDeliveryDate,
  Value<bool> priorStillbirth,
  Value<bool> priorCsection,
  Value<bool> priorPreeclampsia,
  Value<bool> hivPositive,
  Value<bool> diabetes,
  Value<bool> anaemia,
  Value<bool> multiplePregnancy,
  Value<String?> nearestFacilityId,
  Value<String?> latestRiskTier,
  Value<double?> latestRiskScore,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<bool> synced,
  Value<int> rowid,
});
typedef $$PatientsTableUpdateCompanionBuilder = PatientsCompanion Function({
  Value<String> id,
  Value<String> fullName,
  Value<String?> phone,
  Value<int?> age,
  Value<int> gravida,
  Value<int> parity,
  Value<bool> isPregnant,
  Value<int?> gestationalWeeksAtRegistration,
  Value<DateTime?> pregnancyRegisteredAt,
  Value<String?> expectedDeliveryDate,
  Value<bool> priorStillbirth,
  Value<bool> priorCsection,
  Value<bool> priorPreeclampsia,
  Value<bool> hivPositive,
  Value<bool> diabetes,
  Value<bool> anaemia,
  Value<bool> multiplePregnancy,
  Value<String?> nearestFacilityId,
  Value<String?> latestRiskTier,
  Value<double?> latestRiskScore,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<bool> synced,
  Value<int> rowid,
});

class $$PatientsTableFilterComposer
    extends Composer<_$AppDatabase, $PatientsTable> {
  $$PatientsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get fullName => $composableBuilder(
      column: $table.fullName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get age => $composableBuilder(
      column: $table.age, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get gravida => $composableBuilder(
      column: $table.gravida, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get parity => $composableBuilder(
      column: $table.parity, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isPregnant => $composableBuilder(
      column: $table.isPregnant, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get gestationalWeeksAtRegistration => $composableBuilder(
      column: $table.gestationalWeeksAtRegistration,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get pregnancyRegisteredAt => $composableBuilder(
      column: $table.pregnancyRegisteredAt,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get expectedDeliveryDate => $composableBuilder(
      column: $table.expectedDeliveryDate,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get priorStillbirth => $composableBuilder(
      column: $table.priorStillbirth,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get priorCsection => $composableBuilder(
      column: $table.priorCsection, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get priorPreeclampsia => $composableBuilder(
      column: $table.priorPreeclampsia,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get hivPositive => $composableBuilder(
      column: $table.hivPositive, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get diabetes => $composableBuilder(
      column: $table.diabetes, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get anaemia => $composableBuilder(
      column: $table.anaemia, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get multiplePregnancy => $composableBuilder(
      column: $table.multiplePregnancy,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nearestFacilityId => $composableBuilder(
      column: $table.nearestFacilityId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get latestRiskTier => $composableBuilder(
      column: $table.latestRiskTier,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get latestRiskScore => $composableBuilder(
      column: $table.latestRiskScore,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get synced => $composableBuilder(
      column: $table.synced, builder: (column) => ColumnFilters(column));
}

class $$PatientsTableOrderingComposer
    extends Composer<_$AppDatabase, $PatientsTable> {
  $$PatientsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fullName => $composableBuilder(
      column: $table.fullName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get age => $composableBuilder(
      column: $table.age, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get gravida => $composableBuilder(
      column: $table.gravida, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get parity => $composableBuilder(
      column: $table.parity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isPregnant => $composableBuilder(
      column: $table.isPregnant, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get gestationalWeeksAtRegistration => $composableBuilder(
      column: $table.gestationalWeeksAtRegistration,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get pregnancyRegisteredAt => $composableBuilder(
      column: $table.pregnancyRegisteredAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get expectedDeliveryDate => $composableBuilder(
      column: $table.expectedDeliveryDate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get priorStillbirth => $composableBuilder(
      column: $table.priorStillbirth,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get priorCsection => $composableBuilder(
      column: $table.priorCsection,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get priorPreeclampsia => $composableBuilder(
      column: $table.priorPreeclampsia,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get hivPositive => $composableBuilder(
      column: $table.hivPositive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get diabetes => $composableBuilder(
      column: $table.diabetes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get anaemia => $composableBuilder(
      column: $table.anaemia, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get multiplePregnancy => $composableBuilder(
      column: $table.multiplePregnancy,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nearestFacilityId => $composableBuilder(
      column: $table.nearestFacilityId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get latestRiskTier => $composableBuilder(
      column: $table.latestRiskTier,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get latestRiskScore => $composableBuilder(
      column: $table.latestRiskScore,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get synced => $composableBuilder(
      column: $table.synced, builder: (column) => ColumnOrderings(column));
}

class $$PatientsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PatientsTable> {
  $$PatientsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get fullName =>
      $composableBuilder(column: $table.fullName, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<int> get age =>
      $composableBuilder(column: $table.age, builder: (column) => column);

  GeneratedColumn<int> get gravida =>
      $composableBuilder(column: $table.gravida, builder: (column) => column);

  GeneratedColumn<int> get parity =>
      $composableBuilder(column: $table.parity, builder: (column) => column);

  GeneratedColumn<bool> get isPregnant => $composableBuilder(
      column: $table.isPregnant, builder: (column) => column);

  GeneratedColumn<int> get gestationalWeeksAtRegistration => $composableBuilder(
      column: $table.gestationalWeeksAtRegistration,
      builder: (column) => column);

  GeneratedColumn<DateTime> get pregnancyRegisteredAt => $composableBuilder(
      column: $table.pregnancyRegisteredAt, builder: (column) => column);

  GeneratedColumn<String> get expectedDeliveryDate => $composableBuilder(
      column: $table.expectedDeliveryDate, builder: (column) => column);

  GeneratedColumn<bool> get priorStillbirth => $composableBuilder(
      column: $table.priorStillbirth, builder: (column) => column);

  GeneratedColumn<bool> get priorCsection => $composableBuilder(
      column: $table.priorCsection, builder: (column) => column);

  GeneratedColumn<bool> get priorPreeclampsia => $composableBuilder(
      column: $table.priorPreeclampsia, builder: (column) => column);

  GeneratedColumn<bool> get hivPositive => $composableBuilder(
      column: $table.hivPositive, builder: (column) => column);

  GeneratedColumn<bool> get diabetes =>
      $composableBuilder(column: $table.diabetes, builder: (column) => column);

  GeneratedColumn<bool> get anaemia =>
      $composableBuilder(column: $table.anaemia, builder: (column) => column);

  GeneratedColumn<bool> get multiplePregnancy => $composableBuilder(
      column: $table.multiplePregnancy, builder: (column) => column);

  GeneratedColumn<String> get nearestFacilityId => $composableBuilder(
      column: $table.nearestFacilityId, builder: (column) => column);

  GeneratedColumn<String> get latestRiskTier => $composableBuilder(
      column: $table.latestRiskTier, builder: (column) => column);

  GeneratedColumn<double> get latestRiskScore => $composableBuilder(
      column: $table.latestRiskScore, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);
}

class $$PatientsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PatientsTable,
    LocalPatient,
    $$PatientsTableFilterComposer,
    $$PatientsTableOrderingComposer,
    $$PatientsTableAnnotationComposer,
    $$PatientsTableCreateCompanionBuilder,
    $$PatientsTableUpdateCompanionBuilder,
    (LocalPatient, BaseReferences<_$AppDatabase, $PatientsTable, LocalPatient>),
    LocalPatient,
    PrefetchHooks Function()> {
  $$PatientsTableTableManager(_$AppDatabase db, $PatientsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PatientsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PatientsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PatientsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> fullName = const Value.absent(),
            Value<String?> phone = const Value.absent(),
            Value<int?> age = const Value.absent(),
            Value<int> gravida = const Value.absent(),
            Value<int> parity = const Value.absent(),
            Value<bool> isPregnant = const Value.absent(),
            Value<int?> gestationalWeeksAtRegistration = const Value.absent(),
            Value<DateTime?> pregnancyRegisteredAt = const Value.absent(),
            Value<String?> expectedDeliveryDate = const Value.absent(),
            Value<bool> priorStillbirth = const Value.absent(),
            Value<bool> priorCsection = const Value.absent(),
            Value<bool> priorPreeclampsia = const Value.absent(),
            Value<bool> hivPositive = const Value.absent(),
            Value<bool> diabetes = const Value.absent(),
            Value<bool> anaemia = const Value.absent(),
            Value<bool> multiplePregnancy = const Value.absent(),
            Value<String?> nearestFacilityId = const Value.absent(),
            Value<String?> latestRiskTier = const Value.absent(),
            Value<double?> latestRiskScore = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> synced = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PatientsCompanion(
            id: id,
            fullName: fullName,
            phone: phone,
            age: age,
            gravida: gravida,
            parity: parity,
            isPregnant: isPregnant,
            gestationalWeeksAtRegistration: gestationalWeeksAtRegistration,
            pregnancyRegisteredAt: pregnancyRegisteredAt,
            expectedDeliveryDate: expectedDeliveryDate,
            priorStillbirth: priorStillbirth,
            priorCsection: priorCsection,
            priorPreeclampsia: priorPreeclampsia,
            hivPositive: hivPositive,
            diabetes: diabetes,
            anaemia: anaemia,
            multiplePregnancy: multiplePregnancy,
            nearestFacilityId: nearestFacilityId,
            latestRiskTier: latestRiskTier,
            latestRiskScore: latestRiskScore,
            createdAt: createdAt,
            updatedAt: updatedAt,
            synced: synced,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String fullName,
            Value<String?> phone = const Value.absent(),
            Value<int?> age = const Value.absent(),
            Value<int> gravida = const Value.absent(),
            Value<int> parity = const Value.absent(),
            Value<bool> isPregnant = const Value.absent(),
            Value<int?> gestationalWeeksAtRegistration = const Value.absent(),
            Value<DateTime?> pregnancyRegisteredAt = const Value.absent(),
            Value<String?> expectedDeliveryDate = const Value.absent(),
            Value<bool> priorStillbirth = const Value.absent(),
            Value<bool> priorCsection = const Value.absent(),
            Value<bool> priorPreeclampsia = const Value.absent(),
            Value<bool> hivPositive = const Value.absent(),
            Value<bool> diabetes = const Value.absent(),
            Value<bool> anaemia = const Value.absent(),
            Value<bool> multiplePregnancy = const Value.absent(),
            Value<String?> nearestFacilityId = const Value.absent(),
            Value<String?> latestRiskTier = const Value.absent(),
            Value<double?> latestRiskScore = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<bool> synced = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PatientsCompanion.insert(
            id: id,
            fullName: fullName,
            phone: phone,
            age: age,
            gravida: gravida,
            parity: parity,
            isPregnant: isPregnant,
            gestationalWeeksAtRegistration: gestationalWeeksAtRegistration,
            pregnancyRegisteredAt: pregnancyRegisteredAt,
            expectedDeliveryDate: expectedDeliveryDate,
            priorStillbirth: priorStillbirth,
            priorCsection: priorCsection,
            priorPreeclampsia: priorPreeclampsia,
            hivPositive: hivPositive,
            diabetes: diabetes,
            anaemia: anaemia,
            multiplePregnancy: multiplePregnancy,
            nearestFacilityId: nearestFacilityId,
            latestRiskTier: latestRiskTier,
            latestRiskScore: latestRiskScore,
            createdAt: createdAt,
            updatedAt: updatedAt,
            synced: synced,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$PatientsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PatientsTable,
    LocalPatient,
    $$PatientsTableFilterComposer,
    $$PatientsTableOrderingComposer,
    $$PatientsTableAnnotationComposer,
    $$PatientsTableCreateCompanionBuilder,
    $$PatientsTableUpdateCompanionBuilder,
    (LocalPatient, BaseReferences<_$AppDatabase, $PatientsTable, LocalPatient>),
    LocalPatient,
    PrefetchHooks Function()>;
typedef $$DevicesTableCreateCompanionBuilder = DevicesCompanion Function({
  required String id,
  required String deviceHardwareId,
  required String deviceName,
  required String deviceType,
  Value<String?> assignedPatientId,
  Value<String> status,
  Value<int?> batteryLevel,
  Value<DateTime?> lastSeenAt,
  required DateTime createdAt,
  Value<bool> synced,
  Value<int> rowid,
});
typedef $$DevicesTableUpdateCompanionBuilder = DevicesCompanion Function({
  Value<String> id,
  Value<String> deviceHardwareId,
  Value<String> deviceName,
  Value<String> deviceType,
  Value<String?> assignedPatientId,
  Value<String> status,
  Value<int?> batteryLevel,
  Value<DateTime?> lastSeenAt,
  Value<DateTime> createdAt,
  Value<bool> synced,
  Value<int> rowid,
});

class $$DevicesTableFilterComposer
    extends Composer<_$AppDatabase, $DevicesTable> {
  $$DevicesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deviceHardwareId => $composableBuilder(
      column: $table.deviceHardwareId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deviceName => $composableBuilder(
      column: $table.deviceName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deviceType => $composableBuilder(
      column: $table.deviceType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get assignedPatientId => $composableBuilder(
      column: $table.assignedPatientId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get batteryLevel => $composableBuilder(
      column: $table.batteryLevel, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastSeenAt => $composableBuilder(
      column: $table.lastSeenAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get synced => $composableBuilder(
      column: $table.synced, builder: (column) => ColumnFilters(column));
}

class $$DevicesTableOrderingComposer
    extends Composer<_$AppDatabase, $DevicesTable> {
  $$DevicesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deviceHardwareId => $composableBuilder(
      column: $table.deviceHardwareId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deviceName => $composableBuilder(
      column: $table.deviceName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deviceType => $composableBuilder(
      column: $table.deviceType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get assignedPatientId => $composableBuilder(
      column: $table.assignedPatientId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get batteryLevel => $composableBuilder(
      column: $table.batteryLevel,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastSeenAt => $composableBuilder(
      column: $table.lastSeenAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get synced => $composableBuilder(
      column: $table.synced, builder: (column) => ColumnOrderings(column));
}

class $$DevicesTableAnnotationComposer
    extends Composer<_$AppDatabase, $DevicesTable> {
  $$DevicesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get deviceHardwareId => $composableBuilder(
      column: $table.deviceHardwareId, builder: (column) => column);

  GeneratedColumn<String> get deviceName => $composableBuilder(
      column: $table.deviceName, builder: (column) => column);

  GeneratedColumn<String> get deviceType => $composableBuilder(
      column: $table.deviceType, builder: (column) => column);

  GeneratedColumn<String> get assignedPatientId => $composableBuilder(
      column: $table.assignedPatientId, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get batteryLevel => $composableBuilder(
      column: $table.batteryLevel, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSeenAt => $composableBuilder(
      column: $table.lastSeenAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);
}

class $$DevicesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DevicesTable,
    LocalDevice,
    $$DevicesTableFilterComposer,
    $$DevicesTableOrderingComposer,
    $$DevicesTableAnnotationComposer,
    $$DevicesTableCreateCompanionBuilder,
    $$DevicesTableUpdateCompanionBuilder,
    (LocalDevice, BaseReferences<_$AppDatabase, $DevicesTable, LocalDevice>),
    LocalDevice,
    PrefetchHooks Function()> {
  $$DevicesTableTableManager(_$AppDatabase db, $DevicesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DevicesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DevicesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DevicesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> deviceHardwareId = const Value.absent(),
            Value<String> deviceName = const Value.absent(),
            Value<String> deviceType = const Value.absent(),
            Value<String?> assignedPatientId = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<int?> batteryLevel = const Value.absent(),
            Value<DateTime?> lastSeenAt = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<bool> synced = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DevicesCompanion(
            id: id,
            deviceHardwareId: deviceHardwareId,
            deviceName: deviceName,
            deviceType: deviceType,
            assignedPatientId: assignedPatientId,
            status: status,
            batteryLevel: batteryLevel,
            lastSeenAt: lastSeenAt,
            createdAt: createdAt,
            synced: synced,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String deviceHardwareId,
            required String deviceName,
            required String deviceType,
            Value<String?> assignedPatientId = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<int?> batteryLevel = const Value.absent(),
            Value<DateTime?> lastSeenAt = const Value.absent(),
            required DateTime createdAt,
            Value<bool> synced = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DevicesCompanion.insert(
            id: id,
            deviceHardwareId: deviceHardwareId,
            deviceName: deviceName,
            deviceType: deviceType,
            assignedPatientId: assignedPatientId,
            status: status,
            batteryLevel: batteryLevel,
            lastSeenAt: lastSeenAt,
            createdAt: createdAt,
            synced: synced,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$DevicesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $DevicesTable,
    LocalDevice,
    $$DevicesTableFilterComposer,
    $$DevicesTableOrderingComposer,
    $$DevicesTableAnnotationComposer,
    $$DevicesTableCreateCompanionBuilder,
    $$DevicesTableUpdateCompanionBuilder,
    (LocalDevice, BaseReferences<_$AppDatabase, $DevicesTable, LocalDevice>),
    LocalDevice,
    PrefetchHooks Function()>;
typedef $$MonitoringSessionsTableCreateCompanionBuilder
    = MonitoringSessionsCompanion Function({
  required String id,
  required String patientId,
  required DateTime startedAt,
  Value<DateTime?> endedAt,
  Value<double?> locationLat,
  Value<double?> locationLng,
  Value<String?> deviceId,
  Value<bool> synced,
  Value<int> rowid,
});
typedef $$MonitoringSessionsTableUpdateCompanionBuilder
    = MonitoringSessionsCompanion Function({
  Value<String> id,
  Value<String> patientId,
  Value<DateTime> startedAt,
  Value<DateTime?> endedAt,
  Value<double?> locationLat,
  Value<double?> locationLng,
  Value<String?> deviceId,
  Value<bool> synced,
  Value<int> rowid,
});

class $$MonitoringSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $MonitoringSessionsTable> {
  $$MonitoringSessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get patientId => $composableBuilder(
      column: $table.patientId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
      column: $table.startedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get endedAt => $composableBuilder(
      column: $table.endedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get locationLat => $composableBuilder(
      column: $table.locationLat, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get locationLng => $composableBuilder(
      column: $table.locationLng, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get synced => $composableBuilder(
      column: $table.synced, builder: (column) => ColumnFilters(column));
}

class $$MonitoringSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $MonitoringSessionsTable> {
  $$MonitoringSessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get patientId => $composableBuilder(
      column: $table.patientId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
      column: $table.startedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get endedAt => $composableBuilder(
      column: $table.endedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get locationLat => $composableBuilder(
      column: $table.locationLat, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get locationLng => $composableBuilder(
      column: $table.locationLng, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get synced => $composableBuilder(
      column: $table.synced, builder: (column) => ColumnOrderings(column));
}

class $$MonitoringSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MonitoringSessionsTable> {
  $$MonitoringSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get patientId =>
      $composableBuilder(column: $table.patientId, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => column);

  GeneratedColumn<double> get locationLat => $composableBuilder(
      column: $table.locationLat, builder: (column) => column);

  GeneratedColumn<double> get locationLng => $composableBuilder(
      column: $table.locationLng, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);
}

class $$MonitoringSessionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MonitoringSessionsTable,
    LocalSession,
    $$MonitoringSessionsTableFilterComposer,
    $$MonitoringSessionsTableOrderingComposer,
    $$MonitoringSessionsTableAnnotationComposer,
    $$MonitoringSessionsTableCreateCompanionBuilder,
    $$MonitoringSessionsTableUpdateCompanionBuilder,
    (
      LocalSession,
      BaseReferences<_$AppDatabase, $MonitoringSessionsTable, LocalSession>
    ),
    LocalSession,
    PrefetchHooks Function()> {
  $$MonitoringSessionsTableTableManager(
      _$AppDatabase db, $MonitoringSessionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MonitoringSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MonitoringSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MonitoringSessionsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> patientId = const Value.absent(),
            Value<DateTime> startedAt = const Value.absent(),
            Value<DateTime?> endedAt = const Value.absent(),
            Value<double?> locationLat = const Value.absent(),
            Value<double?> locationLng = const Value.absent(),
            Value<String?> deviceId = const Value.absent(),
            Value<bool> synced = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MonitoringSessionsCompanion(
            id: id,
            patientId: patientId,
            startedAt: startedAt,
            endedAt: endedAt,
            locationLat: locationLat,
            locationLng: locationLng,
            deviceId: deviceId,
            synced: synced,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String patientId,
            required DateTime startedAt,
            Value<DateTime?> endedAt = const Value.absent(),
            Value<double?> locationLat = const Value.absent(),
            Value<double?> locationLng = const Value.absent(),
            Value<String?> deviceId = const Value.absent(),
            Value<bool> synced = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MonitoringSessionsCompanion.insert(
            id: id,
            patientId: patientId,
            startedAt: startedAt,
            endedAt: endedAt,
            locationLat: locationLat,
            locationLng: locationLng,
            deviceId: deviceId,
            synced: synced,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$MonitoringSessionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $MonitoringSessionsTable,
    LocalSession,
    $$MonitoringSessionsTableFilterComposer,
    $$MonitoringSessionsTableOrderingComposer,
    $$MonitoringSessionsTableAnnotationComposer,
    $$MonitoringSessionsTableCreateCompanionBuilder,
    $$MonitoringSessionsTableUpdateCompanionBuilder,
    (
      LocalSession,
      BaseReferences<_$AppDatabase, $MonitoringSessionsTable, LocalSession>
    ),
    LocalSession,
    PrefetchHooks Function()>;
typedef $$ReadingsTableCreateCompanionBuilder = ReadingsCompanion Function({
  required String id,
  required String sessionId,
  required String patientId,
  required String vitalType,
  required String valuesJson,
  required DateTime recordedAt,
  Value<String> dangerLevel,
  Value<String> source,
  Value<String?> deviceName,
  Value<String?> deviceHardwareId,
  Value<bool> synced,
  Value<int> rowid,
});
typedef $$ReadingsTableUpdateCompanionBuilder = ReadingsCompanion Function({
  Value<String> id,
  Value<String> sessionId,
  Value<String> patientId,
  Value<String> vitalType,
  Value<String> valuesJson,
  Value<DateTime> recordedAt,
  Value<String> dangerLevel,
  Value<String> source,
  Value<String?> deviceName,
  Value<String?> deviceHardwareId,
  Value<bool> synced,
  Value<int> rowid,
});

class $$ReadingsTableFilterComposer
    extends Composer<_$AppDatabase, $ReadingsTable> {
  $$ReadingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sessionId => $composableBuilder(
      column: $table.sessionId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get patientId => $composableBuilder(
      column: $table.patientId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get vitalType => $composableBuilder(
      column: $table.vitalType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get valuesJson => $composableBuilder(
      column: $table.valuesJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get recordedAt => $composableBuilder(
      column: $table.recordedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get dangerLevel => $composableBuilder(
      column: $table.dangerLevel, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get source => $composableBuilder(
      column: $table.source, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deviceName => $composableBuilder(
      column: $table.deviceName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deviceHardwareId => $composableBuilder(
      column: $table.deviceHardwareId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get synced => $composableBuilder(
      column: $table.synced, builder: (column) => ColumnFilters(column));
}

class $$ReadingsTableOrderingComposer
    extends Composer<_$AppDatabase, $ReadingsTable> {
  $$ReadingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sessionId => $composableBuilder(
      column: $table.sessionId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get patientId => $composableBuilder(
      column: $table.patientId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get vitalType => $composableBuilder(
      column: $table.vitalType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get valuesJson => $composableBuilder(
      column: $table.valuesJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get recordedAt => $composableBuilder(
      column: $table.recordedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get dangerLevel => $composableBuilder(
      column: $table.dangerLevel, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get source => $composableBuilder(
      column: $table.source, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deviceName => $composableBuilder(
      column: $table.deviceName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deviceHardwareId => $composableBuilder(
      column: $table.deviceHardwareId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get synced => $composableBuilder(
      column: $table.synced, builder: (column) => ColumnOrderings(column));
}

class $$ReadingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReadingsTable> {
  $$ReadingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get sessionId =>
      $composableBuilder(column: $table.sessionId, builder: (column) => column);

  GeneratedColumn<String> get patientId =>
      $composableBuilder(column: $table.patientId, builder: (column) => column);

  GeneratedColumn<String> get vitalType =>
      $composableBuilder(column: $table.vitalType, builder: (column) => column);

  GeneratedColumn<String> get valuesJson => $composableBuilder(
      column: $table.valuesJson, builder: (column) => column);

  GeneratedColumn<DateTime> get recordedAt => $composableBuilder(
      column: $table.recordedAt, builder: (column) => column);

  GeneratedColumn<String> get dangerLevel => $composableBuilder(
      column: $table.dangerLevel, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get deviceName => $composableBuilder(
      column: $table.deviceName, builder: (column) => column);

  GeneratedColumn<String> get deviceHardwareId => $composableBuilder(
      column: $table.deviceHardwareId, builder: (column) => column);

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);
}

class $$ReadingsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ReadingsTable,
    LocalReading,
    $$ReadingsTableFilterComposer,
    $$ReadingsTableOrderingComposer,
    $$ReadingsTableAnnotationComposer,
    $$ReadingsTableCreateCompanionBuilder,
    $$ReadingsTableUpdateCompanionBuilder,
    (LocalReading, BaseReferences<_$AppDatabase, $ReadingsTable, LocalReading>),
    LocalReading,
    PrefetchHooks Function()> {
  $$ReadingsTableTableManager(_$AppDatabase db, $ReadingsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReadingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReadingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReadingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> sessionId = const Value.absent(),
            Value<String> patientId = const Value.absent(),
            Value<String> vitalType = const Value.absent(),
            Value<String> valuesJson = const Value.absent(),
            Value<DateTime> recordedAt = const Value.absent(),
            Value<String> dangerLevel = const Value.absent(),
            Value<String> source = const Value.absent(),
            Value<String?> deviceName = const Value.absent(),
            Value<String?> deviceHardwareId = const Value.absent(),
            Value<bool> synced = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ReadingsCompanion(
            id: id,
            sessionId: sessionId,
            patientId: patientId,
            vitalType: vitalType,
            valuesJson: valuesJson,
            recordedAt: recordedAt,
            dangerLevel: dangerLevel,
            source: source,
            deviceName: deviceName,
            deviceHardwareId: deviceHardwareId,
            synced: synced,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String sessionId,
            required String patientId,
            required String vitalType,
            required String valuesJson,
            required DateTime recordedAt,
            Value<String> dangerLevel = const Value.absent(),
            Value<String> source = const Value.absent(),
            Value<String?> deviceName = const Value.absent(),
            Value<String?> deviceHardwareId = const Value.absent(),
            Value<bool> synced = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ReadingsCompanion.insert(
            id: id,
            sessionId: sessionId,
            patientId: patientId,
            vitalType: vitalType,
            valuesJson: valuesJson,
            recordedAt: recordedAt,
            dangerLevel: dangerLevel,
            source: source,
            deviceName: deviceName,
            deviceHardwareId: deviceHardwareId,
            synced: synced,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ReadingsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ReadingsTable,
    LocalReading,
    $$ReadingsTableFilterComposer,
    $$ReadingsTableOrderingComposer,
    $$ReadingsTableAnnotationComposer,
    $$ReadingsTableCreateCompanionBuilder,
    $$ReadingsTableUpdateCompanionBuilder,
    (LocalReading, BaseReferences<_$AppDatabase, $ReadingsTable, LocalReading>),
    LocalReading,
    PrefetchHooks Function()>;
typedef $$RiskScoresTableCreateCompanionBuilder = RiskScoresCompanion Function({
  required String id,
  required String patientId,
  Value<String?> sessionId,
  required double riskScore,
  required String riskTier,
  Value<String?> topFactorsJson,
  required DateTime scoredAt,
  Value<bool> synced,
  Value<int> rowid,
});
typedef $$RiskScoresTableUpdateCompanionBuilder = RiskScoresCompanion Function({
  Value<String> id,
  Value<String> patientId,
  Value<String?> sessionId,
  Value<double> riskScore,
  Value<String> riskTier,
  Value<String?> topFactorsJson,
  Value<DateTime> scoredAt,
  Value<bool> synced,
  Value<int> rowid,
});

class $$RiskScoresTableFilterComposer
    extends Composer<_$AppDatabase, $RiskScoresTable> {
  $$RiskScoresTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get patientId => $composableBuilder(
      column: $table.patientId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sessionId => $composableBuilder(
      column: $table.sessionId, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get riskScore => $composableBuilder(
      column: $table.riskScore, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get riskTier => $composableBuilder(
      column: $table.riskTier, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get topFactorsJson => $composableBuilder(
      column: $table.topFactorsJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get scoredAt => $composableBuilder(
      column: $table.scoredAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get synced => $composableBuilder(
      column: $table.synced, builder: (column) => ColumnFilters(column));
}

class $$RiskScoresTableOrderingComposer
    extends Composer<_$AppDatabase, $RiskScoresTable> {
  $$RiskScoresTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get patientId => $composableBuilder(
      column: $table.patientId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sessionId => $composableBuilder(
      column: $table.sessionId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get riskScore => $composableBuilder(
      column: $table.riskScore, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get riskTier => $composableBuilder(
      column: $table.riskTier, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get topFactorsJson => $composableBuilder(
      column: $table.topFactorsJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get scoredAt => $composableBuilder(
      column: $table.scoredAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get synced => $composableBuilder(
      column: $table.synced, builder: (column) => ColumnOrderings(column));
}

class $$RiskScoresTableAnnotationComposer
    extends Composer<_$AppDatabase, $RiskScoresTable> {
  $$RiskScoresTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get patientId =>
      $composableBuilder(column: $table.patientId, builder: (column) => column);

  GeneratedColumn<String> get sessionId =>
      $composableBuilder(column: $table.sessionId, builder: (column) => column);

  GeneratedColumn<double> get riskScore =>
      $composableBuilder(column: $table.riskScore, builder: (column) => column);

  GeneratedColumn<String> get riskTier =>
      $composableBuilder(column: $table.riskTier, builder: (column) => column);

  GeneratedColumn<String> get topFactorsJson => $composableBuilder(
      column: $table.topFactorsJson, builder: (column) => column);

  GeneratedColumn<DateTime> get scoredAt =>
      $composableBuilder(column: $table.scoredAt, builder: (column) => column);

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);
}

class $$RiskScoresTableTableManager extends RootTableManager<
    _$AppDatabase,
    $RiskScoresTable,
    LocalRiskScore,
    $$RiskScoresTableFilterComposer,
    $$RiskScoresTableOrderingComposer,
    $$RiskScoresTableAnnotationComposer,
    $$RiskScoresTableCreateCompanionBuilder,
    $$RiskScoresTableUpdateCompanionBuilder,
    (
      LocalRiskScore,
      BaseReferences<_$AppDatabase, $RiskScoresTable, LocalRiskScore>
    ),
    LocalRiskScore,
    PrefetchHooks Function()> {
  $$RiskScoresTableTableManager(_$AppDatabase db, $RiskScoresTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RiskScoresTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RiskScoresTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RiskScoresTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> patientId = const Value.absent(),
            Value<String?> sessionId = const Value.absent(),
            Value<double> riskScore = const Value.absent(),
            Value<String> riskTier = const Value.absent(),
            Value<String?> topFactorsJson = const Value.absent(),
            Value<DateTime> scoredAt = const Value.absent(),
            Value<bool> synced = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              RiskScoresCompanion(
            id: id,
            patientId: patientId,
            sessionId: sessionId,
            riskScore: riskScore,
            riskTier: riskTier,
            topFactorsJson: topFactorsJson,
            scoredAt: scoredAt,
            synced: synced,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String patientId,
            Value<String?> sessionId = const Value.absent(),
            required double riskScore,
            required String riskTier,
            Value<String?> topFactorsJson = const Value.absent(),
            required DateTime scoredAt,
            Value<bool> synced = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              RiskScoresCompanion.insert(
            id: id,
            patientId: patientId,
            sessionId: sessionId,
            riskScore: riskScore,
            riskTier: riskTier,
            topFactorsJson: topFactorsJson,
            scoredAt: scoredAt,
            synced: synced,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$RiskScoresTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $RiskScoresTable,
    LocalRiskScore,
    $$RiskScoresTableFilterComposer,
    $$RiskScoresTableOrderingComposer,
    $$RiskScoresTableAnnotationComposer,
    $$RiskScoresTableCreateCompanionBuilder,
    $$RiskScoresTableUpdateCompanionBuilder,
    (
      LocalRiskScore,
      BaseReferences<_$AppDatabase, $RiskScoresTable, LocalRiskScore>
    ),
    LocalRiskScore,
    PrefetchHooks Function()>;
typedef $$ReferralsTableCreateCompanionBuilder = ReferralsCompanion Function({
  required String id,
  required String patientId,
  required String triggerType,
  Value<String?> triggerDetailJson,
  Value<String?> vitalsSnapshotJson,
  Value<double?> aiRiskScore,
  Value<String?> facilityId,
  Value<String> status,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<bool> synced,
  Value<int> rowid,
});
typedef $$ReferralsTableUpdateCompanionBuilder = ReferralsCompanion Function({
  Value<String> id,
  Value<String> patientId,
  Value<String> triggerType,
  Value<String?> triggerDetailJson,
  Value<String?> vitalsSnapshotJson,
  Value<double?> aiRiskScore,
  Value<String?> facilityId,
  Value<String> status,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<bool> synced,
  Value<int> rowid,
});

class $$ReferralsTableFilterComposer
    extends Composer<_$AppDatabase, $ReferralsTable> {
  $$ReferralsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get patientId => $composableBuilder(
      column: $table.patientId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get triggerType => $composableBuilder(
      column: $table.triggerType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get triggerDetailJson => $composableBuilder(
      column: $table.triggerDetailJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get vitalsSnapshotJson => $composableBuilder(
      column: $table.vitalsSnapshotJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get aiRiskScore => $composableBuilder(
      column: $table.aiRiskScore, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get facilityId => $composableBuilder(
      column: $table.facilityId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get synced => $composableBuilder(
      column: $table.synced, builder: (column) => ColumnFilters(column));
}

class $$ReferralsTableOrderingComposer
    extends Composer<_$AppDatabase, $ReferralsTable> {
  $$ReferralsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get patientId => $composableBuilder(
      column: $table.patientId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get triggerType => $composableBuilder(
      column: $table.triggerType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get triggerDetailJson => $composableBuilder(
      column: $table.triggerDetailJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get vitalsSnapshotJson => $composableBuilder(
      column: $table.vitalsSnapshotJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get aiRiskScore => $composableBuilder(
      column: $table.aiRiskScore, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get facilityId => $composableBuilder(
      column: $table.facilityId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get synced => $composableBuilder(
      column: $table.synced, builder: (column) => ColumnOrderings(column));
}

class $$ReferralsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReferralsTable> {
  $$ReferralsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get patientId =>
      $composableBuilder(column: $table.patientId, builder: (column) => column);

  GeneratedColumn<String> get triggerType => $composableBuilder(
      column: $table.triggerType, builder: (column) => column);

  GeneratedColumn<String> get triggerDetailJson => $composableBuilder(
      column: $table.triggerDetailJson, builder: (column) => column);

  GeneratedColumn<String> get vitalsSnapshotJson => $composableBuilder(
      column: $table.vitalsSnapshotJson, builder: (column) => column);

  GeneratedColumn<double> get aiRiskScore => $composableBuilder(
      column: $table.aiRiskScore, builder: (column) => column);

  GeneratedColumn<String> get facilityId => $composableBuilder(
      column: $table.facilityId, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);
}

class $$ReferralsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ReferralsTable,
    LocalReferral,
    $$ReferralsTableFilterComposer,
    $$ReferralsTableOrderingComposer,
    $$ReferralsTableAnnotationComposer,
    $$ReferralsTableCreateCompanionBuilder,
    $$ReferralsTableUpdateCompanionBuilder,
    (
      LocalReferral,
      BaseReferences<_$AppDatabase, $ReferralsTable, LocalReferral>
    ),
    LocalReferral,
    PrefetchHooks Function()> {
  $$ReferralsTableTableManager(_$AppDatabase db, $ReferralsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReferralsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReferralsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReferralsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> patientId = const Value.absent(),
            Value<String> triggerType = const Value.absent(),
            Value<String?> triggerDetailJson = const Value.absent(),
            Value<String?> vitalsSnapshotJson = const Value.absent(),
            Value<double?> aiRiskScore = const Value.absent(),
            Value<String?> facilityId = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> synced = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ReferralsCompanion(
            id: id,
            patientId: patientId,
            triggerType: triggerType,
            triggerDetailJson: triggerDetailJson,
            vitalsSnapshotJson: vitalsSnapshotJson,
            aiRiskScore: aiRiskScore,
            facilityId: facilityId,
            status: status,
            createdAt: createdAt,
            updatedAt: updatedAt,
            synced: synced,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String patientId,
            required String triggerType,
            Value<String?> triggerDetailJson = const Value.absent(),
            Value<String?> vitalsSnapshotJson = const Value.absent(),
            Value<double?> aiRiskScore = const Value.absent(),
            Value<String?> facilityId = const Value.absent(),
            Value<String> status = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<bool> synced = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ReferralsCompanion.insert(
            id: id,
            patientId: patientId,
            triggerType: triggerType,
            triggerDetailJson: triggerDetailJson,
            vitalsSnapshotJson: vitalsSnapshotJson,
            aiRiskScore: aiRiskScore,
            facilityId: facilityId,
            status: status,
            createdAt: createdAt,
            updatedAt: updatedAt,
            synced: synced,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ReferralsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ReferralsTable,
    LocalReferral,
    $$ReferralsTableFilterComposer,
    $$ReferralsTableOrderingComposer,
    $$ReferralsTableAnnotationComposer,
    $$ReferralsTableCreateCompanionBuilder,
    $$ReferralsTableUpdateCompanionBuilder,
    (
      LocalReferral,
      BaseReferences<_$AppDatabase, $ReferralsTable, LocalReferral>
    ),
    LocalReferral,
    PrefetchHooks Function()>;
typedef $$FacilitiesTableCreateCompanionBuilder = FacilitiesCompanion Function({
  required String id,
  required String name,
  required String facilityType,
  Value<String?> address,
  Value<String?> phone,
  Value<double?> latitude,
  Value<double?> longitude,
  Value<int> rowid,
});
typedef $$FacilitiesTableUpdateCompanionBuilder = FacilitiesCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String> facilityType,
  Value<String?> address,
  Value<String?> phone,
  Value<double?> latitude,
  Value<double?> longitude,
  Value<int> rowid,
});

class $$FacilitiesTableFilterComposer
    extends Composer<_$AppDatabase, $FacilitiesTable> {
  $$FacilitiesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get facilityType => $composableBuilder(
      column: $table.facilityType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get address => $composableBuilder(
      column: $table.address, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get latitude => $composableBuilder(
      column: $table.latitude, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get longitude => $composableBuilder(
      column: $table.longitude, builder: (column) => ColumnFilters(column));
}

class $$FacilitiesTableOrderingComposer
    extends Composer<_$AppDatabase, $FacilitiesTable> {
  $$FacilitiesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get facilityType => $composableBuilder(
      column: $table.facilityType,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get address => $composableBuilder(
      column: $table.address, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get latitude => $composableBuilder(
      column: $table.latitude, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get longitude => $composableBuilder(
      column: $table.longitude, builder: (column) => ColumnOrderings(column));
}

class $$FacilitiesTableAnnotationComposer
    extends Composer<_$AppDatabase, $FacilitiesTable> {
  $$FacilitiesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get facilityType => $composableBuilder(
      column: $table.facilityType, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);
}

class $$FacilitiesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $FacilitiesTable,
    LocalFacility,
    $$FacilitiesTableFilterComposer,
    $$FacilitiesTableOrderingComposer,
    $$FacilitiesTableAnnotationComposer,
    $$FacilitiesTableCreateCompanionBuilder,
    $$FacilitiesTableUpdateCompanionBuilder,
    (
      LocalFacility,
      BaseReferences<_$AppDatabase, $FacilitiesTable, LocalFacility>
    ),
    LocalFacility,
    PrefetchHooks Function()> {
  $$FacilitiesTableTableManager(_$AppDatabase db, $FacilitiesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FacilitiesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FacilitiesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FacilitiesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> facilityType = const Value.absent(),
            Value<String?> address = const Value.absent(),
            Value<String?> phone = const Value.absent(),
            Value<double?> latitude = const Value.absent(),
            Value<double?> longitude = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              FacilitiesCompanion(
            id: id,
            name: name,
            facilityType: facilityType,
            address: address,
            phone: phone,
            latitude: latitude,
            longitude: longitude,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            required String facilityType,
            Value<String?> address = const Value.absent(),
            Value<String?> phone = const Value.absent(),
            Value<double?> latitude = const Value.absent(),
            Value<double?> longitude = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              FacilitiesCompanion.insert(
            id: id,
            name: name,
            facilityType: facilityType,
            address: address,
            phone: phone,
            latitude: latitude,
            longitude: longitude,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$FacilitiesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $FacilitiesTable,
    LocalFacility,
    $$FacilitiesTableFilterComposer,
    $$FacilitiesTableOrderingComposer,
    $$FacilitiesTableAnnotationComposer,
    $$FacilitiesTableCreateCompanionBuilder,
    $$FacilitiesTableUpdateCompanionBuilder,
    (
      LocalFacility,
      BaseReferences<_$AppDatabase, $FacilitiesTable, LocalFacility>
    ),
    LocalFacility,
    PrefetchHooks Function()>;
typedef $$SyncOutboxTableCreateCompanionBuilder = SyncOutboxCompanion Function({
  Value<int> id,
  required String syncTableName,
  required String recordId,
  required String operation,
  required String payloadJson,
  required DateTime createdAt,
  Value<int> retryCount,
  Value<String?> lastError,
});
typedef $$SyncOutboxTableUpdateCompanionBuilder = SyncOutboxCompanion Function({
  Value<int> id,
  Value<String> syncTableName,
  Value<String> recordId,
  Value<String> operation,
  Value<String> payloadJson,
  Value<DateTime> createdAt,
  Value<int> retryCount,
  Value<String?> lastError,
});

class $$SyncOutboxTableFilterComposer
    extends Composer<_$AppDatabase, $SyncOutboxTable> {
  $$SyncOutboxTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncTableName => $composableBuilder(
      column: $table.syncTableName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get recordId => $composableBuilder(
      column: $table.recordId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get operation => $composableBuilder(
      column: $table.operation, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lastError => $composableBuilder(
      column: $table.lastError, builder: (column) => ColumnFilters(column));
}

class $$SyncOutboxTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncOutboxTable> {
  $$SyncOutboxTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncTableName => $composableBuilder(
      column: $table.syncTableName,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get recordId => $composableBuilder(
      column: $table.recordId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get operation => $composableBuilder(
      column: $table.operation, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lastError => $composableBuilder(
      column: $table.lastError, builder: (column) => ColumnOrderings(column));
}

class $$SyncOutboxTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncOutboxTable> {
  $$SyncOutboxTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get syncTableName => $composableBuilder(
      column: $table.syncTableName, builder: (column) => column);

  GeneratedColumn<String> get recordId =>
      $composableBuilder(column: $table.recordId, builder: (column) => column);

  GeneratedColumn<String> get operation =>
      $composableBuilder(column: $table.operation, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => column);

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);
}

class $$SyncOutboxTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SyncOutboxTable,
    LocalSyncOutbox,
    $$SyncOutboxTableFilterComposer,
    $$SyncOutboxTableOrderingComposer,
    $$SyncOutboxTableAnnotationComposer,
    $$SyncOutboxTableCreateCompanionBuilder,
    $$SyncOutboxTableUpdateCompanionBuilder,
    (
      LocalSyncOutbox,
      BaseReferences<_$AppDatabase, $SyncOutboxTable, LocalSyncOutbox>
    ),
    LocalSyncOutbox,
    PrefetchHooks Function()> {
  $$SyncOutboxTableTableManager(_$AppDatabase db, $SyncOutboxTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncOutboxTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncOutboxTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncOutboxTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> syncTableName = const Value.absent(),
            Value<String> recordId = const Value.absent(),
            Value<String> operation = const Value.absent(),
            Value<String> payloadJson = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> retryCount = const Value.absent(),
            Value<String?> lastError = const Value.absent(),
          }) =>
              SyncOutboxCompanion(
            id: id,
            syncTableName: syncTableName,
            recordId: recordId,
            operation: operation,
            payloadJson: payloadJson,
            createdAt: createdAt,
            retryCount: retryCount,
            lastError: lastError,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String syncTableName,
            required String recordId,
            required String operation,
            required String payloadJson,
            required DateTime createdAt,
            Value<int> retryCount = const Value.absent(),
            Value<String?> lastError = const Value.absent(),
          }) =>
              SyncOutboxCompanion.insert(
            id: id,
            syncTableName: syncTableName,
            recordId: recordId,
            operation: operation,
            payloadJson: payloadJson,
            createdAt: createdAt,
            retryCount: retryCount,
            lastError: lastError,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SyncOutboxTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SyncOutboxTable,
    LocalSyncOutbox,
    $$SyncOutboxTableFilterComposer,
    $$SyncOutboxTableOrderingComposer,
    $$SyncOutboxTableAnnotationComposer,
    $$SyncOutboxTableCreateCompanionBuilder,
    $$SyncOutboxTableUpdateCompanionBuilder,
    (
      LocalSyncOutbox,
      BaseReferences<_$AppDatabase, $SyncOutboxTable, LocalSyncOutbox>
    ),
    LocalSyncOutbox,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$PatientsTableTableManager get patients =>
      $$PatientsTableTableManager(_db, _db.patients);
  $$DevicesTableTableManager get devices =>
      $$DevicesTableTableManager(_db, _db.devices);
  $$MonitoringSessionsTableTableManager get monitoringSessions =>
      $$MonitoringSessionsTableTableManager(_db, _db.monitoringSessions);
  $$ReadingsTableTableManager get readings =>
      $$ReadingsTableTableManager(_db, _db.readings);
  $$RiskScoresTableTableManager get riskScores =>
      $$RiskScoresTableTableManager(_db, _db.riskScores);
  $$ReferralsTableTableManager get referrals =>
      $$ReferralsTableTableManager(_db, _db.referrals);
  $$FacilitiesTableTableManager get facilities =>
      $$FacilitiesTableTableManager(_db, _db.facilities);
  $$SyncOutboxTableTableManager get syncOutbox =>
      $$SyncOutboxTableTableManager(_db, _db.syncOutbox);
}
