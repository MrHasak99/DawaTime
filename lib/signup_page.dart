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

  bool _acceptedTerms = false;
  final bool _acceptedPrivacy = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(color: Colors.white),
        title: const Text("Sign Up"),
        centerTitle: true,
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
                  Image.asset("assets/app_icon.png", height: 80),
                  const SizedBox(height: 24),
                  TextField(
                    controller: nameController,
                    cursorColor: Colors.lightGreen,
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: const InputDecoration(
                      labelText: "Name",
                      labelStyle: TextStyle(
                        color: Colors.lightGreen,
                        fontWeight: FontWeight.bold,
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.lightGreen),
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.lightGreen),
                      ),
                    ),
                  ),
                  TextField(
                    controller: emailController,
                    cursorColor: Colors.lightGreen,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: const InputDecoration(
                      labelText: "Email",
                      labelStyle: TextStyle(
                        color: Colors.lightGreen,
                        fontWeight: FontWeight.bold,
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.lightGreen),
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.lightGreen),
                      ),
                    ),
                  ),
                  TextField(
                    controller: passwordController,
                    cursorColor: Colors.lightGreen,
                    keyboardType: TextInputType.visiblePassword,
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: const InputDecoration(
                      labelText: "Password",
                      labelStyle: TextStyle(
                        color: Colors.lightGreen,
                        fontWeight: FontWeight.bold,
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.lightGreen),
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.lightGreen),
                      ),
                    ),
                    obscureText: true,
                  ),
                  TextField(
                    controller: confirmPasswordController,
                    cursorColor: Colors.lightGreen,
                    keyboardType: TextInputType.visiblePassword,
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: const InputDecoration(
                      labelText: "Confirm Password",
                      labelStyle: TextStyle(
                        color: Colors.lightGreen,
                        fontWeight: FontWeight.bold,
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.lightGreen),
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.lightGreen),
                      ),
                    ),
                    obscureText: true,
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
                        activeColor: Colors.lightGreen,
                        checkColor: Colors.white,
                      ),
                      Expanded(
                        child: RichText(
                          textAlign: TextAlign.left,
                          text: TextSpan(
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                            children: [
                              const TextSpan(
                                text: "I accept the ",
                                style: TextStyle(color: Colors.black),
                              ),
                              TextSpan(
                                text: "Terms & Conditions",
                                style: const TextStyle(
                                  decoration: TextDecoration.underline,
                                  color: Colors.lightGreen,
                                  fontWeight: FontWeight.bold,
                                ),
                                recognizer:
                                    TapGestureRecognizer()
                                      ..onTap = () async {
                                        final url = Uri.parse(
                                          'https://firebasestorage.googleapis.com/v0/b/medication-cd9b8.firebasestorage.app/o/Resume%20(Hamad%20AlKhalaf).pdf?alt=media&token=5ba43398-bdcc-4fda-9e47-c90c340a9711',
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
                              const TextSpan(
                                text: " and ",
                                style: TextStyle(color: Colors.black),
                              ),
                              TextSpan(
                                text: "Privacy Policy",
                                style: const TextStyle(
                                  decoration: TextDecoration.underline,
                                  color: Colors.lightGreen,
                                  fontWeight: FontWeight.bold,
                                ),
                                recognizer:
                                    TapGestureRecognizer()
                                      ..onTap = () async {
                                        final url = Uri.parse(
                                          'https://firebasestorage.googleapis.com/v0/b/medication-cd9b8.firebasestorage.app/o/299100800434_Hamad%20_Al%20khalaf_SingleView_2025-05-07.pdf?alt=media&token=db9a331f-1d13-4b14-833c-a5a0a232b60d',
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
                        color: Colors.lightGreen,
                      )
                      : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.lightGreen,
                        ),
                        onPressed: () async {
                          if (!_acceptedTerms || !_acceptedPrivacy) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "You must accept the Terms & Conditions and Privacy Policy.",
                                ),
                              ),
                            );
                            return;
                          }
                          if (passwordController.text !=
                              confirmPasswordController.text) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Passwords do not match"),
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
                            if (user != null && !user.emailVerified) {
                              await user.sendEmailVerification();
                            }
                            final uid = userCredential.user?.uid;
                            await FirebaseFirestore.instance
                                .collection('Users')
                                .doc(uid)
                                .set({
                                  'name': nameController.text.trim(),
                                  'email': emailController.text.trim(),
                                });
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Verification email sent. Please check your inbox.",
                                ),
                              ),
                            );
                            Navigator.pop(context);
                          } on FirebaseAuthException catch (e) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(e.message ?? "Sign up failed"),
                              ),
                            );
                          } finally {
                            if (mounted) setState(() => isLoading = false);
                          }
                        },
                        child: const Text(
                          "Sign Up",
                          style: TextStyle(
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
