// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $LicenseSecurityStoreTable extends LicenseSecurityStore
    with TableInfo<$LicenseSecurityStoreTable, LicenseSecurityStoreData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LicenseSecurityStoreTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deviceModeMeta = const VerificationMeta(
    'deviceMode',
  );
  @override
  late final GeneratedColumn<String> deviceMode = GeneratedColumn<String>(
    'device_mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pairedDeviceIdMeta = const VerificationMeta(
    'pairedDeviceId',
  );
  @override
  late final GeneratedColumn<String> pairedDeviceId = GeneratedColumn<String>(
    'paired_device_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _licenseKeyMeta = const VerificationMeta(
    'licenseKey',
  );
  @override
  late final GeneratedColumn<String> licenseKey = GeneratedColumn<String>(
    'license_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _clubNameMeta = const VerificationMeta(
    'clubName',
  );
  @override
  late final GeneratedColumn<String> clubName = GeneratedColumn<String>(
    'club_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _teamNameMeta = const VerificationMeta(
    'teamName',
  );
  @override
  late final GeneratedColumn<String> teamName = GeneratedColumn<String>(
    'team_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _packageTypeMeta = const VerificationMeta(
    'packageType',
  );
  @override
  late final GeneratedColumn<String> packageType = GeneratedColumn<String>(
    'package_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _activatedAtMeta = const VerificationMeta(
    'activatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> activatedAt = GeneratedColumn<DateTime>(
    'activated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _expiresAtMeta = const VerificationMeta(
    'expiresAt',
  );
  @override
  late final GeneratedColumn<DateTime> expiresAt = GeneratedColumn<DateTime>(
    'expires_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _highWatermarkTimestampMeta =
      const VerificationMeta('highWatermarkTimestamp');
  @override
  late final GeneratedColumn<DateTime> highWatermarkTimestamp =
      GeneratedColumn<DateTime>(
        'high_watermark_timestamp',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _cumulativeRuntimeMinutesMeta =
      const VerificationMeta('cumulativeRuntimeMinutes');
  @override
  late final GeneratedColumn<int> cumulativeRuntimeMinutes =
      GeneratedColumn<int>(
        'cumulative_runtime_minutes',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(0),
      );
  static const VerificationMeta _tamperFlagMeta = const VerificationMeta(
    'tamperFlag',
  );
  @override
  late final GeneratedColumn<bool> tamperFlag = GeneratedColumn<bool>(
    'tamper_flag',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("tamper_flag" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _signatureProofMeta = const VerificationMeta(
    'signatureProof',
  );
  @override
  late final GeneratedColumn<String> signatureProof = GeneratedColumn<String>(
    'signature_proof',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    deviceId,
    deviceMode,
    pairedDeviceId,
    licenseKey,
    clubName,
    teamName,
    packageType,
    activatedAt,
    expiresAt,
    highWatermarkTimestamp,
    cumulativeRuntimeMinutes,
    tamperFlag,
    signatureProof,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'license_security_store';
  @override
  VerificationContext validateIntegrity(
    Insertable<LicenseSecurityStoreData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('device_mode')) {
      context.handle(
        _deviceModeMeta,
        deviceMode.isAcceptableOrUnknown(data['device_mode']!, _deviceModeMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceModeMeta);
    }
    if (data.containsKey('paired_device_id')) {
      context.handle(
        _pairedDeviceIdMeta,
        pairedDeviceId.isAcceptableOrUnknown(
          data['paired_device_id']!,
          _pairedDeviceIdMeta,
        ),
      );
    }
    if (data.containsKey('license_key')) {
      context.handle(
        _licenseKeyMeta,
        licenseKey.isAcceptableOrUnknown(data['license_key']!, _licenseKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_licenseKeyMeta);
    }
    if (data.containsKey('club_name')) {
      context.handle(
        _clubNameMeta,
        clubName.isAcceptableOrUnknown(data['club_name']!, _clubNameMeta),
      );
    } else if (isInserting) {
      context.missing(_clubNameMeta);
    }
    if (data.containsKey('team_name')) {
      context.handle(
        _teamNameMeta,
        teamName.isAcceptableOrUnknown(data['team_name']!, _teamNameMeta),
      );
    }
    if (data.containsKey('package_type')) {
      context.handle(
        _packageTypeMeta,
        packageType.isAcceptableOrUnknown(
          data['package_type']!,
          _packageTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_packageTypeMeta);
    }
    if (data.containsKey('activated_at')) {
      context.handle(
        _activatedAtMeta,
        activatedAt.isAcceptableOrUnknown(
          data['activated_at']!,
          _activatedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_activatedAtMeta);
    }
    if (data.containsKey('expires_at')) {
      context.handle(
        _expiresAtMeta,
        expiresAt.isAcceptableOrUnknown(data['expires_at']!, _expiresAtMeta),
      );
    } else if (isInserting) {
      context.missing(_expiresAtMeta);
    }
    if (data.containsKey('high_watermark_timestamp')) {
      context.handle(
        _highWatermarkTimestampMeta,
        highWatermarkTimestamp.isAcceptableOrUnknown(
          data['high_watermark_timestamp']!,
          _highWatermarkTimestampMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_highWatermarkTimestampMeta);
    }
    if (data.containsKey('cumulative_runtime_minutes')) {
      context.handle(
        _cumulativeRuntimeMinutesMeta,
        cumulativeRuntimeMinutes.isAcceptableOrUnknown(
          data['cumulative_runtime_minutes']!,
          _cumulativeRuntimeMinutesMeta,
        ),
      );
    }
    if (data.containsKey('tamper_flag')) {
      context.handle(
        _tamperFlagMeta,
        tamperFlag.isAcceptableOrUnknown(data['tamper_flag']!, _tamperFlagMeta),
      );
    }
    if (data.containsKey('signature_proof')) {
      context.handle(
        _signatureProofMeta,
        signatureProof.isAcceptableOrUnknown(
          data['signature_proof']!,
          _signatureProofMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_signatureProofMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {deviceId};
  @override
  LicenseSecurityStoreData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LicenseSecurityStoreData(
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      deviceMode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_mode'],
      )!,
      pairedDeviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}paired_device_id'],
      ),
      licenseKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}license_key'],
      )!,
      clubName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}club_name'],
      )!,
      teamName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}team_name'],
      ),
      packageType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}package_type'],
      )!,
      activatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}activated_at'],
      )!,
      expiresAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}expires_at'],
      )!,
      highWatermarkTimestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}high_watermark_timestamp'],
      )!,
      cumulativeRuntimeMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cumulative_runtime_minutes'],
      )!,
      tamperFlag: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}tamper_flag'],
      )!,
      signatureProof: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}signature_proof'],
      )!,
    );
  }

  @override
  $LicenseSecurityStoreTable createAlias(String alias) {
    return $LicenseSecurityStoreTable(attachedDatabase, alias);
  }
}

class LicenseSecurityStoreData extends DataClass
    implements Insertable<LicenseSecurityStoreData> {
  final String deviceId;
  final String deviceMode;
  final String? pairedDeviceId;
  final String licenseKey;
  final String clubName;
  final String? teamName;
  final String packageType;
  final DateTime activatedAt;
  final DateTime expiresAt;
  final DateTime highWatermarkTimestamp;
  final int cumulativeRuntimeMinutes;
  final bool tamperFlag;
  final String signatureProof;
  const LicenseSecurityStoreData({
    required this.deviceId,
    required this.deviceMode,
    this.pairedDeviceId,
    required this.licenseKey,
    required this.clubName,
    this.teamName,
    required this.packageType,
    required this.activatedAt,
    required this.expiresAt,
    required this.highWatermarkTimestamp,
    required this.cumulativeRuntimeMinutes,
    required this.tamperFlag,
    required this.signatureProof,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['device_id'] = Variable<String>(deviceId);
    map['device_mode'] = Variable<String>(deviceMode);
    if (!nullToAbsent || pairedDeviceId != null) {
      map['paired_device_id'] = Variable<String>(pairedDeviceId);
    }
    map['license_key'] = Variable<String>(licenseKey);
    map['club_name'] = Variable<String>(clubName);
    if (!nullToAbsent || teamName != null) {
      map['team_name'] = Variable<String>(teamName);
    }
    map['package_type'] = Variable<String>(packageType);
    map['activated_at'] = Variable<DateTime>(activatedAt);
    map['expires_at'] = Variable<DateTime>(expiresAt);
    map['high_watermark_timestamp'] = Variable<DateTime>(
      highWatermarkTimestamp,
    );
    map['cumulative_runtime_minutes'] = Variable<int>(cumulativeRuntimeMinutes);
    map['tamper_flag'] = Variable<bool>(tamperFlag);
    map['signature_proof'] = Variable<String>(signatureProof);
    return map;
  }

  LicenseSecurityStoreCompanion toCompanion(bool nullToAbsent) {
    return LicenseSecurityStoreCompanion(
      deviceId: Value(deviceId),
      deviceMode: Value(deviceMode),
      pairedDeviceId: pairedDeviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(pairedDeviceId),
      licenseKey: Value(licenseKey),
      clubName: Value(clubName),
      teamName: teamName == null && nullToAbsent
          ? const Value.absent()
          : Value(teamName),
      packageType: Value(packageType),
      activatedAt: Value(activatedAt),
      expiresAt: Value(expiresAt),
      highWatermarkTimestamp: Value(highWatermarkTimestamp),
      cumulativeRuntimeMinutes: Value(cumulativeRuntimeMinutes),
      tamperFlag: Value(tamperFlag),
      signatureProof: Value(signatureProof),
    );
  }

  factory LicenseSecurityStoreData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LicenseSecurityStoreData(
      deviceId: serializer.fromJson<String>(json['deviceId']),
      deviceMode: serializer.fromJson<String>(json['deviceMode']),
      pairedDeviceId: serializer.fromJson<String?>(json['pairedDeviceId']),
      licenseKey: serializer.fromJson<String>(json['licenseKey']),
      clubName: serializer.fromJson<String>(json['clubName']),
      teamName: serializer.fromJson<String?>(json['teamName']),
      packageType: serializer.fromJson<String>(json['packageType']),
      activatedAt: serializer.fromJson<DateTime>(json['activatedAt']),
      expiresAt: serializer.fromJson<DateTime>(json['expiresAt']),
      highWatermarkTimestamp: serializer.fromJson<DateTime>(
        json['highWatermarkTimestamp'],
      ),
      cumulativeRuntimeMinutes: serializer.fromJson<int>(
        json['cumulativeRuntimeMinutes'],
      ),
      tamperFlag: serializer.fromJson<bool>(json['tamperFlag']),
      signatureProof: serializer.fromJson<String>(json['signatureProof']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'deviceId': serializer.toJson<String>(deviceId),
      'deviceMode': serializer.toJson<String>(deviceMode),
      'pairedDeviceId': serializer.toJson<String?>(pairedDeviceId),
      'licenseKey': serializer.toJson<String>(licenseKey),
      'clubName': serializer.toJson<String>(clubName),
      'teamName': serializer.toJson<String?>(teamName),
      'packageType': serializer.toJson<String>(packageType),
      'activatedAt': serializer.toJson<DateTime>(activatedAt),
      'expiresAt': serializer.toJson<DateTime>(expiresAt),
      'highWatermarkTimestamp': serializer.toJson<DateTime>(
        highWatermarkTimestamp,
      ),
      'cumulativeRuntimeMinutes': serializer.toJson<int>(
        cumulativeRuntimeMinutes,
      ),
      'tamperFlag': serializer.toJson<bool>(tamperFlag),
      'signatureProof': serializer.toJson<String>(signatureProof),
    };
  }

  LicenseSecurityStoreData copyWith({
    String? deviceId,
    String? deviceMode,
    Value<String?> pairedDeviceId = const Value.absent(),
    String? licenseKey,
    String? clubName,
    Value<String?> teamName = const Value.absent(),
    String? packageType,
    DateTime? activatedAt,
    DateTime? expiresAt,
    DateTime? highWatermarkTimestamp,
    int? cumulativeRuntimeMinutes,
    bool? tamperFlag,
    String? signatureProof,
  }) => LicenseSecurityStoreData(
    deviceId: deviceId ?? this.deviceId,
    deviceMode: deviceMode ?? this.deviceMode,
    pairedDeviceId: pairedDeviceId.present
        ? pairedDeviceId.value
        : this.pairedDeviceId,
    licenseKey: licenseKey ?? this.licenseKey,
    clubName: clubName ?? this.clubName,
    teamName: teamName.present ? teamName.value : this.teamName,
    packageType: packageType ?? this.packageType,
    activatedAt: activatedAt ?? this.activatedAt,
    expiresAt: expiresAt ?? this.expiresAt,
    highWatermarkTimestamp:
        highWatermarkTimestamp ?? this.highWatermarkTimestamp,
    cumulativeRuntimeMinutes:
        cumulativeRuntimeMinutes ?? this.cumulativeRuntimeMinutes,
    tamperFlag: tamperFlag ?? this.tamperFlag,
    signatureProof: signatureProof ?? this.signatureProof,
  );
  LicenseSecurityStoreData copyWithCompanion(
    LicenseSecurityStoreCompanion data,
  ) {
    return LicenseSecurityStoreData(
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      deviceMode: data.deviceMode.present
          ? data.deviceMode.value
          : this.deviceMode,
      pairedDeviceId: data.pairedDeviceId.present
          ? data.pairedDeviceId.value
          : this.pairedDeviceId,
      licenseKey: data.licenseKey.present
          ? data.licenseKey.value
          : this.licenseKey,
      clubName: data.clubName.present ? data.clubName.value : this.clubName,
      teamName: data.teamName.present ? data.teamName.value : this.teamName,
      packageType: data.packageType.present
          ? data.packageType.value
          : this.packageType,
      activatedAt: data.activatedAt.present
          ? data.activatedAt.value
          : this.activatedAt,
      expiresAt: data.expiresAt.present ? data.expiresAt.value : this.expiresAt,
      highWatermarkTimestamp: data.highWatermarkTimestamp.present
          ? data.highWatermarkTimestamp.value
          : this.highWatermarkTimestamp,
      cumulativeRuntimeMinutes: data.cumulativeRuntimeMinutes.present
          ? data.cumulativeRuntimeMinutes.value
          : this.cumulativeRuntimeMinutes,
      tamperFlag: data.tamperFlag.present
          ? data.tamperFlag.value
          : this.tamperFlag,
      signatureProof: data.signatureProof.present
          ? data.signatureProof.value
          : this.signatureProof,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LicenseSecurityStoreData(')
          ..write('deviceId: $deviceId, ')
          ..write('deviceMode: $deviceMode, ')
          ..write('pairedDeviceId: $pairedDeviceId, ')
          ..write('licenseKey: $licenseKey, ')
          ..write('clubName: $clubName, ')
          ..write('teamName: $teamName, ')
          ..write('packageType: $packageType, ')
          ..write('activatedAt: $activatedAt, ')
          ..write('expiresAt: $expiresAt, ')
          ..write('highWatermarkTimestamp: $highWatermarkTimestamp, ')
          ..write('cumulativeRuntimeMinutes: $cumulativeRuntimeMinutes, ')
          ..write('tamperFlag: $tamperFlag, ')
          ..write('signatureProof: $signatureProof')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    deviceId,
    deviceMode,
    pairedDeviceId,
    licenseKey,
    clubName,
    teamName,
    packageType,
    activatedAt,
    expiresAt,
    highWatermarkTimestamp,
    cumulativeRuntimeMinutes,
    tamperFlag,
    signatureProof,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LicenseSecurityStoreData &&
          other.deviceId == this.deviceId &&
          other.deviceMode == this.deviceMode &&
          other.pairedDeviceId == this.pairedDeviceId &&
          other.licenseKey == this.licenseKey &&
          other.clubName == this.clubName &&
          other.teamName == this.teamName &&
          other.packageType == this.packageType &&
          other.activatedAt == this.activatedAt &&
          other.expiresAt == this.expiresAt &&
          other.highWatermarkTimestamp == this.highWatermarkTimestamp &&
          other.cumulativeRuntimeMinutes == this.cumulativeRuntimeMinutes &&
          other.tamperFlag == this.tamperFlag &&
          other.signatureProof == this.signatureProof);
}

class LicenseSecurityStoreCompanion
    extends UpdateCompanion<LicenseSecurityStoreData> {
  final Value<String> deviceId;
  final Value<String> deviceMode;
  final Value<String?> pairedDeviceId;
  final Value<String> licenseKey;
  final Value<String> clubName;
  final Value<String?> teamName;
  final Value<String> packageType;
  final Value<DateTime> activatedAt;
  final Value<DateTime> expiresAt;
  final Value<DateTime> highWatermarkTimestamp;
  final Value<int> cumulativeRuntimeMinutes;
  final Value<bool> tamperFlag;
  final Value<String> signatureProof;
  final Value<int> rowid;
  const LicenseSecurityStoreCompanion({
    this.deviceId = const Value.absent(),
    this.deviceMode = const Value.absent(),
    this.pairedDeviceId = const Value.absent(),
    this.licenseKey = const Value.absent(),
    this.clubName = const Value.absent(),
    this.teamName = const Value.absent(),
    this.packageType = const Value.absent(),
    this.activatedAt = const Value.absent(),
    this.expiresAt = const Value.absent(),
    this.highWatermarkTimestamp = const Value.absent(),
    this.cumulativeRuntimeMinutes = const Value.absent(),
    this.tamperFlag = const Value.absent(),
    this.signatureProof = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LicenseSecurityStoreCompanion.insert({
    required String deviceId,
    required String deviceMode,
    this.pairedDeviceId = const Value.absent(),
    required String licenseKey,
    required String clubName,
    this.teamName = const Value.absent(),
    required String packageType,
    required DateTime activatedAt,
    required DateTime expiresAt,
    required DateTime highWatermarkTimestamp,
    this.cumulativeRuntimeMinutes = const Value.absent(),
    this.tamperFlag = const Value.absent(),
    required String signatureProof,
    this.rowid = const Value.absent(),
  }) : deviceId = Value(deviceId),
       deviceMode = Value(deviceMode),
       licenseKey = Value(licenseKey),
       clubName = Value(clubName),
       packageType = Value(packageType),
       activatedAt = Value(activatedAt),
       expiresAt = Value(expiresAt),
       highWatermarkTimestamp = Value(highWatermarkTimestamp),
       signatureProof = Value(signatureProof);
  static Insertable<LicenseSecurityStoreData> custom({
    Expression<String>? deviceId,
    Expression<String>? deviceMode,
    Expression<String>? pairedDeviceId,
    Expression<String>? licenseKey,
    Expression<String>? clubName,
    Expression<String>? teamName,
    Expression<String>? packageType,
    Expression<DateTime>? activatedAt,
    Expression<DateTime>? expiresAt,
    Expression<DateTime>? highWatermarkTimestamp,
    Expression<int>? cumulativeRuntimeMinutes,
    Expression<bool>? tamperFlag,
    Expression<String>? signatureProof,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (deviceId != null) 'device_id': deviceId,
      if (deviceMode != null) 'device_mode': deviceMode,
      if (pairedDeviceId != null) 'paired_device_id': pairedDeviceId,
      if (licenseKey != null) 'license_key': licenseKey,
      if (clubName != null) 'club_name': clubName,
      if (teamName != null) 'team_name': teamName,
      if (packageType != null) 'package_type': packageType,
      if (activatedAt != null) 'activated_at': activatedAt,
      if (expiresAt != null) 'expires_at': expiresAt,
      if (highWatermarkTimestamp != null)
        'high_watermark_timestamp': highWatermarkTimestamp,
      if (cumulativeRuntimeMinutes != null)
        'cumulative_runtime_minutes': cumulativeRuntimeMinutes,
      if (tamperFlag != null) 'tamper_flag': tamperFlag,
      if (signatureProof != null) 'signature_proof': signatureProof,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LicenseSecurityStoreCompanion copyWith({
    Value<String>? deviceId,
    Value<String>? deviceMode,
    Value<String?>? pairedDeviceId,
    Value<String>? licenseKey,
    Value<String>? clubName,
    Value<String?>? teamName,
    Value<String>? packageType,
    Value<DateTime>? activatedAt,
    Value<DateTime>? expiresAt,
    Value<DateTime>? highWatermarkTimestamp,
    Value<int>? cumulativeRuntimeMinutes,
    Value<bool>? tamperFlag,
    Value<String>? signatureProof,
    Value<int>? rowid,
  }) {
    return LicenseSecurityStoreCompanion(
      deviceId: deviceId ?? this.deviceId,
      deviceMode: deviceMode ?? this.deviceMode,
      pairedDeviceId: pairedDeviceId ?? this.pairedDeviceId,
      licenseKey: licenseKey ?? this.licenseKey,
      clubName: clubName ?? this.clubName,
      teamName: teamName ?? this.teamName,
      packageType: packageType ?? this.packageType,
      activatedAt: activatedAt ?? this.activatedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      highWatermarkTimestamp:
          highWatermarkTimestamp ?? this.highWatermarkTimestamp,
      cumulativeRuntimeMinutes:
          cumulativeRuntimeMinutes ?? this.cumulativeRuntimeMinutes,
      tamperFlag: tamperFlag ?? this.tamperFlag,
      signatureProof: signatureProof ?? this.signatureProof,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (deviceMode.present) {
      map['device_mode'] = Variable<String>(deviceMode.value);
    }
    if (pairedDeviceId.present) {
      map['paired_device_id'] = Variable<String>(pairedDeviceId.value);
    }
    if (licenseKey.present) {
      map['license_key'] = Variable<String>(licenseKey.value);
    }
    if (clubName.present) {
      map['club_name'] = Variable<String>(clubName.value);
    }
    if (teamName.present) {
      map['team_name'] = Variable<String>(teamName.value);
    }
    if (packageType.present) {
      map['package_type'] = Variable<String>(packageType.value);
    }
    if (activatedAt.present) {
      map['activated_at'] = Variable<DateTime>(activatedAt.value);
    }
    if (expiresAt.present) {
      map['expires_at'] = Variable<DateTime>(expiresAt.value);
    }
    if (highWatermarkTimestamp.present) {
      map['high_watermark_timestamp'] = Variable<DateTime>(
        highWatermarkTimestamp.value,
      );
    }
    if (cumulativeRuntimeMinutes.present) {
      map['cumulative_runtime_minutes'] = Variable<int>(
        cumulativeRuntimeMinutes.value,
      );
    }
    if (tamperFlag.present) {
      map['tamper_flag'] = Variable<bool>(tamperFlag.value);
    }
    if (signatureProof.present) {
      map['signature_proof'] = Variable<String>(signatureProof.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LicenseSecurityStoreCompanion(')
          ..write('deviceId: $deviceId, ')
          ..write('deviceMode: $deviceMode, ')
          ..write('pairedDeviceId: $pairedDeviceId, ')
          ..write('licenseKey: $licenseKey, ')
          ..write('clubName: $clubName, ')
          ..write('teamName: $teamName, ')
          ..write('packageType: $packageType, ')
          ..write('activatedAt: $activatedAt, ')
          ..write('expiresAt: $expiresAt, ')
          ..write('highWatermarkTimestamp: $highWatermarkTimestamp, ')
          ..write('cumulativeRuntimeMinutes: $cumulativeRuntimeMinutes, ')
          ..write('tamperFlag: $tamperFlag, ')
          ..write('signatureProof: $signatureProof, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ClubSettingsTable extends ClubSettings
    with TableInfo<$ClubSettingsTable, ClubSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ClubSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL CHECK (id = 1)',
  );
  static const VerificationMeta _clubNameMeta = const VerificationMeta(
    'clubName',
  );
  @override
  late final GeneratedColumn<String> clubName = GeneratedColumn<String>(
    'club_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _logoPathMeta = const VerificationMeta(
    'logoPath',
  );
  @override
  late final GeneratedColumn<String> logoPath = GeneratedColumn<String>(
    'logo_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _seasonMeta = const VerificationMeta('season');
  @override
  late final GeneratedColumn<String> season = GeneratedColumn<String>(
    'season',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _adminNameMeta = const VerificationMeta(
    'adminName',
  );
  @override
  late final GeneratedColumn<String> adminName = GeneratedColumn<String>(
    'admin_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _managerNameMeta = const VerificationMeta(
    'managerName',
  );
  @override
  late final GeneratedColumn<String> managerName = GeneratedColumn<String>(
    'manager_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pinCodeHashMeta = const VerificationMeta(
    'pinCodeHash',
  );
  @override
  late final GeneratedColumn<String> pinCodeHash = GeneratedColumn<String>(
    'pin_code_hash',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _entitlementSportEnabledMeta =
      const VerificationMeta('entitlementSportEnabled');
  @override
  late final GeneratedColumn<bool> entitlementSportEnabled =
      GeneratedColumn<bool>(
        'entitlement_sport_enabled',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("entitlement_sport_enabled" IN (0, 1))',
        ),
        defaultValue: const Constant(true),
      );
  static const VerificationMeta _entitlementCountsExcusedMeta =
      const VerificationMeta('entitlementCountsExcused');
  @override
  late final GeneratedColumn<bool> entitlementCountsExcused =
      GeneratedColumn<bool>(
        'entitlement_counts_excused',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("entitlement_counts_excused" IN (0, 1))',
        ),
        defaultValue: const Constant(true),
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    clubName,
    logoPath,
    season,
    adminName,
    managerName,
    pinCodeHash,
    entitlementSportEnabled,
    entitlementCountsExcused,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'club_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<ClubSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('club_name')) {
      context.handle(
        _clubNameMeta,
        clubName.isAcceptableOrUnknown(data['club_name']!, _clubNameMeta),
      );
    } else if (isInserting) {
      context.missing(_clubNameMeta);
    }
    if (data.containsKey('logo_path')) {
      context.handle(
        _logoPathMeta,
        logoPath.isAcceptableOrUnknown(data['logo_path']!, _logoPathMeta),
      );
    }
    if (data.containsKey('season')) {
      context.handle(
        _seasonMeta,
        season.isAcceptableOrUnknown(data['season']!, _seasonMeta),
      );
    } else if (isInserting) {
      context.missing(_seasonMeta);
    }
    if (data.containsKey('admin_name')) {
      context.handle(
        _adminNameMeta,
        adminName.isAcceptableOrUnknown(data['admin_name']!, _adminNameMeta),
      );
    }
    if (data.containsKey('manager_name')) {
      context.handle(
        _managerNameMeta,
        managerName.isAcceptableOrUnknown(
          data['manager_name']!,
          _managerNameMeta,
        ),
      );
    }
    if (data.containsKey('pin_code_hash')) {
      context.handle(
        _pinCodeHashMeta,
        pinCodeHash.isAcceptableOrUnknown(
          data['pin_code_hash']!,
          _pinCodeHashMeta,
        ),
      );
    }
    if (data.containsKey('entitlement_sport_enabled')) {
      context.handle(
        _entitlementSportEnabledMeta,
        entitlementSportEnabled.isAcceptableOrUnknown(
          data['entitlement_sport_enabled']!,
          _entitlementSportEnabledMeta,
        ),
      );
    }
    if (data.containsKey('entitlement_counts_excused')) {
      context.handle(
        _entitlementCountsExcusedMeta,
        entitlementCountsExcused.isAcceptableOrUnknown(
          data['entitlement_counts_excused']!,
          _entitlementCountsExcusedMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ClubSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ClubSetting(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      clubName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}club_name'],
      )!,
      logoPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}logo_path'],
      ),
      season: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}season'],
      )!,
      adminName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}admin_name'],
      ),
      managerName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}manager_name'],
      ),
      pinCodeHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pin_code_hash'],
      ),
      entitlementSportEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}entitlement_sport_enabled'],
      )!,
      entitlementCountsExcused: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}entitlement_counts_excused'],
      )!,
    );
  }

  @override
  $ClubSettingsTable createAlias(String alias) {
    return $ClubSettingsTable(attachedDatabase, alias);
  }
}

