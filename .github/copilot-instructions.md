# DawaTime - AI Coding Agent Instructions

## Project Overview
DawaTime is a Flutter medication reminder app with Firebase backend, supporting Arabic/English localization. The app manages medication schedules, local notifications, and refill reminders with background task execution. Target platforms: Android (SDK 24+) and iOS.

## Architecture & Key Components

### Core Files Structure
- **`lib/main.dart`** (1055 lines): App entry point with critical initialization sequence:
  - Firebase initialization with timeout handling
  - Workmanager background task registration (`medicationRescheduleTask` runs hourly)
  - Timezone initialization via `flutter_timezone` (fallback to UTC if fails)
  - Notification plugin setup with `selectNotificationStream` listener
  - Theme/locale persistence via `SharedPreferences`
  - Force update check on app launch (`forceUpdateCheck()` compares Firestore `AppConfig/Version` with local version)
  - FCM background message handler (`_firebaseMessagingBackgroundHandler`)

- **`lib/home_page.dart`** (4488 lines): Main UI and notification logic hub:
  - `StreamBuilder<QuerySnapshot>` for real-time Firestore medication updates
  - `Dismissible` widgets for swipe-to-edit (left/right) and swipe-to-delete (end-to-start)
  - Notification scheduling: `scheduleMedicationNotification()`, `scheduleWeeklyRefillNotification()`
  - Notification cancellation: `cancelMedicationReminders()`, `cancelRefillNotifications()`
  - Utility functions: `medicationFromDoc()`, `getNextReminder()`, `convertArabicNumerals()`
  - Auto-reschedule logic in `_autoRescheduleOverdueMedications()` (runs on app open)
  - Permission checking: `requestExactAlarmPermission()`, `openExactAlarmSettings()`

- **`lib/add_medications.dart`** (1608 lines): Medication CRUD operations:
  - Two frequency modes via `FrequencyType` enum: `everyXDays` (interval-based) or `daysOfWeek` (specific weekdays)
  - 12-medication limit enforcement (checked via Firestore query count)
  - Inline edit dialogs within `home_page.dart` use same validation logic
  - Refill threshold field (optional) triggers weekly refill notifications

- **`lib/settings.dart`** (2306 lines): User profile and app configuration:
  - Theme switching (light/dark/system) with `ValueNotifier<ThemeMode>` + `SharedPreferences` persistence
  - Language toggle (English/Arabic) with `ValueNotifier<Locale?>` + Firestore user profile update
  - Account deletion flow (calls Cloud Function `requestAccountDeletion`)
  - App version display and update check trigger
  - Privacy policy and terms links to public website pages

- **`lib/login_page.dart` & `lib/signup_page.dart`**: Firebase Authentication flows:
  - Email/password only (no social auth)
  - Signup sends verification email via `sendEmailVerification()`
  - Terms & Conditions and Privacy Policy acceptance required (checkbox validation)
  - Creates Firestore `/Users/{uid}` document on successful signup

### Data Model & Firestore Structure

#### Medications Class
```dart
class Medications {
  final String name;
  final String typeOfMedication;  // Unit of measurement (pills, ml, etc.)
  final double dosage;
  final int frequency;            // Days between doses (everyXDays mode)
  final double amount;            // Current stock amount
  final String? notifyTime;       // Format: "HH:mm" (24-hour)
  final DateTime? startDate;      // First scheduled dose date
  final List<int>? daysOfWeek;    // Weekday numbers (1=Mon, 7=Sun) for daysOfWeek mode
  final DateTime? lastTaken;      // Timestamp of last dose confirmation
  final double? refillThreshold;  // Stock level to trigger refill reminder
  final bool? refillNotified;     // Flag to prevent duplicate refill notifications
}
```

#### Firestore Collections
- **`/Users/{uid}`**: User profile data (name, email, fcmToken, preferredLanguage)
- **`/{userId}/{medicationId}`**: Medication documents (scoped per user)
- **`/AppConfig/Version`**: App version control (triggers Cloud Function on update)
- **`/ContactMessages/{messageId}`**: Contact form submissions
- **`/Messages/{document}`**: Public read/write (used for support messages)

#### Firestore Security Rules Pattern
```javascript
match /{userId}/{medicationId} {
  allow read, write: if request.auth != null && request.auth.uid == userId;
}
```
All user data is strictly isolated by authenticated UID - never use shared collections for medication data.

### Notification System Architecture

#### Broadcast StreamController Pattern
**Critical**: All pages that need to handle notification taps must listen to this stream in `initState()`:
```dart
final StreamController<NotificationResponse> selectNotificationStream =
    StreamController<NotificationResponse>.broadcast();
```

**Why broadcast?** Multiple pages (HomePage, AddMedications, Settings) listen simultaneously. When notification is tapped, all listeners receive the event, but only the currently mounted widget should process it (check `context.mounted`).

