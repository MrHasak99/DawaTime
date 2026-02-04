import 'package:dawatime/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:dawatime/home_page.dart';
import 'package:dawatime/signup_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dawatime/l10n/app_localizations.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:cloud_functions/cloud_functions.dart';

class LoginPage extends StatefulWidget {
  final bool showAccountDeletedMessage;
  const LoginPage({super.key, this.showAccountDeletedMessage = false});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;
  bool _obscurePassword = true;
  bool _emailError = false;
  bool _passwordError = false;

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
              AppLocalizations.of(context)!.welcomeToDawaTime,
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
                      fontSize: 18,
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

  Future<void> _updateLoginMetadata(String uid) async {
    if (kIsWeb) return;

    try {
      final messaging = FirebaseMessaging.instance;

      if (!kIsWeb && Platform.isIOS) {
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

  Future<bool> _verifyPlayIntegrity() async {
    if (kIsWeb || !Platform.isAndroid) return true;

    try {
      if (kDebugMode) {
        print('🔐 Starting Play Integrity verification...');
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final userId = FirebaseAuth.instance.currentUser?.uid ?? 'login_pending';
      final nonce = '$userId:$timestamp'.codeUnits.toString();

      const channel = MethodChannel('com.mrhasak99.dawatime/play_integrity');
      final integrityToken = await channel.invokeMethod<String>(
        'requestIntegrityToken',
        {'cloudProjectNumber': 173965270100, 'nonce': nonce},
      );

      if (integrityToken == null || integrityToken.isEmpty) {
        if (kDebugMode) {
          print('⚠️ Play Integrity token is null/empty');
        }
        return true;
      }

      final callable = FirebaseFunctions.instance.httpsCallable(
        'verifyPlayIntegrity',
      );

      final result = await callable.call<Map<String, dynamic>>({
        'token': integrityToken,
      });

      final verified = result.data['verified'] as bool? ?? false;
      final action = result.data['action'] as String? ?? 'allow';

      if (kDebugMode) {
        print(
          '✓ Play Integrity verification result: verified=$verified, action=$action',
        );
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Play Integrity verification error: $e');
      }
      return true;
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
                                  try {
                                    final url = Uri.parse(
                                      'https://dawatime.com/terms-and-conditions',
                                    );
                                    if (await canLaunchUrl(url)) {
                                      await launchUrl(
                                        url,
                                        mode: LaunchMode.externalApplication,
                                      );
                                    }
                                  } catch (e) {
                                    // Silent fail
                                  }
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
                                  try {
                                    final url = Uri.parse(
                                      'https://dawatime.com/privacy-policy',
                                    );
                                    if (await canLaunchUrl(url)) {
                                      await launchUrl(
                                        url,
                                        mode: LaunchMode.externalApplication,
                                      );
                                    }
                                  } catch (e) {
                                    // Silent fail
                                  }
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
    if (widget.showAccountDeletedMessage) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Color(0xFF8AC249),
            content: Text(
              AppLocalizations.of(context)!.accountDeleted,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontFamily: 'Inter',
              ),
            ),
            persist: false,
          ),
        );
      });
    }
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFF8AC249),
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(AppLocalizations.of(context)!.welcomeToDawaTime),
            centerTitle: true,
          ),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: () {
                            localeNotifier.value = const Locale('en');
                          },
                          child: Text(
                            'English',
                            style: TextStyle(
                              color:
                                  localeNotifier.value?.languageCode == 'en'
                                      ? const Color(0xFF8AC249)
                                      : Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text('|', style: TextStyle(color: Colors.grey)),
                        const SizedBox(width: 8),
                        TextButton(
                          onPressed: () {
                            localeNotifier.value = const Locale('ar');
                          },
                          child: Text(
                            'العربية',
                            style: TextStyle(
                              color:
                                  localeNotifier.value?.languageCode == 'ar'
                                      ? const Color(0xFF8AC249)
                                      : Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Image.asset("assets/DawaTime_green.png", height: 80),
                  const SizedBox(height: 24),
                  TextField(
                    controller: emailController,
                    cursorColor: Color(0xFF8AC249),
                    keyboardType: TextInputType.emailAddress,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    onChanged: (value) {
                      if (_emailError && value.isNotEmpty) {
                        setState(() => _emailError = false);
                      }
                    },
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.email,
                      labelStyle: TextStyle(
                        color: _emailError ? Colors.red : Color(0xFF8AC249),
                        fontWeight: FontWeight.bold,
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: _emailError ? Colors.red : Color(0xFF8AC249),
                        ),
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: _emailError ? Colors.red : Color(0xFF8AC249),
                        ),
                      ),
                      errorText:
                          _emailError
                              ? AppLocalizations.of(
                                context,
                              )!.pleaseFillAllFields
                              : null,
                    ),
                  ),
                  TextField(
                    controller: passwordController,
                    cursorColor: Color(0xFF8AC249),
                    keyboardType: TextInputType.visiblePassword,
                    obscureText: _obscurePassword,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    onChanged: (value) {
                      if (_passwordError && value.isNotEmpty) {
                        setState(() => _passwordError = false);
                      }
                    },
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.password,
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color:
                              _passwordError ? Colors.red : Color(0xFF8AC249),
                        ),
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color:
                              _passwordError ? Colors.red : Color(0xFF8AC249),
                        ),
                      ),
                      labelStyle: TextStyle(
                        color: _passwordError ? Colors.red : Color(0xFF8AC249),
                        fontWeight: FontWeight.bold,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_rounded
                              : Icons.visibility_rounded,
                          color: Color(0xFF8AC249),
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      errorText:
                          _passwordError
                              ? AppLocalizations.of(
                                context,
                              )!.pleaseFillAllFields
                              : null,
                    ),
                  ),
                  const SizedBox(height: 24),
                  isLoading
                      ? const CircularProgressIndicator(
                        color: Color(0xFF8AC249),
                      )
                      : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF8AC249),
                        ),
                        onPressed: () async {
                          setState(() {
                            _emailError = false;
                            _passwordError = false;
                          });

                          if (emailController.text.trim().isEmpty ||
                              passwordController.text.trim().isEmpty) {
                            setState(() {
                              if (emailController.text.trim().isEmpty) {
                                _emailError = true;
                              }
                              if (passwordController.text.trim().isEmpty) {
                                _passwordError = true;
                              }
                            });
                            return;
                          }

                          setState(() => isLoading = true);
                          try {
                            final userCredential = await FirebaseAuth.instance
                                .signInWithEmailAndPassword(
                                  email: emailController.text.trim(),
                                  password: passwordController.text.trim(),
                                );
                            final user = userCredential.user;
                            if (user != null && !user.emailVerified) {
                              await FirebaseAuth.instance.signOut();
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: Color(0xFF8AC249),
                                    content: Text(
                                      AppLocalizations.of(
                                        context,
                                      )!.pleaseVerfiy,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Inter',
                                      ),
                                    ),
                                    persist: false,
                                  ),
                                );
                              }
                              if (mounted) {
                                setState(() => isLoading = false);
                              }
                              return;
                            }
                            final uid = user?.uid;
                            if (user != null && user.emailVerified) {
                              await FirebaseFirestore.instance
                                  .collection('Users')
                                  .doc(user.uid)
                                  .update({'isVerified': true});
                              final legalUpdateNeeded =
                                  await _checkLegalDocumentVersions(user.uid);
                              if (legalUpdateNeeded) {
                                await _showLegalUpdateDialog(user.uid);
                                final currentUser =
                                    FirebaseAuth.instance.currentUser;
                                if (currentUser == null) {
                                  setState(() => isLoading = false);
                                  return;
                                }
                              }
                              await _verifyPlayIntegrity();
                              await _updateLoginMetadata(user.uid);
                            }
                            if (!context.mounted) return;
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => HomePage(uid: uid),
                              ),
                            );
                          } on FirebaseAuthException catch (e) {
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: Colors.red,
                                content: Text(
                                  getFriendlyLoginError(context, e),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Inter',
                                  ),
                                ),
                                persist: false,
                              ),
                            );
                          } finally {
                            if (mounted) setState(() => isLoading = false);
                          }
                        },
                        child: Text(
                          AppLocalizations.of(context)!.login,
                          style: Theme.of(
                            context,
                          ).textTheme.bodyLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  TextButton(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SignUpPage()),
                      );
                    },
                    child: Text(
                      AppLocalizations.of(context)!.dontHaveAccountSignUp,
                      style: TextStyle(
                        color: Color(0xFF8AC249),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      final resetEmailController = TextEditingController();

                      if (emailController.text.trim().isNotEmpty) {
                        resetEmailController.text = emailController.text.trim();
                      }

                      final result = await showDialog<String>(
                        context: context,
                        builder:
                            (context) => AlertDialog(
                              backgroundColor: const Color(0xFF8AC249),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              title: Text(
                                AppLocalizations.of(context)!.resetPassword,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    AppLocalizations.of(
                                      context,
                                    )!.pleaseEnterYourEmail,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  TextField(
                                    controller: resetEmailController,
                                    cursorColor: Colors.white,
                                    keyboardType: TextInputType.emailAddress,
                                    style: TextStyle(
                                      color:
                                          Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? Colors.white
                                              : Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    decoration: InputDecoration(
                                      labelText:
                                          AppLocalizations.of(context)!.email,
                                      labelStyle: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.white,
                                        ),
                                      ),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, null),
                                  child: Text(
                                    AppLocalizations.of(context)!.cancel,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                  ),
                                  onPressed: () {
                                    final email =
                                        resetEmailController.text.trim();
                                    if (email.isEmpty) return;
                                    Navigator.pop(context, email);
                                  },
                                  child: Text(
                                    AppLocalizations.of(context)!.sendEmail,
                                    style: TextStyle(
                                      color: Color(0xFF8AC249),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                      );

                      if (result == null || result.isEmpty) return;

                      try {
                        await FirebaseAuth.instance.sendPasswordResetEmail(
                          email: result,
                        );
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: Color(0xFF8AC249),
                              content: Text(
                                AppLocalizations.of(context)!.resetEmailSent,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Inter',
                                ),
                              ),
                              persist: false,
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: const Color(0xFF8AC249),
                              content: Text(
                                '${AppLocalizations.of(context)!.resetEmailFailed} $e',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Inter',
                                ),
                              ),
                              persist: false,
                            ),
                          );
                        }
                      }
                    },
                    child: Text(
                      AppLocalizations.of(context)!.forgotPassword,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Color(0xFF8AC249),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF8AC249),
                    ),
                    onPressed: _showIntroGuide,
                    child: Text(
                      AppLocalizations.of(context)!.appGuide,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        flex: 1,
                        child: TextButton(
                          onPressed: () async {
                            try {
                              final url = Uri.parse(
                                'https://dawatime.com/privacy-policy',
                              );
                              if (await canLaunchUrl(url)) {
                                await launchUrl(
                                  url,
                                  mode: LaunchMode.externalApplication,
                                );
                              }
                            } catch (e) {
                              // Silent fail
                            }
                          },
                          child: Text(
                            AppLocalizations.of(context)!.privacyPolicy,
                            style: TextStyle(
                              color: Color(0xFF8AC249),
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Flexible(
                        flex: 1,
                        child: TextButton(
                          onPressed: () async {
                            try {
                              final url = Uri.parse(
                                'https://dawatime.com/terms-and-conditions',
                              );
                              if (await canLaunchUrl(url)) {
                                await launchUrl(
                                  url,
                                  mode: LaunchMode.externalApplication,
                                );
                              }
                            } catch (e) {
                              // Silent fail
                            }
                          },
                          child: Text(
                            AppLocalizations.of(context)!.termsAndConditions,
                            style: TextStyle(
                              color: Color(0xFF8AC249),
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

String getFriendlyLoginError(BuildContext context, FirebaseAuthException e) {
  switch (e.code) {
    case 'user-not-found':
      return AppLocalizations.of(context)!.noAccount;
    case 'wrong-password':
      return AppLocalizations.of(context)!.incorrectPassword;
    case 'invalid-email':
      return AppLocalizations.of(context)!.invalidEmail;
    case 'user-disabled':
      return AppLocalizations.of(context)!.disabledAccount;
    default:
      return AppLocalizations.of(context)!.loginFailed;
  }
}
