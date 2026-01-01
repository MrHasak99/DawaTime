# DawaTime - AI Coding Agent Instructions

## Recent Changes (January 2026)

**Current Version**: v1.4.4+24 (Production Ready)
**Database Structure**: `/Users/{userId}/medications/{medicationId}` (new subcollection structure, default since v1.4.4)
**Migration Status**: Complete - smart bridge auto-cleanup implemented, all database operations updated
**Key Features**: iOS notifications working, FCM push notifications, single permission dialog, version tracking active, legal document check in AuthGate

---

### Legal Document Check in AuthGate (January 1, 2026)
**Status**: ✅ **IMPLEMENTED** - Legal document version check added to AuthGate gatekeeper pattern

**Issue**: Users needed to close and reopen app after login to see legal document update dialog. Dialog was showing after HomePage had already loaded in background.

**Implementation** (main.dart AuthGate):
- Added `_showingLegalDialog` flag to block HomePage rendering while dialog is active
- Legal check happens in FutureBuilder before HomePage navigation
- Dialog shows on loading screen (CircularProgressIndicator), not on top of HomePage
- `_lastCheckedUserId` tracks which user has been checked this session
- FCM token and metadata only update after legal acceptance (or if no update needed)

**Logic Flow**:
1. User logs in → AuthGate StreamBuilder detects authenticated user
2. FutureBuilder calls `_checkLegalDocumentVersions(uid)` to compare versions
3. If update needed: Set `_showingLegalDialog = true` and show dialog via addPostFrameCallback
4. While `_showingLegalDialog = true`: Loading screen stays visible, HomePage blocked
5. User accepts → Update Firestore, set `_lastCheckedUserId = uid`, set `_showingLegalDialog = false`
6. FutureBuilder rebuilds → Condition false → Calls `_saveFCMToken(uid)` → Shows HomePage
7. User declines → Sign out, reset flags

**Files Updated**:
- `/lib/main.dart` (AuthGate):
  - Added `_showingLegalDialog` boolean flag
  - Modified FutureBuilder condition: `(legalSnapshot.data == true && _lastCheckedUserId != user.uid) || _showingLegalDialog`
  - Set `_lastCheckedUserId = uid` after acceptance (not before)
  - Reset both flags on logout
- `/lib/login_page.dart`:
  - Removed unused `_checkLegalDocumentVersions()` method
  - Removed unused `_showLegalUpdateDialog()` method
  - Removed `_updateLoginMetadata()` method and its call - metadata now only updates in AuthGate after legal check
- `/pubspec.yaml` - Version: 1.4.4+23 → 1.4.4+24
- `/android/app/build.gradle.kts` - versionCode: 23 → 24

**Result**: Legal dialog appears immediately after login on loading screen, blocking HomePage access until user accepts or declines. No more background HomePage rendering during legal check.

### 12th Medication Save Navigation Bug Fix (December 30, 2025)
**Status**: ✅ **FIXED** - Replaced FutureBuilder with initState check for medication limit

**Issue**: When saving the 12th medication, the medication was saved successfully but the user remained on the add medication page with "You can only have up to 12 medications" warning displayed.

**Root Cause**: 
- `FutureBuilder` in add_medications.dart continuously rebuilding during async operations
- Navigation (`Navigator.pop()`) completed but FutureBuilder queried Firestore post-navigation
- Notification scheduling triggered widget rebuilds, causing FutureBuilder to re-execute
- Duplicate medication count check in both FutureBuilder and save button handler

**Fix Applied** (add_medications.dart):
- Replaced continuous FutureBuilder pattern with one-time `initState()` check
- Added `_isLoadingCount` and `_isAtLimit` state variables to cache medication count result
- Moved limit check to `_checkMedicationLimit()` method called only once in `initState()`
- Removed duplicate medication count check from save button handler
- Result: Limit check happens once on page load, navigation works correctly after 12th medication save

**Code Cleanup (December 30, 2025)**:
- Removed 28 debug print statements across 4 files (add_medications.dart, main.dart, home_page.dart, medication_notifications.dart)
- Fixed 25+ empty catch blocks: replaced `catch (e) {}` with `catch (_) {}` (Dart idiom for explicit ignore)
- Removed 3 unused variable declarations (apnsToken, token, retryToken) in main.dart
- Removed unused `foundation.dart` imports after debug cleanup
- Incremented build number: 1.4.4+20 → 1.4.4+21

**Files Updated**:
- `/lib/add_medications.dart` - Medication limit check logic refactored
- `/lib/main.dart` - Debug statements removed, empty catch blocks fixed, unused variables removed
- `/lib/home_page.dart` - Empty catch blocks fixed
- `/lib/utils/medication_notifications.dart` - Debug statements removed, empty catch blocks fixed
- `/lib/utils/medication_helpers.dart` - Empty catch blocks fixed
- `/pubspec.yaml` - Version: 1.4.4+20 → 1.4.4+21
- `/android/app/build.gradle.kts` - versionCode: 20 → 21

**Result**: 12th medication saves correctly and navigates back to home page. Codebase cleaned up with 0 analyzer warnings for targeted issues.

### Duplicate FCM Notification Fix (December 30, 2025)
**Status**: ✅ **FIXED** - Removed duplicate notification creation in background handler

**Issue**: Users receiving 2 identical update notifications instead of 1 when app is backgrounded/terminated.

**Root Cause**: 
- Cloud Function sends complete `notification` payload (title + body) which system auto-displays
- Background handler (`_firebaseMessagingBackgroundHandler`) was ALSO creating a local notification
- Result: Two notifications appeared simultaneously

**Fix Applied** (main.dart):
- Removed all local notification creation code from `_firebaseMessagingBackgroundHandler`
- Background handler now just exists as entry point (Firebase requires it), but doesn't create notifications
- System automatically displays notification from Cloud Function's payload when app is backgrounded
- Foreground handler (`onMessage` listener) still creates local notification (required for foreground display)

**Files Updated**:
- `/lib/main.dart` (1422 → 1367 lines, removed 55 lines of duplicate notification code)

**Result**: Only 1 notification appears in all scenarios. Background/terminated app uses system notification, foreground uses local notification.

### SnackBar Persistence Fix (December 30, 2025)
**Status**: ✅ **FIXED** - Added persist: false to all SnackBars with actions

**Issue**: SnackBars with action buttons showing persistent close icon that remains on screen.

**Root Cause**: 
- Recent Flutter update changed default behavior for SnackBars with actions
- SnackBars with `action: SnackBarAction(...)` now show persistent close icon by default
- This prevents the auto-dismiss behavior expected for temporary notifications

**Fix Applied**:
- Added `persist: false` to all 5 SnackBars that have action buttons:
  1. Exact alarm permission prompt (home_page.dart line ~343)
  2. Undo medication deletion (home_page.dart line ~998)
  3. Undo swipe delete (home_page.dart line ~2786)
  4. Undo take medication (home_page.dart line ~3416)
  5. Exact alarm permission in notifications utility (medication_notifications.dart line ~397)

**Files Updated**:
- `/lib/home_page.dart` (4 snackbars fixed)
- `/lib/utils/medication_notifications.dart` (1 snackbar fixed)

**Result**: SnackBars behave as expected - they auto-dismiss without persistent close icons, while action buttons remain functional.

### Database Operations Update (December 29, 2025)
**Status**: ✅ **COMPLETE** - All Firestore operations now use new database structure

**Issue**: After making new structure default, add/edit operations still used old collection paths causing "not-found" errors.

**Fixes Applied**: Updated all direct Firestore operations across the codebase to use new subcollection structure:
- Medication creation (`.add()`)
- Medication editing (`.update()`)
- Medication deletion (`.delete()`)
- Inline edit dialogs
- "Take Medication" button
- Notification tap handlers
- Account deletion cleanup
- Medication count checks (12-limit)

**Files Updated**:
- `/lib/add_medications.dart` (1414 → 1419 lines)
- `/lib/home_page.dart` (3938 → 3938 lines)
- `/lib/settings.dart` (2306 → 2316 lines)

