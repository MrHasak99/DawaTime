import 'dart:convert';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:dawatime/home_page.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'firebase_options.dart';
import 'login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:background_fetch/background_fetch.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
bool notificationsInitialized = false;

final ValueNotifier<ThemeMode> themeModeNotifier = ValueNotifier(
  ThemeMode.system,
);

void backgroundFetchHeadlessTask(HeadlessTask task) async {
  String taskId = task.taskId;
  bool timeout = task.timeout;
  if (timeout) {
    BackgroundFetch.finish(taskId);
    return;
  }
  await Firebase.initializeApp();
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    final now = DateTime.now();
    if (now.hour == 0 && now.minute < 20) {
      await rescheduleAllMedications(user.uid);
    }
  }
  BackgroundFetch.finish(taskId);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final prefs = await SharedPreferences.getInstance();
  final themeString = prefs.getString('themeMode');
  if (themeString == 'dark') {
    themeModeNotifier.value = ThemeMode.dark;
  } else if (themeString == 'light') {
    themeModeNotifier.value = ThemeMode.light;
  } else {
    themeModeNotifier.value = ThemeMode.system;
  }

  themeModeNotifier.addListener(() async {
    final prefs = await SharedPreferences.getInstance();
    if (themeModeNotifier.value == ThemeMode.dark) {
      await prefs.setString('themeMode', 'dark');
    } else if (themeModeNotifier.value == ThemeMode.light) {
      await prefs.setString('themeMode', 'light');
    } else {
      await prefs.setString('themeMode', 'system');
    }
  });

  tz.initializeTimeZones();
  final String timeZoneName = await FlutterTimezone.getLocalTimezone();
  tz.setLocalLocation(tz.getLocation(timeZoneName));

  if (await Permission.notification.isDenied) {
    await Permission.notification.request();
  }

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  final DarwinInitializationSettings initializationSettingsIOS =
      DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) async {
      selectNotificationStream.add(response);
      if (navigatorKey.currentContext != null && response.payload != null) {
        showDialog(
          context: navigatorKey.currentContext!,
          builder:
              (context) => AlertDialog(
                backgroundColor: const Color(0xFF8AC249),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                title: const Text(
                  'Notification',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                content: Text(
                  response.payload!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      'OK',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
        );
      }
    },
  );

  notificationsInitialized = true;

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin
      >()
      ?.requestPermissions(alert: true, badge: true, sound: true);

  final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
      flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
  await androidImplementation?.requestNotificationsPermission();

  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  runApp(const MainApp());

  BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeModeNotifier,
      builder: (context, mode, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          home: const SplashScreen(),
          navigatorKey: navigatorKey,
          theme: ThemeData(
            fontFamily: 'Nunito',
            brightness: Brightness.light,
            primarySwatch: Colors.green,
            scaffoldBackgroundColor: Colors.white,
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF8AC249),
              foregroundColor: Colors.white,
              elevation: 0,
              titleTextStyle: TextStyle(
                fontFamily: 'Nunito',
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF8AC249),
                foregroundColor: Colors.white,
                textStyle: const TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 32,
                ),
              ),
            ),
            inputDecorationTheme: const InputDecorationTheme(
              border: UnderlineInputBorder(),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF8AC249)),
              ),
              labelStyle: TextStyle(
                color: Color(0xFF8AC249),
                fontWeight: FontWeight.bold,
                fontFamily: 'Inter',
              ),
            ),
            snackBarTheme: const SnackBarThemeData(
              backgroundColor: Color(0xFF8AC249),
              contentTextStyle: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontFamily: 'Inter',
              ),
            ),
            textTheme: const TextTheme(
              bodyLarge: TextStyle(fontFamily: 'Nunito', color: Colors.black),
              bodyMedium: TextStyle(fontFamily: 'Nunito', color: Colors.black),
              bodySmall: TextStyle(fontFamily: 'Nunito', color: Colors.black),
              titleLarge: TextStyle(fontFamily: 'Nunito', color: Colors.black),
              titleMedium: TextStyle(fontFamily: 'Nunito', color: Colors.black),
              titleSmall: TextStyle(fontFamily: 'Nunito', color: Colors.black),
              labelLarge: TextStyle(fontFamily: 'Inter', color: Colors.black),
              labelMedium: TextStyle(fontFamily: 'Inter', color: Colors.black),
              labelSmall: TextStyle(fontFamily: 'Inter', color: Colors.black),
              displayLarge: TextStyle(
                fontFamily: 'Nunito',
                color: Colors.black,
              ),
              displayMedium: TextStyle(
                fontFamily: 'Nunito',
                color: Colors.black,
              ),
              displaySmall: TextStyle(
                fontFamily: 'Nunito',
                color: Colors.black,
              ),
              headlineLarge: TextStyle(
                fontFamily: 'Nunito',
                color: Colors.black,
              ),
              headlineMedium: TextStyle(
                fontFamily: 'Nunito',
                color: Colors.black,
              ),
              headlineSmall: TextStyle(
                fontFamily: 'Nunito',
                color: Colors.black,
              ),
            ),
          ),
          darkTheme: ThemeData(
            fontFamily: 'Nunito',
            brightness: Brightness.dark,
            primarySwatch: Colors.green,
            scaffoldBackgroundColor: Colors.black,
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              elevation: 0,
              titleTextStyle: TextStyle(
                fontFamily: 'Nunito',
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            snackBarTheme: const SnackBarThemeData(
              backgroundColor: Color(0xFF8AC249),
              contentTextStyle: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontFamily: 'Inter',
              ),
            ),
            inputDecorationTheme: const InputDecorationTheme(
              border: UnderlineInputBorder(),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF8AC249)),
              ),
              labelStyle: TextStyle(
                color: Color(0xFF8AC249),
                fontWeight: FontWeight.bold,
                fontFamily: 'Inter',
              ),
            ),
            textTheme: const TextTheme(
              bodyLarge: TextStyle(fontFamily: 'Nunito', color: Colors.white),
              bodyMedium: TextStyle(fontFamily: 'Nunito', color: Colors.white),
              bodySmall: TextStyle(fontFamily: 'Nunito', color: Colors.white),
              titleLarge: TextStyle(fontFamily: 'Nunito', color: Colors.white),
              titleMedium: TextStyle(fontFamily: 'Nunito', color: Colors.white),
              titleSmall: TextStyle(fontFamily: 'Nunito', color: Colors.white),
              labelLarge: TextStyle(fontFamily: 'Inter', color: Colors.white),
              labelMedium: TextStyle(fontFamily: 'Inter', color: Colors.white),
              labelSmall: TextStyle(fontFamily: 'Inter', color: Colors.white),
              displayLarge: TextStyle(
                fontFamily: 'Nunito',
                color: Colors.white,
              ),
              displayMedium: TextStyle(
                fontFamily: 'Nunito',
                color: Colors.white,
              ),
              displaySmall: TextStyle(
                fontFamily: 'Nunito',
                color: Colors.white,
              ),
              headlineLarge: TextStyle(
                fontFamily: 'Nunito',
                color: Colors.white,
              ),
              headlineMedium: TextStyle(
                fontFamily: 'Nunito',
                color: Colors.white,
              ),
              headlineSmall: TextStyle(
                fontFamily: 'Nunito',
                color: Colors.white,
              ),
            ),
          ),
          themeMode: mode,
        );
      },
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFF8AC249)),
            ),
          );
        }
        if (snapshot.hasData && snapshot.data != null) {
          return HomePage(uid: snapshot.data!.uid);
        }
        return const LoginPage();
      },
    );
  }
}

