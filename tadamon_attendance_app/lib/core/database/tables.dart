import 'package:drift/drift.dart';

class LicenseSecurityStore extends Table {
  @override
  String get tableName => 'license_security_store';

  TextColumn get deviceId => text().named('device_id')();
  TextColumn get deviceMode => text().named('device_mode')();
  TextColumn get pairedDeviceId =>
      text().named('paired_device_id').nullable()();
  TextColumn get licenseKey => text().named('license_key')();
  TextColumn get clubName => text().named('club_name')();
  TextColumn get teamName => text().named('team_name').nullable()();
  TextColumn get packageType => text().named('package_type')();
  DateTimeColumn get activatedAt => dateTime().named('activated_at')();
  DateTimeColumn get expiresAt => dateTime().named('expires_at')();
  DateTimeColumn get highWatermarkTimestamp =>
      dateTime().named('high_watermark_timestamp')();
  IntColumn get cumulativeRuntimeMinutes => integer()
      .named('cumulative_runtime_minutes')
      .withDefault(const Constant(0))();
  BoolColumn get tamperFlag =>
      boolean().named('tamper_flag').withDefault(const Constant(false))();
  TextColumn get signatureProof => text().named('signature_proof')();

  @override
  Set<Column<Object>> get primaryKey => {deviceId};
}

class ClubSettings extends Table {
  @override
  String get tableName => 'club_settings';

  IntColumn get id => integer().customConstraint('NOT NULL CHECK (id = 1)')();
  TextColumn get clubName => text().named('club_name')();
  TextColumn get logoPath => text().named('logo_path').nullable()();
  TextColumn get season => text()();
  TextColumn get adminName => text().named('admin_name').nullable()();
  TextColumn get managerName => text().named('manager_name').nullable()();
  TextColumn get pinCodeHash => text().named('pin_code_hash').nullable()();
  BoolColumn get entitlementSportEnabled => boolean()
      .named('entitlement_sport_enabled')
      .withDefault(const Constant(true))();
  BoolColumn get entitlementCountsExcused => boolean()
      .named('entitlement_counts_excused')
      .withDefault(const Constant(true))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class Teams extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get category => text()();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get updatedAt => dateTime().named('updated_at')();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class Players extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get teamId => text().named('team_id').references(Teams, #id)();
  IntColumn get jerseyNumber => integer().named('jersey_number').nullable()();
  TextColumn get position => text().nullable()();
  DateTimeColumn get joinDate => dateTime().named('join_date')();
  BoolColumn get isArchived =>
      boolean().named('is_archived').withDefault(const Constant(false))();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get updatedAt => dateTime().named('updated_at')();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class Sessions extends Table {
  TextColumn get sessionUuid => text().named('session_uuid')();
  TextColumn get teamId => text().named('team_id').references(Teams, #id)();
  DateTimeColumn get sessionDate => dateTime().named('date')();
  TextColumn get type => text().withDefault(const Constant('تمرين'))();
  TextColumn get period => text().withDefault(const Constant('مسائي'))();
  TextColumn get location => text().nullable()();
  BoolColumn get isCancelled =>
      boolean().named('is_cancelled').withDefault(const Constant(false))();
  BoolColumn get countsInAttendance => boolean()
      .named('counts_in_attendance')
      .withDefault(const Constant(true))();
  BoolColumn get isDispatched =>
      boolean().named('is_dispatched').withDefault(const Constant(false))();
  DateTimeColumn get dispatchedAt =>
      dateTime().named('dispatched_at').nullable()();
  BoolColumn get isLocked =>
      boolean().named('is_locked').withDefault(const Constant(false))();
  TextColumn get syncStatus =>
      text().named('sync_status').withDefault(const Constant('local'))();
  TextColumn get sessionHash => text().named('session_hash')();
  TextColumn get status => text().withDefault(const Constant('draft'))();
  DateTimeColumn get approvedAt => dateTime().named('approved_at').nullable()();
  TextColumn get approvedBy => text().named('approved_by').nullable()();

  @override
  Set<Column<Object>> get primaryKey => {sessionUuid};
}

class AttendanceRecords extends Table {
  @override
  String get tableName => 'attendance_records';

  TextColumn get id => text()();
  TextColumn get sessionUuid => text()
      .named('session_uuid')
      .references(Sessions, #sessionUuid, onDelete: KeyAction.cascade)();
  TextColumn get playerId =>
      text().named('player_id').references(Players, #id)();
  TextColumn get status => text()();
  IntColumn get lateMinutes =>
      integer().named('late_minutes').withDefault(const Constant(0))();
  TextColumn get reason => text().nullable()();
  TextColumn get notes => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {sessionUuid, playerId},
  ];
}

class AuditLogs extends Table {
  @override
  String get tableName => 'audit_logs';

  TextColumn get id => text()();
  TextColumn get sessionUuid =>
      text().named('session_uuid').references(Sessions, #sessionUuid)();
  TextColumn get action => text()();
  TextColumn get modifiedBy => text().named('modified_by')();
  TextColumn get reason => text()();
  DateTimeColumn get timestamp => dateTime()();
  TextColumn get diff => text()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class SyncAuditLogs extends Table {
  @override
  String get tableName => 'sync_audit_logs';

  TextColumn get id => text()();
  TextColumn get sessionUuid => text().named('session_uuid')();
  TextColumn get syncDirection => text().named('sync_direction')();
  TextColumn get syncChannel => text().named('sync_channel')();
  TextColumn get sourceDeviceId => text().named('source_device_id')();
  TextColumn get targetDeviceId => text().named('target_device_id')();
  DateTimeColumn get syncedAt => dateTime().named('synced_at')();
  TextColumn get status => text()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