**Result**: All operations (add, edit, delete, query) now consistently use `/Users/{userId}/medications/{medicationId}`. App is fully functional with new database structure.

### Critical iOS Notification Fixes
**Issue**: Users reported no medication reminders on iOS for 2 weeks, only receiving incorrect refill alerts.

**Root Causes Identified**:
1. Missing main scheduling loop for `everyXDays` medications - only within-window notifications were scheduled
2. Missing `interruptionLevel: InterruptionLevel.timeSensitive` on iOS notifications - iOS 15+ was suppressing alerts
3. Stale weekly refill notifications persisting even after medication refilled - iOS doesn't reliably cancel repeating notifications by ID

**Fixes Applied** (medication_notifications.dart, home_page.dart):
- Added while loop in `scheduleMedicationNotification()` to advance scheduled time for future notifications (lines 416-477)
- Added `interruptionLevel: InterruptionLevel.timeSensitive` to all DarwinNotificationDetails configurations
- Implemented startup cleanup in `_scheduleAfterPermissionCheck()` using `cancelAll()` before rescheduling
- Added new `cancelAllRefillNotifications()` function for nuclear cleanup
- Enhanced debug logging throughout notification scheduling/cancellation for troubleshooting

**Files Updated**:
- `/lib/utils/medication_notifications.dart` (504 → 637 lines)
- `/lib/home_page.dart` (3785 → 3856 lines)

**Testing Verification**: Deploy to physical iOS device, add test medication for 2-3 minutes ahead, verify notification fires at exact time with follow-ups.

### Database Migration & Permission Fixes (December 29, 2025)
**Issue**: Multiple issues discovered during v1.4.4 testing and migration deployment.

**Root Causes Identified**:
1. Permission-denied errors when reading AppConfig collection (legal documents, version checks)
2. FCM initialization null check error when checking platform for iOS
3. Duplicate FCM token cleanup causing permission errors with cross-user queries
4. Migration cleanup failing due to Firestore security rules requiring validation on delete
5. Duplicate notification permission dialogs on fresh install (AppDelegate + FCM both requesting)
6. New database structure not defaulting correctly (showing "using old location" logs)