Future<Medications?> fetchMedicationByDocId(String docId) async {
  final doc =
      await FirebaseFirestore.instance
          .collection('medications')
          .doc(docId)
          .get();
  if (doc.exists) {
    return medicationFromDoc(doc);
  }
  return null;
}

Future<void> requestExactAlarmPermission() async {
  if (await Permission.scheduleExactAlarm.isDenied) {
    await Permission.scheduleExactAlarm.request();
  }
}

bool isAppInForeground() {
  final state = WidgetsBinding.instance.lifecycleState;
  return state == AppLifecycleState.resumed;
}

Future<void> requestNotificationPermission() async {
  if (await Permission.notification.isDenied) {
    await Permission.notification.request();
  }
}

Future<void> checkFirstInstallAndSignOut() async {
  final prefs = await SharedPreferences.getInstance();
  final isFirstInstall = prefs.getBool('hasRunBefore') ?? false;
  if (!isFirstInstall) {
    await FirebaseAuth.instance.signOut();
    await prefs.setBool('hasRunBefore', true);
  }
}

Future<bool> isUpdateRequired(BuildContext context) async {
  final info = await PackageInfo.fromPlatform();
  final platform =
      Theme.of(context).platform == TargetPlatform.iOS ? 'ios' : 'android';
  final doc =
      await FirebaseFirestore.instance
          .collection('AppConfig')
          .doc('Version')
          .get();
  if (!doc.exists) return false;
  final latestVersion = doc.data()?[platform];
  if (latestVersion == null) return false;
  return _isVersionLower(info.version, latestVersion);
}

