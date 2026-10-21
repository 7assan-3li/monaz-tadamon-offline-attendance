import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tadamon_attendance_app/features/sync/domain/repositories/cloud_sync_repository.dart';
import 'package:tadamon_attendance_app/features/sync/presentation/bloc/cloud_sync_event.dart';
import 'package:tadamon_attendance_app/features/sync/presentation/bloc/cloud_sync_state.dart';

class CloudSyncBloc extends Bloc<CloudSyncEvent, CloudSyncState> {
  CloudSyncBloc({required this.repository}) : super(const CloudSyncInitial()) {
    on<CheckCloudHealthEvent>(_onCheckHealth);
    on<RegisterCloudDeviceEvent>(_onRegisterDevice);
    on<PushMasterDataCloudEvent>(_onPushMasterData);
    on<PullMasterDataCloudEvent>(_onPullMasterData);
    on<DispatchSessionCloudEvent>(_onDispatchSession);
    on<FetchCloudSessionsEvent>(_onFetchSessions);
    on<ApproveCloudSessionEvent>(_onApproveSession);
  }

  final CloudSyncRepository repository;

  Future<void> _onCheckHealth(
    CheckCloudHealthEvent event,
    Emitter<CloudSyncState> emit,
  ) async {
    emit(const CloudSyncLoading(operation: 'فحص الاتصال بالسحابة...'));
    final isOnline = await repository.checkConnectivity();
    emit(CloudHealthState(isOnline: isOnline));
  }

  Future<void> _onRegisterDevice(
    RegisterCloudDeviceEvent event,
    Emitter<CloudSyncState> emit,
  ) async {
    emit(const CloudSyncLoading(operation: 'تسجيل الجهاز في منظومة النادي...'));
    final success = await repository.registerDevice(
      deviceId: event.deviceId,
      deviceName: event.deviceName,
      role: event.role,
      clubName: event.clubName,
      season: event.season,
      primaryColorHex: event.primaryColorHex,
    );

    if (success) {
      emit(CloudDeviceRegisteredState(
        message: 'تم ربط الجهاز بنجاح مع النادي السحابي.',
        deviceId: event.deviceId,
        role: event.role,
      ));
    } else {
      emit(const CloudSyncFailure(
        error: 'تعذر تسجيل الجهاز؛ يرجى التأكد من الاتصال بالإنترنت.',
      ));
    }
  }

  Future<void> _onPushMasterData(
    PushMasterDataCloudEvent event,
    Emitter<CloudSyncState> emit,
  ) async {
    emit(const CloudSyncLoading(operation: 'رفع بيانات اللاعبين والفرق للسحابة...'));
    final success = await repository.pushMasterData(
      sourceDeviceId: event.sourceDeviceId,
      clubProfile: event.clubProfile,
      teams: event.teams,
      players: event.players,
    );

    if (success) {
      emit(const MasterDataPushedState(
        message: 'تم رفع ومزامنة كافة بيانات اللاعبين والفرق وهوية النادي بنجاح.',
      ));
    } else {
      emit(const CloudSyncFailure(
        error: 'فشل رفع البيانات؛ تعذر الاتصال بالخادم السحابي.',
      ));
    }
  }

  Future<void> _onPullMasterData(
    PullMasterDataCloudEvent event,
    Emitter<CloudSyncState> emit,
  ) async {
    emit(const CloudSyncLoading(operation: 'سحب بيانات وهوية النادي من السحابة...'));
    final masterData = await repository.pullMasterData(clubId: event.clubId);

    if (masterData != null) {
      emit(MasterDataPulledState(
        message: 'تم استلام وتحديث بيانات النادي واللاعبين بنجاح.',
        masterData: masterData,
      ));
    } else {
      emit(const CloudSyncFailure(
        error: 'تعذر سحب البيانات؛ يرجى التأكد من توفر اتصال بالإنترنت.',
      ));
    }
  }

  Future<void> _onDispatchSession(
    DispatchSessionCloudEvent event,
    Emitter<CloudSyncState> emit,
  ) async {
    emit(const CloudSyncLoading(operation: 'ترحيل الحصة التدريبية إلى السحابة...'));
    final success = await repository.dispatchSessionToCloud(event.session);

    if (success) {
      emit(SessionDispatchedCloudState(
        message: 'تم ترحيل وتوثيق الحصة التدريبية في السحابة بنجاح.',
        sessionUuid: event.session.sessionUuid,
      ));
    } else {
      emit(const CloudSyncFailure(
        error: 'تعذر رفع الحصة للسحابة؛ يمكنك استخدام كود الـ QR كبديل محلي فوري.',
      ));
    }
  }

  Future<void> _onFetchSessions(
    FetchCloudSessionsEvent event,
    Emitter<CloudSyncState> emit,
  ) async {
    emit(const CloudSyncLoading(operation: 'جلب الحصص المرحّلة من السحابة...'));
    final sessions = await repository.fetchDispatchedSessionsFromCloud(teamId: event.teamId);
    emit(CloudSessionsFetchedState(sessions: sessions));
  }

  Future<void> _onApproveSession(
    ApproveCloudSessionEvent event,
    Emitter<CloudSyncState> emit,
  ) async {
    emit(const CloudSyncLoading(operation: 'توثيق اعتماد الحصة في السحابة...'));
    final success = await repository.approveSessionOnCloud(
      event.sessionUuid,
      approverDeviceId: event.approverDeviceId,
    );

    if (success) {
      emit(SessionApprovedCloudState(
        message: 'تم اعتماد وتثبيت الحصة رسمياً في السحابة.',
        sessionUuid: event.sessionUuid,
      ));
    } else {
      emit(const CloudSyncFailure(
        error: 'تعذر توثيق الاعتماد سحابياً.',
      ));
    }
  }
}