**Initialization in main.dart**:
```dart
await flutterLocalNotificationsPlugin.initialize(
  initializationSettings,
  onDidReceiveNotificationResponse: (NotificationResponse response) async {
    selectNotificationStream.add(response);  // Broadcast to all listeners
    // Handle special payloads like 'update_available'
  },
);
```

#### Notification Scheduling Logic

**Function: `scheduleMedicationNotification()` (line ~3749 in home_page.dart)**
- **Cancels previous notifications**: Loops through `docId.hashCode + i` (i=0 to 4) to clear old schedules
- **Two scheduling modes**:
  1. **daysOfWeek mode**: Calculates next occurrence of each selected weekday
  2. **everyXDays mode**: Adds `frequency` days to `startDate` repeatedly until future date found
- **Follow-up reminders**: Schedules 5 notifications at 30-minute intervals (immediate, +30min, +60min, +90min, +120min)
- **2-hour grace period**: If notification time passed today but < 2 hours ago, schedules follow-ups starting now
- **Uses `androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle`** for reliable delivery even in Doze mode
- **Notification ID generation**: `('${docId}_${weekday}_$followUpIndex').hashCode` ensures uniqueness

**Function: `scheduleWeeklyRefillNotification()` (line ~4082)**
- Schedules weekly recurring notification at 10:00 AM
- Uses `matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime` for weekly repeat
- Separate channel ID `'refill_channel'` with orange color (`0xFFFF9800`)
- Notification ID: `('refill_weekly_$docId').hashCode`

**Function: `cancelMedicationReminders()` (line ~4075)**
- Cancels notifications with IDs: `('${docId}_$i').hashCode` where i=0 to 8
- Call before rescheduling to prevent duplicate notifications

**Function: `cancelRefillNotifications()` (line ~4165)**
- Cancels refill notification with ID: `('refill_weekly_$docId').hashCode`

#### Notification Channels
1. **Medication reminders**: Channel ID = `'medication_channel_$docId'` (per-medication channel)
2. **Refill reminders**: Channel ID = `'refill_channel'` (shared channel, orange color)
3. **App updates**: Channel ID = `'updates'` (green color, high priority)

#### Payload Handling Patterns
- **Medication reminder**: `payload = docId` → Open medication details dialog
- **Refill reminder**: `payload = 'refill_$docId'` or `'refill_multiple'` → Show refill alert
- **Update notification**: `payload = 'update_available'` → Open force update dialog

### Firebase Integration Details

#### Cloud Functions (`functions/index.js`)

**`notifyOnVersionUpdate` (line 9-145)**:
- Trigger: Firestore document `AppConfig/Version` onUpdate
- Paginates through `/Users` collection (100 docs per batch)
- Sends FCM data messages to all users with `fcmToken`
- Separate messages for Arabic (`language: 'ar'`) and English users
- Batches FCM sends (500 tokens per multicast)
- Returns success/failure counts

**`emailAdminsOnContactMessage` (line 147-172)**:
- Trigger: Firestore document `ContactMessages/{messageId}` onCreate
- Sends email via Nodemailer (Zoho SMTP: `smtppro.zoho.com:465`)
- From: `admin@dawatime.com`, To: `help@dawatime.com`

**`requestAccountDeletion` (line 174-274)**:
- HTTPS callable function (POST only)
- Authenticates user with email/password
- Deletes Firestore user data recursively
- Deletes Firebase Auth account
- Returns success/failure JSON response

#### Firebase Authentication Flow
1. **Signup** (signup_page.dart):
   - Create auth account with `createUserWithEmailAndPassword()`
   - Send verification email via `sendEmailVerification()`
   - Create Firestore document: `/Users/{uid}` with {name, email, fcmToken, preferredLanguage}
   - Show SnackBar: "Verification email sent, please check your inbox"

2. **Login** (login_page.dart):
   - Sign in with `signInWithEmailAndPassword()`
   - Check `user.emailVerified` (currently not enforced, but should be)
   - Fetch FCM token and update Firestore `/Users/{uid}/fcmToken`
   - Navigate to HomePage with `uid` parameter

3. **Auto-login** (main.dart `AuthGate` widget):
   - Uses `StreamBuilder<User?>` on `FirebaseAuth.instance.authStateChanges()`
   - If user != null → navigate to HomePage
   - If user == null → show LoginPage

#### Firestore Query Patterns
- **Get all medications**: `FirebaseFirestore.instance.collection(userId).get()`
- **Real-time updates**: `FirebaseFirestore.instance.collection(userId).snapshots()` (used in HomePage)
- **Single medication**: `FirebaseFirestore.instance.collection(userId).doc(docId).get()`
- **Update medication**: `.update({...})` (partial update)
- **Delete medication**: `.delete()` + cancel notifications

## Developer Workflows

### Build & Release Commands

