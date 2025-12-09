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
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
bool notificationsInitialized = false;

final ValueNotifier<ThemeMode> themeModeNotifier = ValueNotifier(
  ThemeMode.system,
);

final ValueNotifier<Locale?> localeNotifier = ValueNotifier(null);

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  if (message.data['type'] == 'update_available') {
    final title = message.data['title'] ?? 'New Update Available!';
    final body =
        message.data['body'] ??
        'A new version of DawaTime is available. Tap to update now.';

    const initializationSettingsAndroid = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const initializationSettingsIOS = DarwinInitializationSettings();
    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'updates',
          'App Updates',
          channelDescription: 'Notifications for app updates',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          showWhen: true,
          ongoing: false,
          autoCancel: true,
          icon: 'dawatime_notify',
          sound: RawResourceAndroidNotificationSound('notification_sound'),
          color: Color(0xFF8AC249),
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'notification_sound.wav',
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      999999,
      title,
      body,
      details,
      payload: 'update_available',
    );
  }
}

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
  try {
    WidgetsFlutterBinding.ensureInitialized();
  } catch (e) {
    rethrow;
  }

  if (!kIsWeb) {
    try {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
    } catch (_) {}
  }

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ).timeout(const Duration(seconds: 10));
  } catch (_) {}

  if (!kIsWeb) {
    try {
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
    } catch (_) {}
  }

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

  if (!kIsWeb) {
    try {
      tz.initializeTimeZones();
      final String timeZoneName = await FlutterTimezone.getLocalTimezone()
          .timeout(const Duration(seconds: 5));
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (_) {}

    try {
      if (await Permission.notification.isDenied) {
        await Permission.notification.request().timeout(
          const Duration(seconds: 5),
        );
      }
    } catch (_) {}
  }

  if (!kIsWeb) {
    try {
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('dawatime_notify');

      final DarwinInitializationSettings initializationSettingsIOS =
          DarwinInitializationSettings(
            requestAlertPermission: true,
            requestBadgePermission: true,
            requestSoundPermission: true,
          );

      final InitializationSettings initializationSettings =
          InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsIOS,
          );

      await flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (
          NotificationResponse response,
        ) async {
          selectNotificationStream.add(response);
          if (navigatorKey.currentContext != null && response.payload != null) {
            if (response.payload == 'update_available') {
              final context = navigatorKey.currentContext!;
              await showForceUpdateDialog(context);
              return;
            }

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
    } catch (_) {}
    try {
      final messaging = FirebaseMessaging.instance;
      FirebaseMessaging.onBackgroundMessage(
        _firebaseMessagingBackgroundHandler,
      );

      await messaging.requestPermission(alert: true, badge: true, sound: true);

      final token = await messaging.getToken();
      if (token != null) {}

      FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
        if (message.data['type'] == 'update_available') {
          final title = message.data['title'] ?? 'New Update Available!';
          final body =
              message.data['body'] ??
              'A new version of DawaTime is available. Tap to update now.';

          const AndroidNotificationDetails androidDetails =
              AndroidNotificationDetails(
                'updates',
                'App Updates',
                channelDescription: 'Notifications for app updates',
                importance: Importance.max,
                priority: Priority.high,
                playSound: true,
                showWhen: true,
                ongoing: false,
                autoCancel: true,
                icon: 'dawatime_notify',
                sound: RawResourceAndroidNotificationSound(
                  'notification_sound',
                ),
                color: Color(0xFF8AC249),
              );

          const DarwinNotificationDetails iosDetails =
              DarwinNotificationDetails(
                presentAlert: true,
                presentBadge: true,
                presentSound: true,
                sound: 'notification_sound.wav',
              );

          const NotificationDetails details = NotificationDetails(
            android: androidDetails,
            iOS: iosDetails,
          );

          await flutterLocalNotificationsPlugin.show(
            999999,
            title,
            body,
            details,
            payload: 'update_available',
          );
        }
      });

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        if (message.data['type'] == 'update_available') {
          Future.delayed(const Duration(milliseconds: 500), () {
            if (navigatorKey.currentContext != null) {
              showForceUpdateDialog(navigatorKey.currentContext!);
            }
          });
        }
      });

      final initialMessage = await messaging.getInitialMessage();
      if (initialMessage != null &&
          initialMessage.data['type'] == 'update_available') {
        Future.delayed(const Duration(seconds: 2), () {
          if (navigatorKey.currentContext != null) {
            showForceUpdateDialog(navigatorKey.currentContext!);
          }
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('FCM initialization error: $e');
      }
    }
  }

  try {
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

    FlutterError.onError = (errorDetails) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  } catch (_) {}

  try {
    if (kIsWeb) {
      await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
    }
  } catch (_) {}

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

  Future<void> _saveFCMToken(String uid) async {
    if (kIsWeb) return;

    try {
      final messaging = FirebaseMessaging.instance;
      final token = await messaging.getToken();

      if (token != null) {
        final prefs = await SharedPreferences.getInstance();
        final preferredLang = prefs.getString('preferredLanguage') ?? 'en';

        await FirebaseFirestore.instance.collection('Users').doc(uid).set({
          'fcmToken': token,
          'preferredLanguage': preferredLang,
        }, SetOptions(merge: true));
      } else {}
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error saving FCM token: $e');
      }
    }
  }

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
          final user = snapshot.data!;
          _saveFCMToken(user.uid);
          return HomePage(uid: user.uid);
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
  if (kIsWeb) return;

  try {
    final status = await Permission.scheduleExactAlarm.status;
    if (status.isGranted) {
      return;
    }
  } catch (e) {
    if (kDebugMode) {
      print('Error checking exact alarm permission: $e');
    }
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

Future<bool> _shouldCheckForUpdates() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final lastCheckTime = prefs.getInt('last_update_check') ?? 0;
    final currentTime = DateTime.now().millisecondsSinceEpoch;

    const updateCheckInterval = 24 * 60 * 60 * 1000;

    if (currentTime - lastCheckTime >= updateCheckInterval) {
      await prefs.setInt('last_update_check', currentTime);
      return true;
    }
    return false;
  } catch (e) {
    if (kDebugMode) {
      print('Error checking update frequency: $e');
    }
    return true;
  }
}

