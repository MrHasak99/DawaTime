import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dawatime/home_page.dart';
import 'package:dawatime/utils/medication_helpers.dart';
import 'package:dawatime/utils/medication_notifications.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'login_page.dart';
import 'package:dawatime/main.dart'
    show
        flutterLocalNotificationsPlugin,
        notificationsInitialized,
        themeModeNotifier,
        localeNotifier,
        forceUpdateCheck,
        showForceUpdateDialog;
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
        final payload = response.payload!;

        if (payload == 'refill_multiple' || payload.startsWith('refill_')) {
          Navigator.of(context).popUntil((route) => route.isFirst);
          return;
        }

        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          final doc =
              await FirebaseFirestore.instance
                  .collection('Users')
                  .doc(user.uid)
                  .collection('medications')
                  .doc(payload)
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
                icon: const Icon(
                  Icons.info_outline_rounded,
                  color: Colors.white,
                ),
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
                                      Icons.person_rounded,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${AppLocalizations.of(context)!.developed}: ${AppLocalizations.of(context)!.developer}',
                                            style: Theme.of(
                                              context,
                                            ).textTheme.bodyLarge?.copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          InkWell(
                                            onTap: () async {
                                              Navigator.pop(context);
                                              try {
                                                final url = Uri.parse(
                                                  'https://portfolio.hamadalkhalaf.com',
                                                );
                                                if (await canLaunchUrl(url)) {
                                                  await launchUrl(
                                                    url,
                                                    mode:
                                                        LaunchMode
                                                            .externalApplication,
                                                  );
                                                }
                                              } catch (e) {
                                                // Silent fail
                                              }
                                            },
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.language,
                                                  color: Colors.white70,
                                                  size: 14,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  AppLocalizations.of(
                                                    context,
                                                  )!.visitPortfolio,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall
                                                      ?.copyWith(
                                                        color: Colors.white70,
                                                        fontSize: 13,
                                                        decoration:
                                                            TextDecoration
                                                                .underline,
                                                        decorationColor:
                                                            Colors.white70,
                                                      ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Color(0xFF405DE6),
                                            Color(0xFF5B51D8),
                                            Color(0xFF833AB4),
                                            Color(0xFFC13584),
                                            Color(0xFFE1306C),
                                            Color(0xFFFD1D1D),
                                            Color(0xFFF56040),
                                            Color(0xFFF77737),
                                            Color(0xFFFCAF45),
                                            Color(0xFFFFDC80),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Image.asset(
                                          'assets/instagram.png',
                                          width: 20,
                                          height: 20,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: TextButton(
                                        onPressed: () async {
                                          Navigator.pop(context);
                                          try {
                                            final url = Uri.parse(
                                              'https://www.instagram.com/dawatimeapp/',
                                            );
                                            if (await canLaunchUrl(url)) {
                                              await launchUrl(
                                                url,
                                                mode:
                                                    LaunchMode
                                                        .externalApplication,
                                              );
                                            }
                                          } catch (e) {
                                            // Silent fail
                                          }
                                        },
                                        style: TextButton.styleFrom(
                                          foregroundColor: Colors.white,
                                          alignment: Alignment.centerLeft,
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 8,
                                          ),
                                        ),
                                        child: Text(
                                          AppLocalizations.of(
                                            context,
                                          )!.followUsOnInstagram,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                            decoration:
                                                TextDecoration.underline,
                                            decorationColor: Colors.white,
                                          ),
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
                                        onPressed: () async {
                                          Navigator.pop(context);
                                          try {
                                            final url = Uri.parse(
                                              'https://dawatime.com/privacy-policy',
                                            );
                                            if (await canLaunchUrl(url)) {
                                              await launchUrl(
                                                url,
                                                mode:
                                                    LaunchMode
                                                        .externalApplication,
                                              );
                                            }
                                          } catch (e) {
                                            // Silent fail
                                          }
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
                                        onPressed: () async {
                                          Navigator.pop(context);
                                          try {
                                            final url = Uri.parse(
                                              'https://dawatime.com/terms-and-conditions',
                                            );
                                            if (await canLaunchUrl(url)) {
                                              await launchUrl(
                                                url,
                                                mode:
                                                    LaunchMode
                                                        .externalApplication,
                                              );
                                            }
                                          } catch (e) {
                                            // Silent fail
                                          }
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
                                if (!kIsWeb) ...[
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton.icon(
                                      icon: Icon(Icons.system_update_rounded),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white
                                            .withValues(alpha: 0.1),
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          side: BorderSide(
                                            color: Colors.white.withValues(
                                              alpha: 0.3,
                                            ),
                                          ),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 14,
                                        ),
                                        elevation: 0,
                                      ),
                                      label: Text(
                                        AppLocalizations.of(
                                          context,
                                        )!.checkForUpdates,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      onPressed: () async {
                                        try {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                AppLocalizations.of(
                                                  context,
                                                )!.checkingForUpdates,
                                                style: TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                              backgroundColor: Color(
                                                0xFF8AC249,
                                              ),
                                              persist: false,
                                            ),
                                          );

                                          final updateNeeded =
                                              await forceUpdateCheck(context);

                                          if (updateNeeded) {
                                            Navigator.pop(context);
                                            await showForceUpdateDialog(
                                              context,
                                            );
                                          } else {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  AppLocalizations.of(
                                                    context,
                                                  )!.upToDate,
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                backgroundColor: Color(
                                                  0xFF8AC249,
                                                ),
                                                persist: false,
                                              ),
                                            );
                                          }
                                        } catch (e) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                AppLocalizations.of(
                                                  context,
                                                )!.failedUpdateCheck,
                                                style: TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                              backgroundColor: Colors.red,
                                              persist: false,
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                ],
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
                                        color: Color(0xFF8AC249),
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
                icon: const Icon(Icons.logout_rounded, color: Colors.white),
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
                    try {
                      if (!kIsWeb) {
                        await flutterLocalNotificationsPlugin.cancelAll();
                      }
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.clear();
                      await FirebaseAuth.instance.signOut();
                      if (!context.mounted) return;
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginPage()),
                        (route) => false,
                      );
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: Colors.red,
                            content: Text(
                              'Logout failed: $e',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            persist: false,
                          ),
                        );
                      }
                    }
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
                                  Icons.account_circle_rounded,
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
                                                      textDirection: null,
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
                                            setState(() {});
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
                                                persist: false,
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
                                                persist: false,
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
                                                                color:
                                                                    Colors
                                                                        .white,
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
                                                                color:
                                                                    Colors
                                                                        .white,
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
                                                persist: false,
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
                                              persist: false,
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
                                                "${AppLocalizations.of(context)!.passwordEmail} ${user.email}\n\n${AppLocalizations.of(context)!.continueConfirmation}",
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
                                              persist: false,
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
                                              persist: false,
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
                                    Icons.delete_rounded,
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
                                                        persist: false,
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
                                                        persist: false,
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
                                            .collection('Users')
                                            .doc(user.uid)
                                            .collection('medications');
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
                                              persist: false,
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
                                    Icons.email_rounded,
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
                                                          persist: false,
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
                                                          persist: false,
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
                                                          persist: false,
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
                                              persist: false,
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
                                    Icons.palette_rounded,
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
                                    Icons.language_rounded,
                                    color: Color(0xFF8AC249),
                                  ),
                                  title: Text(
                                    AppLocalizations.of(context)!.language,
                                    style: Theme.of(context).textTheme.bodyLarge
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: ValueListenableBuilder<Locale?>(
                                    valueListenable: localeNotifier,
                                    builder: (context, locale, _) {
                                      return DropdownButton<Locale?>(
                                        value: locale,
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
                                          final savedValue =
                                              locale?.languageCode ?? 'system';

                                          localeNotifier.value = locale;
                                          final prefs =
                                              await SharedPreferences.getInstance();
                                          await prefs.setString(
                                            'preferredLanguage',
                                            savedValue,
                                          );
                                          final user =
                                              FirebaseAuth.instance.currentUser;
                                          if (user != null) {
                                            await FirebaseFirestore.instance
                                                .collection('Users')
                                                .doc(user.uid)
                                                .set({
                                                  'preferredLanguage':
                                                      savedValue,
                                                }, SetOptions(merge: true));
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
                                child: FutureBuilder<DocumentSnapshot>(
                                  future:
                                      FirebaseFirestore.instance
                                          .collection('Users')
                                          .doc(user.uid)
                                          .get(),
                                  builder: (context, snapshot) {
                                    if (!snapshot.hasData) {
                                      return const SizedBox.shrink();
                                    }

                                    final userData =
                                        snapshot.data!.data()
                                            as Map<String, dynamic>?;
                                    final refillDay =
                                        userData?['refillReminderDay'] ?? 7;
                                    final refillTime =
                                        userData?['refillReminderTime'] ??
                                        '10:00';

                                    final timeParts = refillTime.split(':');
                                    final refillTimeOfDay = TimeOfDay(
                                      hour: int.tryParse(timeParts[0]) ?? 10,
                                      minute: int.tryParse(timeParts[1]) ?? 0,
                                    );

                                    String getDayName(int day) {
                                      final loc = AppLocalizations.of(context)!;
                                      switch (day) {
                                        case 1:
                                          return loc.monday;
                                        case 2:
                                          return loc.tuesday;
                                        case 3:
                                          return loc.wednesday;
                                        case 4:
                                          return loc.thursday;
                                        case 5:
                                          return loc.friday;
                                        case 6:
                                          return loc.saturday;
                                        case 7:
                                          return loc.sunday;
                                        default:
                                          return loc.sunday;
                                      }
                                    }

                                    return ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      leading: const Icon(
                                        Icons.event_repeat_rounded,
                                        color: Color(0xFF8AC249),
                                      ),
                                      title: Text(
                                        AppLocalizations.of(
                                          context,
                                        )!.refillReminderSettings,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodyLarge?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      subtitle: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.baseline,
                                        textBaseline: TextBaseline.alphabetic,
                                        children: [
                                          DropdownButton<int>(
                                            value: refillDay,
                                            dropdownColor:
                                                Theme.of(context).cardColor,
                                            items:
                                                [7, 1, 2, 3, 4, 5, 6].map((
                                                  day,
                                                ) {
                                                  return DropdownMenuItem(
                                                    value: day,
                                                    child: Text(
                                                      getDayName(day),
                                                      style:
                                                          Theme.of(
                                                            context,
                                                          ).textTheme.bodyLarge,
                                                    ),
                                                  );
                                                }).toList(),
                                            onChanged: (int? newDay) async {
                                              if (newDay != null) {
                                                await FirebaseFirestore.instance
                                                    .collection('Users')
                                                    .doc(user.uid)
                                                    .set({
                                                      'refillReminderDay':
                                                          newDay,
                                                    }, SetOptions(merge: true));
                                                await _rescheduleAllRefillReminders(
                                                  user.uid,
                                                );
                                                if (mounted) {
                                                  setState(() {});
                                                }
                                              }
                                            },
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            AppLocalizations.of(context)!.at,
                                            style: Theme.of(
                                              context,
                                            ).textTheme.bodyLarge?.copyWith(
                                              color:
                                                  Theme.of(
                                                    context,
                                                  ).textTheme.bodyLarge?.color,
                                              fontWeight: FontWeight.normal,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          InkWell(
                                            onTap: () async {
                                              final timeParts = refillTime
                                                  .split(':');
                                              final currentTime = TimeOfDay(
                                                hour:
                                                    int.tryParse(
                                                      timeParts[0],
                                                    ) ??
                                                    10,
                                                minute:
                                                    int.tryParse(
                                                      timeParts[1],
                                                    ) ??
                                                    0,
                                              );

                                              final isDark =
                                                  Theme.of(
                                                    context,
                                                  ).brightness ==
                                                  Brightness.dark;
                                              final primaryColor = const Color(
                                                0xFF8AC249,
                                              );
                                              final surfaceColor =
                                                  isDark
                                                      ? const Color(0xFF222222)
                                                      : Colors.white;
                                              final hourMinuteBg =
                                                  isDark
                                                      ? primaryColor.withValues(
                                                        alpha: 0.15,
                                                      )
                                                      : primaryColor.withValues(
                                                        alpha: 0.08,
                                                      );

                                              final TimeOfDay?
                                              picked = await showTimePicker(
                                                context: context,
                                                initialTime: currentTime,
                                                builder: (context, child) {
                                                  return Theme(
                                                    data: Theme.of(
                                                      context,
                                                    ).copyWith(
                                                      timePickerTheme: TimePickerThemeData(
                                                        backgroundColor:
                                                            surfaceColor,
                                                        hourMinuteTextColor:
                                                            primaryColor,
                                                        hourMinuteColor:
                                                            hourMinuteBg,
                                                        dayPeriodTextColor:
                                                            primaryColor,
                                                        dayPeriodColor:
                                                            hourMinuteBg,
                                                        dialHandColor:
                                                            primaryColor,
                                                        dialBackgroundColor:
                                                            hourMinuteBg,
                                                        entryModeIconColor:
                                                            primaryColor,
                                                        helpTextStyle:
                                                            TextStyle(
                                                              color:
                                                                  primaryColor,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                        hourMinuteTextStyle:
                                                            TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 28,
                                                              color:
                                                                  primaryColor,
                                                            ),
                                                        dayPeriodTextStyle:
                                                            TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 16,
                                                              color:
                                                                  primaryColor,
                                                            ),
                                                        dialTextStyle:
                                                            TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 20,
                                                              color:
                                                                  primaryColor,
                                                            ),
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                24,
                                                              ),
                                                        ),
                                                      ),
                                                      textButtonTheme:
                                                          TextButtonThemeData(
                                                            style: TextButton.styleFrom(
                                                              foregroundColor:
                                                                  primaryColor,
                                                              textStyle:
                                                                  const TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                            ),
                                                          ),
                                                      colorScheme: ColorScheme(
                                                        brightness:
                                                            isDark
                                                                ? Brightness
                                                                    .dark
                                                                : Brightness
                                                                    .light,
                                                        primary: primaryColor,
                                                        onPrimary: Colors.white,
                                                        secondary: primaryColor,
                                                        onSecondary:
                                                            Colors.white,
                                                        error: Colors.red,
                                                        onError: Colors.white,
                                                        surface: surfaceColor,
                                                        onSurface:
                                                            isDark
                                                                ? Colors.white
                                                                : primaryColor,
                                                      ),
                                                    ),
                                                    child: child!,
                                                  );
                                                },
                                              );

                                              if (picked != null) {
                                                final newTime =
                                                    '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
                                                await FirebaseFirestore.instance
                                                    .collection('Users')
                                                    .doc(user.uid)
                                                    .set({
                                                      'refillReminderTime':
                                                          newTime,
                                                    }, SetOptions(merge: true));
                                                await _rescheduleAllRefillReminders(
                                                  user.uid,
                                                );
                                                if (mounted) {
                                                  setState(() {});
                                                }
                                              }
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.only(
                                                bottom: 5,
                                              ),
                                              decoration: BoxDecoration(
                                                border: Border(
                                                  bottom: BorderSide(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onSurface
                                                        .withValues(
                                                          alpha: 0.12,
                                                        ),
                                                    width: 1,
                                                  ),
                                                ),
                                              ),
                                              child: Text(
                                                refillTimeOfDay.format(context),
                                                style:
                                                    Theme.of(
                                                      context,
                                                    ).textTheme.bodyLarge,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 18),
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

  Future<void> _rescheduleAllRefillReminders(String userId) async {
    try {
      final meds =
          await FirebaseFirestore.instance
              .collection('Users')
              .doc(userId)
              .collection('medications')
              .limit(12)
              .get();

      for (var doc in meds.docs) {
        final medication = medicationFromDoc(doc);

        if (medication.refillThreshold != null &&
            medication.refillThreshold! > 0 &&
            medication.amount <= medication.refillThreshold!) {
          await scheduleWeeklyRefillNotification(medication, doc.id, userId);
        }
      }
    } catch (_) {}
  }
}
