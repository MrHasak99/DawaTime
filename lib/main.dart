import 'dart:convert';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dawatime/l10n/app_localizations.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:dawatime/home_page.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:workmanager/workmanager.dart';
import 'firebase_options.dart';
import 'login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_localizations/flutter_localizations.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
bool notificationsInitialized = false;

final ValueNotifier<ThemeMode> themeModeNotifier = ValueNotifier(
  ThemeMode.system,
);

final ValueNotifier<Locale?> localeNotifier = ValueNotifier(null);

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    await Firebase.initializeApp();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final now = DateTime.now();
      if (now.hour == 0 && now.minute < 20) {
        await rescheduleAllMedications(user.uid);
      }
    }
    return Future.value(true);
  });
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  Workmanager().initialize(callbackDispatcher);

  Workmanager().registerPeriodicTask(
    "medicationRescheduleTask",
    "medicationRescheduleTask",
    frequency: Duration(hours: 1),
    initialDelay: Duration(minutes: 1),
    constraints: Constraints(
      networkType: NetworkType.notRequired,
      requiresBatteryNotLow: false,
      requiresCharging: false,
      requiresDeviceIdle: false,
      requiresStorageNotLow: false,
    ),
  );

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
  final preferredLang = prefs.getString('preferredLanguage');
  if (preferredLang != null) {
    localeNotifier.value = Locale(preferredLang);
  }

  tz.initializeTimeZones();
  final String timeZoneName = await FlutterTimezone.getLocalTimezone();
  tz.setLocalLocation(tz.getLocation(timeZoneName));

  if (await Permission.notification.isDenied) {
    await Permission.notification.request();
  }

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('dawatime_notify');

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
                title: Text(
                  AppLocalizations.of(context)!.notification,
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
                    child: Text(
                      AppLocalizations.of(context)!.ok,
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

  if (kIsWeb) {
    await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
  }

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  static void setLocale(BuildContext context, Locale newLocale) {
    localeNotifier.value = newLocale;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeModeNotifier,
      builder: (context, themeMode, _) {
        return ValueListenableBuilder<Locale?>(
          valueListenable: localeNotifier,
          builder: (context, locale, _) {
            final currentLocale =
                locale ?? WidgetsBinding.instance.platformDispatcher.locale;
            final isArabic = currentLocale.languageCode == 'ar';

            return MaterialApp(
              debugShowCheckedModeBanner: false,
              home: const SplashScreen(),
              navigatorKey: navigatorKey,
              supportedLocales: const [Locale('en'), Locale('ar')],
              locale: locale,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              theme: ThemeData(
                fontFamily: isArabic ? 'NotoKufiArabic' : 'Nunito',
                brightness: Brightness.light,
                primarySwatch: Colors.green,
                scaffoldBackgroundColor: Colors.white,
                appBarTheme: AppBarTheme(
                  backgroundColor: const Color(0xFF8AC249),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  titleTextStyle: TextStyle(
                    fontFamily: isArabic ? 'NotoKufiArabic' : 'Nunito',
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
                elevatedButtonTheme: ElevatedButtonThemeData(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8AC249),
                    foregroundColor: Colors.white,
                    textStyle: TextStyle(
                      fontFamily: isArabic ? 'NotoKufiArabic' : 'Nunito',
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
                textTheme: ThemeData.light().textTheme.apply(
                  fontFamily: isArabic ? 'NotoKufiArabic' : 'Nunito',
                ),
              ),
              darkTheme: ThemeData(
                fontFamily: isArabic ? 'NotoKufiArabic' : 'Nunito',
                brightness: Brightness.dark,
                primarySwatch: Colors.green,
                scaffoldBackgroundColor: Colors.black,
                appBarTheme: AppBarTheme(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  titleTextStyle: TextStyle(
                    fontFamily: isArabic ? 'NotoKufiArabic' : 'Nunito',
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
                textTheme: ThemeData.dark().textTheme.apply(
                  fontFamily: isArabic ? 'NotoKufiArabic' : 'Nunito',
                ),
              ),
              themeMode: themeMode,
              builder: (context, child) {
                return Directionality(
                  textDirection:
                      isArabic ? TextDirection.rtl : TextDirection.ltr,
                  child: child!,
                );
              },
            );
          },
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
  final isFirstInstall = prefs.getBool('hasRunBefore');
  if (isFirstInstall == null) {
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
          backgroundColor: Colors.red,
          title: Text(
            AppLocalizations.of(context)!.updateRequired,
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            AppLocalizations.of(context)!.pleaseUpdate,
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              onPressed: () {
                final url =
                    Theme.of(context).platform == TargetPlatform.iOS
                        ? 'https://apps.apple.com/app/6748280994'
                        : 'https://play.google.com/store/apps/details?id=com.mrhasak99.dawatime';
                launchUrl(Uri.parse(url));
              },
              child: Text(
                AppLocalizations.of(context)!.update,
                style: TextStyle(color: Colors.white),
              ),
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
    _handleFirstInstall();
    _checkUpdateAndNavigate();
  }

  Future<void> _handleFirstInstall() async {
    final prefs = await SharedPreferences.getInstance();
    final isFirstInstall = prefs.getBool('hasRunBefore');
    if (isFirstInstall == null) {
      await prefs.setBool('hasRunBefore', true);
    }
  }

  Future<void> _checkUpdateAndNavigate() async {
    bool blocked = false;
    try {
      blocked = await isBlockedCountry().timeout(
        const Duration(seconds: 8),
        onTimeout: () => false,
      );
    } catch (e, stack) {
      FirebaseCrashlytics.instance.recordError(e, stack);
    }
    if (blocked) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (context) => AlertDialog(
              backgroundColor: Colors.red,
              title: Text(
                AppLocalizations.of(context)!.accessDenied,
                style: TextStyle(color: Colors.white),
              ),
              content: Text(
                AppLocalizations.of(context)!.notAvailable,
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
        SystemNavigator.pop();
        return;
      }
    } catch (e, stack) {
      FirebaseCrashlytics.instance.recordError(e, stack);
      await showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              backgroundColor: Colors.red,
              title: Text(
                AppLocalizations.of(context)!.error,
                style: TextStyle(color: Colors.white),
              ),
              content: Text(
                AppLocalizations.of(context)!.failedUpdateCheck,
                style: TextStyle(color: Colors.white),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    AppLocalizations.of(context)!.ok,
                    style: TextStyle(color: Colors.white, fontFamily: 'Inter'),
                  ),
                ),
              ],
            ),
      );
      if (mounted) {
        Navigator.of(
          context,
        ).pushReplacement(MaterialPageRoute(builder: (_) => const AuthGate()));
      }
      return;
    }
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const AuthGate()));
  }

  void _showIntroGuide() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color(0xFF8AC249),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            title: Text(
              AppLocalizations.of(context)!.appGuide,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.getStarted,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    '${AppLocalizations.of(context)!.addMedicationBody2}\n'
                    '${AppLocalizations.of(context)!.setReminders}\n'
                    '${AppLocalizations.of(context)!.viewDetails}\n'
                    '${AppLocalizations.of(context)!.swipe}\n'
                    '${AppLocalizations.of(context)!.checkReminders}\n'
                    '${AppLocalizations.of(context)!.manageProfile}.\n',
                    style: TextStyle(color: Colors.white, fontSize: 15),
                  ),
                  SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context)!.medicationNotifications,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  AppLocalizations.of(context)!.gotIt,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF8AC249),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/DawaTime_white.png", width: 100, height: 100),
            Text(
              AppLocalizations.of(context)!.appTitle,
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
                fontFamily: 'Nunito',
              ),
            ),
            const SizedBox(height: 16),
            const CircularProgressIndicator(color: Colors.white),
            const SizedBox(height: 32),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
              onPressed: _showIntroGuide,
              child: Text(
                AppLocalizations.of(context)!.appGuide,
                style: TextStyle(
                  color: Color(0xFF8AC249),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () {
                    launchUrl(
                      Uri.parse('https://dawatime.com/PrivacyPolicy.pdf'),
                      mode: LaunchMode.externalApplication,
                    );
                  },
                  child: Text(
                    AppLocalizations.of(context)!.privacyPolicy,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 16),
                TextButton(
                  onPressed: () {
                    launchUrl(
                      Uri.parse('https://dawatime.com/Terms&Conditions.pdf'),
                      mode: LaunchMode.externalApplication,
                    );
                  },
                  child: Text(
                    AppLocalizations.of(context)!.termsAndConditions,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
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
    final response = await http
        .get(Uri.parse('https://ipinfo.io/json'))
        .timeout(const Duration(seconds: 5));
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
        final position = await Geolocator.getCurrentPosition().timeout(
          const Duration(seconds: 5),
        );
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