class ClubSetting extends DataClass implements Insertable<ClubSetting> {
  final int id;
  final String clubName;
  final String? logoPath;
  final String season;
  final String? adminName;
  final String? managerName;
  final String? pinCodeHash;
  final bool entitlementSportEnabled;
  final bool entitlementCountsExcused;
  const ClubSetting({
    required this.id,
    required this.clubName,
    this.logoPath,
    required this.season,
    this.adminName,
    this.managerName,
    this.pinCodeHash,
    required this.entitlementSportEnabled,
    required this.entitlementCountsExcused,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['club_name'] = Variable<String>(clubName);
    if (!nullToAbsent || logoPath != null) {
      map['logo_path'] = Variable<String>(logoPath);
    }
    map['season'] = Variable<String>(season);
    if (!nullToAbsent || adminName != null) {
      map['admin_name'] = Variable<String>(adminName);
    }
    if (!nullToAbsent || managerName != null) {
      map['manager_name'] = Variable<String>(managerName);
    }
    if (!nullToAbsent || pinCodeHash != null) {
      map['pin_code_hash'] = Variable<String>(pinCodeHash);
    }
    map['entitlement_sport_enabled'] = Variable<bool>(entitlementSportEnabled);
    map['entitlement_counts_excused'] = Variable<bool>(
      entitlementCountsExcused,
    );
    return map;
  }

  ClubSettingsCompanion toCompanion(bool nullToAbsent) {
    return ClubSettingsCompanion(
      id: Value(id),
      clubName: Value(clubName),
      logoPath: logoPath == null && nullToAbsent
          ? const Value.absent()
          : Value(logoPath),
      season: Value(season),
      adminName: adminName == null && nullToAbsent
          ? const Value.absent()
          : Value(adminName),
      managerName: managerName == null && nullToAbsent
          ? const Value.absent()
          : Value(managerName),
      pinCodeHash: pinCodeHash == null && nullToAbsent
          ? const Value.absent()
          : Value(pinCodeHash),
      entitlementSportEnabled: Value(entitlementSportEnabled),
      entitlementCountsExcused: Value(entitlementCountsExcused),
    );
  }

  factory ClubSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ClubSetting(
      id: serializer.fromJson<int>(json['id']),
      clubName: serializer.fromJson<String>(json['clubName']),
      logoPath: serializer.fromJson<String?>(json['logoPath']),
      season: serializer.fromJson<String>(json['season']),
      adminName: serializer.fromJson<String?>(json['adminName']),
      managerName: serializer.fromJson<String?>(json['managerName']),
      pinCodeHash: serializer.fromJson<String?>(json['pinCodeHash']),
      entitlementSportEnabled: serializer.fromJson<bool>(
        json['entitlementSportEnabled'],
      ),
      entitlementCountsExcused: serializer.fromJson<bool>(
        json['entitlementCountsExcused'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'clubName': serializer.toJson<String>(clubName),
      'logoPath': serializer.toJson<String?>(logoPath),
      'season': serializer.toJson<String>(season),
      'adminName': serializer.toJson<String?>(adminName),
      'managerName': serializer.toJson<String?>(managerName),
      'pinCodeHash': serializer.toJson<String?>(pinCodeHash),
      'entitlementSportEnabled': serializer.toJson<bool>(
        entitlementSportEnabled,
      ),
      'entitlementCountsExcused': serializer.toJson<bool>(
        entitlementCountsExcused,
      ),
    };
  }

  ClubSetting copyWith({
    int? id,
    String? clubName,
    Value<String?> logoPath = const Value.absent(),
    String? season,
    Value<String?> adminName = const Value.absent(),
    Value<String?> managerName = const Value.absent(),
    Value<String?> pinCodeHash = const Value.absent(),
    bool? entitlementSportEnabled,
    bool? entitlementCountsExcused,
  }) => ClubSetting(
    id: id ?? this.id,
    clubName: clubName ?? this.clubName,
    logoPath: logoPath.present ? logoPath.value : this.logoPath,
    season: season ?? this.season,
    adminName: adminName.present ? adminName.value : this.adminName,
    managerName: managerName.present ? managerName.value : this.managerName,
    pinCodeHash: pinCodeHash.present ? pinCodeHash.value : this.pinCodeHash,
    entitlementSportEnabled:
        entitlementSportEnabled ?? this.entitlementSportEnabled,
    entitlementCountsExcused:
        entitlementCountsExcused ?? this.entitlementCountsExcused,
  );
  ClubSetting copyWithCompanion(ClubSettingsCompanion data) {
    return ClubSetting(
      id: data.id.present ? data.id.value : this.id,
      clubName: data.clubName.present ? data.clubName.value : this.clubName,
      logoPath: data.logoPath.present ? data.logoPath.value : this.logoPath,
      season: data.season.present ? data.season.value : this.season,
      adminName: data.adminName.present ? data.adminName.value : this.adminName,
      managerName: data.managerName.present
          ? data.managerName.value
          : this.managerName,
      pinCodeHash: data.pinCodeHash.present
          ? data.pinCodeHash.value
          : this.pinCodeHash,
      entitlementSportEnabled: data.entitlementSportEnabled.present
          ? data.entitlementSportEnabled.value
          : this.entitlementSportEnabled,
      entitlementCountsExcused: data.entitlementCountsExcused.present
          ? data.entitlementCountsExcused.value
          : this.entitlementCountsExcused,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ClubSetting(')
          ..write('id: $id, ')
          ..write('clubName: $clubName, ')
          ..write('logoPath: $logoPath, ')
          ..write('season: $season, ')
          ..write('adminName: $adminName, ')
          ..write('managerName: $managerName, ')
          ..write('pinCodeHash: $pinCodeHash, ')
          ..write('entitlementSportEnabled: $entitlementSportEnabled, ')
          ..write('entitlementCountsExcused: $entitlementCountsExcused')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    clubName,
    logoPath,
    season,
    adminName,
    managerName,
    pinCodeHash,
    entitlementSportEnabled,
    entitlementCountsExcused,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ClubSetting &&
          other.id == this.id &&
          other.clubName == this.clubName &&
          other.logoPath == this.logoPath &&
          other.season == this.season &&
          other.adminName == this.adminName &&
          other.managerName == this.managerName &&
          other.pinCodeHash == this.pinCodeHash &&
          other.entitlementSportEnabled == this.entitlementSportEnabled &&
          other.entitlementCountsExcused == this.entitlementCountsExcused);
}

class ClubSettingsCompanion extends UpdateCompanion<ClubSetting> {
  final Value<int> id;
  final Value<String> clubName;
  final Value<String?> logoPath;
  final Value<String> season;
  final Value<String?> adminName;
  final Value<String?> managerName;
  final Value<String?> pinCodeHash;
  final Value<bool> entitlementSportEnabled;
  final Value<bool> entitlementCountsExcused;
  const ClubSettingsCompanion({
    this.id = const Value.absent(),
    this.clubName = const Value.absent(),
    this.logoPath = const Value.absent(),
    this.season = const Value.absent(),
    this.adminName = const Value.absent(),
    this.managerName = const Value.absent(),
    this.pinCodeHash = const Value.absent(),
    this.entitlementSportEnabled = const Value.absent(),
    this.entitlementCountsExcused = const Value.absent(),
  });
  ClubSettingsCompanion.insert({
    this.id = const Value.absent(),
    required String clubName,
    this.logoPath = const Value.absent(),
    required String season,
    this.adminName = const Value.absent(),
    this.managerName = const Value.absent(),
    this.pinCodeHash = const Value.absent(),
    this.entitlementSportEnabled = const Value.absent(),
    this.entitlementCountsExcused = const Value.absent(),
  }) : clubName = Value(clubName),
       season = Value(season);
  static Insertable<ClubSetting> custom({
    Expression<int>? id,
    Expression<String>? clubName,
    Expression<String>? logoPath,
    Expression<String>? season,
    Expression<String>? adminName,
    Expression<String>? managerName,
    Expression<String>? pinCodeHash,
    Expression<bool>? entitlementSportEnabled,
    Expression<bool>? entitlementCountsExcused,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (clubName != null) 'club_name': clubName,
      if (logoPath != null) 'logo_path': logoPath,
      if (season != null) 'season': season,
      if (adminName != null) 'admin_name': adminName,
      if (managerName != null) 'manager_name': managerName,
      if (pinCodeHash != null) 'pin_code_hash': pinCodeHash,
      if (entitlementSportEnabled != null)
        'entitlement_sport_enabled': entitlementSportEnabled,
      if (entitlementCountsExcused != null)
        'entitlement_counts_excused': entitlementCountsExcused,
    });
  }

  ClubSettingsCompanion copyWith({
    Value<int>? id,
    Value<String>? clubName,
    Value<String?>? logoPath,
    Value<String>? season,
    Value<String?>? adminName,
    Value<String?>? managerName,
    Value<String?>? pinCodeHash,
    Value<bool>? entitlementSportEnabled,
    Value<bool>? entitlementCountsExcused,
  }) {
    return ClubSettingsCompanion(
      id: id ?? this.id,
      clubName: clubName ?? this.clubName,
      logoPath: logoPath ?? this.logoPath,
      season: season ?? this.season,
      adminName: adminName ?? this.adminName,
      managerName: managerName ?? this.managerName,
      pinCodeHash: pinCodeHash ?? this.pinCodeHash,
      entitlementSportEnabled:
          entitlementSportEnabled ?? this.entitlementSportEnabled,
      entitlementCountsExcused:
          entitlementCountsExcused ?? this.entitlementCountsExcused,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (clubName.present) {
      map['club_name'] = Variable<String>(clubName.value);
    }
    if (logoPath.present) {
      map['logo_path'] = Variable<String>(logoPath.value);
    }
    if (season.present) {
      map['season'] = Variable<String>(season.value);
    }
    if (adminName.present) {
      map['admin_name'] = Variable<String>(adminName.value);
    }
    if (managerName.present) {
      map['manager_name'] = Variable<String>(managerName.value);
    }
    if (pinCodeHash.present) {
      map['pin_code_hash'] = Variable<String>(pinCodeHash.value);
    }
    if (entitlementSportEnabled.present) {
      map['entitlement_sport_enabled'] = Variable<bool>(
        entitlementSportEnabled.value,
      );
    }
    if (entitlementCountsExcused.present) {
      map['entitlement_counts_excused'] = Variable<bool>(
        entitlementCountsExcused.value,
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ClubSettingsCompanion(')
          ..write('id: $id, ')
          ..write('clubName: $clubName, ')
          ..write('logoPath: $logoPath, ')
          ..write('season: $season, ')
          ..write('adminName: $adminName, ')
          ..write('managerName: $managerName, ')
          ..write('pinCodeHash: $pinCodeHash, ')
          ..write('entitlementSportEnabled: $entitlementSportEnabled, ')
          ..write('entitlementCountsExcused: $entitlementCountsExcused')
          ..write(')'))
        .toString();
  }
}

class $TeamsTable extends Teams with TableInfo<$TeamsTable, Team> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TeamsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    category,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'teams';
  @override
  VerificationContext validateIntegrity(
    Insertable<Team> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Team map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Team(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $TeamsTable createAlias(String alias) {
    return $TeamsTable(attachedDatabase, alias);
  }
}

class Team extends DataClass implements Insertable<Team> {
  final String id;
  final String name;
  final String category;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Team({
    required this.id,
    required this.name,
    required this.category,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['category'] = Variable<String>(category);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  TeamsCompanion toCompanion(bool nullToAbsent) {
    return TeamsCompanion(
      id: Value(id),
      name: Value(name),
      category: Value(category),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Team.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Team(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      category: serializer.fromJson<String>(json['category']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'category': serializer.toJson<String>(category),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Team copyWith({
    String? id,
    String? name,
    String? category,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Team(
    id: id ?? this.id,
    name: name ?? this.name,
    category: category ?? this.category,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Team copyWithCompanion(TeamsCompanion data) {
    return Team(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      category: data.category.present ? data.category.value : this.category,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Team(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('category: $category, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, category, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Team &&
          other.id == this.id &&
          other.name == this.name &&
          other.category == this.category &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class TeamsCompanion extends UpdateCompanion<Team> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> category;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const TeamsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.category = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TeamsCompanion.insert({
    required String id,
    required String name,
    required String category,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       category = Value(category),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Team> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? category,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (category != null) 'category': category,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TeamsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? category,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return TeamsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
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
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TeamsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('category: $category, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlayersTable extends Players with TableInfo<$PlayersTable, Player> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlayersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _teamIdMeta = const VerificationMeta('teamId');
  @override
  late final GeneratedColumn<String> teamId = GeneratedColumn<String>(
    'team_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES teams (id)',
    ),
  );
  static const VerificationMeta _jerseyNumberMeta = const VerificationMeta(
    'jerseyNumber',
  );
  @override
  late final GeneratedColumn<int> jerseyNumber = GeneratedColumn<int>(
    'jersey_number',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<String> position = GeneratedColumn<String>(
    'position',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _joinDateMeta = const VerificationMeta(
    'joinDate',
  );
  @override
  late final GeneratedColumn<DateTime> joinDate = GeneratedColumn<DateTime>(
    'join_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isArchivedMeta = const VerificationMeta(
    'isArchived',
  );
  @override
  late final GeneratedColumn<bool> isArchived = GeneratedColumn<bool>(
    'is_archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_archived" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    teamId,
    jerseyNumber,
    position,
    joinDate,
    isArchived,
    notes,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'players';
  @override
  VerificationContext validateIntegrity(
    Insertable<Player> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('team_id')) {
      context.handle(
        _teamIdMeta,
        teamId.isAcceptableOrUnknown(data['team_id']!, _teamIdMeta),
      );
    } else if (isInserting) {
      context.missing(_teamIdMeta);
    }
    if (data.containsKey('jersey_number')) {
      context.handle(
        _jerseyNumberMeta,
        jerseyNumber.isAcceptableOrUnknown(
          data['jersey_number']!,
          _jerseyNumberMeta,
        ),
      );
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    }
    if (data.containsKey('join_date')) {
      context.handle(
        _joinDateMeta,
        joinDate.isAcceptableOrUnknown(data['join_date']!, _joinDateMeta),
      );
    } else if (isInserting) {
      context.missing(_joinDateMeta);
    }
    if (data.containsKey('is_archived')) {
      context.handle(
        _isArchivedMeta,
        isArchived.isAcceptableOrUnknown(data['is_archived']!, _isArchivedMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Player map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Player(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      teamId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}team_id'],
      )!,
      jerseyNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}jersey_number'],
      ),
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}position'],
      ),
      joinDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}join_date'],
      )!,
      isArchived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_archived'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $PlayersTable createAlias(String alias) {
    return $PlayersTable(attachedDatabase, alias);
  }
}

class Player extends DataClass implements Insertable<Player> {
  final String id;
  final String name;
  final String teamId;
  final int? jerseyNumber;
  final String? position;
  final DateTime joinDate;
  final bool isArchived;
  final String? notes;
  final DateTime updatedAt;
  const Player({
    required this.id,
    required this.name,
    required this.teamId,
    this.jerseyNumber,
    this.position,
    required this.joinDate,
    required this.isArchived,
    this.notes,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['team_id'] = Variable<String>(teamId);
    if (!nullToAbsent || jerseyNumber != null) {
      map['jersey_number'] = Variable<int>(jerseyNumber);
    }
    if (!nullToAbsent || position != null) {
      map['position'] = Variable<String>(position);
    }
    map['join_date'] = Variable<DateTime>(joinDate);
    map['is_archived'] = Variable<bool>(isArchived);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  PlayersCompanion toCompanion(bool nullToAbsent) {
    return PlayersCompanion(
      id: Value(id),
      name: Value(name),
      teamId: Value(teamId),
      jerseyNumber: jerseyNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(jerseyNumber),
      position: position == null && nullToAbsent
          ? const Value.absent()
          : Value(position),
      joinDate: Value(joinDate),
      isArchived: Value(isArchived),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      updatedAt: Value(updatedAt),
    );
  }

  factory Player.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Player(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      teamId: serializer.fromJson<String>(json['teamId']),
      jerseyNumber: serializer.fromJson<int?>(json['jerseyNumber']),
      position: serializer.fromJson<String?>(json['position']),
      joinDate: serializer.fromJson<DateTime>(json['joinDate']),
      isArchived: serializer.fromJson<bool>(json['isArchived']),
      notes: serializer.fromJson<String?>(json['notes']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'teamId': serializer.toJson<String>(teamId),
      'jerseyNumber': serializer.toJson<int?>(jerseyNumber),
      'position': serializer.toJson<String?>(position),
      'joinDate': serializer.toJson<DateTime>(joinDate),
      'isArchived': serializer.toJson<bool>(isArchived),
      'notes': serializer.toJson<String?>(notes),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Player copyWith({
    String? id,
    String? name,
    String? teamId,
    Value<int?> jerseyNumber = const Value.absent(),
    Value<String?> position = const Value.absent(),
    DateTime? joinDate,
    bool? isArchived,
    Value<String?> notes = const Value.absent(),
    DateTime? updatedAt,
  }) => Player(
    id: id ?? this.id,
    name: name ?? this.name,
    teamId: teamId ?? this.teamId,
    jerseyNumber: jerseyNumber.present ? jerseyNumber.value : this.jerseyNumber,
    position: position.present ? position.value : this.position,
    joinDate: joinDate ?? this.joinDate,
    isArchived: isArchived ?? this.isArchived,
    notes: notes.present ? notes.value : this.notes,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Player copyWithCompanion(PlayersCompanion data) {
    return Player(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      teamId: data.teamId.present ? data.teamId.value : this.teamId,
      jerseyNumber: data.jerseyNumber.present
          ? data.jerseyNumber.value
          : this.jerseyNumber,
      position: data.position.present ? data.position.value : this.position,
      joinDate: data.joinDate.present ? data.joinDate.value : this.joinDate,
      isArchived: data.isArchived.present
          ? data.isArchived.value
          : this.isArchived,
      notes: data.notes.present ? data.notes.value : this.notes,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Player(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('teamId: $teamId, ')
          ..write('jerseyNumber: $jerseyNumber, ')
          ..write('position: $position, ')
          ..write('joinDate: $joinDate, ')
          ..write('isArchived: $isArchived, ')
          ..write('notes: $notes, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    teamId,
    jerseyNumber,
    position,
    joinDate,
    isArchived,
    notes,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Player &&
          other.id == this.id &&
          other.name == this.name &&
          other.teamId == this.teamId &&
          other.jerseyNumber == this.jerseyNumber &&
          other.position == this.position &&
          other.joinDate == this.joinDate &&
          other.isArchived == this.isArchived &&
          other.notes == this.notes &&
          other.updatedAt == this.updatedAt);
}

class PlayersCompanion extends UpdateCompanion<Player> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> teamId;
  final Value<int?> jerseyNumber;
  final Value<String?> position;
  final Value<DateTime> joinDate;
  final Value<bool> isArchived;
  final Value<String?> notes;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const PlayersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.teamId = const Value.absent(),
    this.jerseyNumber = const Value.absent(),
    this.position = const Value.absent(),
    this.joinDate = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.notes = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlayersCompanion.insert({
    required String id,
    required String name,
    required String teamId,
    this.jerseyNumber = const Value.absent(),
    this.position = const Value.absent(),
    required DateTime joinDate,
    this.isArchived = const Value.absent(),
    this.notes = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       teamId = Value(teamId),
       joinDate = Value(joinDate),
       updatedAt = Value(updatedAt);
  static Insertable<Player> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? teamId,
    Expression<int>? jerseyNumber,
    Expression<String>? position,
    Expression<DateTime>? joinDate,
    Expression<bool>? isArchived,
    Expression<String>? notes,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (teamId != null) 'team_id': teamId,
      if (jerseyNumber != null) 'jersey_number': jerseyNumber,
      if (position != null) 'position': position,
      if (joinDate != null) 'join_date': joinDate,
      if (isArchived != null) 'is_archived': isArchived,
      if (notes != null) 'notes': notes,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlayersCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? teamId,
    Value<int?>? jerseyNumber,
    Value<String?>? position,
    Value<DateTime>? joinDate,
    Value<bool>? isArchived,
    Value<String?>? notes,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return PlayersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      teamId: teamId ?? this.teamId,
      jerseyNumber: jerseyNumber ?? this.jerseyNumber,
      position: position ?? this.position,
      joinDate: joinDate ?? this.joinDate,
      isArchived: isArchived ?? this.isArchived,
      notes: notes ?? this.notes,
      updatedAt: updatedAt ?? this.updatedAt,
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
    if (teamId.present) {
      map['team_id'] = Variable<String>(teamId.value);
    }
    if (jerseyNumber.present) {
      map['jersey_number'] = Variable<int>(jerseyNumber.value);
    }
    if (position.present) {
      map['position'] = Variable<String>(position.value);
    }
    if (joinDate.present) {
      map['join_date'] = Variable<DateTime>(joinDate.value);
    }
    if (isArchived.present) {
      map['is_archived'] = Variable<bool>(isArchived.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlayersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('teamId: $teamId, ')
          ..write('jerseyNumber: $jerseyNumber, ')
          ..write('position: $position, ')
          ..write('joinDate: $joinDate, ')
          ..write('isArchived: $isArchived, ')
          ..write('notes: $notes, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SessionsTable extends Sessions with TableInfo<$SessionsTable, Session> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _sessionUuidMeta = const VerificationMeta(
    'sessionUuid',
  );
  @override
  late final GeneratedColumn<String> sessionUuid = GeneratedColumn<String>(
    'session_uuid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _teamIdMeta = const VerificationMeta('teamId');
  @override
  late final GeneratedColumn<String> teamId = GeneratedColumn<String>(
    'team_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES teams (id)',
    ),
  );
  static const VerificationMeta _sessionDateMeta = const VerificationMeta(
    'sessionDate',
  );
  @override
  late final GeneratedColumn<DateTime> sessionDate = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('تمرين'),
  );
  static const VerificationMeta _periodMeta = const VerificationMeta('period');
  @override
  late final GeneratedColumn<String> period = GeneratedColumn<String>(
    'period',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('مسائي'),
  );
  static const VerificationMeta _locationMeta = const VerificationMeta(
    'location',
  );
  @override
  late final GeneratedColumn<String> location = GeneratedColumn<String>(
    'location',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isCancelledMeta = const VerificationMeta(
    'isCancelled',
  );
  @override
  late final GeneratedColumn<bool> isCancelled = GeneratedColumn<bool>(
    'is_cancelled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_cancelled" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _countsInAttendanceMeta =
      const VerificationMeta('countsInAttendance');
  @override
  late final GeneratedColumn<bool> countsInAttendance = GeneratedColumn<bool>(
    'counts_in_attendance',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("counts_in_attendance" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _isDispatchedMeta = const VerificationMeta(
    'isDispatched',
  );
  @override
  late final GeneratedColumn<bool> isDispatched = GeneratedColumn<bool>(
    'is_dispatched',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_dispatched" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _dispatchedAtMeta = const VerificationMeta(
    'dispatchedAt',
  );
  @override
  late final GeneratedColumn<DateTime> dispatchedAt = GeneratedColumn<DateTime>(
    'dispatched_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isLockedMeta = const VerificationMeta(
    'isLocked',
  );
  @override
  late final GeneratedColumn<bool> isLocked = GeneratedColumn<bool>(
    'is_locked',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_locked" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('local'),
  );
  static const VerificationMeta _sessionHashMeta = const VerificationMeta(
    'sessionHash',
  );
  @override
  late final GeneratedColumn<String> sessionHash = GeneratedColumn<String>(
    'session_hash',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('draft'),
  );
  static const VerificationMeta _approvedAtMeta = const VerificationMeta(
    'approvedAt',
  );
  @override
  late final GeneratedColumn<DateTime> approvedAt = GeneratedColumn<DateTime>(
    'approved_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _approvedByMeta = const VerificationMeta(
    'approvedBy',
  );
  @override
  late final GeneratedColumn<String> approvedBy = GeneratedColumn<String>(
    'approved_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    sessionUuid,
    teamId,
    sessionDate,
    type,
    period,
    location,
    isCancelled,
    countsInAttendance,
    isDispatched,
    dispatchedAt,
    isLocked,
    syncStatus,
    sessionHash,
    status,
    approvedAt,
    approvedBy,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<Session> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('session_uuid')) {
      context.handle(
        _sessionUuidMeta,
        sessionUuid.isAcceptableOrUnknown(
          data['session_uuid']!,
          _sessionUuidMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sessionUuidMeta);
    }
    if (data.containsKey('team_id')) {
      context.handle(
        _teamIdMeta,
        teamId.isAcceptableOrUnknown(data['team_id']!, _teamIdMeta),
      );
    } else if (isInserting) {
      context.missing(_teamIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _sessionDateMeta,
        sessionDate.isAcceptableOrUnknown(data['date']!, _sessionDateMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionDateMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    }
    if (data.containsKey('period')) {
      context.handle(
        _periodMeta,
        period.isAcceptableOrUnknown(data['period']!, _periodMeta),
      );
    }
    if (data.containsKey('location')) {
      context.handle(
        _locationMeta,
        location.isAcceptableOrUnknown(data['location']!, _locationMeta),
      );
    }
    if (data.containsKey('is_cancelled')) {
      context.handle(
        _isCancelledMeta,
        isCancelled.isAcceptableOrUnknown(
          data['is_cancelled']!,
          _isCancelledMeta,
        ),
      );
    }
    if (data.containsKey('counts_in_attendance')) {
      context.handle(
        _countsInAttendanceMeta,
        countsInAttendance.isAcceptableOrUnknown(
          data['counts_in_attendance']!,
          _countsInAttendanceMeta,
        ),
      );
    }
    if (data.containsKey('is_dispatched')) {
      context.handle(
        _isDispatchedMeta,
        isDispatched.isAcceptableOrUnknown(
          data['is_dispatched']!,
          _isDispatchedMeta,
        ),
      );
    }
    if (data.containsKey('dispatched_at')) {
      context.handle(
        _dispatchedAtMeta,
        dispatchedAt.isAcceptableOrUnknown(
          data['dispatched_at']!,
          _dispatchedAtMeta,
        ),
      );
    }
    if (data.containsKey('is_locked')) {
      context.handle(
        _isLockedMeta,
        isLocked.isAcceptableOrUnknown(data['is_locked']!, _isLockedMeta),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('session_hash')) {
      context.handle(
        _sessionHashMeta,
        sessionHash.isAcceptableOrUnknown(
          data['session_hash']!,
          _sessionHashMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sessionHashMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('approved_at')) {
      context.handle(
        _approvedAtMeta,
        approvedAt.isAcceptableOrUnknown(data['approved_at']!, _approvedAtMeta),
      );
    }
    if (data.containsKey('approved_by')) {
      context.handle(
        _approvedByMeta,
        approvedBy.isAcceptableOrUnknown(data['approved_by']!, _approvedByMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {sessionUuid};
  @override
  Session map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Session(
      sessionUuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_uuid'],
      )!,
      teamId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}team_id'],
      )!,
      sessionDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      period: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}period'],
      )!,
      location: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location'],
      ),
      isCancelled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_cancelled'],
      )!,
      countsInAttendance: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}counts_in_attendance'],
      )!,
      isDispatched: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_dispatched'],
      )!,
      dispatchedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}dispatched_at'],
      ),
      isLocked: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_locked'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      sessionHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_hash'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      approvedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}approved_at'],
      ),
      approvedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}approved_by'],
      ),
    );
  }

  @override
  $SessionsTable createAlias(String alias) {
    return $SessionsTable(attachedDatabase, alias);
  }
}

class Session extends DataClass implements Insertable<Session> {
  final String sessionUuid;
  final String teamId;
  final DateTime sessionDate;
  final String type;
  final String period;
  final String? location;
  final bool isCancelled;
  final bool countsInAttendance;
  final bool isDispatched;
  final DateTime? dispatchedAt;
  final bool isLocked;
  final String syncStatus;
  final String sessionHash;
  final String status;
  final DateTime? approvedAt;
  final String? approvedBy;
  const Session({
    required this.sessionUuid,
    required this.teamId,
    required this.sessionDate,
    required this.type,
    required this.period,
    this.location,
    required this.isCancelled,
    required this.countsInAttendance,
    required this.isDispatched,
    this.dispatchedAt,
    required this.isLocked,
    required this.syncStatus,
    required this.sessionHash,
    required this.status,
    this.approvedAt,
    this.approvedBy,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['session_uuid'] = Variable<String>(sessionUuid);
    map['team_id'] = Variable<String>(teamId);
    map['date'] = Variable<DateTime>(sessionDate);
    map['type'] = Variable<String>(type);
    map['period'] = Variable<String>(period);
    if (!nullToAbsent || location != null) {
      map['location'] = Variable<String>(location);
    }
    map['is_cancelled'] = Variable<bool>(isCancelled);
    map['counts_in_attendance'] = Variable<bool>(countsInAttendance);
    map['is_dispatched'] = Variable<bool>(isDispatched);
    if (!nullToAbsent || dispatchedAt != null) {
      map['dispatched_at'] = Variable<DateTime>(dispatchedAt);
    }
    map['is_locked'] = Variable<bool>(isLocked);
    map['sync_status'] = Variable<String>(syncStatus);
    map['session_hash'] = Variable<String>(sessionHash);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || approvedAt != null) {
      map['approved_at'] = Variable<DateTime>(approvedAt);
    }
    if (!nullToAbsent || approvedBy != null) {
      map['approved_by'] = Variable<String>(approvedBy);
    }
    return map;
  }

  SessionsCompanion toCompanion(bool nullToAbsent) {
    return SessionsCompanion(
      sessionUuid: Value(sessionUuid),
      teamId: Value(teamId),
      sessionDate: Value(sessionDate),
      type: Value(type),
      period: Value(period),
      location: location == null && nullToAbsent
          ? const Value.absent()
          : Value(location),
      isCancelled: Value(isCancelled),
      countsInAttendance: Value(countsInAttendance),
      isDispatched: Value(isDispatched),
      dispatchedAt: dispatchedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(dispatchedAt),
      isLocked: Value(isLocked),
      syncStatus: Value(syncStatus),
      sessionHash: Value(sessionHash),
      status: Value(status),
      approvedAt: approvedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(approvedAt),
      approvedBy: approvedBy == null && nullToAbsent
          ? const Value.absent()
          : Value(approvedBy),
    );
  }

  factory Session.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Session(
      sessionUuid: serializer.fromJson<String>(json['sessionUuid']),
      teamId: serializer.fromJson<String>(json['teamId']),
      sessionDate: serializer.fromJson<DateTime>(json['sessionDate']),
      type: serializer.fromJson<String>(json['type']),
      period: serializer.fromJson<String>(json['period']),
      location: serializer.fromJson<String?>(json['location']),
      isCancelled: serializer.fromJson<bool>(json['isCancelled']),
      countsInAttendance: serializer.fromJson<bool>(json['countsInAttendance']),
      isDispatched: serializer.fromJson<bool>(json['isDispatched']),
      dispatchedAt: serializer.fromJson<DateTime?>(json['dispatchedAt']),
      isLocked: serializer.fromJson<bool>(json['isLocked']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      sessionHash: serializer.fromJson<String>(json['sessionHash']),
      status: serializer.fromJson<String>(json['status']),
      approvedAt: serializer.fromJson<DateTime?>(json['approvedAt']),
      approvedBy: serializer.fromJson<String?>(json['approvedBy']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'sessionUuid': serializer.toJson<String>(sessionUuid),
      'teamId': serializer.toJson<String>(teamId),
      'sessionDate': serializer.toJson<DateTime>(sessionDate),
      'type': serializer.toJson<String>(type),
      'period': serializer.toJson<String>(period),
      'location': serializer.toJson<String?>(location),
      'isCancelled': serializer.toJson<bool>(isCancelled),
      'countsInAttendance': serializer.toJson<bool>(countsInAttendance),
      'isDispatched': serializer.toJson<bool>(isDispatched),
      'dispatchedAt': serializer.toJson<DateTime?>(dispatchedAt),
      'isLocked': serializer.toJson<bool>(isLocked),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'sessionHash': serializer.toJson<String>(sessionHash),
      'status': serializer.toJson<String>(status),
      'approvedAt': serializer.toJson<DateTime?>(approvedAt),
      'approvedBy': serializer.toJson<String?>(approvedBy),
    };
  }

  Session copyWith({
    String? sessionUuid,
    String? teamId,
    DateTime? sessionDate,
    String? type,
    String? period,
    Value<String?> location = const Value.absent(),
    bool? isCancelled,
    bool? countsInAttendance,
    bool? isDispatched,
    Value<DateTime?> dispatchedAt = const Value.absent(),
    bool? isLocked,
    String? syncStatus,
    String? sessionHash,
    String? status,
    Value<DateTime?> approvedAt = const Value.absent(),
    Value<String?> approvedBy = const Value.absent(),
  }) => Session(
    sessionUuid: sessionUuid ?? this.sessionUuid,
    teamId: teamId ?? this.teamId,
    sessionDate: sessionDate ?? this.sessionDate,
    type: type ?? this.type,
    period: period ?? this.period,
    location: location.present ? location.value : this.location,
    isCancelled: isCancelled ?? this.isCancelled,
    countsInAttendance: countsInAttendance ?? this.countsInAttendance,
    isDispatched: isDispatched ?? this.isDispatched,
    dispatchedAt: dispatchedAt.present ? dispatchedAt.value : this.dispatchedAt,
    isLocked: isLocked ?? this.isLocked,
    syncStatus: syncStatus ?? this.syncStatus,
    sessionHash: sessionHash ?? this.sessionHash,
    status: status ?? this.status,
    approvedAt: approvedAt.present ? approvedAt.value : this.approvedAt,
    approvedBy: approvedBy.present ? approvedBy.value : this.approvedBy,
  );
  Session copyWithCompanion(SessionsCompanion data) {
    return Session(
      sessionUuid: data.sessionUuid.present
          ? data.sessionUuid.value
          : this.sessionUuid,
      teamId: data.teamId.present ? data.teamId.value : this.teamId,
      sessionDate: data.sessionDate.present
          ? data.sessionDate.value
          : this.sessionDate,
      type: data.type.present ? data.type.value : this.type,
      period: data.period.present ? data.period.value : this.period,
      location: data.location.present ? data.location.value : this.location,
      isCancelled: data.isCancelled.present
          ? data.isCancelled.value
          : this.isCancelled,
      countsInAttendance: data.countsInAttendance.present
          ? data.countsInAttendance.value
          : this.countsInAttendance,
      isDispatched: data.isDispatched.present
          ? data.isDispatched.value
          : this.isDispatched,
      dispatchedAt: data.dispatchedAt.present
          ? data.dispatchedAt.value
          : this.dispatchedAt,
      isLocked: data.isLocked.present ? data.isLocked.value : this.isLocked,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      sessionHash: data.sessionHash.present
          ? data.sessionHash.value
          : this.sessionHash,
      status: data.status.present ? data.status.value : this.status,
      approvedAt: data.approvedAt.present
          ? data.approvedAt.value
          : this.approvedAt,
      approvedBy: data.approvedBy.present
          ? data.approvedBy.value
          : this.approvedBy,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Session(')
          ..write('sessionUuid: $sessionUuid, ')
          ..write('teamId: $teamId, ')
          ..write('sessionDate: $sessionDate, ')
          ..write('type: $type, ')
          ..write('period: $period, ')
          ..write('location: $location, ')
          ..write('isCancelled: $isCancelled, ')
          ..write('countsInAttendance: $countsInAttendance, ')
          ..write('isDispatched: $isDispatched, ')
          ..write('dispatchedAt: $dispatchedAt, ')
          ..write('isLocked: $isLocked, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('sessionHash: $sessionHash, ')
          ..write('status: $status, ')
          ..write('approvedAt: $approvedAt, ')
          ..write('approvedBy: $approvedBy')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    sessionUuid,
    teamId,
    sessionDate,
    type,
    period,
    location,
    isCancelled,
    countsInAttendance,
    isDispatched,
    dispatchedAt,
    isLocked,
    syncStatus,
    sessionHash,
    status,
    approvedAt,
    approvedBy,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Session &&
          other.sessionUuid == this.sessionUuid &&
          other.teamId == this.teamId &&
          other.sessionDate == this.sessionDate &&
          other.type == this.type &&
          other.period == this.period &&
          other.location == this.location &&
          other.isCancelled == this.isCancelled &&
          other.countsInAttendance == this.countsInAttendance &&
          other.isDispatched == this.isDispatched &&
          other.dispatchedAt == this.dispatchedAt &&
          other.isLocked == this.isLocked &&
          other.syncStatus == this.syncStatus &&
          other.sessionHash == this.sessionHash &&
          other.status == this.status &&
          other.approvedAt == this.approvedAt &&
          other.approvedBy == this.approvedBy);
}

class SessionsCompanion extends UpdateCompanion<Session> {
  final Value<String> sessionUuid;
  final Value<String> teamId;
  final Value<DateTime> sessionDate;
  final Value<String> type;
  final Value<String> period;
  final Value<String?> location;
  final Value<bool> isCancelled;
  final Value<bool> countsInAttendance;
  final Value<bool> isDispatched;
  final Value<DateTime?> dispatchedAt;
  final Value<bool> isLocked;
  final Value<String> syncStatus;
  final Value<String> sessionHash;
  final Value<String> status;
  final Value<DateTime?> approvedAt;
  final Value<String?> approvedBy;
  final Value<int> rowid;
  const SessionsCompanion({
    this.sessionUuid = const Value.absent(),
    this.teamId = const Value.absent(),
    this.sessionDate = const Value.absent(),
    this.type = const Value.absent(),
    this.period = const Value.absent(),
    this.location = const Value.absent(),
    this.isCancelled = const Value.absent(),
    this.countsInAttendance = const Value.absent(),
    this.isDispatched = const Value.absent(),
    this.dispatchedAt = const Value.absent(),
    this.isLocked = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.sessionHash = const Value.absent(),
    this.status = const Value.absent(),
    this.approvedAt = const Value.absent(),
    this.approvedBy = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SessionsCompanion.insert({
    required String sessionUuid,
    required String teamId,
    required DateTime sessionDate,
    this.type = const Value.absent(),
    this.period = const Value.absent(),
    this.location = const Value.absent(),
    this.isCancelled = const Value.absent(),
    this.countsInAttendance = const Value.absent(),
    this.isDispatched = const Value.absent(),
    this.dispatchedAt = const Value.absent(),
    this.isLocked = const Value.absent(),
    this.syncStatus = const Value.absent(),
    required String sessionHash,
    this.status = const Value.absent(),
    this.approvedAt = const Value.absent(),
    this.approvedBy = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : sessionUuid = Value(sessionUuid),
       teamId = Value(teamId),
       sessionDate = Value(sessionDate),
       sessionHash = Value(sessionHash);
  static Insertable<Session> custom({
    Expression<String>? sessionUuid,
    Expression<String>? teamId,
    Expression<DateTime>? sessionDate,
    Expression<String>? type,
    Expression<String>? period,
    Expression<String>? location,
    Expression<bool>? isCancelled,
    Expression<bool>? countsInAttendance,
    Expression<bool>? isDispatched,
    Expression<DateTime>? dispatchedAt,
    Expression<bool>? isLocked,
    Expression<String>? syncStatus,
    Expression<String>? sessionHash,
    Expression<String>? status,
    Expression<DateTime>? approvedAt,
    Expression<String>? approvedBy,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (sessionUuid != null) 'session_uuid': sessionUuid,
      if (teamId != null) 'team_id': teamId,
      if (sessionDate != null) 'date': sessionDate,
      if (type != null) 'type': type,
      if (period != null) 'period': period,
      if (location != null) 'location': location,
      if (isCancelled != null) 'is_cancelled': isCancelled,
      if (countsInAttendance != null)
        'counts_in_attendance': countsInAttendance,
      if (isDispatched != null) 'is_dispatched': isDispatched,
      if (dispatchedAt != null) 'dispatched_at': dispatchedAt,
      if (isLocked != null) 'is_locked': isLocked,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (sessionHash != null) 'session_hash': sessionHash,
      if (status != null) 'status': status,
      if (approvedAt != null) 'approved_at': approvedAt,
      if (approvedBy != null) 'approved_by': approvedBy,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SessionsCompanion copyWith({
    Value<String>? sessionUuid,
    Value<String>? teamId,
    Value<DateTime>? sessionDate,
    Value<String>? type,
    Value<String>? period,
    Value<String?>? location,
    Value<bool>? isCancelled,
    Value<bool>? countsInAttendance,
    Value<bool>? isDispatched,
    Value<DateTime?>? dispatchedAt,
    Value<bool>? isLocked,
    Value<String>? syncStatus,
    Value<String>? sessionHash,
    Value<String>? status,
    Value<DateTime?>? approvedAt,
    Value<String?>? approvedBy,
    Value<int>? rowid,
  }) {
    return SessionsCompanion(
      sessionUuid: sessionUuid ?? this.sessionUuid,
      teamId: teamId ?? this.teamId,
      sessionDate: sessionDate ?? this.sessionDate,
      type: type ?? this.type,
      period: period ?? this.period,
      location: location ?? this.location,
      isCancelled: isCancelled ?? this.isCancelled,
      countsInAttendance: countsInAttendance ?? this.countsInAttendance,
      isDispatched: isDispatched ?? this.isDispatched,
      dispatchedAt: dispatchedAt ?? this.dispatchedAt,
      isLocked: isLocked ?? this.isLocked,
      syncStatus: syncStatus ?? this.syncStatus,
      sessionHash: sessionHash ?? this.sessionHash,
      status: status ?? this.status,
      approvedAt: approvedAt ?? this.approvedAt,
      approvedBy: approvedBy ?? this.approvedBy,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (sessionUuid.present) {
      map['session_uuid'] = Variable<String>(sessionUuid.value);
    }
    if (teamId.present) {
      map['team_id'] = Variable<String>(teamId.value);
    }
    if (sessionDate.present) {
      map['date'] = Variable<DateTime>(sessionDate.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (period.present) {
      map['period'] = Variable<String>(period.value);
    }
    if (location.present) {
      map['location'] = Variable<String>(location.value);
    }
    if (isCancelled.present) {
      map['is_cancelled'] = Variable<bool>(isCancelled.value);
    }
    if (countsInAttendance.present) {
      map['counts_in_attendance'] = Variable<bool>(countsInAttendance.value);
    }
    if (isDispatched.present) {
      map['is_dispatched'] = Variable<bool>(isDispatched.value);
    }
    if (dispatchedAt.present) {
      map['dispatched_at'] = Variable<DateTime>(dispatchedAt.value);
    }
    if (isLocked.present) {
      map['is_locked'] = Variable<bool>(isLocked.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (sessionHash.present) {
      map['session_hash'] = Variable<String>(sessionHash.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (approvedAt.present) {
      map['approved_at'] = Variable<DateTime>(approvedAt.value);
    }
    if (approvedBy.present) {
      map['approved_by'] = Variable<String>(approvedBy.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionsCompanion(')
          ..write('sessionUuid: $sessionUuid, ')
          ..write('teamId: $teamId, ')
          ..write('sessionDate: $sessionDate, ')
          ..write('type: $type, ')
          ..write('period: $period, ')
          ..write('location: $location, ')
          ..write('isCancelled: $isCancelled, ')
          ..write('countsInAttendance: $countsInAttendance, ')
          ..write('isDispatched: $isDispatched, ')
          ..write('dispatchedAt: $dispatchedAt, ')
          ..write('isLocked: $isLocked, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('sessionHash: $sessionHash, ')
          ..write('status: $status, ')
          ..write('approvedAt: $approvedAt, ')
          ..write('approvedBy: $approvedBy, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AttendanceRecordsTable extends AttendanceRecords
    with TableInfo<$AttendanceRecordsTable, AttendanceRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AttendanceRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sessionUuidMeta = const VerificationMeta(
    'sessionUuid',
  );
  @override
  late final GeneratedColumn<String> sessionUuid = GeneratedColumn<String>(
    'session_uuid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sessions (session_uuid) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _playerIdMeta = const VerificationMeta(
    'playerId',
  );
  @override
  late final GeneratedColumn<String> playerId = GeneratedColumn<String>(
    'player_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES players (id)',
    ),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lateMinutesMeta = const VerificationMeta(
    'lateMinutes',
  );
  @override
  late final GeneratedColumn<int> lateMinutes = GeneratedColumn<int>(
    'late_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
    'reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionUuid,
    playerId,
    status,
    lateMinutes,
    reason,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'attendance_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<AttendanceRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('session_uuid')) {
      context.handle(
        _sessionUuidMeta,
        sessionUuid.isAcceptableOrUnknown(
          data['session_uuid']!,
          _sessionUuidMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sessionUuidMeta);
    }
    if (data.containsKey('player_id')) {
      context.handle(
        _playerIdMeta,
        playerId.isAcceptableOrUnknown(data['player_id']!, _playerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_playerIdMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('late_minutes')) {
      context.handle(
        _lateMinutesMeta,
        lateMinutes.isAcceptableOrUnknown(
          data['late_minutes']!,
          _lateMinutesMeta,
        ),
      );
    }
    if (data.containsKey('reason')) {
      context.handle(
        _reasonMeta,
        reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {sessionUuid, playerId},
  ];
  @override
  AttendanceRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AttendanceRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      sessionUuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_uuid'],
      )!,
      playerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}player_id'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      lateMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}late_minutes'],
      )!,
      reason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reason'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
    );
  }

  @override
  $AttendanceRecordsTable createAlias(String alias) {
    return $AttendanceRecordsTable(attachedDatabase, alias);
  }
}

class AttendanceRecord extends DataClass
    implements Insertable<AttendanceRecord> {
  final String id;
  final String sessionUuid;
  final String playerId;
  final String status;
  final int lateMinutes;
  final String? reason;
  final String? notes;
  const AttendanceRecord({
    required this.id,
    required this.sessionUuid,
    required this.playerId,
    required this.status,
    required this.lateMinutes,
    this.reason,
    this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['session_uuid'] = Variable<String>(sessionUuid);
    map['player_id'] = Variable<String>(playerId);
    map['status'] = Variable<String>(status);
    map['late_minutes'] = Variable<int>(lateMinutes);
    if (!nullToAbsent || reason != null) {
      map['reason'] = Variable<String>(reason);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  AttendanceRecordsCompanion toCompanion(bool nullToAbsent) {
    return AttendanceRecordsCompanion(
      id: Value(id),
      sessionUuid: Value(sessionUuid),
      playerId: Value(playerId),
      status: Value(status),
      lateMinutes: Value(lateMinutes),
      reason: reason == null && nullToAbsent
          ? const Value.absent()
          : Value(reason),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
    );
  }

  factory AttendanceRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AttendanceRecord(
      id: serializer.fromJson<String>(json['id']),
      sessionUuid: serializer.fromJson<String>(json['sessionUuid']),
      playerId: serializer.fromJson<String>(json['playerId']),
      status: serializer.fromJson<String>(json['status']),
      lateMinutes: serializer.fromJson<int>(json['lateMinutes']),
      reason: serializer.fromJson<String?>(json['reason']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sessionUuid': serializer.toJson<String>(sessionUuid),
      'playerId': serializer.toJson<String>(playerId),
      'status': serializer.toJson<String>(status),
      'lateMinutes': serializer.toJson<int>(lateMinutes),
      'reason': serializer.toJson<String?>(reason),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  AttendanceRecord copyWith({
    String? id,
    String? sessionUuid,
    String? playerId,
    String? status,
    int? lateMinutes,
    Value<String?> reason = const Value.absent(),
    Value<String?> notes = const Value.absent(),
  }) => AttendanceRecord(
    id: id ?? this.id,
    sessionUuid: sessionUuid ?? this.sessionUuid,
    playerId: playerId ?? this.playerId,
    status: status ?? this.status,
    lateMinutes: lateMinutes ?? this.lateMinutes,
    reason: reason.present ? reason.value : this.reason,
    notes: notes.present ? notes.value : this.notes,
  );
  AttendanceRecord copyWithCompanion(AttendanceRecordsCompanion data) {
    return AttendanceRecord(
      id: data.id.present ? data.id.value : this.id,
      sessionUuid: data.sessionUuid.present
          ? data.sessionUuid.value
          : this.sessionUuid,
      playerId: data.playerId.present ? data.playerId.value : this.playerId,
      status: data.status.present ? data.status.value : this.status,
      lateMinutes: data.lateMinutes.present
          ? data.lateMinutes.value
          : this.lateMinutes,
      reason: data.reason.present ? data.reason.value : this.reason,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AttendanceRecord(')
          ..write('id: $id, ')
          ..write('sessionUuid: $sessionUuid, ')
          ..write('playerId: $playerId, ')
          ..write('status: $status, ')
          ..write('lateMinutes: $lateMinutes, ')
          ..write('reason: $reason, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sessionUuid,
    playerId,
    status,
    lateMinutes,
    reason,
    notes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AttendanceRecord &&
          other.id == this.id &&
          other.sessionUuid == this.sessionUuid &&
          other.playerId == this.playerId &&
          other.status == this.status &&
          other.lateMinutes == this.lateMinutes &&
          other.reason == this.reason &&
          other.notes == this.notes);
}

class AttendanceRecordsCompanion extends UpdateCompanion<AttendanceRecord> {
  final Value<String> id;
  final Value<String> sessionUuid;
  final Value<String> playerId;
  final Value<String> status;
  final Value<int> lateMinutes;
  final Value<String?> reason;
  final Value<String?> notes;
  final Value<int> rowid;
  const AttendanceRecordsCompanion({
    this.id = const Value.absent(),
    this.sessionUuid = const Value.absent(),
    this.playerId = const Value.absent(),
    this.status = const Value.absent(),
    this.lateMinutes = const Value.absent(),
    this.reason = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AttendanceRecordsCompanion.insert({
    required String id,
    required String sessionUuid,
    required String playerId,
    required String status,
    this.lateMinutes = const Value.absent(),
    this.reason = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       sessionUuid = Value(sessionUuid),
       playerId = Value(playerId),
       status = Value(status);
  static Insertable<AttendanceRecord> custom({
    Expression<String>? id,
    Expression<String>? sessionUuid,
    Expression<String>? playerId,
    Expression<String>? status,
    Expression<int>? lateMinutes,
    Expression<String>? reason,
    Expression<String>? notes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionUuid != null) 'session_uuid': sessionUuid,
      if (playerId != null) 'player_id': playerId,
      if (status != null) 'status': status,
      if (lateMinutes != null) 'late_minutes': lateMinutes,
      if (reason != null) 'reason': reason,
      if (notes != null) 'notes': notes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AttendanceRecordsCompanion copyWith({
    Value<String>? id,
    Value<String>? sessionUuid,
    Value<String>? playerId,
    Value<String>? status,
    Value<int>? lateMinutes,
    Value<String?>? reason,
    Value<String?>? notes,
    Value<int>? rowid,
  }) {
    return AttendanceRecordsCompanion(
      id: id ?? this.id,
      sessionUuid: sessionUuid ?? this.sessionUuid,
      playerId: playerId ?? this.playerId,
      status: status ?? this.status,
      lateMinutes: lateMinutes ?? this.lateMinutes,
      reason: reason ?? this.reason,
      notes: notes ?? this.notes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sessionUuid.present) {
      map['session_uuid'] = Variable<String>(sessionUuid.value);
    }
    if (playerId.present) {
      map['player_id'] = Variable<String>(playerId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (lateMinutes.present) {
      map['late_minutes'] = Variable<int>(lateMinutes.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AttendanceRecordsCompanion(')
          ..write('id: $id, ')
          ..write('sessionUuid: $sessionUuid, ')
          ..write('playerId: $playerId, ')
          ..write('status: $status, ')
          ..write('lateMinutes: $lateMinutes, ')
          ..write('reason: $reason, ')
          ..write('notes: $notes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AuditLogsTable extends AuditLogs
    with TableInfo<$AuditLogsTable, AuditLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AuditLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sessionUuidMeta = const VerificationMeta(
    'sessionUuid',
  );
  @override
  late final GeneratedColumn<String> sessionUuid = GeneratedColumn<String>(
    'session_uuid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sessions (session_uuid)',
    ),
  );
  static const VerificationMeta _actionMeta = const VerificationMeta('action');
  @override
  late final GeneratedColumn<String> action = GeneratedColumn<String>(
    'action',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modifiedByMeta = const VerificationMeta(
    'modifiedBy',
  );
  @override
  late final GeneratedColumn<String> modifiedBy = GeneratedColumn<String>(
    'modified_by',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
    'reason',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
    'timestamp',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _diffMeta = const VerificationMeta('diff');
  @override
  late final GeneratedColumn<String> diff = GeneratedColumn<String>(
    'diff',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionUuid,
    action,
    modifiedBy,
    reason,
    timestamp,
    diff,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'audit_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<AuditLog> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('session_uuid')) {
      context.handle(
        _sessionUuidMeta,
        sessionUuid.isAcceptableOrUnknown(
          data['session_uuid']!,
          _sessionUuidMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sessionUuidMeta);
    }
    if (data.containsKey('action')) {
      context.handle(
        _actionMeta,
        action.isAcceptableOrUnknown(data['action']!, _actionMeta),
      );
    } else if (isInserting) {
      context.missing(_actionMeta);
    }
    if (data.containsKey('modified_by')) {
      context.handle(
        _modifiedByMeta,
        modifiedBy.isAcceptableOrUnknown(data['modified_by']!, _modifiedByMeta),
      );
    } else if (isInserting) {
      context.missing(_modifiedByMeta);
    }
    if (data.containsKey('reason')) {
      context.handle(
        _reasonMeta,
        reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta),
      );
    } else if (isInserting) {
      context.missing(_reasonMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('diff')) {
      context.handle(
        _diffMeta,
        diff.isAcceptableOrUnknown(data['diff']!, _diffMeta),
      );
    } else if (isInserting) {
      context.missing(_diffMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AuditLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AuditLog(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      sessionUuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_uuid'],
      )!,
      action: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}action'],
      )!,
      modifiedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}modified_by'],
      )!,
      reason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reason'],
      )!,
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}timestamp'],
      )!,
      diff: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}diff'],
      )!,
    );
  }

  @override
  $AuditLogsTable createAlias(String alias) {
    return $AuditLogsTable(attachedDatabase, alias);
  }
}

class AuditLog extends DataClass implements Insertable<AuditLog> {
  final String id;
  final String sessionUuid;
  final String action;
  final String modifiedBy;
  final String reason;
  final DateTime timestamp;
  final String diff;
  const AuditLog({
    required this.id,
    required this.sessionUuid,
    required this.action,
    required this.modifiedBy,
    required this.reason,
    required this.timestamp,
    required this.diff,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['session_uuid'] = Variable<String>(sessionUuid);
    map['action'] = Variable<String>(action);
    map['modified_by'] = Variable<String>(modifiedBy);
    map['reason'] = Variable<String>(reason);
    map['timestamp'] = Variable<DateTime>(timestamp);
    map['diff'] = Variable<String>(diff);
    return map;
  }

  AuditLogsCompanion toCompanion(bool nullToAbsent) {
    return AuditLogsCompanion(
      id: Value(id),
      sessionUuid: Value(sessionUuid),
      action: Value(action),
      modifiedBy: Value(modifiedBy),
      reason: Value(reason),
      timestamp: Value(timestamp),
      diff: Value(diff),
    );
  }

  factory AuditLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AuditLog(
      id: serializer.fromJson<String>(json['id']),
      sessionUuid: serializer.fromJson<String>(json['sessionUuid']),
      action: serializer.fromJson<String>(json['action']),
      modifiedBy: serializer.fromJson<String>(json['modifiedBy']),
      reason: serializer.fromJson<String>(json['reason']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
      diff: serializer.fromJson<String>(json['diff']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sessionUuid': serializer.toJson<String>(sessionUuid),
      'action': serializer.toJson<String>(action),
      'modifiedBy': serializer.toJson<String>(modifiedBy),
      'reason': serializer.toJson<String>(reason),
      'timestamp': serializer.toJson<DateTime>(timestamp),
      'diff': serializer.toJson<String>(diff),
    };
  }

  AuditLog copyWith({
    String? id,
    String? sessionUuid,
    String? action,
    String? modifiedBy,
    String? reason,
    DateTime? timestamp,
    String? diff,
  }) => AuditLog(
    id: id ?? this.id,
    sessionUuid: sessionUuid ?? this.sessionUuid,
    action: action ?? this.action,
    modifiedBy: modifiedBy ?? this.modifiedBy,
    reason: reason ?? this.reason,
    timestamp: timestamp ?? this.timestamp,
    diff: diff ?? this.diff,
  );
  AuditLog copyWithCompanion(AuditLogsCompanion data) {
    return AuditLog(
      id: data.id.present ? data.id.value : this.id,
      sessionUuid: data.sessionUuid.present
          ? data.sessionUuid.value
          : this.sessionUuid,
      action: data.action.present ? data.action.value : this.action,
      modifiedBy: data.modifiedBy.present
          ? data.modifiedBy.value
          : this.modifiedBy,
      reason: data.reason.present ? data.reason.value : this.reason,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      diff: data.diff.present ? data.diff.value : this.diff,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AuditLog(')
          ..write('id: $id, ')
          ..write('sessionUuid: $sessionUuid, ')
          ..write('action: $action, ')
          ..write('modifiedBy: $modifiedBy, ')
          ..write('reason: $reason, ')
          ..write('timestamp: $timestamp, ')
          ..write('diff: $diff')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, sessionUuid, action, modifiedBy, reason, timestamp, diff);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AuditLog &&
          other.id == this.id &&
          other.sessionUuid == this.sessionUuid &&
          other.action == this.action &&
          other.modifiedBy == this.modifiedBy &&
          other.reason == this.reason &&
          other.timestamp == this.timestamp &&
          other.diff == this.diff);
}

class AuditLogsCompanion extends UpdateCompanion<AuditLog> {
  final Value<String> id;
  final Value<String> sessionUuid;
  final Value<String> action;
  final Value<String> modifiedBy;
  final Value<String> reason;
  final Value<DateTime> timestamp;
  final Value<String> diff;
  final Value<int> rowid;
  const AuditLogsCompanion({
    this.id = const Value.absent(),
    this.sessionUuid = const Value.absent(),
    this.action = const Value.absent(),
    this.modifiedBy = const Value.absent(),
    this.reason = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.diff = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AuditLogsCompanion.insert({
    required String id,
    required String sessionUuid,
    required String action,
    required String modifiedBy,
    required String reason,
    required DateTime timestamp,
    required String diff,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       sessionUuid = Value(sessionUuid),
       action = Value(action),
       modifiedBy = Value(modifiedBy),
       reason = Value(reason),
       timestamp = Value(timestamp),
       diff = Value(diff);
  static Insertable<AuditLog> custom({
    Expression<String>? id,
    Expression<String>? sessionUuid,
    Expression<String>? action,
    Expression<String>? modifiedBy,
    Expression<String>? reason,
    Expression<DateTime>? timestamp,
    Expression<String>? diff,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionUuid != null) 'session_uuid': sessionUuid,
      if (action != null) 'action': action,
      if (modifiedBy != null) 'modified_by': modifiedBy,
      if (reason != null) 'reason': reason,
      if (timestamp != null) 'timestamp': timestamp,
      if (diff != null) 'diff': diff,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AuditLogsCompanion copyWith({
    Value<String>? id,
    Value<String>? sessionUuid,
    Value<String>? action,
    Value<String>? modifiedBy,
    Value<String>? reason,
    Value<DateTime>? timestamp,
    Value<String>? diff,
    Value<int>? rowid,
  }) {
    return AuditLogsCompanion(
      id: id ?? this.id,
      sessionUuid: sessionUuid ?? this.sessionUuid,
      action: action ?? this.action,
      modifiedBy: modifiedBy ?? this.modifiedBy,
      reason: reason ?? this.reason,
      timestamp: timestamp ?? this.timestamp,
      diff: diff ?? this.diff,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sessionUuid.present) {
      map['session_uuid'] = Variable<String>(sessionUuid.value);
    }
    if (action.present) {
      map['action'] = Variable<String>(action.value);
    }
    if (modifiedBy.present) {
      map['modified_by'] = Variable<String>(modifiedBy.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (diff.present) {
      map['diff'] = Variable<String>(diff.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AuditLogsCompanion(')
          ..write('id: $id, ')
          ..write('sessionUuid: $sessionUuid, ')
          ..write('action: $action, ')
          ..write('modifiedBy: $modifiedBy, ')
          ..write('reason: $reason, ')
          ..write('timestamp: $timestamp, ')
          ..write('diff: $diff, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncAuditLogsTable extends SyncAuditLogs
    with TableInfo<$SyncAuditLogsTable, SyncAuditLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncAuditLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sessionUuidMeta = const VerificationMeta(
    'sessionUuid',
  );
  @override
  late final GeneratedColumn<String> sessionUuid = GeneratedColumn<String>(
    'session_uuid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncDirectionMeta = const VerificationMeta(
    'syncDirection',
  );
  @override
  late final GeneratedColumn<String> syncDirection = GeneratedColumn<String>(
    'sync_direction',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncChannelMeta = const VerificationMeta(
    'syncChannel',
  );
  @override
  late final GeneratedColumn<String> syncChannel = GeneratedColumn<String>(
    'sync_channel',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceDeviceIdMeta = const VerificationMeta(
    'sourceDeviceId',
  );
  @override
  late final GeneratedColumn<String> sourceDeviceId = GeneratedColumn<String>(
    'source_device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetDeviceIdMeta = const VerificationMeta(
    'targetDeviceId',
  );
  @override
  late final GeneratedColumn<String> targetDeviceId = GeneratedColumn<String>(
    'target_device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> syncedAt = GeneratedColumn<DateTime>(
    'synced_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionUuid,
    syncDirection,
    syncChannel,
    sourceDeviceId,
    targetDeviceId,
    syncedAt,
    status,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_audit_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncAuditLog> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('session_uuid')) {
      context.handle(
        _sessionUuidMeta,
        sessionUuid.isAcceptableOrUnknown(
          data['session_uuid']!,
          _sessionUuidMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sessionUuidMeta);
    }
    if (data.containsKey('sync_direction')) {
      context.handle(
        _syncDirectionMeta,
        syncDirection.isAcceptableOrUnknown(
          data['sync_direction']!,
          _syncDirectionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_syncDirectionMeta);
    }
    if (data.containsKey('sync_channel')) {
      context.handle(
        _syncChannelMeta,
        syncChannel.isAcceptableOrUnknown(
          data['sync_channel']!,
          _syncChannelMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_syncChannelMeta);
    }
    if (data.containsKey('source_device_id')) {
      context.handle(
        _sourceDeviceIdMeta,
        sourceDeviceId.isAcceptableOrUnknown(
          data['source_device_id']!,
          _sourceDeviceIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sourceDeviceIdMeta);
    }
    if (data.containsKey('target_device_id')) {
      context.handle(
        _targetDeviceIdMeta,
        targetDeviceId.isAcceptableOrUnknown(
          data['target_device_id']!,
          _targetDeviceIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_targetDeviceIdMeta);
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_syncedAtMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncAuditLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncAuditLog(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      sessionUuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_uuid'],
      )!,
      syncDirection: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_direction'],
      )!,
      syncChannel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_channel'],
      )!,
      sourceDeviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_device_id'],
      )!,
      targetDeviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_device_id'],
      )!,
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}synced_at'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
    );
  }

  @override
  $SyncAuditLogsTable createAlias(String alias) {
    return $SyncAuditLogsTable(attachedDatabase, alias);
  }
}

class SyncAuditLog extends DataClass implements Insertable<SyncAuditLog> {
  final String id;
  final String sessionUuid;
  final String syncDirection;
  final String syncChannel;
  final String sourceDeviceId;
  final String targetDeviceId;
  final DateTime syncedAt;
  final String status;
  const SyncAuditLog({
    required this.id,
    required this.sessionUuid,
    required this.syncDirection,
    required this.syncChannel,
    required this.sourceDeviceId,
    required this.targetDeviceId,
    required this.syncedAt,
    required this.status,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['session_uuid'] = Variable<String>(sessionUuid);
    map['sync_direction'] = Variable<String>(syncDirection);
    map['sync_channel'] = Variable<String>(syncChannel);
    map['source_device_id'] = Variable<String>(sourceDeviceId);
    map['target_device_id'] = Variable<String>(targetDeviceId);
    map['synced_at'] = Variable<DateTime>(syncedAt);
    map['status'] = Variable<String>(status);
    return map;
  }

  SyncAuditLogsCompanion toCompanion(bool nullToAbsent) {
    return SyncAuditLogsCompanion(
      id: Value(id),
      sessionUuid: Value(sessionUuid),
      syncDirection: Value(syncDirection),
      syncChannel: Value(syncChannel),
      sourceDeviceId: Value(sourceDeviceId),
      targetDeviceId: Value(targetDeviceId),
      syncedAt: Value(syncedAt),
      status: Value(status),
    );
  }

  factory SyncAuditLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncAuditLog(
      id: serializer.fromJson<String>(json['id']),
      sessionUuid: serializer.fromJson<String>(json['sessionUuid']),
      syncDirection: serializer.fromJson<String>(json['syncDirection']),
      syncChannel: serializer.fromJson<String>(json['syncChannel']),
      sourceDeviceId: serializer.fromJson<String>(json['sourceDeviceId']),
      targetDeviceId: serializer.fromJson<String>(json['targetDeviceId']),
      syncedAt: serializer.fromJson<DateTime>(json['syncedAt']),
      status: serializer.fromJson<String>(json['status']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sessionUuid': serializer.toJson<String>(sessionUuid),
      'syncDirection': serializer.toJson<String>(syncDirection),
      'syncChannel': serializer.toJson<String>(syncChannel),
      'sourceDeviceId': serializer.toJson<String>(sourceDeviceId),
      'targetDeviceId': serializer.toJson<String>(targetDeviceId),
      'syncedAt': serializer.toJson<DateTime>(syncedAt),
      'status': serializer.toJson<String>(status),
    };
  }

  SyncAuditLog copyWith({
    String? id,
    String? sessionUuid,
    String? syncDirection,
    String? syncChannel,
    String? sourceDeviceId,
    String? targetDeviceId,
    DateTime? syncedAt,
    String? status,
  }) => SyncAuditLog(
    id: id ?? this.id,
    sessionUuid: sessionUuid ?? this.sessionUuid,
    syncDirection: syncDirection ?? this.syncDirection,
    syncChannel: syncChannel ?? this.syncChannel,
    sourceDeviceId: sourceDeviceId ?? this.sourceDeviceId,
    targetDeviceId: targetDeviceId ?? this.targetDeviceId,
    syncedAt: syncedAt ?? this.syncedAt,
    status: status ?? this.status,
  );
  SyncAuditLog copyWithCompanion(SyncAuditLogsCompanion data) {
    return SyncAuditLog(
      id: data.id.present ? data.id.value : this.id,
      sessionUuid: data.sessionUuid.present
          ? data.sessionUuid.value
          : this.sessionUuid,
      syncDirection: data.syncDirection.present
          ? data.syncDirection.value
          : this.syncDirection,
      syncChannel: data.syncChannel.present
          ? data.syncChannel.value
          : this.syncChannel,
      sourceDeviceId: data.sourceDeviceId.present
          ? data.sourceDeviceId.value
          : this.sourceDeviceId,
      targetDeviceId: data.targetDeviceId.present
          ? data.targetDeviceId.value
          : this.targetDeviceId,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
      status: data.status.present ? data.status.value : this.status,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncAuditLog(')
          ..write('id: $id, ')
          ..write('sessionUuid: $sessionUuid, ')
          ..write('syncDirection: $syncDirection, ')
          ..write('syncChannel: $syncChannel, ')
          ..write('sourceDeviceId: $sourceDeviceId, ')
          ..write('targetDeviceId: $targetDeviceId, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sessionUuid,
    syncDirection,
    syncChannel,
    sourceDeviceId,
    targetDeviceId,
    syncedAt,
    status,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncAuditLog &&
          other.id == this.id &&
          other.sessionUuid == this.sessionUuid &&
          other.syncDirection == this.syncDirection &&
          other.syncChannel == this.syncChannel &&
          other.sourceDeviceId == this.sourceDeviceId &&
          other.targetDeviceId == this.targetDeviceId &&
          other.syncedAt == this.syncedAt &&
          other.status == this.status);
}

class SyncAuditLogsCompanion extends UpdateCompanion<SyncAuditLog> {
  final Value<String> id;
  final Value<String> sessionUuid;
  final Value<String> syncDirection;
  final Value<String> syncChannel;
  final Value<String> sourceDeviceId;
  final Value<String> targetDeviceId;
  final Value<DateTime> syncedAt;
  final Value<String> status;
  final Value<int> rowid;
  const SyncAuditLogsCompanion({
    this.id = const Value.absent(),
    this.sessionUuid = const Value.absent(),
    this.syncDirection = const Value.absent(),
    this.syncChannel = const Value.absent(),
    this.sourceDeviceId = const Value.absent(),
    this.targetDeviceId = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.status = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncAuditLogsCompanion.insert({
    required String id,
    required String sessionUuid,
    required String syncDirection,
    required String syncChannel,
    required String sourceDeviceId,
    required String targetDeviceId,
    required DateTime syncedAt,
    required String status,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       sessionUuid = Value(sessionUuid),
       syncDirection = Value(syncDirection),
       syncChannel = Value(syncChannel),
       sourceDeviceId = Value(sourceDeviceId),
       targetDeviceId = Value(targetDeviceId),
       syncedAt = Value(syncedAt),
       status = Value(status);
  static Insertable<SyncAuditLog> custom({
    Expression<String>? id,
    Expression<String>? sessionUuid,
    Expression<String>? syncDirection,
    Expression<String>? syncChannel,
    Expression<String>? sourceDeviceId,
    Expression<String>? targetDeviceId,
    Expression<DateTime>? syncedAt,
    Expression<String>? status,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionUuid != null) 'session_uuid': sessionUuid,
      if (syncDirection != null) 'sync_direction': syncDirection,
      if (syncChannel != null) 'sync_channel': syncChannel,
      if (sourceDeviceId != null) 'source_device_id': sourceDeviceId,
      if (targetDeviceId != null) 'target_device_id': targetDeviceId,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (status != null) 'status': status,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncAuditLogsCompanion copyWith({
    Value<String>? id,
    Value<String>? sessionUuid,
    Value<String>? syncDirection,
    Value<String>? syncChannel,
    Value<String>? sourceDeviceId,
    Value<String>? targetDeviceId,
    Value<DateTime>? syncedAt,
    Value<String>? status,
    Value<int>? rowid,
  }) {
    return SyncAuditLogsCompanion(
      id: id ?? this.id,
      sessionUuid: sessionUuid ?? this.sessionUuid,
      syncDirection: syncDirection ?? this.syncDirection,
      syncChannel: syncChannel ?? this.syncChannel,
      sourceDeviceId: sourceDeviceId ?? this.sourceDeviceId,
      targetDeviceId: targetDeviceId ?? this.targetDeviceId,
      syncedAt: syncedAt ?? this.syncedAt,
      status: status ?? this.status,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sessionUuid.present) {
      map['session_uuid'] = Variable<String>(sessionUuid.value);
    }
    if (syncDirection.present) {
      map['sync_direction'] = Variable<String>(syncDirection.value);
    }
    if (syncChannel.present) {
      map['sync_channel'] = Variable<String>(syncChannel.value);
    }
    if (sourceDeviceId.present) {
      map['source_device_id'] = Variable<String>(sourceDeviceId.value);
    }
    if (targetDeviceId.present) {
      map['target_device_id'] = Variable<String>(targetDeviceId.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<DateTime>(syncedAt.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncAuditLogsCompanion(')
          ..write('id: $id, ')
          ..write('sessionUuid: $sessionUuid, ')
          ..write('syncDirection: $syncDirection, ')
          ..write('syncChannel: $syncChannel, ')
          ..write('sourceDeviceId: $sourceDeviceId, ')
          ..write('targetDeviceId: $targetDeviceId, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('status: $status, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $LicenseSecurityStoreTable licenseSecurityStore =
      $LicenseSecurityStoreTable(this);
  late final $ClubSettingsTable clubSettings = $ClubSettingsTable(this);
  late final $TeamsTable teams = $TeamsTable(this);
  late final $PlayersTable players = $PlayersTable(this);
  late final $SessionsTable sessions = $SessionsTable(this);
  late final $AttendanceRecordsTable attendanceRecords =
      $AttendanceRecordsTable(this);
  late final $AuditLogsTable auditLogs = $AuditLogsTable(this);
  late final $SyncAuditLogsTable syncAuditLogs = $SyncAuditLogsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    licenseSecurityStore,
    clubSettings,
    teams,
    players,
    sessions,
    attendanceRecords,
    auditLogs,
    syncAuditLogs,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'sessions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('attendance_records', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$LicenseSecurityStoreTableCreateCompanionBuilder =
    LicenseSecurityStoreCompanion Function({
      required String deviceId,
      required String deviceMode,
      Value<String?> pairedDeviceId,
      required String licenseKey,
      required String clubName,
      Value<String?> teamName,
      required String packageType,
      required DateTime activatedAt,
      required DateTime expiresAt,
      required DateTime highWatermarkTimestamp,
      Value<int> cumulativeRuntimeMinutes,
      Value<bool> tamperFlag,
      required String signatureProof,
      Value<int> rowid,
    });
typedef $$LicenseSecurityStoreTableUpdateCompanionBuilder =
    LicenseSecurityStoreCompanion Function({
      Value<String> deviceId,
      Value<String> deviceMode,
      Value<String?> pairedDeviceId,
      Value<String> licenseKey,
      Value<String> clubName,
      Value<String?> teamName,
      Value<String> packageType,
      Value<DateTime> activatedAt,
      Value<DateTime> expiresAt,
      Value<DateTime> highWatermarkTimestamp,
      Value<int> cumulativeRuntimeMinutes,
      Value<bool> tamperFlag,
      Value<String> signatureProof,
      Value<int> rowid,
    });

class $$LicenseSecurityStoreTableFilterComposer
    extends Composer<_$AppDatabase, $LicenseSecurityStoreTable> {
  $$LicenseSecurityStoreTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceMode => $composableBuilder(
    column: $table.deviceMode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pairedDeviceId => $composableBuilder(
    column: $table.pairedDeviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get licenseKey => $composableBuilder(
    column: $table.licenseKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get clubName => $composableBuilder(
    column: $table.clubName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get teamName => $composableBuilder(
    column: $table.teamName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get packageType => $composableBuilder(
    column: $table.packageType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get activatedAt => $composableBuilder(
    column: $table.activatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get expiresAt => $composableBuilder(
    column: $table.expiresAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get highWatermarkTimestamp => $composableBuilder(
    column: $table.highWatermarkTimestamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cumulativeRuntimeMinutes => $composableBuilder(
    column: $table.cumulativeRuntimeMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get tamperFlag => $composableBuilder(
    column: $table.tamperFlag,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get signatureProof => $composableBuilder(
    column: $table.signatureProof,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LicenseSecurityStoreTableOrderingComposer
    extends Composer<_$AppDatabase, $LicenseSecurityStoreTable> {
  $$LicenseSecurityStoreTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceMode => $composableBuilder(
    column: $table.deviceMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pairedDeviceId => $composableBuilder(
    column: $table.pairedDeviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get licenseKey => $composableBuilder(
    column: $table.licenseKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get clubName => $composableBuilder(
    column: $table.clubName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get teamName => $composableBuilder(
    column: $table.teamName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get packageType => $composableBuilder(
    column: $table.packageType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get activatedAt => $composableBuilder(
    column: $table.activatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get expiresAt => $composableBuilder(
    column: $table.expiresAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get highWatermarkTimestamp => $composableBuilder(
    column: $table.highWatermarkTimestamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cumulativeRuntimeMinutes => $composableBuilder(
    column: $table.cumulativeRuntimeMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get tamperFlag => $composableBuilder(
    column: $table.tamperFlag,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get signatureProof => $composableBuilder(
    column: $table.signatureProof,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LicenseSecurityStoreTableAnnotationComposer
    extends Composer<_$AppDatabase, $LicenseSecurityStoreTable> {
  $$LicenseSecurityStoreTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get deviceMode => $composableBuilder(
    column: $table.deviceMode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get pairedDeviceId => $composableBuilder(
    column: $table.pairedDeviceId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get licenseKey => $composableBuilder(
    column: $table.licenseKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get clubName =>
      $composableBuilder(column: $table.clubName, builder: (column) => column);

  GeneratedColumn<String> get teamName =>
      $composableBuilder(column: $table.teamName, builder: (column) => column);

  GeneratedColumn<String> get packageType => $composableBuilder(
    column: $table.packageType,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get activatedAt => $composableBuilder(
    column: $table.activatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get expiresAt =>
      $composableBuilder(column: $table.expiresAt, builder: (column) => column);

  GeneratedColumn<DateTime> get highWatermarkTimestamp => $composableBuilder(
    column: $table.highWatermarkTimestamp,
    builder: (column) => column,
  );

  GeneratedColumn<int> get cumulativeRuntimeMinutes => $composableBuilder(
    column: $table.cumulativeRuntimeMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get tamperFlag => $composableBuilder(
    column: $table.tamperFlag,
    builder: (column) => column,
  );

  GeneratedColumn<String> get signatureProof => $composableBuilder(
    column: $table.signatureProof,
    builder: (column) => column,
  );
}

class $$LicenseSecurityStoreTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LicenseSecurityStoreTable,
          LicenseSecurityStoreData,
          $$LicenseSecurityStoreTableFilterComposer,
          $$LicenseSecurityStoreTableOrderingComposer,
          $$LicenseSecurityStoreTableAnnotationComposer,
          $$LicenseSecurityStoreTableCreateCompanionBuilder,
          $$LicenseSecurityStoreTableUpdateCompanionBuilder,
          (
            LicenseSecurityStoreData,
            BaseReferences<
              _$AppDatabase,
              $LicenseSecurityStoreTable,
              LicenseSecurityStoreData
            >,
          ),
          LicenseSecurityStoreData,
          PrefetchHooks Function()
        > {
  $$LicenseSecurityStoreTableTableManager(
    _$AppDatabase db,
    $LicenseSecurityStoreTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LicenseSecurityStoreTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LicenseSecurityStoreTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$LicenseSecurityStoreTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> deviceId = const Value.absent(),
                Value<String> deviceMode = const Value.absent(),
                Value<String?> pairedDeviceId = const Value.absent(),
                Value<String> licenseKey = const Value.absent(),
                Value<String> clubName = const Value.absent(),
                Value<String?> teamName = const Value.absent(),
                Value<String> packageType = const Value.absent(),
                Value<DateTime> activatedAt = const Value.absent(),
                Value<DateTime> expiresAt = const Value.absent(),
                Value<DateTime> highWatermarkTimestamp = const Value.absent(),
                Value<int> cumulativeRuntimeMinutes = const Value.absent(),
                Value<bool> tamperFlag = const Value.absent(),
                Value<String> signatureProof = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LicenseSecurityStoreCompanion(
                deviceId: deviceId,
                deviceMode: deviceMode,
                pairedDeviceId: pairedDeviceId,
                licenseKey: licenseKey,
                clubName: clubName,
                teamName: teamName,
                packageType: packageType,
                activatedAt: activatedAt,
                expiresAt: expiresAt,
                highWatermarkTimestamp: highWatermarkTimestamp,
                cumulativeRuntimeMinutes: cumulativeRuntimeMinutes,
                tamperFlag: tamperFlag,
                signatureProof: signatureProof,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String deviceId,
                required String deviceMode,
                Value<String?> pairedDeviceId = const Value.absent(),
                required String licenseKey,
                required String clubName,
                Value<String?> teamName = const Value.absent(),
                required String packageType,
                required DateTime activatedAt,
                required DateTime expiresAt,
                required DateTime highWatermarkTimestamp,
                Value<int> cumulativeRuntimeMinutes = const Value.absent(),
                Value<bool> tamperFlag = const Value.absent(),
                required String signatureProof,
                Value<int> rowid = const Value.absent(),
              }) => LicenseSecurityStoreCompanion.insert(
                deviceId: deviceId,
                deviceMode: deviceMode,
                pairedDeviceId: pairedDeviceId,
                licenseKey: licenseKey,
                clubName: clubName,
                teamName: teamName,
                packageType: packageType,
                activatedAt: activatedAt,
                expiresAt: expiresAt,
                highWatermarkTimestamp: highWatermarkTimestamp,
                cumulativeRuntimeMinutes: cumulativeRuntimeMinutes,
                tamperFlag: tamperFlag,
                signatureProof: signatureProof,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<
                    $LicenseSecurityStoreTable,
                    LicenseSecurityStoreData
                  >(table),
                  BaseReferences<
                    _$AppDatabase,
                    $LicenseSecurityStoreTable,
                    LicenseSecurityStoreData
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LicenseSecurityStoreTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LicenseSecurityStoreTable,
      LicenseSecurityStoreData,
      $$LicenseSecurityStoreTableFilterComposer,
      $$LicenseSecurityStoreTableOrderingComposer,
      $$LicenseSecurityStoreTableAnnotationComposer,
      $$LicenseSecurityStoreTableCreateCompanionBuilder,
      $$LicenseSecurityStoreTableUpdateCompanionBuilder,
      (
        LicenseSecurityStoreData,
        BaseReferences<
          _$AppDatabase,
          $LicenseSecurityStoreTable,
          LicenseSecurityStoreData
        >,
      ),
      LicenseSecurityStoreData,
      PrefetchHooks Function()
    >;
typedef $$ClubSettingsTableCreateCompanionBuilder =
    ClubSettingsCompanion Function({
      Value<int> id,
      required String clubName,
      Value<String?> logoPath,
      required String season,
      Value<String?> adminName,
      Value<String?> managerName,
      Value<String?> pinCodeHash,
      Value<bool> entitlementSportEnabled,
      Value<bool> entitlementCountsExcused,
    });
typedef $$ClubSettingsTableUpdateCompanionBuilder =
    ClubSettingsCompanion Function({
      Value<int> id,
      Value<String> clubName,
      Value<String?> logoPath,
      Value<String> season,
      Value<String?> adminName,
      Value<String?> managerName,
      Value<String?> pinCodeHash,
      Value<bool> entitlementSportEnabled,
      Value<bool> entitlementCountsExcused,
    });

class $$ClubSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $ClubSettingsTable> {
  $$ClubSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get clubName => $composableBuilder(
    column: $table.clubName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get logoPath => $composableBuilder(
    column: $table.logoPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get season => $composableBuilder(
    column: $table.season,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get adminName => $composableBuilder(
    column: $table.adminName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get managerName => $composableBuilder(
    column: $table.managerName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pinCodeHash => $composableBuilder(
    column: $table.pinCodeHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get entitlementSportEnabled => $composableBuilder(
    column: $table.entitlementSportEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get entitlementCountsExcused => $composableBuilder(
    column: $table.entitlementCountsExcused,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ClubSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $ClubSettingsTable> {
  $$ClubSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get clubName => $composableBuilder(
    column: $table.clubName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get logoPath => $composableBuilder(
    column: $table.logoPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get season => $composableBuilder(
    column: $table.season,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get adminName => $composableBuilder(
    column: $table.adminName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get managerName => $composableBuilder(
    column: $table.managerName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pinCodeHash => $composableBuilder(
    column: $table.pinCodeHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get entitlementSportEnabled => $composableBuilder(
    column: $table.entitlementSportEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get entitlementCountsExcused => $composableBuilder(
    column: $table.entitlementCountsExcused,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ClubSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ClubSettingsTable> {
  $$ClubSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get clubName =>
      $composableBuilder(column: $table.clubName, builder: (column) => column);

  GeneratedColumn<String> get logoPath =>
      $composableBuilder(column: $table.logoPath, builder: (column) => column);

  GeneratedColumn<String> get season =>
      $composableBuilder(column: $table.season, builder: (column) => column);

  GeneratedColumn<String> get adminName =>
      $composableBuilder(column: $table.adminName, builder: (column) => column);

  GeneratedColumn<String> get managerName => $composableBuilder(
    column: $table.managerName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get pinCodeHash => $composableBuilder(
    column: $table.pinCodeHash,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get entitlementSportEnabled => $composableBuilder(
    column: $table.entitlementSportEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get entitlementCountsExcused => $composableBuilder(
    column: $table.entitlementCountsExcused,
    builder: (column) => column,
  );
}

class $$ClubSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ClubSettingsTable,
          ClubSetting,
          $$ClubSettingsTableFilterComposer,
          $$ClubSettingsTableOrderingComposer,
          $$ClubSettingsTableAnnotationComposer,
          $$ClubSettingsTableCreateCompanionBuilder,
          $$ClubSettingsTableUpdateCompanionBuilder,
          (
            ClubSetting,
            BaseReferences<_$AppDatabase, $ClubSettingsTable, ClubSetting>,
          ),
          ClubSetting,
          PrefetchHooks Function()
        > {
  $$ClubSettingsTableTableManager(_$AppDatabase db, $ClubSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ClubSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ClubSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ClubSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> clubName = const Value.absent(),
                Value<String?> logoPath = const Value.absent(),
                Value<String> season = const Value.absent(),
                Value<String?> adminName = const Value.absent(),
                Value<String?> managerName = const Value.absent(),
                Value<String?> pinCodeHash = const Value.absent(),
                Value<bool> entitlementSportEnabled = const Value.absent(),
                Value<bool> entitlementCountsExcused = const Value.absent(),
              }) => ClubSettingsCompanion(
                id: id,
                clubName: clubName,
                logoPath: logoPath,
                season: season,
                adminName: adminName,
                managerName: managerName,
                pinCodeHash: pinCodeHash,
                entitlementSportEnabled: entitlementSportEnabled,
                entitlementCountsExcused: entitlementCountsExcused,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String clubName,
                Value<String?> logoPath = const Value.absent(),
                required String season,
                Value<String?> adminName = const Value.absent(),
                Value<String?> managerName = const Value.absent(),
                Value<String?> pinCodeHash = const Value.absent(),
                Value<bool> entitlementSportEnabled = const Value.absent(),
                Value<bool> entitlementCountsExcused = const Value.absent(),
              }) => ClubSettingsCompanion.insert(
                id: id,
                clubName: clubName,
                logoPath: logoPath,
                season: season,
                adminName: adminName,
                managerName: managerName,
                pinCodeHash: pinCodeHash,
                entitlementSportEnabled: entitlementSportEnabled,
                entitlementCountsExcused: entitlementCountsExcused,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ClubSettingsTable, ClubSetting>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $ClubSettingsTable,
                    ClubSetting
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ClubSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ClubSettingsTable,
      ClubSetting,
      $$ClubSettingsTableFilterComposer,
      $$ClubSettingsTableOrderingComposer,
      $$ClubSettingsTableAnnotationComposer,
      $$ClubSettingsTableCreateCompanionBuilder,
      $$ClubSettingsTableUpdateCompanionBuilder,
      (
        ClubSetting,
        BaseReferences<_$AppDatabase, $ClubSettingsTable, ClubSetting>,
      ),
      ClubSetting,
      PrefetchHooks Function()
    >;
typedef $$TeamsTableCreateCompanionBuilder = TeamsCompanion Function({
  required String id,
  required String name,
  required String category,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$TeamsTableUpdateCompanionBuilder = TeamsCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String> category,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

final class $$TeamsTableReferences
    extends BaseReferences<_$AppDatabase, $TeamsTable, Team> {
  $$TeamsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$PlayersTable, List<Player>> _playersRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.players,
    aliasName: 'teams__id__players__team_id',
  );

  $$PlayersTableProcessedTableManager get playersRefs {
    final manager = $$PlayersTableTableManager(
      $_db,
      $_db.players,
    ).filter((f) => f.teamId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_playersRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SessionsTable, List<Session>> _sessionsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.sessions,
    aliasName: 'teams__id__sessions__team_id',
  );

  $$SessionsTableProcessedTableManager get sessionsRefs {
    final manager = $$SessionsTableTableManager(
      $_db,
      $_db.sessions,
    ).filter((f) => f.teamId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_sessionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TeamsTableFilterComposer extends Composer<_$AppDatabase, $TeamsTable> {
  $$TeamsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> playersRefs(
    Expression<bool> Function($$PlayersTableFilterComposer f) f,
  ) {
    final $$PlayersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.players,
      getReferencedColumn: (t) => t.teamId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlayersTableFilterComposer(
            $db: $db,
            $table: $db.players,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> sessionsRefs(
    Expression<bool> Function($$SessionsTableFilterComposer f) f,
  ) {
    final $$SessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.teamId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableFilterComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TeamsTableOrderingComposer
    extends Composer<_$AppDatabase, $TeamsTable> {
  $$TeamsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TeamsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TeamsTable> {
  $$TeamsTableAnnotationComposer({
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

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> playersRefs<T extends Object>(
    Expression<T> Function($$PlayersTableAnnotationComposer a) f,
  ) {
    final $$PlayersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.players,
      getReferencedColumn: (t) => t.teamId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlayersTableAnnotationComposer(
            $db: $db,
            $table: $db.players,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> sessionsRefs<T extends Object>(
    Expression<T> Function($$SessionsTableAnnotationComposer a) f,
  ) {
    final $$SessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.teamId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TeamsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TeamsTable,
          Team,
          $$TeamsTableFilterComposer,
          $$TeamsTableOrderingComposer,
          $$TeamsTableAnnotationComposer,
          $$TeamsTableCreateCompanionBuilder,
          $$TeamsTableUpdateCompanionBuilder,
          (Team, $$TeamsTableReferences),
          Team,
          PrefetchHooks Function({bool playersRefs, bool sessionsRefs})
        > {
  $$TeamsTableTableManager(_$AppDatabase db, $TeamsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TeamsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TeamsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TeamsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TeamsCompanion(
                id: id,
                name: name,
                category: category,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String category,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => TeamsCompanion.insert(
                id: id,
                name: name,
                category: category,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TeamsTable, Team>(table),
                  $$TeamsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({playersRefs = false, sessionsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (playersRefs) db.players,
                if (sessionsRefs) db.sessions,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (playersRefs)
                    await $_getPrefetchedData<Team, $TeamsTable, Player>(
                      currentTable: table,
                      referencedTable: $$TeamsTableReferences._playersRefsTable(
                        db,
                      ),
                      managerFromTypedResult: (p0) =>
                          $$TeamsTableReferences(db, table, p0).playersRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.teamId == item.id),
                      typedResults: items,
                    ),
                  if (sessionsRefs)
                    await $_getPrefetchedData<Team, $TeamsTable, Session>(
                      currentTable: table,
                      referencedTable: $$TeamsTableReferences
                          ._sessionsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$TeamsTableReferences(db, table, p0).sessionsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.teamId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$TeamsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TeamsTable,
      Team,
      $$TeamsTableFilterComposer,
      $$TeamsTableOrderingComposer,
      $$TeamsTableAnnotationComposer,
      $$TeamsTableCreateCompanionBuilder,
      $$TeamsTableUpdateCompanionBuilder,
      (Team, $$TeamsTableReferences),
      Team,
      PrefetchHooks Function({bool playersRefs, bool sessionsRefs})
    >;
typedef $$PlayersTableCreateCompanionBuilder = PlayersCompanion Function({
  required String id,
  required String name,
  required String teamId,
  Value<int?> jerseyNumber,
  Value<String?> position,
  required DateTime joinDate,
  Value<bool> isArchived,
  Value<String?> notes,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$PlayersTableUpdateCompanionBuilder = PlayersCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String> teamId,
  Value<int?> jerseyNumber,
  Value<String?> position,
  Value<DateTime> joinDate,
  Value<bool> isArchived,
  Value<String?> notes,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

final class $$PlayersTableReferences
    extends BaseReferences<_$AppDatabase, $PlayersTable, Player> {
  $$PlayersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TeamsTable _teamIdTable(_$AppDatabase db) =>
      db.teams.createAlias('players__team_id__teams__id');

  $$TeamsTableProcessedTableManager get teamId {
    final $_column = $_itemColumn<String>('team_id')!;

    final manager = $$TeamsTableTableManager(
      $_db,
      $_db.teams,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_teamIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$AttendanceRecordsTable, List<AttendanceRecord>>
  _attendanceRecordsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.attendanceRecords,
        aliasName: 'players__id__attendance_records__player_id',
      );

  $$AttendanceRecordsTableProcessedTableManager get attendanceRecordsRefs {
    final manager = $$AttendanceRecordsTableTableManager(
      $_db,
      $_db.attendanceRecords,
    ).filter((f) => f.playerId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _attendanceRecordsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PlayersTableFilterComposer
    extends Composer<_$AppDatabase, $PlayersTable> {
  $$PlayersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get jerseyNumber => $composableBuilder(
    column: $table.jerseyNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get joinDate => $composableBuilder(
    column: $table.joinDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$TeamsTableFilterComposer get teamId {
    final $$TeamsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.teamId,
      referencedTable: $db.teams,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TeamsTableFilterComposer(
            $db: $db,
            $table: $db.teams,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> attendanceRecordsRefs(
    Expression<bool> Function($$AttendanceRecordsTableFilterComposer f) f,
  ) {
    final $$AttendanceRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.attendanceRecords,
      getReferencedColumn: (t) => t.playerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AttendanceRecordsTableFilterComposer(
            $db: $db,
            $table: $db.attendanceRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PlayersTableOrderingComposer
    extends Composer<_$AppDatabase, $PlayersTable> {
  $$PlayersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get jerseyNumber => $composableBuilder(
    column: $table.jerseyNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get joinDate => $composableBuilder(
    column: $table.joinDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$TeamsTableOrderingComposer get teamId {
    final $$TeamsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.teamId,
      referencedTable: $db.teams,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TeamsTableOrderingComposer(
            $db: $db,
            $table: $db.teams,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlayersTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlayersTable> {
  $$PlayersTableAnnotationComposer({
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

  GeneratedColumn<int> get jerseyNumber => $composableBuilder(
    column: $table.jerseyNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<DateTime> get joinDate =>
      $composableBuilder(column: $table.joinDate, builder: (column) => column);

  GeneratedColumn<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$TeamsTableAnnotationComposer get teamId {
    final $$TeamsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.teamId,
      referencedTable: $db.teams,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TeamsTableAnnotationComposer(
            $db: $db,
            $table: $db.teams,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> attendanceRecordsRefs<T extends Object>(
    Expression<T> Function($$AttendanceRecordsTableAnnotationComposer a) f,
  ) {
    final $$AttendanceRecordsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.attendanceRecords,
          getReferencedColumn: (t) => t.playerId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$AttendanceRecordsTableAnnotationComposer(
                $db: $db,
                $table: $db.attendanceRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$PlayersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlayersTable,
          Player,
          $$PlayersTableFilterComposer,
          $$PlayersTableOrderingComposer,
          $$PlayersTableAnnotationComposer,
          $$PlayersTableCreateCompanionBuilder,
          $$PlayersTableUpdateCompanionBuilder,
          (Player, $$PlayersTableReferences),
          Player,
          PrefetchHooks Function({bool teamId, bool attendanceRecordsRefs})
        > {
  $$PlayersTableTableManager(_$AppDatabase db, $PlayersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlayersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlayersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlayersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> teamId = const Value.absent(),
                Value<int?> jerseyNumber = const Value.absent(),
                Value<String?> position = const Value.absent(),
                Value<DateTime> joinDate = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlayersCompanion(
                id: id,
                name: name,
                teamId: teamId,
                jerseyNumber: jerseyNumber,
                position: position,
                joinDate: joinDate,
                isArchived: isArchived,
                notes: notes,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String teamId,
                Value<int?> jerseyNumber = const Value.absent(),
                Value<String?> position = const Value.absent(),
                required DateTime joinDate,
                Value<bool> isArchived = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => PlayersCompanion.insert(
                id: id,
                name: name,
                teamId: teamId,
                jerseyNumber: jerseyNumber,
                position: position,
                joinDate: joinDate,
                isArchived: isArchived,
                notes: notes,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PlayersTable, Player>(table),
                  $$PlayersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({teamId = false, attendanceRecordsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (attendanceRecordsRefs) db.attendanceRecords,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (teamId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.teamId,
                            referencedTable: $$PlayersTableReferences
                                ._teamIdTable(db),
                            referencedColumn: $$PlayersTableReferences
                                ._teamIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (attendanceRecordsRefs)
                        await $_getPrefetchedData<
                          Player,
                          $PlayersTable,
                          AttendanceRecord
                        >(
                          currentTable: table,
                          referencedTable: $$PlayersTableReferences
                              ._attendanceRecordsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PlayersTableReferences(
                                db,
                                table,
                                p0,
                              ).attendanceRecordsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.playerId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$PlayersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlayersTable,
      Player,
      $$PlayersTableFilterComposer,
      $$PlayersTableOrderingComposer,
      $$PlayersTableAnnotationComposer,
      $$PlayersTableCreateCompanionBuilder,
      $$PlayersTableUpdateCompanionBuilder,
      (Player, $$PlayersTableReferences),
      Player,
      PrefetchHooks Function({bool teamId, bool attendanceRecordsRefs})
    >;
typedef $$SessionsTableCreateCompanionBuilder = SessionsCompanion Function({
  required String sessionUuid,
  required String teamId,
  required DateTime sessionDate,
  Value<String> type,
  Value<String> period,
  Value<String?> location,
  Value<bool> isCancelled,
  Value<bool> countsInAttendance,
  Value<bool> isDispatched,
  Value<DateTime?> dispatchedAt,
  Value<bool> isLocked,
  Value<String> syncStatus,
  required String sessionHash,
  Value<String> status,
  Value<DateTime?> approvedAt,
  Value<String?> approvedBy,
  Value<int> rowid,
});
typedef $$SessionsTableUpdateCompanionBuilder = SessionsCompanion Function({
  Value<String> sessionUuid,
  Value<String> teamId,
  Value<DateTime> sessionDate,
  Value<String> type,
  Value<String> period,
  Value<String?> location,
  Value<bool> isCancelled,
  Value<bool> countsInAttendance,
  Value<bool> isDispatched,
  Value<DateTime?> dispatchedAt,
  Value<bool> isLocked,
  Value<String> syncStatus,
  Value<String> sessionHash,
  Value<String> status,
  Value<DateTime?> approvedAt,
  Value<String?> approvedBy,
  Value<int> rowid,
});

final class $$SessionsTableReferences
    extends BaseReferences<_$AppDatabase, $SessionsTable, Session> {
  $$SessionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TeamsTable _teamIdTable(_$AppDatabase db) =>
      db.teams.createAlias('sessions__team_id__teams__id');

  $$TeamsTableProcessedTableManager get teamId {
    final $_column = $_itemColumn<String>('team_id')!;

    final manager = $$TeamsTableTableManager(
      $_db,
      $_db.teams,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_teamIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$AttendanceRecordsTable, List<AttendanceRecord>>
  _attendanceRecordsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.attendanceRecords,
        aliasName: 'sessions__session_uuid__attendance_records__session_uuid',
      );

  $$AttendanceRecordsTableProcessedTableManager get attendanceRecordsRefs {
    final manager =
        $$AttendanceRecordsTableTableManager(
          $_db,
          $_db.attendanceRecords,
        ).filter(
          (f) => f.sessionUuid.sessionUuid.sqlEquals(
            $_itemColumn<String>('session_uuid')!,
          ),
        );

    final cache = $_typedResult.readTableOrNull(
      _attendanceRecordsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$AuditLogsTable, List<AuditLog>>
  _auditLogsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.auditLogs,
    aliasName: 'sessions__session_uuid__audit_logs__session_uuid',
  );

  $$AuditLogsTableProcessedTableManager get auditLogsRefs {
    final manager = $$AuditLogsTableTableManager($_db, $_db.auditLogs).filter(
      (f) => f.sessionUuid.sessionUuid.sqlEquals(
        $_itemColumn<String>('session_uuid')!,
      ),
    );

    final cache = $_typedResult.readTableOrNull(_auditLogsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SessionsTableFilterComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get sessionUuid => $composableBuilder(
    column: $table.sessionUuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get sessionDate => $composableBuilder(
    column: $table.sessionDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get period => $composableBuilder(
    column: $table.period,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCancelled => $composableBuilder(
    column: $table.isCancelled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get countsInAttendance => $composableBuilder(
    column: $table.countsInAttendance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDispatched => $composableBuilder(
    column: $table.isDispatched,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dispatchedAt => $composableBuilder(
    column: $table.dispatchedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isLocked => $composableBuilder(
    column: $table.isLocked,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sessionHash => $composableBuilder(
    column: $table.sessionHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get approvedAt => $composableBuilder(
    column: $table.approvedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get approvedBy => $composableBuilder(
    column: $table.approvedBy,
    builder: (column) => ColumnFilters(column),
  );

  $$TeamsTableFilterComposer get teamId {
    final $$TeamsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.teamId,
      referencedTable: $db.teams,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TeamsTableFilterComposer(
            $db: $db,
            $table: $db.teams,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> attendanceRecordsRefs(
    Expression<bool> Function($$AttendanceRecordsTableFilterComposer f) f,
  ) {
    final $$AttendanceRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionUuid,
      referencedTable: $db.attendanceRecords,
      getReferencedColumn: (t) => t.sessionUuid,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AttendanceRecordsTableFilterComposer(
            $db: $db,
            $table: $db.attendanceRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> auditLogsRefs(
    Expression<bool> Function($$AuditLogsTableFilterComposer f) f,
  ) {
    final $$AuditLogsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionUuid,
      referencedTable: $db.auditLogs,
      getReferencedColumn: (t) => t.sessionUuid,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AuditLogsTableFilterComposer(
            $db: $db,
            $table: $db.auditLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get sessionUuid => $composableBuilder(
    column: $table.sessionUuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get sessionDate => $composableBuilder(
    column: $table.sessionDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get period => $composableBuilder(
    column: $table.period,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCancelled => $composableBuilder(
    column: $table.isCancelled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get countsInAttendance => $composableBuilder(
    column: $table.countsInAttendance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDispatched => $composableBuilder(
    column: $table.isDispatched,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dispatchedAt => $composableBuilder(
    column: $table.dispatchedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isLocked => $composableBuilder(
    column: $table.isLocked,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sessionHash => $composableBuilder(
    column: $table.sessionHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get approvedAt => $composableBuilder(
    column: $table.approvedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get approvedBy => $composableBuilder(
    column: $table.approvedBy,
    builder: (column) => ColumnOrderings(column),
  );

  $$TeamsTableOrderingComposer get teamId {
    final $$TeamsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.teamId,
      referencedTable: $db.teams,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TeamsTableOrderingComposer(
            $db: $db,
            $table: $db.teams,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get sessionUuid => $composableBuilder(
    column: $table.sessionUuid,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get sessionDate => $composableBuilder(
    column: $table.sessionDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get period =>
      $composableBuilder(column: $table.period, builder: (column) => column);

  GeneratedColumn<String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => column);

  GeneratedColumn<bool> get isCancelled => $composableBuilder(
    column: $table.isCancelled,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get countsInAttendance => $composableBuilder(
    column: $table.countsInAttendance,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDispatched => $composableBuilder(
    column: $table.isDispatched,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dispatchedAt => $composableBuilder(
    column: $table.dispatchedAt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isLocked =>
      $composableBuilder(column: $table.isLocked, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sessionHash => $composableBuilder(
    column: $table.sessionHash,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get approvedAt => $composableBuilder(
    column: $table.approvedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get approvedBy => $composableBuilder(
    column: $table.approvedBy,
    builder: (column) => column,
  );

  $$TeamsTableAnnotationComposer get teamId {
    final $$TeamsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.teamId,
      referencedTable: $db.teams,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TeamsTableAnnotationComposer(
            $db: $db,
            $table: $db.teams,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> attendanceRecordsRefs<T extends Object>(
    Expression<T> Function($$AttendanceRecordsTableAnnotationComposer a) f,
  ) {
    final $$AttendanceRecordsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.sessionUuid,
          referencedTable: $db.attendanceRecords,
          getReferencedColumn: (t) => t.sessionUuid,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$AttendanceRecordsTableAnnotationComposer(
                $db: $db,
                $table: $db.attendanceRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> auditLogsRefs<T extends Object>(
    Expression<T> Function($$AuditLogsTableAnnotationComposer a) f,
  ) {
    final $$AuditLogsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionUuid,
      referencedTable: $db.auditLogs,
      getReferencedColumn: (t) => t.sessionUuid,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AuditLogsTableAnnotationComposer(
            $db: $db,
            $table: $db.auditLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SessionsTable,
          Session,
          $$SessionsTableFilterComposer,
          $$SessionsTableOrderingComposer,
          $$SessionsTableAnnotationComposer,
          $$SessionsTableCreateCompanionBuilder,
          $$SessionsTableUpdateCompanionBuilder,
          (Session, $$SessionsTableReferences),
          Session,
          PrefetchHooks Function({
            bool teamId,
            bool attendanceRecordsRefs,
            bool auditLogsRefs,
          })
        > {
  $$SessionsTableTableManager(_$AppDatabase db, $SessionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> sessionUuid = const Value.absent(),
                Value<String> teamId = const Value.absent(),
                Value<DateTime> sessionDate = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> period = const Value.absent(),
                Value<String?> location = const Value.absent(),
                Value<bool> isCancelled = const Value.absent(),
                Value<bool> countsInAttendance = const Value.absent(),
                Value<bool> isDispatched = const Value.absent(),
                Value<DateTime?> dispatchedAt = const Value.absent(),
                Value<bool> isLocked = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<String> sessionHash = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime?> approvedAt = const Value.absent(),
                Value<String?> approvedBy = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SessionsCompanion(
                sessionUuid: sessionUuid,
                teamId: teamId,
                sessionDate: sessionDate,
                type: type,
                period: period,
                location: location,
                isCancelled: isCancelled,
                countsInAttendance: countsInAttendance,
                isDispatched: isDispatched,
                dispatchedAt: dispatchedAt,
                isLocked: isLocked,
                syncStatus: syncStatus,
                sessionHash: sessionHash,
                status: status,
                approvedAt: approvedAt,
                approvedBy: approvedBy,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String sessionUuid,
                required String teamId,
                required DateTime sessionDate,
                Value<String> type = const Value.absent(),
                Value<String> period = const Value.absent(),
                Value<String?> location = const Value.absent(),
                Value<bool> isCancelled = const Value.absent(),
                Value<bool> countsInAttendance = const Value.absent(),
                Value<bool> isDispatched = const Value.absent(),
                Value<DateTime?> dispatchedAt = const Value.absent(),
                Value<bool> isLocked = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                required String sessionHash,
                Value<String> status = const Value.absent(),
                Value<DateTime?> approvedAt = const Value.absent(),
                Value<String?> approvedBy = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SessionsCompanion.insert(
                sessionUuid: sessionUuid,
                teamId: teamId,
                sessionDate: sessionDate,
                type: type,
                period: period,
                location: location,
                isCancelled: isCancelled,
                countsInAttendance: countsInAttendance,
                isDispatched: isDispatched,
                dispatchedAt: dispatchedAt,
                isLocked: isLocked,
                syncStatus: syncStatus,
                sessionHash: sessionHash,
                status: status,
                approvedAt: approvedAt,
                approvedBy: approvedBy,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SessionsTable, Session>(table),
                  $$SessionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                teamId = false,
                attendanceRecordsRefs = false,
                auditLogsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (attendanceRecordsRefs) db.attendanceRecords,
                    if (auditLogsRefs) db.auditLogs,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (teamId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.teamId,
                            referencedTable: $$SessionsTableReferences
                                ._teamIdTable(db),
                            referencedColumn: $$SessionsTableReferences
                                ._teamIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (attendanceRecordsRefs)
                        await $_getPrefetchedData<
                          Session,
                          $SessionsTable,
                          AttendanceRecord
                        >(
                          currentTable: table,
                          referencedTable: $$SessionsTableReferences
                              ._attendanceRecordsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SessionsTableReferences(
                                db,
                                table,
                                p0,
                              ).attendanceRecordsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sessionUuid == item.sessionUuid,
                              ),
                          typedResults: items,
                        ),
                      if (auditLogsRefs)
                        await $_getPrefetchedData<
                          Session,
                          $SessionsTable,
                          AuditLog
                        >(
                          currentTable: table,
                          referencedTable: $$SessionsTableReferences
                              ._auditLogsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SessionsTableReferences(
                                db,
                                table,
                                p0,
                              ).auditLogsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sessionUuid == item.sessionUuid,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$SessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SessionsTable,
      Session,
      $$SessionsTableFilterComposer,
      $$SessionsTableOrderingComposer,
      $$SessionsTableAnnotationComposer,
      $$SessionsTableCreateCompanionBuilder,
      $$SessionsTableUpdateCompanionBuilder,
      (Session, $$SessionsTableReferences),
      Session,
      PrefetchHooks Function({
        bool teamId,
        bool attendanceRecordsRefs,
        bool auditLogsRefs,
      })
    >;
typedef $$AttendanceRecordsTableCreateCompanionBuilder =
    AttendanceRecordsCompanion Function({
      required String id,
      required String sessionUuid,
      required String playerId,
      required String status,
      Value<int> lateMinutes,
      Value<String?> reason,
      Value<String?> notes,
      Value<int> rowid,
    });
typedef $$AttendanceRecordsTableUpdateCompanionBuilder =
    AttendanceRecordsCompanion Function({
      Value<String> id,
      Value<String> sessionUuid,
      Value<String> playerId,
      Value<String> status,
      Value<int> lateMinutes,
      Value<String?> reason,
      Value<String?> notes,
      Value<int> rowid,
    });

final class $$AttendanceRecordsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $AttendanceRecordsTable,
          AttendanceRecord
        > {
  $$AttendanceRecordsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $SessionsTable _sessionUuidTable(_$AppDatabase db) => db.sessions
      .createAlias('attendance_records__session_uuid__sessions__session_uuid');

  $$SessionsTableProcessedTableManager get sessionUuid {
    final $_column = $_itemColumn<String>('session_uuid')!;

    final manager = $$SessionsTableTableManager(
      $_db,
      $_db.sessions,
    ).filter((f) => f.sessionUuid.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionUuidTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $PlayersTable _playerIdTable(_$AppDatabase db) =>
      db.players.createAlias('attendance_records__player_id__players__id');

  $$PlayersTableProcessedTableManager get playerId {
    final $_column = $_itemColumn<String>('player_id')!;

    final manager = $$PlayersTableTableManager(
      $_db,
      $_db.players,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_playerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$AttendanceRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $AttendanceRecordsTable> {
  $$AttendanceRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lateMinutes => $composableBuilder(
    column: $table.lateMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  $$SessionsTableFilterComposer get sessionUuid {
    final $$SessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionUuid,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.sessionUuid,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableFilterComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PlayersTableFilterComposer get playerId {
    final $$PlayersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.playerId,
      referencedTable: $db.players,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlayersTableFilterComposer(
            $db: $db,
            $table: $db.players,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AttendanceRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $AttendanceRecordsTable> {
  $$AttendanceRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lateMinutes => $composableBuilder(
    column: $table.lateMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  $$SessionsTableOrderingComposer get sessionUuid {
    final $$SessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionUuid,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.sessionUuid,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableOrderingComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PlayersTableOrderingComposer get playerId {
    final $$PlayersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.playerId,
      referencedTable: $db.players,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlayersTableOrderingComposer(
            $db: $db,
            $table: $db.players,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AttendanceRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AttendanceRecordsTable> {
  $$AttendanceRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get lateMinutes => $composableBuilder(
    column: $table.lateMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  $$SessionsTableAnnotationComposer get sessionUuid {
    final $$SessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionUuid,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.sessionUuid,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PlayersTableAnnotationComposer get playerId {
    final $$PlayersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.playerId,
      referencedTable: $db.players,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlayersTableAnnotationComposer(
            $db: $db,
            $table: $db.players,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AttendanceRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AttendanceRecordsTable,
          AttendanceRecord,
          $$AttendanceRecordsTableFilterComposer,
          $$AttendanceRecordsTableOrderingComposer,
          $$AttendanceRecordsTableAnnotationComposer,
          $$AttendanceRecordsTableCreateCompanionBuilder,
          $$AttendanceRecordsTableUpdateCompanionBuilder,
          (AttendanceRecord, $$AttendanceRecordsTableReferences),
          AttendanceRecord,
          PrefetchHooks Function({bool sessionUuid, bool playerId})
        > {
  $$AttendanceRecordsTableTableManager(
    _$AppDatabase db,
    $AttendanceRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AttendanceRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AttendanceRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AttendanceRecordsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> sessionUuid = const Value.absent(),
                Value<String> playerId = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> lateMinutes = const Value.absent(),
                Value<String?> reason = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AttendanceRecordsCompanion(
                id: id,
                sessionUuid: sessionUuid,
                playerId: playerId,
                status: status,
                lateMinutes: lateMinutes,
                reason: reason,
                notes: notes,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String sessionUuid,
                required String playerId,
                required String status,
                Value<int> lateMinutes = const Value.absent(),
                Value<String?> reason = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AttendanceRecordsCompanion.insert(
                id: id,
                sessionUuid: sessionUuid,
                playerId: playerId,
                status: status,
                lateMinutes: lateMinutes,
                reason: reason,
                notes: notes,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AttendanceRecordsTable, AttendanceRecord>(table),
                  $$AttendanceRecordsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sessionUuid = false, playerId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (sessionUuid) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.sessionUuid,
                        referencedTable: $$AttendanceRecordsTableReferences
                            ._sessionUuidTable(db),
                        referencedColumn: $$AttendanceRecordsTableReferences
                            ._sessionUuidTable(db)
                            .sessionUuid,
                      ) as T;
                    }
                    if (playerId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.playerId,
                        referencedTable: $$AttendanceRecordsTableReferences
                            ._playerIdTable(db),
                        referencedColumn: $$AttendanceRecordsTableReferences
                            ._playerIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$AttendanceRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AttendanceRecordsTable,
      AttendanceRecord,
      $$AttendanceRecordsTableFilterComposer,
      $$AttendanceRecordsTableOrderingComposer,
      $$AttendanceRecordsTableAnnotationComposer,
      $$AttendanceRecordsTableCreateCompanionBuilder,
      $$AttendanceRecordsTableUpdateCompanionBuilder,
      (AttendanceRecord, $$AttendanceRecordsTableReferences),
      AttendanceRecord,
      PrefetchHooks Function({bool sessionUuid, bool playerId})
    >;
typedef $$AuditLogsTableCreateCompanionBuilder = AuditLogsCompanion Function({
  required String id,
  required String sessionUuid,
  required String action,
  required String modifiedBy,
  required String reason,
  required DateTime timestamp,
  required String diff,
  Value<int> rowid,
});
typedef $$AuditLogsTableUpdateCompanionBuilder = AuditLogsCompanion Function({
  Value<String> id,
  Value<String> sessionUuid,
  Value<String> action,
  Value<String> modifiedBy,
  Value<String> reason,
  Value<DateTime> timestamp,
  Value<String> diff,
  Value<int> rowid,
});

final class $$AuditLogsTableReferences
    extends BaseReferences<_$AppDatabase, $AuditLogsTable, AuditLog> {
  $$AuditLogsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SessionsTable _sessionUuidTable(_$AppDatabase db) => db.sessions
      .createAlias('audit_logs__session_uuid__sessions__session_uuid');

  $$SessionsTableProcessedTableManager get sessionUuid {
    final $_column = $_itemColumn<String>('session_uuid')!;

    final manager = $$SessionsTableTableManager(
      $_db,
      $_db.sessions,
    ).filter((f) => f.sessionUuid.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionUuidTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$AuditLogsTableFilterComposer
    extends Composer<_$AppDatabase, $AuditLogsTable> {
  $$AuditLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get modifiedBy => $composableBuilder(
    column: $table.modifiedBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get diff => $composableBuilder(
    column: $table.diff,
    builder: (column) => ColumnFilters(column),
  );

  $$SessionsTableFilterComposer get sessionUuid {
    final $$SessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionUuid,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.sessionUuid,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableFilterComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AuditLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $AuditLogsTable> {
  $$AuditLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get modifiedBy => $composableBuilder(
    column: $table.modifiedBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get diff => $composableBuilder(
    column: $table.diff,
    builder: (column) => ColumnOrderings(column),
  );

  $$SessionsTableOrderingComposer get sessionUuid {
    final $$SessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionUuid,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.sessionUuid,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableOrderingComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AuditLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AuditLogsTable> {
  $$AuditLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get action =>
      $composableBuilder(column: $table.action, builder: (column) => column);

  GeneratedColumn<String> get modifiedBy => $composableBuilder(
    column: $table.modifiedBy,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<String> get diff =>
      $composableBuilder(column: $table.diff, builder: (column) => column);

  $$SessionsTableAnnotationComposer get sessionUuid {
    final $$SessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionUuid,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.sessionUuid,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AuditLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AuditLogsTable,
          AuditLog,
          $$AuditLogsTableFilterComposer,
          $$AuditLogsTableOrderingComposer,
          $$AuditLogsTableAnnotationComposer,
          $$AuditLogsTableCreateCompanionBuilder,
          $$AuditLogsTableUpdateCompanionBuilder,
          (AuditLog, $$AuditLogsTableReferences),
          AuditLog,
          PrefetchHooks Function({bool sessionUuid})
        > {
  $$AuditLogsTableTableManager(_$AppDatabase db, $AuditLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AuditLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AuditLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AuditLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> sessionUuid = const Value.absent(),
                Value<String> action = const Value.absent(),
                Value<String> modifiedBy = const Value.absent(),
                Value<String> reason = const Value.absent(),
                Value<DateTime> timestamp = const Value.absent(),
                Value<String> diff = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AuditLogsCompanion(
                id: id,
                sessionUuid: sessionUuid,
                action: action,
                modifiedBy: modifiedBy,
                reason: reason,
                timestamp: timestamp,
                diff: diff,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String sessionUuid,
                required String action,
                required String modifiedBy,
                required String reason,
                required DateTime timestamp,
                required String diff,
                Value<int> rowid = const Value.absent(),
              }) => AuditLogsCompanion.insert(
                id: id,
                sessionUuid: sessionUuid,
                action: action,
                modifiedBy: modifiedBy,
                reason: reason,
                timestamp: timestamp,
                diff: diff,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AuditLogsTable, AuditLog>(table),
                  $$AuditLogsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sessionUuid = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (sessionUuid) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.sessionUuid,
                        referencedTable: $$AuditLogsTableReferences
                            ._sessionUuidTable(db),
                        referencedColumn: $$AuditLogsTableReferences
                            ._sessionUuidTable(db)
                            .sessionUuid,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$AuditLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AuditLogsTable,
      AuditLog,
      $$AuditLogsTableFilterComposer,
      $$AuditLogsTableOrderingComposer,
      $$AuditLogsTableAnnotationComposer,
      $$AuditLogsTableCreateCompanionBuilder,
      $$AuditLogsTableUpdateCompanionBuilder,
      (AuditLog, $$AuditLogsTableReferences),
      AuditLog,
      PrefetchHooks Function({bool sessionUuid})
    >;
typedef $$SyncAuditLogsTableCreateCompanionBuilder =
    SyncAuditLogsCompanion Function({
      required String id,
      required String sessionUuid,
      required String syncDirection,
      required String syncChannel,
      required String sourceDeviceId,
      required String targetDeviceId,
      required DateTime syncedAt,
      required String status,
      Value<int> rowid,
    });
typedef $$SyncAuditLogsTableUpdateCompanionBuilder =
    SyncAuditLogsCompanion Function({
      Value<String> id,
      Value<String> sessionUuid,
      Value<String> syncDirection,
      Value<String> syncChannel,
      Value<String> sourceDeviceId,
      Value<String> targetDeviceId,
      Value<DateTime> syncedAt,
      Value<String> status,
      Value<int> rowid,
    });

class $$SyncAuditLogsTableFilterComposer
    extends Composer<_$AppDatabase, $SyncAuditLogsTable> {
  $$SyncAuditLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sessionUuid => $composableBuilder(
    column: $table.sessionUuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncDirection => $composableBuilder(
    column: $table.syncDirection,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncChannel => $composableBuilder(
    column: $table.syncChannel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceDeviceId => $composableBuilder(
    column: $table.sourceDeviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get targetDeviceId => $composableBuilder(
    column: $table.targetDeviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncAuditLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncAuditLogsTable> {
  $$SyncAuditLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sessionUuid => $composableBuilder(
    column: $table.sessionUuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncDirection => $composableBuilder(
    column: $table.syncDirection,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncChannel => $composableBuilder(
    column: $table.syncChannel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceDeviceId => $composableBuilder(
    column: $table.sourceDeviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get targetDeviceId => $composableBuilder(
    column: $table.targetDeviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncAuditLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncAuditLogsTable> {
  $$SyncAuditLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get sessionUuid => $composableBuilder(
    column: $table.sessionUuid,
    builder: (column) => column,
  );

  GeneratedColumn<String> get syncDirection => $composableBuilder(
    column: $table.syncDirection,
    builder: (column) => column,
  );

  GeneratedColumn<String> get syncChannel => $composableBuilder(
    column: $table.syncChannel,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceDeviceId => $composableBuilder(
    column: $table.sourceDeviceId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get targetDeviceId => $composableBuilder(
    column: $table.targetDeviceId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);
}

class $$SyncAuditLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncAuditLogsTable,
          SyncAuditLog,
          $$SyncAuditLogsTableFilterComposer,
          $$SyncAuditLogsTableOrderingComposer,
          $$SyncAuditLogsTableAnnotationComposer,
          $$SyncAuditLogsTableCreateCompanionBuilder,
          $$SyncAuditLogsTableUpdateCompanionBuilder,
          (
            SyncAuditLog,
            BaseReferences<_$AppDatabase, $SyncAuditLogsTable, SyncAuditLog>,
          ),
          SyncAuditLog,
          PrefetchHooks Function()
        > {
  $$SyncAuditLogsTableTableManager(_$AppDatabase db, $SyncAuditLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncAuditLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncAuditLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncAuditLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> sessionUuid = const Value.absent(),
                Value<String> syncDirection = const Value.absent(),
                Value<String> syncChannel = const Value.absent(),
                Value<String> sourceDeviceId = const Value.absent(),
                Value<String> targetDeviceId = const Value.absent(),
                Value<DateTime> syncedAt = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncAuditLogsCompanion(
                id: id,
                sessionUuid: sessionUuid,
                syncDirection: syncDirection,
                syncChannel: syncChannel,
                sourceDeviceId: sourceDeviceId,
                targetDeviceId: targetDeviceId,
                syncedAt: syncedAt,
                status: status,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String sessionUuid,
                required String syncDirection,
                required String syncChannel,
                required String sourceDeviceId,
                required String targetDeviceId,
                required DateTime syncedAt,
                required String status,
                Value<int> rowid = const Value.absent(),
              }) => SyncAuditLogsCompanion.insert(
                id: id,
                sessionUuid: sessionUuid,
                syncDirection: syncDirection,
                syncChannel: syncChannel,
                sourceDeviceId: sourceDeviceId,
                targetDeviceId: targetDeviceId,
                syncedAt: syncedAt,
                status: status,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SyncAuditLogsTable, SyncAuditLog>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $SyncAuditLogsTable,
                    SyncAuditLog
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncAuditLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncAuditLogsTable,
      SyncAuditLog,
      $$SyncAuditLogsTableFilterComposer,
      $$SyncAuditLogsTableOrderingComposer,
      $$SyncAuditLogsTableAnnotationComposer,
      $$SyncAuditLogsTableCreateCompanionBuilder,
      $$SyncAuditLogsTableUpdateCompanionBuilder,
      (
        SyncAuditLog,
        BaseReferences<_$AppDatabase, $SyncAuditLogsTable, SyncAuditLog>,
      ),
      SyncAuditLog,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$LicenseSecurityStoreTableTableManager get licenseSecurityStore =>
      $$LicenseSecurityStoreTableTableManager(_db, _db.licenseSecurityStore);
  $$ClubSettingsTableTableManager get clubSettings =>
      $$ClubSettingsTableTableManager(_db, _db.clubSettings);
  $$TeamsTableTableManager get teams =>
      $$TeamsTableTableManager(_db, _db.teams);
  $$PlayersTableTableManager get players =>
      $$PlayersTableTableManager(_db, _db.players);
  $$SessionsTableTableManager get sessions =>
      $$SessionsTableTableManager(_db, _db.sessions);
  $$AttendanceRecordsTableTableManager get attendanceRecords =>
      $$AttendanceRecordsTableTableManager(_db, _db.attendanceRecords);
  $$AuditLogsTableTableManager get auditLogs =>
      $$AuditLogsTableTableManager(_db, _db.auditLogs);
  $$SyncAuditLogsTableTableManager get syncAuditLogs =>
      $$SyncAuditLogsTableTableManager(_db, _db.syncAuditLogs);
}
