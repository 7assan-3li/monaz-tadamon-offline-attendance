import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tadamon_attendance_app/core/di/service_locator.dart';
import 'package:tadamon_attendance_app/core/presentation/design_system_gallery_screen.dart';
import 'package:tadamon_attendance_app/core/routing/field_attendance_app_shell.dart';
import 'package:tadamon_attendance_app/core/routing/master_admin_app_shell.dart';
import 'package:tadamon_attendance_app/core/security/android_hardware_components_source.dart';
import 'package:tadamon_attendance_app/core/security/hardware_fingerprint.dart';
import 'package:tadamon_attendance_app/core/security/high_watermark_guard.dart';
import 'package:tadamon_attendance_app/core/theme/app_theme.dart';
import 'package:tadamon_attendance_app/features/activation/domain/entities/activated_license.dart';
import 'package:tadamon_attendance_app/features/activation/domain/repositories/activation_repository.dart';
import 'package:tadamon_attendance_app/features/activation/presentation/bloc/activation_bloc.dart';
import 'package:tadamon_attendance_app/features/activation/presentation/screens/activation_screen.dart';
import 'package:tadamon_attendance_app/features/activation/presentation/screens/clock_tampered_screen.dart';
import 'package:tadamon_attendance_app/features/players/presentation/bloc/players_bloc.dart';
import 'package:tadamon_attendance_app/features/players/presentation/bloc/players_event.dart';
import 'package:tadamon_attendance_app/features/players/presentation/screens/players_list_screen.dart';
import 'package:tadamon_attendance_app/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:tadamon_attendance_app/features/settings/presentation/screens/club_settings_screen.dart';
import 'package:tadamon_attendance_app/features/teams/presentation/bloc/teams_bloc.dart';
import 'package:tadamon_attendance_app/features/attendance/presentation/bloc/attendance_bloc.dart';
import 'package:tadamon_attendance_app/features/attendance/presentation/screens/field_attendance_flow.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeCoreDependencies();
  final hardwareComponents = await const AndroidHardwareComponentsSource()
      .read();
  final deviceId = await CompositeHardwareFingerprint().derive(
    hardwareComponents,
  );
  configureActivationDependencies(currentDeviceId: deviceId);
  configureAttendanceDependencies();
  final storedLicense = await serviceLocator<ActivationRepository>()
      .readActivatedLicense();
  var clockTampered = false;
  if (storedLicense != null) {
    try {
      await serviceLocator<HighWatermarkGuard>().verifyAndAdvance();
    } on ClockTamperedException {
      clockTampered = true;
    }
  }
  runApp(
    MyApp(
      home: clockTampered
          ? const ClockTamperedScreen()
          : AppBootstrap(deviceId: deviceId, initialLicense: storedLicense),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({required this.home, super.key});

  final Widget home;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'نظام تحضير نادي تضامن حضرموت',
      theme: AppTheme.light,
      builder: (context, child) => Directionality(
        textDirection: TextDirection.rtl,
        child: child ?? const SizedBox.shrink(),
      ),
      home: home,
    );
  }
}

class AppBootstrap extends StatefulWidget {
  const AppBootstrap({
    required this.deviceId,
    required this.initialLicense,
    super.key,
  });

  final String deviceId;
  final ActivatedLicense? initialLicense;

  @override
  State<AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends State<AppBootstrap> {
  late ActivatedLicense? _license = widget.initialLicense;
  var _selectedIndex = 0;
  var _masterReady = false;

  @override
  void initState() {
    super.initState();
    if (_license?.role == ActivatedDeviceRole.masterAdmin) _prepareMaster();
  }

  Future<void> _prepareMaster() async {
    await configureMasterDependencies();
    if (mounted) setState(() => _masterReady = true);
  }

  @override
  Widget build(BuildContext context) {
    final license = _license;
    if (license == null) {
      return BlocProvider<ActivationBloc>(
        create: (_) => serviceLocator<ActivationBloc>(),
        child: ActivationScreen(
          deviceId: widget.deviceId,
          onActivated: (activatedLicense) {
            setState(() => _license = activatedLicense);
            if (activatedLicense.role == ActivatedDeviceRole.masterAdmin) {
              _prepareMaster();
            }
          },
        ),
      );
    }

    return switch (license.role) {
      ActivatedDeviceRole.masterAdmin =>
        !_masterReady
            ? const Center(child: CircularProgressIndicator())
            : MasterAdminAppShell(
                selectedIndex: _selectedIndex,
                onDestinationSelected: (index) =>
                    setState(() => _selectedIndex = index),
                child: switch (_selectedIndex) {
                  1 => BlocProvider(
                    create: (_) =>
                        serviceLocator<PlayersBloc>()
                          ..add(const PlayersRequested()),
                    child: const PlayersListScreen(),
                  ),
                  3 => MultiBlocProvider(
                    providers: [
                      BlocProvider(
                        create: (_) =>
                            serviceLocator<SettingsBloc>()
                              ..add(const SettingsRequested()),
                      ),
                      BlocProvider(
                        create: (_) =>
                            serviceLocator<TeamsBloc>()
                              ..add(const TeamsRequested()),
                      ),
                    ],
                    child: const ClubSettingsScreen(),
                  ),
                  _ => const DesignSystemGalleryScreen(),
                },
              ),
      ActivatedDeviceRole.fieldAttendance => FieldAttendanceAppShell(
        child: BlocProvider(
          create: (_) => serviceLocator<AttendanceBloc>(),
          child: const FieldAttendanceFlow(),
        ),
      ),
    };
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.primary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: .center,
          children: [
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
