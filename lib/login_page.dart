import 'package:dawatime/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:dawatime/home_page.dart';
import 'package:dawatime/signup_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dawatime/l10n/app_localizations.dart';

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
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.email,
                      labelStyle: TextStyle(
                        color: Color(0xFF8AC249),
                        fontWeight: FontWeight.bold,
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF8AC249)),
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF8AC249)),
                      ),
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
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.password,
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF8AC249)),
                      ),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF8AC249)),
                      ),
                      labelStyle: const TextStyle(
                        color: Color(0xFF8AC249),
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
                              setState(() => isLoading = false);
                              return;
                            }
                            final uid = user?.uid;
                            if (user != null && user.emailVerified) {
                              await FirebaseFirestore.instance
                                  .collection('Users')
                                  .doc(user.uid)
                                  .update({'isVerified': true});
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
                      TextButton(
                        onPressed: () {
                          launchUrl(
                            Uri.parse('https://dawatime.com/PrivacyPolicy.pdf'),
                            mode: LaunchMode.externalApplication,
                          );
                        },
                        child: Text(
                          AppLocalizations.of(context)!.privacyPolicy,
                          style: TextStyle(
                            color: Color(0xFF8AC249),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      TextButton(
                        onPressed: () {
                          launchUrl(
                            Uri.parse(
                              'https://dawatime.com/Terms&Conditions.pdf',
                            ),
                            mode: LaunchMode.externalApplication,
                          );
                        },
                        child: Text(
                          AppLocalizations.of(context)!.termsAndConditions,
                          style: TextStyle(
                            color: Color(0xFF8AC249),
                            fontWeight: FontWeight.bold,
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
