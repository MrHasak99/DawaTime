import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dawatime/home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_page.dart';
import 'package:dawatime/main.dart'
    show
        MainApp,
        flutterLocalNotificationsPlugin,
        notificationsInitialized,
        themeModeNotifier,
        localeNotifier;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dawatime/l10n/app_localizations.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _obscureEmailPassword = true;

  @override
  void initState() {
    super.initState();
    selectNotificationStream.stream.listen((
      NotificationResponse response,
    ) async {
      if (response.payload != null && context.mounted) {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          final doc =
              await FirebaseFirestore.instance
                  .collection(user.uid)
                  .doc(response.payload!)
                  .get();
          if (doc.exists) {
            final medication = medicationFromDoc(doc);
            showDialog(
              context: context,
              builder:
                  (context) => AlertDialog(
                    backgroundColor: const Color(0xFF8AC249),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    title: Text(
                      AppLocalizations.of(
                        context,
                      )!.timeToTakeMedication(medication.name),
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
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
            );
          }
        }
      }
    });
  }

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
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF8AC249),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
            boxShadow: [
              BoxShadow(
                color:
                    Theme.of(context).brightness == Brightness.dark
                        ? Colors.black.withValues(alpha: 0.3)
                        : const Color(0x228AC249),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: const BackButton(color: Colors.white),
            centerTitle: true,
            title: Text(
              AppLocalizations.of(context)!.settings,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 26,
                letterSpacing: 1.2,
              ),
              textAlign: TextAlign.center,
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.info_outline, color: Colors.white),
                tooltip: AppLocalizations.of(context)!.appInfo,
                onPressed: () async {
                  final info = await PackageInfo.fromPlatform();
                  showDialog(
                    context: context,
                    builder:
                        (context) => Dialog(
                          backgroundColor: Colors.transparent,
                          insetPadding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 40,
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF8AC249),
                              borderRadius: BorderRadius.circular(32),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.15),
                                  blurRadius: 24,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(32),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Image.asset(
                                  'assets/DawaTime_white.png',
                                  width: 128,
                                  height: 128,
                                  fit: BoxFit.contain,
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  info.appName,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.headlineSmall?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 32,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${AppLocalizations.of(context)!.version}: ${info.version}',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.bodyLarge?.copyWith(
                                    color: Colors.white70,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                Divider(
                                  color: Colors.white.withValues(alpha: 0.3),
                                  thickness: 1,
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.person,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        '${AppLocalizations.of(context)!.developed}: ${AppLocalizations.of(context)!.developer}',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodyLarge?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          launchUrl(
                                            Uri.parse(
                                              'https://dawatime.com/PrivacyPolicy.pdf',
                                            ),
                                            mode:
                                                LaunchMode.externalApplication,
                                          );
                                        },
                                        child: Text(
                                          AppLocalizations.of(
                                            context,
                                          )!.privacyPolicy,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Colors.white,
                                            decoration:
                                                TextDecoration.underline,
                                            decorationColor: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          launchUrl(
                                            Uri.parse(
                                              'https://dawatime.com/Terms&Conditions.pdf',
                                            ),
                                            mode:
                                                LaunchMode.externalApplication,
                                          );
                                        },
                                        child: Text(
                                          AppLocalizations.of(
                                            context,
                                          )!.termsAndConditions,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Colors.white,
                                            decoration:
                                                TextDecoration.underline,
                                            decorationColor: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: const Color(0xFF8AC249),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                      elevation: 0,
                                    ),
                                    label: Text(
                                      AppLocalizations.of(context)!.close,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                    onPressed: () => Navigator.pop(context),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.white),
                tooltip: AppLocalizations.of(context)!.logOut,
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder:
                        (context) => AlertDialog(
                          backgroundColor: Color(0xFF8AC249),
                          title: Text(
                            AppLocalizations.of(context)!.logOut,
                            style: Theme.of(
                              context,
                            ).textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          content: Text(
                            AppLocalizations.of(context)!.areYouSureLogOut,
                            style: Theme.of(
                              context,
                            ).textTheme.bodyLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: Text(
                                AppLocalizations.of(context)!.cancel,
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
                              child: Text(
                                AppLocalizations.of(context)!.logOut,
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
        ),
      ),
      body: Container(
        width: double.infinity,
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Center(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 104),
                  FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                    future: userDoc.get(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF8AC249),
                          ),
                        );
                      }
                      if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            AppLocalizations.of(context)!.failedToLoadUserData,
                            style: TextStyle(color: Colors.red),
                          ),
                        );
                      }
                      final data = snapshot.data?.data() ?? {};
                      return Card(
                        elevation: 12,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 18,
                        ),
                        color: Theme.of(context).cardColor,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 36,
                            horizontal: 28,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: 44,
                                backgroundColor: const Color(0xFF8AC249),
                                child: Icon(
                                  Icons.account_circle,
                                  size: 72,
                                  color: Theme.of(context).cardColor,
                                ),
                              ),
                              const SizedBox(height: 22),
                              Text(
                                "${AppLocalizations.of(context)!.name}: ${data['name'] ?? ''}",
                                style: Theme.of(
                                  context,
                                ).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "${AppLocalizations.of(context)!.email}: ${user.email ?? ''}",
                                style: Theme.of(
                                  context,
                                ).textTheme.bodyMedium?.copyWith(
                                  fontSize: 16,
                                  color:
                                      Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.white70
                                          : Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 28),

                              Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? Colors.black
                                              : Colors.white,
                                      foregroundColor: const Color(0xFF8AC249),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                        side: const BorderSide(
                                          color: Color(0xFF8AC249),
                                          width: 2,
                                        ),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                      elevation: 0,
                                      alignment: Alignment.center,
                                    ),
                                    onPressed: () async {
                                      final user =
                                          FirebaseAuth.instance.currentUser;
                                      if (user == null) return;
                                      final userDoc = FirebaseFirestore.instance
                                          .collection('Users')
                                          .doc(user.uid);
                                      final docSnapshot = await userDoc.get();
                                      final data = docSnapshot.data() ?? {};
                                      final nameController =
                                          TextEditingController(
                                            text: data['name'] ?? '',
                                          );
                                      final result = await showDialog<bool>(
                                        context: context,
                                        builder:
                                            (context) => AlertDialog(
                                              backgroundColor: const Color(
                                                0xFF8AC249,
                                              ),
                                              title: Text(
                                                AppLocalizations.of(
                                                  context,
                                                )!.editProfile,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleLarge
                                                    ?.copyWith(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                              ),
                                              content: SingleChildScrollView(
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    TextField(
                                                      controller:
                                                          nameController,
                                                      cursorColor: Colors.white,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyLarge
                                                          ?.copyWith(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                      decoration: InputDecoration(
                                                        labelText:
                                                            AppLocalizations.of(
                                                              context,
                                                            )!.name,
                                                        labelStyle: Theme.of(
                                                              context,
                                                            )
                                                            .textTheme
                                                            .bodyLarge
                                                            ?.copyWith(
                                                              color:
                                                                  Colors.white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                        focusedBorder:
                                                            const UnderlineInputBorder(
                                                              borderSide:
                                                                  BorderSide(
                                                                    color:
                                                                        Colors
                                                                            .white,
                                                                  ),
                                                            ),
                                                        enabledBorder:
                                                            const UnderlineInputBorder(
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
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed:
                                                      () => Navigator.pop(
                                                        context,
                                                        false,
                                                      ),
                                                  child: Text(
                                                    AppLocalizations.of(
                                                      context,
                                                    )!.cancel,
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                                ElevatedButton(
                                                  onPressed:
                                                      () => Navigator.pop(
                                                        context,
                                                        true,
                                                      ),
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                        backgroundColor:
                                                            Colors.white,
                                                      ),
                                                  child: Text(
                                                    AppLocalizations.of(
                                                      context,
                                                    )!.save,
                                                    style: TextStyle(
                                                      color: const Color(
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
                                          await userDoc.update({
                                            'name': nameController.text.trim(),
                                          });
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                backgroundColor: Color(
                                                  0xFF8AC249,
                                                ),
                                                content: Text(
                                                  AppLocalizations.of(
                                                    context,
                                                  )!.profileUpdated,
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
                                                backgroundColor: const Color(
                                                  0xFF8AC249,
                                                ),
                                                content: Text(
                                                  '${AppLocalizations.of(context)!.updateFailed} $e',
                                                  style: const TextStyle(
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
                                    child: Text(
                                      AppLocalizations.of(context)!.editProfile,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyLarge?.copyWith(
                                        color: const Color(0xFF8AC249),
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  const SizedBox(height: 14),

                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? Colors.black
                                              : Colors.white,
                                      foregroundColor: const Color(0xFF8AC249),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                        side: const BorderSide(
                                          color: Color(0xFF8AC249),
                                          width: 2,
                                        ),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                      elevation: 0,
                                      alignment: Alignment.center,
                                    ),
                                    child: Text(
                                      AppLocalizations.of(context)!.changeEmail,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF8AC249),
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    onPressed: () async {
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
                                            (context) => StatefulBuilder(
                                              builder:
                                                  (
                                                    context,
                                                    setDialogState,
                                                  ) => AlertDialog(
                                                    backgroundColor:
                                                        const Color(0xFF8AC249),
                                                    title: Text(
                                                      AppLocalizations.of(
                                                        context,
                                                      )!.changeEmail,
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    content: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        TextField(
                                                          controller:
                                                              newEmailController,
                                                          cursorColor:
                                                              Colors.white,
                                                          keyboardType:
                                                              TextInputType
                                                                  .emailAddress,
                                                          style: Theme.of(
                                                                context,
                                                              )
                                                              .textTheme
                                                              .bodyLarge
                                                              ?.copyWith(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                          decoration: InputDecoration(
                                                            labelText:
                                                                AppLocalizations.of(
                                                                  context,
                                                                )!.newEmail,
                                                            labelStyle:
                                                                TextStyle(
                                                                  color:
                                                                      Colors
                                                                          .white,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                            focusedBorder:
                                                                UnderlineInputBorder(
                                                                  borderSide:
                                                                      BorderSide(
                                                                        color:
                                                                            Colors.white,
                                                                      ),
                                                                ),
                                                            enabledBorder:
                                                                UnderlineInputBorder(
                                                                  borderSide:
                                                                      BorderSide(
                                                                        color:
                                                                            Colors.white,
                                                                      ),
                                                                ),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          height: 12,
                                                        ),
                                                        TextField(
                                                          controller:
                                                              passwordController,
                                                          obscureText:
                                                              _obscureEmailPassword,
                                                          cursorColor:
                                                              Colors.white,
                                                          style: Theme.of(
                                                                context,
                                                              )
                                                              .textTheme
                                                              .bodyLarge
                                                              ?.copyWith(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                          decoration: InputDecoration(
                                                            labelText:
                                                                AppLocalizations.of(
                                                                  context,
                                                                )!.currentPassword,
                                                            labelStyle:
                                                                const TextStyle(
                                                                  color:
                                                                      Colors
                                                                          .white,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                            suffixIcon: IconButton(
                                                              icon: Icon(
                                                                _obscureEmailPassword
                                                                    ? Icons
                                                                        .visibility_off
                                                                    : Icons
                                                                        .visibility,
                                                                color:
                                                                    Colors
                                                                        .white,
                                                              ),
                                                              onPressed: () {
                                                                setDialogState(() {
                                                                  _obscureEmailPassword =
                                                                      !_obscureEmailPassword;
                                                                });
                                                              },
                                                            ),
                                                            focusedBorder:
                                                                const UnderlineInputBorder(
                                                                  borderSide:
                                                                      BorderSide(
                                                                        color:
                                                                            Colors.white,
                                                                      ),
                                                                ),
                                                            enabledBorder:
                                                                const UnderlineInputBorder(
                                                                  borderSide:
                                                                      BorderSide(
                                                                        color:
                                                                            Colors.white,
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
                                                        child: Text(
                                                          AppLocalizations.of(
                                                            context,
                                                          )!.cancel,
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
                                                        child: Text(
                                                          AppLocalizations.of(
                                                            context,
                                                          )!.change,
                                                          style: TextStyle(
                                                            color: const Color(
                                                              0xFF8AC249,
                                                            ),
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
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
                                            await user.reload();
                                            setState(() {});
                                            if (context.mounted) {
                                              await showDialog(
                                                context: context,
                                                builder:
                                                    (context) => AlertDialog(
                                                      backgroundColor:
                                                          const Color(
                                                            0xFF8AC249,
                                                          ),
                                                      title: Text(
                                                        AppLocalizations.of(
                                                          context,
                                                        )!.emailChange,
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      content: Text(
                                                        AppLocalizations.of(
                                                          context,
                                                        )!.verifyNewEmail,
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
                                                          child: Text(
                                                            AppLocalizations.of(
                                                              context,
                                                            )!.ok,
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
                                                backgroundColor: const Color(
                                                  0xFF8AC249,
                                                ),
                                                content: Text(
                                                  '${AppLocalizations.of(context)!.updateEmailFailed} $e',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyLarge
                                                      ?.copyWith(
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
                                  ),
                                  const SizedBox(height: 10),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? Colors.black
                                              : Colors.white,
                                      foregroundColor: const Color(0xFF8AC249),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                        side: const BorderSide(
                                          color: Color(0xFF8AC249),
                                          width: 2,
                                        ),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                      elevation: 0,
                                      alignment: Alignment.center,
                                    ),
                                    child: Text(
                                      AppLocalizations.of(
                                        context,
                                      )!.resetPasswordButton,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF8AC249),
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    onPressed: () async {
                                      final user =
                                          FirebaseAuth.instance.currentUser;
                                      if (user == null || user.email == null) {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              backgroundColor: Color(
                                                0xFF8AC249,
                                              ),
                                              content: Text(
                                                AppLocalizations.of(
                                                  context,
                                                )!.noUser,
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

                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder:
                                            (context) => AlertDialog(
                                              backgroundColor: const Color(
                                                0xFF8AC249,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              title: Text(
                                                AppLocalizations.of(
                                                  context,
                                                )!.resetPassword,
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              content: Text(
                                                "${AppLocalizations.of(context)!.resetPassword} ${user.email}\n\n${AppLocalizations.of(context)!.continueConfirmation}",
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed:
                                                      () => Navigator.pop(
                                                        context,
                                                        false,
                                                      ),
                                                  child: Text(
                                                    AppLocalizations.of(
                                                      context,
                                                    )!.cancel,
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
                                                  child: Text(
                                                    AppLocalizations.of(
                                                      context,
                                                    )!.sendEmail,
                                                    style: TextStyle(
                                                      color: Color(0xFF8AC249),
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                      );

                                      if (confirm != true) return;

                                      try {
                                        await FirebaseAuth.instance
                                            .sendPasswordResetEmail(
                                              email: user.email!,
                                            );
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              backgroundColor: Color(
                                                0xFF8AC249,
                                              ),
                                              content: Text(
                                                AppLocalizations.of(
                                                  context,
                                                )!.resetEmailSent,
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
                                              backgroundColor: const Color(
                                                0xFF8AC249,
                                              ),
                                              content: Text(
                                                '${AppLocalizations.of(context)!.resetEmailFailed} $e',
                                                style: const TextStyle(
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
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              const SizedBox(height: 10),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                  label: Text(
                                    AppLocalizations.of(context)!.deleteAccount,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: 0.5,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 18,
                                    ),
                                    elevation: 1,
                                    alignment: Alignment.center,
                                    textStyle: Theme.of(
                                      context,
                                    ).textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
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
                                            title: Text(
                                              AppLocalizations.of(
                                                context,
                                              )!.deleteAccountTitle,
                                              style: Theme.of(
                                                context,
                                              ).textTheme.titleLarge?.copyWith(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            backgroundColor: const Color(
                                              0xFF8AC249,
                                            ),
                                            content: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  AppLocalizations.of(
                                                    context,
                                                  )!.deleteAccountConfirm,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(height: 16),
                                                TextField(
                                                  controller:
                                                      passwordController1,
                                                  obscureText: true,
                                                  cursorColor: Colors.white,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyLarge
                                                      ?.copyWith(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                  decoration: InputDecoration(
                                                    labelText:
                                                        AppLocalizations.of(
                                                          context,
                                                        )!.enterYourPassword,
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
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyLarge
                                                      ?.copyWith(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                  decoration: InputDecoration(
                                                    labelText:
                                                        AppLocalizations.of(
                                                          context,
                                                        )!.confirmPassword,
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
                                                child: Text(
                                                  AppLocalizations.of(
                                                    context,
                                                  )!.cancel,
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
                                                  if (passwordController1
                                                          .text
                                                          .isEmpty ||
                                                      passwordController2
                                                          .text
                                                          .isEmpty) {
                                                    ScaffoldMessenger.of(
                                                      context,
                                                    ).showSnackBar(
                                                      SnackBar(
                                                        backgroundColor: Color(
                                                          0xFF8AC249,
                                                        ),
                                                        content: Text(
                                                          AppLocalizations.of(
                                                            context,
                                                          )!.enterPasswordTwice,
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontFamily: 'Inter',
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
                                                      SnackBar(
                                                        backgroundColor: Color(
                                                          0xFF8AC249,
                                                        ),
                                                        content: Text(
                                                          AppLocalizations.of(
                                                            context,
                                                          )!.passwordsDontMatch,
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontFamily: 'Inter',
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                    return;
                                                  }
                                                  Navigator.pop(context, true);
                                                },
                                                child: Text(
                                                  AppLocalizations.of(
                                                    context,
                                                  )!.delete,
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
                                      BuildContext? dialogContext;
                                      showDialog(
                                        context: context,
                                        barrierDismissible: false,
                                        builder: (ctx) {
                                          dialogContext = ctx;
                                          return const Center(
                                            child: CircularProgressIndicator(
                                              color: Color(0xFF8AC249),
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
                                            AppLocalizations.of(
                                              context,
                                            )!.noUserEmail,
                                          );
                                        }

                                        final cred =
                                            EmailAuthProvider.credential(
                                              email: email,
                                              password: password,
                                            );
                                        await user!
                                            .reauthenticateWithCredential(cred);

                                        if (notificationsInitialized) {
                                          await flutterLocalNotificationsPlugin
                                              .cancelAll();
                                        }

                                        final medsCollection = FirebaseFirestore
                                            .instance
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
                                                  backgroundColor: const Color(
                                                    0xFF8AC249,
                                                  ),
                                                  title: Text(
                                                    AppLocalizations.of(
                                                      context,
                                                    )!.accountDeleted,
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  content: Text(
                                                    AppLocalizations.of(
                                                      context,
                                                    )!.accountDeletedSuccess,
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
                                                      child: Text(
                                                        AppLocalizations.of(
                                                          context,
                                                        )!.ok,
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
                                              backgroundColor: const Color(
                                                0xFF8AC249,
                                              ),
                                              content: Text(
                                                "${AppLocalizations.of(context)!.accountDeletedFailed} $e",
                                                style: const TextStyle(
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
                              ),

                              const SizedBox(height: 18),
                              Divider(
                                color:
                                    Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.white24
                                        : const Color(
                                          0xFF8AC249,
                                        ).withValues(alpha: 0.2),
                                thickness: 1.2,
                              ),
                              const SizedBox(height: 10),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  icon: const Icon(
                                    Icons.email,
                                    color: Colors.white,
                                  ),
                                  label: Text(
                                    AppLocalizations.of(context)!.contactMe,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyLarge?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF8AC249),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    elevation: 2,
                                  ),
                                  onPressed: () async {
                                    final messageController =
                                        TextEditingController();
                                    final result = await showDialog<String>(
                                      context: context,
                                      builder:
                                          (context) => AlertDialog(
                                            backgroundColor: Color(0xFF8AC249),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            title: Text(
                                              AppLocalizations.of(
                                                context,
                                              )!.contactMe,
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            content: TextField(
                                              controller: messageController,
                                              maxLines: 5,
                                              cursorColor: Colors.white,
                                              style: Theme.of(
                                                context,
                                              ).textTheme.bodyLarge?.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                              decoration: InputDecoration(
                                                hintText:
                                                    AppLocalizations.of(
                                                      context,
                                                    )!.writeYourMessageHere,
                                                hintStyle: Theme.of(
                                                  context,
                                                ).textTheme.bodyLarge?.copyWith(
                                                  color: Colors.white70,
                                                  fontWeight: FontWeight.normal,
                                                ),
                                                filled: true,
                                                fillColor: Colors.white
                                                    .withValues(alpha: 0.15),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            12,
                                                          ),
                                                      borderSide:
                                                          const BorderSide(
                                                            color: Colors.white,
                                                          ),
                                                    ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            12,
                                                          ),
                                                      borderSide:
                                                          const BorderSide(
                                                            color: Colors.white,
                                                          ),
                                                    ),
                                              ),
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed:
                                                    () =>
                                                        Navigator.pop(context),
                                                child: Text(
                                                  AppLocalizations.of(
                                                    context,
                                                  )!.cancel,
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.white,
                                                  foregroundColor: Color(
                                                    0xFF8AC249,
                                                  ),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                  ),
                                                ),
                                                onPressed: () async {
                                                  final message =
                                                      messageController.text
                                                          .trim();
                                                  if (message.isEmpty) return;

                                                  final user =
                                                      FirebaseAuth
                                                          .instance
                                                          .currentUser;
                                                  if (user == null) {
                                                    if (context.mounted) {
                                                      ScaffoldMessenger.of(
                                                        context,
                                                      ).showSnackBar(
                                                        SnackBar(
                                                          backgroundColor:
                                                              Color(0xFF8AC249),
                                                          content: Text(
                                                            AppLocalizations.of(
                                                              context,
                                                            )!.mustBeLoggedIn,
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontFamily:
                                                                  'Inter',
                                                            ),
                                                          ),
                                                        ),
                                                      );
                                                    }
                                                    return;
                                                  }

                                                  try {
                                                    await FirebaseFirestore
                                                        .instance
                                                        .collection(
                                                          'ContactMessages',
                                                        )
                                                        .add({
                                                          'userId': user.uid,
                                                          'userEmail':
                                                              user.email,
                                                          'message': message,
                                                          'timestamp':
                                                              FieldValue.serverTimestamp(),
                                                        });
                                                    if (context.mounted) {
                                                      Navigator.pop(
                                                        context,
                                                        message,
                                                      );
                                                      ScaffoldMessenger.of(
                                                        context,
                                                      ).showSnackBar(
                                                        SnackBar(
                                                          backgroundColor:
                                                              Color(0xFF8AC249),
                                                          content: Text(
                                                            AppLocalizations.of(
                                                              context,
                                                            )!.messageSent,
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontFamily:
                                                                  'Inter',
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
                                                          backgroundColor:
                                                              Color(0xFF8AC249),
                                                          content: Text(
                                                            '${AppLocalizations.of(context)!.messageFailed} $e',
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontFamily:
                                                                  'Inter',
                                                            ),
                                                          ),
                                                        ),
                                                      );
                                                    }
                                                  }
                                                },
                                                child: Text(
                                                  AppLocalizations.of(
                                                    context,
                                                  )!.send,
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
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              backgroundColor: Color(
                                                0xFF8AC249,
                                              ),
                                              content: Text(
                                                '${AppLocalizations.of(context)!.messageFailed} $e',
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
                              ),
                              SizedBox(height: 18),
                              Container(
                                decoration: BoxDecoration(
                                  color:
                                      Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.white10
                                          : const Color(0xFFF1F8E9),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                child: ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: const Icon(
                                    Icons.palette,
                                    color: Color(0xFF8AC249),
                                  ),
                                  title: Text(
                                    AppLocalizations.of(context)!.theme,
                                    style: Theme.of(context).textTheme.bodyLarge
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: ValueListenableBuilder<ThemeMode>(
                                    valueListenable: themeModeNotifier,
                                    builder: (context, mode, _) {
                                      return DropdownButton<ThemeMode>(
                                        value: mode,
                                        dropdownColor:
                                            Theme.of(context).cardColor,
                                        items: [
                                          DropdownMenuItem(
                                            value: ThemeMode.system,
                                            child: Text(
                                              AppLocalizations.of(
                                                context,
                                              )!.systemTheme,
                                              style:
                                                  Theme.of(
                                                    context,
                                                  ).textTheme.bodyLarge,
                                            ),
                                          ),
                                          DropdownMenuItem(
                                            value: ThemeMode.light,
                                            child: Text(
                                              AppLocalizations.of(
                                                context,
                                              )!.light,
                                              style:
                                                  Theme.of(
                                                    context,
                                                  ).textTheme.bodyLarge,
                                            ),
                                          ),
                                          DropdownMenuItem(
                                            value: ThemeMode.dark,
                                            child: Text(
                                              AppLocalizations.of(
                                                context,
                                              )!.dark,
                                              style:
                                                  Theme.of(
                                                    context,
                                                  ).textTheme.bodyLarge,
                                            ),
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
                              ),
                              const SizedBox(height: 18),
                              Container(
                                decoration: BoxDecoration(
                                  color:
                                      Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.white10
                                          : const Color(0xFFF1F8E9),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                child: ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: const Icon(
                                    Icons.language,
                                    color: Color(0xFF8AC249),
                                  ),
                                  title: Text(
                                    AppLocalizations.of(context)!.language,
                                    style: Theme.of(context).textTheme.bodyLarge
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: DropdownButton<Locale?>(
                                    value: localeNotifier.value,
                                    items: [
                                      DropdownMenuItem(
                                        value: null,
                                        child: Text(
                                          AppLocalizations.of(
                                            context,
                                          )!.systemTheme,
                                        ),
                                      ),
                                      DropdownMenuItem(
                                        value: const Locale('en'),
                                        child: Text('English'),
                                      ),
                                      DropdownMenuItem(
                                        value: const Locale('ar'),
                                        child: Text('العربية'),
                                      ),
                                    ],
                                    onChanged: (Locale? locale) async {
                                      MainApp.setLocale(
                                        context,
                                        locale ?? const Locale('en'),
                                      );
                                      localeNotifier.value = locale;
                                      final prefs =
                                          await SharedPreferences.getInstance();
                                      await prefs.setString(
                                        'preferredLanguage',
                                        locale?.languageCode ?? 'en',
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
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