**Fixes Applied**:
- **firestore.rules**: Added `AppConfig` read permission for all authenticated users (needed for legal document version checks)
- **firestore.rules**: Separated `allow delete` from `allow update` to remove validation requirement during migration cleanup
- **main.dart**: Changed iOS platform check from `Theme.of(context).platform` to `Platform.isIOS` (fixes null check error)
- **main.dart**: Removed client-side duplicate FCM token cleanup (now handled by Cloud Function only)
- **main.dart**: Removed redundant permission requests (kept only FCM's `requestPermission()`)
- **AppDelegate.swift**: Removed `requestAuthorization()` call - permission now requested only by Firebase Messaging
- **home_page.dart**: Changed `_useNewStructure` default behavior to use new structure by default (null or true)
- **home_page.dart**: Removed duplicate "Using OLD/NEW location" logging from `_getMedicationsCollection()`
- **functions/index.js**: Added `checkVersionAdoption` Cloud Function for monitoring user version distribution

**Files Updated**:
- `/firestore.rules` (60 → 67 lines) - Added AppConfig read, separated delete from update validation
- `/lib/main.dart` (1423 → 1422 lines) - Fixed iOS platform check, removed duplicate permissions/token cleanup
- `/ios/Runner/AppDelegate.swift` (45 → 31 lines) - Removed duplicate permission request
- `/lib/home_page.dart` (3950 → 3938 lines) - New structure default, cleaner logging
- `/functions/index.js` (567 → 694 lines) - Added version adoption monitoring function

**Testing Verification**: 
- Fresh app install shows only ONE notification permission dialog
- No permission-denied errors in console
- Migration cleanup successfully deletes old data
- Console shows clean logs: "✅ Only new location has data - using new structure"
- Version tracking active via `lastAppVersion` field

### iOS FCM Token Registration Fixes (December 2025)
**Issue**: iPhone not receiving remote update notifications from Cloud Function.

**Root Causes Identified**:
1. iOS requires APNs token to be registered before FCM token can be generated
2. Cloud Function only sent `data` payload - iOS requires `notification` payload for reliable delivery
3. Missing APNs alert configuration in Cloud Function payload
4. No token refresh handling when FCM tokens expire/change
5. No invalid token cleanup causing repeated failures
6. AppDelegate not properly registering for remote notifications

**Fixes Applied**:
- **main.dart**: Added APNs token acquisition before FCM token with retry logic (lines 295-309, 546-591)
- **main.dart**: Added `onTokenRefresh` listener to auto-update Firestore when tokens change (lines 378-392)
- **AppDelegate.swift**: Added proper remote notification registration in `didFinishLaunchingWithOptions`
- **functions/index.js**: Added `notification` payload with title/body for both iOS and Android
- **functions/index.js**: Added complete APNs configuration with alert, sound, badge, and proper headers
- **functions/index.js**: Implemented detailed error logging showing failed token details
- **functions/index.js**: Added automatic invalid token cleanup from Firestore
- Enhanced debug logging for FCM token acquisition and APNs status

**Files Updated**:
- `/lib/main.dart` (1200 → 1423 lines)
- `/ios/Runner/AppDelegate.swift` (13 → 45 lines)
- `/functions/index.js` (145 → 567 lines)

**Testing Verification**: Install on iPhone, check console for "APNs token obtained: true" and "✓ FCM token saved", update Firestore version, verify notification received within 1-2 minutes.

---

## Project Overview
DawaTime is a Flutter medication reminder app with Firebase backend, supporting Arabic/English localization. The app manages medication schedules, local notifications, and refill reminders with background task execution. Target platforms: Android (SDK 24+) and iOS.

## Architecture & Key Components

### Core Files Structure
- **`lib/main.dart`** (1367 lines): App entry point with critical initialization sequence:
  - Firebase initialization with timeout handling
  - Workmanager background task registration (`medicationRescheduleTask` runs hourly)
  - Timezone initialization via `flutter_timezone` (fallback to UTC if fails)
  - Notification plugin setup with `selectNotificationStream` listener
  - Theme/locale persistence via `SharedPreferences`
  - Force update check on app launch (`forceUpdateCheck()` compares Firestore `AppConfig/Version` with local version)
  - **Legal document version check** in splash screen (`_checkLegalDocumentVersions()` compares user's accepted versions with current versions in Firestore)
  - **Legal update dialog** shown when documents are updated (blocks app access until user accepts or logs out, uses `PopScope` and `onPopInvokedWithResult` for back navigation prevention)
  - FCM background message handler (`_firebaseMessagingBackgroundHandler`)
  - **iOS APNs token handling**: Ensures APNs token obtained before FCM token generation (critical for iOS notifications)
  - **FCM token refresh listener**: Auto-updates Firestore when tokens expire/change via `onTokenRefresh`
  - **FCM debug logging**: Console output for token acquisition, APNs status, and save confirmation

- **`lib/home_page.dart`** (3938 lines): Main UI and medication list display:
  - `StreamBuilder<QuerySnapshot>` for real-time Firestore medication updates
  - `Dismissible` widgets for swipe-to-edit (left/right) and swipe-to-delete (end-to-start)
  - Utility functions: `medicationFromDoc()`, `rescheduleAllMedications()`, `initializeNotifications()`
  - Auto-reschedule logic in `_autoRescheduleOverdueMedications()` (runs on app open)
  - **Startup cleanup**: `_scheduleAfterPermissionCheck()` calls `cancelAll()` to clear stale notifications before rescheduling (critical for preventing incorrect refill alerts)
  - **Migration detection**: `_checkMigrationStatus()` auto-detects migration and cleans up old data (lines 140-214)
  - **New structure default**: `_useNewStructure` defaults to true (uses new subcollection structure by default)
  - Notification handling via imports from `lib/utils/medication_notifications.dart`
  - Helper functions via imports from `lib/utils/medication_helpers.dart`
  - **Intro guide**: 6-step onboarding shown on first app launch (stored in `SharedPreferences` as `seenIntroGuide`)

- **`lib/add_medications.dart`** (1419 lines): Medication CRUD operations:
  - Two frequency modes via `FrequencyType` enum: `everyXDays` (interval-based) or `daysOfWeek` (specific weekdays)
  - 12-medication limit enforcement (checked via Firestore query count)
  - Inline edit dialogs within `home_page.dart` use same validation logic
  - Refill threshold field (optional) triggers weekly refill notifications
  - Notification scheduling via imports from `lib/utils/medication_notifications.dart`
  - String utilities via imports from `lib/utils/string_utils.dart`

- **`lib/settings.dart`** (2316 lines): User profile and app configuration:
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
  - **Legal document version fetch on signup**: On signup, the app fetches the current `termsVersion` and `privacyVersion` from Firestore `/AppConfig/LegalDocuments` and sets them for the new user. No hardcoded version numbers in code.
  - **Login page does NOT handle legal check or metadata updates**: Legal document version checking and FCM token/metadata updates are handled by AuthGate (main.dart), not login_page.dart. Login page only handles authentication.

### Shared Utilities (lib/utils/)

**IMPORTANT**: These utilities were extracted from duplicated code across `home_page.dart` and `add_medications.dart` to establish a single source of truth. Approximately 700 lines of duplicate code were eliminated through this refactoring.

- **`lib/utils/string_utils.dart`** (10 lines): String manipulation utilities
  - `convertArabicNumerals()`: Converts Eastern Arabic numerals (٠-٩) to Western (0-9)
  - Critical for parsing numeric input in Arabic locale (prevents `int.parse()` crashes)
  - Used in 27+ call sites across form validation and data parsing
  - Example: `convertArabicNumerals('١٢٣')` returns `'123'`

- **`lib/utils/medication_notifications.dart`** (637 lines): Notification scheduling and permission management
  - `scheduleMedicationNotification()`: Main scheduling function with 5 follow-up reminders (T+0, T+30, T+60, T+90, T+120). **Fixed Dec 2025**: Added missing main scheduling loop for everyXDays medications and iOS `interruptionLevel` parameter
  - `cancelMedicationReminders()`: Comprehensive cancellation of all pending notifications (cancels both weekday-based and basic notification IDs)
  - `scheduleWeeklyRefillNotification()`: Weekly refill reminders at 10:00 AM with debug logging
  - `cancelRefillNotifications()`: Cancel refill notification by docId with confirmation logging
  - `cancelAllRefillNotifications()`: Nuclear cleanup option to cancel ALL pending notifications (used on app startup)
  - `requestExactAlarmPermission()`: Check Android 13+ exact alarm permission status
  - `openExactAlarmSettings()`: Navigate to system settings for alarm permission
  - **Debug logging**: Comprehensive console output for troubleshooting notification scheduling/cancellation
  - Used in 13+ call sites for medication scheduling across add/edit/reschedule operations
  - **Import pattern**: `import 'package:dawatime/utils/medication_notifications.dart';`

- **`lib/utils/medication_helpers.dart`** (233 lines): Medication data processing and display logic
  - `getNextReminder()`: Calculates and formats next reminder time with 2-hour window detection
  - Handles both `daysOfWeek` and `everyXDays` scheduling modes
  - Returns "Time to take medication now!" if within reminder window and not yet taken
  - Returns formatted date/time string (e.g., "January 15, 2025 - 2:30 PM") for future reminders
  - Supports Arabic locale with translated month names and RTL formatting
  - Used in 4 call sites for displaying "Next Reminder" in UI (ListView cards and detail dialogs)
  - **Import pattern**: `import 'package:dawatime/utils/medication_helpers.dart';`

**Refactoring Benefits**:
- Single source of truth for notification logic (eliminates sync bugs)
- Reduced code duplication: ~897 lines eliminated (703 from home_page.dart, 194 from add_medications.dart)
- Improved maintainability: Bug fixes and feature updates only need to happen once
- Cleaner imports: Files only import what they actually use
- Better organization: Utilities separated by function (strings, notifications, helpers)

**Import Dependencies**:
- `medication_notifications.dart` depends on: `home_page.dart` (Medications class), `main.dart` (flutterLocalNotificationsPlugin, navigatorKey), `l10n` (localization)
- `medication_helpers.dart` depends on: `home_page.dart` (Medications class), `main.dart` (navigatorKey), `l10n` (localization)
- `string_utils.dart` has no external dependencies (pure utility function)

**Call Site Verification**:
- `scheduleMedicationNotification()`: 13 call sites (10 in home_page.dart, 2 in add_medications.dart, 1 internal)
- `getNextReminder()`: 4 call sites (all in home_page.dart for UI display)
- `convertArabicNumerals()`: 27+ call sites (8 in home_page.dart, 19 in add_medications.dart)
- `cancelMedicationReminders()`: 3 call sites (2 in home_page.dart, 1 internal)
- `rescheduleAllMedications()`: 2 call sites (1 in home_page.dart, 1 in main.dart)

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
- **`/Users/{uid}`**: User profile data
  - `name`, `email`, `fcmToken`, `preferredLanguage`
  - **`acceptedTermsVersion`**: Version of T&C user accepted (e.g., "1.0"). On signup, this is fetched from `/AppConfig/LegalDocuments`.
  - **`acceptedPrivacyVersion`**: Version of Privacy Policy user accepted (e.g., "1.0"). On signup, this is fetched from `/AppConfig/LegalDocuments`.
  - **`legalAcceptanceDate`**: ISO timestamp of when user accepted legal docs
  - **`lastAppVersion`**: App version user is currently running (e.g., "1.4.4"). Updated on every app launch starting from v1.4.4.
  - **`lastAccessedAt`**: Firestore server timestamp of last app access. Used to track active users and migration progress.
- **`/{userId}/{medicationId}`**: Medication documents (scoped per user)
- **`/AppConfig/Version`**: App version control (triggers Cloud Function on update)
- **`/AppConfig/LegalDocuments`**: Legal document version tracking
  - `termsVersion`: Current Terms & Conditions version (e.g., "1.0")
  - `privacyVersion`: Current Privacy Policy version (e.g., "1.0")
  - `lastUpdated`: ISO date of last legal document update
- **`/ContactMessages/{messageId}`**: Contact form submissions
- **`/Messages/{document}`**: Public read/write (used for support messages)

#### Firestore Security Rules Pattern
**New Structure (Default for v1.4.4+):**
```javascript
match /Users/{userId}/medications/{medicationId} {
  allow list, get: if request.auth != null && request.auth.uid == userId;
  allow delete: if request.auth != null && request.auth.uid == userId;
  allow update: if request.auth != null && request.auth.uid == userId
    && request.resource.data.amount >= 0
    && request.resource.data.dosage > 0
    && request.resource.data.frequency > 0;
  allow create: if request.auth != null && request.auth.uid == userId
    && request.resource.data.amount >= 0
    && request.resource.data.dosage > 0
    && request.resource.data.frequency > 0;
}
```

**Legacy Structure (Backward compatibility for v1.3.4):**
```javascript
match /{userId}/{medicationId} {
  allow list, get: if request.auth != null && request.auth.uid == userId;
  allow delete: if request.auth != null && request.auth.uid == userId;
  allow update: if request.auth != null && request.auth.uid == userId
    && request.resource.data.amount >= 0;
}
```

**AppConfig (Read-only for all authenticated users):**
```javascript
match /AppConfig/{document} {
  allow read: if request.auth != null;
}
```

**Important**: 
- `allow delete` is separate from `allow update` (request.resource.data is null during delete)
- Use `allow list, get` instead of `allow read` for collection queries
- All user data is strictly isolated by authenticated UID

### Notification System Architecture

#### Broadcast StreamController Pattern
**Critical**: All pages that need to handle notification taps must listen to this stream in `initState()`:
```dart
final StreamController<NotificationResponse> selectNotificationStream =
    StreamController<NotificationResponse>.broadcast();
```

**Why broadcast?** Multiple pages (HomePage, AddMedications, Settings) listen simultaneously. When notification is tapped, all listeners receive the event, but only the currently mounted widget should process it (check `context.mounted`).

**Why ALL THREE listeners are REQUIRED:**
- **HomePage listener**: Shows medication details dialog with home page context, handles foreground alerts
- **Settings listener**: Handles notification taps when user is configuring app settings, navigates to home for refills
- **AddMedications listener**: Handles notification taps when user is adding/editing medications, navigates to home for refills

**What breaks without these listeners?**
- User on settings page, taps medication notification → **Nothing happens** (no listener mounted)
- User on add medication page, taps refill notification → **Stuck on page** (can't navigate to see alert)
- Only HomePage listener → **Notifications ignored** when user is on any other page

**User scenarios requiring all listeners:**
1. User editing settings → Medication reminder fires → Taps notification → Should show alert
2. User adding medication → Refill notification fires → Taps notification → Should navigate to home
3. User on home page → Any notification fires → Should show immediate dialog

**DO NOT remove these listeners**—they're part of a well-designed broadcast pattern ensuring notifications work correctly regardless of which page is currently mounted.

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

**Function: `scheduleMedicationNotification()` (lib/utils/medication_notifications.dart)**
- **Cancels previous notifications**: Loops through `docId.hashCode + i` (i=0 to 4) to clear old schedules
- **Two scheduling modes**:
  1. **daysOfWeek mode**: Calculates next occurrence of each selected weekday
  2. **everyXDays mode**: Uses while loop to advance `scheduledTime` by `frequency` days until future date found. **CRITICAL FIX (Dec 2025)**: This main scheduling loop was missing, causing no notifications for future dates on iOS
- **Follow-up reminders**: Schedules 5 notifications at 30-minute intervals (immediate, +30min, +60min, +90min, +120min)
- **2-hour grace period**: If notification time passed today but < 2 hours ago, schedules follow-ups starting now
- **Skip old notifications**: If notification time is more than 2 hours past, skips scheduling entirely (prevents stale notifications when app opened after long period)
- **Uses `androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle`** for reliable delivery even in Doze mode
- **iOS notifications**: All notifications include `interruptionLevel: InterruptionLevel.timeSensitive` for iOS 15+ reliable delivery
- **Notification ID generation**: `('${docId}_${weekday}_$followUpIndex').hashCode` ensures uniqueness
- **Debug logging**: Console output shows scheduling details, notification IDs, and timing for troubleshooting

**Function: `scheduleWeeklyRefillNotification()` (lib/utils/medication_notifications.dart)**
- Schedules weekly recurring notification at 10:00 AM
- Uses `matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime` for weekly repeat
- Separate channel ID `'refill_channel'` with orange color (`0xFFFF9800`)
- Notification ID: `('refill_weekly_$docId').hashCode`
- Includes `interruptionLevel: InterruptionLevel.timeSensitive` for iOS 15+ delivery
- Debug logging shows medication name, current amount, threshold, notification ID, and next fire time

**Function: `cancelMedicationReminders()` (lib/utils/medication_notifications.dart)**
- Cancels notifications with IDs: `('${docId}_$i').hashCode` where i=0 to 8
- Call before rescheduling to prevent duplicate notifications

**Function: `cancelRefillNotifications()` (lib/utils/medication_notifications.dart)**
- Cancels refill notification with ID: `('refill_weekly_$docId').hashCode`
- Includes debug logging showing cancellation confirmation

**Function: `cancelAllRefillNotifications()` (lib/utils/medication_notifications.dart)**
- Nuclear cleanup function that cancels ALL pending notifications via `cancelAll()`
- Used during app startup to prevent stale refill notifications from persisting
- **Why needed**: iOS repeating notifications (via `matchDateTimeComponents`) persist even after cancellation attempts, causing incorrect refill alerts for medications above threshold

#### Startup Notification Cleanup
**Critical Fix (Dec 2025)**: Added comprehensive startup cleanup to prevent "ghost notifications"

**Implementation** (`_scheduleAfterPermissionCheck()` in home_page.dart):
```dart
try {
  await flutterLocalNotificationsPlugin.cancelAll();
  if (kDebugMode) {
    print('✓ Cleared all old notifications');
  }
} catch (e) {
  if (kDebugMode) {
    print('⚠️ Error clearing notifications: $e');
  }
}

// Now reschedule everything fresh
rescheduleAllMedications(userId);
_autoRescheduleOverdueMedications(userId);
_checkRefillReminders(userId);
```

**Why this is critical**:
- Refill notifications use weekly repeating pattern (`matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime`)
- Once scheduled, they fire every week forever at 10 AM
- Even after refilling medication (amount > threshold), old notifications kept firing on iOS
- Cancellation by ID wasn't reliable for iOS repeating notifications
- Solution: Cancel ALL notifications on startup, then reschedule based on current medication data

#### Notification Channels
1. **Medication reminders**: Channel ID = `'medication_channel_$docId'` (per-medication channel)
2. **Refill reminders**: Channel ID = `'refill_channel'` (shared channel, orange color)
3. **App updates**: Channel ID = `'updates'` (green color, high priority)

#### Payload Handling Patterns
**CRITICAL**: All notification listeners must handle refill payloads BEFORE attempting Firestore queries.

**Implementation in home_page.dart, add_medications.dart, and settings.dart**:
```dart
selectNotificationStream.stream.listen((NotificationResponse response) async {
  if (response.payload != null && context.mounted) {
    final payload = response.payload!;
    
    // MUST check refill payloads first
    if (payload == 'refill_multiple' || payload.startsWith('refill_')) {
      // home_page.dart: await _checkAndShowDueMedications();
      // add_medications.dart & settings.dart: Navigator.popUntil((route) => route.isFirst);
      return;
    }
    
    // Then handle medication reminders with Firestore query
    final doc = await FirebaseFirestore.instance.collection(userId).doc(payload).get();
    // ...
  }
});
```

**Payload types**:
- **Medication reminder**: `payload = docId` → Open medication details dialog
- **Refill reminder**: `payload = 'refill_$docId'` or `'refill_multiple'` → Show refill alert or navigate to home
- **Update notification**: `payload = 'update_available'` → Open force update dialog

#### Foreground Alert System
**Purpose**: Automatically show alert dialogs when reminder notifications fire while the app is in the foreground, without requiring user to tap the notification.

**Implementation** (home_page.dart `_checkAndShowDueMedications()`):
- **Timer-based checking**: Runs every 1 second via `Timer.periodic`
- **Checks all 5 follow-up times**: T+0, T+30, T+60, T+90, T+120 minutes
- **Deduplication**: Uses `_shownAlerts` set to prevent duplicate dialogs (stores keys like `${docId}_$followUpIndex`)
- **1-second window**: Triggers if current time is within ±1 second of any reminder time
- **Auto-cleanup**: Removes old alert keys when time moves before the schedule window

**Logic flow**:
```dart
for (int i = 0; i <= 4; i++) {
  final followUpTime = scheduledTime.add(Duration(minutes: 30 * i));
  alertKey = '${doc.id}_$i';
  
  if ((now.difference(followUpTime).inSeconds).abs() <= 1 &&
      !_shownAlerts.contains(alertKey)) {
    shouldShowAlert = true;
    break;
  }
}
```

**Example Timeline - Foreground Detection:**
| Time | Follow-up Index | Action |
|------|----------------|--------|
| 2:00:00 PM | 0 | Timer detects match → Shows dialog "Time to take Medicine A" |
| 2:00:01 PM | 0 | Already in `_shownAlerts` → Skip (prevents duplicate) |
| 2:30:00 PM | 1 | Timer detects T+30 match → Shows dialog "Reminder: Take Medicine A" |
| 3:00:00 PM | 2 | Timer detects T+60 match → Shows dialog (if not confirmed yet) |
| 3:30:00 PM | 3 | Timer detects T+90 match → Shows dialog (if not confirmed yet) |
| 4:00:00 PM | 4 | Timer detects T+120 match → Shows dialog (if not confirmed yet) |

**When User Confirms Taking Medication:**
1. Updates Firestore (`lastTaken` timestamp, reduces `amount`)
2. **Cancels ALL pending notifications** via `cancelMedicationReminders(docId)`
3. Reschedules next occurrence
4. Alert keys remain in `_shownAlerts` until page disposed/refreshed

**Why this approach?**
- **Better UX**: Users actively using the app see immediate alerts instead of having to check notification tray
- **Complements system notifications**: System notifications still fire for background/locked scenarios
- **Handles all follow-ups**: Unlike tap-only handling, this catches all 5 reminder times automatically

**Key considerations**:
- Only works when HomePage is mounted (app in foreground on home screen)
- System notifications still appear in notification tray as backup
- Alert dialogs are non-blocking (user can dismiss and continue using app)

### Firebase Integration Details

#### Cloud Functions (`functions/index.js`)

**`notifyOnVersionUpdate` (line 9-240)**:
- Trigger: Firestore document `AppConfig/Version` onUpdate
- Paginates through `/Users` collection (100 docs per batch)
- Sends FCM messages to all users with `fcmToken`
- Separate messages for Arabic (`language: 'ar'`) and English users
- Batches FCM sends (500 tokens per multicast)
- **iOS-compatible payload**: Includes both `notification` (visible alert) and `data` (custom handling) payloads
- **Complete APNs configuration**: 
  - Alert object with title/body
  - Sound: "default"
  - Badge: 1
  - APNs headers: priority 10, push-type "alert"
  - Content-available: 1 (background updates)
  - Mutable-content: 1 (notification extensions)
- **Android notification config**: Channel ID "updates", priority max, default sound/vibrate
- **Detailed error logging**: Shows failed token prefix, error code, and error message
- **Automatic token cleanup**: Removes invalid/unregistered tokens from Firestore
- Returns success/failure counts and logs cleanup operations

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

**`migrateLegalAcceptanceFields` (HTTPS Callable)**:
- One-time migration function to add legal acceptance fields to existing users
- Requires authentication
- Adds `acceptedTermsVersion`, `acceptedPrivacyVersion`, and `legalAcceptanceDate` to all users
- Processes in batches of 500 users
- Safe to run multiple times (skips already migrated users)

**`migrateLegalAcceptanceFieldsHTTP` (HTTPS Request)**:
- HTTP trigger version of migration function
- Secret key authentication (`?secret=dawatime-migration-2025`)
- Same functionality as callable version but easier to trigger via URL
- Returns JSON with migration results (success/failed/already migrated counts)

#### Firebase Authentication Flow
1. **Signup** (signup_page.dart):
   - Create auth account with `createUserWithEmailAndPassword()`
   - Send verification email via `sendEmailVerification()`
   - Create Firestore document: `/Users/{uid}` with:
    - `name`, `email`, `fcmToken`, `preferredLanguage`
    - **`acceptedTermsVersion`**: fetched from `/AppConfig/LegalDocuments/termsVersion` (no longer hardcoded)
    - **`acceptedPrivacyVersion`**: fetched from `/AppConfig/LegalDocuments/privacyVersion` (no longer hardcoded)
    - **`legalAcceptanceDate`**: ISO timestamp
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

#### FCM Token Handling (iOS & Android)
**Critical iOS Pattern**: iOS requires APNs token registration BEFORE FCM token can be generated.

**FCM Initialization** (main.dart, lines 289-392):
```dart
try {
  final messaging = FirebaseMessaging.instance;
  
  await messaging.requestPermission(alert: true, badge: true, sound: true);
  
  // For iOS: Wait for APNs token before getting FCM token
  if (Theme.of(navigatorKey.currentContext!).platform == TargetPlatform.iOS) {
    try {
      final apnsToken = await messaging.getAPNSToken();
      if (kDebugMode) {
        print('APNs token obtained: ${apnsToken != null}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting APNs token: $e');
      }
    }
  }

  final token = await messaging.getToken();
  if (kDebugMode) {
    print('FCM token: ${token ?? "null"}');
  }

  // Listen for token refresh (tokens can expire)
  messaging.onTokenRefresh.listen((newToken) {
    if (kDebugMode) {
      print('🔄 FCM token refreshed: ${newToken.substring(0, 20)}...');
    }
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      FirebaseFirestore.instance.collection('Users').doc(user.uid).update({
        'fcmToken': newToken,
      });
    }
  });
}
```

**Token Save Function** (`_saveFCMToken()`, lines 546-591):
```dart
Future<void> _saveFCMToken(String uid) async {
  if (kIsWeb) return;
  
  try {
    final messaging = FirebaseMessaging.instance;
    
    // For iOS: Ensure APNs token is registered first
    if (Theme.of(navigatorKey.currentContext!).platform == TargetPlatform.iOS) {
      try {
        final apnsToken = await messaging.getAPNSToken();
        if (apnsToken == null) {
          // Wait and retry
          await Future.delayed(const Duration(seconds: 2));
          final retryToken = await messaging.getAPNSToken();
          if (kDebugMode) {
            print('APNs token retry: ${retryToken != null}');
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print('⚠️ APNs token error: $e');
        }
      }
    }
    
    final token = await messaging.getToken();
    
    if (token != null) {
      // Get current app version for tracking
      final packageInfo = await PackageInfo.fromPlatform();
      final appVersion = packageInfo.version; // e.g., "1.4.4"
      
      await FirebaseFirestore.instance.collection('Users').doc(uid).set({
        'fcmToken': token,
        'preferredLanguage': preferredLang,
        'lastAppVersion': appVersion,
        'lastAccessedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      
      if (kDebugMode) {
        print('✓ FCM token saved for user: $uid');
        print('  App Version: $appVersion');
      }
    } else {
      if (kDebugMode) {
        print('⚠️ FCM token is null - notifications may not work');
      }
    }
  } catch (e) {
    if (kDebugMode) {
      print('❌ Error saving FCM token: $e');
    }
  }
}
```

**Why this pattern is critical**:
- iOS will not generate FCM token if APNs token isn't registered
- Token refresh listener ensures Firestore stays updated when tokens expire
- Retry logic handles timing issues on app startup
- Debug logging helps diagnose token acquisition issues

**Verification**: After login, check console for:
- `APNs token obtained: true` (iOS only)
- `FCM token: <token>`
- `✓ FCM token saved for user: <uid>`

#### Firestore Query Patterns
**New Structure (v1.4.4+ default):**
- **Get all medications**: `FirebaseFirestore.instance.collection('Users').doc(userId).collection('medications').get()`
- **Real-time updates**: `FirebaseFirestore.instance.collection('Users').doc(userId).collection('medications').snapshots()` (used in HomePage via `_getMedicationsCollection()` helper)
- **Single medication**: `FirebaseFirestore.instance.collection('Users').doc(userId).collection('medications').doc(docId).get()`
- **Add medication**: `collection('Users').doc(userId).collection('medications').add({...})`
- **Update medication**: `collection('Users').doc(userId).collection('medications').doc(docId).update({...})`
- **Delete medication**: `collection('Users').doc(userId).collection('medications').doc(docId).delete()` + cancel notifications

**Legacy Structure (v1.3.4 backward compatibility):**
- Still supported via dual security rules during migration period
- App auto-detects which structure to use via `_checkMigrationStatus()`

#### Firebase Hosting Configuration (`firebase.json`)
**WWW Subdomain Redirect**:
```json
"hosting": {
  "public": "public",
  "redirects": [
    {
      "source": "https://www.dawatime.com{,/**}",
      "destination": "https://dawatime.com",
      "type": 301
    }
  ],
  "rewrites": [
    {"source": "/account-deletion", "destination": "/account-deletion.html"},
    {"source": "/user-management", "destination": "/user-management.html"},
    {"source": "/support", "destination": "/support.html"},
    {"source": "/", "destination": "/index.html"}
  ]
}
```

**DNS Configuration** (Cloudflare):
**CRITICAL**: DNS is managed by Cloudflare (nameservers: rick.ns.cloudflare.com), NOT Porkbun.

**WWW Subdomain Setup**:
- Type: CNAME
- Name: `www`
- Target: `medication-cd9b8.web.app` (Firebase Hosting URL)
- Proxy status: **Grey cloud (DNS only)** - MUST be disabled for Firebase SSL provisioning
- TTL: Auto or 300

**Adding Custom Domain in Firebase Hosting Console**:
1. Navigate to: https://console.firebase.google.com/project/medication-cd9b8/hosting
2. Click "Add custom domain" button
3. Enter domain name (e.g., `www.dawatime.com`)
4. Click "Continue"
5. Firebase verifies DNS records automatically (if CNAME is correct)
6. If ownership verification required, add TXT record to Cloudflare as instructed
7. Wait for SSL certificate provisioning (5-60 minutes)
8. Status will change from "Needs Setup" → "Pending" → "Connected"

**Troubleshooting www subdomain**:
1. Verify DNS provider: `dig dawatime.com SOA` (check for cloudflare.com in output)
2. Check CNAME record: `dig @rick.ns.cloudflare.com www.dawatime.com CNAME`
3. Ensure Cloudflare proxy (orange cloud) is DISABLED - Firebase cannot verify with proxy enabled
4. Clear local DNS cache: `sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder`
5. Verify CNAME returns `medication-cd9b8.web.app` (not dawatime.com)
6. Wait for SSL provisioning (5-60 minutes)

## Developer Workflows

### Build & Release Commands

#### Android
```bash
flutter clean && flutter pub get
flutter build apk --release
flutter build appbundle --release
flutter install
flutter run --flavor production
```

**Build command notes:**
- `flutter build apk --release` - Production build for website distribution
- `flutter build appbundle --release` - Google Play Store (AAB format, not currently used)

**Distribution Method**: APK distributed via website (https://dawatime.com) due to Google Play Console restrictions on health-related apps from personal developer accounts.

**Android Build Configuration** (`android/app/build.gradle.kts`):
- Namespace: `com.mrhasak99.dawatime`
- Min SDK: 24 (Android 7.0)
- Target SDK: 34 (Android 14)
- Compile SDK: Uses flutter.compileSdkVersion (likely 34)
- Signing: Release builds auto-signed with `my-release-key.jks` (stored in `android/app/`)
- ProGuard: Enabled with minification (`isMinifyEnabled = true`)
- Core library desugaring: Enabled for Java 8+ API support on older devices

**Output location**: `build/app/outputs/flutter-apk/app-release.apk`

#### iOS
```bash
flutter build ipa
flutter build ios --release
flutter build ios
flutter run
```

**Build command notes:**
- `flutter build ipa` - App Store distribution (creates IPA)
- `flutter build ios --release` - Xcode build (for manual signing/distribution)
- `flutter build ios` - Debug build
- `flutter run` - Run on simulator/device

**Distribution Method**: App Store Connect (standard iOS distribution).

**iOS Configuration** (`ios/Runner/Info.plist`):
- Bundle ID: `com.mrhasak99.dawatime`
- Minimum iOS version: Check `ios/Podfile` for `platform :ios` version
- Permissions required: Notifications, exact alarm scheduling
- Background modes: Remote notifications, background fetch

**iOS AppDelegate Configuration** (`ios/Runner/AppDelegate.swift`):
**Critical for FCM**: AppDelegate must properly register for remote notifications to obtain APNs token.

```swift
import Flutter
import UIKit
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    
    // Set up notification center delegate for foreground notifications
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self
    }
    
    // Register for remote notifications (APNs)
    // Permission request is handled by Firebase Messaging in Flutter code
    application.registerForRemoteNotifications()
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  // Handle APNs token registration
  override func application(_ application: UIApplication,
                            didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    print("✓ APNs device token registered")
  }
  
  override func application(_ application: UIApplication,
                            didFailToRegisterForRemoteNotificationsWithError error: Error) {
    print("❌ Failed to register for remote notifications: \(error)")
  }
}
```

**Why this is critical**:
- iOS requires APNs token before FCM can generate its token
- Without proper registration, `getAPNSToken()` returns null
- FCM token generation fails silently without APNs token
- Update notifications won't be received on iOS devices
- **Permission request MUST be handled by FCM only** - duplicate requests cause two permission dialogs

**Output location**: `build/ios/ipa/dawatime.ipa`

#### Combined Build for Both Platforms
```bash
flutter clean
flutter pub get
flutter build apk --release
flutter build ipa
```

**Build sequence notes:**
- Android APK output: `build/app/outputs/flutter-apk/app-release.apk`
- iOS IPA output: `build/ios/ipa/dawatime.ipa`

### Version Management Checklist

When releasing a new version, update **all three** in sync:

1. **`pubspec.yaml`**: `version: 1.4.4+21` (current development version)
  - Format: `<major>.<minor>.<patch>+<buildNumber>`
  - Example: `1.4.4+21` = version 1.4.4, build 21
  - **Production deployed**: v1.3.4 (App Store)
  - **Development**: v1.4.4+21 (ready for next release)

2. **`android/app/build.gradle.kts`**:
  ```kotlin
  versionCode = 21
  versionName = "1.4.4"
  ```

3. **Firebase Firestore** (manual update):
   - Update `/AppConfig/Version` document field `version: "1.4.4"`
   - This triggers Cloud Function to send FCM notifications to all users
   - **Current production version in Firestore**: "1.3.4"


**Version number incrementation definition (using 1.2.3 as example):**

**1** = Major updates (breaking changes, significant new features)
**2** = Minor updates (backwards-compatible feature additions, improvements)
**3** = Hotfixes/patches (bug fixes, small tweaks)

**Build number increment rules:**
For any release (major, minor, or hotfix), always increment the relevant number and never reset any part of the version. For example:
  - Hotfix/patch release: Increment the third number (e.g., 1.2.3 → 1.2.4)
  - Minor release: Increment the second number (e.g., 1.2.3 → 1.3.3)
  - Major release: Increment the first number (e.g., 1.2.3 → 2.2.3)
  - Do not reset any version segment to zero when incrementing another.

**Build number incrementation for testing:**
- The build number (the number after the +, e.g., 1.2.3+16) can be incremented for internal testing or CI/CD builds, even if the main version number does not change. This allows for distributing test builds without affecting the public versioning scheme.
- **IMPORTANT**: When asked to "increment build number", ONLY increment the number after the + sign (e.g., 1.4.4+17 → 1.4.4+18). Do NOT change the version number itself (1.4.4 stays 1.4.4).
- When asked to "increment version number", increment the appropriate version segment AND RESET the build number to 1 (e.g., 1.4.4+16 → 1.4.5+1 for patch, 1.4.4+16 → 1.5.4+1 for minor, 1.4.4+16 → 2.4.4+1 for major).

**Version Planning for Database Migration:**
- **v1.3.4**: Current production (App Store) - uses old structure `/{userId}/{medicationId}`
- **v1.4.4**: Smart bridge version - **auto-detects migration and cleans up old data**
  - Includes `_checkMigrationStatus()` in home_page.dart initState
  - If both old and new structures exist → Deletes old, uses new
  - If only old exists → Uses old (migration not run yet)
  - If only new exists → Uses new (already migrated)
  - **Result**: Each user auto-cleans their old data on first app open after migration
- **v1.5.4**: Post-migration version - uses new subcollection structure `/ Users/{userId}/medications/{medicationId}`
  - By this point, most old data already cleaned up by v1.4.4 users
- Migration timeline: Run migration → Deploy v1.4.4 → Wait for adoption → Most cleanup happens automatically

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

3. **Generate Dart code** (ALWAYS run after modifying ARB files):
   ```bash
   flutter gen-l10n
   ```
   **Important**: This command MUST be run every time you modify `app_en.arb` or `app_ar.arb` to regenerate the localization classes. While `flutter pub get` and `flutter build` also trigger generation, explicitly running `flutter gen-l10n` ensures immediate feedback on any ARB syntax errors.

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

4. **SnackBars with Actions**: Always set `persist: false` to prevent persistent close icon
   ```dart
   SnackBar(
     backgroundColor: const Color(0xFF8AC249),
     content: Text('Message'),
     persist: false,  // Required for SnackBars with actions
     action: SnackBarAction(
       label: 'Action',
       onPressed: () { /* ... */ },
     ),
   )
   ```
   **Why?** Recent Flutter updates changed SnackBars with actions to show persistent close icons by default, preventing auto-dismiss behavior.

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

### App Guides / Onboarding

The app includes **two separate guide implementations** for different user contexts:

#### 1. Splash Screen Quick Guide (main.dart)
**Purpose**: Quick reference guide button available on splash screen, always accessible.

**Location**: Button on splash screen (`SplashScreen` widget)

**Format**: Single-dialog with bullet-point overview

**Content** (localized in `app_en.arb`/`app_ar.arb`):
- Add medications using the "+" button
- Set reminders — you'll get up to 5 notifications every 30 minutes
- Tap a medication to view details
- Swipe left to delete or right to edit
- Set refill thresholds for low stock alerts (orange/red cards)
- Check upcoming reminders on home screen
- Manage profile and settings from top right
- Notification behavior note at bottom

**Implementation** (navigation guard pattern):
```dart
class _SplashScreenState extends State<SplashScreen> {
  bool _isShowingGuide = false;
  
  Future<void> _checkUpdateAndNavigate() async {
    // ... update checks ...
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted || _isShowingGuide) {  // Guard against premature navigation
      return;
    }
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const AuthGate())
    );
  }
  
  Future<void> _showIntroGuide() async {
    setState(() => _isShowingGuide = true);
    await showDialog(/* guide dialog */);
    // Navigate only after user closes dialog
    if (mounted) {
      setState(() => _isShowingGuide = false);
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const AuthGate())
      );
    }
  }
}
```

**Why this pattern?** Prevents automatic splash screen navigation from interrupting the guide dialog. The `_isShowingGuide` flag ensures users can read the guide at their own pace without being prematurely navigated to login/home.

**Accessibility**: Always available to users on splash screen, never dismissed permanently.

#### 2. Home Page Intro Guide (home_page.dart)
**Purpose**: 6-step interactive tutorial shown automatically to first-time users, comprehensive onboarding.

**Trigger**: Automatically displayed on first app launch when `SharedPreferences` key `seenIntroGuide` is `false` or not set.

**Implementation**:
- `_checkIntroGuide()` called in `initState()` checks if user has seen guide
- `_introSteps` getter returns list of 6 steps with localized titles and bodies
- Modal dialog with pagination controls (Back/Next buttons)
- Step counter shows progress (e.g., "1/6", "2/6")
- "Continue" button on final step dismisses guide and sets `seenIntroGuide = true`

**Step Structure**:
```dart
List<Map<String, String>> get _introSteps {
  final loc = AppLocalizations.of(context)!;
  return [
    {'title': loc.welcomeToDawaTime, 'body': loc.welcomeBody},
    {'title': loc.addMedicationTitle, 'body': loc.addMedicationBody},
    {'title': loc.editDeleteTitle, 'body': loc.editDeleteBody},
    {'title': loc.notifications, 'body': loc.notificationsBody},
    {'title': loc.stockRefillTitle, 'body': loc.stockRefillBody},
    {'title': loc.profileAndSettings, 'body': loc.profileAndSettingsBody},
  ];
}
```

**Current Steps**:
1. **Welcome to DawaTime**: "DawaTime helps you manage your medications and reminders with ease."
2. **Add Medications**: "Tap the '+' button to add a new medication and set up reminders."
3. **Edit & Delete**: "Swipe right to edit or left to delete a medication from your list."
4. **Notifications**: "You'll receive up to 5 reminder notifications every 30 minutes. Tap to confirm when taken!"
5. **Stock & Refill Alerts**: "Set a refill threshold to get weekly alerts when medication is running low. Orange cards = low stock, red = out of stock."
6. **Profile & Settings**: "Manage your profile and app settings from the top right corner."

**Localization**: All content for both guides defined in `app_en.arb` and `app_ar.arb` for full Arabic/English support.

**Manual re-trigger**: "App Guide" button available on login page and splash screen for returning users who want to review the tutorial.

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
  stream: _getMedicationsCollection(userId).snapshots(),
  // Or explicitly: FirebaseFirestore.instance
  //   .collection('Users')
  //   .doc(userId)
  //   .collection('medications')
  //   .snapshots(),
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

### iOS Notification Delivery Issues (Fixed Dec 2025)

**Problem 1: Medication Reminders Not Firing on iOS**
- **Root cause**: Missing main scheduling loop for `everyXDays` medications (lines 416-477 in medication_notifications.dart)
- **Symptom**: Only medications within 2-hour window got notifications; future reminders never scheduled
- **Fix**: Added while loop that advances `scheduledTime` by `medication.frequency` days until future date found

**Problem 2: iOS 15+ Notifications Suppressed**
- **Root cause**: Missing `interruptionLevel: InterruptionLevel.timeSensitive` parameter in `DarwinNotificationDetails`
- **Symptom**: Time-sensitive medication reminders delayed or grouped by iOS
- **Fix**: Added `interruptionLevel` to all iOS notification configurations (3 locations in medication_notifications.dart)

**Problem 3: Incorrect Refill Alerts on iOS**
- **Root cause**: Weekly repeating notifications persisted even after medication refilled (amount > threshold)
- **Symptom**: Users receiving refill alerts for medications with adequate stock
- **Technical issue**: iOS doesn't reliably cancel repeating notifications by ID; old schedules survived app restarts
- **Fix**: Added startup cleanup (`cancelAll()`) in `_scheduleAfterPermissionCheck()` before rescheduling

**Testing these fixes**:
```bash
flutter clean
flutter pub get
cd ios && rm -rf Pods Podfile.lock && pod repo update && pod install && cd ..
flutter build ios --release
flutter run --release
```

**Verification Steps**:
1. **Test medication reminders**: Add medication scheduled 2-3 minutes ahead, lock device, verify notification fires at exact time
2. **Check debug console**: Look for `✓ Cleared all old notifications` on app startup
3. **Verify refill logic**: Ensure medications ABOVE threshold don't trigger refill alerts
4. **Test follow-ups**: If medication not confirmed, verify T+30, T+60, T+90, T+120 notifications fire

### Async Function Return Types

**Problem**: Using `void` return type for async functions causes compilation errors when awaited.

**Solution**: Always use `Future<void>` for async functions:
```dart
// ❌ WRONG - causes "Uses 'await' on an instance of 'void'" error
void _checkAndShowDueMedications() async {
  await someAsyncOperation();
}

// ✅ CORRECT
Future<void> _checkAndShowDueMedications() async {
  await someAsyncOperation();
}
```

**Where this matters**: Any async function that is awaited elsewhere in the codebase must return `Future<void>` or `Future<T>`.

### Arabic Numeral Handling

**Problem**: Arabic locale inputs use Eastern Arabic numerals (٠١٢٣٤٥٦٧٨٩) which crash `int.parse()` and `double.parse()`.

**Solution**: Use the shared utility function from `lib/utils/string_utils.dart`:
```dart
import 'package:dawatime/utils/string_utils.dart';

// Usage in forms:
final dosage = double.tryParse(convertArabicNumerals(dosageController.text)) ?? 0;
final frequency = int.tryParse(convertArabicNumerals(frequencyController.text)) ?? 1;
```

**Function implementation** (lib/utils/string_utils.dart):
```dart
String convertArabicNumerals(String input) {
  const arabicNums = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
  for (int i = 0; i < arabicNums.length; i++) {
    input = input.replaceAll(arabicNums[i], i.toString());
  }
  return input;
}
```

**Where to use**: All numeric TextField inputs (dosage, frequency, amount, refillThreshold).

**Call sites**: 27+ locations across home_page.dart (8) and add_medications.dart (19).

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
  
  // CRITICAL: Check refill payloads FIRST before Firestore queries
  if (payload == 'refill_multiple' || payload.startsWith('refill_')) {
    // home_page.dart: await _checkAndShowDueMedications();
    // add_medications.dart & settings.dart: Navigator.popUntil((route) => route.isFirst);
    return;
  }
  
  if (payload == 'update_available') {
    await showForceUpdateDialog(context);
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

### Medication Reminders Persisting After Confirmation (Mid-Schedule Bug)

**Problem**: When a user confirmed taking medication mid-schedule (e.g., at T+30 min), follow-up notifications (T+60, T+90, T+120) would still fire because only the initial notification was cancelled, not the entire sequence.

**Root Cause**: The follow-up reminder pattern schedules 5 notifications with different IDs:
- `('${docId}_${weekday}_0').hashCode` - Initial notification
- `('${docId}_${weekday}_1').hashCode` - T+30 min
- `('${docId}_${weekday}_2').hashCode` - T+60 min
- `('${docId}_${weekday}_3').hashCode` - T+90 min
- `('${docId}_${weekday}_4').hashCode` - T+120 min

**Solution**: Comprehensive cancellation in `cancelMedicationReminders()` function (lib/utils/medication_notifications.dart):
```dart
Future<void> cancelMedicationReminders(String docId) async {
  // Cancel basic notification IDs (legacy/fallback)
  for (int i = 0; i <= 8; i++) {
    final notificationId = ('${docId}_$i').hashCode;
    await flutterLocalNotificationsPlugin.cancel(notificationId);
  }
  
  // Cancel ALL weekday-based follow-up notifications
  for (int weekday = 1; weekday <= 7; weekday++) {
    for (int j = 0; j <= 4; j++) {
      final notificationId = ('${docId}_${weekday}_$j').hashCode;
      await flutterLocalNotificationsPlugin.cancel(notificationId);
    }
  }
}
```

**Confirmation Flow** (home_page.dart "Take Medication" button):
1. User taps "Take Medication" button (can be at any time: T+0, T+15, T+45, etc.)
2. Firestore updated with `lastTaken` timestamp and reduced `amount`
3. **All pending notifications cancelled** via `cancelMedicationReminders(docId)` (cancels ALL 5 follow-ups)
4. Fresh medication document fetched from Firestore
5. **New notifications scheduled for next occurrence** via `scheduleMedicationNotification()`

**Example Timeline - Early Confirmation:**
| Time | Event |
|------|-------|
| 2:00 PM | System notification fires (T+0) → User sees notification |
| 2:15 PM | **User confirms "Take Medication"** (before T+30) |
| 2:15 PM | `cancelMedicationReminders()` cancels T+30, T+60, T+90, T+120 notifications |
| 2:30 PM | ❌ **No notification** (cancelled) |
| 3:00 PM | ❌ **No notification** (cancelled) |
| 3:30 PM | ❌ **No notification** (cancelled) |
| 4:00 PM | ❌ **No notification** (cancelled) |
| **Next day 2:00 PM** | ✅ **Fresh notifications scheduled** for next medication time |

**Why This Works**: By iterating through all possible weekdays (1-7) and all follow-up indices (0-4), we ensure that every single pending notification for this medication is cancelled, regardless of which weekday or follow-up stage it's in. This prevents any stale notifications from the current schedule from persisting after confirmation.

**Important**: This is **intentional behavior** to prevent annoying users with reminders for medication they've already confirmed taking.

**Testing**: To verify the fix, schedule a medication for 2 minutes ahead, wait for the first notification, tap it and confirm taking the medication. Verify that no follow-up notifications (T+30, T+60, etc.) fire afterward.

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

### Permission Flow (Android & iOS)

#### Notification Permission
**Handled by Firebase Cloud Messaging** - single request for both platforms:

```dart
// In main.dart initialization (line ~296)
final messaging = FirebaseMessaging.instance;
await messaging.requestPermission(alert: true, badge: true, sound: true);

// This single call handles:
// - iOS notification permission
// - Android 13+ notification permission
// - Local notifications
// - Remote push notifications
```

**Important**: Do NOT request permissions separately via:
- ~~`permission_handler` package~~ (causes duplicate dialogs)
- ~~iOS `UNUserNotificationCenter.requestAuthorization()`~~ (causes duplicate dialogs)
- ~~Local notification plugin's `requestPermissions()`~~ (redundant)

Only `FirebaseMessaging.instance.requestPermission()` should be used.

#### Exact Alarm Permission (Android 13+)
**Critical difference**: Cannot be requested programmatically - must open system settings.

**Permission check and settings functions** are in `lib/utils/medication_notifications.dart`:
- `requestExactAlarmPermission()` - Check Android 13+ exact alarm permission status
- `openExactAlarmSettings()` - Navigate to system settings for alarm permission

```dart
// Check status (from medication_notifications.dart)
final status = await Permission.scheduleExactAlarm.status;

// If not granted, show SnackBar with action
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    backgroundColor: const Color(0xFF8AC249),
    content: Text(AppLocalizations.of(context)!.allowSettings),
    persist: false,  // Prevent persistent close icon
    action: SnackBarAction(
      label: AppLocalizations.of(context)!.openSettings,
      onPressed: openExactAlarmSettings,
    ),
  ),
);

// Open system settings (from medication_notifications.dart)
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
4. System automatically displays notification from Cloud Function's `notification` payload
5. User taps notification → `onMessageOpenedApp` or `getInitialMessage` handlers trigger
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
  // No need to create a local notification here - the Cloud Function sends a
  // complete 'notification' payload that is automatically displayed by the system.
  // The onMessageOpenedApp and getInitialMessage handlers will handle user taps.
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
**Function**: `_autoRescheduleOverdueMedications()` (home_page.dart line ~317)

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
**Function**: `scheduleWeeklyRefillNotification()` (lib/utils/medication_notifications.dart)

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

### Notification Debug Output (December 2025)
The app now includes comprehensive debug logging for notification operations:

**Startup Cleanup** (home_page.dart `_scheduleAfterPermissionCheck()`):
```
✓ Cleared all old notifications
```

**Refill Checking** (home_page.dart `_checkRefillReminders()`):
```
📊 Checking refill reminders for 3 medications...
  • Aspirin: 50.0 / 10.0
    → Stock OK: Cancelled refill notification
  • Vitamin D: 5.0 / 10.0
    → LOW STOCK: Scheduled refill notification
```

**Notification Scheduling** (medication_notifications.dart):
```
DEBUG: scheduleMedicationNotification called for Medicine A (docId: abc123)
Scheduling Medicine A for 2025-12-28 14:00:00 (in 2 hours)
✓ Scheduled notification #123456 for Medicine A at 2025-12-28 14:00:00
✓ Scheduled notification #123457 for Medicine A at 2025-12-28 14:30:00
```

**Refill Notification Scheduling**:
```
✓ Scheduled weekly refill notification for Medicine B
  - Current amount: 5.0
  - Refill threshold: 10.0
  - Notification ID: 789012
  - Next fire time: 2025-12-29 10:00:00
```

**Cancellation Logging**:
```
✓ Cancelled refill notification for abc123 (ID: 789012)
✓ Cancelled all pending notifications for cleanup
```

These logs appear in the console when running `flutter run` with a debug build.

### Notification Debugging (Android)
```bash
# View scheduled alarms
adb shell dumpsys alarm | grep dawatime

# View notification channels
adb shell cmd notification list

# Force trigger notification (simulate time change)
adb shell su 0 date MMDDHHMMYYYY.SS
```

### iOS / Wireless Device Troubleshooting

- **Symptoms:** Device visible to `flutter devices` but not appearing in VS Code device picker.
- **Quick checks:**
  - Both Mac and iPhone on the same Wi‑Fi network (no VPN).
  - iPhone trusts this Mac: Settings → General → VPN & Device Management → verify trust.
  - Connect iPhone once via USB, open Xcode → Window → Devices and Simulators → enable "Connect via network".
- **Commands to run:**
```bash
# Show connected devices
flutter devices

# Restart Flutter daemon to refresh devices
killall -9 dart

# Diagnose environment
flutter doctor -v
```
- **VS Code steps:** `Cmd+Shift+P` → `Flutter: Select Device` (or Reload Window).
- **If still missing:** open Xcode, toggle "Connect via network" off then on for the device and reconnect via USB once.
- **Notes:** Wireless iOS requires Xcode pairing; ensure iOS and Xcode versions are compatible and the device has a trusted pairing certificate.

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
