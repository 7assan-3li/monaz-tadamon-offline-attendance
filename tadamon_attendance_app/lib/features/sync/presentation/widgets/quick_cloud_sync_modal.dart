import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:tadamon_attendance_app/core/constants/app_colors.dart';
import 'package:tadamon_attendance_app/core/database/app_database.dart';
import 'package:tadamon_attendance_app/core/di/service_locator.dart';
import 'package:tadamon_attendance_app/core/security/license_parser.dart';
import 'package:tadamon_attendance_app/core/theme/club_theme_service.dart';
import 'package:tadamon_attendance_app/core/widgets/club_logo_widget.dart';
import 'package:tadamon_attendance_app/features/activation/data/datasources/license_local_data_source.dart';
import 'package:tadamon_attendance_app/features/settings/domain/repositories/settings_repository.dart';
import 'package:tadamon_attendance_app/features/sync/domain/repositories/cloud_sync_repository.dart';
import 'package:tadamon_attendance_app/features/sync/presentation/bloc/cloud_sync_bloc.dart';
import 'package:tadamon_attendance_app/features/teams/domain/repositories/teams_repository.dart';

class QuickCloudSyncModal extends StatefulWidget {
  const QuickCloudSyncModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider<CloudSyncBloc>.value(
        value: serviceLocator<CloudSyncBloc>(),
        child: const QuickCloudSyncModal(),
      ),
    );
  }

  @override
  State<QuickCloudSyncModal> createState() => _QuickCloudSyncModalState();
}

class _QuickCloudSyncModalState extends State<QuickCloudSyncModal> {
  bool _isChecking = true;
  bool _isOnline = false;
  bool _isSyncing = false;
  String? _syncStatusMessage;
  String _deviceId = '';
  String _clubId = '';
  String _clubName = '';
  String _deviceRole = '';
  int _localPlayersCount = 0;
  int _localTeamsCount = 0;

  @override
  void initState() {
    super.initState();
    _loadDeviceInfoAndCheckHealth();
  }

  Future<void> _loadDeviceInfoAndCheckHealth() async {
    String devId = 'TD-DEVICE';
    String cId = 'tadamon_hadhramaut';
    String cName = ClubThemeService.instance.currentClubName;
    String role = 'master_admin';

    try {
      if (serviceLocator.isRegistered<LicenseLocalDataSource>()) {
        final license = await serviceLocator<LicenseLocalDataSource>().readLicense();
        if (license != null) {
          devId = license.deviceId;
          cName = license.clubName;
          role = license.deviceMode;
          if (serviceLocator.isRegistered<LicenseParser>()) {
            final parsed = serviceLocator<LicenseParser>().parse(license.licenseKey);
            final c = parsed.payload['club_id'];
            if (c is String && c.isNotEmpty) cId = c;
          }
        }
      }

      if (serviceLocator.isRegistered<AppDatabase>()) {
        final db = serviceLocator<AppDatabase>();
        final players = await db.select(db.players).get();
        _localPlayersCount = players.length;
      }
      if (serviceLocator.isRegistered<TeamsRepository>()) {
        final teams = await serviceLocator<TeamsRepository>().getTeams();
        _localTeamsCount = teams.length;
      }
    } catch (_) {}

    final repo = serviceLocator<CloudSyncRepository>();
    final online = await repo.checkConnectivity();

    if (mounted) {
      setState(() {
        _deviceId = devId;
        _clubId = cId;
        _clubName = cName;
        _deviceRole = role;
        _isOnline = online;
        _isChecking = false;
      });
    }
  }