#### Android
```bash
# Clean build (ALWAYS run after dependency changes or switching branches)
flutter clean && flutter pub get

# Release builds
flutter build appbundle --release  # Google Play Store (AAB format)
flutter build apk --release         # Direct APK distribution

# Install debug build on connected device
flutter install

# Run with specific flavor (if flavors configured)
flutter run --flavor production
```

**Android Build Configuration** (`android/app/build.gradle.kts`):
- Namespace: `com.mrhasak99.dawatime`
- Min SDK: 24 (Android 7.0)
- Target SDK: 34 (Android 14)
- Compile SDK: Uses flutter.compileSdkVersion (likely 34)
- Signing: Release builds auto-signed with `my-release-key.jks` (stored in `android/app/`)
- ProGuard: Enabled with minification (`isMinifyEnabled = true`)
- Core library desugaring: Enabled for Java 8+ API support on older devices

#### iOS
```bash
# Release builds (macOS only)
flutter build ipa                   # App Store distribution (creates IPA)
flutter build ios --release         # Xcode build (for manual signing/distribution)

# Development builds
flutter build ios                   # Debug build
flutter run                         # Run on simulator/device
```

**iOS Configuration** (`ios/Runner/Info.plist`):
- Bundle ID: `com.mrhasak99.dawatime`
- Minimum iOS version: Check `ios/Podfile` for `platform :ios` version
- Permissions required: Notifications, exact alarm scheduling
- Background modes: Remote notifications, background fetch

### Version Management Checklist

When releasing a new version, update **all three** in sync:

1. **`pubspec.yaml`**: `version: 1.4.4+4`
   - Format: `<major>.<minor>.<patch>+<buildNumber>`
   - Example: `1.4.4+4` = version 1.4.4, build 4

2. **`android/app/build.gradle.kts`**:
   ```kotlin
   versionCode = 4
   versionName = "1.4.4"
   ```

3. **Firebase Firestore** (manual update):
   - Update `/AppConfig/Version` document field `version: "1.4.4"`
   - This triggers Cloud Function to send FCM notifications to all users

**Build number increment rules**:
- Patch release (bug fixes): Increment patch and build (1.4.3+3 → 1.4.4+4)
- Minor release (new features): Increment minor, reset patch (1.4.4+4 → 1.5.0+5)
- Major release (breaking changes): Increment major, reset minor/patch (1.5.0+5 → 2.0.0+6)

### Localization Workflow

#### Adding New Strings
1. **Edit source files**:
   - `lib/l10n/app_en.arb` (English - master file)
   - `lib/l10n/app_ar.arb` (Arabic translation)

2. **ARB format**:
   ```json
   {
     "keyName": "English text",
     "@keyName": {
       "description": "Context for translators"
     },
     "greetUser": "Hello {name}!",
     "@greetUser": {
       "placeholders": {
         "name": {"type": "String"}
       }
     }
   }
   ```

3. **Generate Dart code**:
   ```bash
   flutter gen-l10n  # Manual generation
   # OR just run 'flutter pub get' or 'flutter build' (auto-generates)
   ```

4. **Use in code**:
   ```dart
   final loc = AppLocalizations.of(context)!;
   Text(loc.keyName);                    // Simple string
   Text(loc.greetUser('John'));          // Parameterized string
   ```

#### RTL Support Pattern
Always check locale when setting text direction:
```dart
final isArabic = Localizations.localeOf(context).languageCode == 'ar';
final textDirection = isArabic ? TextDirection.rtl : TextDirection.ltr;

// Apply to widgets:
TextField(
  textDirection: textDirection,
  ...
)

// For Directionality checks:
final isRTL = Directionality.of(context) == TextDirection.rtl;
```

#### Generated Files Location
- **Generated classes**: `.dart_tool/flutter_gen/gen_l10n/`
  - `app_localizations.dart` (base class)
  - `app_localizations_en.dart` (English implementation)
  - `app_localizations_ar.dart` (Arabic implementation)
- **NEVER edit these files directly** - they're regenerated on every build

### Testing Notifications Locally