bool _isVersionLower(String current, String latest) {
  final currentParts =
      current
          .trim()
          .split('.')
          .map((e) => int.tryParse(e.trim()) ?? 0)
          .toList();
  final latestParts =
      latest.trim().split('.').map((e) => int.tryParse(e.trim()) ?? 0).toList();
  for (int i = 0; i < latestParts.length; i++) {
    if (i >= currentParts.length || currentParts[i] < latestParts[i]) {
      return true;
    }
    if (currentParts[i] > latestParts[i]) return false;
  }
  return false;
}

Future<void> showForceUpdateDialog(BuildContext context) async {
  await showDialog(
    context: context,
    barrierDismissible: false,
    builder:
        (context) => AlertDialog(
          title: const Text('Update Required'),
          content: const Text(
            'A new version of the app is available. Please update to continue.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Replace with your app's store URL
                final url =
                    Theme.of(context).platform == TargetPlatform.iOS
                        ? 'https://apps.apple.com/app/idYOUR_APP_ID'
                        : 'https://play.google.com/store/apps/details?id=YOUR_PACKAGE_NAME';
                launchUrl(Uri.parse(url));
              },
              child: const Text('Update'),
            ),
          ],
        ),
  );
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkUpdateAndNavigate();
  }

  Future<void> _checkUpdateAndNavigate() async {
    final blocked = await isBlockedCountry();
    if (blocked) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (context) => AlertDialog(
              backgroundColor: Colors.red,
              title: const Text(
                'Access Denied',
                style: TextStyle(color: Colors.white),
              ),
              content: const Text(
                'This app is not available in your country.',
                style: TextStyle(color: Colors.white),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    SystemNavigator.pop();
                  },
                  child: const Text(
                    'Exit',
                    style: TextStyle(color: Colors.white, fontFamily: 'Inter'),
                  ),
                ),
              ],
            ),
      );
      return;
    }

    try {
      final updateNeeded = await isUpdateRequired(
        context,
      ).timeout(const Duration(seconds: 8), onTimeout: () => false);
      if (updateNeeded) {
        await showForceUpdateDialog(context);
        return;
      }
    } catch (e) {
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Error'),
              content: const Text(
                'Failed to check for updates. Please try again later.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            ),
      );
      return;
    }
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const AuthGate()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF8AC249),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/DawaTime_white.png", width: 100, height: 100),
            const Text(
              'Dawatime',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
                fontFamily: 'Nunito',
              ),
            ),
            const SizedBox(height: 16),
            const CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}

Future<bool> isBlockedCountry() async {
  final blockedCountries = ['IL'];
  bool blockedByIp = false;
  bool blockedByGps = false;
  try {
    final response = await http.get(Uri.parse('https://ipinfo.io/json'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final countryCode = data['country'];
      if (blockedCountries.contains(countryCode)) {
        blockedByIp = true;
      }
    }
  } catch (_) {}
  try {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (serviceEnabled) {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        final position = await Geolocator.getCurrentPosition();
        final placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        final countryCode = placemarks.first.isoCountryCode;
        if (blockedCountries.contains(countryCode)) {
          blockedByGps = true;
        }
      }
    }
  } catch (_) {}

  return blockedByIp || blockedByGps;
}
