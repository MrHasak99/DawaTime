import 'package:dawatime/l10n/app_localizations.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

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
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.name,
                      labelStyle: Theme.of(
                        context,
                      ).textTheme.bodyLarge?.copyWith(
                        color: Color(0xFF8AC249),
                        fontWeight: FontWeight.bold,
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF8AC249)),
                      ),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF8AC249)),
                      ),
                    ),
                  ),
                  TextField(
                    controller: emailController,
                    cursorColor: Color(0xFF8AC249),
                    keyboardType: TextInputType.emailAddress,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.email,
                      labelStyle: Theme.of(
                        context,
                      ).textTheme.bodyLarge?.copyWith(
                        color: Color(0xFF8AC249),
                        fontWeight: FontWeight.bold,
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF8AC249)),
                      ),
                      enabledBorder: const UnderlineInputBorder(
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
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
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
                  TextField(
                    controller: confirmPasswordController,
                    cursorColor: Color(0xFF8AC249),
                    keyboardType: TextInputType.visiblePassword,
                    obscureText: _obscureConfirmPassword,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.confirmPassword,
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
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Color(0xFF8AC249),
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                      ),
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
                                        final url = Uri.parse(
                                          'https://dawatime.com/Terms&Conditions.pdf',
                                        );
                                        if (await canLaunchUrl(url)) {
                                          await launchUrl(
                                            url,
                                            mode:
                                                LaunchMode.externalApplication,
                                          );
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
                                        final url = Uri.parse(
                                          'https://dawatime.com/PrivacyPolicy.pdf',
                                        );
                                        if (await canLaunchUrl(url)) {
                                          await launchUrl(
                                            url,
                                            mode:
                                                LaunchMode.externalApplication,
                                          );
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
                              ),
                            );
                            return;
                          }
                          if (passwordController.text !=
                              confirmPasswordController.text) {
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
                              ),
                            );
                            return;
                          }
                          setState(() => isLoading = true);
                          try {
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