#### Prerequisites
1. **Physical device required** - Emulators have unreliable notification timing and permission models
2. **Android 13+ specific**: Exact alarm permission must be granted manually (app can't request programmatically)

#### Permission Flow Testing
1. Run app and add medication
2. Check for SnackBar prompting: "Allow DawaTime to schedule exact alarms"
3. Tap "Open Settings" → redirects to system settings via `openExactAlarmSettings()`
4. Enable "Alarms & reminders" toggle
5. Return to app and verify notification schedules

#### Permission Check Function
```dart
Future<void> requestExactAlarmPermission() async {
  final status = await Permission.scheduleExactAlarm.status;
  if (status.isGranted) return;
  // Cannot programmatically request - must use openExactAlarmSettings()
}

Future<void> openExactAlarmSettings() async {
  final intent = AndroidIntent(
    action: 'android.settings.REQUEST_SCHEDULE_EXACT_ALARM',
  );
  await intent.launch();
}
```

#### Testing Immediate Notifications
```dart
// Test notification display (no scheduling)
await flutterLocalNotificationsPlugin.show(
  12345,  // Arbitrary ID
  'Test Title',
  'Test Body',
  NotificationDetails(
    android: AndroidNotificationDetails(
      'test_channel',
      'Test Notifications',
      importance: Importance.max,
      priority: Priority.high,
    ),
  ),
);
```

#### Testing Scheduled Notifications
1. Set medication reminder for 2 minutes in future
2. Check logcat (Android) or Console (iOS) for scheduling confirmation
3. Lock device and wait - notification should appear at exact time
4. Tap notification → verify app opens to medication details

#### Timezone Debugging
If notifications fire at wrong times:
1. Check timezone initialization in `main.dart`:
   ```dart
   tz.initializeTimeZones();
   final String timeZoneName = await FlutterTimezone.getLocalTimezone();
   tz.setLocalLocation(tz.getLocation(timeZoneName));
   ```
2. Verify `tz.local` is set correctly (print in debug mode)
3. Ensure `tz.TZDateTime.from(scheduledTime, tz.local)` used in all scheduling calls

## Project-Specific Conventions

### Theme & Styling

#### Color Palette
- **Primary brand**: `Color(0xFF8AC249)` (vibrant green)
  - Used for: AppBar, buttons, cards, dialogs, icons
- **Refill warning**: `Color(0xFFFF9800)` (orange)
  - Used for: Low stock cards, refill notification channel
- **Out of stock**: `Colors.red`
  - Used for: Empty medication cards, delete actions
- **Dark mode surface**: `Color(0xFF222222)` (dark gray)
  - Used for: Cards and surfaces in dark theme
- **Dark mode check**: `Theme.of(context).brightness == Brightness.dark`

#### Font Families (defined in pubspec.yaml)
- **Inter** (400): Latin script, body text
- **NotoKufiArabic** (400, 700): Arabic script, RTL text
- **Nunito** (800 ExtraBold): Headers and emphasis

#### Consistent Widget Patterns
1. **Dialogs**: Always use rounded corners (24px) with green background
   ```dart
   AlertDialog(
     backgroundColor: const Color(0xFF8AC249),
     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
     ...
   )
   ```

2. **Cards**: Elevation 4, rounded corners (16px)
   ```dart
   Card(
     elevation: 4,
     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
     color: /* conditional color logic */,
     ...
   )
   ```

3. **AppBar**: Transparent with container background
   ```dart
   Container(
     decoration: BoxDecoration(
       color: Color(0xFF8AC249),
       borderRadius: BorderRadius.all(Radius.circular(14)),
     ),
     child: AppBar(backgroundColor: Colors.transparent, elevation: 0, ...),
   )
   ```

### Medication Card Color Logic

Cards in `home_page.dart` ListView use conditional coloring based on stock levels:

```dart
color: medication.amount <= 0
    ? Colors.red  // Out of stock - urgent
    : (medication.refillThreshold != null &&
       medication.refillThreshold! > 0 &&
       medication.amount <= medication.refillThreshold!)
    ? const Color(0xFFFF9800)  // Low stock - warning
    : Color(0xFF8AC249),  // Normal stock - success
```

**Visual hierarchy**:
- **Red card** = Immediate action required (out of stock)
- **Orange card** = Proactive warning (approaching threshold)
- **Green card** = Healthy stock level

### Background Task Pattern (Workmanager)

#### Initialization (main.dart)
```dart
Workmanager().initialize(callbackDispatcher);
Workmanager().registerPeriodicTask(
  "medicationRescheduleTask",
  "medicationRescheduleTask",
  frequency: Duration(hours: 1),  // Minimum interval on Android
  initialDelay: Duration(minutes: 1),
  constraints: Constraints(
    networkType: NetworkType.notRequired,  // Works offline
    requiresBatteryNotLow: false,
    requiresCharging: false,
    requiresDeviceIdle: false,
  ),
);
```

#### Callback Dispatcher (main.dart line ~98)
```dart
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    await Firebase.initializeApp();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final now = DateTime.now();
      if (now.hour == 0 && now.minute < 20) {  // Midnight window
        await rescheduleAllMedications(user.uid);
      }
    }
    return Future.value(true);
  });
}
```

**Important Limitations**:
- **Android**: Works reliably but minimum frequency is 15 minutes (we use 1 hour)
- **iOS**: Severely restricted by system (may not run at all in background)
- **DO NOT rely on this for critical timing** - local notifications are the source of truth
- Use case: Fallback mechanism to reschedule notifications user may have missed
- Runs at midnight (00:00-00:20) to reset daily schedules

### State Management Approach

#### Global State (Theme & Locale)
```dart
// main.dart globals
final ValueNotifier<ThemeMode> themeModeNotifier = ValueNotifier(ThemeMode.system);
final ValueNotifier<Locale?> localeNotifier = ValueNotifier(null);

// Persistence pattern
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

// UI listening pattern
localeNotifier.addListener(() {
  if (mounted) setState(() {});
});
```

#### Firestore Data (Real-time Updates)
```dart
StreamBuilder<QuerySnapshot>(
  stream: FirebaseFirestore.instance.collection(userId).snapshots(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return CircularProgressIndicator();
    }
    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
      return EmptyStateWidget();
    }
    final docs = snapshot.data!.docs;
    return ListView.builder(...);
  },
)
```

**Why StreamBuilder?** Real-time sync across devices - if user adds medication on phone, it appears instantly on tablet.

#### Local State (Form Validation)
```dart
// Stateful widget state
bool _nameError = false;
bool _dosageError = false;
TextEditingController nameController = TextEditingController();

// Validation pattern
if (nameController.text.isEmpty) {
  setState(() => _nameError = true);
  return;
}

// Clear error on input
TextField(
  controller: nameController,
  onChanged: (value) {
    if (_nameError && value.isNotEmpty) {
      setState(() => _nameError = false);
    }
  },
  decoration: InputDecoration(
    errorText: _nameError ? AppLocalizations.of(context)!.pleaseFillAllFields : null,
  ),
)
```

## Common Pitfalls & Solutions

### Arabic Numeral Handling

**Problem**: Arabic locale inputs use Eastern Arabic numerals (٠١٢٣٤٥٦٧٨٩) which crash `int.parse()` and `double.parse()`.

**Solution**: Always convert before parsing:
```dart
String convertArabicNumerals(String input) {
  const arabicNums = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
  for (int i = 0; i < arabicNums.length; i++) {
    input = input.replaceAll(arabicNums[i], i.toString());
  }
  return input;
}

// Usage:
final dosage = double.tryParse(convertArabicNumerals(dosageController.text)) ?? 0;
final frequency = int.tryParse(convertArabicNumerals(frequencyController.text)) ?? 1;
```

**Where to use**: All numeric TextField inputs (dosage, frequency, amount, refillThreshold).

### Dismissible Swipe Direction (RTL)

**Problem**: Swipe gestures feel reversed in Arabic RTL layout.

**Solution**: Swap background widgets based on text direction:
```dart
final isRTL = Directionality.of(context) == TextDirection.rtl;

Dismissible(
  direction: DismissDirection.horizontal,
  background: isRTL
      ? Container(/* Edit icon on right */)  // Swipe left shows edit
      : Container(/* Edit icon on left */),  // Swipe right shows edit
  secondaryBackground: isRTL
      ? Container(/* Delete icon on left */)
      : Container(/* Delete icon on right */),
  confirmDismiss: (direction) async {
    if (direction == DismissDirection.endToStart) {
      // Delete action (swipe toward end of text direction)
      return await showDeleteConfirmDialog();
    } else if (direction == DismissDirection.startToEnd) {
      // Edit action (swipe toward start of text direction)
      showEditDialog();
      return false;  // Don't dismiss, just open dialog
    }
  },
  ...
)
```

### Notification Payload Handling

**Pattern**: Use payload string to determine action in `selectNotificationStream` listener:

```dart
selectNotificationStream.stream.listen((NotificationResponse response) async {
  if (response.payload == null || !context.mounted) return;
  
  final payload = response.payload!;
  
  if (payload == 'update_available') {
    await showForceUpdateDialog(context);
    return;
  }
  
  if (payload.startsWith('refill_')) {
    // Show refill reminder dialog
    return;
  }
  
  // Default: medication reminder (payload = docId)
  final doc = await FirebaseFirestore.instance
      .collection(userId)
      .doc(payload)
      .get();
  if (doc.exists) {
    showMedicationDetailsDialog(context, medicationFromDoc(doc));
  }
});
```

### Firestore Document ID to Notification ID

**Problem**: Notification IDs must be integers, but Firestore auto-IDs are strings.

**Solution**: Use `String.hashCode` for consistent integer conversion:
```dart
// Basic notification ID
final notificationId = docId.hashCode;

// Follow-up notifications (same medication, different times)
final followUpId = ('${docId}_${weekday}_$index').hashCode;

// Refill notifications (different channel)
final refillId = ('refill_weekly_$docId').hashCode;

// Offset pattern (alternative to string interpolation)
final refillId = docId.hashCode + 1000;
```

**Collision risk**: Hash codes can theoretically collide, but probability is low with 12-medication limit. If implementing unlimited medications, consider UUID-based ID generation.

### lastTaken Field Logic

**Purpose**: Prevents duplicate "Take Medication" confirmations within same day.

**Implementation** (home_page.dart "Take Medication" button):
```dart
// When user confirms taking medication:
await firestore.collection(userId).doc(docId).update({
  'amount': medication.amount - medication.dosage < 0 ? 0 : medication.amount - medication.dosage,
  'lastTaken': DateTime.now().toIso8601String(),
});

// Before showing "time to take" alert:
if (medication.lastTaken != null &&
    medication.lastTaken!.isAfter(DateTime(now.year, now.month, now.day))) {
  // Already taken today - skip notification
  return;
}
```

**Edge case**: User changes device timezone mid-day - may allow duplicate confirmations. Consider using UTC for `lastTaken` if this becomes an issue.

## Critical Integration Points

### Permission Flow (Android)

#### Notification Permission (Android 13+)
```dart
// Request in main.dart initialization
if (await Permission.notification.isDenied) {
  await Permission.notification.request().timeout(Duration(seconds: 5));
}

// Check permission status
final status = await Permission.notification.status;
if (status.isGranted) {
  // Can show notifications
}
```

#### Exact Alarm Permission (Android 13+)
**Critical difference**: Cannot be requested programmatically - must open system settings.

```dart
// Check status
final status = await Permission.scheduleExactAlarm.status;

// If not granted, show SnackBar with action
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    backgroundColor: const Color(0xFF8AC249),
    content: Text(AppLocalizations.of(context)!.allowSettings),
    action: SnackBarAction(
      label: AppLocalizations.of(context)!.openSettings,
      onPressed: openExactAlarmSettings,
    ),
  ),
);

// Open system settings
Future<void> openExactAlarmSettings() async {
  final intent = AndroidIntent(
    action: 'android.settings.REQUEST_SCHEDULE_EXACT_ALARM',
  );
  await intent.launch();
}
```

**User flow**:
1. User adds first medication → App checks permission
2. If not granted → SnackBar appears with "Open Settings" action
3. User taps action → System settings page opens
4. User toggles "Alarms & reminders" → Returns to app
5. App reschedules notifications automatically (via StreamBuilder update)

### Force Update Mechanism

#### Flow Overview
1. Developer updates version in Firestore `/AppConfig/Version` document
2. Cloud Function `notifyOnVersionUpdate` triggers and sends FCM to all users
3. User's device receives FCM message while app is in background
4. `_firebaseMessagingBackgroundHandler` in main.dart shows local notification
5. User taps notification → `onDidReceiveNotificationResponse` called with payload `'update_available'`
6. App shows non-dismissible dialog with store links

#### Implementation Details

**Cloud Function Trigger** (functions/index.js):
```javascript
exports.notifyOnVersionUpdate = functions
  .firestore
  .document("AppConfig/Version")
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();
    if (before.version !== after.version) {
      // Send FCM to all users with fcmToken
      // Separate messages for Arabic vs English users
    }
  });
```

**FCM Background Handler** (main.dart):
```dart
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  if (message.data['type'] == 'update_available') {
    // Show local notification with payload 'update_available'
    await flutterLocalNotificationsPlugin.show(999999, title, body, details, payload: 'update_available');
  }
}
```

**Force Update Dialog** (main.dart `showForceUpdateDialog()`):
```dart
Future<void> showForceUpdateDialog(BuildContext context) async {
  return showDialog(
    context: context,
    barrierDismissible: false,  // Cannot dismiss
    builder: (context) => WillPopScope(
      onWillPop: () async => false,  // Cannot back out
      child: AlertDialog(
        title: Text('Update Required'),
        content: Text('Please update to continue using DawaTime'),
        actions: [
          ElevatedButton(
            onPressed: () async {
              // Open Play Store or App Store
              final url = Platform.isAndroid
                  ? 'https://play.google.com/store/apps/details?id=com.mrhasak99.dawatime'
                  : 'https://apps.apple.com/app/dawatime/id...';
              await launchUrl(Uri.parse(url));
            },
            child: Text('Update Now'),
          ),
        ],
      ),
    ),
  );
}
```

**Version Check** (main.dart `forceUpdateCheck()`):
```dart
Future<void> forceUpdateCheck() async {
  final doc = await FirebaseFirestore.instance.collection('AppConfig').doc('Version').get();
  final remoteVersion = doc.data()?['version'] as String?;
  final packageInfo = await PackageInfo.fromPlatform();
  final localVersion = packageInfo.version;
  
  if (remoteVersion != null && remoteVersion != localVersion) {
    // Show force update dialog
    await showForceUpdateDialog(navigatorKey.currentContext!);
  }
}
```

#### Testing Force Update
1. Update local app to version 1.4.3 (build 3)
2. In Firestore, set `/AppConfig/Version/version` to "1.4.4"
3. Cold start app → Force update dialog should appear immediately
4. Verify dialog is non-dismissible (back button doesn't close)

## File Generation & Assets

### Launcher Icons
**Configuration** (pubspec.yaml):
```yaml
flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/DawaTime.png"
  remove_alpha_ios: true  # iOS requires non-transparent icon
```

**Generation command**:
```bash
flutter pub run flutter_launcher_icons
```

**Output**:
- Android: `android/app/src/main/res/mipmap-*/ic_launcher.png` (multiple densities)
- iOS: `ios/Runner/Assets.xcassets/AppIcon.appiconset/` (multiple sizes)

### Splash Screen
**Configuration** (pubspec.yaml):
```yaml
flutter_native_splash:
  color: "#8AC249"  # Brand green background
  image: assets/DawaTime.png
  ios: true
```

**Generation command**:
```bash
flutter pub run flutter_native_splash:create
```

**Output**:
- Android: `android/app/src/main/res/drawable*/launch_background.xml`
- iOS: `ios/Runner/Assets.xcassets/LaunchImage.imageset/`

### Localization (Auto-generated)
**Trigger**: Any of these commands regenerate `.dart_tool/flutter_gen/gen_l10n/`:
- `flutter pub get`
- `flutter build <platform>`
- `flutter gen-l10n` (explicit generation)

**Generated files** (NEVER edit directly):
- `app_localizations.dart` - Base class with abstract methods
- `app_localizations_en.dart` - English implementation
- `app_localizations_ar.dart` - Arabic implementation

**Usage in code**:
```dart
// Import (usually already imported in main.dart)
import 'package:dawatime/l10n/app_localizations.dart';

// Access in build method
final loc = AppLocalizations.of(context)!;
Text(loc.welcomeBack);

// With parameters
Text(loc.medicationDeleted(medication.name));
```

## External Dependencies & Quirks

### workmanager: ^0.9.0+2
**Purpose**: Background task execution for rescheduling missed notifications.

**Android behavior**:
- Minimum frequency: 15 minutes (we use 1 hour)
- Runs reliably even when app is closed
- Respects system battery optimization settings

**iOS behavior**:
- **Severely limited** by iOS background restrictions
- May not run at all if app not opened regularly
- Only executes when system decides (often during charging/WiFi)
- Consider alternative: iOS Background App Refresh (more reliable)

**Implementation notes**:
- Use `@pragma('vm:entry-point')` on callback function
- Always initialize Firebase in callback (no context available)
- Keep execution time < 60 seconds to avoid termination

### timezone: ^0.10.1
**Purpose**: Required for scheduled notifications with exact timezone handling.

**Critical setup** (main.dart):
```dart
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

// In main():
tz.initializeTimeZones();  // Loads IANA timezone database
final String timeZoneName = await FlutterTimezone.getLocalTimezone();  // e.g., "America/New_York"
tz.setLocalLocation(tz.getLocation(timeZoneName));

// When scheduling:
final scheduledTZ = tz.TZDateTime.from(scheduledTime, tz.local);
await flutterLocalNotificationsPlugin.zonedSchedule(..., scheduledTZ, ...);
```

**Common issues**:
- **Forgot `initializeTimeZones()`**: Notification fires at UTC time instead of local
- **Wrong timezone name**: Use `flutter_timezone` plugin, not `geolocator` (more reliable)
- **DST transitions**: `tz.TZDateTime` handles automatically if timezone DB is loaded

### flutter_slidable: ^4.0.0
**Status**: Included in pubspec.yaml but **NOT USED** in codebase.

**Reason for inclusion**: Likely used in earlier version, replaced with `Dismissible` widget for simpler swipe implementation.

**Recommendation**: Remove from dependencies in next version to reduce APK size.

### geolocator: ^14.0.2 & geocoding: ^4.0.0
**Status**: Included but **timezone detection uses `flutter_timezone` instead**.

**Reason for inclusion**: Possibly planned feature for location-based reminders or clinic finder.

**Current usage**: None - consider removing if no future plans for geolocation features.

### permission_handler: ^12.0.0+1
**Usage**: Handles notification and exact alarm permissions.

**Supported permissions in app**:
- `Permission.notification` (Android 13+, iOS always)
- `Permission.scheduleExactAlarm` (Android 13+)

**Platform-specific behavior**:
```dart
if (Platform.isAndroid) {
  // Android 13+ requires runtime permission
  await Permission.notification.request();
  
  // Exact alarm cannot be requested programmatically
  final status = await Permission.scheduleExactAlarm.status;
  if (!status.isGranted) {
    // Must open settings manually
  }
}

if (Platform.isIOS) {
  // iOS permissions requested via flutterLocalNotificationsPlugin
  await iosImplementation.requestPermissions(alert: true, badge: true, sound: true);
}
```

## Advanced Notification Scenarios

### Handling Overdue Medications
**Function**: `_autoRescheduleOverdueMedications()` (home_page.dart line ~374)

**Trigger**: Called in `initState()` of HomePage - runs when app opens.

**Logic**:
1. Iterate all user's medications
2. For each medication, calculate last scheduled time
3. If last scheduled time was > 2 hours ago AND user hasn't confirmed taking it (`lastTaken` check):
   - Reschedule notification for next occurrence
   - Update `startDate` in Firestore (for everyXDays mode)

**Why 2-hour window?** Allows user to take medication slightly late without immediate reschedule.

### Follow-up Reminder Pattern
**Purpose**: Send multiple reminders at 30-minute intervals after initial notification.

**Implementation** (scheduleMedicationNotification):
```dart
for (int j = 0; j <= 4; j++) {  // 5 total notifications
  final followUpTime = scheduledTime.add(Duration(minutes: 30 * j));
  if (followUpTime.isAfter(now)) {
    final notificationId = ('${docId}_${weekday}_$j').hashCode;
    await flutterLocalNotificationsPlugin.zonedSchedule(
      notificationId,
      medication.name,
      notificationMessage,
      tz.TZDateTime.from(followUpTime, tz.local),
      notificationDetails,
      payload: docId,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }
}
```

**Result**: User receives notifications at:
- T+0 (scheduled time)
- T+30 minutes
- T+60 minutes
- T+90 minutes
- T+120 minutes

**Cancellation**: When user confirms taking medication, all follow-up notifications are cancelled via `cancelMedicationReminders(docId)`.

### Refill Notification Weekly Pattern
**Function**: `scheduleWeeklyRefillNotification()` (line ~4082)

**Trigger**: Scheduled when `medication.amount <= medication.refillThreshold`.

**Schedule**: Every 7 days at 10:00 AM using `matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime`.

**Cancellation**: Cancelled when user refills (amount goes above threshold) or deletes medication.

**Notification appearance**:
- Orange color (0xFFFF9800)
- Separate channel (`'refill_channel'`)
- Shows stock level: "You have X pills left. Time to refill!"

## Code Quality & Linting

### Analysis Options (analysis_options.yaml)
```yaml
include: package:flutter_lints/flutter.yaml
analyzer:
  errors:
    use_build_context_synchronously: ignore  # Disabled due to async/await patterns
```

**Why `use_build_context_synchronously` ignored?**
- App heavily uses async operations before accessing `context` (Firestore queries, dialogs)
- Manually checks `context.mounted` before usage instead
- Consider re-enabling and adding explicit `if (!mounted) return;` checks

### Common Lint Warnings to Watch
- **Prefer const constructors**: Use `const` for immutable widgets (reduces rebuilds)
- **Avoid print() in production**: Wrap with `if (kDebugMode) { print(...); }`
- **Unhandled exceptions**: Always wrap Firestore/Firebase calls in try-catch
- **Missing keys on list items**: Use `Key(doc.id)` for ListView items

## Debugging Tips

### Enable Debug Logs
```dart
import 'package:flutter/foundation.dart' show kDebugMode;

if (kDebugMode) {
  print('Scheduling notification for ${medication.name} at $scheduledTime');
}
```

### Notification Debugging (Android)
```bash
# View scheduled alarms
adb shell dumpsys alarm | grep dawatime

# View notification channels
adb shell cmd notification list

# Force trigger notification (simulate time change)
adb shell su 0 date MMDDHHMMYYYY.SS
```

### Firestore Debugging
```dart
// Enable Firestore logging (main.dart)
FirebaseFirestore.instance.settings = const Settings(
  persistenceEnabled: true,
  cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
);

// Log all Firestore reads/writes
FirebaseFirestore.instance.enableNetwork().then((_) {
  print('Firestore network enabled');
});
```

### Common Error Messages

**"Missing google-services.json"**:
- Download from Firebase Console → Project Settings → Your apps
- Place in `android/app/` directory
- Re-run `flutter pub get`

**"Pod install failed"** (iOS):
```bash
cd ios
rm Podfile.lock
rm -rf Pods
pod install --repo-update
```

**"FlutterLocalNotificationsPlugin not initialized"**:
- Ensure `flutterLocalNotificationsPlugin.initialize()` called in main() before any notification operations
- Check `notificationsInitialized` flag is true

## Performance Optimization

### Firestore Query Optimization
- **Use `.limit(12)`** for medication queries (app has 12-medication cap)
- **Index** not needed (queries are simple collection scans on small datasets)
- **Offline persistence**: Enabled by default, reduces network requests

### Notification Scheduling Optimization
- **Batch cancellations**: Cancel multiple notification IDs in single loop
- **Debounce reschedules**: Don't reschedule on every Firestore update - only on user action
- **Lazy loading**: Don't schedule all notifications on app start - schedule as user navigates

### Image Optimization
- **Launcher icon**: PNG, max 1024x1024px
- **Splash screen**: PNG, max 2048x2048px
- **Notification icons**: Use vector drawable (Android) - stored in `android/app/src/main/res/drawable/`
