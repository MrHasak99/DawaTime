import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'login_page.dart';
import 'package:dawatime/main.dart'
    show
        flutterLocalNotificationsPlugin,
        notificationsInitialized,
        themeModeNotifier;
import 'package:package_info_plus/package_info_plus.dart';

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
          child: CircularProgressIndicator(color: Color(0xFF8AC249)),
        ),
      );
    }

    final userDoc = FirebaseFirestore.instance
        .collection('Users')
        .doc(user.uid);

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
            leading: const BackButton(color: Colors.white),
            title: const Text("Settings"),
            actions: [
              IconButton(
                icon: const Icon(Icons.info_outline, color: Colors.white),
                tooltip: 'App Info',
                onPressed: () async {
                  final info = await PackageInfo.fromPlatform();
                  showDialog(
                    context: context,
                    builder:
                        (context) => AlertDialog(
                          backgroundColor: const Color(0xFF8AC249),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          title: Row(
                            children: [
                              Image.asset(
                                'assets/DawaTime_white.png',
                                width: 48,
                                height: 48,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  info.appName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 22,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Version: ${info.version} (Build ${info.buildNumber})',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Thank you for using Dawatime!',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text(
                                'Close',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.white),
                tooltip: 'Logout',
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder:
                        (context) => AlertDialog(
                          backgroundColor: Color(0xFF8AC249),
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
            centerTitle: true,
          ),
        ),
      ),
      body: Center(
        child: StreamBuilder<DocumentSnapshot>(
          stream: userDoc.snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF8AC249)),
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
                            color: Color(0xFF8AC249),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "Name: ${data['name'] ?? ''}",
                            style: Theme.of(
                              context,
                            ).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Email: ${user.email ?? ''}",
                            style: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.copyWith(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.edit, color: Colors.white),
                    label: const Text(
                      "Edit Profile",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8AC249),
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
                              backgroundColor: Color(0xFF8AC249),
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
                                      style: TextStyle(
                                        color:
                                            Theme.of(context).brightness ==
                                                    Brightness.dark
                                                ? Colors.white
                                                : Colors.black,
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
                                                backgroundColor: Color(
                                                  0xFF8AC249,
                                                ),
                                                title: const Text(
                                                  'Change Email',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                content: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    TextField(
                                                      controller:
                                                          newEmailController,
                                                      cursorColor: Colors.white,
                                                      keyboardType:
                                                          TextInputType
                                                              .emailAddress,
                                                      style: TextStyle(
                                                        color:
                                                            Theme.of(
                                                                      context,
                                                                    ).brightness ==
                                                                    Brightness
                                                                        .dark
                                                                ? Colors.white
                                                                : Colors.black,
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
                                                      style: TextStyle(
                                                        color:
                                                            Theme.of(
                                                                      context,
                                                                    ).brightness ==
                                                                    Brightness
                                                                        .dark
                                                                ? Colors.white
                                                                : Colors.black,
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
                                                        color: Color(
                                                          0xFF8AC249,
                                                        ),
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
                                            passwordController
                                                .text
                                                .isNotEmpty) {
                                          try {
                                            final user =
                                                FirebaseAuth
                                                    .instance
                                                    .currentUser;
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
                                              await user
                                                  .verifyBeforeUpdateEmail(
                                                    newEmailController.text
                                                        .trim(),
                                                  );
                                              if (context.mounted) {
                                                await showDialog(
                                                  context: context,
                                                  builder:
                                                      (context) => AlertDialog(
                                                        backgroundColor: Color(
                                                          0xFF8AC249,
                                                        ),
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
                                                                    Colors
                                                                        .white,
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
                                                        (_) =>
                                                            const LoginPage(),
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
                                                  backgroundColor: Color(
                                                    0xFF8AC249,
                                                  ),
                                                  content: Text(
                                                    'Failed to update email: $e',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontFamily: 'Inter',
                                                    ),
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
                                          color: Color(0xFF8AC249),
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
                                                backgroundColor: Color(
                                                  0xFF8AC249,
                                                ),
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
                                                  style: TextStyle(
                                                    color:
                                                        Theme.of(
                                                                  context,
                                                                ).brightness ==
                                                                Brightness.dark
                                                            ? Colors.white
                                                            : Colors.black,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  decoration: const InputDecoration(
                                                    labelText:
                                                        'Please enter your email',
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
                                                        color: Color(
                                                          0xFF8AC249,
                                                        ),
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
                                                      emailController.text
                                                          .trim(),
                                                );
                                            if (!context.mounted) return;
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                backgroundColor: Color(
                                                  0xFF8AC249,
                                                ),
                                                content: Text(
                                                  'Password reset email sent!',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily: 'Inter',
                                                  ),
                                                ),
                                              ),
                                            );
                                          } catch (e) {
                                            if (!context.mounted) return;
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                backgroundColor: Color(
                                                  0xFF8AC249,
                                                ),
                                                content: Text(
                                                  'Failed to send reset email: $e',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily: 'Inter',
                                                  ),
                                                ),
                                              ),
                                            );
                                          }
                                        }
                                      },
                                      child: const Text(
                                        'Reset Password',
                                        style: TextStyle(
                                          color: Color(0xFF8AC249),
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
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
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
                                                backgroundColor: Color(
                                                  0xFF8AC249,
                                                ),
                                                content: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
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
                                                      style: TextStyle(
                                                        color:
                                                            Theme.of(
                                                                      context,
                                                                    ).brightness ==
                                                                    Brightness
                                                                        .dark
                                                                ? Colors.white
                                                                : Colors.black,
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
                                                      style: TextStyle(
                                                        color:
                                                            Theme.of(
                                                                      context,
                                                                    ).brightness ==
                                                                    Brightness
                                                                        .dark
                                                                ? Colors.white
                                                                : Colors.black,
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
                                                            backgroundColor:
                                                                Color(
                                                                  0xFF8AC249,
                                                                ),
                                                            content: Text(
                                                              "Please enter your password twice.",
                                                              style: TextStyle(
                                                                color:
                                                                    Colors
                                                                        .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontFamily:
                                                                    'Inter',
                                                              ),
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
                                                            backgroundColor:
                                                                Color(
                                                                  0xFF8AC249,
                                                                ),
                                                            content: Text(
                                                              "Passwords do not match.",
                                                              style: TextStyle(
                                                                color:
                                                                    Colors
                                                                        .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontFamily:
                                                                    'Inter',
                                                              ),
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
                                                child:
                                                    CircularProgressIndicator(
                                                      color: Color(0xFF8AC249),
                                                    ),
                                              );
                                            },
                                          );

                                          try {
                                            final user =
                                                FirebaseAuth
                                                    .instance
                                                    .currentUser;
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
                                            for (final doc
                                                in medsSnapshot.docs) {
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
                                                    (
                                                      alertContext,
                                                    ) => AlertDialog(
                                                      backgroundColor: Color(
                                                        0xFF8AC249,
                                                      ),
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
                                                              rootNavigator:
                                                                  true,
                                                            ).pop();
                                                            Navigator.of(
                                                              context,
                                                              rootNavigator:
                                                                  true,
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
                                                  backgroundColor: Color(
                                                    0xFF8AC249,
                                                  ),
                                                  content: Text(
                                                    "Failed to delete user: $e",
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontFamily: 'Inter',
                                                    ),
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
                                  onPressed:
                                      () => Navigator.pop(context, false),
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
                                      color: Color(0xFF8AC249),
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
                                    backgroundColor: Color(0xFF8AC249),
                                    content: Text(
                                      'Email updated! Please verify your new email address.',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Inter',
                                      ),
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
                                        backgroundColor: Color(0xFF8AC249),
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
                                          style: TextStyle(
                                            color:
                                                Theme.of(context).brightness ==
                                                        Brightness.dark
                                                    ? Colors.white
                                                    : Colors.black,
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
                                                () => Navigator.pop(
                                                  context,
                                                  false,
                                                ),
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
                                                () => Navigator.pop(
                                                  context,
                                                  true,
                                                ),
                                            child: const Text(
                                              'Confirm',
                                              style: TextStyle(
                                                color: Color(0xFF8AC249),
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
                                    await user.reauthenticateWithCredential(
                                      cred,
                                    );
                                    await user.verifyBeforeUpdateEmail(
                                      emailController.text.trim(),
                                    );
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          backgroundColor: Color(0xFF8AC249),
                                          content: Text(
                                            'Email updated! Please verify your new email address.',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'Inter',
                                            ),
                                          ),
                                        ),
                                      );
                                    }
                                  } catch (reauthError) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          backgroundColor: Color(0xFF8AC249),
                                          content: Text(
                                            'Re-authentication failed: $reauthError',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'Inter',
                                            ),
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
                                      backgroundColor: Color(0xFF8AC249),
                                      content: Text(
                                        'Failed to update email: ${e.message}',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Inter',
                                        ),
                                      ),
                                    ),
                                  );
                                }
                              }
                            }
                          } else {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  backgroundColor: Color(0xFF8AC249),
                                  content: Text(
                                    'Profile updated!',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Inter',
                                    ),
                                  ),
                                ),
                              );
                            }
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: Color(0xFF8AC249),
                                content: Text(
                                  'Failed to update: $e',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Inter',
                                  ),
                                ),
                              ),
                            );
                          }
                        }
                      }
                    },
                  ),
                  const SizedBox(height: 16),
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
                      backgroundColor: Color(0xFF8AC249),
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
                              backgroundColor: Color(0xFF8AC249),
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
                                style: TextStyle(
                                  color:
                                      Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.white
                                          : Colors.black,
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
                                    foregroundColor: Color(0xFF8AC249),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  onPressed: () async {
                                    final message =
                                        messageController.text.trim();
                                    if (message.isEmpty) return;

                                    final user =
                                        FirebaseAuth.instance.currentUser;
                                    if (user == null) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            backgroundColor: Color(0xFF8AC249),
                                            content: Text(
                                              'You must be logged in to send a message.',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'Inter',
                                              ),
                                            ),
                                          ),
                                        );
                                      }
                                      return;
                                    }

                                    try {
                                      await FirebaseFirestore.instance
                                          .collection('ContactMessages')
                                          .add({
                                            'userId': user.uid,
                                            'userEmail': user.email,
                                            'message': message,
                                            'timestamp':
                                                FieldValue.serverTimestamp(),
                                          });
                                      if (context.mounted) {
                                        Navigator.pop(context, message);
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            backgroundColor: Color(0xFF8AC249),
                                            content: Text(
                                              'Message sent!',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'Inter',
                                              ),
                                            ),
                                          ),
                                        );
                                      }
                                    } catch (e) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            backgroundColor: Color(0xFF8AC249),
                                            content: Text(
                                              'Failed to send message: $e',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'Inter',
                                              ),
                                            ),
                                          ),
                                        );
                                      }
                                    }
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
                                backgroundColor: Color(0xFF8AC249),
                                content: Text(
                                  "Failed to send message: $e",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Inter',
                                  ),
                                ),
                              ),
                            );
                          }
                        }
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    title: const Text(
                      'Theme',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: ValueListenableBuilder<ThemeMode>(
                      valueListenable: themeModeNotifier,
                      builder: (context, mode, _) {
                        return DropdownButton<ThemeMode>(
                          value: mode,
                          items: const [
                            DropdownMenuItem(
                              value: ThemeMode.system,
                              child: Text('System (Follow device)'),
                            ),
                            DropdownMenuItem(
                              value: ThemeMode.light,
                              child: Text('Light'),
                            ),
                            DropdownMenuItem(
                              value: ThemeMode.dark,
                              child: Text('Dark'),
                            ),
                          ],
                          onChanged: (ThemeMode? newMode) {
                            if (newMode != null) {
                              themeModeNotifier.value = newMode;
                            }
                          },
                        );
                      },
                    ),
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
