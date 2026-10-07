enum DeviceRole { masterAdmin, fieldAttendance }

abstract final class AppRoutes {
  static const String fieldTodaySession = '/field/today-session';
  static const String masterHome = '/master/home';
  static const String players = '/players';
  static const String reports = '/reports';
  static const String settings = '/settings';
  static const String pin = '/pin';

  static const Set<String> administrativeRoots = {
    players,
    reports,
    settings,
    pin,
  };
}

class DeviceRoleGuard {
  const DeviceRoleGuard();

  String resolve({required DeviceRole role, required String requestedRoute}) {
    if (role == DeviceRole.fieldAttendance &&
        _isAdministrativeRoute(requestedRoute)) {
      return AppRoutes.fieldTodaySession;
    }

    return requestedRoute;
  }

  bool _isAdministrativeRoute(String route) {
    return AppRoutes.administrativeRoots.any(
      (root) => route == root || route.startsWith('$root/'),
    );
  }
}
