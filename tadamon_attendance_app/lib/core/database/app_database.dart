import 'package:drift/drift.dart';
import 'package:tadamon_attendance_app/core/database/connection/native.dart';
import 'package:tadamon_attendance_app/core/database/tables.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    LicenseSecurityStore,
    ClubSettings,
    Teams,
    Players,
    Sessions,
    AttendanceRecords,
    AuditLogs,
    SyncAuditLogs,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(openNativeDatabase());

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) async {
      await migrator.createAll();
    },
    onUpgrade: (migrator, from, to) async {
      // Future upgrades are additive and versioned here. Destructive table
      // drops or recreation are prohibited to preserve club records.
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
