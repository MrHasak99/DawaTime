import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'login_page.dart';
import 'package:dawatime/main.dart'
    show flutterLocalNotificationsPlugin, notificationsInitialized;

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Future.microtask(() {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
        );
      });
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Colors.lightGreen),
        ),
      );
    }

    final userDoc = FirebaseFirestore.instance
        .collection('Users')
        .doc(user.uid);

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(color: Colors.white),
        title: const Text("Settings"),
        backgroundColor: Colors.lightGreen,
        actions: [
          Builder(
            builder:
                (context) => IconButton(
                  icon: const Icon(Icons.edit, color: Colors.white),
                  tooltip: 'Edit Profile',
                  onPressed: () async {
                    final user = FirebaseAuth.instance.currentUser;
                    if (user == null) return;
                    final userDoc = FirebaseFirestore.instance
                        .collection('Users')
                        .doc(user.uid);
                    final docSnapshot = await userDoc.get();
                    final data = docSnapshot.data() ?? {};
                    final nameController = TextEditingController(
                      text: data['name'] ?? '',
                    );
                    final emailController = TextEditingController(
                      text: user.email ?? '',
                    );

                    final result = await showDialog<bool>(
                      context: context,
                      builder:
                          (context) => AlertDialog(
                            backgroundColor: Colors.lightGreen,
                            title: const Text(
                              'Edit Profile',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            content: SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextField(
                                    controller: nameController,
                                    cursorColor: Colors.white,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    decoration: const InputDecoration(
                                      labelText: 'Name',
                                      labelStyle: TextStyle(
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
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                    ),
                                    onPressed: () async {
                                      Navigator.pop(context);

                                      final rootContext = context;
                                      final newEmailController =
                                          TextEditingController();
                                      final passwordController =
                                          TextEditingController();
                                      final emailResult = await showDialog<
                                        bool
                                      >(
                                        context: rootContext,
                                        builder:
                                            (context) => AlertDialog(
                                              backgroundColor:
                                                  Colors.lightGreen,
                                              title: const Text(
                                                'Change Email',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              content: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  TextField(
                                                    controller:
                                                        newEmailController,
                                                    cursorColor: Colors.white,
                                                    keyboardType:
                                                        TextInputType
                                                            .emailAddress,
                                                    style: const TextStyle(
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                    decoration: const InputDecoration(
                                                      labelText: 'New Email',
                                                      labelStyle: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                      focusedBorder:
                                                          UnderlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                                  color:
                                                                      Colors
                                                                          .white,
                                                                ),
                                                          ),
                                                      enabledBorder:
                                                          UnderlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                                  color:
                                                                      Colors
                                                                          .white,
                                                                ),
                                                          ),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 12),
                                                  TextField(
                                                    controller:
                                                        passwordController,
                                                    obscureText: true,
                                                    cursorColor: Colors.white,
                                                    style: const TextStyle(
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                    decoration: const InputDecoration(
                                                      labelText:
                                                          'Current Password',
                                                      labelStyle: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                      focusedBorder:
                                                          UnderlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                                  color:
                                                                      Colors
                                                                          .white,
                                                                ),
                                                          ),
                                                      enabledBorder:
                                                          UnderlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                                  color:
                                                                      Colors
                                                                          .white,
                                                                ),
                                                          ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed:
                                                      () => Navigator.pop(
                                                        context,
                                                        false,
                                                      ),
                                                  child: const Text(
                                                    'Cancel',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                                ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                        backgroundColor:
                                                            Colors.white,
                                                      ),
                                                  onPressed:
                                                      () => Navigator.pop(
                                                        context,
                                                        true,
                                                      ),
                                                  child: const Text(
                                                    'Change',
                                                    style: TextStyle(
                                                      color: Colors.lightGreen,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                      );
                                      if (emailResult == true &&
                                          newEmailController.text
                                              .trim()
                                              .isNotEmpty &&
                                          passwordController.text.isNotEmpty) {
                                        try {
                                          final user =
                                              FirebaseAuth.instance.currentUser;
                                          if (user != null &&
                                              user.email !=
                                                  newEmailController.text
                                                      .trim()) {
                                            final cred =
                                                EmailAuthProvider.credential(
                                                  email: user.email!,
                                                  password:
                                                      passwordController.text,
                                                );
                                            await user
                                                .reauthenticateWithCredential(
                                                  cred,
                                                );
                                            await user.verifyBeforeUpdateEmail(
                                              newEmailController.text.trim(),
                                            );
                                            if (context.mounted) {
                                              await showDialog(
                                                context: context,
                                                builder:
                                                    (context) => AlertDialog(
                                                      backgroundColor:
                                                          Colors.lightGreen,
                                                      title: const Text(
                                                        'Email Change Requested',
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      content: const Text(
                                                        'A verification email has been sent to your new email address. Please verify it, then log in again with your new email.',
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      actions: [
                                                        TextButton(
                                                          onPressed:
                                                              () =>
                                                                  Navigator.pop(
                                                                    context,
                                                                  ),
                                                          child: const Text(
                                                            'OK',
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                              );
                                              await FirebaseAuth.instance
                                                  .signOut();
                                              Navigator.pushAndRemoveUntil(
                                                context,
                                                MaterialPageRoute(
                                                  builder:
                                                      (_) => const LoginPage(),
                                                ),
                                                (route) => false,
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
                                                  'Failed to update email: $e',
                                                ),
                                              ),
                                            );
                                          }
                                        }
                                      }
                                    },
                                    child: const Text(
                                      'Change Email',
                                      style: TextStyle(
                                        color: Colors.lightGreen,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                    ),
                                    onPressed: () async {
                                      Navigator.pop(context);
                                      final rootContext = context;
                                      await Future.delayed(
                                        const Duration(milliseconds: 100),
                                      );
                                      final emailController =
                                          TextEditingController();
                                      final result = await showDialog<bool>(
                                        context: rootContext,
                                        builder:
                                            (context) => AlertDialog(
                                              backgroundColor:
                                                  Colors.lightGreen,
                                              title: const Text(
                                                'Reset Password',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              content: TextField(
                                                controller: emailController,
                                                cursorColor: Colors.white,
                                                style: const TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                decoration: const InputDecoration(
                                                  labelText:
                                                      'Please enter your email',
                                                  labelStyle: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  focusedBorder:
                                                      UnderlineInputBorder(
                                                        borderSide: BorderSide(
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                  enabledBorder:
                                                      UnderlineInputBorder(
                                                        borderSide: BorderSide(
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                ),
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed:
                                                      () => Navigator.pop(
                                                        context,
                                                        false,
                                                      ),
                                                  child: const Text(
                                                    'Cancel',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                                ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                        backgroundColor:
                                                            Colors.white,
                                                      ),
                                                  onPressed:
                                                      () => Navigator.pop(
                                                        context,
                                                        true,
                                                      ),
                                                  child: const Text(
                                                    'Send',
                                                    style: TextStyle(
                                                      color: Colors.lightGreen,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                      );
                                      if (result == true) {
                                        try {
                                          await FirebaseAuth.instance
                                              .sendPasswordResetEmail(
                                                email:
                                                    emailController.text.trim(),
                                              );
                                          if (!context.mounted) return;
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Password reset email sent!',
                                              ),
                                            ),
                                          );
                                        } catch (e) {
                                          if (!context.mounted) return;
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Failed to send reset email: $e',
                                              ),
                                            ),
                                          );
                                        }
                                      }
                                    },
                                    child: const Text(
                                      'Reset Password',
                                      style: TextStyle(
                                        color: Colors.lightGreen,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton.icon(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.white,
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    onPressed: () async {
                                      final passwordController1 =
                                          TextEditingController();
                                      final passwordController2 =
                                          TextEditingController();

                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder:
                                            (context) => AlertDialog(
                                              title: const Text(
                                                "Delete Account",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              backgroundColor:
                                                  Colors.lightGreen,
                                              content: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Text(
                                                    "Are you sure you want to delete your account? This cannot be undone.",
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 16),
                                                  TextField(
                                                    controller:
                                                        passwordController1,
                                                    obscureText: true,
                                                    cursorColor: Colors.white,
                                                    style: const TextStyle(
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                    decoration: const InputDecoration(
                                                      labelText:
                                                          'Enter Your Password',
                                                      labelStyle: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                      focusedBorder:
                                                          UnderlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                                  color:
                                                                      Colors
                                                                          .white,
                                                                ),
                                                          ),
                                                      enabledBorder:
                                                          UnderlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                                  color:
                                                                      Colors
                                                                          .white,
                                                                ),
                                                          ),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 12),
                                                  TextField(
                                                    controller:
                                                        passwordController2,
                                                    obscureText: true,
                                                    cursorColor: Colors.white,
                                                    style: const TextStyle(
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                    decoration: const InputDecoration(
                                                      labelText:
                                                          'Confirm Password',
                                                      labelStyle: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                      focusedBorder:
                                                          UnderlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                                  color:
                                                                      Colors
                                                                          .white,
                                                                ),
                                                          ),
                                                      enabledBorder:
                                                          UnderlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                                  color:
                                                                      Colors
                                                                          .white,
                                                                ),
                                                          ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed:
                                                      () => Navigator.pop(
                                                        context,
                                                        false,
                                                      ),
                                                  child: const Text(
                                                    "Cancel",
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                                ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                        backgroundColor:
                                                            Colors.white,
                                                      ),
                                                  onPressed: () {
                                                    if (passwordController1
                                                            .text
                                                            .isEmpty ||
                                                        passwordController2
                                                            .text
                                                            .isEmpty) {
                                                      ScaffoldMessenger.of(
                                                        context,
                                                      ).showSnackBar(
                                                        const SnackBar(
                                                          content: Text(
                                                            "Please enter your password twice.",
                                                          ),
                                                        ),
                                                      );
                                                      return;
                                                    }
                                                    if (passwordController1
                                                            .text !=
                                                        passwordController2
                                                            .text) {
                                                      ScaffoldMessenger.of(
                                                        context,
                                                      ).showSnackBar(
                                                        const SnackBar(
                                                          content: Text(
                                                            "Passwords do not match.",
                                                          ),
                                                        ),
                                                      );
                                                      return;
                                                    }
                                                    Navigator.pop(
                                                      context,
                                                      true,
                                                    );
                                                  },
                                                  child: const Text(
                                                    "Delete",
                                                    style: TextStyle(
                                                      color: Colors.red,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                      );

                                      if (confirm == true) {
                                        BuildContext? dialogContext;
                                        showDialog(
                                          context: context,
                                          barrierDismissible: false,
                                          builder: (ctx) {
                                            dialogContext = ctx;
                                            return const Center(
                                              child: CircularProgressIndicator(
                                                color: Colors.lightGreen,
                                              ),
                                            );
                                          },
                                        );

                                        try {
                                          final user =
                                              FirebaseAuth.instance.currentUser;
                                          final email = user?.email;
                                          final password =
                                              passwordController1.text;
                                          if (email == null) {
                                            throw Exception(
                                              "No email found for user.",
                                            );
                                          }

                                          final cred =
                                              EmailAuthProvider.credential(
                                                email: email,
                                                password: password,
                                              );
                                          await user!
                                              .reauthenticateWithCredential(
                                                cred,
                                              );

                                          if (notificationsInitialized) {
                                            await flutterLocalNotificationsPlugin
                                                .cancelAll();
                                          }

                                          final medsCollection =
                                              FirebaseFirestore.instance
                                                  .collection(user.uid);
                                          final medsSnapshot =
                                              await medsCollection.get();
                                          for (final doc in medsSnapshot.docs) {
                                            await doc.reference.delete();
                                          }

                                          final userDoc = FirebaseFirestore
                                              .instance
                                              .collection('Users')
                                              .doc(user.uid);
                                          await userDoc.delete();

                                          await user.delete();
                                          if (dialogContext != null) {
                                            Navigator.of(
                                              dialogContext!,
                                              rootNavigator: true,
                                            ).pop();
                                          }

                                          if (context.mounted) {
                                            await showDialog(
                                              context: context,
                                              barrierDismissible: false,
                                              builder:
                                                  (alertContext) => AlertDialog(
                                                    backgroundColor:
                                                        Colors.lightGreen,
                                                    title: const Text(
                                                      "Account Deleted",
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    content: const Text(
                                                      "Your account has been deleted successfully.",
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () {
                                                          Navigator.of(
                                                            alertContext,
                                                            rootNavigator: true,
                                                          ).pop();
                                                          Navigator.of(
                                                            context,
                                                            rootNavigator: true,
                                                          ).pushAndRemoveUntil(
                                                            MaterialPageRoute(
                                                              builder:
                                                                  (
                                                                    _,
                                                                  ) => const LoginPage(
                                                                    showAccountDeletedMessage:
                                                                        true,
                                                                  ),
                                                            ),
                                                            (route) => false,
                                                          );
                                                        },
                                                        child: const Text(
                                                          "OK",
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                            );
                                          }
                                          return;
                                        } catch (e) {
                                          if (dialogContext != null) {
                                            Navigator.of(
                                              dialogContext!,
                                              rootNavigator: true,
                                            ).pop();
                                          }
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  "Failed to delete user: $e",
                                                ),
                                              ),
                                            );
                                          }
                                        }
                                      }
                                    },
                                    label: const Text(
                                      "Delete Account",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text(
                                  'Cancel',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(context, true),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                ),
                                child: const Text(
                                  'Save',
                                  style: TextStyle(
                                    color: Colors.lightGreen,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                    );
                    if (result == true) {
                      try {
                        await userDoc.update({
                          'name': nameController.text.trim(),
                          'email': emailController.text.trim(),
                        });
                        if (user.email != emailController.text.trim()) {
                          try {
                            await user.verifyBeforeUpdateEmail(
                              emailController.text.trim(),
                            );
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Email updated! Please verify your new email address.',
                                  ),
                                ),
                              );
                            }
                          } on FirebaseAuthException catch (e) {
                            if (e.code == 'requires-recent-login') {
                              final passwordController =
                                  TextEditingController();
                              final confirmed = await showDialog<bool>(
                                context: context,
                                builder:
                                    (context) => AlertDialog(
                                      backgroundColor: Colors.lightGreen,
                                      title: const Text(
                                        'Re-authenticate',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      content: TextField(
                                        controller: passwordController,
                                        obscureText: true,
                                        cursorColor: Colors.white,
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        decoration: const InputDecoration(
                                          labelText: 'Enter your password',
                                          labelStyle: TextStyle(
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
                                      actions: [
                                        TextButton(
                                          onPressed:
                                              () =>
                                                  Navigator.pop(context, false),
                                          child: const Text(
                                            'Cancel',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        ElevatedButton(
                                          onPressed:
                                              () =>
                                                  Navigator.pop(context, true),
                                          child: const Text(
                                            'Confirm',
                                            style: TextStyle(
                                              color: Colors.lightGreen,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                              );
                              if (confirmed == true) {
                                try {
                                  final cred = EmailAuthProvider.credential(
                                    email: user.email!,
                                    password: passwordController.text,
                                  );
                                  await user.reauthenticateWithCredential(cred);
                                  await user.verifyBeforeUpdateEmail(
                                    emailController.text.trim(),
                                  );
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Email updated! Please verify your new email address.',
                                        ),
                                      ),
                                    );
                                  }
                                } catch (reauthError) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Re-authentication failed: $reauthError',
                                        ),
                                      ),
                                    );
                                  }
                                }
                              }
                            } else {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Failed to update email: ${e.message}',
                                    ),
                                  ),
                                );
                              }
                            }
                          }
                        } else {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Profile updated!')),
                            );
                          }
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Failed to update: $e')),
                          );
                        }
                      }
                    }
                  },
                ),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Logout',
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder:
                    (context) => AlertDialog(
                      backgroundColor: Colors.lightGreen,
                      title: const Text(
                        "Log Out",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      content: const Text(
                        "Are you sure you want to log out?",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text(
                            "Cancel",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                          ),
                          child: const Text(
                            "Log Out",
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
              );
              if (confirm == true) {
                await flutterLocalNotificationsPlugin.cancelAll();
                await FirebaseAuth.instance.signOut();
                if (!context.mounted) return;
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: Center(
        child: StreamBuilder<DocumentSnapshot>(
          stream: userDoc.snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.lightGreen),
              );
            }
            if (!snapshot.hasData || !snapshot.data!.exists) {
              Future.microtask(() {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                  (route) => false,
                );
              });
              return const SizedBox.shrink();
            }
            final data = snapshot.data!.data() as Map<String, dynamic>;
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          Icon(
                            Icons.account_circle,
                            size: 64,
                            color: Colors.lightGreen,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "Name: ${data['name'] ?? ''}",
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Email: ${user.email ?? ''}",
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.email, color: Colors.white),
                    label: const Text(
                      "Contact Me",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                      elevation: 4,
                    ),
                    onPressed: () async {
                      final messageController = TextEditingController();
                      final result = await showDialog<String>(
                        context: context,
                        builder:
                            (context) => AlertDialog(
                              backgroundColor: Colors.lightGreen,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              title: const Text(
                                "Contact Me",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              content: TextField(
                                controller: messageController,
                                maxLines: 5,
                                cursorColor: Colors.white,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                                decoration: InputDecoration(
                                  hintText: "Write your message here...",
                                  hintStyle: const TextStyle(
                                    color: Colors.white70,
                                  ),
                                  filled: true,
                                  fillColor: Colors.white.withValues(
                                    alpha: 0.15,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Colors.white,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text(
                                    "Cancel",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: Colors.lightGreen,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.pop(
                                      context,
                                      messageController.text.trim(),
                                    );
                                  },
                                  child: const Text(
                                    "Send",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                      );
                      if (result != null && result.isNotEmpty) {
                        try {} catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Failed to send message: $e"),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      }
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
