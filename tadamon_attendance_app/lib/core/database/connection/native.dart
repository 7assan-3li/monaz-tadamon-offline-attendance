import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

const String databaseFileName = 'tadamon_attendance.sqlite';

LazyDatabase openNativeDatabase() {
  return LazyDatabase(() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final databaseFile = File(
      path.join(documentsDirectory.path, databaseFileName),
    );

    return NativeDatabase.createInBackground(databaseFile);
  });
}
