import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dawatime/l10n/app_localizations.dart';
import 'package:dawatime/utils/medication_helpers.dart';
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
  if (preferredLang != null && preferredLang != 'system') {
    localeNotifier.value = Locale(preferredLang);
  }

  if (!kIsWeb) {
    try {
      tz.initializeTimeZones();
      final String timeZoneName = await FlutterTimezone.getLocalTimezone()
          .timeout(const Duration(seconds: 5));
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (e) {
      tz.setLocalLocation(tz.getLocation('UTC'));
    }
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
    } catch (_) {}
    try {
      final messaging = FirebaseMessaging.instance;
      FirebaseMessaging.onBackgroundMessage(
        _firebaseMessagingBackgroundHandler,
      );

      await messaging.requestPermission(alert: true, badge: true, sound: true);
      if (Platform.isIOS) {
        try {
          await messaging.getAPNSToken();
        } catch (_) {}
      }

      await messaging.getToken();

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
                interruptionLevel: InterruptionLevel.timeSensitive,
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

      messaging.onTokenRefresh.listen((newToken) {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          FirebaseFirestore.instance
              .collection('Users')
              .doc(user.uid)
              .update({'fcmToken': newToken})
              .catchError((_) {});
        }
      });
    } catch (_) {}
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

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  String? _lastCheckedUserId;
  bool _showingLegalDialog = false;

  Future<void> _saveFCMToken(String uid) async {
    if (kIsWeb) return;

    try {
      final messaging = FirebaseMessaging.instance;
      if (Theme.of(navigatorKey.currentContext!).platform ==
          TargetPlatform.iOS) {
        try {
          final apnsToken = await messaging.getAPNSToken();
          if (apnsToken == null) {
            await Future.delayed(const Duration(seconds: 2));
            await messaging.getAPNSToken();
          }
        } catch (_) {}
      }

      final token = await messaging.getToken();

      if (token != null) {
        final prefs = await SharedPreferences.getInstance();
        final preferredLang = prefs.getString('preferredLanguage') ?? 'en';
        final packageInfo = await PackageInfo.fromPlatform();
        final appVersion = packageInfo.version;

        await FirebaseFirestore.instance.collection('Users').doc(uid).set({
          'fcmToken': token,
          'preferredLanguage': preferredLang,
          'lastAppVersion': appVersion,
          'lastAccessedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    } catch (_) {}
  }

  Future<bool> _checkLegalDocumentVersions(String uid) async {
    try {
      final configDoc =
          await FirebaseFirestore.instance
              .collection('AppConfig')
              .doc('LegalDocuments')
              .get();

      if (!configDoc.exists) {
        return false;
      }

      final currentTermsVersion = configDoc.data()?['termsVersion'] ?? '1.0';
      final currentPrivacyVersion =
          configDoc.data()?['privacyVersion'] ?? '1.0';

      final userDoc =
          await FirebaseFirestore.instance.collection('Users').doc(uid).get();

      if (!userDoc.exists) {
        return false;
      }

      final acceptedTermsVersion =
          userDoc.data()?['acceptedTermsVersion'] ?? '0.0';
      final acceptedPrivacyVersion =
          userDoc.data()?['acceptedPrivacyVersion'] ?? '0.0';

      return acceptedTermsVersion != currentTermsVersion ||
          acceptedPrivacyVersion != currentPrivacyVersion;
    } catch (e) {
      return false;
    }
  }

  Future<void> _showLegalUpdateDialog(String uid) async {
    bool accepted = false;
    final loc = AppLocalizations.of(context)!;

    setState(() {
      _showingLegalDialog = true;
    });

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => StatefulBuilder(
            builder: (context, setDialogState) {
              return PopScope(
                canPop: false,
                onPopInvokedWithResult: (didPop, result) {},
                child: AlertDialog(
                  backgroundColor: const Color(0xFF8AC249),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          loc.legalUpdateRequired,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            fontFamily: 'Nunito',
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          loc.legalUpdateMessage,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontFamily: 'Inter',
                          ),
                        ),
                        const SizedBox(height: 20),
                        Center(
                          child: Column(
                            children: [
                              ElevatedButton(
                                onPressed: () async {
                                  await launchUrl(
                                    Uri.parse(
                                      'https://dawatime.com/terms-and-conditions.html',
                                    ),
                                    mode: LaunchMode.externalApplication,
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: const Color(0xFF8AC249),
                                  minimumSize: const Size(220, 45),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  loc.viewTerms,
                                  style: const TextStyle(fontFamily: 'Inter'),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(height: 10),
                              ElevatedButton(
                                onPressed: () async {
                                  await launchUrl(
                                    Uri.parse(
                                      'https://dawatime.com/privacy-policy.html',
                                    ),
                                    mode: LaunchMode.externalApplication,
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: const Color(0xFF8AC249),
                                  minimumSize: const Size(220, 45),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  loc.viewPrivacy,
                                  style: const TextStyle(fontFamily: 'Inter'),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.all(8),
                          child: CheckboxListTile(
                            value: accepted,
                            onChanged: (value) {
                              setDialogState(() {
                                accepted = value ?? false;
                              });
                            },
                            title: Text(
                              loc.acceptUpdatedLegal,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontFamily: 'Inter',
                              ),
                            ),
                            activeColor: Colors.white,
                            checkColor: const Color(0xFF8AC249),
                            controlAffinity: ListTileControlAffinity.leading,
                          ),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();
                        if (!context.mounted) return;
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        loc.declineAndLogout,
                        style: const TextStyle(
                          color: Colors.white,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed:
                          accepted
                              ? () async {
                                try {
                                  final configDoc =
                                      await FirebaseFirestore.instance
                                          .collection('AppConfig')
                                          .doc('LegalDocuments')
                                          .get();

                                  final currentTermsVersion =
                                      configDoc.data()?['termsVersion'] ??
                                      '1.0';
                                  final currentPrivacyVersion =
                                      configDoc.data()?['privacyVersion'] ??
                                      '1.0';

                                  await FirebaseFirestore.instance
                                      .collection('Users')
                                      .doc(uid)
                                      .update({
                                        'acceptedTermsVersion':
                                            currentTermsVersion,
                                        'acceptedPrivacyVersion':
                                            currentPrivacyVersion,
                                        'legalAcceptanceDate':
                                            DateTime.now().toIso8601String(),
                                      });

                                  if (!context.mounted) return;
                                  Navigator.of(context).pop();

                                  if (mounted) {
                                    setState(() {
                                      _lastCheckedUserId = uid;
                                      _showingLegalDialog = false;
                                    });
                                  }
                                } catch (e) {
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Error updating acceptance. Please try again.',
                                      ),
                                      backgroundColor: Colors.red,
                                      persist: false,
                                    ),
                                  );
                                }
                              }
                              : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF8AC249),
                        disabledBackgroundColor: Colors.white.withValues(
                          alpha: 0.5,
                        ),
                        disabledForegroundColor: const Color(
                          0xFF8AC249,
                        ).withValues(alpha: 0.5),
                      ),
                      child: Text(
                        loc.acceptButton,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
    );
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

        if (!snapshot.hasData) {
          if (_lastCheckedUserId != null || _showingLegalDialog) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() {
                  _lastCheckedUserId = null;
                  _showingLegalDialog = false;
                });
              }
            });
          }
          return const LoginPage();
        }

        if (snapshot.hasData && snapshot.data != null) {
          final user = snapshot.data!;

          return FutureBuilder<bool>(
            key: ValueKey(user.uid + (_lastCheckedUserId ?? '')),
            future: _checkLegalDocumentVersions(user.uid),
            builder: (context, legalSnapshot) {
              if (legalSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(color: Color(0xFF8AC249)),
                  ),
                );
              }

              if ((legalSnapshot.data == true &&
                      _lastCheckedUserId != user.uid) ||
                  _showingLegalDialog) {
                if (!_showingLegalDialog) {
                  WidgetsBinding.instance.addPostFrameCallback((_) async {
                    if (mounted) {
                      await _showLegalUpdateDialog(user.uid);
                    }
                  });
                }
                return const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(color: Color(0xFF8AC249)),
                  ),
                );
              }

              if (_lastCheckedUserId != user.uid) {
                _lastCheckedUserId = user.uid;
              }

              _saveFCMToken(user.uid);
              return HomePage(uid: user.uid);
            },
          );
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
  } catch (_) {}
}

bool isAppInForeground() {
  final state = WidgetsBinding.instance.lifecycleState;
  return state == AppLifecycleState.resumed;
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
    return isOutdated;
  } catch (e) {
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
  } catch (_) {}
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
  bool _isShowingGuide = false;
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
    } catch (_) {}
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
    } catch (_) {}
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final legalUpdateNeeded = await _checkLegalDocumentVersions(user.uid);
        if (legalUpdateNeeded) {
          await _showLegalUpdateDialog(user.uid);
          if (!mounted) return;
        }
      } catch (_) {}
    }
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted || _isShowingGuide) {
      return;
    }
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const AuthGate()));
  }

  Future<void> _showIntroGuide() async {
    setState(() {
      _isShowingGuide = true;
    });

    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color(0xFF8AC249),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            title: Text(
              AppLocalizations.of(context)!.appGuide,
              style: const TextStyle(
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
                    '${AppLocalizations.of(context)!.stockRefillGuide}\n'
                    '${AppLocalizations.of(context)!.checkReminders}\n'
                    '${AppLocalizations.of(context)!.manageProfile}\n',
                    style: const TextStyle(color: Colors.white, fontSize: 15),
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
    if (mounted) {
      setState(() {
        _isShowingGuide = false;
      });
      if (!mounted) return;
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const AuthGate()));
    }
  }

  Future<bool> _checkLegalDocumentVersions(String uid) async {
    try {
      final configDoc =
          await FirebaseFirestore.instance
              .collection('AppConfig')
              .doc('LegalDocuments')
              .get();

      if (!configDoc.exists) {
        return false;
      }

      final currentTermsVersion = configDoc.data()?['termsVersion'] ?? '1.0';
      final currentPrivacyVersion =
          configDoc.data()?['privacyVersion'] ?? '1.0';

      final userDoc =
          await FirebaseFirestore.instance.collection('Users').doc(uid).get();

      if (!userDoc.exists) {
        return false;
      }

      final acceptedTermsVersion =
          userDoc.data()?['acceptedTermsVersion'] ?? '0.0';
      final acceptedPrivacyVersion =
          userDoc.data()?['acceptedPrivacyVersion'] ?? '0.0';

      return acceptedTermsVersion != currentTermsVersion ||
          acceptedPrivacyVersion != currentPrivacyVersion;
    } catch (e) {
      return false;
    }
  }

  Future<void> _showLegalUpdateDialog(String uid) async {
    bool accepted = false;
    final loc = AppLocalizations.of(context)!;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => StatefulBuilder(
            builder: (context, setDialogState) {
              return PopScope(
                canPop: false,
                onPopInvokedWithResult: (didPop, result) {},
                child: AlertDialog(
                  backgroundColor: const Color(0xFF8AC249),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          loc.legalUpdateRequired,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            fontFamily: 'Nunito',
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          loc.legalUpdateMessage,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontFamily: 'Inter',
                          ),
                        ),
                        const SizedBox(height: 20),
                        Center(
                          child: Column(
                            children: [
                              ElevatedButton(
                                onPressed: () async {
                                  await launchUrl(
                                    Uri.parse(
                                      'https://dawatime.com/terms-and-conditions.html',
                                    ),
                                    mode: LaunchMode.externalApplication,
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: const Color(0xFF8AC249),
                                  minimumSize: const Size(220, 45),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Center(
                                      child: Text(
                                        loc.viewTerms,
                                        style: const TextStyle(
                                          fontFamily: 'Inter',
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),
                              ElevatedButton(
                                onPressed: () async {
                                  await launchUrl(
                                    Uri.parse(
                                      'https://dawatime.com/privacy-policy.html',
                                    ),
                                    mode: LaunchMode.externalApplication,
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: const Color(0xFF8AC249),
                                  minimumSize: const Size(220, 45),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Center(
                                      child: Text(
                                        loc.viewPrivacy,
                                        style: const TextStyle(
                                          fontFamily: 'Inter',
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.all(8),
                          child: CheckboxListTile(
                            value: accepted,
                            onChanged: (value) {
                              setDialogState(() {
                                accepted = value ?? false;
                              });
                            },
                            title: Text(
                              loc.acceptUpdatedLegal,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontFamily: 'Inter',
                              ),
                            ),
                            activeColor: Colors.white,
                            checkColor: const Color(0xFF8AC249),
                            controlAffinity: ListTileControlAffinity.leading,
                          ),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();
                        if (!context.mounted) return;
                        Navigator.of(context).pop();
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (_) => const LoginPage()),
                        );
                      },
                      child: Text(
                        loc.declineAndLogout,
                        style: const TextStyle(
                          color: Colors.white,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed:
                          accepted
                              ? () async {
                                try {
                                  final configDoc =
                                      await FirebaseFirestore.instance
                                          .collection('AppConfig')
                                          .doc('LegalDocuments')
                                          .get();

                                  final currentTermsVersion =
                                      configDoc.data()?['termsVersion'] ??
                                      '1.0';
                                  final currentPrivacyVersion =
                                      configDoc.data()?['privacyVersion'] ??
                                      '1.0';

                                  await FirebaseFirestore.instance
                                      .collection('Users')
                                      .doc(uid)
                                      .update({
                                        'acceptedTermsVersion':
                                            currentTermsVersion,
                                        'acceptedPrivacyVersion':
                                            currentPrivacyVersion,
                                        'legalAcceptanceDate':
                                            DateTime.now().toIso8601String(),
                                      });

                                  if (!context.mounted) return;
                                  Navigator.of(context).pop();
                                } catch (e) {
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Error updating acceptance. Please try again.',
                                      ),
                                      backgroundColor: Colors.red,
                                      persist: false,
                                    ),
                                  );
                                }
                              }
                              : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF8AC249),
                        disabledBackgroundColor: Colors.white.withValues(
                          alpha: 0.5,
                        ),
                        disabledForegroundColor: const Color(
                          0xFF8AC249,
                        ).withValues(alpha: 0.5),
                      ),
                      child: Text(
                        loc.acceptButton,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
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
                      Uri.parse('https://dawatime.com/privacy-policy.html'),
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
                      Uri.parse(
                        'https://dawatime.com/terms-and-conditions.html',
                      ),
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
  } catch (_) {}
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
  } catch (_) {}

  return blockedByIp || blockedByGps;
}