  Future<void> _performFullSync() async {
    if (!_isOnline) {
      setState(() {
        _syncStatusMessage = 'يرجى التأكد من اتصال الإنترنت للبدء في المزامنة.';
      });
      return;
    }

    setState(() {
      _isSyncing = true;
      _syncStatusMessage = 'جاري المزامنة مع خادم النادي السحابي (attendance.monaz.dev)...';
    });

    final repo = serviceLocator<CloudSyncRepository>();
    final isMaster = _deviceRole == 'master_admin';

    try {
      if (isMaster) {
        // Master Admin Flow: Push Master Data + Check Sessions
        final settingsRepo = serviceLocator<SettingsRepository>();
        final settings = await settingsRepo.read();

        final clubProfile = {
          'club_name': settings.clubName.isNotEmpty ? settings.clubName : _clubName,
          'season': settings.season.isNotEmpty ? settings.season : '2026/2027',
          'primary_color_hex': settings.primaryColorHex ?? '#0F48A2',
          'admin_name': settings.adminName,
          'manager_name': settings.managerName,
        };

        final List<Map<String, dynamic>> teamsData = [];
        if (serviceLocator.isRegistered<TeamsRepository>()) {
          final teams = await serviceLocator<TeamsRepository>().getTeams();
          for (final t in teams) {
            teamsData.add({'id': t.id, 'name': t.name, 'age_category': t.category});
          }
        }

        final List<Map<String, dynamic>> playersData = [];
        if (serviceLocator.isRegistered<AppDatabase>()) {
          final db = serviceLocator<AppDatabase>();
          final players = await db.select(db.players).get();
          for (final p in players) {
            playersData.add({
              'id': p.id,
              'name': p.name,
              'jersey_number': p.jerseyNumber,
              'position': p.position,
              'team_id': p.teamId,
              'is_archived': p.isArchived,
            });
          }
        }

        final pushed = await repo.pushMasterData(
          sourceDeviceId: _deviceId,
          clubId: _clubId,
          clubProfile: clubProfile,
          teams: teamsData,
          players: playersData,
        );

        final sessions = await repo.fetchDispatchedSessionsFromCloud(clubId: _clubId);

        if (mounted) {
          setState(() {
            _isSyncing = false;
            if (pushed) {
              _syncStatusMessage =
                  'تمت المزامنة بنجاح! تم رفع $_localPlayersCount لاعباً و $_localTeamsCount فرق إلى السحابة، ومراجعة ${sessions.length} حصة تدريبية مرحّلة. 🟢';
            } else {
              _syncStatusMessage = 'تعذر رفع البيانات، يرجى المحاولة لاحقاً.';
            }
          });
        }
      } else {
        // Field Scout Flow: Pull Latest Master Data to local Drift SQLite
        final pulled = await repo.pullMasterData(clubId: _clubId);
        if (mounted) {
          setState(() {
            _isSyncing = false;
            if (pulled != null) {
              _syncStatusMessage =
                  'تم سحب وتحديث كشوفات اللاعبين بنجاح (${pulled.players.length} لاعب • ${pulled.teams.length} فرق). الجهاز جاهز للعمل دون إنترنت 100%! 🟢';
            } else {
              _syncStatusMessage = 'تعذر سحب البيانات من السحابة حالياً.';
            }
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSyncing = false;
          _syncStatusMessage = 'حدث خطأ أثناء المزامنة: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = ClubThemeService.instance.currentPrimaryColor;
    final isMaster = _deviceRole == 'master_admin';

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: const ClubLogoWidget(width: 38, height: 40, fit: BoxFit.contain),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _clubName.isNotEmpty ? _clubName : 'نادي تضامن حضرموت الرياضي',
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          isMaster ? 'جهاز الإدارة العامة' : 'جهاز المحضر الميداني',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                        if (_deviceId.isNotEmpty) ...[
                          const Text(' • ', style: TextStyle(color: Colors.grey)),
                          Text(
                            _deviceId,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              // Close button
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(LucideIcons.x, size: 20),
                color: AppColors.textSecondary,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Cloud Health & Server Info Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: _isOnline ? const Color(0xFFF0FDF4) : const Color(0xFFFFF1F2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _isOnline ? const Color(0xFFBBF7D0) : const Color(0xFFFECDD3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _isOnline ? LucideIcons.cloud : LucideIcons.cloudOff,
                  size: 20,
                  color: _isOnline ? const Color(0xFF16A34A) : const Color(0xFFE11D48),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isChecking
                            ? 'جاري فحص الاتصال بالسيرفر...'
                            : (_isOnline
                                ? 'الخادم السحابي متصل ويعمل بكفاءة 🟢'
                                : 'غير متصل بالسيرفر (وضع أوفلاين) 🔴'),
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _isOnline ? const Color(0xFF15803D) : const Color(0xFFBE123C),
                        ),
                      ),
                      const Text(
                        'https://attendance.monaz.dev',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 10,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_isChecking)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  IconButton(
                    onPressed: _loadDeviceInfoAndCheckHealth,
                    icon: const Icon(LucideIcons.refreshCw, size: 16),
                    tooltip: 'إعادة الفحص',
                    color: AppColors.textSecondary,
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Stats row
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.canvas,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '$_localPlayersCount',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                      const Text(
                        'اللاعبين بالجهاز',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.canvas,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '$_localTeamsCount',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                      const Text(
                        'الفرق الرياضية',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          if (_syncStatusMessage != null) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _syncStatusMessage!.contains('بنجاح')
                    ? const Color(0xFFF0FDF4)
                    : const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: _syncStatusMessage!.contains('بنجاح')
                      ? const Color(0xFF86EFAC)
                      : const Color(0xFFFDE68A),
                ),
              ),
              child: Text(
                _syncStatusMessage!,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  height: 1.4,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
          const SizedBox(height: 20),

          // Primary One-Touch Sync Action Button
          ElevatedButton.icon(
            onPressed: (_isSyncing || !_isOnline) ? null : _performFullSync,
            icon: _isSyncing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(LucideIcons.refreshCw, size: 18),
            label: Text(
              _isSyncing
                  ? 'جاري تنفيذ المزامنة السحابية...'
                  : (isMaster
                      ? 'مزامنة ورفع بيانات النادي للسحابة ⬆️'
                      : 'سحب وتحديث بيانات النادي فورياً ⬇️'),
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 2,
            ),
          ),
          const SizedBox(height: 8),

          Text(
            isMaster
                ? 'تقوم المزامنة برفع كشوفات اللاعبين والفرق وهوية النادي للسحابة ليتمكن مدربو الميدان من استلامها فورياً.'
                : 'تقوم المزامنة بسحب أحدث كشوفات اللاعبين من السحابة لتتمكن من التحضير بدون إنترنت في الملعب.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 10.5,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
