# DawaTime (دواء تايم) 💊

[![iOS App Store](https://img.shields.io/badge/App_Store-iOS-blue?logo=apple&logoColor=white)](https://apps.apple.com/app/dawatime/id6748280994)
[![Google Play Store](https://img.shields.io/badge/Google_Play-Android-green?logo=google-play&logoColor=white)](https://play.google.com/store/apps/details?id=com.mrhasak99.dawatime)
[![APK Download](https://img.shields.io/badge/APK-v1.4.6-3DDC84?logo=android&logoColor=white)](https://dawatime.hamadalkhalaf.com/dawatime-v1.4.6.apk)
[![Web App](https://img.shields.io/badge/Web_App-Live-orange?logo=flutter&logoColor=white)](https://webapp.dawatime.hamadalkhalaf.com)
[![Website](https://img.shields.io/badge/Website-dawatime.hamadalkhalaf.com-8AC249?logo=firebase&logoColor=white)](https://dawatime.hamadalkhalaf.com)

**DawaTime** is a production-grade medication reminder application designed for the Kuwait and GCC market. Built with Flutter and Firebase, it focuses on extreme reliability, bilingual accessibility (English/Arabic), and smart scheduling to help users never miss a dose.

> **"Dawa" (دواء)** = Medicine in Arabic &nbsp;•&nbsp; **"Time"** = Never miss it.

---

## ✨ Key Features

- **🌍 Full Bilingual Support** — Native RTL (Right-to-Left) for Arabic and LTR for English, optimized for the GCC region with locale-aware fonts (NotoKufiArabic / Nunito).
- **🔔 Persistent Notifications** — Up to 5 follow-up reminders every 30 minutes (T+0, T+30, T+60, T+90, T+120) until the medication is marked as taken.
- **📅 Flexible Scheduling** — Specific weekdays (e.g., every Monday & Thursday) or interval-based scheduling (every X days).
- **📦 Refill Alerts** — Intelligent stock tracking with customizable thresholds and weekly refill reminders. Orange cards = low stock, red = out of stock.
- **☁️ Cloud Synchronization** — Real-time data sync via Firebase Firestore with secure email/password authentication.
- **🛡️ Security & Privacy** — Play Integrity API (Android), App Attest (iOS), reCAPTCHA v3 (Web), region-based access control (GCC compliance), and a transparent legal document versioning system.
- **🎨 Modern UI** — Clean, accessible design with Light, Dark, and System theme modes.
- **🌐 Web App** — Full CRUD functionality available at [webapp.dawatime.hamadalkhalaf.com](https://webapp.dawatime.hamadalkhalaf.com) without requiring a download.

---

## 📱 Download

| Platform               | Link                                                                             | Status           |
| ---------------------- | -------------------------------------------------------------------------------- | ---------------- |
| iOS App Store          | [Download](https://apps.apple.com/app/dawatime/id6748280994)                     | ✅ Live (v1.4.6) |
| Google Play Store      | [Download](https://play.google.com/store/apps/details?id=com.mrhasak99.dawatime) | ✅ Live (v1.4.6) |
| Android APK (Direct)   | [Download](https://dawatime.hamadalkhalaf.com/dawatime-v1.4.6.apk)               | ✅ Live (v1.4.6) |
| Web App                | [Open](https://webapp.dawatime.hamadalkhalaf.com)                                | ✅ Live          |

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
        ├── Firebase App Check     → Play Integrity API (Android) / App Attest (iOS) / reCAPTCHA v3 (Web)
        ├── Firebase Crashlytics   → Production crash monitoring
        ├── Firebase Analytics     → User behavior tracking
        └── Firebase Hosting       → dawatime.hamadalkhalaf.com + webapp.dawatime.hamadalkhalaf.com
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
│   ├── main.dart                  # App entry, auth gate, splash, update checker, App Check
│   ├── home_page.dart             # Medication list, swipe gestures, reminders
│   ├── add_medications.dart       # Add/edit medication form
│   ├── login_page.dart            # Login, Play Integrity check, legal version checks
│   ├── signup_page.dart           # Registration with T&C/Privacy acceptance, Android 11+ URL fix
│   ├── settings.dart              # Profile, theme, language, refill reminder scheduling, portfolio link
│   ├── utils/
│   │   ├── medication_helpers.dart    # Firestore CRUD, data models
│   │   ├── medication_notifications.dart  # Notification scheduling logic (5 follow-ups)
│   │   └── string_utils.dart          # Localization helpers
│   └── l10n/
│       ├── app_en.arb             # English translations
│       └── app_ar.arb             # Arabic translations
├── functions/
│   └── index.js                   # Cloud Functions (FCM, Play Integrity verification, email, version check)
├── public/                        # Firebase Hosting (marketing site — dawatime.hamadalkhalaf.com)
│   ├── index.html                 # Landing page (bilingual, App Store + Google Play badges, direct APK download)
│   ├── privacy-policy.html        # Privacy Policy (bilingual, Trust Box, FOUC prevention)
│   ├── terms-and-conditions.html  # Terms & Conditions (bilingual, Safety Box, FOUC prevention)
│   ├── support.html               # Support center
│   ├── account-deletion.html      # Account deletion instructions (Google Play requirement)
│   ├── sitemap.xml                # XML sitemap for SEO
│   ├── robots.txt                 # Search engine crawling rules
│   └── shared-toggles.js/css      # Shared theme/language toggle system (IIFE pattern, ~210 lines JS)
├── android/                       # Android-specific configuration (SDK 35, edge-to-edge, keep.xml)
├── ios/                           # iOS-specific configuration (APNs production, dSYM auto-upload)
└── web/                           # Flutter Web App wrapper (SEO, loading screen, PWA)
    ├── index.html                 # PWA entry, loading screen, OG tags, Kuwait SEO
    └── manifest.json              # PWA configuration
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
   - Create the `/AppConfig/Version` document with `version: "1.4.6"`

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

## 📋 Production Timeline

### Version History

| Version | Date         | Highlights                                                                     |
| ------- | ------------ | ------------------------------------------------------------------------------ |
| v1.1.1  | Aug 14, 2025 | First iOS App Store release                                                    |
| v1.2.1  | Aug 28, 2025 | Arabic localization + RTL support                                              |
| v1.2.2  | Aug 31, 2025 | Bug fixes                                                                      |
| v1.3.4  | Oct 28, 2025 | Weekday scheduling + website distribution                                      |
| v1.4.4  | Jan 21, 2026 | Database migration + iOS fixes + Google Play debut                             |
| v1.4.5  | Feb 11, 2026 | Play Integrity API + Safe URL launching + 7 critical fixes                     |
| v1.4.6  | May 14, 2026 | iOS lifecycle simplification + startup timeout safety + "Today" reminder label |

### Key Infrastructure Milestones

| Date         | Milestone                                                                          |
| ------------ | ---------------------------------------------------------------------------------- |
| May 22, 2025 | First git commit — DawaTime rebuild begins                                         |
| Jun 25, 2025 | `dawatime.com` domain purchased (Porkbun), Cloudflare DNS configured               |
| Jul 2, 2025  | Brand identity finalized — `#8AC249` green, logo by Javeria Hareem Shiraz (Upwork) |
| Jul 9, 2025  | Firebase Crashlytics, Analytics, and Performance monitoring integrated             |
| Aug 14, 2025 | **v1.1.1** — First iOS App Store release                                           |
| Oct 22, 2025 | Marketing website live at [dawatime.hamadalkhalaf.com](https://dawatime.hamadalkhalaf.com) |
| Dec 2025     | Major refactoring: Firestore subcollection migration, iOS notification overhaul    |
| Jan 5, 2026  | Google Play Console beta testing begins (Testers Community, 25 initial testers)    |
| Jan 21, 2026 | **v1.4.4** — 🎉 Coordinated dual-platform launch: iOS App Store + Google Play Store  |
| Feb 11, 2026 | **v1.4.5** — Security hardening, 7 critical fixes, 30 professional screenshots     |
| Feb 27, 2026 | Infrastructure consolidation: Netlify → Firebase Hosting; DNS cleanup (Zoho/SendGrid records removed) |
| Mar 12, 2026 | SEO fixes: `robots.txt` + `sitemap.xml` corrected, Search Console issues resolved  |
| May 14, 2026 | **v1.4.6** — iOS lifecycle improvements and "Today" label                          |
| Jul 19, 2026 | Direct APK download (v1.4.6) added to landing page; domain consolidated to `dawatime.hamadalkhalaf.com` |

### Beta Testing (January 7–21, 2026)

The production launch on January 21, 2026 followed a rigorous 15-day beta testing period:

- **25 initial testers** via Testers Community, stabilizing to **12 continuous testers** for 10+ days
- **6 emergency updates** deployed (v42 → v44 → v45 → v46 → v47 → v49 → v50)
- **100% crash-free rate** on final build (v1.4.4+50) across both platforms
- **Key crises resolved** during beta:
  - 5 crash fixes (widget lifecycle, context safety, UI overflow, ProGuard, Firebase Auth)
  - Android 15 edge-to-edge support + SHA certificate configuration
  - Firestore migration data-safety fix (copy-then-delete pattern)
  - iOS notification overhaul (missing scheduling loop, `interruptionLevel.timeSensitive`)
  - Google Search Console duplicate canonical URL issues
  - iOS SafariViewController crash (deferred to v1.4.5)

---

## 🛡️ Security & Reliability

### App Integrity Verification

DawaTime uses Firebase App Check across all platforms to protect the backend from unauthorized access:

| Platform | Provider             | Purpose                                          |
| -------- | -------------------- | ------------------------------------------------ |
| Android  | Play Integrity API   | Verifies app authenticity and device integrity   |
| iOS      | App Attest           | Cryptographic attestation of app integrity       |
| Web      | reCAPTCHA v3         | Protects web app from bot/automated abuse        |

A Cloud Function performs server-side Play Integrity verification on login and app startup. Debug bypasses are stripped from production builds.

### Legal Document Versioning System

The app uses a dual-entry-point legal check to ensure users have accepted the latest Terms & Conditions and Privacy Policy:

- **Entry Point 1** — `login_page.dart`: Checks on every fresh login
- **Entry Point 2** — `main.dart` AuthGate: Checks on app startup for existing sessions
- Version numbers are stored in Firestore (`/AppConfig/LegalDocuments`) and compared against each user's `acceptedTermsVersion` / `acceptedPrivacyVersion`
- If a mismatch is found, a non-dismissible acceptance dialog is shown; declining signs the user out

Updating documents requires no app release — just update the HTML page and increment the version in Firestore.

### Notification Reliability

The 5-follow-up notification system is designed to survive iOS battery management and Android background restrictions:

- **`workmanager`** runs hourly to reschedule any missed notifications
- **`interruptionLevel: timeSensitive`** on iOS 15+ prevents the system from silencing reminders
- **Startup cleanup** (`cancelAll()`) runs on launch to eliminate ghost/duplicate notifications
- **ProGuard `keep.xml`** ensures notification icon drawables survive R8 resource shrinking on Android release builds

### Infrastructure & Hosting

- **Marketing site** (`dawatime.hamadalkhalaf.com`): Firebase Hosting with clean URL rewrites, canonical tags, sitemap, and 301 redirects
- **Flutter web app** (`webapp.dawatime.hamadalkhalaf.com`): Firebase Hosting multi-site target (`webapp`), separate from marketing site to allow independent deployments
- **CDN**: Firebase uses Fastly CDN for both sites
- **Email**: Google Workspace SMTP via Nodemailer (credentials in Firebase Secret Manager, not in source)
- **DNS**: Cloudflare (proxy + Redirect Rules for `www` → root, HTTP → HTTPS handled at CDN layer)

---

## 📈 Growth & Market Validation

### Launch Results (as of May 2026)

- **110+ registered users** in Kuwait (organic growth post-launch)
- **Platforms**: iOS App Store (since August 2025) + Google Play Store (since January 21, 2026)
- **Revenue**: $0 — strategic Phase 1 growth focus before monetization
- **Vision**: Public health tool first, commercial product second

### Instagram Launch Campaign (January 21–27, 2026)

A 7-day paid Instagram campaign targeting Kuwait ran concurrent with the dual-platform launch:

| Metric               | Result                             |
| -------------------- | ---------------------------------- |
| Total spend          | $69.84 (99.8% of $70 budget)       |
| Impressions          | 11,525                             |
| Reach                | 7,198                              |
| Website visits       | 289 ($0.24 per visit)              |
| Downloads            | 61 ($1.14 per download)            |
| New registered users | 10 (98 → 108 total)                |
| CTR                  | 1.24%                              |

**Audience**: 77.9% male, 25–34 age bracket (36.3%), balanced across Kuwait governorates (Hawalli 26.5%, Capital 26.2%).

### Multi-Channel Marketing Strategy

| Channel       | Audience     | Angle                                                         |
| ------------- | ------------ | ------------------------------------------------------------- |
| Instagram     | Consumer     | Local pride (`#MadeInKuwait`), bilingual, paid GCC targeting  |
| LinkedIn      | Professional | Failure→success narrative, technical showcase, builder story  |
| Portfolio     | Evergreen    | Capability-focused, dual-platform availability                |

---

## 📖 The Story: From Failure to Production

DawaTime is a reincarnation of a [failed 2022 Flutter course final project](https://github.com/MrHasak99/UC-final-project-flutter). The original submission — a 2-week CODED UniCODE program final project (December 2022) — passed the course but was critically broken.

### What Went Wrong in 2022

| Problem | Root Cause |
| ------- | ---------- |
| Save functionality crashed on every tap | Uninitialized `nameController` and `pref` variables |
| App crashed on first launch | Force-unwrap on SharedPreferences (null safety violation) |
| Could only store one medication | SharedPreferences used as single key/value store |
| No notifications | Zero notification implementation despite being a reminder app |
| Delete button did nothing | `onPressed: (() {})` — empty handler |
| No user accounts | No Firebase Auth, no cloud backend |
| Data lost on reinstall | Local-only storage, no cloud backup |

The README even acknowledged it: _"Had issues setting up and saving user data... Fix app and implement notifications"_ — but the course was over.

### The Rebuild Journey (May 2025 – Present)

Rather than abandoning the concept, Hamad rebuilt from scratch — **while working full-time at Kuwait's Ministry of Electricity & Water & Renewable Energy (MEW)** — applying every lesson learned:

- **July 2023**: Joined CODED as a Student Mentor for the same Flutter course he had failed 7 months prior
- **August 2024**: Promoted to Teacher Assistant (first paid contract after 13 months of volunteering)
- **October 2024 – January 2025**: Enrolled in CODED Full-Stack Bootcamp (14-week MERN stack)
- **May 22, 2025**: First commit of the DawaTime rebuild
- **August 14, 2025**: v1.1.1 — first production iOS App Store release
- **January 21, 2026**: Coordinated dual-platform launch on both iOS App Store and Google Play Store
- **Timeline**: December 20, 2022 (failed project) → January 21, 2026 (production launch) = **3 years, 1 month**

### Original Project vs. DawaTime Rebuild

| Original Failed Project (2022)            | DawaTime Rebuild (2025–2026)                          |
| ----------------------------------------- | ----------------------------------------------------- |
| ❌ Uninitialized variables → save crashes | ✅ Proper state management, controller initialization |
| ❌ Local-only SharedPreferences           | ✅ Firebase Firestore cloud database                  |
| ❌ Single medication storage (unusable)   | ✅ Subcollection structure, unlimited medications     |
| ❌ No notification system                 | ✅ 5 follow-up reminders every 30 min per medication  |
| ❌ No authentication                      | ✅ Firebase Auth with email verification              |
| ❌ Broken delete button (empty handler)   | ✅ Swipe gestures with confirmation + undo            |
| ❌ Null safety crashes                    | ✅ Proper null checks + mounted checks throughout     |
| ❌ Desktop platform bloat                 | ✅ Focused mobile-only (iOS/Android) + Web            |
| ❌ Generic "medication_app" branding      | ✅ Professional "DawaTime" brand identity (#8AC249)   |
| ❌ No crash monitoring                    | ✅ Firebase Crashlytics + Analytics in production     |
| ❌ 0 users (never worked)                 | ✅ 110+ active users in Kuwait                        |

### Key Learnings

1. **Scope Management** — Start with MVP (medication reminders), add features incrementally
2. **Architecture First** — Professional patterns (Firebase, Firestore rules, notification system) from day one
3. **User Focus** — Real beta testing (25 testers), feedback integration, market validation
4. **Documentation** — Comprehensive project documentation drives consistency across long development cycles
5. **Strategic Planning** — Business model thinking, monetization roadmap, growth milestones
6. **Quality over Speed** — 3-year journey from failure to production vs. rushing incomplete features

---

## 👤 Developer

**Hamad AlKhalaf** — Full-stack developer and full-time employee at Kuwait's Ministry of Electricity & Water & Renewable Energy.

- 🌐 [Portfolio](https://portfolio.hamadalkhalaf.com)
- 💼 [LinkedIn](https://www.linkedin.com/in/hamad-alkhalaf/)
- 📸 [Instagram](https://www.instagram.com/eng.hamad_alkhalaf/)
- 📱 [DawaTime on Instagram](https://www.instagram.com/dawatime.app/)

---

## ⚖️ Legal

All rights reserved © Hamad AlKhalaf.

- [Privacy Policy](https://dawatime.hamadalkhalaf.com/privacy-policy)
- [Terms & Conditions](https://dawatime.hamadalkhalaf.com/terms-and-conditions)
- [Support](https://dawatime.hamadalkhalaf.com/support)

---

_DawaTime — Never miss a dose. 💚_
