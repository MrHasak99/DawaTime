# DawaTime (دواء تايم) 💊

[![iOS App Store](https://img.shields.io/badge/App_Store-iOS-blue?logo=apple&logoColor=white)](https://apps.apple.com/app/dawatime/id6748280994)
[![Google Play Store](https://img.shields.io/badge/Google_Play-Android-green?logo=google-play&logoColor=white)](https://play.google.com/store/apps/details?id=com.mrhasak99.dawatime)
[![Web App](https://img.shields.io/badge/Web_App-Live-orange?logo=flutter&logoColor=white)](https://webapp.dawatime.com)
[![Website](https://img.shields.io/badge/Website-dawatime.com-8AC249?logo=firebase&logoColor=white)](https://dawatime.com)

**DawaTime** is a production-grade medication reminder application designed for the Kuwait and GCC market. Built with Flutter and Firebase, it focuses on extreme reliability, bilingual accessibility (English/Arabic), and smart scheduling to help users never miss a dose.

> **"Dawa" (دواء)** = Medicine in Arabic &nbsp;•&nbsp; **"Time"** = Never miss it.

---

## ✨ Key Features

- **🌍 Full Bilingual Support** — Native RTL (Right-to-Left) for Arabic and LTR for English, optimized for the GCC region with locale-aware fonts (NotoKufiArabic / Nunito).
- **🔔 Persistent Notifications** — Up to 5 follow-up reminders every 30 minutes (T+0, T+30, T+60, T+90, T+120) until the medication is marked as taken.
- **📅 Flexible Scheduling** — Specific weekdays (e.g., every Monday & Thursday) or interval-based scheduling (every X days).
- **📦 Refill Alerts** — Intelligent stock tracking with customizable thresholds and weekly refill reminders. Orange cards = low stock, red = out of stock.
- **☁️ Cloud Synchronization** — Real-time data sync via Firebase Firestore with secure email/password authentication.
- **🛡️ Security & Privacy** — Play Integrity API (Android), region-based access control (GCC compliance), and a transparent legal document versioning system.
- **🎨 Modern UI** — Clean, accessible design with Light, Dark, and System theme modes.
- **🌐 Web App** — Full CRUD functionality available at [webapp.dawatime.com](https://webapp.dawatime.com) without requiring a download.

---

## 📱 Download

| Platform          | Link                                                                             | Status           |
| ----------------- | -------------------------------------------------------------------------------- | ---------------- |
| iOS App Store     | [Download](https://apps.apple.com/app/dawatime/id6748280994)                     | ✅ Live (v1.4.5) |
| Google Play Store | [Download](https://play.google.com/store/apps/details?id=com.mrhasak99.dawatime) | ✅ Live (v1.4.5) |
| Web App           | [Open](https://webapp.dawatime.com)                                              | ✅ Live          |

---

## 🏗️ Architecture Overview

DawaTime uses a modern serverless architecture for scalability and reliability.

```
Flutter App (iOS / Android / Web)
        │
        ├── Firebase Auth          → Email/password authentication + verification
        ├── Cloud Firestore        → /Users/{uid}/medications/{medicationId}
        ├── Cloud Functions        → Version notifications, Play Integrity, email
        ├── Firebase Messaging     → Push notifications (FCM)
        ├── Firebase App Check     → Play Integrity API (Android) / reCAPTCHA (Web)
        ├── Firebase Crashlytics   → Production crash monitoring
        ├── Firebase Analytics     → User behavior tracking
        └── Firebase Hosting       → dawatime.com + webapp.dawatime.com
```

---

## 🛠️ Technology Stack

| Layer                   | Technology                                     |
| ----------------------- | ---------------------------------------------- |
| **Mobile Framework**    | Flutter (Dart)                                 |
| **Authentication**      | Firebase Auth (email/password + verification)  |
| **Database**            | Cloud Firestore (subcollection structure)      |
| **Cloud Logic**         | Firebase Cloud Functions (Node.js)             |
| **Push Notifications**  | Firebase Cloud Messaging (FCM)                 |
| **Local Notifications** | `flutter_local_notifications`                  |
| **Background Tasks**    | `workmanager` (hourly medication rescheduling) |
| **Observability**       | Firebase Crashlytics, Analytics, Performance   |
| **Hosting**             | Firebase Hosting (multi-site: main + webapp)   |
| **Security**            | Firebase App Check + Play Integrity API        |
| **Localization**        | Flutter ARB files (English + Arabic)           |

---

## 📂 Project Structure

```
dawatime/
├── lib/
│   ├── main.dart                  # App entry, auth gate, splash, update checker
│   ├── home_page.dart             # Medication list, swipe gestures, reminders
│   ├── add_medications.dart       # Add/edit medication form
│   ├── login_page.dart            # Login, legal version checks
│   ├── signup_page.dart           # Registration with T&C/Privacy acceptance
│   ├── settings.dart              # Profile, theme, language, account management
│   ├── utils/
│   │   ├── medication_helpers.dart    # Firestore CRUD, data models
│   │   ├── medication_notifications.dart  # Notification scheduling logic
│   │   └── string_utils.dart          # Localization helpers
│   └── l10n/
│       ├── app_en.arb             # English translations
│       └── app_ar.arb             # Arabic translations
├── functions/
│   └── index.js                   # Cloud Functions (FCM, Play Integrity, email)
├── public/                        # Firebase Hosting (marketing site)
│   ├── index.html                 # Landing page
│   ├── privacy-policy.html        # Privacy Policy (bilingual)
│   ├── terms-and-conditions.html  # Terms & Conditions (bilingual)
│   ├── support.html               # Support center
│   └── shared-toggles.js/css      # Shared theme/language toggle system
├── android/                       # Android-specific configuration
├── ios/                           # iOS-specific configuration
└── web/                           # Flutter Web App wrapper
```

---

## 🚀 Getting Started (for Developers)

### Prerequisites

- Flutter SDK `^3.7.2`
- Firebase CLI (`npm install -g firebase-tools`)
- CocoaPods (for iOS: `sudo gem install cocoapods`)
- Node.js 18+ (for Cloud Functions)

### Installation

1. **Clone the repository**:

   ```bash
   git clone https://github.com/MrHasak99/dawatime.git
   cd dawatime
   ```

2. **Install Flutter dependencies**:

   ```bash
   flutter pub get
   ```

3. **Configure Firebase**:
   - Create a new Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
   - Add iOS, Android, and Web apps to the project
   - Download and place `google-services.json` in `android/app/`
   - Download and place `GoogleService-Info.plist` in `ios/Runner/`
   - Run `flutterfire configure` to generate `lib/firebase_options.dart`

4. **Set up Firestore**:
   - Deploy Firestore rules: `firebase deploy --only firestore:rules`
   - Create the `/AppConfig/LegalDocuments` document with `termsVersion: "1.0"` and `privacyVersion: "1.0"`
   - Create the `/AppConfig/Version` document with `version: "1.4.5"`

5. **Deploy Cloud Functions**:

   ```bash
   cd functions
   npm install
   firebase deploy --only functions
   ```

6. **Run the app**:
   ```bash
   flutter run
   ```

---

## 📋 Version History

| Version | Date         | Highlights                                                 |
| ------- | ------------ | ---------------------------------------------------------- |
| v1.1.1  | Aug 14, 2025 | First iOS App Store release                                |
| v1.2.1  | Aug 28, 2025 | Arabic localization + RTL support                          |
| v1.2.2  | Aug 31, 2025 | Bug fixes                                                  |
| v1.3.4  | Oct 28, 2025 | Weekday scheduling + website distribution                  |
| v1.4.4  | Jan 21, 2026 | Database migration + iOS fixes + Google Play debut         |
| v1.4.5  | Feb 11, 2026 | Play Integrity API + Safe URL launching + 7 critical fixes |

---

## 📖 The Story: From Failure to Production

DawaTime is a reincarnation of a [failed 2022 Flutter course final project](https://github.com/MrHasak99/UC-final-project-flutter). The original submission had broken save functionality, no notifications, and local-only storage. Rather than abandoning the concept, Hamad rebuilt it from scratch — while working full-time at Kuwait's Ministry of Electricity & Water — and went on to teach the same Flutter course he had once failed.

| Original Failed Project (2022)       | DawaTime Rebuild (2025–2026)              |
| ------------------------------------ | ----------------------------------------- |
| ❌ Uninitialized variables → crashes | ✅ Proper state management                |
| ❌ Local-only SharedPreferences      | ✅ Firebase Firestore cloud database      |
| ❌ Single medication storage         | ✅ Unlimited medications (subcollections) |
| ❌ No notification system            | ✅ 5 follow-up reminders per medication   |
| ❌ No authentication                 | ✅ Firebase Auth with email verification  |
| ❌ Broken delete button              | ✅ Swipe gestures with undo               |
| ❌ 0 users (never worked)            | ✅ 110+ active users in Kuwait            |

---

## 👤 Developer

**Hamad AlKhalaf** — Full-stack developer and full-time employee at Kuwait's Ministry of Electricity & Water.

- 🌐 [Portfolio](https://hamadalkhalaf.com)
- 💼 [LinkedIn](https://www.linkedin.com/in/hamad-alkhalaf/)
- 📸 [Instagram](https://www.instagram.com/eng.hamad_alkhalaf/)
- 📱 [DawaTime on Instagram](https://www.instagram.com/dawatime.app/)

---

## ⚖️ Legal

All rights reserved © Hamad AlKhalaf.

- [Privacy Policy](https://dawatime.com/privacy-policy)
- [Terms & Conditions](https://dawatime.com/terms-and-conditions)
- [Support](https://dawatime.com/support)

---

_DawaTime — Never miss a dose. 💚_
