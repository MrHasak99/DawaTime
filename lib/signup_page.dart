import 'package:dawatime/l10n/app_localizations.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:cloud_functions/cloud_functions.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final nameController = TextEditingController();
  bool isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  bool _acceptedTerms = false;
  bool _acceptedPrivacy = false;

  bool _nameError = false;
  bool _emailError = false;
  bool _passwordError = false;
  bool _confirmPasswordError = false;

  Future<bool> _verifyPlayIntegrity() async {
    if (!Platform.isAndroid) return true;

    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final userId = FirebaseAuth.instance.currentUser?.uid ?? 'signup';
      final nonce = '$userId:$timestamp'.codeUnits.toString();

      const channel = MethodChannel('com.mrhasak99.dawatime/play_integrity');
      final integrityToken = await channel.invokeMethod<String>(
        'requestIntegrityToken',
        {'cloudProjectNumber': 173965270100, 'nonce': nonce},
      );

      if (integrityToken == null || integrityToken.isEmpty) {
        return true;
      }

      final callable = FirebaseFunctions.instance.httpsCallable(
        'verifyPlayIntegrity',
      );

      await callable.call<Map<String, dynamic>>({
        'integrityToken': integrityToken,
      });

      return true;
    } catch (e) {
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
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
            leading: BackButton(color: Colors.white),
            title: Text(
              AppLocalizations.of(context)!.signUp,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
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
                  Image.asset("assets/DawaTime_green.png", height: 80),
                  const SizedBox(height: 24),
                  TextField(
                    controller: nameController,
                    textCapitalization: TextCapitalization.words,
                    cursorColor: Color(0xFF8AC249),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    onChanged: (value) {
                      if (_nameError && value.isNotEmpty) {
                        setState(() => _nameError = false);
                      }
                    },
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.name,
                      labelStyle: Theme.of(
                        context,
                      ).textTheme.bodyLarge?.copyWith(
                        color: _nameError ? Colors.red : Color(0xFF8AC249),
                        fontWeight: FontWeight.bold,
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: _nameError ? Colors.red : Color(0xFF8AC249),
                        ),
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: _nameError ? Colors.red : Color(0xFF8AC249),
                        ),
                      ),
                      errorText:
                          _nameError
                              ? AppLocalizations.of(
                                context,
                              )!.pleaseFillAllFields
                              : null,
                    ),
                  ),
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
                      labelStyle: Theme.of(
                        context,
                      ).textTheme.bodyLarge?.copyWith(
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
                              ? AppLocalizations.of(context)!.invalidEmail
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
                      labelStyle: TextStyle(
                        color: _passwordError ? Colors.red : Color(0xFF8AC249),
                        fontWeight: FontWeight.bold,
                      ),
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
                              ? 'Password must be at least 6 characters'
                              : null,
                    ),
                  ),
                  TextField(
                    controller: confirmPasswordController,
                    cursorColor: Color(0xFF8AC249),
                    keyboardType: TextInputType.visiblePassword,
                    obscureText: _obscureConfirmPassword,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    onChanged: (value) {
                      if (_confirmPasswordError && value.isNotEmpty) {
                        setState(() => _confirmPasswordError = false);
                      }
                    },
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.confirmPassword,
                      labelStyle: TextStyle(
                        color:
                            _confirmPasswordError
                                ? Colors.red
                                : Color(0xFF8AC249),
                        fontWeight: FontWeight.bold,
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color:
                              _confirmPasswordError
                                  ? Colors.red
                                  : Color(0xFF8AC249),
                        ),
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color:
                              _confirmPasswordError
                                  ? Colors.red
                                  : Color(0xFF8AC249),
                        ),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility_off_rounded
                              : Icons.visibility_rounded,
                          color: Color(0xFF8AC249),
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                      ),
                      errorText:
                          _confirmPasswordError
                              ? AppLocalizations.of(context)!.passwordsDontMatch
                              : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Checkbox(
                        value: _acceptedTerms,
                        onChanged: (val) {
                          setState(() => _acceptedTerms = val ?? false);
                        },
                        activeColor: Color(0xFF8AC249),
                        checkColor: Colors.white,
                      ),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                            children: [
                              TextSpan(
                                text: AppLocalizations.of(context)!.accept,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              TextSpan(
                                text: AppLocalizations.of(context)!.terms,
                                style: Theme.of(
                                  context,
                                ).textTheme.bodyMedium?.copyWith(
                                  decoration: TextDecoration.underline,
                                  color: Color(0xFF8AC249),
                                  fontWeight: FontWeight.bold,
                                ),
                                recognizer:
                                    TapGestureRecognizer()
                                      ..onTap = () async {
                                        try {
                                          final url = Uri.parse(
                                            'https://dawatime.com/terms-and-conditions',
                                          );
                                          if (await canLaunchUrl(url)) {
                                            await launchUrl(
                                              url,
                                            mode: LaunchMode.externalApplication,
                                            );
                                          } else {
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    'Could not open Terms. Please visit dawatime.com',
                                                  ),
                                                  backgroundColor: Colors.red,
                                                ),
                                              );
                                            }
                                          }
                                        } catch (e) {
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'Error opening link. Please try again.',
                                                ),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                          }
                                        }
                                      },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Checkbox(
                        value: _acceptedPrivacy,
                        onChanged: (val) {
                          setState(() => _acceptedPrivacy = val ?? false);
                        },
                        activeColor: Color(0xFF8AC249),
                        checkColor: Colors.white,
                      ),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                            children: [
                              TextSpan(
                                text: AppLocalizations.of(context)!.accept,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              TextSpan(
                                text: AppLocalizations.of(context)!.privacy,
                                style: Theme.of(
                                  context,
                                ).textTheme.bodyMedium?.copyWith(
                                  decoration: TextDecoration.underline,
                                  color: Color(0xFF8AC249),
                                  fontWeight: FontWeight.bold,
                                ),
                                recognizer:
                                    TapGestureRecognizer()
                                      ..onTap = () async {
                                        try {
                                          final url = Uri.parse(
                                            'https://dawatime.com/privacy-policy',
                                          );
                                          if (await canLaunchUrl(url)) {
                                            await launchUrl(
                                              url,
                                            mode: LaunchMode.externalApplication,
                                            );
                                          } else {
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    'Could not open Privacy Policy. Please visit dawatime.com',
                                                  ),
                                                  backgroundColor: Colors.red,
                                                ),
                                              );
                                            }
                                          }
                                        } catch (e) {
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'Error opening link. Please try again.',
                                                ),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                          }
                                        }
                                      },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
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
                            _nameError = false;
                            _emailError = false;
                            _passwordError = false;
                            _confirmPasswordError = false;
                          });

                          if (nameController.text.trim().isEmpty ||
                              emailController.text.trim().isEmpty ||
                              passwordController.text.trim().isEmpty ||
                              confirmPasswordController.text.trim().isEmpty) {
                            setState(() {
                              if (nameController.text.trim().isEmpty) {
                                _nameError = true;
                              }
                              if (emailController.text.trim().isEmpty) {
                                _emailError = true;
                              }
                              if (passwordController.text.trim().isEmpty) {
                                _passwordError = true;
                              }
                              if (confirmPasswordController.text
                                  .trim()
                                  .isEmpty) {
                                _confirmPasswordError = true;
                              }
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: Colors.red,
                                content: Text(
                                  AppLocalizations.of(
                                    context,
                                  )!.pleaseFillAllFields,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Inter',
                                  ),
                                ),
                                persist: false,
                              ),
                            );
                            return;
                          }

                          if (!emailController.text.trim().contains('@')) {
                            setState(() => _emailError = true);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: Colors.red,
                                content: Text(
                                  AppLocalizations.of(context)!.invalidEmail,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Inter',
                                  ),
                                ),
                                persist: false,
                              ),
                            );
                            return;
                          }

                          if (passwordController.text.trim().length < 6) {
                            setState(() => _passwordError = true);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: Colors.red,
                                content: const Text(
                                  'Password must be at least 6 characters',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Inter',
                                  ),
                                ),
                                persist: false,
                              ),
                            );
                            return;
                          }

                          if (!_acceptedTerms || !_acceptedPrivacy) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: Colors.red,
                                content: Text(
                                  AppLocalizations.of(context)!.mustAccept,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Inter',
                                  ),
                                ),
                                persist: false,
                              ),
                            );
                            return;
                          }
                          if (passwordController.text !=
                              confirmPasswordController.text) {
                            setState(() => _confirmPasswordError = true);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: Colors.red,
                                content: Text(
                                  AppLocalizations.of(
                                    context,
                                  )!.passwordsDontMatch,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.bodyLarge?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Inter',
                                  ),
                                ),
                                persist: false,
                              ),
                            );
                            return;
                          }
                          setState(() => isLoading = true);
                          try {
                            final legalDocSnap =
                                await FirebaseFirestore.instance
                                    .collection('AppConfig')
                                    .doc('LegalDocuments')
                                    .get();
                            final termsVersion =
                                legalDocSnap
                                    .data()?['termsVersion']
                                    ?.toString() ??
                                '1.0';
                            final privacyVersion =
                                legalDocSnap
                                    .data()?['privacyVersion']
                                    ?.toString() ??
                                '1.0';

                            await _verifyPlayIntegrity();

                            final userCredential = await FirebaseAuth.instance
                                .createUserWithEmailAndPassword(
                                  email: emailController.text.trim(),
                                  password: passwordController.text.trim(),
                                );
                            final user = userCredential.user;
                            final uid = userCredential.user?.uid;
                            if (user != null && !user.emailVerified) {
                              await user.sendEmailVerification();
                            }
                            await FirebaseFirestore.instance
                                .collection('Users')
                                .doc(uid)
                                .set({
                                  'name': nameController.text.trim(),
                                  'email': emailController.text.trim(),
                                  'isVerified': user?.emailVerified ?? false,
                                  'acceptedTermsVersion': termsVersion,
                                  'acceptedPrivacyVersion': privacyVersion,
                                  'legalAcceptanceDate':
                                      DateTime.now().toIso8601String(),
                                });
                            await FirebaseAuth.instance.signOut();
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: Color(0xFF8AC249),
                                content: Text(
                                  AppLocalizations.of(
                                    context,
                                  )!.verificationSent,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Inter',
                                  ),
                                ),
                                persist: false,
                              ),
                            );
                            Navigator.pop(context);
                          } on FirebaseAuthException catch (e) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: Colors.red,
                                content: Text(
                                  getFriendlyAuthError(context, e),
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
                          AppLocalizations.of(context)!.signUp,
                          style: Theme.of(
                            context,
                          ).textTheme.bodyLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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

String getFriendlyAuthError(BuildContext context, FirebaseAuthException e) {
  switch (e.code) {
    case 'email-already-in-use':
      return AppLocalizations.of(context)!.emailAlreadyRegistered;
    case 'invalid-email':
      return AppLocalizations.of(context)!.emailInvalid;
    case 'weak-password':
      return AppLocalizations.of(context)!.weakPassword;
    case 'operation-not-allowed':
      return AppLocalizations.of(context)!.emailMethod;
    default:
      return AppLocalizations.of(context)!.signupFailed;
  }
}