Future<bool> isUpdateRequired(
  BuildContext context, {
  bool forceCheck = false,
}) async {
  if (kIsWeb) return false;

  if (!forceCheck) {
    final shouldCheck = await _shouldCheckForUpdates();
    if (!shouldCheck) {
      if (kDebugMode) {
        print('Skipping update check - checked recently');
      }
      return false;
    }
  }

  try {
    final info = await PackageInfo.fromPlatform();
    final doc = await FirebaseFirestore.instance
        .collection('AppConfig')
        .doc('Version')
        .get()
        .timeout(const Duration(seconds: 3));

    if (!doc.exists) return false;
    final latestVersion = doc.data()?['version'];
    if (latestVersion == null) return false;
    final isOutdated = _isVersionLower(info.version, latestVersion);
    if (kDebugMode) {
      print(
        'Update check: Current ${info.version} vs Latest $latestVersion = ${isOutdated ? 'Update needed' : 'Up to date'}',
      );
    }
    return isOutdated;
  } catch (e) {
    if (kDebugMode) {
      print('Error checking for updates: $e');
    }
    return false;
  }
}

Future<bool> forceUpdateCheck(BuildContext context) async {
  return await isUpdateRequired(context, forceCheck: true);
}

Future<void> resetUpdateCheckTimer() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('last_update_check');
    if (kDebugMode) {
      print('Update check timer reset');
    }
  } catch (e) {
    if (kDebugMode) {
      print('Error resetting update check timer: $e');
    }
  }
}

Future<DateTime?> getLastUpdateCheckTime() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final lastCheckTime = prefs.getInt('last_update_check');
    if (lastCheckTime != null) {
      return DateTime.fromMillisecondsSinceEpoch(lastCheckTime);
    }
    return null;
  } catch (e) {
    if (kDebugMode) {
      print('Error getting last update check time: $e');
    }
    return null;
  }
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
                        : 'https://dawatime.com';
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
        const Duration(seconds: 3),
        onTimeout: () => false,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error checking blocked country: $e');
      }
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
      final updateNeeded = await isUpdateRequired(context);
      if (updateNeeded) {
        await showForceUpdateDialog(context);
        SystemNavigator.pop();
        return;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error checking for updates: $e');
      }
    }
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) {
      return;
    }
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
  if (kIsWeb) return false;

  final blockedCountries = ['IL'];
  bool blockedByIp = false;
  bool blockedByGps = false;
  try {
    final response = await http
        .get(Uri.parse('https://ipinfo.io/json'))
        .timeout(const Duration(seconds: 2));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final countryCode = data['country'];
      if (blockedCountries.contains(countryCode)) {
        blockedByIp = true;
      }
    }
  } catch (e) {
    if (kDebugMode) {
      print('IP check failed: $e');
    }
  }
  try {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled().timeout(
      const Duration(seconds: 1),
    );
    if (serviceEnabled) {
      LocationPermission permission = await Geolocator.checkPermission()
          .timeout(const Duration(seconds: 1));
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission().timeout(
          const Duration(seconds: 1),
        );
      }
      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        final position = await Geolocator.getCurrentPosition().timeout(
          const Duration(seconds: 2),
        );
        final placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        ).timeout(const Duration(seconds: 1));
        final countryCode = placemarks.first.isoCountryCode;
        if (blockedCountries.contains(countryCode)) {
          blockedByGps = true;
        }
      }
    }
  } catch (e) {
    if (kDebugMode) {
      print('GPS check failed: $e');
    }
  }

  return blockedByIp || blockedByGps;
}
