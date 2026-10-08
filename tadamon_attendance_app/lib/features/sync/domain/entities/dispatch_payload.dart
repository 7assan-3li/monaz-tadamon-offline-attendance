import 'package:tadamon_attendance_app/features/attendance/domain/entities/player_attendance_item.dart';

final class AbsenteePayloadItem {
  const AbsenteePayloadItem({
    required this.playerId,
    required this.status,
  });

  final String playerId;
  final PlayerAttendanceStatus status;

  String toCompactString() =>
      '$playerId:${status == PlayerAttendanceStatus.excused ? 'e' : 'u'}';

  factory AbsenteePayloadItem.fromCompactString(String compact) {
    final idx = compact.lastIndexOf(':');
    if (idx == -1) {
      return AbsenteePayloadItem(
        playerId: compact,
        status: PlayerAttendanceStatus.unexcused,
      );
    }
    final id = compact.substring(0, idx);
    final st = compact.substring(idx + 1);
    return AbsenteePayloadItem(
      playerId: id,
      status: st == 'e'
          ? PlayerAttendanceStatus.excused
          : PlayerAttendanceStatus.unexcused,
    );
  }

  Map<String, Object?> toJson() => {
    'i': playerId,
    's': status == PlayerAttendanceStatus.excused ? 'e' : 'u',
  };

  factory AbsenteePayloadItem.fromJson(Object? json) {
    if (json is String) {
      return AbsenteePayloadItem.fromCompactString(json);
    }
    if (json is Map<String, Object?>) {
      final statusChar = json['s'] as String? ?? 'u';
      return AbsenteePayloadItem(
        playerId: json['i'] as String? ?? '',
        status: statusChar == 'e'
            ? PlayerAttendanceStatus.excused
            : PlayerAttendanceStatus.unexcused,
      );
    }
    return AbsenteePayloadItem(
      playerId: json?.toString() ?? '',
      status: PlayerAttendanceStatus.unexcused,
    );
  }
}

final class DispatchPayload {
  const DispatchPayload({
    required this.sessionUuid,
    required this.teamId,
    required this.sessionDate,
    required this.sourceDeviceId,
    required this.absentees,
    required this.signature,
  });

  final String sessionUuid;
  final String teamId;
  final DateTime sessionDate;
  final String sourceDeviceId;
  final List<AbsenteePayloadItem> absentees;
  final String signature;

  Map<String, Object?> toContentMap() => {
    'u': sessionUuid,
    't': teamId,
    'd': sessionDate.toUtc().millisecondsSinceEpoch ~/ 1000,
    's': sourceDeviceId,
    'a': absentees.map((e) => e.toCompactString()).toList(growable: false),
  };
}
