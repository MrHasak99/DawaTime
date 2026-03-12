# DawaTime - AI Coding Agent Instructions

## Project Genesis

**Origin Story**: DawaTime is a reincarnation of a failed final project from a Flutter course program. Rather than abandoning the concept after the initial failure, the developer (Hamad AlKhalaf) chose to rebuild from scratch, applying lessons learned and professional development practices.

**Original Failed Project**:

- **Repository**: https://github.com/MrHasak99/UC-final-project-2 (uploaded December 20, 2022)
- **Context**: CODED UniCODE Flutter course final project (2-week program, December 2022)
- **Outcome**: Passed the course, but submitted broken/incomplete project at last possible minute
- **Key Issues**: Rushed submission with critical bugs (save functionality broken, null safety crashes), acknowledged as personal failure despite passing grade

**Professional Background**:

- **January 12, 2023 - Present**: Full-time employee at Kuwait's Ministry of Electricity & Water & Renewable Energy (MEW)
- **Context**: All teaching, learning, and development work (CODED, bootcamp, DawaTime) accomplished while maintaining full-time government employment
- **Time Management**: Demonstrates ability to balance professional career with continuous learning and side projects
- **Business Registration Constraint**: As Kuwait government employee, cannot register commercial business (impacts monetization strategy and Google Play privacy options)

**From Failed Student to Instructor** (July 2023 - Present):

- **July 2023**: Joined CODED as Student Mentor for Kuwait Codes and UniCODE programs (volunteer role, 6 months after starting MEW)
- **August 2024**: Promoted to Teacher Assistant (TA) - first paid contract position after 13 months of volunteering
- **CODED Education Structure**:
  - Student Mentor (volunteer) → Teacher Assistant (paid contract) → Instructor (paid contract)
  - Progression demonstrates proven value and institutional recognition
- **Teaching Role**: Supporting the same UniCODE Flutter course he had taken (and personally failed) 7 months prior
- **Growth Journey**: Despite submitting broken final project as student, mastered Flutter well enough to teach others
- **Perspective Shift**: Teaching experience reinforced understanding of proper software architecture and development practices

**The Rebuild Journey** (May 2025 - Present):

- **October 2024 - January 2025**: Enrolled in CODED Full-Stack Bootcamp (14-week MERN stack program: MongoDB, Express, React, Node.js)
- **January 23, 2025**: Completed Full-Stack Bootcamp
- **Late January - May 2025**: Programming break (~4 months)
- **May 22, 2025**: Started DawaTime rebuild (first git commit), applying lessons learned from failed project
- **May-July 2025**: Core functionality implementation (CRUD, notifications, Firebase integration)
- **August 2025**: First production release (iOS App Store v1.1.1)
- **August-October 2025**: Feature releases (v1.2.1 Arabic, v1.2.2 bug fixes, v1.3.4 weekday scheduling)
- **October 2025**: Android website distribution begins, iOS v1.3.4 current production
- **December 2025**: Major refactoring (database migration, iOS notification fixes)
- **January 2026**: Google Play beta testing (Days 1-14), production launch Day 15
- **January 21, 2026**: 🎉 Production launch on both iOS App Store and Google Play Store
- **January 21, 2026**: Website post-launch updates - Google Play badge integration, Web App reactivation, improved Arabic translations, larger logo with favicon optimization
- **January 21, 2026**: Marketing campaigns launched - Instagram paid advertising (50-75 KWD/month Kuwait targeting), LinkedIn professional positioning (failure→success narrative), multi-channel brand coordination (Instagram consumer + LinkedIn professional + Portfolio evergreen)

**Portfolio Strategy**:
DawaTime serves as the **first project** in Hamad's programming portfolio (https://hamadalkhalaf.com), demonstrating:

- **Resilience**: Turning failure into learning opportunity
- **Professional Growth**: Evolution from student code to production-ready app
- **End-to-End Development**: Concept → Design → Development → Testing → Production → Growth
- **Strategic Thinking**: Not just building features, but planning sustainable business model
- **Real-World Impact**: Solving actual medication adherence problems for 100+ Kuwaiti users
- **Technical Breadth**: Flutter, Firebase, Cloud Functions, iOS/Android, web deployment, localization (Arabic/English)

**Why This Story Matters**: Demonstrates perseverance and learning agility (shipping real products while at MEW), powerful failure→success narrative ("learned more from rebuilding"), taught same course he failed (broken project → 13 months volunteering → paid TA), documents growth from student to production.

**Key Learnings from Failure → Success**:

1. **Scope Management**: Started with MVP (medication reminders), added features incrementally
2. **Architecture First**: Professional patterns (Firebase, Firestore rules, notification system) from day one
3. **User Focus**: Real user testing (beta program), feedback integration, market validation
4. **Documentation**: Comprehensive project documentation (5,600+ line copilot-instructions.md)
5. **Strategic Planning**: Business model thinking, monetization strategy, growth milestones
6. **Quality over Speed**: 3-year journey from failure to production vs rushing incomplete features

**Root Causes of Original Project Failure** (Technical Analysis):

**Critical Bugs**:

1. **Broken Save**: Uninitialized variables (`nameController`, `pref`) caused null reference crashes on every save attempt
2. **Null Safety Crash**: Force unwrap on SharedPreferences crashed app on first launch
3. **Single Medication Storage**: Only saved ONE medication in SharedPreferences - unusable for real users
4. **Local-Only Data**: No Firebase, no cloud backup - data lost on app deletion

**Missing Core Features**:

1. **No Notifications**: Despite being "medication reminder app", zero notification implementation
2. **No Authentication**: No user accounts, no Firebase Auth
3. **Broken Delete**: Empty `onPressed: (() {})` handler - button did nothing
4. **No Validation**: Text fields had zero input validation or error handling

**Code Quality Issues**: Model typo ("quanity"), UI typo ("regaring"), generic branding ("medication_app"), desktop platform bloat (Windows/Linux/macOS boilerplate unused), default Flutter test file never updated

**README Acknowledgement**: _"Had issues setting up and saving user data... Fix app and implement notifications"_ - Student recognized failure but couldn't fix

**DawaTime vs Original Failed Project Comparison**:

| **Original Failed Project**               | **DawaTime Rebuild**                                  |
| ----------------------------------------- | ----------------------------------------------------- |
| ❌ Uninitialized variables → save crashes | ✅ Proper state management, controller initialization |
| ❌ Local-only SharedPreferences           | ✅ Firebase Firestore cloud database                  |
| ❌ Single medication storage (unusable)   | ✅ Subcollection structure, unlimited medications     |
| ❌ No notification system                 | ✅ flutter_local_notifications + 5 follow-ups         |
| ❌ No authentication                      | ✅ Firebase Auth with email verification              |
| ❌ Broken delete button (empty handler)   | ✅ Swipe gestures with confirmation + undo            |
| ❌ Null safety crashes                    | ✅ Proper null checks, mounted checks throughout      |
| ❌ Desktop platform bloat                 | ✅ Focused mobile-only (iOS/Android)                  |
| ❌ Generic "medication_app" branding      | ✅ Professional "DawaTime" brand (Arabic)             |
| ❌ Typos, poor code quality               | ✅ Production monitoring (Crashlytics, Analytics)     |
| ❌ 0 users (never worked)                 | ✅ 108 active users in Kuwait market (103 real users) |

**Portfolio Narrative Power**: This technical analysis demonstrates not just "I rebuilt an app" but "I identified fundamental flaws (uninitialized variables, broken architecture, missing features), implemented professional solutions (Firebase cloud architecture, proper state management, working notifications), and shipped a production app with real users." The failure becomes a strength by showing deep understanding of what makes software succeed vs fail.

**Interview Talking Point**: _"I learned more from failing and rebuilding than from the course itself. My final project failed because uninitialized variables crashed the save functionality, local-only storage limited scalability, and core features like notifications were missing entirely. While working full-time at Kuwait's Ministry of Electricity & Water, I joined CODED as Student Mentor, volunteering for 13 months before being promoted to paid Teacher Assistant position, supporting the same UniCODE course I had failed. Two years after that, I rebuilt from scratch with Firebase cloud architecture, proper state management, and working notifications. Result: 113 real users in Kuwait with production apps on both iOS and Android (118 total including test accounts)."_

**Current Status** (February 2026 - Day 44):

- **Users**: 118 registered users in Kuwait (68 pre-testing + 15 closed testing + 35 post-launch)
  - **Real users**: 113 (excludes 5 accounts below)
  - **Developer/Personal/Test accounts**: 5 total
    1. Personal account: hamad_alkhalaf_99@hotmail.com (genuine active use)
    2. Personal testing: hamad@dawatime.com
    3. Apple testing: testapple@dawatime.com
    4. Google testing: testgoogle@dawatime.com
    5. Designer account: design@dawatime.com
- **Versions**: iOS v1.4.4+50 (LIVE in Production), Android v1.4.4+50 (LIVE in Production)
- **Beta Testing**: ✅ COMPLETE - 12 continuous testers for 10+ days, 100% crash-free rate
- **Production Status**: 🎉 **LIVE ON BOTH PLATFORMS** - Coordinated v1.4.4 release successful
- **Launch Date**: ✅ Day 15 (January 21, 2026) - Android Play Store debut + iOS update from v1.3.4
- **Release Strategy**: Coordinated v1.4.4 release (Android's first Play Store release, iOS update from October 2025 v1.3.4)
- **Revenue**: $0 (strategic choice - growth phase, Phase 1 of monetization roadmap)
- **Privacy**: Home address publicly visible on Play Store (MEW employment prevents business registration)
- **7-Day Ad Campaign**: ✅ COMPLETE - $69.84 spent, 7,198 reach, 289 website visits, 11,525 impressions
- **Next Milestone**: Growth phase - targeting 200-300 users by March 2026 (Q1 2026, recalibrated based on 0.48/day organic growth rate)
- **Next Hotfix**: v1.4.5 (Play Integrity API + Safe URL fix + Update Checker + Signup Buttons Android) - deploy Days 16-20
- **Vision**: Public health tool first, commercial product second

**App Store Links**:

- **iOS App Store**: https://apps.apple.com/app/dawatime/id6748280994
- **Google Play Store**: https://play.google.com/store/apps/details?id=com.mrhasak99.dawatime
- **Google Play Testing**: https://play.google.com/apps/testing/com.mrhasak99.dawatime

---

## Development History

### Early Development (May - July 2025)

**Initial Concept**: Medication reminder app built with Flutter, focusing on local notifications and Firebase backend.

**Key Milestones**:

- **May 22, 2025**: Initial project upload with basic CRUD operations
- **June 23, 2025**: App renamed to "DawaTime" (Arabic: دواء = medicine)
- **June 25, 2025**: Domain dawatime.com purchased from Porkbun
- **July 2, 2025**: Brand green color (#8AC249) and app icons finalized
  - **Logo & Brand Design Guide**: Created by freelancer Javeria Hareem Shiraz (https://www.upwork.com/freelancers/javeriahareemshiraz)
  - Brand assets include: DawaTime logo, color palette, app icons, visual identity guidelines
- **July 8, 2025**: Cloudflare DNS configuration for dawatime.com
- **July 9, 2025**: Firebase Crashlytics, Analytics, and Performance monitoring integrated
- **July 14, 2025**: App uploaded to App Store Connect

**Core Architecture Established**:

- Firebase Authentication (email/password), Firestore database, local notifications (5 follow-ups every 30 minutes)
- Flat database structure `/{userId}/{medicationId}` (migrated to subcollections Dec 2025)
- Light/dark theme system, swipe gestures, force update mechanism

### Pre-v1.3.4 Refinements (August - October 2025)

**Major Features Added**:

- **August 12, 2025**: v1.1.1 released to App Store (first production release)
- **August 17, 2025**: Arabic localization added - complete bilingual support with RTL layout
- **August 29, 2025**: Days of week scheduling feature (specific weekdays vs every X days)
- **October 22, 2025**: Website created at https://dawatime.com with App Store links
- **October 26, 2025**: v1.3.4 finalized and released (weekday scheduling + production polish)

### Initial Deployments

**Current Production (v1.4.4 - January 21, 2026)**:

- Database migration to subcollection structure `/Users/{userId}/medications/{medicationId}`
- iOS notification fixes (main scheduling loop, interruption levels, startup cleanup)
- Customizable refill reminder scheduling (day/time selection)
- Legal document version tracking system
- **Deployed simultaneously**: iOS App Store + Google Play Store (coordinated launch)

**Version History**:

- **v1.1.1** (August 14, 2025): First iOS App Store release
- **v1.2.1** (August 28, 2025): Arabic localization added
- **v1.3.4** (October 26, 2025): Weekday scheduling + website APK distribution
- **v1.4.4** (January 21, 2026): Database migration + iOS fixes + Play Store debut
- **v1.4.5** (February 11, 2026): Play Integrity API + Safe URL launching + 7 critical stability fixes + 30 professional screenshots

### Stable Feature Set (v1.3.4)

**Deployment Status**: iOS v1.3.4 on App Store (October 2025), Android v1.3.4 on website (October 2025)

**Core Features**:

- Medication management with frequency modes (every X days, specific weekdays)
- Follow-up reminders (T+0, T+30, T+60, T+90, T+120 minutes)
- Refill threshold alerts with weekly notifications
- Arabic/English localization with RTL support
- Light/dark/system theme modes
- Account management (password change, account deletion)
- Force update mechanism via FCM
- Contact form for user support

**Known Limitations (v1.3.4)**:

- Flat database structure (single collection per user)
- iOS notification delivery inconsistent
- No legal document version tracking
- Single notification permission request pattern unclear
- Background task reliability issues on iOS

### Post-v1.3.4 Development Cycle (November - December 2025)

**Development Focus**: Reliability improvements, iOS fixes, and database architecture modernization.

**Major Features Added**:

- CarPlay integration attempted (later removed Dec 8, 2025)
- Country blocking for restricted regions (Israel geo-blocked for GCC compliance)
- Notification rescheduling improvements
- iOS notification interruption levels for time-sensitive alerts
- Firebase Cloud Functions for version notifications
- Resource optimization and cleanup

**December 2025 Major Refactoring**:

- **Database Migration**: Transitioned from `/{userId}/{medicationId}` to `/Users/{userId}/medications/{medicationId}` subcollection structure
- **Legal Documents System**: Added Terms & Conditions and Privacy Policy version tracking
- **iOS Notification Overhaul**: Fixed missing main scheduling loop, added `interruptionLevel` parameter
- **FCM Integration**: iOS APNs token handling, token refresh listeners
- **Startup Cleanup**: Nuclear notification cleanup to prevent ghost alerts
- **Dual Entry Point Legal Checks**: Enforcement at both login and app startup

**Version Progression (December 2025)**:

- v1.4.0: Database migration foundation
- v1.4.1: iOS notification fixes
- v1.4.2: Legal document acceptance flow
- v1.4.3: Deployment preparation (Android SDK 35, Java 17)
- v1.4.4: Customizable refill reminders, production ready

---

## Recent Changes (February 2026)

**Current Version**: v1.4.5+54 (DEPLOYED - February 11, 2026)
**Production Status**: 🎉 **LIVE ON BOTH PLATFORMS** - iOS App Store & Google Play Store (v1.4.5+54)
**Deployment Status**: ✅ **BOTH PLATFORMS LIVE** - v1.4.5 successfully deployed with all hotfixes and new screenshots
**Previous Versions**: v1.4.4+50 (Production) | v1.4.5+52 (Day 19 - Play Integrity) | v1.4.5+51 (Day 16 - RenderFlex) | v1.4.4+49 (Day 7 Evening - Migration Fix) | v1.4.4+47 (Day 7 Morning - setState Fix) | v1.4.4+46 (Day 6 - Migration Safety) | v1.4.4+45 (Day 4 - Android 15) | v1.4.4+44 (Day 3 - Crash Fixes) | v1.4.4+42 (Days 1-2) | v1.4.4+43 & +48 (Skipped)
**Database Structure**: `/Users/{userId}/medications/{medicationId}` (new subcollection structure, default since v1.4.4)
**Migration Status**: Complete - three-phase complete replacement (delete new, copy old, delete old)
**Key Features (v1.4.5)**: iOS notifications working, FCM push notifications, single permission dialog, version tracking active, dual entry point legal document checks, customizable refill reminder scheduling, **Play Integrity API production security**, **Safe URL launching (16 locations)**, **Android signup buttons functional**, **Portfolio domain integration**, **Update checker version detection**, **RenderFlex overflow fixes**, **6 critical crash fixes**, **Android 15 edge-to-edge support**, **Complete migration replacement prevents zombie/duplicate data**, **Website SEO optimization**, **Clean legal document URLs**, **HTTP→HTTPS redirect validation fixed**, **30 professional screenshots (14 iOS + 14 Android + 2 featured graphics)**

**🎉 Day 15 Production Launch (January 21, 2026)**:

- ✅ **iOS v1.4.4+50**: Published to App Store - LIVE in production (update from v1.3.4)
- ✅ **Android v1.4.4+50**: Published to Google Play Store - LIVE in production (first Play Store release)
- 🚀 **Launch Type**: Coordinated v1.4.4 release on same day
- 📊 **Beta Testing Results**: 12 continuous testers, 10+ days testing, 100% crash-free rate
- 🎯 **Milestone**: Android's official Play Store debut + iOS update (iOS in production since August 2025 v1.1.1, v1.3.4 October 2025)
- 🔗 **App Store Links**:
  - iOS: https://apps.apple.com/app/dawatime/id6748280994
  - Android: https://play.google.com/store/apps/details?id=com.mrhasak99.dawatime
- 📈 **Next Steps**: Monitor production metrics, Instagram marketing announcement

**🎉 Day 36 v1.4.5 Hotfix Deployment (February 11, 2026)**:

- ✅ **iOS v1.4.5+54**: Published to App Store - LIVE in production with new screenshots
- ✅ **Android v1.4.5+54**: Published to Google Play Store - LIVE in production with new screenshots
- 🛡️ **Security**: Play Integrity API production integration complete
- 🔗 **Stability**: Safe URL launching (16 locations), Signup Buttons fix, Update Checker fix
- 🎨 **Visual**: 30 professional screenshots (14 iOS + 14 Android + 2 featured graphics)
- 🐛 **Bug Fixes**: RenderFlex overflow, Migration setState, Portfolio domain integration
- 📊 **7 Critical Fixes**: Comprehensive stability and security update
- � **Production Crash Fixed**: v1.4.4 iOS SafariViewController crash confirmed via Crashlytics (FlutterError at url_launcher_ios.dart:176)
- 📈 **Next Steps**: Monitor Crashlytics for v1.4.5 crash-free rate validation, track user adoption, prepare for MOH partnership application (Q2 2026)

**Infrastructure Cleanup & Migration (February 27, 2026)**:

**Status**: ✅ **COMPLETE** - Flutter web app migrated from Netlify → Firebase Hosting; DNS decluttered; project files cleaned up; ESLint fixed

---

#### Flutter Web App Migration: Netlify → Firebase Hosting

- **Trigger**: Decision to consolidate all hosting on Firebase/Google to eliminate Cloudflare dependency and simplify the stack
- **Build**: `flutter build web --release` — succeeded (42 files output to `build/web/`)
- **Deploy**: `firebase deploy --only hosting:webapp` — deployed to `dawatime-webapp` Firebase Hosting site
- **Live URL**: https://webapp.dawatime.com (CNAME → `dawatime-webapp.web.app` ✅)
- **Custom Domain**: `webapp.dawatime.com` was already "Connected" in Firebase Console (pre-configured)
- **CDN**: Firebase uses Fastly CDN (`x-served-by: cache-dxb*` headers) — same performance tier as Netlify
- **Firebase target**: `webapp` → `dawatime-webapp` (defined in `.firebaserc` and `firebase.json`)
- **Files deleted**:
  - `netlify.toml` — Netlify configuration file, no longer needed
  - `.netlify/` — Netlify local state folder (contained `state.json`, `functions-internal/`, `v1/`)

---

#### DNS Cleanup (Cloudflare)

**Zoho Records Removed** (Zoho Mail stopped being used weeks prior, replaced by Google Workspace):

- ✅ **SPF record updated**: Removed `include:zohomail.com` from `v=spf1` TXT record
  - Before: `v=spf1 include:zohomail.com include:_spf.google.com ~all`
  - After: `v=spf1 include:_spf.google.com ~all`
- ✅ **`zoho-verification` TXT record deleted** (domain ownership verification for Zoho, no longer needed)

**SendGrid Records Removed** (SendGrid was never actually used — email notifications use Nodemailer with Google Workspace SMTP `smtp.gmail.com`, not SendGrid):

- ✅ Deleted 6 stale SendGrid DNS records:
  - `em1234.dawatime.com` CNAME (SendGrid click tracking)
  - `s1._domainkey.dawatime.com` CNAME (SendGrid DKIM key 1)
  - `s2._domainkey.dawatime.com` CNAME (SendGrid DKIM key 2)
  - `url1234.dawatime.com` CNAME (SendGrid link branding)
  - `dawatime.com` TXT `v=DKIM1; k=rsa; p=...` (SendGrid DKIM public key)
  - `_dmarc.dawatime.com` TXT `v=DMARC1; p=none; rua=mailto:...@sendgrid.com` (SendGrid DMARC reporting)

**Remaining DNS records (all active/needed)**:

| Record | Type | Purpose |
|--------|------|---------|
| `dawatime.com` | A | Firebase Hosting landing page (185.199.x.x) |
| `www.dawatime.com` | CNAME | → `dawatime.com` |
| `webapp.dawatime.com` | CNAME | → `dawatime-webapp.web.app` (Flutter web app) |
| `dawatime.com` | MX | Google Workspace email routing |
| `dawatime.com` | TXT SPF | `v=spf1 include:_spf.google.com ~all` |
| `google._domainkey` | TXT | Google Workspace DKIM signing |
| `_dmarc` | TXT | DMARC policy for email authentication |

---

#### Project File Cleanup

**Files deleted**:

| File | Reason |
|------|--------|
| `netlify.toml` | Netlify config — no longer using Netlify |
| `.netlify/` | Netlify local state folder |
| `package.json` (root) | Duplicate/leftover — real one is `functions/package.json` |
| `package-lock.json` (root) | Duplicate/leftover — same reason |
| `ios/Runner.xcodeproj/project.pbxproj.backup` | Xcode backup file |
| `.firebase/hosting.YnVpbGQvd2Vi.cache` | Firebase deploy cache for `build/web` |
| `.firebase/hosting.cHVibGlj.cache` | Firebase deploy cache for `public/` |
| `functions/migrate-to-subcollections.js` | One-time migration script (already completed long ago) |

**`.gitignore` updated**:
- Removed stale Netlify comment block
- Re-added `.netlify` as a proper gitignore entry

**`functions/index.js` updated**:
- Removed `require` and `exports` for the deleted migration script:
  ```js
  // REMOVED:
  const { migrateMedicationsToSubcollections } = require("./migrate-to-subcollections");
  exports.migrateMedicationsToSubcollections = migrateMedicationsToSubcollections;
  ```

---

#### ESLint Fix (`functions/index.js`)

- **Problem**: 543 pre-existing ESLint errors (2-space indentation vs required 4-space, `object-curly-spacing` violations)
- **Auto-fix**: `./node_modules/.bin/eslint --fix index.js` resolved all but 2
- **Manual fix**: 2 `max-len` violations (lines exceeded 80-char limit) fixed by splitting filter callbacks:
  ```js
  // Before (81+ chars):
  const arabicUsers = deduplicatedUsers.filter((u) => u.language === "ar");
  const englishUsers = deduplicatedUsers.filter((u) => u.language !== "ar");

  // After:
  const arabicUsers = deduplicatedUsers.filter(
      (u) => u.language === "ar",
  );
  const englishUsers = deduplicatedUsers.filter(
      (u) => u.language !== "ar",
  );
  ```
- **Result**: `npm run lint` → **0 errors** ✅

---

#### Email Notification Architecture (Confirmed)

Email notifications (contact form → Firestore → Cloud Function → email to admin) use:
- **Transport**: Nodemailer with `smtp.gmail.com` (Google Workspace SMTP)
- **Credentials**: Firebase Secret Manager (`EMAIL_USER`, `EMAIL_PASSWORD`) — NOT in source code
- **Local dev only**: `functions/.env` contains plaintext credentials (properly listed in `functions/.gitignore`, never committed to Git)
- **NOT using**: SendGrid (all SendGrid DNS records were stale leftovers from an abandoned setup attempt)

---

**npm Security Updates (February 18, 2026)**:

**Status**: ✅ **COMPLETE** - All 4 Dependabot alerts resolved

**Vulnerabilities Fixed**:

- ✅ **fast-xml-parser (HIGH)**: DoS through entity expansion in DOCTYPE (GHSA-jmr7-xgp7-cmfj)
  - Fixed in root package.json (changed 3 packages)
  - Fixed in functions/package.json
- ✅ **qs (LOW)**: arrayLimit bypass in comma parsing allows denial of service (GHSA-w7fw-mjwx-w883)
  - Fixed in root package.json (upgraded to ≥6.14.1)
  - Fixed in functions/package.json (upgraded to ≥6.14.1)

**Commands Executed**:

```bash
# Root directory
npm audit fix  # Changed 3 packages, audited 621 packages

# Functions directory
cd functions && npm audit fix  # Updated transitive dependencies
```

**Remaining Issues**: 29 vulnerabilities (3 moderate, 26 high) in devDependencies only, not in production build

**Dependabot Alert #35 - ajv ReDoS (February 19, 2026)**:

- **Alert**: ajv <8.18.0 vulnerable to ReDoS when using `$data` option (GHSA-2g4f-4pwh-qvx6)
- **Severity**: Moderate (5.5/10 CVSS), low exploitability (EPSS 0.086%)
- **Location**: functions/package-lock.json (nested in eslint dependencies)
- **Attempted Fix #1** (Feb 18): ❌ Running `npm audit fix --force` downgraded eslint to deprecated v4.1.1 and increased vulnerabilities
- **Attempted Fix #2** (Feb 19): ❌ Added explicit "ajv": ">=8.18.0" to devDependencies
  - Failed because eslint@8.57.1 has bundled ajv in nested node_modules
  - npm doesn't override nested dependencies with top-level versions
- **Decision**: Accept dev-only risk and keep current versions (reverted ajv addition)
- **Rationale**:
  - All 29 vulnerabilities are in devDependencies (eslint, firebase-functions-test/jest, geoip-lite)
  - Zero impact on deployed Cloud Functions (production code unaffected)
  - `npm audit fix --force` would break modern linting (downgrade to eslint 4.1.1 from 2017)
  - Risk limited to local development environment only
- **Risk**: Low (malicious code would need to be introduced during development to exploit)

**Files Modified**:

- `/package-lock.json` - Updated fast-xml-parser and qs versions
- `/functions/package-lock.json` - Updated fast-xml-parser and qs versions

**Result**: All 4 GitHub Dependabot alerts cleared ✅ (0 high severity, 0 low severity in production dependencies)

**Website Post-Launch Updates (Day 15 - January 21, 2026)**:

- **Google Play Badge Integration**:
  - ✅ Replaced "Coming Soon" button with functional Google Play Store badge
  - ✅ Bilingual badge switching: English (`GetItOnGooglePlay_Badge_Web_color_English.svg`) / Arabic (`GetItOnGooglePlay_Badge_Web_color_Arabic-Saudi-Arabia.svg`)
  - ✅ Hover effects matching App Store badge (lift + shadow)
  - ✅ Links to: https://play.google.com/store/apps/details?id=com.mrhasak99.dawatime
- **Web App Button Reactivation**:
  - ✅ Removed disabled state and opacity: 0.5
  - ✅ Added hover effects (color change, lift, shadow)
  - ✅ Links to: https://webapp.dawatime.com
- **Content Updates**:
  - ✅ English description: "Download from the App Store **or Google Play**, or use our web app"
  - ✅ Arabic description: "حمّل من آب ستور **أو جوجل بلاي**، أو استخدم تطبيق الويب"
  - ✅ Improved Arabic translation: "متوفر" instead of "متاح" (more natural for app availability)
  - ✅ Enhanced support link: "تفضل بزيارة مركز الدعم" (polite formal tone)
  - ✅ English support link: Added "Please" for consistency ("Please visit Support Center")
- **Visual Design Enhancements**:
  - ✅ Logo size increased: 200px → 280px (40% larger, more prominent)
  - ✅ Logo rounded corners: 24px border-radius for softer appearance
  - ✅ New favicon: DawaTime-favicon.png (green background, rounded corners, 80-85% icon fill for better visibility in browser tabs)
- **JavaScript Updates**:
  - ✅ Renamed `updateAppStoreBadge()` to `updateStoreBadges()` to handle both App Store and Google Play badges
  - ✅ MutationObserver now switches both badges simultaneously on language toggle
- **Files Modified**:
  - public/index.html (8 replacements: badge integration, Web App reactivation, translations, logo styling, favicon updates)
  - public/DawaTime-favicon.png (NEW: optimized favicon with larger icon, rounded corners, green background)
- **Deployment**: Firebase Hosting (20 files deployed, live at https://dawatime.com)

---

### Web App Enhancements (January-February 2026)

**Status**: ✅ **DEPLOYED** - Live at https://webapp.dawatime.com (February 5, 2026)

**File**: web/index.html (Flutter Web App wrapper for Progressive Web App)

**Context**: The Flutter web app serves as an alternative to mobile apps for users who prefer browser-based access. Unlike the marketing site (public/index.html at https://dawatime.com), the web app provides full CRUD functionality for medication management without requiring app downloads.

#### 1. Kuwait-Specific SEO Optimization

**Purpose**: Target Kuwait and GCC market with localized search engine optimization

**Implementation**:

- **Description meta tag**: Added "for Kuwait & GCC" regional positioning
- **Keywords expansion**: 8 generic terms → 20+ Kuwait-specific keywords
  - English: "medication reminder Kuwait", "pill tracker GCC", "medicine schedule Kuwait"
  - Arabic: "دواء تايم", "تذكير الدواء الكويت", "جدول الأدوية"
- **Author meta tag**: Added "Hamad AlKhalaf" for developer attribution
- **Search control**: `<meta name="robots" content="noindex, nofollow">`
  - Prevents web app from competing with marketing site in search results
  - Marketing site (dawatime.com) handles SEO, web app serves authenticated users
- **Geographic targeting**:
  - `<meta name="geo.region" content="KW">` (Kuwait ISO code)
  - `<meta name="language" content="English, Arabic">` (bilingual support)

**Rationale**: noindex strategy ensures clean SEO separation—marketing site ranks in search engines, web app provides functionality.

#### 2. Enhanced Social Media Integration

**Purpose**: Proper Open Graph and Twitter Card metadata for social sharing

**Implementation**:

- **Open Graph tags** (8 new properties):
  - `og:url`: https://webapp.dawatime.com
  - `og:type`: website
  - `og:title`: DawaTime - Never Miss a Dose
  - `og:description`: Smart medication reminder app for Kuwait & GCC
  - `og:image`: https://webapp.dawatime.com/icons/Icon-512.png
  - `og:image:width`: 512
  - `og:image:height`: 512
  - `og:locale`: en_US (with ar_KW alternate)
  - `og:site_name`: DawaTime
- **Twitter Cards** (HTML5 compliance):
  - Fixed: Changed `property="twitter:*"` to `name="twitter:*"` (HTML5 spec)
  - Added: `twitter:url` metadata
  - Card type: summary_large_image
- **Image URLs**: Changed from relative to absolute (https://webapp.dawatime.com/icons/Icon-512.png)

**Benefits**: Proper social media previews when users share web app links on Facebook, Twitter, LinkedIn, WhatsApp.

#### 3. Loading Screen System

**Purpose**: Prevent Flutter white flash during ~1-2 second app initialization

**Implementation** (~108 lines total):

**HTML Structure**:

```html
<div id="loading-screen">
  <div class="loading-card">
    <img
      src="icons/Icon-192.png"
      alt="DawaTime Logo"
      style="width: 96px; height: 96px; border-radius: 20px;"
    />
    <h1 class="app-name">DawaTime</h1>
    <p class="tagline">Never miss a dose...</p>
    <div class="spinner"></div>
  </div>
</div>
```

**Logo Evolution**:

- **Original (January 2026)**: CSS-based animated pill icon (green capsule shape)
- **Updated (February 17, 2026)**: Professional branded logo (DawaTime.png)
- **Rationale**: Display actual brand identity instead of generic placeholder

**Styling**:

- **Background**: Green gradient (#8AC249 → #6fa32e, 45° diagonal)
- **Card**: White rounded container (24px border-radius, centered)
- **Logo**: Professional DawaTime brand icon (96px × 96px, rounded corners 20px)
- **Typography**: Nunito ExtraBold 32px for "DawaTime", 18px tagline
- **Spinner**: Animated circular loader (2px green border, 1s rotation)
- **Animations**:
  - Logo pulse: scale(1) → scale(1.05) → scale(1) over 2s (infinite)
  - Spinner rotation: 360° over 1s (infinite linear)
  - Fade-out: opacity 1 → 0 over 0.5s when Flutter loads

**JavaScript Removal**:

```javascript
window.addEventListener("flutter-first-frame", function () {
  var loadingScreen = document.getElementById("loading-screen");
  if (loadingScreen) {
    loadingScreen.classList.add("fade-out");
    setTimeout(function () {
      loadingScreen.remove();
    }, 500);
  }
});
```

**User Experience**:

- Prevents jarring white screen flash
- Provides branded loading experience
- Shows app initialization progress
- Smooth fade-out transition to Flutter UI

#### 4. Hidden SEO Content

**Purpose**: Keyword-rich structured content for search engines (despite noindex)

**Implementation** (~19 lines):

```html
<div style="position: absolute; left: -9999px;" aria-hidden="true">
  <h1>DawaTime - Medication Reminder App for Kuwait</h1>
  <h2>Smart Pill Tracker & Medicine Schedule</h2>
  <h3>Features:</h3>
  <ul>
    <li>Set medication reminders with 5 follow-ups</li>
    <li>Track refills and low stock alerts</li>
    <li>Bilingual support (English/Arabic)</li>
    <li>Weekday scheduling for complex medication plans</li>
    <li>Dark mode and theme customization</li>
    <li>Available on iOS, Android, and Web</li>
    <li>Free medication management for Kuwait & GCC</li>
  </ul>
  <p>Contact: Available 24/7 via in-app support</p>
</div>
```

**Positioning**: Off-screen (left: -9999px) with `aria-hidden="true"` for accessibility compliance

**Purpose**: Provides search engines with structured H1/H2/H3 hierarchy and keyword-rich bullet points

**Note**: Despite noindex meta tag, this content serves as fallback if indexing rules change or for web crawlers that ignore robots directives.

#### 5. Technical Details

**Changes Summary**:

- **Total additions**: ~138 lines
- **Total modifications**: ~10 lines
- **Categories**: SEO (12 changes), social media (13 changes), loading screen (108 lines), hidden content (19 lines)

**Deployment** (Migrated to Firebase Hosting - February 19, 2026):

- **Platform**: Firebase Hosting (multi-site target: `webapp`)
- **URL**: https://webapp.dawatime.com
- **Build command**: `flutter build web --release`
- **Deploy command**: `firebase deploy --only hosting:webapp`
- **Build time**: ~24 seconds
- **Font optimization**: MaterialIcons tree-shaken 99.3% (1.6MB → 11.8KB)

**Files Modified**:

- `/web/index.html` (Flutter web wrapper)
- `/web/manifest.json` (unchanged, PWA configuration)
- `/web/robots.txt` (unchanged, allows all crawlers despite noindex meta tag)

**Deployment History**:

- **February 5, 2026**: Initial SEO optimization deployment (4 assets uploaded to CDN)
- **February 17, 2026**: Logo update deployment (5 assets uploaded to CDN)
  - Replaced CSS pill icon with professional branded logo (DawaTime.png)
  - Build time: 22.0s, MaterialIcons tree-shaken 99.3%
  - Deployed to: https://webapp.dawatime.com
- **Status**: ✅ Live in production

**Why These Changes**:

- **SEO**: Kuwait/GCC targeting aligns with primary market positioning
- **Loading screen**: Standard Flutter web best practice (prevents white flash)
- **Social media**: Proper link previews improve user trust and sharing
- **noindex**: Prevents confusion—marketing site for discovery, web app for usage

---

**v1.4.5+53 Hotfix Release** (Day 19 - January 25, 2026):

**Release Status**: ✅ **DEPLOYED TO INTERNAL TESTING**

- **Build**: 54.3MB app-release.aab
- **Testing**: 5 of 6 features validated on physical Android device (83%)
- **Release Notes**: Approved (English + Arabic, production-ready)
- **Deployment**: ✅ Uploaded to Google Play Console Internal Testing (Day 19)
- **Monitoring Phase**: ⏭️ **SKIPPED** - User decision (issues validated and fixed on physical device)
- **Next Phase**: Staged rollout to production (10% → 50% → 100%)

**All Features Implemented** ✅ (7 total):

**1. Play Integrity API Production Integration** ✅ VALIDATED:

- **Purpose**: App authenticity verification to prevent tampering, clones, and abuse
- **Implementation**:
  - Removed debug bypasses from main.dart lines 772-776 (splash screen verification)
  - Removed debug bypasses from login_page.dart lines 160-166 (login flow verification)
  - Total: 16 lines removed across 2 files
  - Pattern removed: `if (kDebugMode) { return true; }` guards
- **Impact**: Production app now enforces Firebase Cloud Function verification on ALL devices
- **Testing**: ✅ Validated in previous session (working correctly)
- **Build**: v1.4.5+52 (54.3MB)

**2. Migration setState Crash Fix** ✅ VALIDATED:

- **Issue**: Null check operator crash when users navigate away during migration status check
- **Implementation**: Added mounted checks before setState in home_page.dart lines 178, 180, 183
- **Fix Pattern**: Wrapped all three setState calls with `if (mounted)` guards
- **Impact**: Prevents production crashes discovered via Crashlytics
- **Testing**: ✅ Validated in previous session (no crashes observed)

**3. Signup Buttons Android Fix** ✅ VALIDATED (Day 19):

- **Issue**: Terms & Privacy links not working on Android/Samsung devices (silent failure)
- **Root Cause**: LaunchMode.platformDefault incompatible with Android 11+ package visibility restrictions
- **Implementation** (3-part fix):
  1. Added Android 11+ queries in AndroidManifest.xml (lines 66-69):
     ```xml
     <queries>
       <intent><action android:name="android.intent.action.VIEW" />
         <data android:scheme="https" /></intent>
     </queries>
     ```
  2. Changed LaunchMode.platformDefault → LaunchMode.externalApplication in signup_page.dart (2 locations)
  3. Added error handling with SnackBar feedback
- **Impact**: Unblocks new user signups on Android/Samsung devices
- **Testing**: ✅ **User confirmed: "signup text buttons now work in android"**
- **Build**: v1.4.5+53 (54.3MB)
- **Discovery**: Day 15 production user complaint, iOS works fine, Android silent failure

**4. RenderFlex Overflow Crash Fix** ✅ VALIDATED (Day 19):

- **Issue**: "A RenderFlex overflowed by 25 pixels on the right" crash on physical Android device (Galaxy A15 5G)
- **Root Cause**: Legal update dialog buttons had unnecessary Row + Center wrappers inside button child
- **Implementation**: Removed Row and Center wrappers in main.dart lines 1097, 1130
  - Before: `child: Row(children: [Center(child: Text(...))])`
  - After: `child: Text(...)`
- **Impact**: Prevents crashes during legal document update flow, buttons display correctly on all screen sizes
- **Discovery**: Firebase Crashlytics during physical device testing (v1.4.5 build 51)
- **Testing**: ✅ **User confirmed: "Renderflex issue now disappeared"**

**5. Portfolio Domain Integration** ✅ VALIDATED (Day 19):

- **Purpose**: Added developer portfolio link to Settings → About dialog
- **Implementation**:
  - Added "visitPortfolio" localization keys in app_en.arb, app_ar.arb
  - Made developer name section clickable in settings.dart (lines 225-285)
  - Added Column with developer name + "Visit Portfolio" link (language icon + underlined text)
  - Links to: https://hamadalkhalaf.com
- **Impact**: Users can access developer's portfolio website from app settings
- **Testing**: ✅ **User confirmed: "portfolio is now shown and it works"**

**6. Update Checker Bug Fix** ⏹️ SKIPPED (Code-Reviewed):

- **Issue**: False "up to date" message when reinstalling older version
- **Root Cause**: SharedPreferences persists across reinstalls, 24-hour cache blocks update checks for downgraded versions
- **Implementation**: Added version change detection in lib/main.dart lines 583-608 (\_shouldCheckForUpdates function)
  - Compares stored version vs. current version
  - If versions don't match → clears cache → forces update check
- **Impact**: Users on older versions now correctly see "Update Required" dialog
- **Validation**: ✅ flutter analyze passed (4.2s, no issues)
- **Testing**: ⏹️ **User chose to skip** (complex test scenario, edge case, low-risk)

**7. Safe URL Launching (iOS SafariViewController Fix)** N/A (Android Testing Only):

- **Purpose**: Fix iOS SafariViewController crashes with canLaunchUrl validation
- **Implementation**: Added validation to 16 launchUrl locations:
  - signup_page.dart (2 locations)
  - main.dart (8 locations)
  - settings.dart (3 locations)
  - login_page.dart (4 locations)
- **Pattern**: `try { if (await canLaunchUrl(url)) { await launchUrl(...) } else { SnackBar error } } catch (e) { SnackBar error }`
- **Impact**: Prevents iOS production crashes when opening Terms/Privacy/Update links
- **Testing**: N/A (tested on Android device only, iOS testing pending)

**Build Details**:

- **Bundle Size**: 54.3MB (app-release.aab)
- **Build Number**: 53
- **Version**: 1.4.5
- **flutter analyze**: ✅ Passed (no issues)
- **Platforms**: Android + iOS (coordinated release)

**Testing Validation Results** (Day 19 - January 25, 2026):

- **Test Device**: Physical Android device (Galaxy A15 5G)
- **Features Validated**: 5 of 6 testable features (83%)
  1. ✅ Play Integrity: Working correctly
  2. ✅ Migration setState: No crashes observed
  3. ✅ **Signup Buttons**: "signup text buttons now work in android" ← User confirmed
  4. ✅ **RenderFlex Overflow**: "Renderflex issue now disappeared" ← User confirmed
  5. ✅ **Portfolio Domain**: "portfolio is now shown and it works" ← User confirmed
  6. ⏹️ **Update Checker**: Skipped by user decision (complex test, edge case, code-reviewed)
  7. N/A **iOS URL Launcher**: Android device only (iOS testing pending)

**Approved Release Notes** (Production-Ready):

**English Version**:

```
We've improved DawaTime for you:

- Enhanced Security: Added verification to protect your data.
- Fixed Links: Signup page terms & policy links work perfectly now.
- Visual Polish: Better button layout on screens of all sizes.
- Stability: Bug fixes for a smoother experience.

Never miss a dose! 💚
```

**Arabic Version**:

```
قمنا بتحديث تطبيق دواء تايم لخدمتكم بشكل أفضل:

- أمان مُعزّز: أضفنا حماية إضافية لبياناتكم.
- إصلاح الروابط: روابط الشروط والسياسة تعمل الآن بكفاءة.
- تحسينات بصرية: تعديل الأزرار لتناسب جميع الشاشات.
- استقرار: إصلاحات عامة لتجربة أكثر سلاسة.

لا تفوّت جرعة! 💚
```

**Deployment Timeline**:

- **Day 16 (Jan 22)**: v1.4.5+51 development started (RenderFlex fix)
- **Day 19 (Jan 25)**: v1.4.5+52 built (Play Integrity production integration)
- **Day 19 (Jan 25)**: Signup Buttons Android issue discovered
- **Day 19 (Jan 25)**: v1.4.5+53 built with Android 11+ queries fix (54.3MB)
- **Day 19 (Jan 25)**: Comprehensive physical device testing (5 of 6 features validated)
- **Day 19 (Jan 25)**: Release notes generated and approved
- **Day 19 (Jan 25)**: Documentation updated
- **Day 19 (Jan 25)**: ✅ **Deployed to Google Play Console Internal Testing**
- **Days 18-19 (Jan 26-27)**: ~~24-48h Crashlytics monitoring~~ → **SKIPPED** (user decision)
- **Days 20-22 (Jan 28-30)**: ~~Staged rollout to production (10% → 50% → 100%)~~ → **ON HOLD**
- **Day 22 (Jan 28, 2026)**: ✅ **HANDOFF COMPLETE** - All materials delivered to Rahma (test account, documentation, brand assets)
- **Days 22-42 (Jan 28-Feb 17, 2026)**: ⏳ **IN PROGRESS** - Rahma creating 14-16 screenshots (3-4 week delivery)
- **Day 42+ (Feb 17+)**: **DUAL DEPLOYMENT** - iOS v1.4.5+53 with new screenshots (App Store Connect)
- **Day 42+ (Feb 17+)**: Android v1.4.5+53 staged rollout begins (Play Console)

**Next Steps**:

- ✅ ~~Upload to Google Play Console Internal Testing~~ → **DEPLOYED** (Day 19)
- ⏭️ ~~Monitor Firebase Crashlytics for 24-48 hours~~ → **SKIPPED** (user decision - issues validated on physical device)
- ⏳ Begin staged rollout to production (10% → 50% → 100%)
- ⏳ Monitor App Store Connect & Play Console metrics during rollout
- ⏳ Watch for user feedback on signup flow and portfolio link
- ⏳ Prepare iOS v1.4.5+53 upload to App Store Connect (coordinated release)

**Signup Buttons Fix Journey** (Days 15-19): Discovery: Android/Samsung Terms & Privacy links fail silently, blocks signups (CRITICAL). Diagnosis: LaunchMode.platformDefault incompatible with Android 11+ package visibility, missing AndroidManifest.xml queries. Implementation (3-part fix): Added `<queries>` block (lines 66-69), changed to LaunchMode.externalApplication, added try-catch+SnackBar. Files: AndroidManifest.xml, signup_page.dart (lines 294-330, 349-375). Validation: Galaxy A15 5G tested, user confirmed working, signups unblocked. Build: v1.4.5+53 (54.3MB).

**Files Modified (v1.4.5+53 Complete Changeset)**:

- `/lib/home_page.dart` - Migration setState mounted checks (lines 178, 180, 183)
- `/lib/main.dart` - Safe URL launching (8 locations), Update Checker (lines 583-608), Play Integrity debug removal (lines 772-776), RenderFlex fix (lines 1097, 1130)
- `/lib/signup_page.dart` - Safe URL launching (2 locations), Signup Buttons Android fix (lines 294-330, 349-375)
- `/lib/settings.dart` - Safe URL launching (3 locations), Portfolio Domain (lines 225-285)
- `/lib/login_page.dart` - Safe URL launching (4 locations), Play Integrity debug removal (lines 160-166)
- `/lib/l10n/app_en.arb` - "visitPortfolio" key
- `/lib/l10n/app_ar.arb` - "visitPortfolio" key
- `/android/app/src/main/AndroidManifest.xml` - Android 11+ queries (lines 66-69)
- `/pubspec.yaml` - Version: 1.4.5+53
- `/android/app/build.gradle.kts` - versionCode: 53

**Deployment Status (January 21, 2026 - Day 15)** - PRODUCTION LAUNCH COMPLETE:

- 🎉 **PRODUCTION LAUNCH**: v1.4.4 published on both platforms
- ✅ **iOS v1.4.4+50**: Published to App Store - LIVE in production (update from v1.3.4)
- ✅ **Android v1.4.4+50**: Published to Google Play Store - LIVE in production (first-ever Play Store release)
- 📊 **Beta Testing**: 12 continuous testers for 10+ days, 100% crash-free rate on final build
- 🚀 **Launch Strategy**: Coordinated v1.4.4 release - Android Play Store debut, iOS update (iOS in production since August 2025)
- 🔗 **Store Links**: Both apps accessible at official App Store and Google Play Store URLs
- 📈 **Post-Launch**: Monitor Firebase Crashlytics, App Store Connect, Play Console analytics
- 🎯 **Next Steps**: Instagram announcement, v1.4.5 hotfix preparation (Days 16-20)

**Marketing Campaign Launch (Day 15 - January 21, 2026)**:

**Instagram Paid Advertising Campaign**:

- **Post**: https://www.instagram.com/p/DTw9AasDEUD/ (bilingual carousel: English + Arabic)
- **Status**: ✅ **ACTIVE** - Ad approved and live, running 7-day campaign
- **Creative**: #8AC249 green background, DawaTime logo, "Never miss a dose" tagline, dual store badges
- **Caption Strategy**: Bilingual (English → Arabic), minimal text, "Link in bio" CTA, 5 hashtags optimized
- **Hashtags**: #DawaTime #kuwait #الكويت #madeinkuwait #صحة (5-tag Instagram ad limit)
- **Strategic Decision**: #MadeInKuwait (local pride) over #MedicationReminder (conversion) for launch day emotional appeal
- **Ad Configuration** (Actual):
  - **Goal**: Learn More (website clicks)
  - **Destination**: http://dawatime.com/
  - **Budget**: $70.00 USD over 7 days ($10/day)
  - **Target Audience**: Kuwait, Age 18+, Interest: Health & wellness
  - **Duration**: 7 days (Week 1 test campaign)
- **Performance Targets**: CPI <2 KWD (~$6.50), CTR >1.5%, Day 1 retention >20%
- **Placement**: Instagram Feed (primary) + Stories (secondary)
- **Week 2-4 Optimization**: Switch to #medicationreminder (conversion focus) after launch awareness wave
- **Month 2-3 Expansion**: Add Bahrain, Qatar if Kuwait CPI <2 KWD performs well

**Campaign Performance Tracking** (7-Day Results, Jan 21-27, 2026): 11,525 views, 7,198 reach, 289 website visits ($0.24 CPI), $69.84 spend (99.8%), ✅ COMPLETED. Engagement: 30 likes, 8 shares, 9 saves, 237 profile visits, 3 follows. Kuwait governorates balanced (Hawalli 26.5%, Capital 26.2%). Demographics: 77.9% male, 25-34 age 36.3%. Performance: 4.0% visit conversion rate, CTR 1.24% (acceptable for awareness), cost-effective ($0.01 CPM), balanced geographic distribution validates Kuwait-wide appeal.

**Campaign Conversion Analysis**: $69.84 spend → 289 visits → 61 downloads (iOS: 47, Android: 14) → 10 new users (98→108 total). Funnel: 21% visit-to-download, 16% download-to-signup. Cost metrics: $0.24/visit, $1.14/download (82% below target), $6.98/new user. Performance: Exceptional CPI, strong download conversion, low signup rate due to existing user reinstalls. Week 2-4 optimization: target cold audiences.

**Store Installation Data (Days 15-44: Jan 21-Feb 18, 2026)**:

- **iOS**: 57 total downloads (47 during 7-day campaign Jan 21-27, launch day peak: 10 installs, 10 post-campaign Jan 28-Feb 18)
- **Android**: 14 production installs (Jan 21-28) + 33 closed testing (Jan 15-20)
- **Combined Production Performance**: 71 downloads (iOS: 57, Android: 14) - Platform split: iOS 80%, Android 20%
- **Campaign Correlation**: 61 downloads during 7-day Instagram ad campaign (Jan 21-27, $69.84 spend, 289 website visits, 7,198 reach)
- **Post-Campaign Performance**: 10 additional iOS downloads (Jan 28-Feb 18, 22-day period) = organic growth
- **Firebase Authentication Total (Day 44)**: 118 users (113 real + 5 dev/test accounts: hamad_alkhalaf_99, hamad@dawatime, testapple@dawatime, testgoogle@dawatime, design@dawatime)
- **User Growth**: 98 pre-campaign → 118 current = 20 new registered users in 29 days
- **Install-to-Registration Rate**: 71 downloads → 20 new registrations = 28% conversion (improved from 16% during campaign)

**LinkedIn Professional Positioning**:

- **Post**: https://www.linkedin.com/feed/update/urn:li:activity:7419657007840022528/
- **Strategy**: Failure→success narrative (9.5/10 rating vs 7/10 generic announcement)
- **Hook**: "Three years ago, I submitted a broken final project for my Flutter course at CODED"
- **Structure**: Context (MEW full-time) → Technical bullets (🛠️💊🌍🔔) → Validation (12 testers, 100% crash-free) → Growth lesson → CTA
- **Timeline**: December 20, 2022 (failed project) → January 21, 2026 (production launch) = 3 years 1 month
- **Hashtags**: #Flutter #HealthTech #Kuwait #AndroidDev #iOSDev #CrossPlatform #DawaTime #FromFailureToSuccess
- **Positioning**: Builder credibility + technical execution + growth mindset (professional network engagement)

**Multi-Channel Brand Positioning**:

- **Instagram** (Consumer): Local pride (#MadeInKuwait), health benefit ("Never miss a dose"), bilingual GCC targeting, paid ads for acquisition
- **LinkedIn** (Professional): Builder credibility, failure→success narrative, technical showcase, growth mindset
- **Portfolio** (Evergreen): https://hamadalkhalaf.com - Capability-focused, dual-platform availability, no limiting metrics
- **Milestone**: January 21, 2026 - Coordinated multi-platform marketing launch (Instagram paid + LinkedIn organic + Portfolio integration)

**Post-Launch Actions** (Days 15-22):

- **Instagram**: ✅ **Ad Campaign LIVE** - 7-day boosted campaign running ($10/day, $70 total). Monitor reach/impressions/CPI daily. Evaluate performance Day 22 for Week 2 strategy.
- **LinkedIn**: First 2 hours critical for algorithm, reply to comments within 15 minutes, share to Stories within 24 hours
- **Week 1 Goals**: Track CPI, CTR, install conversion rate via Firebase Analytics + App Store Connect + Play Console, target 98→150 users (53% growth)
- **Week 2-4**: Hashtag optimization (#medicationreminder conversion focus), A/B test creative variations, refine targeting based on data

**iOS Upload Timeline**:

- **Day 5 (Jan 11)**: iOS v1.4.4+45 uploaded to TestFlight - Status "Waiting for Review"
- **Day 6 (Jan 12)**: 🚨 Migration data loss bug discovered in v45 → Emergency v46 deployment
- **Day 6 (Jan 12)**: iOS v1.4.4+46 uploaded to TestFlight - Status "Waiting for Review" (superseded v45)
- **Day 7 (Jan 13 Morning)**: iOS v1.4.4+47 uploaded to TestFlight - Status "Waiting for Review" (setState fix)
- **Day 7 (Jan 13 Evening)**: iOS v1.4.4+49 uploaded to TestFlight - Status "Waiting for Review" (canceled v47, skipped v48, migration fix)
- **Day 8 (Jan 14)**: iOS v1.4.4+50 uploaded to TestFlight - Status "Waiting for Review" (SEO & legal link optimization)
- **Day 9 (Jan 15)**: ✅ **iOS v1.4.4+50 APPROVED** - Status changed to "Pending Developer Release"
- **Day 9 (Jan 15)**: 🚨 **CRISIS #6** - iOS SafariViewController crash discovered in production v1.1.1
- **Day 9 (Jan 15)**: **Decision**: Defer SafariViewController fix to v1.4.5 post-launch hotfix (Days 15-20)
- **Day 15 (Jan 21)**: 🎉 **iOS v1.4.4+50 PUBLISHED** - Released to production on App Store
- **Day 32 (Feb 7)**: ✅ **iOS v1.4.5+53 IPA BUILT** - 45MB IPA created for App Store Connect standby
- **Day 33 (Feb 8)**: ✅ **iOS v1.4.5+53 UPLOADED** - Deployed to App Store Connect via Apple Transporter, awaiting TestFlight processing
- **Day 34 (Feb 9)**: ✅ **iOS v1.4.5+54 IPA BUILT & UPLOADED** - 49.6MB IPA deployed to App Store Connect via Apple Transporter
- **Day 34 (Feb 9)**: ✅ **Android v1.4.5+54 AAB BUILT & UPLOADED** - 54.4MB AAB deployed to Play Console
- **Version Parity**: Both platforms launched simultaneously on Day 15 (January 21, 2026) with v1.4.4+50, coordinated v1.4.5+54 upload Day 34

**Beta Testing Timeline (January 7-21, 2026)**:

**Testing Period**: 15 days (Days 1-15) with 25 initial testers → 12 continuous testers for 10+ days

**Emergency Updates Deployed**: 6 versions (v42→v44→v45→v46→v47→v49→v50, skipped v43 and v48)

- Days 1-2: v42 initial release (25 testers, 100% engagement)
- Day 3: v44 emergency (5 crashes fixed: widget lifecycle, context safety, UI constraints, ProGuard, Firebase Auth, iOS symbolication)
- Day 4: v45 emergency (SHA certificate + Android 15 edge-to-edge)
- Day 4: v46 emergency (migration data safety: two-phase copy-then-delete)
- Day 5: v47 emergency (setState mounted checks)
- Day 5: Website emergency (bad APK Dec 16 deployment discovered and removed)
- Day 6: Website SEO optimization (canonical tags, sitemap, robots.txt, legal link cleanup)
- Day 6: v50 deployment (legal link optimization - SEO fixes integrated)
- Day 7: v49 emergency (migration complete replacement: delete new, copy old, delete old)
- Day 7: iOS v50 APPROVED by Apple
- Day 7: Strategic decision - deferred Play Integrity API + Safe URL fix to v1.4.5 post-launch

**Key Milestones**:

- Day 4: Testers Community generated Production and Feedback reports (10 days early)
- Days 8-13: v50 stability confirmed - 100% crash-free rate, zero errors on both platforms
- Day 10: Tester engagement stabilized at 12 continuous testers (50% retention = high quality)
- Day 10: Google Play privacy crisis resolved (home address verified per Civil ID)
- Day 13: Google Search Console HTTP→HTTPS redirect fixed
- Day 14: Production access application submitted and approved same day (<12 hours)
- Day 14: Android production release approved - both platforms ready
- Day 14: SMTP security hardening (migrated to Firebase Secret Manager)
- Day 15: 🎉 **PRODUCTION LAUNCH** - v1.4.4+50 LIVE on both App Store and Google Play

**Final Metrics**: 12 continuous testers × 10+ days, 100% crash-free rate on v50, 6 emergency updates demonstrating rapid iteration, coordinated dual-platform launch. Android's first Play Store release, iOS update from v1.3.4.

---

### Testers Community Report Analysis (January 10, 2026 - Day 6)

**Status**: ✅ **COMPLETE** - Reports used successfully for Day 14 production submission (January 20, 2026)

**Key Outcomes**:

- **Production Report**: 10-question pre-filled questionnaire used for Google Play production access form
- **Feedback Report**: Validation showed "no critical issues" and "exceptional performance across all devices"
- **Results**: Production access approved same day (<12 hours), coordinated launch Day 15
- **Tester Metrics**: 12 continuous testers for 10+ days, 100% crash-free rate on final build (v1.4.4+50)

**Enhancement Recommendations (all addressed)**:

1. ASO optimization - Deferred to post-launch with real user data
2. User onboarding - Already implemented (6-step intro guide)
3. Social login - On roadmap as Minor Feature #2 (v1.5.0+)

---

### Emergency Deployment #2 - Day 6 Data Safety Fix (January 12, 2026)

**Status**: ✅ **COMPLETE** - Migration data safety fix deployed in v1.4.4+46

**Critical Bug**: Smart bridge deleted old Firestore structure before copying data, risking user data loss.

**Two-Phase Fix Pattern**:

1. **Phase 1**: Copy all old medications to new structure with `SetOptions(merge: true)`
2. **Phase 2**: Delete old structure only after safe copy complete

**Key Lesson**: Always copy-then-delete in migrations, never delete-then-copy. Prevents data loss when users are on mixed app versions.

---

### Emergency Deployment #1 - Day 3 Crisis Response (January 7, 2026)

**Status**: ✅ **COMPLETE** - 6 critical crash fixes deployed in v1.4.4+44/+45 within 4 hours

**Crash Patterns Fixed**:

1. **Widget Lifecycle**: setState after disposal → Add `if (mounted)` checks before all setState calls
2. **Context Safety**: ScaffoldMessenger after navigation → Add `if (context.mounted)` checks before InheritedWidget access
3. **UI Constraints**: RenderFlex overflow with Arabic labels → Wrap dynamic text in `Flexible` with `TextOverflow.ellipsis`
4. **ProGuard**: R8 stripping notification icons → Add explicit keep rules for drawables referenced by string
5. **Firebase Auth**: SignInHubActivity crash → Configure SHA-1/SHA-256 certificates in Firebase Console
6. **iOS Symbolication**: 24 unprocessed crashes → Upload dSYM files + configure automatic upload in Xcode

**Key Lessons**:

- Always check widget/context validity before state changes (mounted checks critical for async callbacks)
- ProGuard requires explicit keep rules for resources referenced dynamically (keep.xml insufficient alone)
- Firebase Auth triggers Google Play Services checks even without explicit Google Sign-In implementation
- Emergency response demonstrates engineering maturity: 25 active testers, 6 crashes fixed in 4 hours

**Strategic Decision**: Skipped v43 entirely, deployed v44 emergency update Day 3 (10+ days before production deadline)

---

### Android 15 Edge-to-Edge Support + SHA Certificate Fix (January 8, 2026)

**Status**: ✅ **COMPLETE** - Both fixes applied and built in v1.4.4+45 (52MB AAB)

**Problem 1**: Google Play Console warnings for apps targeting SDK 35:

- "Edge-to-edge may not display for all users"
- "Your app uses deprecated APIs or parameters for edge-to-edge"

**Root Cause**: Android 15 (SDK 35) requires apps to explicitly handle edge-to-edge display. Flutter apps with minimal MainActivity don't enable this by default.

**Solution**: Updated MainActivity to enable edge-to-edge mode for backward compatibility.

**Problem 2**: SignInHubActivity crash in v1.4.4+44

- `RuntimeException: Unable to start activity SignInHubActivity: NullPointerException`
- Firebase Auth requires SHA-1/SHA-256 certificates even without Google Sign-In

**Solution**: Added SHA certificates to Firebase Console and updated google-services.json

**Implementation** (android/app/src/main/kotlin/com/mrhasak99/dawatime/MainActivity.kt):

```kotlin
class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        WindowCompat.setDecorFitsSystemWindows(window, false)
        super.onCreate(savedInstanceState)
    }
}
```

**Files Modified**:

- `android/app/src/main/kotlin/com/mrhasak99/dawatime/MainActivity.kt` - Added edge-to-edge support
- `android/app/google-services.json` - **UPDATED**: Downloaded from Firebase Console with SHA certificates configured
- `pubspec.yaml` - Version: 1.4.4+44 → 1.4.4+45
- `android/app/build.gradle.kts` - versionCode: 44 → 45

**Benefits**: Resolves Play Console SDK 35 warnings, fixes SignInHubActivity crash, proper edge-to-edge display on Android 15+ with backward compatibility.

**Known Limitation**: Google Play Console still shows deprecation warnings for Flutter framework's internal use of deprecated Android APIs (`setStatusBarColor`, `setNavigationBarColor`). This is a Flutter v3.38.6 framework limitation affecting all apps targeting SDK 35, not specific to DawaTime. App will NOT be rejected and users won't experience issues. Accept as informational warning until Flutter framework updates.

---

### iOS dSYM Automatic Upload Configuration (January 7, 2026)

**Status**: ✅ **COMPLETE** - Automatic symbolication configured

**Implementation**: Added Xcode build phase `[Firebase Crashlytics] Upload dSYM Files` that runs after each archive build, uploading dSYM files automatically to Firebase Crashlytics. Uploaded 43 dSYM files from v1.4.4+44 manually. All future releases will have automatic debug symbol uploads for readable crash stack traces.

**Configuration**: ios/Runner.xcodeproj/project.pbxproj build phase (ID: FB8A3C5D2A1E4F8B00C7D9E1) executes FirebaseCrashlytics upload-symbols script after "[CP] Copy Pods Resources".

---

### Website Emergency - Bad APK Deployment (December 16, 2025 - January 13, 2026)

**Status**: ✅ **RESOLVED** - Bad APK removed within hours of discovery

**Crisis**: Unfinished v1.4.4 build accidentally deployed to dawatime.com for 26 days (Dec 16 - Jan 11, 2026), exposed through holidays. Build contained bugs later fixed in v42→v50 emergency updates (6 critical crash fixes). Unknown download count during exposure period.

**Discovery**: Day 7 (Jan 13) - User disclosed accidental deployment when requesting APK removal for marketing. Git investigation (`git log -p -S"v1.4.4" -- public/index.html`) confirmed Dec 16 deployment.

**Emergency Response** (7 steps, same day):

1. Located APK download section in index.html
2. Replaced clickable download with disabled "Coming Soon" teaser (Google colors gradient)
3. Removed all APK-related content (safety card, translation strings, CSS)
4. Added dynamic App Store badge switching (English/Arabic)
5. Temporarily disabled Web App button
6. Deleted bad APK file and .DS_Store
7. Deployed cleaned website via Firebase Hosting

**Files Modified**: /public/index.html (button replacement, content cleanup, localization)
**Files Deleted**: dawatime-v1.4.4.apk (bad build), .DS_Store

**Key Lessons Learned**:

- **Build deployment verification critical**: Always verify correct build file before Firebase Hosting uploads
- **Git history investigation essential**: `git log -p -S` pattern identified 26-day exposure timeline when APK files excluded from git
- **Emergency disclosure importance**: User revealing true reason changed approach from "marketing cleanup" to "user safety emergency"
- **Rapid website cleanup advantage**: Website APK removal much faster than app store removal
- **Staging environment needed**: Consider separate staging site for testing deployments
- **User safety priority**: Emergency took precedence over celebrating v47 success
- **.gitignore limitation**: APK exclusion prevented tracking actual upload date, only HTML reference changes tracked

---

### Website SEO Optimization & Legal Link Cleanup (January 14, 2026 - Day 8)

**Status**: ✅ **COMPLETE** - Google Search Console issues resolved, in-app links optimized

**Crisis Discovery** (Day 8 Morning - January 14, 2026):

- Google Search Console showed 2 critical indexing issues:
  - "Duplicate without user-selected canonical" for support.html vs /support
  - "Duplicate without user-selected canonical" for privacy-policy.html vs /privacy-policy
- Root cause: Firebase Hosting serving both .html and clean URLs, confusing Google's indexing
- Impact: Search results showing wrong URLs, diluted page authority, suboptimal SEO

**SEO Fix Implementation** (Day 8 Morning - January 14, 2026):

1. **Canonical Tags Added** - All 6 HTML pages updated:

   ```html
   <!-- index.html -->
   <link rel="canonical" href="https://dawatime.com/" />

   <!-- support.html -->
   <link rel="canonical" href="https://dawatime.com/support" />

   <!-- privacy-policy.html -->
   <link rel="canonical" href="https://dawatime.com/privacy-policy" />

   <!-- terms-and-conditions.html -->
   <link rel="canonical" href="https://dawatime.com/terms-and-conditions" />

   <!-- account-deletion.html -->
   <link rel="canonical" href="https://dawatime.com/account-deletion" />

   <!-- user-management.html -->
   <link rel="canonical" href="https://dawatime.com/user-management" />
   ```

2. **sitemap.xml Created** - Proper XML sitemap structure:

   ```xml
   <?xml version="1.0" encoding="UTF-8"?>
   <urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
     <url>
       <loc>https://dawatime.com/</loc>
       <lastmod>2026-01-12</lastmod>
       <changefreq>monthly</changefreq>
       <priority>1.0</priority>
     </url>
     <url>
       <loc>https://dawatime.com/support</loc>
       <lastmod>2026-01-12</lastmod>
       <changefreq>monthly</changefreq>
       <priority>0.8</priority>
     </url>
     <!-- Additional 4 URLs with priorities 0.5-0.3 -->
   </urlset>
   ```

3. **robots.txt Created** - Search engine crawling instructions:

   ```
   User-agent: *
   Allow: /
   Disallow: /user-management

   Sitemap: https://dawatime.com/sitemap.xml
   ```

4. **Firebase Deployment**:
   - Command: `firebase deploy --only hosting`
   - Result: All SEO files live on production
   - URL redirects already configured (301 from .html to clean URLs)

**In-App Link Audit** (Day 8 Afternoon - January 14, 2026):

- Discovered all 14 legal document links using .html extensions
- Issue: Links worked but caused unnecessary 301 redirect step
- Impact: Slower page load, extra HTTP request, suboptimal user experience

**Legal Link Cleanup Implementation** (Day 8 Afternoon - January 14, 2026):

**Files Modified** (4 files, 14 link occurrences):

1. **main.dart** - 6 links updated:
   - Line 613: Force update dialog Privacy Policy button
   - Line 637: Force update dialog Terms & Conditions button
   - Line 1278: Legal update dialog Terms button
   - Line 1310: Legal update dialog Privacy button
   - Line 1498: Intro guide Terms link
   - Line 1512: Intro guide Privacy link

2. **settings.dart** - 2 links updated:
   - Line 326: Account deletion confirmation Privacy link
   - Line 354: Account deletion confirmation Terms link

3. **signup_page.dart** - 2 links updated:
   - Line 292: Signup checkbox Terms link
   - Line 347: Signup checkbox Privacy link

4. **login_page.dart** - 4 links updated:
   - Line 222: Legal update dialog Terms button
   - Line 246: Legal update dialog Privacy button
   - Line 870: Intro guide Terms link
   - Line 888: Intro guide Privacy link

**Link Pattern Change**:

```dart
// BEFORE (v1.4.4+49):
const url = 'https://dawatime.com/privacy-policy.html';
const url = 'https://dawatime.com/terms-and-conditions.html';

// AFTER (v1.4.4+50):
const url = 'https://dawatime.com/privacy-policy';
const url = 'https://dawatime.com/terms-and-conditions';
```

**Emergency v1.4.4+50 Deployment** (Day 8 Afternoon - January 14, 2026):

- Version incremented: 1.4.4+49 → 1.4.4+50
- Build artifacts:
  - Android AAB: 54.2MB (build time: 89.3s)
  - iOS IPA: 48.2MB (build time: 198.2s archive + 105.8s IPA)
- Uploaded to both platforms within 2 hours
- Android: LIVE in Closed Testing
- iOS: Waiting for Review in TestFlight

**Benefits**:

- ✅ **SEO**: Canonical tags tell Google which URL to index (clean URLs preferred)
- ✅ **Sitemap**: Helps Google discover and prioritize pages
- ✅ **Performance**: In-app links avoid redirect, load pages faster
- ✅ **Consistency**: All links point to canonical URLs
- ✅ **Indexing**: Google Search Console will recrawl and resolve duplicate issues (1-2 weeks)

**Files Created**:

- `/public/sitemap.xml` - XML sitemap with 6 pages
- `/public/robots.txt` - Search engine crawling instructions

**Files Updated**:

- `/public/index.html` - Canonical tag, improved meta description
- `/public/support.html` - Canonical tag
- `/public/privacy-policy.html` - Canonical tag
- `/public/terms-and-conditions.html` - Canonical tag
- `/public/account-deletion.html` - Canonical tag
- `/public/user-management.html` - Canonical tag
- `/lib/main.dart` - 6 legal links cleaned
- `/lib/settings.dart` - 2 legal links cleaned
- `/lib/signup_page.dart` - 2 legal links cleaned
- `/lib/login_page.dart` - 4 legal links cleaned
- `/pubspec.yaml` - Version 1.4.4+49 → 1.4.4+50
- `/android/app/build.gradle.kts` - versionCode 49 → 50

**Development Sequence** (Day 8 - January 14, 2026):

1. Google Search Console duplicate page issues discovered
2. Canonical tags implemented, sitemap/robots.txt created
3. Firebase deployment complete, SEO fixes live
4. In-app link audit revealed .html usage
5. All 14 links updated across 4 files
6. v1.4.4+50 builds created (Android AAB: 89.3s, iOS IPA: 304s)
7. Android v50 uploaded and LIVE in Closed Testing
8. iOS v50 upload in progress

**Result**: Google Search Console issues resolved (awaiting recrawl), in-app links optimized for performance, v1.4.4+50 deployment underway with Android live and iOS pending upload, production launch on track for Day 14 (January 18, 2026).

---

### Google Search Console HTTP Redirect Fix (January 19, 2026 - Day 13)

**Status**: ✅ **RESOLVED** - HTTP→HTTPS redirect deployed (February 17, 2026)

**Issues Discovered** (Day 13 - January 19, 2026):

1. **"Alternate page with proper canonical tag"** (https://www.dawatime.com/)
   - Status: ✅ **RESOLVED** (Day 29 - January 29, 2026) via Cloudflare Redirect Rule
   - Root Cause: Firebase Hosting custom domain configuration for www subdomain

2. **"Page with redirect"** (http://dawatime.com/)
   - Status: ✅ **RESOLVED** (February 17, 2026) - HTTP→HTTPS redirect deployed
   - Root Cause: Missing explicit HTTP→HTTPS redirect configuration in firebase.json (despite documentation stating it was added Day 13)

**Root Cause Analysis**:

- Firebase Hosting auto-redirects HTTP to HTTPS by default
- However, Google Search Console validation requires **explicit redirect configuration**
- Existing firebase.json only had www→non-www redirect, not HTTP→HTTPS
- Result: Validation failed despite redirect working in practice
- Documentation error: Day 13 docs stated redirect was added, but it was actually missing until Day 60

**Fix Implementation** (February 17, 2026):

Added explicit HTTP to HTTPS redirect rule to firebase.json:

```json
"redirects": [
  {
    "source": "http://dawatime.com{,/**}",
    "destination": "https://dawatime.com",
    "type": 301
  },
  {
    "source": "https://www.dawatime.com{,/**}",
    "destination": "https://dawatime.com",
    "type": 301
  },
  // ... other .html → clean URL redirects
]
```

**Deployment**:

```bash
firebase deploy --only hosting
```

Result: 20 files deployed successfully to Firebase Hosting

**Files Modified**:

- `/firebase.json` - Added HTTP→HTTPS redirect rule (February 17, 2026)

**Redirect Chain Now Complete**:

1. `http://dawatime.com{,/**}` → `https://dawatime.com` (ADDED Feb 17, 2026 - fixes validation)
2. `https://www.dawatime.com{,/**}` → `https://dawatime.com` (existing - resolved Jan 29 via Cloudflare)
3. `*.html` pages → clean URLs (existing - 5 redirect rules from Day 8)

**Verification** (February 17, 2026):

Test redirect chain manually:

```bash
# Test HTTP → HTTPS (should show 301)
curl -I http://dawatime.com
# Result: HTTP/1.1 301 Moved Permanently
# Location: https://dawatime.com/

# Test www → non-www (should show 301)
curl -I https://www.dawatime.com
# Result: HTTP/2 301
# Location: https://dawatime.com/
```

**Google Search Console Actions**:

1. **Issue 1** ("Alternate page with proper canonical tag") - ✅ **RESOLVED** (Jan 29 via Cloudflare):

   **Root Cause**: Firebase redirect rules only work for configured custom domains. When www.dawatime.com was configured as a separate custom domain, it served content directly (HTTP 200) instead of redirecting. Removing it from Firebase caused 404 errors.

   **Solution: Cloudflare Redirect Rules** (CDN-level redirect):

   Configuration at https://dash.cloudflare.com:
   - **Rule name**: "Redirect from WWW to root"
   - **Request URL**: `https://www.dawatime.com/*`
   - **Target URL**: `https://dawatime.com/${1}` (must include full domain)
   - **Status code**: 301
   - **DNS**: Enable Cloudflare proxy (orange cloud) on www CNAME record

   Verification:

   ```bash
   curl -I https://www.dawatime.com
   # Should return: HTTP/2 301, Location: https://dawatime.com/, server: cloudflare
   ```

2. **Issue 2** ("Page with redirect"):
   - ✅ **RESOLVED** - HTTP→HTTPS redirect validated successfully (February 17, 2026)
   - Final action: User must click "VALIDATE FIX" in Google Search Console

**Resolution Timeline**:

- **Day 13 (Jan 19)**: Issues discovered
- **Day 29 (Jan 29)**: WWW issue resolved via Cloudflare Redirect Rule
- **February 17, 2026**: HTTP→HTTPS redirect added to firebase.json and deployed

**Key Lesson**: Documentation stated HTTP→HTTPS redirect was added on Day 13, but code review revealed it was actually missing until February 17. Always verify code matches documentation, especially for critical SEO configurations.

**Benefits**:

- ✅ **SEO**: Proper redirect chain improves search ranking
- ✅ **Security**: Ensures all HTTP traffic redirects to HTTPS
- ✅ **Compliance**: Meets Google Search Console validation requirements
- ✅ **User Experience**: No broken links from HTTP URLs

**Additional Discovery - Unused Verification Tokens** (February 17, 2026):

During Google Search Console investigation, discovered 1 unused ownership token warning. Investigation revealed **TWO** redundant google-site-verification TXT records in Cloudflare DNS:

1. `google-site-verification=pSAXwvhRbk-CBVEUy_Z+H07-66QdiuJ_zhyTLaMfwc=`
2. `google-site-verification=6uJUUhL_R2zFcQVb3eH4muNi_nOeRCxXELQdJyPoS8k=`

**Current Verification Method**: Firebase Hosting automatic verification (most reliable, maintenance-free)

**Recommendation**: Delete BOTH TXT records from Cloudflare DNS - they are redundant and create unnecessary security surface. Firebase Hosting verification is active and sufficient.

**Manual Cleanup Steps**:

1. Login to Cloudflare Dashboard: https://dash.cloudflare.com
2. Select `dawatime.com` domain
3. Navigate to DNS → Records
4. Find both google-site-verification TXT records
5. Click Delete (trash icon) for each record
6. Verify: Google Search Console continues working (Firebase verification remains active)

---

### Google Search Console - "Page with redirect" Validation Failure (March 12, 2026)

**Status**: ✅ **COMPLETE** - sitemap and robots.txt fixed, deployed to Firebase Hosting

**Issue**: Google Search Console showed "Validation Failed - Page with redirect" for 2 URLs:
- `http://dawatime.com/` (last crawled Mar 4, 2026)
- `https://www.dawatime.com/` (last crawled Mar 2, 2026)

**Root Cause Analysis**:

These pages are **working correctly as 301 redirects** — they are supposed to redirect:
- `http://dawatime.com/` → `https://dawatime.com/` (via Cloudflare/Firebase)
- `https://www.dawatime.com/` → `https://dawatime.com/` (via Cloudflare Redirect Rule)

The "Validation Failed" status is **expected behavior** — redirect pages can never be indexed as standalone pages. Google's validation will always fail for redirect URLs because they are not indexable. The canonical `https://dawatime.com/` is correctly indexed.

**Key Insight**: The `http://dawatime.com{,/**}` redirect rule in `firebase.json` is dead code — Firebase Hosting only serves HTTPS, so this rule never fires at the Firebase level. The HTTP→HTTPS redirect is handled by Cloudflare infrastructure automatically. The rule is harmless but misleading.

**Fixes Applied (March 12, 2026)**:

1. **`/public/robots.txt`** — Added missing `Disallow: /user-management` rule (was documented as required since Day 8 but was absent from the file):
   ```
   User-agent: *
   Allow: /
   Disallow: /user-management

   Sitemap: https://dawatime.com/sitemap.xml
   ```

2. **`/public/sitemap.xml`** — Two changes:
   - Removed `/user-management` entry (Firebase Auth action handler page — password reset, email verification — not a public indexable page)
   - Updated `lastmod` to `2026-03-12` for homepage (`/`) and support page (`/support`)

3. **Deployment**: `firebase deploy --only hosting:main` — 20 files deployed successfully ✅

**What NOT to do**: Do not attempt to "fix" the redirect validation in Google Search Console by clicking "Start New Validation" — redirect pages will always fail indexing validation. These URLs are correctly redirecting and should remain as-is.

**DNS**: Cloudflare DNS remains as-is. The `www` redirect is handled by the Cloudflare Redirect Rule (configured January 29, 2026). No DNS changes needed.

**Files Modified**:
- `/public/robots.txt` — Added `Disallow: /user-management`
- `/public/sitemap.xml` — Removed `/user-management`, updated lastmod dates

---

### Legal Document Webpages & App Integration (December 2025)

**Status**: ✅ **COMPLETE** - Dedicated legal document pages created and integrated into app

**Problem**: App had inline text-only legal documents in dialogs with no way to update content without app releases. Users couldn't easily review documents or see version history.

**Solution**: Created dedicated bilingual webpages for Terms & Conditions and Privacy Policy with version tracking system.

**Website Implementation**:

1. **Created Legal Document Pages**:
   - `/public/terms-and-conditions.html` - Full Terms & Conditions with English/Arabic
   - `/public/privacy-policy.html` - Full Privacy Policy with English/Arabic
   - Both pages use `.en-content`/`.ar-content` class-based translation pattern
   - Fully responsive design with theme support (light/dark mode)
   - Professional legal document formatting with sections, subsections, and highlights

2. **Firebase Hosting Rewrites** (firebase.json):
   **All website pages** configured with clean URLs (no `.html` extensions):

   ```json
   "rewrites": [
     {"source": "/account-deletion", "destination": "/account-deletion.html"},
     {"source": "/user-management", "destination": "/user-management.html"},
     {"source": "/support", "destination": "/support.html"},
     {"source": "/privacy-policy", "destination": "/privacy-policy.html"},
     {"source": "/terms-and-conditions", "destination": "/terms-and-conditions.html"},
     {"source": "/", "destination": "/index.html"}
   ]
   ```

   - **Clean URL Pattern**: All 6 pages accessible without `.html` extension
   - **301 Redirects**: Configured from `.html` URLs to clean URLs for SEO
   - **Examples**:
     - `https://dawatime.com/terms-and-conditions` (not `/terms-and-conditions.html`)
     - `https://dawatime.com/support` (not `/support.html`)
     - `https://dawatime.com/account-deletion` (not `/account-deletion.html`)

3. **Version Tracking System** (Firestore):
   - Created `/AppConfig/LegalDocuments` collection with fields:
     - `termsVersion`: "1.0" (current Terms version)
     - `privacyVersion`: "1.0" (current Privacy version)
     - `lastUpdated`: ISO date string
   - Enables version checking without hardcoded values in app

**App Integration**:

1. **User Document Tracking** (Firestore `/Users/{uid}` collection):
   - `acceptedTermsVersion`: "1.0" (version user accepted)
   - `acceptedPrivacyVersion`: "1.0" (version user accepted)
   - `legalAcceptanceDate`: ISO timestamp
   - Set automatically during signup by fetching current versions from Firestore

2. **Signup Flow Updates** (signup_page.dart):
   - Checkbox validation for T&C and Privacy Policy acceptance
   - Links open webpages in browser: `https://dawatime.com/terms-and-conditions`
   - On successful signup, fetches current versions from `/AppConfig/LegalDocuments`
   - Stores accepted versions in user profile (no hardcoded version numbers)

3. **Legal Update Detection System**:
   - **Dual Entry Point Architecture** (see separate section below):
     - Entry Point 1: Login page checks after authentication
     - Entry Point 2: App startup checks for existing sessions
   - Compares user's `acceptedTermsVersion`/`acceptedPrivacyVersion` with current versions
   - If mismatch → Shows non-dismissible dialog requiring acceptance
   - User accepts → Updates Firestore with new versions and current timestamp
   - User declines → Signs out (on login) or blocked from app (on startup)

4. **Settings Page Links** (settings.dart):
   - Privacy Policy button: Opens `https://dawatime.com/privacy-policy` in browser
   - Terms & Conditions button: Opens `https://dawatime.com/terms-and-conditions` in browser
   - Users can review documents anytime without being forced to accept

5. **Support Page Links** (support.html):
   - Both "View Online" and "PDF" links for each document
   - PDF versions generated from webpages for offline access

**Benefits**:

- ✅ **Update documents without app releases**: Change webpage content anytime
- ✅ **Version tracking**: Increment version in Firestore, app detects automatically
- ✅ **User consent tracking**: Know exactly which version each user accepted
- ✅ **Audit trail**: `legalAcceptanceDate` provides timestamp of acceptance
- ✅ **Bilingual support**: Full English/Arabic translations with theme support
- ✅ **Professional presentation**: Proper legal document formatting and styling
- ✅ **Always accessible**: Users can review documents anytime via Settings or website

**Files Created**:

- `/public/terms-and-conditions.html` - Full T&C page with bilingual content
- `/public/privacy-policy.html` - Full Privacy Policy page with bilingual content

**Files Updated**:

- `/firebase.json` - Added URL rewrites for clean paths
- `/lib/signup_page.dart` - Checkbox validation, Firestore version fetch, link integration
- `/lib/settings.dart` - Added legal document links to settings page
- `/lib/main.dart` - Legal version check on app startup (AuthGate)
- `/lib/login_page.dart` - Legal version check after login
- `/firestore.rules` - Public read access to `/AppConfig` for version fetching

**Version Update Process**:

1. Update content in `/public/terms-and-conditions.html` or `/public/privacy-policy.html`
2. Deploy website: `firebase deploy --only hosting`
3. Update version in Firestore `/AppConfig/LegalDocuments`:
   - Increment `termsVersion` to "1.1" (or `privacyVersion`)
   - Update `lastUpdated` timestamp
4. Next time users open app, they'll be prompted to accept new version
5. User acceptance tracked automatically in their profile

---

### Legal Document Page Enhancements (Late January - Early February 2026)

**Status**: ✅ **COMPLETE** - Trust Box, Safety Box, and FOUC prevention implemented

**Context**: After creating the dedicated legal document webpages in December 2025, additional enhancements were made to improve user trust, visual design, and performance.

#### Trust Box - Privacy Policy (Commands 34-44)

**Purpose**: Build user confidence by highlighting DawaTime's privacy commitments with a prominent, friendly callout box.

**Design**:

- **Color Theme**: Green (#8ac249) matching DawaTime brand
- **Icon**: Material Design checkmark SVG (circle background with white checkmark)
- **Style**: Outlined container with gradient background, rounded corners (12px)
- **Position**: After main "Privacy Policy" heading, before document sections
- **Tone**: Doctor-to-patient (empathetic, reassuring, professional)

**Content** (Bilingual - English/Arabic):

1. **Transparency**: "We explain in plain language what data we collect and why"
2. **Security**: "Your medication information is encrypted and protected"
3. **Control**: "You can delete your data anytime from Settings"

**Implementation** (~65 lines):

```html
<div class="trust-box">
  <div class="trust-icon">
    <svg><!-- Checkmark icon --></svg>
  </div>
  <div class="trust-content">
    <h3 class="en-content">Your Privacy Matters</h3>
    <h3 class="ar-content">خصوصيتك تهمّنا</h3>
    <ul class="trust-list">
      <li class="en-content">
        <svg class="checkmark-icon">...</svg>
        <span
          ><strong>Transparency:</strong> We explain in plain language...</span
        >
      </li>
      <!-- 2 more bullets -->
    </ul>
  </div>
</div>
```

**Styling**:

- Flexbox layout (icon left, content right)
- SVG checkmark bullets (green, 16px, inline with text)
- Responsive design (stacks on mobile)
- Theme-aware (adapts to light/dark mode)

#### Safety Box - Terms & Conditions (Commands 46-48)

**Purpose**: Set proper expectations about DawaTime's role as a medication reminder tool (not medical advice) with a clear, non-scary warning callout.

**Design**:

- **Color Theme**: Amber/orange (#FFA726) for professional warning tone
- **Icon**: Material Design shield SVG (protection symbolism)
- **Style**: Outlined container with gradient background, rounded corners (12px)
- **Position**: After main "Terms & Conditions" heading, before document sections
- **Tone**: Professional warning (helpful, not scary, legally clear)

**Content** (Bilingual - English/Arabic):

1. **Medical Disclaimer**: "DawaTime is a reminder tool, not a replacement for professional medical advice"
2. **User Responsibility**: "Always consult your doctor about medication changes or concerns"
3. **Liability**: "We provide the app 'as-is' and aren't liable for medical decisions"

**Implementation** (~108 lines):

```html
<div class="safety-box">
  <div class="safety-icon">
    <svg><!-- Shield icon --></svg>
  </div>
  <div class="safety-content">
    <h3 class="en-content">Important Safety Information</h3>
    <h3 class="ar-content">معلومات السلامة المهمّة</h3>
    <ul class="safety-list">
      <li class="en-content">
        <svg class="checkmark-icon amber">...</svg>
        <span
          ><strong>Medical Disclaimer:</strong> DawaTime is a reminder
          tool...</span
        >
      </li>
      <!-- 2 more bullets -->
    </ul>
  </div>
</div>
```

**Styling**:

- Identical structure to Trust Box (consistent design pattern)
- Amber checkmark bullets instead of green
- Amber border and gradient (warning color psychology)
- Same responsive behavior and theme adaptation

**Design Refinement (Command 48)**:

- **Original**: Warning emoji (⚠️) for bullets
- **Problem**: Emoji rendering inconsistent across browsers/devices, accessibility concerns
- **Solution**: Replaced with amber SVG checkmark (same as Privacy Policy but amber instead of green)
- **Benefit**: Consistent vector rendering, theme-aware, WCAG compliant

#### Design System Pattern

**Consistent Architecture** (Both Callout Boxes):

- **Container**: Flexbox with icon + content areas
- **Icon**: SVG in circular background (40px circle, 24px icon)
- **Bullets**: SVG checkmarks (16px, colored to match theme)
- **Typography**: Bold labels with regular explanatory text
- **Responsive**: Flexbox wraps to column on mobile (<600px)
- **Theming**: CSS custom properties for light/dark mode adaptation
- **Gradients**: Subtle background gradients (5% opacity variation)

**Color Psychology**:

- **Green (Privacy Policy)**: Trust, safety, health (positive reinforcement)
- **Amber (Terms & Conditions)**: Caution, attention, professionalism (appropriate warning)

**Why Two Different Callouts**: Privacy Policy (reassurance, building confidence), Terms & Conditions (awareness, setting expectations), different purposes require different tones/colors but unified design system structure.

#### FOUC Prevention System (Commands 49-50)

**Status**: ✅ **COMPLETE** - Blocking inline scripts prevent Flash of Unstyled Content

**Problem**: Flash of Unstyled Content when users return to legal pages with saved theme/language preferences.

**User Experience Issue**:

1. User selects dark theme → localStorage saves `theme: 'dark'`
2. User refreshes page → HTML loads with light default → CSS applies → JavaScript runs → theme switches
3. **Visible flash**: Light background → Dark background (100-500ms delay)
4. Same issue with language: English → Arabic causes layout shift (LTR → RTL)

**Solution**: Blocking inline `<script>` in `<head>` that reads localStorage BEFORE CSS loads.

**Implementation** (~25 lines per page):

```html
<head>
  <link rel="icon" type="image/png" href="DawaTime.png" />

  <!-- Critical: Apply theme/language BEFORE page renders to prevent FOUC -->
  <script>
    (function () {
      // Apply theme immediately
      const savedTheme = localStorage.getItem("theme") || "system";
      const html = document.documentElement;

      if (savedTheme === "dark") {
        html.setAttribute("data-theme", "dark");
      } else if (savedTheme === "system") {
        // Check system preference
        const prefersDark = window.matchMedia(
          "(prefers-color-scheme: dark)",
        ).matches;
        if (prefersDark) {
          html.setAttribute("data-theme", "dark");
        }
      }

      // Apply language immediately
      const savedLang = localStorage.getItem("language") || "en";
      if (savedLang === "ar") {
        html.setAttribute("lang", "ar");
        html.setAttribute("dir", "rtl");
      }
    })();
  </script>

  <style>
    ...
  </style>
</head>
```

**Why This Works**:

1. Browser parses `<head>` sequentially (top to bottom)
2. Inline `<script>` executes immediately (blocking execution)
3. localStorage read + HTML attribute set (~1-2ms)
4. `<style>` tag parsed next
5. CSS sees `[data-theme="dark"]` and `[lang="ar"]` already applied
6. First paint renders with correct theme/language
7. **No flash, no layout shift** ✅

**Code Architecture Decision**:

- **Critical Path** (inline `<head>` script): HTML attribute setting only, runs before CSS
- **Interactive Path** (external shared-toggles.js): DOM manipulation, UI updates, event handlers

**Why Split**: Full `initTheme()`/`initLanguage()` functions manipulate DOM (doesn't exist during `<head>` parsing), so minimal inline script handles only HTML attributes, keeping external JavaScript for interactive features (toggle buttons, user actions).

**Performance Trade-off**:

- **Cost**: ~1-2ms blocking execution in `<head>`
- **Benefit**: Eliminates 100-500ms visible FOUC
- **Net**: Improved perceived performance and UX

**Files Modified**:

- `/public/terms-and-conditions.html` (lines 10-36: added blocking script)
- `/public/privacy-policy.html` (lines 8-34: added blocking script)

**Industry Pattern**: This is a standard technique used for dark mode, internationalization, A/B testing, and any feature requiring instant state restoration before first paint.

#### Summary of Enhancements

**Privacy Policy Total Additions**: ~90 lines

- Trust Box: ~65 lines
- FOUC Prevention: ~25 lines

**Terms & Conditions Total Additions**: ~133 lines

- Safety Box: ~108 lines
- FOUC Prevention: ~25 lines

**Design System**: Consistent callout box pattern (Trust Box + Safety Box) with color-coded themes

**Performance**: Blocking script eliminates FOUC (<2ms cost, 100-500ms benefit)

**User Trust**: Professional presentation of legal commitments and medical disclaimers

**Timeline**: Late January - Early February 2026 (Commands 34-50 across multiple sessions)

---

### Documentation Enhancement - Firebase Hosting Clean URLs (January 5, 2026)

**Status**: ✅ **COMPLETE** - Clarified that all website pages use clean URLs without `.html` extensions

**Update**: Enhanced the "Legal Document Webpages & App Integration" section to document comprehensive URL rewriting system.

**Firebase Hosting Configuration** (firebase.json):

- **All 6 website pages** configured with clean URLs:
  - `/account-deletion` → `account-deletion.html`
  - `/user-management` → `user-management.html`
  - `/support` → `support.html`
  - `/privacy-policy` → `privacy-policy.html`
  - `/terms-and-conditions` → `terms-and-conditions.html`
  - `/` → `index.html`
- **301 Redirects**: Configured from `.html` URLs to clean URLs for SEO benefits
- **User Experience**: All pages accessible without file extensions (e.g., `https://dawatime.com/support`)

**Documentation Changes**:

- Expanded Firebase Hosting Rewrites section from 2 example pages to complete list of 6 pages
- Added redirect configuration documentation (301 redirects from `.html` to clean URLs)
- Included URL examples showing proper usage pattern

**Files Updated**:

- `/.github/copilot-instructions.md` - Enhanced legal documents section with comprehensive URL rewriting documentation

**Version Tracking**:

- pubspec.yaml: 1.4.4+41 → 1.4.4+42
- android/app/build.gradle.kts: versionCode 41 → 42

---

### Pre-Deployment Review & Dependency Analysis (January 5, 2026)

**Status**: ✅ **COMPLETE** - All platforms ready for deployment (v1.4.4+42). Code quality: 0 errors/warnings. Configuration: Android SDK 35, iOS 15.0+, Firebase secured, 100% localization coverage. Deferred 3 major dependency updates (package_info_plus, android_intent_plus, flutter_timezone) requiring build tool upgrades to post-production. Current versions stable with no critical patches. Strategy: Deploy stable, monitor 1-2 weeks, then update incrementally.

---

### Website Toggle System Centralization (January 5, 2026)

**Status**: ✅ **COMPLETE** - Created shared-toggles.css (134 lines) and shared-toggles.js (210 lines) with IIFE pattern. Eliminated ~600 lines of duplicate toggle code across 6 website pages (70% reduction). Fixed conflicting variables, icon colors, CSS variables, and cache-busting. Supports 3 translation patterns: class-based, attribute-based, object-based. Single source of truth for theme/language toggles.

---

### Localization Cleanup (January 4, 2026)

**Status**: ✅ **COMPLETE** - Translation files cleaned and optimized

**Work Performed**:

- Analyzed all 161 translation keys in app_en.arb and app_ar.arb
- Identified truly unused translations after comprehensive codebase scan
- Removed 12 genuinely unused translation keys from both English and Arabic files
- Added 7 missing Arabic translations that were present in English but not translated
- All Flutter analyzer errors resolved (0 errors)
- All localization warnings resolved (0 untranslated messages)

**Removed Unused Keys (12 total)**:

- `contactMeTitle` - Duplicate/unused contact form title
- `contactMeSent` - Unused success message variant
- `contactMeFailed` - Duplicate error message (using `messageFailed` instead)
- `refillReminderDay` - Old refill reminder setting (feature was redesigned)
- `refillReminderTime` - Old refill reminder setting (feature was redesigned)
- `lightTheme` - Using `light` instead
- `darkTheme` - Using `dark` instead
- `error` - Generic unused error label
- `medications` - Unused plural label
- `newUpdateAvailable` - Unused update notification title
- `updateAvailableBody` - Unused update notification body
- `mustAcceptLegalUpdates` - Unused legal dialog message

**Added Missing Arabic Translations (7 total)**:

- `noUser` → "لا يوجد مستخدم مسجل الدخول حالياً"
- `enterPasswordTwice` → "يرجى إدخال كلمة المرور مرتين."
- `delete` → "امسح"
- `noUserEmail` → "لا يوجد بريد إلكتروني للمستخدم"
- `accountDeletedSuccess` → "تم مسح الحساب بنجاح"
- `mustBeLoggedIn` → "يجب أن تكون مسجلاً للدخول لإرسال رسالة"
- `messageSent` → "تم إرسال الرسالة بنجاح!"

**Files Updated**:

- `/lib/l10n/app_en.arb` - Removed 12 unused keys
- `/lib/l10n/app_ar.arb` - Removed 12 unused keys, added 7 missing translations
- `/pubspec.yaml` - Version: 1.4.4+40 → 1.4.4+41
- `/android/app/build.gradle.kts` - versionCode: 40 → 41

**Result**: Cleaner, more maintainable localization files with complete Arabic translations. Translation file sizes optimized while maintaining all actively-used strings.

---

### Google Play Store Distribution Attempt (January 5, 2026)

**Status**: 🔄 **IN PROGRESS** - First attempt at Google Play Console distribution

**Context**: After previous inability to distribute on Google Play Store due to personal developer account restrictions for health/medical apps, reattempting distribution via Google Play Console with proper category and data safety declarations.

**Distribution History**:

- **iOS**: Successfully distributed via Apple App Store since August 2025
- **Android (Previous)**: Website-only distribution (https://dawatime.com) since October 2025
- **Android (Current)**: Attempting Google Play Console Internal Testing track

**Play Console Setup - First Attempt (January 5, 2026) - REJECTED**:

1. **Health Apps Declaration**: Selected "Medication and treatment management" ❌ **THIS CAUSED REJECTION**
2. **Data Safety Form**: Declared data collection accurately:
   - Location: Approximate (for country restrictions)
   - Personal info: Name, Email, User IDs
   - Messages: Emails (contact form)
   - App activity: Interactions, User-generated content (medication data)
   - App info: Crash logs, Diagnostics, Performance (Firebase)
   - ❌ Health info: NOT checked (critical - medication names are user-entered text, not health sensor data)
3. **Authentication**: Username and password
4. **Account Deletion**: https://dawatime.com/account-deletion
5. **Data Encryption**: Yes (Firebase HTTPS/SSL)

**REJECTION REASON (January 5, 2026)**:
"Violation of Play Console Requirements - Some types of apps can only be distributed by organizations. You have selected an app category or declared your app offers certain features that require you to submit your app using an organization account."

**Root Cause**: Selecting ANY option in the "Health apps" section (even "Medication and treatment management") triggers organization account requirement for new developer accounts (policy change August 31, 2024).

**Corrective Action Taken (January 5, 2026)**:

1. ✅ **Unchecked all health app features** - Left entire "Health apps" section empty, checked "Other"
2. ✅ Framed app as "reminder/scheduling tool" NOT "medication management"
3. ✅ Category: "Health & Fitness" (safe for personal accounts)
4. ✅ Short Description: Removed "Free!" (violates promotion keywords policy)
5. ✅ Data Safety: Corrected "App interactions" and "User-generated content" to "Required"
6. ✅ Target Age: Selected 13-15, 16-17, 18+ (Teen 13+)
7. ✅ Advertising ID: Declared for Analytics only (Firebase)

**Result**: App status changed from "Rejected" → "Ready to publish" → Published to Open Testing

**Developer Address Verification (January 16, 2026) - Day 12**:

**Privacy Challenge**: Google Play requires legal name + home address verification matching Civil ID for production release.

**Issue**: Developer home address will be publicly visible on Play Store listing.

**Attempted Solutions** (All Failed):

- Attempted vague/partial address → Rejected (must match Civil ID exactly)
- Cannot register business → Kuwait government employees (MEW) prohibited from commercial business registration
- Cannot update Civil ID address → Would require family member's address or virtual office rental + Civil ID update (2-4 week delay)
- iOS-only production launch → Rejected by developer, proceeding with dual platform strategy

**Decision Made (Day 12)**: Proceed with home address exposure for Day 14 production launch

- **Address Visible**: 1/101/55, Kuwait City 15300, Kuwait (updated Jan 16, 2026)
- **Previous Address**: Shuhada Bt S101 H55, Kuwait City 47781, Kuwait (rejected, did not match Civil ID)
- **Rationale**: Temporary solution until potential career change from MEW allows business registration
- **Alternative Path**: When developer leaves MEW employment, can register business and update Google Play address

**Long-term Solution**: Business registration at Kuwait Chamber of Commerce after leaving government employment, then update developer address in Play Console (no app resubmission required).

---

### Google Play Store Beta Testing via Testers Community (January 5, 2026)

**Status**: ✅ **LIVE** - Closed Testing track active with community testers

**Setup Process**:

1. **Testing Track**: Switched from Internal Testing → Closed Testing for Testers Community compatibility
2. **Testing URL**: `https://play.google.com/apps/testing/com.mrhasak99.dawatime`
3. **Testers Community Campaign**: Created at https://www.testerscommunity.com
4. **Release Notes**: Shortened to ~420 characters highlighting key features
5. **Testing Instructions**: Provided clear signup/test workflow (no test credentials needed)

**Testing Instructions Provided**:

```
No test credentials needed - create your own account to test.
1. Sign Up with any email/password
2. Verify email (check inbox)
3. Add test medication (tap "+")
4. Set reminder 2-3 minutes ahead
5. Test swipe gestures, themes, Arabic language

Android 13+: Allow "Exact alarms" in system settings
Report issues via Settings → Contact Me
```

**Closed Testing Configuration**:

- **Track**: Closed Testing (Active - 2 tracks)
- **Release**: v1.4.4 (Build 42)
- **AAB Size**: 54.1MB
- **Target**: Android 7.0+ (API 24-35)
- **Testing Platform**: Testers Community (professional beta testers)
- **Feedback Collection**: In-app contact form + Testers Community platform

**Metadata Finalized**:

- **App Name**: DawaTime
- **Category**: Health & Fitness
- **Short Description**: "Never miss a dose. Smart medication reminders with refill tracking." (73 chars)
- **Full Description**: Bilingual description emphasizing 5 follow-ups, refill tracking, Arabic support
- **Target Age**: 13+ (Teen)
- **Content Rating**: TBD (awaiting IARC questionnaire)
- **Release Notes**:
  - **Android**: Blank (first production release on Google Play - v1.0 moment)
  - **iOS**: Full release notes as usual (update from v1.3.4 → v1.4.4)
- **Play Store Listing**: Verified via internal testing access (Day 8)

**Files Deployed**:

- `/build/app/outputs/bundle/release/app-release.aab` - Closed Testing track (54.1MB)

**Testers Community Requirements for Production Access**:

**Timeline**: 16-day testing period (January 5-21, 2026)

**Reports Generated** (Day 6 - January 10, 2026):

- **Feedback Report**: https://storage.googleapis.com/testing-community-ec6g1l.appspot.com/reports/com.mrhasak99.dawatime_feedback.pdf
  - Contains tester feedback, ratings, comments, testing experience data
- **Production Report**: https://storage.googleapis.com/testing-community-ec6g1l.appspot.com/reports/com.mrhasak99.dawatime_production.pdf
  - Pre-filled data for Google Play's production access form
  - Use on Day 14 when submitting to production track

**Critical Requirements**:

1. **Release 2-3 App Updates** (Days 1-16): ✅ **COMPLETE**
   - v1.4.4+42 (Day 1) → v1.4.4+44 (Day 3) → v1.4.4+45 (Day 4)
   - **2 updates deployed**: Emergency crash fixes demonstrating active development
   - Requirement satisfied on Day 4 (rapid iteration shows engineering maturity)

2. **Production Access Form Report** (Day 14+): ✅ **AVAILABLE**
   - Generated Day 6 (8 days early): https://storage.googleapis.com/testing-community-ec6g1l.appspot.com/reports/com.mrhasak99.dawatime_production.pdf
   - Feedback Report also available: https://storage.googleapis.com/testing-community-ec6g1l.appspot.com/reports/com.mrhasak99.dawatime_feedback.pdf
   - Use pre-filled answers when completing Google Play's production access form on Day 14
   - Required for production release approval

3. **Submit for Production** (Day 14): ⏳ **PENDING**
   - **Critical timing**: Submit to Production track once app crosses 14 days
   - Testers will begin uninstalling after Day 14
   - Continue testing until Day 16, but production submission must happen at Day 14

**Action Plan** (REVISED - Post-Report Analysis):

- **Days 1-4** (Jan 7-10): ✅ Initial release + 2 emergency updates deployed (update requirement COMPLETE)
- **Days 5-6** (Jan 11-12): ✅ iOS v47, v49, v50 uploads + report analysis complete
  - ✅ iOS v1.4.4+46 uploaded to TestFlight ("Waiting for Review")
  - ✅ Production Report analyzed (5 pages, pre-filled questionnaire answers)
  - ✅ Feedback Report analyzed (6 pages, exceptional performance, no critical issues)
  - ✅ Customized answers prepared for Questions 4 and 8
  - ✅ Production readiness confirmed - app is ready for Day 14 submission
- **Day 5** (Jan 11): ✅ Emergency migration fix + website cleanup
  - ✅ v1.4.4+49 deployed with three-phase complete replacement
  - ✅ Bad APK removed from website (exposed 26 days)
  - ✅ Migration duplicate prevention verified
- **Day 6** (Jan 12): ✅ Website SEO + legal link optimization
  - ✅ Google Search Console issues resolved (canonical tags added)
  - ✅ sitemap.xml and robots.txt created and deployed
  - ✅ All 14 in-app legal links updated (4 files modified)
  - ✅ v1.4.4+50 deployed to both platforms
  - ✅ Android v50 LIVE in Closed Testing (25 testers)
  - ✅ iOS v50 uploaded to TestFlight ("Waiting for Review")
- **Days 7-13** (Jan 13-19): Monitor v1.4.4+50 stability, await iOS v50 approval
  - Android v50 LIVE - monitor Crashlytics and tester feedback
  - iOS v50 approved Jan 13 (Day 7) (TestFlight Beta Review 1-3 days)
  - Google Search Console recrawl in progress (1-2 weeks)
  - Instagram marketing post published Day 9 (Jan 15)
- **Day 14** (Jan 20): ✅ Production access application submitted and approved
  - Used Production Report pre-filled answers (customized Q4 and Q8)
  - Referenced Feedback Report showing "exceptional performance, no critical issues"
  - Both platforms approved and ready for coordinated launch
- **Day 15** (Jan 21): 🎉 **PRODUCTION LAUNCH SUCCESS**
  - Published iOS v1.4.4+50 to App Store - LIVE in production (update from v1.3.4)
  - Published Android v1.4.4+50 to Google Play Store - LIVE in production (first Play Store release)
  - Coordinated v1.4.4 release - Android Play Store debut, iOS update (iOS in production since August 2025)
- **Days 16-20** (Jan 22-26): Post-launch monitoring and v1.4.5 hotfix preparation

**Post-Launch Tasks**:

- Monitor production metrics via Firebase Crashlytics, App Store Connect, Play Console
- Track crash-free rate, user ratings, reviews, and feedback
- Post Instagram Phase 3 announcement with both store links
- Prepare v1.4.5 hotfix (Play Integrity API + Safe URL Launching + Update Checker bug fix + Signup Buttons Android fix)
- Continue marketing efforts and user engagement

**App Bundle Build**:

- **File**: `build/app/outputs/bundle/release/app-release.aab`
- **Size**: 54.2MB
- **Version**: 1.4.4 (Build 50)
- **Target SDK**: Android 35 (Google Play requirement)
- **Build Time**: 89.3s
- **Optimizations**: ProGuard enabled, resource shrinking active

**App Store Metadata Prepared**:

- **Description**: Enhanced bilingual description emphasizing 5 follow-up reminders, refill tracking, Arabic support
- **Short Description**: "Never miss a dose. Smart medication reminders with refill tracking. Free!"
- **Keywords** (98 chars): `pill,reminder,medication,medicine,tracker,refill,dose,prescription,vitamin,alarm,alert,schedule,rx`
- **Keywords (Arabic)** (98 chars): `دواء,حبوب,تذكير,أدوية,منبه,جرعات,صحة,جدول,تنبيه,مخزون,تنظيم,منظم,مزمن,كبار,سكري,ضغط,وصفة,فيتامينات`
- **Category**: Health & Fitness (NOT Medical - avoids organization account requirement)
- **Slogan**: "Never miss a dose. | لا تفوّت جرعة بعد اليوم"

**Full App Description (English)**:

```
Never miss a dose.

DawaTime is your personal medication assistant, combining persistent reminders with smart inventory tracking. Simple enough for the elderly, powerful enough for complex treatments.

WHY CHOOSE DAWATIME?

UNBEATABLE REMINDERS
Unlike standard alarms, DawaTime sends 5 follow-up notifications (every 30 mins) until you confirm the dose—even when the app is closed. We make sure the medication gets taken.

SMART REFILL TRACKING
• Visual Dashboard: See stock levels via color-coded cards (Green/Orange/Red).
• Auto-Tracking: Automatically deducts pills or ml when marked as taken.
• Refill Alerts: Get weekly notifications when you hit your custom low-stock threshold.

TRULY BILINGUAL
Full support for English and Arabic. The interface adapts perfectly to Arabic (RTL), making it ideal for local communities and elderly family members.

FLEXIBLE & POWERFUL
• Custom Cycles: Set schedules for "Every X Days" or specific weekdays (e.g., Mon/Thu).
• Capacity: Manage up to 12 active medications.
• Themes: Full Dark Mode and Light Mode support.
• Easy Edits: Swipe gestures to manage your list quickly.

From antibiotics to chronic care, DawaTime takes the stress out of medication management.

Download now—completely free—and experience the smartest way to track your health.
```

**Full App Description (Arabic)**:

```
لا تفوّت جرعة دواء بعد اليوم.

"دواء تايم" (DawaTime) هو مساعدك الشخصي لتنظيم الأدوية، حيث يجمع بين التنبيهات المستمرة والتتبع الذكي للمخزون. التطبيق بسيط بما يكفي لكبار السن، وقوي بما يكفي للخطط العلاجية المعقدة.

لماذا تختار "دواء تايم"؟

تنبيهات لا مثيل لها
بخلاف التنبيهات القياسية، يرسل "دواء تايم" 5 إشعارات متابعة (كل 30 دقيقة) حتى تؤكد تناول الجرعة—حتى عندما يكون التطبيق مغلقاً. نحن نضمن تناول الدواء.

تتبع ذكي لإعادة التعبئة
• لوحة تحكم بصرية: شاهد مستويات المخزون عبر بطاقات ملونة (أخضر/برتقالي/أحمر).
• تتبع تلقائي: يخصم الحبوب أو المليلترات تلقائياً عند تحديد الجرعة كأنها "تم تناولها".
• تنبيهات إعادة التعبئة: احصل على إشعارات أسبوعية عندما يصل مخزونك إلى الحد الأدنى المخصص.

ثنائي اللغة بالكامل
دعم كامل للغتين الإنجليزية والعربية. تتكيف الواجهة تماماً مع اللغة العربية (من اليمين إلى اليسار)، مما يجعلها مثالية للمجتمعات المحلية وأفراد الأسرة من كبار السن.

مرن وقوي
• دورات مخصصة: اضبط جداول زمنية لـ "كل X يوم" أو أيام محددة من الأسبوع (مثل الاثنين/الخميس).
• السعة: إدارة ما يصل إلى 12 نوعاً من الأدوية النشطة.
• السمات: دعم كامل للوضع الداكن والوضع الفاتح.
• تعديلات سهلة: إيماءات السحب لإدارة قائمتك بسرعة.

من المضادات الحيوية إلى الرعاية المزمنة، يزيل "دواء تايم" التوتر من إدارة الأدوية.

حمّل الآن — مجاناً بالكامل — واختبر الطريقة الأذكى لتتبع صحتك.
```

**Release Notes** (Internal Testing):
First internal testing release of DawaTime on Google Play Console. Core features: medication reminders with 5 follow-ups, refill tracking, bilingual support (English/Arabic), dark mode, swipe gestures.

**Risk Mitigation**:

- Avoided "Medical" category (triggers organization requirements)
- Did NOT check "Health info" in data safety (medication names = user content, not health sensor data)
- Properly declared as "Medication and treatment management" (consumer tool, not clinical)
- All permissions (notifications, exact alarms) are standard for reminder apps

**Next Steps**:

- Upload AAB to Play Console Internal Testing track
- Add internal testers (email addresses)
- Complete remaining Play Console setup (content rating, target audience, store listing)
- Test on physical Android devices before wider release

**Files Generated**:

- `/build/app/outputs/bundle/release/app-release.aab` - Google Play App Bundle (54.1MB)

**Confidence Level**: High - App is properly categorized as consumer medication tracker, not health data collector

---

### v1.4.4+42 Multi-Platform Deployment (January 5, 2026)

**Status**: ✅ **COMPLETE** - All platforms deployed with latest version

**Build Artifacts Generated**:

1. **Android APK**: 60MB signed release APK for website distribution
2. **Android AAB**: 54.1MB App Bundle for Google Play Console
3. **iOS IPA**: 44MB App Store package
4. **Web Build**: Flutter web app with version.json

**Deployment Execution**:

**iOS App Store (App Store Connect)**:

- Uploaded: v1.4.4 (Build 42)
- Size: 44MB IPA
- Status: Reached "Pending Developer Release" (Jan 6) → CANCELED for version parity
- Reason: Will upload v1.4.4+43 to match Android Play Store version
- Deployment target: iOS 15.0+
- APNs: Production environment
- Copyright: Updated to 2026

**Android Website (Firebase Hosting)**:

- Deployed: https://dawatime.com
- File: dawatime-v1.4.4.apk (60MB)
- Verification: MD5 checksum confirmed
- Distribution: Public download via website
- Hosting: 16 files deployed

**Web App (Firebase Hosting - Migrated February 19, 2026)**:

- Deployed: https://webapp.dawatime.com
- Platform: Firebase Hosting multi-site (target: `webapp`)
- Assets: 42 files deployed
- Version tracking: version.json with build number
- Build time: 22.3s
- **SEO Strategy**: Blocked from search engines via robots.txt (Day 11)
  - Purpose: Convenience tool for existing users (CRUD without notifications)
  - Not an acquisition channel - search traffic directed to dawatime.com
  - robots.txt deployed: https://webapp.dawatime.com/robots.txt

**Google Play Console (Closed Testing)**:

- Uploaded: app-release.aab (54.2MB, v1.4.4+50)
- Track: Closed Testing (Testers Community)
- Release notes: First beta testing release
- Status: Live with 12 continuous testers (10+ days as of Jan 16)
- **Privacy Status**: Developer home address publicly visible on Play Store listing (1/101/55, Kuwait City 15300, Kuwait - updated Jan 16, 2026)
  - Required by Google Play verification, cannot be avoided due to MEW employment constraint preventing business registration

**App Store Metadata Updates**:

- **Description**: New bilingual description with 5 follow-up reminders emphasis
- **Keywords**: `pill,reminder,medication,medicine,tracker,refill,dose,prescription,vitamin,alarm,alert,schedule,rx` (98 chars)
- **Keywords (Arabic)**: `دواء,حبوب,تذكير,أدوية,منبه,جرعات,صحة,جدول,تنبيه,مخزون,تنظيم,منظم,مزمن,كبار,سكري,ضغط,وصفة,فيتامينات` (98 chars)
- **Short Description**: "Never miss a dose. Smart medication reminders with refill tracking. Free!"
- **Slogan**: "Never miss a dose. | لا تفوّت جرعة بعد اليوم"
- **Copyright**: 2026 Hamad AlKhalaf

**Files Generated**:

- `/build/app/outputs/flutter-apk/app-release.apk` - Website APK (60MB)
- `/build/app/outputs/bundle/release/app-release.aab` - Play Store AAB (54.1MB)
- `/build/ios/ipa/DawaTime.ipa` - App Store IPA (v1.4.4: 44MB, v1.4.5: 45MB)
- `/build/web/` - Web application bundle with version.json
- `/public/dawatime-v1.4.4.apk` - Deployed website APK

**Version Consistency Verification**:

- ✅ pubspec.yaml: 1.4.4+42
- ✅ Android versionCode: 42, versionName: "1.4.4"
- ✅ iOS CFBundleVersion: 42, CFBundleShortVersionString: 1.4.4
- ✅ Web version.json: {"version":"1.4.4","build_number":"42"}

**Deployment Timeline** (January 5, 2026):

- 10:44 - Android APK built (108.3s)
- 10:50 - iOS IPA built (300.9s)
- 11:45 - APK deployed to Firebase Hosting
- 11:51 - Web app built (24.1s)
- 11:57 - Web app deployed to Netlify (30.7s) [Migrated to Firebase Hosting Feb 19, 2026, Netlify project deleted same day]
- 17:01 - Android AAB built for Play Console (62.4s)
- Status: All platforms live/ready for review

**Result**: Full multi-platform release successfully deployed. v1.4.4+42 is now live on website and web app, submitted to iOS App Store, and uploaded to Play Console Internal Testing.

---

### Store Graphics & Screenshots Strategy (January-February 2026)

**Status**: ✅ **COMPLETE** - All 30 assets delivered, verified, and deployed (Feb 10, 2026)

**Upwork Job**: https://www.upwork.com/jobs/~022015687193682464731

**Figma Designs** (Designer's files):

- Original iOS: https://www.figma.com/design/dPtvl3NNwUNRQNPKuLAHIO/dawatime-screenshots
- Final (All Platforms): https://www.figma.com/design/TTW7I04DucS4KHzwDezvEU/dawatime-screenshots--IOS-Android-

**Figma Designs** (Private files - not shared with designer):

- Screenshots: https://www.figma.com/design/K35vgdrXq3D3nUFUEEjVNx/Dawatime-Screenshots

**Designer Hired**: Rahma M. #16 (Jan 27, 2026 at 1:08 PM)

- **Verification**: 1,347h Upwork, 83 jobs, $60K+ earned, 100% JSS, Arabic native
- **Portfolio**: Qatar Moms (iOS), Quran Bee (Android 500K+ downloads), Spedia (iOS)
- **Contract**: $250 + $110 Android + $40 featured graphics = $400 total
- **Timeline**: 3-4 weeks (Jan 28 - Feb 10)

**Handoff**: Jan 28, 2026 at 3:03 PM

- Test account: design@dawatime.com
- Documentation: Feature_Priority_Guide.md, Screenshot_Text_Copy_Sheet.md
- Brand assets: Google Drive (DawaTime → Design Guide → Store Graphics)

**Deliverables** (30 assets total):

- 14 iOS screenshots (7 English + 7 Arabic) - 2796×1290px iPhone mockups
- 14 Android screenshots (7 English + 7 Arabic) - English frameless, Arabic Pixel frames
- 2 Featured graphics (English + Arabic) - 1024×500px RTL/LTR layouts

**Key Dates**:

- Feb 3 (Day 34): Initial delivery (14 iOS screenshots) - 95% production-ready
- Feb 4 (Day 35): Revisions completed (2 fixes: Screenshot 1 font, Screenshot 5 typo)
- Feb 7 (Day 32): Milestone 2 paid ($125), Milestone 3 funded ($110 Android + iOS cleanup)
- Feb 8 (Day 33): Android delivery + featured graphics (28 screenshots + 2 graphics)
- Feb 9-10 (Days 34-35): Final verification, Arabic tagline revision, payments approved
- Feb 10 (Day 35): Contract closed with 5-star review

**Brand Compliance**:

- Primary color: #8AC249 green throughout
- Fonts: Nunito 800 ExtraBold (English), NotoKufiArabic 700 Bold (Arabic)
- Features: Medication reminders, refill tracking, weekday scheduling, theme modes
- RTL layouts: All 14 Arabic screenshots verified perfect

**Milestone Payments**:

- M1: $125 (Feb 4) - Initial iOS screenshots
- M2: $125 (Feb 7) - High-res PNGs + Figma source
- M3: $110 (Feb 10) - 14 Android screenshots + iOS status bar cleanup
- M4: $40 bonus (Feb 10) - 2 featured graphics

**Files Location**: Google Drive → My Drive → DawaTime → Design Guide → Store Graphics

**Deployment Status**: ✅ **SUBMITTED FOR REVIEW** - v1.4.5+54 with all 30 screenshots uploaded to App Store Connect & Play Console (February 10, 2026)

---

### Social Media Launch Strategy - Google Play Announcement (January 2026)

**Status**: ✅ **ALL PHASES COMPLETE** - Mystery teaser (Day 5) + Refill reminder (Day 9) + Production Launch (Day 15) executed

**Context**:

- iOS app already live on App Store since August 2025
- Android users have been sideloading from dawatime.com website for months
- Google Play launch represents "going official" milestone
- Instagram page: https://www.instagram.com/dawatimeapp
- LinkedIn page: https://www.linkedin.com/in/hamad-alkhalaf/

**Key Messaging**:
This is NOT a new app launch - it's an **upgrade story**:

- From: Manual APK downloads from website
- To: Official Google Play Store listing with automatic updates
- Frame as: "No more sideloading!" celebration

**Teaser Strategy - Mystery Campaign:**

**Phase 1: Mystery Teaser ✅ COMPLETED (Sunday, January 11, 2026 at 11:00 AM Kuwait time)**

- **Platform**: Instagram Story (not Feed post - Story first for FOMO)
- **Content Posted**: Teaser graphic showing:
  - DawaTime logo with clock
  - "Download on the App Store" badge (iOS already live)
  - "Coming Soon" badge with subtle Google colors gradient (matching website teaser)
  - No text explaining what's "coming soon"
- **Engagement**: Poll sticker ("Can you guess what it is?") and question sticker ("Drop your guesses 👇")
- **Timing Executed**: Sunday 11 AM = first work day after Kuwait weekend, mid-morning break when people are bored at desks and scrolling
- **Coordination**: Posted same morning as website emergency cleanup (website teaser button designed to match Instagram Story)

**Phase 2: Speculation Building (Days 6-13) - IN PROGRESS**

**Day 9: Value Proposition Post ✅ COMPLETED (Thursday, January 15, 2026)**

- **Platform**: Instagram Feed + Story
- **Content Posted**: Refill reminder graphic
  - Prescription bottle graphic with bilingual caption
  - Originally planned poll but removed (wasn't visible/engaging)
- **Caption Used**:
  ```
  How often do you forget to refill your prescriptions?
  DawaTime has you covered 💚 #comingsoon
  —————
  شكثر تنسون تصرفون أدويتكم؟
  دواء تايم يساعدكم 💚 #قريباً
  ```
- **Strategy**: Show real pain point (forgetting refills) + tease solution (refill reminders feature new in v1.4.4)
- **Engagement**: Caption question format maintains mystery without revealing Google Play
- **Amplification**: Shared to Story for dual visibility (Feed + Story viewers)

**Days 10-13: Light Engagement**

- **Friday-Monday**: Cryptic replies to comments ("Stay tuned 👀", "Maybe... 🤫")
- **Repost engagement**: Share comments/reactions to Story
- **Optional countdown**: "2 days until... 👀" (if building more hype)
- **Save to Highlights**: Create "🤖 Coming Soon" or "📱 Announcement" highlight

**Phase 3: Official Reveal ✅ COMPLETED (Tuesday, January 21, 2026 - Day 15)**

**Instagram Production Launch Campaign**:

- **Platform**: Instagram Feed (permanent announcement) + Paid Ad Campaign
- **Post URL**: https://www.instagram.com/p/DTw9AasDEUD/
- **Creative**: Bilingual carousel (English first image, Arabic second)
  - #8AC249 green background
  - DawaTime logo with pill clock icon
  - "Never miss a dose" tagline
  - App Store + Google Play badges (dual platform availability)
- **Caption (Final 10/10 Version)**:

  ```
  Never miss a dose 💚

  Now available on both iOS and Android.
  Download DawaTime today → Link in bio 📲

  ——————

  لا تفوّت جرعة بعد اليوم 💚

  متوفر الآن على iOS و Android.
  حمّل دواء تايم اليوم → الرابط في البايو 📲

  #DawaTime #kuwait #الكويت #madeinkuwait #صحة
  ```

- **Hashtag Strategy**: 5 hashtags (Instagram ad limit)
  - #DawaTime (brand tracking)
  - #kuwait + #الكويت (bilingual geographic targeting)
  - #madeinkuwait (local pride - launch day emotional appeal)
  - #صحة (health category in Arabic)
  - Strategic decision: #MadeInKuwait over #MedicationReminder for launch day (community engagement > conversion)
  - Week 2-4 optimization: Switch to #medicationreminder for conversion focus
- **Paid Ad Campaign**:
  - Budget: 50-75 KWD/month (~$165-$250 USD)
  - Week 1-2: 15-20 KWD/week conservative testing
  - Week 3-4: 20-35 KWD/week scale if performing well
  - Target Audience: Kuwait (all governorates), Age 25-54, Interests: Health & Wellness, Healthcare, Pharmacy
  - Performance Targets: CPI <2 KWD (~$6.50), CTR >1.5%, Day 1 retention >20%
  - Placement: Instagram Feed (primary) + Stories (secondary)
  - Timing: 8-10 PM Kuwait (optimal evening engagement)
  - Geographic Expansion: Month 2-3 add Bahrain/Qatar if Kuwait CPI <2 KWD
- **Early Engagement** (15 minutes post-launch): 1 like, 0 comments, organic phase beginning

**LinkedIn Professional Positioning Launch**:

- **Platform**: LinkedIn Feed (professional network)
- **Post URL**: https://www.linkedin.com/feed/update/urn:li:activity:7419657007840022528/
- **Strategy**: Failure→success narrative (9.5/10 rating)
- **Hook**: "Three years ago, I submitted a broken final project for my Flutter course at CODED"
- **Structure**:
  - Context: Working full-time at Kuwait's Ministry of Electricity & Water while rebuilding
  - Technical Bullets: 🛠️ Architecture (Firebase), 💊 Features (5 reminders every 30 min), 🌍 Localization (Arabic/English RTL), 🔔 Reliability (iOS + Android)
  - Validation: 12 continuous beta testers, 10+ days testing, 100% crash-free rate on v1.4.4+50
  - Lesson: "Sometimes you learn more from rebuilding than from getting it right the first time"
  - CTA: https://dawatime.com
- **Hashtags**: #Flutter #HealthTech #Kuwait #AndroidDev #iOSDev #CrossPlatform #DawaTime #FromFailureToSuccess
- **Positioning**: Builder credibility + technical execution showcase + growth mindset (vs generic product announcement)
- **Timeline**: December 20, 2022 (failed project) → January 21, 2026 (production launch) = 3 years 1 month

**Multi-Channel Coordination**:

- **Instagram** (Consumer): Local pride (#MadeInKuwait), health benefit ("Never miss a dose"), bilingual Kuwait/GCC targeting, paid advertising for user acquisition
- **LinkedIn** (Professional): Builder credibility, failure→success narrative, technical execution showcase, growth mindset positioning
- **Portfolio** (Evergreen): https://hamadalkhalaf.com - Capability-focused, dual-platform availability, no limiting metrics
- **Day 15 Milestone**: January 21, 2026 marks coordinated multi-platform marketing launch (Instagram paid ads + LinkedIn organic + Portfolio integration)

**Post-Launch Strategy**:

- **Instagram**: Let run 2-3 hours organic, then boost to ad after early engagement validation
- **LinkedIn**: First 2 hours critical for algorithm - reply to comments within 15 minutes, share to Stories within 24 hours
- **Week 1 Goals**: Monitor CPI, CTR, install conversion rate, track downloads via Firebase Analytics + App Store Connect + Play Console
- **Week 2-4 Optimization**: Switch Instagram hashtags from #madeinkuwait (awareness) to #medicationreminder (conversion)
- **Month 2-3 Expansion**: Add Bahrain, Qatar if Kuwait performance validates (CPI <2 KWD, strong retention)

**Engagement Tactics**:

- Poll stickers in Stories
- Question stickers for speculation
- Quiz stickers with Google Play hints
- Emoji sliders for excitement measurement
- Link stickers to current download options

**Timing Best Practices (Kuwait/GCC)**:

- **Best Days**: Sunday (first work day), Thursday (pre-weekend excitement)
- **Best Times**: 11 AM-1 PM (mid-morning work break), 3 PM-5 PM (afternoon lull)
- **Avoid**: Friday morning (prayers), Friday evening/Saturday (family time), late evenings
- **Weekend**: Friday-Saturday (not Sunday like Western markets)

**What NOT to Announce During Beta (Days 5-16)**:

- ❌ Specific launch dates
- ❌ "Download now" links to Play Store (not live yet)
- ❌ Technical details about beta testing
- ❌ Version numbers or build details
- ❌ "Beta testers wanted" (already have 25 via Testers Community)

**Teaser Graphic Details**:

- Location: Google Drive → DawaTime → Design Guide → Store Graphics
- Features: DawaTime logo, App Store badge, "Coming Soon" with Google colors gradient
- Intentionally subtle: Google colors in gradient not obvious to casual viewer
- Design quality: Professional, production-ready

**Execution Confirmed (January 11, 2026 - Day 5)**:
Mystery teaser posted **Sunday, January 11 at 11:00 AM Kuwait time** when audience returns to work and is browsing during coffee break. Perfect timing for maximum engagement from work boredom scrolling. Mystery maintained successfully - website teaser button matches Instagram Story design exactly. Phase 2 begins Days 6-13 with cryptic engagement responses.

---

### Beta Testing Update Strategy - Play Store Integration (January 5, 2026)

**Status**: ✅ **PREPARED** - v1.4.4+43 ready, awaiting proper release timing

**Context**: Testers Community requires 2-3 app updates during 16-day testing period to demonstrate "active development" for production access qualification. Need strategy that satisfies requirement while maintaining iOS version parity.

**Update Prepared - Week 1 (v1.4.4+43)**:

**Primary Change**: Google Play Store integration for Android update flow

- **File**: `lib/main.dart` (line 1006-1008, `showForceUpdateDialog()` function)
- **Before**: Android users redirected to `https://dawatime.com` (website APK download)
- **After**: Android users redirected to `https://play.google.com/store/apps/details?id=com.mrhasak99.dawatime`
- **Rationale**: Play Store users should receive updates from Play Store, not website downloads
- **iOS**: Unchanged, still directs to App Store

**Version Changes**:

- `pubspec.yaml`: `1.4.4+42` → `1.4.4+43`
- `android/app/build.gradle.kts` (versionCode): `42` → `43`
- **Build Artifact**: `build/app/outputs/bundle/release/app-release.aab` (54.1MB, build time 93.9s)
- **Functionality**: 100% identical to v1.4.4+42 except update URL

**Release Notes (Prepared)**:

```
Update v1.4.4 Build 43:
• Integrated Google Play Store for seamless updates
• Android users now directed to Play Store instead of website downloads
• Improved update experience
```

**Critical Timing Decision**: DO NOT release immediately after v1.4.4+42

**Why Spacing Updates is Essential**: ❌ Bad (v43 within 1 hour of v42: testers haven't installed, looks rushed, no feedback time, no sustained engagement). ✅ Good (strategic 16-day cadence: shows responsiveness, sustained engagement, proper testing cycles, professional rhythm).

**Recommended Release Timeline**:

**Day 1 (January 5, 2026) - Initial Release:**

- ✅ Published v1.4.4+42 to Closed Testing
- ✅ Testers Community campaign started
- **Action**: Monitor dashboard, let testers install and test

**Days 2-4 (January 6-8) - Monitoring Phase:**

- 📊 Track Testers Community metrics:
  - Install count growth
  - Crash reports (Firebase Crashlytics)
  - Feedback comments
  - Testing completion rate
- **No updates** - give testers 4-6 days to test initial version

**Days 5-7 (January 11-13) - iOS Upload & Stability Monitoring:**

- 📤 **Day 5 (January 11)**: iOS v1.4.4+47, v1.4.4+49 uploaded to TestFlight, submitted for Beta Review
- 📊 Monitor v1.4.4+50 crash reports via Firebase Crashlytics (Android + iOS after approval)
- 📥 Track tester feedback via Testers Community dashboard
- 📈 Review Play Console analytics: install count, crash-free rate, engagement metrics
- ⏳ **Day 7 (January 13)**: iOS TestFlight approved
- **No further updates planned** - update requirement already satisfied (v44, v45, v47, v49 deployed Days 3-5)

**Days 8-9 (January 14-15) - Production Prep:**

- ✅ **Day 6 (January 12)**: iOS v1.4.4+50 uploaded to TestFlight
- ✅ **Day 7 (January 13)**: iOS v1.4.4+50 approved and live
- 📊 Monitor v1.4.4+50 stability on both Android and iOS
- 📝 Collect user feedback for post-production roadmap
- 🔍 Final validation: no critical issues remaining on either platform
- **No updates unless critical crash discovered**

**Days 10-13 (January 16-19) - Pre-Production Testing:**

- ✅ **iOS already uploaded Day 6** - TestFlight approved Day 7 and live
- 📊 Final stability validation on both platforms (iOS 7+ days testing, Android 13+ days)
- 📝 Review aggregated feedback from both platforms
- 🔍 Last chance to catch any edge cases before Day 14 production submission
- 🔧 **Day 13 (Jan 19)**: Google Search Console HTTP redirect investigation
  - Discovered "Page with redirect" validation failure (HTTP→HTTPS)
  - Identified missing explicit redirect rule in firebase.json
  - Deployed SEO improvements (canonical tags, sitemap, robots.txt)
  - **Note**: HTTP→HTTPS redirect documented but not actually added until Feb 17, 2026
- **Strategy**: Both platforms ready with v1.4.4+50 for simultaneous production launch

**Day 14 (January 20, 2026) - CRITICAL DEADLINE:**

- 📥 **Download Production Access Form Report** from Testers Community
- 🚀 **Submit to Production track** in Play Console
- 📊 Review form data: tester count, install count, feedback summary
- ✅ Use pre-filled answers from report for Google's production access form
- **Note**: Testing continues through Day 16 while production review in progress

\*\*Days 15-16 (January 21-22, 2026) - Final Testing:

- 📊 Continue monitoring (testers begin uninstalling after Day 14)
- 🔍 Watch production track review status
- 🐛 Address any final issues before testing period ends

**Post-Testing (Day 19+):**

- ⏳ Await Android production release approval from Google (typically 2-7 days)
- ⏳ Await iOS App Store review completion (typically 1-3 days)
- 🎯 Once both approved: Release simultaneously on both platforms
- 📱 **Coordinated Launch**: Hold approved platform until both ready, then publish together

**Version Parity Management**:

- **iOS**: Uploaded v1.4.4+50 on Day 8 (skips v42, v43, v44, v48 entirely)
- **Android**: v1.4.4+42 → v1.4.4+44 → v1.4.4+45 → v1.4.4+46 → v1.4.4+47 → v1.4.4+49 → v1.4.4+50
- **Production Launch**: Both platforms ship with v1.4.4+50
- **Functionality**: 100% identical across all versions
- **Version Sync**: Both platforms at v1.4.4+50 for Day 14 production launch

**Files Modified This Session**:

- `lib/main.dart` - Line 1006-1008: Changed Android update URL
- `pubspec.yaml` - Version: 1.4.4+42 → 1.4.4+43
- `android/app/build.gradle.kts` - versionCode: 42 → 43
- **Build artifact generated**: 54.1MB AAB ready for upload

**Key Learning**: Beta testing updates should be spaced 4-7 days apart to:

1. Allow proper testing cycles
2. Demonstrate sustained engagement (not rushed development)
3. Show responsiveness to actual feedback
4. Maintain professional release cadence
5. Give Testers Community time to evaluate each build

**What Actually Happened**:

- **Days 1-2**: Initial release v1.4.4+42, 25 testers joined
- **Day 3**: Emergency v1.4.4+44 (5 crash fixes)
- **Day 4**: Emergency v1.4.4+45 (SHA certificate + Android 15)
- **Day 6**: Emergency v1.4.4+46 (migration data safety)
- **Day 7**: Emergency v1.4.4+47 and v1.4.4+49 (setState fix, migration replacement)
- **Day 8**: v1.4.4+50 (website SEO, legal link optimization)
- **Days 9-13**: Monitor v1.4.4+50 stability (update requirement already satisfied)
- **Day 14**: Production submission with v1.4.4+50 on both platforms

---

### Android & iOS Deployment Fixes (January 4, 2026)

**Status**: ✅ **COMPLETE** - Both platforms ready for production deployment

**Android Build Fixes**:

- **Security**: Moved signing credentials to `android/key.properties` (excluded from git)
- **Java Version**: Downgraded from 21 → 17 for better device compatibility
- **Target SDK**: Updated from 34 → 35 (Google Play requirement)
- **Android Gradle Plugin**: 8.7.0 → 8.9.1
- **Gradle Wrapper**: 8.9 → 8.11.1
- **Build Output**: 60MB APK, signed and ready for website distribution

**iOS Build Fixes**:

- **APNs Environment**: Changed from `development` → `production` (required for App Store push notifications)
- **Deployment Target**: Standardized all configurations to iOS 15.0 (previously: Debug=13.0, Release=15.6, Podfile=15.0)
- **Location Permissions**: Validated as required (used for country-based restriction checks via geofencing)
- **Build Output**: 56.5MB app, ready for App Store submission

**Files Modified**:

- `/android/key.properties` - **CREATED** (signing credentials, git-ignored)
- `/android/app/build.gradle.kts` - Security, Java 17, targetSdk 35, keystore properties loader
- `/android/settings.gradle.kts` - AGP version bump
- `/android/gradle/wrapper/gradle-wrapper.properties` - Gradle version bump
- `/ios/Runner.xcodeproj/project.pbxproj` - Deployment target standardization (6 occurrences)
- `/ios/Runner/Runner.entitlements` - Production APNs environment

**Version Tracking**:

- pubspec.yaml: 1.4.4+41
- android/app/build.gradle.kts: versionCode 41, versionName "1.4.4"
- iOS: Uses FLUTTER_BUILD_NUMBER (41) and FLUTTER_BUILD_NAME (1.4.4)

---

### Refill Reminder Settings Customization (January 4, 2026)

**Status**: ✅ **IMPLEMENTED** - Users can customize when they receive weekly low-stock alerts

**Feature Overview**:

- Added user-configurable day of week and time of day for refill reminders
- Collective setting: applies to ALL medications with refill thresholds (not per-medication)
- Default: Sunday at 10:00 AM (preserved for existing users)
- Settings persist in Firestore user document

**User Experience**:

- Inline UI in Settings page: "Sunday at 10:00 am" format with dropdown + time picker
- Matches existing Theme/Language settings style (ListTile with subtitle)
- Day dropdown: Sunday-Saturday order (Sunday first as day 7)
- Time picker: 12-hour format with AM/PM, full theming matching add medications page
- Real-time rescheduling: Changes apply immediately to all low-stock medications
- **Time display uses Flutter's built-in localization**: `TimeOfDay.format(context)` for proper AM/PM (English) and ص-م (Arabic)

**Implementation Details**:

- **Firestore Fields** (User document):
  - `refillReminderDay`: int (1-7 where 1=Monday, 7=Sunday), default: 7
  - `refillReminderTime`: string ("HH:mm" 24-hour format), default: "10:00"
- **Scheduling Logic** (medication_notifications.dart):
  - `scheduleWeeklyRefillNotification()` now accepts `userId` parameter
  - Reads user preferences from Firestore before scheduling
  - Calculates next occurrence: `daysUntilTarget = (refillDay - now.weekday) % 7`
  - Handles same-day scheduling with time comparison
- **UI Structure** (settings.dart):
  - FutureBuilder fetches user document for current settings
  - Row with baseline alignment: DropdownButton<int> + Text("at") + InkWell time picker
  - Time picker Container: 2px bottom padding, subtle underline (alpha: 0.12)
  - Converts stored time string to TimeOfDay: `TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]))`
  - Displays using `refillTimeOfDay.format(context)` for proper localization (matches home page pattern)
  - Helper function: `getDayName(int day)` for weekday localization
  - `_rescheduleAllRefillReminders(userId)` called after any change
- **Auto-Rescheduling**:
  - HomePage `_checkRefillReminders()` runs on app open (in `_scheduleAfterPermissionCheck()`)
  - Checks all medications for low stock and schedules/cancels accordingly
  - No manual intervention needed - settings changes take effect on next homepage visit

**Localization**:

- Added "at" key in app_en.arb and app_ar.arb
- English: "at"
- Arabic: "عند الساعة"

**Files Updated**:

- `/lib/settings.dart` (2691 lines):
  - Added refill reminder settings section with ListTile structure
  - FutureBuilder pattern matching Theme/Language sections
  - Inline day/time selectors with baseline alignment (CrossAxisAlignment.baseline)
  - TimeOfDay conversion and `refillTimeOfDay.format(context)` for localized display
  - `_rescheduleAllRefillReminders()` method
- `/lib/utils/medication_notifications.dart` (637 lines):
  - Updated `scheduleWeeklyRefillNotification()` signature with userId parameter
  - Added Firestore query to fetch user preferences
  - Dynamic scheduling based on user's chosen day/time
- `/lib/home_page.dart` (3902 lines):
  - Updated all 4 calls to `scheduleWeeklyRefillNotification()` to pass userId
  - Existing `_checkRefillReminders()` ensures auto-rescheduling on homepage access
- `/lib/l10n/app_en.arb` & `/lib/l10n/app_ar.arb`:
  - Added "at" translation for inline time display
- `/pubspec.yaml` - Version: 1.4.4+28 → 1.4.4+34
- `/android/app/build.gradle.kts` - versionCode: 28 → 34

**Result**: Users can customize refill reminder timing to match their pharmacy visit schedule. All low-stock alerts fire at the same user-chosen day/time. Changes apply automatically when homepage is accessed.

---

### Android Notification Fixes (January 4, 2026)

**Status**: ✅ **FIXED** - Critical notification issues resolved

**Issue 1: Android Release Build - Notification Icon Not Found**
**Problem**: Release APK crashed with `PlatformException(Invalid_icon, The resource dawatime_notify could not be found...)`. Debug builds worked fine.

**Root Cause**: R8 resource shrinker (enabled with `isShrinkResources = true`) removed notification icon drawables from release builds because they're referenced dynamically by string name, not direct resource ID.

**Solution**: Created `android/app/src/main/res/raw/keep.xml` with tools:keep directive:

```xml
<?xml version="1.0" encoding="utf-8"?>
<resources xmlns:tools="http://schemas.android.com/tools"
    tools:keep="@drawable/dawatime_notify,@drawable/dawatime_foreground,@drawable/background" />
```

**Files Created**:

- `/android/app/src/main/res/raw/keep.xml` - Prevents R8 from removing notification icons

**Issue 2: Days of Week Notifications Scheduling for Next Week**
**Problem**: When today (e.g., Sunday) was in the selected weekdays, Android notifications scheduled for next week instead of checking if today's time had passed.

**Root Cause**: Line 114 logic in medication_notifications.dart: `if (daysUntil <= 0) daysUntil += 7` always added 7 days when current day matched selected weekday, even if scheduled time hadn't passed yet today.

**Solution**: Changed logic to check if today's scheduled DateTime passed before adding 7 days:

```dart
if (daysUntil == 0) {
  // Today is a selected day, check if time has passed
  final todayScheduledTime = DateTime(now.year, now.month, now.day, hour, minute);
  if (todayScheduledTime.isAfter(now)) {
    // Time hasn't passed yet today - schedule for today
    scheduledTime = todayScheduledTime;
  } else {
    // Time already passed - schedule for next week
    daysUntil = 7;
  }
} else if (daysUntil < 0) {
  daysUntil += 7;
}
```

**Files Updated**:

- `/lib/utils/medication_notifications.dart` (lines 112-143) - Fixed weekday calculation logic
- `/pubspec.yaml` - Version: 1.4.4+20 → 1.4.4+21
- `/android/app/build.gradle.kts` - versionCode: 20 → 21

**Debug Process**: Added extensive print logging to trace weekday processing, discovered daysUntil=0 always became daysUntil=7. User confirmed notification fired correctly for today (Sunday 17:41) after fix.

**Result**: Release builds include notification icons successfully. Days of week notifications fire correctly for today when selected. Both Android and iOS notifications now work reliably.

---

### Form Validation & Security Updates (January 1, 2026)

**Status**: ✅ **IMPLEMENTED** - Enhanced UX and security patches

**Visual Form Validation**: Added red TextField error effects with boolean error flags (`_emailError`, `_passwordError`, `_nameError`, `_confirmPasswordError`), conditional styling on validation failure, auto-clearing via `onChanged` callbacks.

**Enhanced Signup Debugging**: Integrated `dart:developer`, added 3-stage SnackBar feedback (blue/orange/green), 10-second timeout handling, comprehensive error catching.

**Security Fixes**: Firestore Rules - AppConfig public read access | Intro Guide - email verification check | npm - Fixed qs DoS vulnerability (GHSA-6rw7-vpxm-498p), upgraded to ≥6.14.1, 0 vulnerabilities.

**Files**: login_page.dart, signup_page.dart, home_page.dart, firestore.rules, functions/package.json, package.json, pubspec.yaml (1.4.4+25→1.4.4+28), build.gradle.kts (25→28)

---

### Legal Document Check - Dual Entry Point Architecture (January 1, 2026)

**Status**: ✅ **IMPLEMENTED** - Legal checks at both login and app startup

**Entry Point 1 (login_page.dart)**: Fresh login → Check versions via `_checkLegalDocumentVersions(uid)` → Show dialog if needed → User accepts/declines → Update metadata via `_updateLoginMetadata(uid)` → Navigate to HomePage

**Entry Point 2 (main.dart AuthGate)**: App startup → Detect logged-in user → Check versions → Show dialog with `_showingLegalDialog` flag → User accepts → Update Firestore → Update metadata via `_saveFCMToken(uid)` → Show HomePage

**Files**: main.dart (AuthGate with `_showingLegalDialog` and `_lastCheckedUserId`), login_page.dart (restored 3 methods), pubspec.yaml (1.4.4+24→1.4.4+25), build.gradle.kts (24→25)

### December 2025 Bug Fixes

**Status**: ✅ **COMPLETE** - 4 production issues resolved (Dec 29-30, 2025)

1. **Navigation Bug**: FutureBuilder rebuilding post-navigation → Replaced with one-time `initState()` check (add_medications.dart)
2. **Duplicate Notification**: Background handler + Cloud Function both creating notifications → Removed local notification creation (main.dart, -55 lines)
3. **SnackBar Persistence**: Flutter update changed action button behavior → Added `persist: false` to 5 SnackBar locations
4. **Database Path**: Mixed old/new structure → Updated all Firestore operations to use subcollection structure `/Users/{userId}/medications/{medicationId}`

**Code Cleanup**: Removed 28 debug print statements, fixed 25+ empty catch blocks, removed 3 unused variables

### Critical iOS Notification Fixes

**Issue**: No medication reminders on iOS for 2 weeks, only incorrect refill alerts.

**Root Causes**: (1) Missing main scheduling loop for `everyXDays` medications, (2) Missing `interruptionLevel: InterruptionLevel.timeSensitive` - iOS 15+ was suppressing alerts, (3) Stale weekly refill notifications persisting.

**Fixes**: Added while loop in `scheduleMedicationNotification()` (lines 416-477), added `interruptionLevel` to all DarwinNotificationDetails, implemented startup cleanup using `cancelAll()`, added `cancelAllRefillNotifications()`, enhanced debug logging.

**Files**: `/lib/utils/medication_notifications.dart` (504 → 637 lines), `/lib/home_page.dart` (3785 → 3856 lines)

### Database Migration & Permission Fixes (December 29, 2025)

**Issues**: Permission-denied errors on AppConfig, FCM null check, duplicate token cleanup, migration cleanup failing, duplicate permission dialogs, wrong database default.

**Fixes**: firestore.rules - Added AppConfig read, separated delete from update validation | main.dart - Changed to `Platform.isIOS`, removed duplicate FCM token cleanup/permissions | AppDelegate.swift - Removed duplicate `requestAuthorization()` | home_page.dart - New structure default, cleaner logging | functions/index.js - Added `checkVersionAdoption` monitoring

**Files**: firestore.rules (60→67), main.dart (1423→1422), AppDelegate.swift (45→31), home_page.dart (3950→3938), functions/index.js (567→694)

### iOS FCM Token Registration Fixes (December 2025)

**Issue**: iPhone not receiving remote update notifications from Cloud Function.

**Root Causes**: iOS requires APNs token before FCM token, Cloud Function only sent `data` payload (iOS needs `notification`), missing APNs alert config, no token refresh handling, no invalid token cleanup, AppDelegate not registering remote notifications.

**Fixes**: main.dart - APNs token acquisition with retry (lines 295-309, 546-591), `onTokenRefresh` listener (lines 378-392) | AppDelegate.swift - Remote notification registration | functions/index.js - `notification` payload, complete APNs config, error logging, automatic invalid token cleanup.

**Files**: main.dart (1200→1423 lines), AppDelegate.swift (13→45 lines)

- `/functions/index.js` (145 → 567 lines)

**Testing Verification**: Install on iPhone, check console for "APNs token obtained: true" and "✓ FCM token saved", update Firestore version, verify notification received within 1-2 minutes.

### Firebase App Check Integration (February 2026)

**Status**: ✅ **PRODUCTION READY** - Configured across all platforms (Android, iOS, Web)

**Purpose**: Security layer that protects Firebase backend services from abuse by verifying requests come from genuine DawaTime apps.

**Implementation Date**: February 4, 2026

**Package Version**: `firebase_app_check: ^0.4.1+4`

#### Platform-Specific Configuration

**Android - Play Integrity API**:

- Provider: Google Play Integrity
- Configuration: Firebase Console → App Check → Android app
- Status: Registered and active
- Usage: Verifies app authenticity and device integrity

**iOS - App Attest**:

- Provider: Apple App Attest
- Configuration: Firebase Console → App Check → iOS app
- Status: Registered and active
- Usage: Cryptographic attestation of app integrity

**Web - reCAPTCHA v3**:

- Provider: Google reCAPTCHA v3
- Site Key: `6LckwmAsAAAAABI25gZvyKhtYcEAou1nheMhIsxN`
- Configuration: Google reCAPTCHA Console + Firebase Console
- Authorized Domains:
  - `localhost` (development)
  - `webapp.dawatime.com` (production)
  - `dawatime.com` (main website)
- Status: Fully configured and verified

#### Code Implementation

**Location**: `/lib/main.dart` (lines 86-103)

```dart
// Firebase App Check - Platform-specific initialization
try {
  if (kIsWeb) {
    // Web requires explicit ReCaptchaV3Provider
    await FirebaseAppCheck.instance.activate(
      providerWeb: ReCaptchaV3Provider(
        '6LckwmAsAAAAABI25gZvyKhtYcEAou1nheMhIsxN',
      ),
    );
  } else {
    // Android and iOS use Firebase Console configuration
    await FirebaseAppCheck.instance.activate();
  }
  // Always log in production too (for verification)
  print('✓ Firebase App Check activated');
} catch (e) {
  // Always log errors in production too
  print('⚠️ App Check initialization failed: $e');
}
```

**Key Implementation Details**:

- **Platform Detection**: Uses `kIsWeb` to determine web vs mobile
- **Web Configuration**: Explicit `providerWeb` parameter with reCAPTCHA v3 site key
- **Mobile Configuration**: Parameterless `activate()` reads from Firebase Console
- **Production Logging**: Uses `print()` instead of `kDebugMode` guard for production visibility
- **Error Handling**: Graceful failure with error logging

#### Platform Compatibility Fixes

**Issue**: `Platform.isAndroid` and `Platform.isIOS` crash on web platform with error:

```
Unsupported operation: Platform._operatingSystem
```

**Solution**: Added `kIsWeb` guards before all Platform checks:

**Files Modified**:

1. `/lib/login_page.dart`:
   - Line 135: `if (kIsWeb || !Platform.isAndroid) return true;` (Play Integrity guard)
   - Lines 104-107: `if (!kIsWeb && Platform.isIOS) {` (APNs token guard)

2. `/lib/signup_page.dart`:
   - Line 36: `if (kIsWeb || !Platform.isAndroid) return true;` (Play Integrity guard)

**Pattern**: Always check `kIsWeb` BEFORE accessing `Platform.isAndroid` or `Platform.isIOS`

#### Verification & Testing

**Development (localhost)**:

```bash
flutter run -d chrome
# Console output:
# ✓ Firebase App Check activated
```

**Production (webapp.dawatime.com)**:

```bash
flutter build web --release
firebase deploy --only hosting:webapp
# Visit https://webapp.dawatime.com
# Console output:
# ✓ Firebase App Check activated
```

**Expected Behavior**:

- ✅ Console shows: `"✓ Firebase App Check activated"`
- ✅ No Platform compatibility errors
- ✅ Firebase services receive valid App Check tokens
- ⚠️ Temporary throttling possible from previous failed attempts (400/429 errors)

#### Troubleshooting

**Common Issue: Throttling (400/429 Errors)**

**Symptoms**:

```
AppCheck: 400 error. Attempts allowed again after 00m:XXs (appCheck/initial-throttle)
AppCheck: Requests throttled due to previous 400 error (appCheck/throttled)
```

**Root Cause**: Firebase server-side rate limiting from previous failed authentication attempts (incorrect keys, wrong parameters during setup)

**Impact**:

- Does NOT affect app functionality - app works normally
- Firebase uses cached tokens or operates with degraded App Check
- Console warnings can be safely ignored during development

**Resolution Options**:

1. **Wait 10-15 minutes** - Throttle auto-clears without any action
2. **Add debug token** - Firebase Console → App Check → Manage Debug Tokens
3. **Continue development** - App functions normally despite warnings

**Not a Bug**: Throttling is expected temporary condition after configuration changes, not a code issue

#### Production Deployment

**Requirements**:

1. ✅ reCAPTCHA site key configured in code
2. ✅ Production domain added to reCAPTCHA Console authorized domains
3. ✅ Web app registered in Firebase Console
4. ✅ Platform-specific providers registered (Play Integrity, App Attest)

**Deployment Checklist**:

- [x] Code updated with correct site key
- [x] `flutter build web --release` completed successfully
- [x] Deployed to production (Firebase Hosting)
- [x] Console verification: `"✓ Firebase App Check activated"` visible
- [x] No Platform compatibility errors
- [x] All three domains configured (localhost, webapp.dawatime.com, dawatime.com)

**Production Status**: Fully deployed and operational as of February 4, 2026

#### Benefits

**Security**:

- ✅ Protects Firebase backend from unauthorized access
- ✅ Prevents abuse from cloned/modified apps
- ✅ Verifies requests come from genuine DawaTime apps
- ✅ Complements Firebase Auth for defense-in-depth

**Compliance**:

- ✅ Strengthens Kuwait MOH partnership application
- ✅ Demonstrates enterprise-grade security practices
- ✅ Required for production Firebase services

**User Trust**:

- ✅ Health data protection
- ✅ Prevents medication data theft from fake apps
- ✅ Ensures only verified apps access user information

#### Dependencies

```yaml
# pubspec.yaml
dependencies:
  firebase_app_check: ^0.4.1+4
  firebase_core: # Required
```

**Import Pattern**:

```dart
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
```

#### Additional Configuration

**OAuth Domain Issue** (Separate from App Check):

If seeing error:

```
Error: The current domain is not authorized for OAuth operations
```

**Solution**: Add production domain to Firebase Console:

1. Firebase Console → Authentication → Settings
2. Scroll to **Authorized domains**
3. Add: `webapp.dawatime.com`
4. Click **Add domain**

**Note**: This is a Firebase Auth configuration, not App Check.

---

## Project Overview

DawaTime is a Flutter medication reminder app with Firebase backend, designed for the Kuwaiti and GCC market with Arabic as a primary language (not just localization). The app manages medication schedules, local notifications, and refill reminders with background task execution. Target platforms: Android (SDK 24+) and iOS.

### Target Market & Regional Context

**Primary Market**: Kuwait

- Developer is Kuwaiti (Hamad AlKhalaf)
- App name "DawaTime" uses Arabic word دواء (dawaa = medicine)
- Arabic language is primary, not secondary
- Design decisions reflect Kuwaiti/GCC cultural context

**Secondary Markets**: GCC Region

- Saudi Arabia, UAE, Qatar, Bahrain, Oman
- Shared language (Arabic)
- Similar healthcare systems and medication practices
- Regional pharmacy networks

**Regional Considerations**:

- **Country blocking**: Israel geo-blocked for GCC regional compliance and political context
  - Implementation: Location permissions check user's country via geolocator
  - Rationale: Compliance with GCC regional policies and market norms
  - Google Play Compliance: NOT a violation of EU geo-blocking regulation (Israel ≠ EU, justified restriction)
  - Other countries: No restrictions (all EU member states accessible)
- **Location permissions**: Used for regional compliance and country-based restriction checks
- **Language priority**: Arabic is equal to English, not a translation afterthought
- **Time formats**: Support for both 12-hour (common in GCC) and 24-hour formats
- **Currency**: Future pricing features should use KWD (Kuwaiti Dinar) as default
- **Pharmacy partnerships**: Should focus on Kuwaiti chains (Al-Dawaiya, Boots, etc.) before expanding regionally

**Phased Geographic Expansion Strategy**:

DawaTime follows a success-driven geographic expansion model, validating product-market fit in each region before expanding to the next:

**Phase 1: Kuwait Market (2025-2027)** - _Current Focus_

- **Goal**: Establish strong local presence and brand recognition
- **Milestones**:
  - 2026: Reach 1,200-1,800 active users
  - 2027: Grow to 2,500-3,000 users for freemium viability
- **Success Criteria**:
  - 4.5+ App Store rating (50+ reviews)
  - 40%+ 30-day retention
  - Kuwait MOH partnership secured
  - Proven monetization model (if freemium launched)
- **Market Advantages**:
  - Developer is Kuwaiti (local credibility)
  - Arabic-first design resonates with target audience
  - Understanding of local healthcare system and pharmacy networks
  - High smartphone penetration (99%)
- **Key Metrics**: User growth rate, retention, App Store rating, word-of-mouth acquisition

**Phase 2: Middle East Expansion (2028+)** - _Conditional on Kuwait Success_

- **Target Markets** (Priority Order):
  1. **GCC First**: Saudi Arabia, UAE, Qatar, Bahrain, Oman
     - Shared language (Arabic)
     - Similar healthcare systems
     - Cultural familiarity
     - Regional pharmacy networks
  2. **Extended Middle East**: Egypt, Jordan, Lebanon (if GCC validates)
- **Prerequisites**:
  - ✅ Kuwait market proven (3,000+ active users, stable retention)
  - ✅ Freemium model validated (if applicable)
  - ✅ Positive unit economics (CAC < LTV)
  - ✅ Scalable infrastructure (Firebase can handle 10x growth)
- **Expansion Strategy**:
  - Start with UAE (largest GCC tech market, high expat population)
  - Leverage Kuwait success stories in marketing
  - Partner with regional pharmacy chains
  - Localize for regional Arabic dialects (if needed)
  - Adjust pricing for local purchasing power (KWD → SAR, AED, etc.)
- **Challenges**:
  - Country-specific health regulations (Saudi FDA, UAE DHA)
  - Regional medication database variations
  - Pharmacy partnership negotiations per country
  - Marketing spend required for each new market
- **Success Metrics**: User acquisition cost (CAC), market penetration rate, retention by country

**Phase 3: Global Expansion (2030+)** - _Conditional on Middle East Success_

- **Target Markets** (Tiered Approach):
  - **Tier 1**: English-speaking markets (US, UK, Canada, Australia)
  - **Tier 2**: European Union (multilingual support required)
  - **Tier 3**: Asia-Pacific (localization-heavy)
- **Prerequisites**:
  - ✅ Middle East market validated (10,000+ active users across region)
  - ✅ Multilingual infrastructure proven (Arabic/English → additional languages)
  - ✅ Profitable unit economics across Middle East markets
  - ✅ Team capacity for international operations
- **Localization Requirements**:
  - Add major languages (Spanish, French, German, Mandarin, Hindi, etc.)
  - Comply with regional health regulations (FDA, EMA, etc.)
  - Partner with international pharmacy chains (CVS, Walgreens, Boots, etc.)
  - Adapt to regional medication naming conventions
- **Challenges**:
  - Regulatory complexity (FDA approval for health apps in US)
  - Competition with established players (Medisafe, MyTherapy, etc.)
  - Higher customer acquisition costs in saturated markets
  - Cultural differences in healthcare/medication management
  - Time zone support for global user base
- **Success Metrics**: International user growth, retention by region, revenue per geography

**Expansion Timeline Estimate**:

- **2025-2027**: Kuwait dominance (Phase 1)
- **2028-2029**: GCC expansion (Phase 2 start)
- **2030+**: Global markets (Phase 3, conditional on Phase 2 success)

**Strategic Rationale**: This phased approach minimizes risk by validating product-market fit in culturally/linguistically similar markets (Kuwait → GCC → Middle East) before tackling the complexity and competition of global markets. Each phase builds on learnings from the previous, allowing iterative improvement of product, marketing, and business model before scaling internationally.

**Development Impact**: Feature priorities reflect Kuwaiti needs, Arabic-first UI/UX, regional pharmacy integrations, GCC-optimized marketing, Kuwait health data compliance.

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
  - **Login page handles fresh login legal checks**: After successful authentication, checks legal document versions, shows dialog if update needed, updates metadata after acceptance, then navigates directly to HomePage (see Dual Entry Point Architecture above).

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

**Refactoring Benefits**: Single source of truth, ~897 lines eliminated, improved maintainability, cleaner imports, better organization.

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
  - **`refillReminderDay`**: int (1-7 where 1=Monday, 7=Sunday), default: 7 (Sunday). User's preferred day of week for refill reminders. Added January 2026.
  - **`refillReminderTime`**: string ("HH:mm" 24-hour format), default: "10:00". User's preferred time of day for refill reminders. Added January 2026.
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

- Schedules weekly recurring notification at user-configurable day/time (default: Sunday at 10:00 AM)
- **User Preferences** (January 2026): Reads `refillReminderDay` and `refillReminderTime` from Firestore user document
- Calculates next occurrence: `daysUntilTarget = (refillDay - now.weekday) % 7`
- Handles same-day scheduling: if target day is today but time already passed, schedules for next week
- Uses `matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime` for weekly repeat
- Separate channel ID `'refill_channel'` with orange color (`0xFFFF9800`)
- Notification ID: `('refill_weekly_$docId').hashCode`
- Includes `interruptionLevel: InterruptionLevel.timeSensitive` for iOS 15+ delivery
- Debug logging shows medication name, current amount, threshold, notification ID, and next fire time
- **Signature**: `scheduleWeeklyRefillNotification(Medications medication, String docId, String userId)` - userId parameter added January 2026

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

**Firebase Project Information**:

- **Project ID**: `medication-cd9b8`
- **Current Owner**: eng@hamadalkhalaf.com (Google Workspace account)
- **Ownership Transfer**: February 22, 2026
  - **From**: hasak81099@gmail.com (original owner)
  - **To**: eng@hamadalkhalaf.com (current owner)
  - **Reason**: Consolidation under professional Google Workspace domain
  - **Verification**: ✅ Complete - CLI access confirmed, deployment permissions verified
  - **Firebase CLI Version**: Updated to v15.7.0 (from v15.5.1) on transfer day
- **Service Account**: medication-cd9b8@appspot.gserviceaccount.com
- **Project URL**: https://console.firebase.google.com/project/medication-cd9b8
- **Active Services**: Authentication, Firestore Database, Cloud Functions, Hosting (multi-site), Cloud Storage, Analytics, Crashlytics, Performance Monitoring, App Check, Cloud Messaging (FCM)

**Ownership Transfer Verification** (February 22, 2026):

1. ✅ Firebase CLI logout from old account: `firebase logout` (hasak81099@gmail.com)
2. ✅ Firebase CLI login with new account: `firebase login` (eng@hamadalkhalaf.com)
3. ✅ Project access verified: `firebase projects:list` showed medication-cd9b8
4. ✅ Active project confirmed: `firebase use` displayed correct project
5. ✅ Deployment permissions tested: `firebase deploy --only hosting:main --dry-run` succeeded

**Important Notes**:

- All Firebase configurations, service accounts, and secrets remain unchanged after ownership transfer
- SMTP authentication continues using eng@hamadalkhalaf.com (already configured before transfer)
- No user-facing or backend functionality affected by ownership change
- All Cloud Functions and hosting configurations preserved
- No code changes required in project files (firebase.json, .firebaserc, google-services.json, etc.)

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

**Secret Manager Integration** (Added January 20, 2026):

**Environment Variables Approach - DEPRECATED**:

- ❌ **dotenv + process.env**: .env files NOT uploaded to Cloud Functions (local emulator only)
- ❌ **defineString() + .env**: defineString() expects Firebase config, not .env files
- ❌ **firebase functions:config:set**: Deprecated API, shutdown March 2026

**Current Production Implementation - Secret Manager**:

```javascript
// functions/index.js - Lines 1-11
const { defineSecret } = require("firebase-functions/params");

const emailUser = defineSecret("EMAIL_USER"); // "eng@hamadalkhalaf.com"
const emailPassword = defineSecret("EMAIL_PASSWORD"); // Google Workspace App Password

// Lines 282-298: getTransporter() - Lazy initialization
function getTransporter() {
  if (!transporter) {
    transporter = nodemailer.createTransport({
      host: "smtp.gmail.com",
      port: 587,
      secure: false, // Uses STARTTLS
      auth: {
        user: emailUser.value(), // ✅ Reads from Secret Manager (eng@hamadalkhalaf.com)
        pass: emailPassword.value(), // ✅ Reads from Secret Manager (App Password)
      },
    });
  }
  return transporter;
}
```

**Secret Creation Commands**:

```bash
# CRITICAL: Use echo -n to prevent trailing newline
echo -n "eng@hamadalkhalaf.com" | firebase functions:secrets:set EMAIL_USER
echo -n "YOUR_GOOGLE_WORKSPACE_APP_PASSWORD" | firebase functions:secrets:set EMAIL_PASSWORD

# Deploy functions to use secrets
firebase deploy --only functions:emailAdminsOnContactMessage,functions:requestAccountDeletion
```

**Secret Versions**:

- **v1-v2** (Deprecated - January 2026): Zoho Mail credentials (zoho@hamadalkhalaf.com)
- **v3** (Current - February 17, 2026): Google Workspace credentials (eng@hamadalkhalaf.com)
  - Migration completed: February 17, 2026
  - Gmail alias loop filtering issue discovered and resolved same day
  - Production verified: Emails delivering to Inbox correctly

**Service Account Permissions**:

- Account: medication-cd9b8@appspot.gserviceaccount.com
- Role: roles/secretmanager.secretAccessor
- Status: Automatically granted by `firebase deploy` on both secrets

**Important Notes**:

1. **functions/.env file**: Exists locally but NOT used in production (Firebase emulator only)
2. **Secret updates**: Require redeployment of functions to use new versions
3. **Google Workspace App Password**: Required for SMTP authentication (not regular password)
4. **defineSecret() vs defineString()**: defineSecret reads Secret Manager, defineString reads environment variables

**Firebase Deprecation Compliance** (Confirmed February 17, 2026):

- **Status**: ✅ **FULLY COMPLIANT** - No action required
- **Legacy Config Audit**: `firebase functions:config:get` returned `{}` (zero legacy data)
- **Export Command Verification**: `firebase functions:config:export` confirmed "Your functions.config() is empty. Nothing to do."
- **Migration Date**: Completed January 20, 2026 (28 days prior to verification)
- **Deadline**: March 31, 2027 (CLI shows "March 2026" but email states March 31, 2027)
- **Implementation**: All Cloud Functions use `defineSecret()` and Secret Manager
- **Verification**: No `functions.config()` calls found in codebase
- **Result**: Project already using modern Firebase Functions configuration standards

**Google Workspace Configuration** (February 2026 Migration):

**Primary Account**:

- **eng@hamadalkhalaf.com** (Hamad AlKhalaf) - Main Google Workspace account, used for SMTP authentication

**Email Aliases** (all @dawatime.com addresses are aliases of eng@hamadalkhalaf.com):

- **admin@dawatime.com** (DawaTime Admin) - Used as FROM address for Cloud Functions, configured in Gmail "Send mail as"
- **design@dawatime.com** (DawaTime Designer) - Design/branding inquiries, configured in Gmail "Send mail as"
- **hamad@dawatime.com** (Hamad AlKhalaf) - Personal developer email, configured in Gmail "Send mail as"
- **help@dawatime.com** (DawaTime Support) - User support responses, configured in Gmail "Send mail as"
- **legal@dawatime.com** (DawaTime Legal) - Legal/privacy inquiries, configured in Gmail "Send mail as"
- **testapple@dawatime.com** (Apple Testing) - iOS testing account
- **testgoogle@dawatime.com** (Google Testing) - Android testing account

**Note**: All aliases configured in Gmail Settings → Accounts → "Send mail as" with "Treat as an alias" checked for Google Workspace domains. This allows Cloud Functions to authenticate with primary account (eng@hamadalkhalaf.com) while sending FROM professional aliases.

**SMTP Configuration**:

- Host: smtp.gmail.com
- Port: 587 (STARTTLS)
- Secure: false (uses STARTTLS for encryption)
- Authentication: eng@hamadalkhalaf.com + Google Workspace App Password (stored in Secret Manager)
- Usage: Cloud Functions (emailAdminsOnContactMessage, requestAccountDeletion)

**Gmail Alias Loop Filtering Issue & Solution** (Discovered February 17, 2026):

**Root Cause**: Gmail automatically filters emails sent FROM alias TO alias on the same account to prevent mail loops. When Cloud Functions sent emails FROM admin@dawatime.com (alias) TO help@dawatime.com (alias), Gmail detected this pattern and delivered the email ONLY to the Sent folder, skipping the Inbox entirely.

**Symptoms**:

- Cloud Functions log showed "Email sent successfully" ✅
- Email appeared in Sent folder ✅
- Email DID NOT appear in Inbox ❌
- Users saw no notification of new contact form submission

**Investigation Timeline**:

- February 17, 11:18 AM UTC: Test with old code (TO: help@dawatime.com) → Filtered to Sent only
- February 17, 11:31 AM UTC: Fix deployed (TO changed to eng@hamadalkhalaf.com)
- February 17, 11:36 AM UTC: Test with new code → **Delivered to Inbox** ✅

**Solution**: Change TO address from alias (help@dawatime.com) to primary email (eng@hamadalkhalaf.com) while maintaining FROM alias for professional branding.

**Updated Code Pattern**:

```javascript
// Cloud Function email configuration
const mailOptions = {
  from: "DawaTime Admin <admin@dawatime.com>", // ✅ Alias for branding
  to: "eng@hamadalkhalaf.com", // ✅ Primary email (bypasses filtering)
  replyTo: userEmail, // ✅ User's email for responses
  subject: "New Contact Message",
  html: emailBody,
};
```

**Gmail "Send mail as" Configuration** (Required for Alias Sending):

- Navigate to: https://mail.google.com/mail/u/0/#settings/accounts
- Section: "Send mail as"
- Must add each @dawatime.com alias:
  - DawaTime Admin <admin@dawatime.com> ✅
  - DawaTime Design <design@dawatime.com> ✅
  - Hamad AlKhalaf <hamad@dawatime.com> ✅
  - DawaTime Support <help@dawatime.com> ✅
  - DawaTime Legal <legal@dawatime.com> ✅
- **Critical Setting**: Check "Treat as an alias" for Google Workspace domains
- **Reply Behavior**: Select "Reply from the same address the message was sent to" for professional consistency

**How Gmail Alias Sending Works**:

1. SMTP authenticates with PRIMARY account (eng@hamadalkhalaf.com)
2. FROM header uses ALIAS (admin@dawatime.com) for branding
3. TO header uses PRIMARY email (eng@hamadalkhalaf.com) to avoid filtering
4. Gmail recognizes alias is verified → allows sending
5. Recipient sees professional FROM address (admin@dawatime.com)
6. Email delivers to Inbox normally ✅

**Key Learnings**:

- ✅ Use aliases for FROM addresses (professional branding)
- ✅ Use primary email for TO addresses (avoid Gmail filtering)
- ❌ Never send FROM alias TO alias on same account (triggers loop detection)
- ✅ "Email sent successfully" in logs doesn't guarantee Inbox delivery
- ✅ Visual confirmation (user checks Inbox) critical for delivery validation

**Email Flow** (Updated February 17, 2026):

- **User submits contact form** → Firestore ContactMessages collection → Cloud Function triggered
- **Cloud Function sends email**: FROM admin@dawatime.com → TO eng@hamadalkhalaf.com
- **Email delivers to Inbox** (primary email bypasses alias loop filtering)
- **Professional appearance**: User sees "DawaTime Admin" sender
- **ReplyTo field**: Set to user's email address for easy response
- **When replying**: Gmail automatically replies FROM admin@dawatime.com (maintains consistency)

**`emailAdminsOnContactMessage` (line 291-318)**:

- Trigger: Firestore document `ContactMessages/{messageId}` onCreate
- Sends email via Nodemailer (Google Workspace SMTP: `smtp.gmail.com:587`)
- **FROM**: `admin@dawatime.com` (alias for professional branding)
- **TO**: `eng@hamadalkhalaf.com` (primary email to bypass Gmail filtering) ✅
- **SMTP Credentials**: Stored in Google Cloud Secret Manager (EMAIL_USER, EMAIL_PASSWORD)
- **Authentication**: eng@hamadalkhalaf.com + Google Workspace App Password
- **Secret Access**: Configured via `runWith({secrets: [emailUser, emailPassword]})` in function definition
- **Service Account**: medication-cd9b8@appspot.gserviceaccount.com has roles/secretmanager.secretAccessor
- **Status**: ✅ Production-ready, verified working February 17, 2026

**`requestAccountDeletion` (line 390-420)**:

- HTTPS callable function (POST only)
- Authenticates user with email/password
- Deletes Firestore user data recursively
- Deletes Firebase Auth account
- Sends confirmation email via Nodemailer (uses same Secret Manager credentials as emailAdminsOnContactMessage)
- **FROM**: `admin@dawatime.com` (alias for professional branding)
- **TO**: `eng@hamadalkhalaf.com` (primary email to bypass Gmail filtering) ✅
- **Secret Access**: Configured via `runWith({secrets: [emailUser, emailPassword]})` in function definition
- Returns success/failure JSON response
- **Status**: ✅ Production-ready with Secret Manager integration

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

#### Firebase Hosting Configuration (Multi-Site Setup)

**Status**: ✅ **MIGRATED TO MULTI-SITE** (February 19, 2026)

**Architecture Overview**:

DawaTime uses Firebase Hosting multi-site configuration to host two separate applications on a single Firebase project:

1. **Marketing Site** (target: `main`) - Static HTML site at https://dawatime.com
2. **Flutter Web App** (target: `webapp`) - Progressive web app at https://webapp.dawatime.com

**Migration History**:

- **Before**: Marketing site on Firebase Hosting (public/), Flutter webapp on Netlify
- **After**: Both sites consolidated on Firebase Hosting using multi-site architecture
- **Reason**: Simplified infrastructure by hosting all services (Auth, Firestore, Functions, Hosting) on single Firebase project
- **Date**: February 19, 2026
- **Old Sites**: medication-cd9b8 (deprecated)
- **Netlify Status**: Project deleted February 19, 2026 (custom domain had been removed, zero user impact)

**Configuration Files**:

**firebase.json** (multi-site hosting array):

```json
"hosting": [
  {
    "target": "main",
    "public": "public",
    "ignore": ["firebase.json", "**/.*", "**/node_modules/**"],
    "redirects": [
      {
        "source": "http://dawatime.com{,/**}",
        "destination": "https://dawatime.com",
        "type": 301
      },
      {
        "source": "https://www.dawatime.com{,/**}",
        "destination": "https://dawatime.com",
        "type": 301
      },
      {
        "source": "/account-deletion.html",
        "destination": "/account-deletion",
        "type": 301
      },
      {
        "source": "/user-management.html",
        "destination": "/user-management",
        "type": 301
      },
      {
        "source": "/support.html",
        "destination": "/support",
        "type": 301
      },
      {
        "source": "/privacy-policy.html",
        "destination": "/privacy-policy",
        "type": 301
      },
      {
        "source": "/terms-and-conditions.html",
        "destination": "/terms-and-conditions",
        "type": 301
      }
    ],
    "rewrites": [
      {"source": "/account-deletion", "destination": "/account-deletion.html"},
      {"source": "/user-management", "destination": "/user-management.html"},
      {"source": "/support", "destination": "/support.html"},
      {"source": "/privacy-policy", "destination": "/privacy-policy.html"},
      {"source": "/terms-and-conditions", "destination": "/terms-and-conditions.html"},
      {"source": "/", "destination": "/index.html"}
    ]
  },
  {
    "target": "webapp",
    "public": "build/web",
    "ignore": ["firebase.json", "**/.*", "**/node_modules/**"],
    "rewrites": [
      {
        "source": "**",
        "destination": "/index.html"
      }
    ]
  }
]
```

**.firebaserc** (hosting targets mapping):

```json
{
  "projects": {
    "default": "medication-cd9b8"
  },
  "targets": {
    "medication-cd9b8": {
      "hosting": {
        "main": ["dawatime-com"],
        "webapp": ["dawatime-webapp"]
      }
    }
  }
}
```

**Firebase Hosting Sites**:

1. **dawatime-com** (Marketing Site)
   - Target: `main`
   - Source Directory: `public/` (20 files)
   - Custom Domain: https://dawatime.com (connected)
   - Firebase URL: https://dawatime-com.web.app
   - SSL: Automatic (Firebase managed)

2. **dawatime-webapp** (Flutter Web App)
   - Target: `webapp`
   - Source Directory: `build/web/` (42 files, generated by `flutter build web --release`)
   - Custom Domain: https://webapp.dawatime.com (connected)
   - Firebase URL: https://dawatime-webapp.web.app
   - SSL: Automatic (Firebase managed)

3. **medication-cd9b8** (Deprecated)
   - Old default site, no longer used
   - Recommend deletion after confidence period

**Deployment Workflow**:

```bash
# Build Flutter web app (required before deploying webapp)
flutter build web --release

# Deploy both sites simultaneously
firebase deploy --only hosting

# Deploy specific target only
firebase deploy --only hosting:main    # Marketing site only
firebase deploy --only hosting:webapp  # Flutter app only
```

**DNS Configuration** (Cloudflare):
**CRITICAL**: DNS is managed by Cloudflare (nameservers: rick.ns.cloudflare.com), NOT Porkbun.

- **Domain registrar**: Porkbun (purchased June 25, 2025)
- **DNS provider**: Cloudflare (configured July 8, 2025)

**Main Domain (dawatime.com)**:

- Type: A record
- Name: `@` (apex domain)
- Target: `199.36.158.100` (Firebase Hosting IP)
- Proxy status: **Proxied** (orange cloud ON)
- TTL: Auto
- Firebase verification: TXT record `hosting-site=dawatime-com`

**WWW Subdomain Setup**:

**DNS Configuration** (Cloudflare):

- Type: CNAME
- Name: `www`
- Target: `dawatime-com.web.app` (Firebase Hosting URL for main site)
- Proxy status: **Proxied** (orange cloud ON)
- TTL: Auto

**Firebase Hosting Configuration**:

- **DO NOT add www.dawatime.com as a custom domain**
- Only configure `dawatime.com` as custom domain
- When www is configured separately, it serves content directly (HTTP 200) instead of redirecting
- The redirect rule in firebase.json only works when www routes through main domain

**How WWW Redirect Works**:

1. User visits `https://www.dawatime.com`
2. DNS CNAME points to Firebase Hosting (dawatime-com.web.app)
3. Firebase sees it's accessing www subdomain (not configured as separate domain)
4. Firebase applies redirect rule from firebase.json (www → apex)
5. User redirected with 301 to `https://dawatime.com`

**Webapp Subdomain Setup**:

**DNS Configuration** (Cloudflare):

- Type: CNAME
- Name: `webapp`
- Target: `dawatime-webapp.web.app` (Firebase Hosting URL for webapp site)
- Proxy status: **DNS only** (grey cloud OFF) - Required for Firebase SSL provisioning
- TTL: Auto

**Firebase Hosting Configuration**:

- Custom domain `webapp.dawatime.com` connected to dawatime-webapp site
- SSL certificate automatically provisioned by Firebase
- SPA routing: All requests rewritten to `/index.html` for Flutter navigation

**Cloudflare Proxy Modes**:

- **Proxied (orange cloud ON)**: Works for apex domain A records (dawatime.com, www)
- **DNS only (grey cloud OFF)**: Required for Firebase CNAME records (webapp subdomain) to allow Firebase SSL provisioning

**Troubleshooting www subdomain**:

1. **Verify www is NOT in Firebase custom domains**:
   - Navigate to: https://console.firebase.google.com/project/medication-cd9b8/hosting/sites
   - Should show `dawatime.com` on dawatime-com site (not www.dawatime.com)
   - If www.dawatime.com appears as separate custom domain, remove it

2. **Check DNS configuration**:

   ```bash
   dig @rick.ns.cloudflare.com www.dawatime.com CNAME
   # Should return: dawatime-com.web.app
   ```

3. **Test redirect**:

   ```bash
   curl -I https://www.dawatime.com
   # Should show: HTTP/2 301 Moved Permanently
   # Location: https://dawatime.com/
   ```

4. **Verify webapp subdomain**:

   ```bash
   dig @rick.ns.cloudflare.com webapp.dawatime.com CNAME
   # Should return: dawatime-webapp.web.app
   ```

5. **Clear local DNS cache** (if testing after changes):
   ```bash
   sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder
   ```

**Creating Additional Hosting Sites**:

If you need to add more Firebase Hosting sites in the future:

```bash
# Create new site (will generate unique site ID)
firebase hosting:sites:create new-site-name

# Add target to .firebaserc manually or via command
firebase target:apply hosting target-name site-id

# Add hosting configuration to firebase.json array
# Then deploy
firebase deploy --only hosting:target-name
```

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

1. **`pubspec.yaml`**: `version: 1.4.4+36` (current development version)

- Format: `<major>.<minor>.<patch>+<buildNumber>`
- Example: `1.4.4+36` = version 1.4.4, build 36
- **Production deployed**: v1.3.4 (App Store)
- **Development**: v1.4.4+36 (ready for next release)

2. **`android/app/build.gradle.kts`**:

```kotlin
versionCode = 36
versionName = "1.4.4"
```

3. **Firebase Firestore** (manual update):
   - Update `/AppConfig/Version` document field `version: "1.4.4"`
   - This triggers Cloud Function to send FCM notifications to all users
   - **Note**: Current production version in Firestore is "1.3.4" (will update to "1.4.4" on Day 14 production launch)

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
         "name": { "type": "String" }
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

### Widget Lifecycle & Context Safety (Fixed Jan 2026)

**Critical Pattern**: Always verify widget/context validity before state changes or inherited widget access.

**Problem 1: setState After Widget Disposal**

- **Symptom**: `Null check operator used on a null value at State.setState`
- **Root Cause**: Async operations complete after user navigates away, widget no longer mounted
- **Fix Pattern**:

  ```dart
  // ❌ WRONG - crashes if user navigates during async operation
  Future<void> someAsyncOperation() async {
    await Future.delayed(Duration(seconds: 2));
    setState(() => isLoading = false);  // Widget may be disposed
  }

  // ✅ CORRECT - check mounted before setState
  Future<void> someAsyncOperation() async {
    await Future.delayed(Duration(seconds: 2));
    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  // ✅ EXTRA DEFENSIVE - double-mounted check for race conditions
  // Use when widget disposal can happen between mounted check and setState execution
  Future<void> migrationOperation() async {
    await complexAsyncWork();
    if (mounted) {
      setState(() {
        if (mounted) {  // Second check prevents race condition
          isLoading = false;
        }
      });
    }
  }
  ```

- **Where this matters**: All async callbacks, timers, futures, streams
- **Real crashes fixed**: login_page.dart:616, home_page.dart:168, home_page.dart:183 (migration function race condition - Jan 26, 2026)

**Problem 2: Context Access After Disposal**

- **Symptom**: `Null check operator used on a null value at ScaffoldMessenger.of`
- **Root Cause**: Context becomes invalid in nested exception handlers during async operations
- **Fix Pattern**:

  ```dart
  // ❌ WRONG - context may be invalid in catch block
  try {
    await someOperation();
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(...);  // Crashes if context gone
  }

  // ✅ CORRECT - check context.mounted before access
  try {
    await someOperation();
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(...);
    }
  }
  ```

- **Applies to**: ScaffoldMessenger, Navigator, Theme, MediaQuery, all InheritedWidgets
- **Real crashes fixed**: home_page.dart:2842, add_medications.dart:1205 (4 validation error SnackBars - Jan 26, 2026), login_page.dart:222 (\_showLegalUpdateDialog accessing context after widget disposal - Feb 9, 2026)

**Problem 3: Unconstrained Widgets in Flex Layouts**

- **Symptom**: `A RenderFlex overflowed by X pixels`
- **Root Cause**: Text/widgets without size constraints in Row/Column exceed available space
- **Fix Pattern**:

  ```dart
  // ❌ WRONG - Text can overflow with long content
  Row(
    children: [
      Icon(Icons.label),
      SizedBox(width: 8),
      Text(longLabel),  // Unbounded width
      SizedBox(width: 8),
      Text(value),
    ],
  )

  // ✅ CORRECT - wrap dynamic content in Flexible/Expanded
  Row(
    children: [
      Icon(Icons.label),
      SizedBox(width: 8),
      Flexible(
        flex: 0,
        child: Text(
          longLabel,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ),
      SizedBox(width: 8),
      Text(value),
    ],
  )
  ```

- **When to use**: Any text that might be long (user-generated, localized, dynamic)
- **Real crashes fixed**: home_page.dart:3857 (Arabic medication labels)

**Problem 4: ProGuard/R8 Resource Stripping**

- **Symptom**: `Invalid notification (no valid small icon)` in Android release builds
- **Root Cause**: R8 removes drawables referenced by string name (not direct resource ID)
- **Fix Pattern**:
  - **Step 1**: Create keep.xml (may not work alone):
    ```xml
    <!-- android/app/src/main/res/raw/keep.xml -->
    <resources xmlns:tools="http://schemas.android.com/tools"
        tools:keep="@drawable/notification_icon" />
    ```
  - **Step 2**: Add explicit ProGuard rules (required):
    ```proguard
    # android/app/proguard-rules.pro
    -keep class **.R$drawable { *; }
    -keepclassmembers class **.R { public static <fields>; }
    -keepclassmembers class **.R$* { public static <fields>; }
    ```
- **When to use**: Notification icons, dynamically referenced drawables
- **Real crashes fixed**: Android notification icon crash (native)

**Testing Checklist**:

- ✅ Test all async flows with rapid navigation (back button, swipe gestures)
- ✅ Test error paths that show SnackBars/dialogs after async operations
- ✅ Test UI with longest possible labels (Arabic is often longer than English)
- ✅ Always test release builds on physical devices (ProGuard issues only appear in release)

---

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

**Why This Works**: Iterating weekdays 1-7 and follow-up indices 0-4 ensures all pending notifications cancelled regardless of stage, preventing stale reminders after confirmation.

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
exports.notifyOnVersionUpdate = functions.firestore
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
                  : 'https://apps.apple.com/app/dawatime/id6748280994';
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
  remove_alpha_ios: true # iOS requires non-transparent icon
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
  color: "#8AC249" # Brand green background
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

### geolocator: ^14.0.2 & geocoding: ^4.0.0

**Status**: Included for **country-based restriction checks** (GCC regional compliance).

**Usage**:

- **Country detection for geo-blocking**: Israel blocked for GCC regional compliance and political context
- **Future features**: Kuwait pharmacy locator, clinic finder
- **Not used for**: Timezone detection (handled by `flutter_timezone` instead)

**Geo-Blocking Implementation**:

- **Blocked Country**: Israel (compliance with GCC regional policies)
- **Method**: Geolocator checks user's country on app launch
- **Google Play Compliance**: NOT a violation of EU geo-blocking regulation (Israel ≠ EU, justified restriction)
- **All other countries**: Accessible, including all 27 EU member states

**Considerations**: Location permissions required, privacy-sensitive data

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
    use_build_context_synchronously: ignore # Disabled due to async/await patterns
```

**Why `use_build_context_synchronously` ignored?** App uses async operations before context access (Firestore queries, dialogs), manually checks context.mounted instead; consider re-enabling with explicit if (!mounted) return checks.

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

---

## Future Feature Roadmap

**Last Updated**: December 8, 2025

This section documents planned features for future DawaTime releases. Features are prioritized as **Major** (significant new functionality requiring substantial development) and **Minor** (smaller enhancements or quality-of-life improvements).

### Major Features (Planned)

**1. Medication Log/Progress Bar/Streaks**

- **Purpose**: Track medication adherence over time with visual progress indicators
- **Features**:
  - Calendar view showing taken/missed doses
  - Streak counter (consecutive days without missing doses)
  - Progress bar showing daily/weekly/monthly adherence percentage
  - Historical log with filtering by date range
- **Complexity**: High (requires new Firestore schema for dose history, new UI screens)
- **Estimated Effort**: 2-3 weeks
- **Dependencies**: None

**2. Caregiver (Carelink 💙) Mode**

- **Purpose**: Allow caregivers to manage medications for family members/patients
- **Features**:
  - Caregiver account linking (invite system)
  - View/manage medications for multiple care recipients
  - Receive notifications for patient's medication times
  - Shared medication history and adherence reports
- **Complexity**: High (requires user relationship management, permission system)
- **Estimated Effort**: 3-4 weeks
- **Dependencies**: May require organization developer account for healthcare features
- **Considerations**: HIPAA compliance implications, privacy policy updates needed

**3. AutoFill Medication Information**

- **Purpose**: Reduce manual data entry and improve medication safety with autocomplete
- **Features**:
  - Medication name autocomplete (English + Arabic)
  - Dosage form suggestions (tablet, syrup, injection, etc.)
  - Strength variations (500mg, 1000mg, etc.)
  - "Available in Kuwait" badge for MOH-verified medications
  - Pre-fill common dosing instructions (stretch goal)
  - Drug interaction warnings (stretch goal)
- **Complexity**: High (requires external API integration, caching strategy, government permissions)
- **Estimated Effort**: 3-4 weeks (including permission acquisition process)
- **Dependencies**: API access, internet connectivity required, **written permission from Kuwait MOH**
- **Kuwait MOH Drug Database** (Discovered January 12, 2026):
  - **Website**: https://eservices.moh.gov.kw/SPCMS/Drugdetails.aspx
  - **Drug Price List PDF**: Updated regularly (last update: November 17, 2025)
  - **Food Supplement Price List PDF**: Updated regularly (last update: October 19, 2025)
  - **Language**: Bilingual (Arabic/English) - perfect for DawaTime
  - **Coverage**: Comprehensive Kuwait pharmaceutical database
  - **Update Frequency**: Every 1-2 months based on historical data
  - **Status**: **REQUIRES WRITTEN PERMISSION** - strict copyright terms
  - **Usage**: Drug names and availability only (NOT pricing data)
- **API Options**:
  - **Primary (Kuwait focus)**: Kuwait MOH drug database (permission required)
  - **Fallback**: FDA OpenFDA (US), RxNorm, or European Medicines Agency
  - **Challenge**: Most global APIs lack Arabic medication names common in Kuwait
- **Legal Requirements** (Discovered January 12, 2026):
  - **MOH Privacy Policy**: https://www.moh.gov.kw/en/pages/PrivatePolicy.aspx
  - **Key Restriction**: "You can not create interfaces... or any other reference on this site or on any of its pages without the approval of the Ministry of Health prior written consent"
  - **Copyright**: "Copyright © 2026 Ministry of Health - Kuwait. All Rights Reserved"
  - **Action Required**: Contact MOH IT/Digital Services for written permission before implementation
  - **Positioning**: Frame as **medication safety initiative** - help users correctly identify medications and reduce errors
  - **Attribution**: Propose clear "Medication names verified against Kuwait MOH database" labeling
- **Considerations**:
  - API rate limits, offline fallback
  - Arabic medication name mapping (e.g., باراسيتامول = Paracetamol)
  - Regional brand names may differ from US/EU databases
  - **Permission timeline**: 2-4 weeks for government approval process
  - **Potential API access**: MOH may provide direct API instead of requiring PDF parsing
  - **Partnership opportunity**: Official MOH endorsement strengthens credibility and market position
  - **Public health benefit**: Reduces medication errors from misspellings or incorrect regional names

**4. Pharmacy Partnership (Kuwait/GCC Focus)**

- **Purpose**: Connect Kuwaiti users with local pharmacies for refill coordination
- **Features**:
  - Pharmacy locator (GPS-based, Kuwait first)
  - "Shopping List" export for medications needing refill
  - Share medication list via WhatsApp/SMS to pharmacy
  - Direct refill requests to pharmacy (stretch goal)
  - Integration with Kuwaiti pharmacy chains (Al-Dawaiya, Boots Kuwait, etc.) (stretch goal)
- **Complexity**: Medium (Phase 1: Low - simple export, Phase 2: High - API integrations)
- **Estimated Effort**: Phase 1: 1-2 weeks (shopping list), Phase 2: 4-6 weeks (pharmacy APIs)
- **Dependencies**:
  - Phase 1: None (simple export, no partnerships needed)
  - Phase 2: Kuwaiti pharmacy partners (Al-Dawaiya Pharmacy, Boots, Ibn Hayyan)
  - Phase 2: Business development in Kuwait
  - Phase 2: Kuwaiti health data regulations compliance
  - Phase 2: May require organization developer account
- **Phased Approach**:
  - **Phase 1** (Simple, no permissions): Export shopping list (medication names, quantities) via share sheet
    - Users can share list with any pharmacy via WhatsApp, SMS, or email
    - No MOH data integration required
    - No pharmacy API partnerships needed
    - Quick win for users needing refills
  - **Phase 2** (Complex, requires partnerships): Direct pharmacy integration
    - API connections with major Kuwait pharmacy chains
    - Real-time inventory checks (if pharmacy provides API)
    - Direct order placement (if pharmacy provides API)
- **Considerations**:
  - Start with Kuwait market validation before GCC expansion
  - Kuwait Ministry of Health regulations (if handling PHI)
  - Pharmacy licensing and data sharing agreements (Phase 2 only)
  - Not HIPAA (US-only), but similar GCC health data privacy standards
  - Phase 1 avoids all legal/partnership complexity
- **Status**: Phase 1 ready for implementation, Phase 2 exploratory

---

### Minor Features (Planned)

**Priority Order**: Features ranked by value/ease ratio - Quick wins (high value + low complexity) first, complex features last.

**1. Optional Medication Notifications**

- **Purpose**: Allow users to disable time-based reminders for specific medications (PRN/"as needed" medications)
- **Features**:
  - Checkbox in add/edit medication form (placed under refill alert section)
  - Toggle to enable/disable medication reminders per medication
  - **Conditional UI Display**:
    - When checkbox **enabled** (notifications ON):
      - Show: Notify at time picker
      - Show: Start date picker
      - Show: Frequency mode selector (Every X days / Days of week)
      - Show: All frequency-related fields (frequency number, weekday checkboxes)
    - When checkbox **disabled** (notifications OFF):
      - Hide: All scheduling UI elements (no need for timing if not notifying)
      - Show: Only basic medication info (name, dosage, amount, refill threshold)
      - Medication still tracks stock/dosage
      - Refill alerts continue to work (independent toggle)
  - Defaults to enabled (safe default for critical medications)
- **Complexity**: Low (boolean field + conditional UI rendering + notification scheduling check)
- **Estimated Effort**: 1-2 days
- **Implementation**:
  - Add `notificationsEnabled` boolean field to Medications model (default: `true`)
  - Add checkbox in add/edit form under refill alert section
  - Wrap scheduling UI in conditional: `if (notificationsEnabled) { /* show time pickers */ }`
  - Check `notificationsEnabled` before calling `scheduleMedicationNotification()`
  - Skip scheduling if disabled, but still allow manual "Take Medication" confirmation
- **UI Location**: Add/edit medication form, positioned under refill threshold field
- **User Benefit**: Proper handling of PRN medications (pain relievers, allergy meds), reduces notification fatigue for less critical medications, cleaner form for stock-only tracking
- **Safety Considerations**:
  - Always defaults to ON to protect against accidental disabling
  - Clear label: "Enable medication reminders" or "Reminder notifications"
  - Helper text: "Disable only for as-needed (PRN) medications"
- **Why Priority #1**: Highest value-to-effort ratio - solves real user pain (PRN medications), lowest complexity (1-2 days), prevents app abandonment from notification fatigue

**2. Optional End Date**

- **Purpose**: Automatically stop reminders after a specified date (e.g., antibiotics course)
- **Features**:
  - End date picker in add/edit form
  - Automatic reminder cancellation when end date reached
  - Visual indicator for time-limited medications
- **Complexity**: Low (date field addition, scheduling check)
- **Estimated Effort**: 2-3 days
- **Implementation**: Add `endDate` field, check in scheduling logic
- **Why Priority #2**: Quick win - common use case (antibiotics courses), simple implementation, clear user value

**3. Google/Apple Sign-In (OAuth)**

- **Purpose**: Faster onboarding with one-tap social authentication
- **Features**:
  - Google Sign-In integration
  - Apple Sign-In integration (required for App Store if offering third-party login)
  - Auto-populate user profile from OAuth data (name, email, photo)
  - Pre-verified email (skip verification step)
  - Legal document acceptance dialog for first-time OAuth users
  - Seamless switching between email/password and OAuth accounts
- **Complexity**: Low-Medium (OAuth well-documented in Firebase)
- **Estimated Effort**: 2-3 days
- **Implementation**:
  - Add packages: `google_sign_in: ^6.2.2`, `sign_in_with_apple: ^6.1.3`
  - Enable providers in Firebase Console
  - Add SHA-1 fingerprint for Android (Google)
  - Configure Apple Service ID in Apple Developer portal
  - Update login/signup pages with social login buttons
  - Handle first-time OAuth users (legal document acceptance, Firestore profile creation)
- **Platform Requirements**:
  - Android: SHA-1/SHA-256 certificate fingerprints
  - iOS: Sign In with Apple capability in Xcode (if offering any third-party login)
- **Regional Considerations**:
  - Google: Widely used in Kuwait/GCC (Gmail dominant)
  - Apple: Very popular (high iPhone penetration in Kuwait)
  - Both providers equally important for GCC market
- **Benefits**:
  - Higher conversion rate (no email verification wait)
  - Better UX for users already signed in to Google/Apple
  - Leverages provider security infrastructure
  - Fits GCC smartphone usage patterns
- **Why Priority #3**: High value (improves onboarding), moderate complexity (well-documented APIs), fits GCC market (Google/Apple dominant)

**4. Medication Notes**

- **Purpose**: Allow users to add custom notes to each medication
- **Features**:
  - Free-text notes field per medication
  - Display notes in medication details dialog
  - Optional notes in reminder notifications
- **Complexity**: Low (single field addition to Firestore document)
- **Estimated Effort**: 2-3 days
- **Implementation**: Add `notes` field to Medications class, update add/edit forms
- **Why Priority #4**: Simple implementation, decent user value (doctor instructions, side effects tracking), low risk

**5. Alternative Edit/Delete Medications Methods**

- **Purpose**: Provide additional UI patterns for medication management beyond swipe gestures
- **Features**:
  - Long-press context menu
  - Three-dot menu button on cards
  - Batch selection mode for multi-delete
- **Complexity**: Low-Medium (UI enhancements, no schema changes)
- **Estimated Effort**: 3-5 days
- **Rationale**: Some users may not discover swipe gestures
- **Why Priority #5**: Improves accessibility/discoverability, moderate effort, no schema changes

**6. Multiple Daily Reminders**

- **Purpose**: Support medications taken multiple times per day at specific times
- **Features**:
  - "X times per day" scheduling pattern (e.g., 3 times daily)
  - Multiple time picker for each daily dose
  - Specify times: Morning, Afternoon, Evening (or custom times)
  - Works with existing frequency modes (`everyXDays`, `daysOfWeek`)
- **Complexity**: Medium (extends existing time picker UI, requires schema update)
- **Estimated Effort**: 1 week
- **Implementation**: Change `notifyTime` from single `String` to `List<String>` in Medications model
- **Considerations**:
  - UI: Multiple time pickers in add/edit form (scrollable list)
  - Notifications: Schedule 5 follow-ups for each time slot
  - Display: Show all times in medication card (e.g., "8 AM, 2 PM, 8 PM")
  - Backward compatible: Single time = existing behavior
- **User Benefit**: Clearer than "every X hours" - users think in "times per day" not intervals
- **Why Priority #6**: High user value (fills scheduling gap), but medium complexity (schema changes, UI updates)

**7. Choose Your Own Medication Icons**

- **Purpose**: Visual differentiation with customizable icons and colors
- **Features**:
  - Icon selection: Pill, Injection, Ointment, Liquid, Inhaler
  - Color picker for medication cards
  - Icons persist in medication list and reminders
- **Complexity**: Medium (requires asset management, color picker UI)
- **Estimated Effort**: 1 week
- **Implementation**: Add `iconType` and `colorHex` fields, create icon asset library
- **Why Priority #7**: Lowest priority - cosmetic feature, requires asset library creation, moderate effort for low functional value

---

### Completed Features ✓

**1. Refill Reminder System** (Implemented January 2026)

- Weekly refill notifications when stock below threshold
- Customizable day of week and time (default: Sunday 10:00 AM)
- Color-coded cards (orange = low stock, red = out of stock)

**2. Days of the Week Reminders** (Implemented August 2025)

- Schedule medications for specific weekdays (e.g., Mon/Wed/Fri)
- Supports complex patterns (e.g., Monday-Friday only)
- Independent from "every X days" frequency mode

**3. Arabic Language** (Implemented August 2025)

- Full bilingual support (English/Arabic)
- RTL layout for Arabic text
- Localized date/time formatting
- 192 English strings, 194 Arabic strings

**4. Play Integrity API (Security)** (Implemented January 2026)

- App authenticity verification and tamper protection
- Device integrity checks for rooted/compromised devices
- Backend token validation via Firebase Cloud Function
- Deployed as v1.4.5+52 on Day 19 (January 25, 2026)

**5. Safe URL Launching** (Implemented January 2026)

- Fixed iOS SafariViewController crashes from url_launcher
- Added canLaunchUrl() validation before all launchUrl() calls (16 locations)
- Graceful error handling with SnackBar feedback
- Deployed as v1.4.5+54, confirmed via Crashlytics validation

**6. Update Checker Bug Fix** (Implemented January 2026)

- Fixed false "up to date" message after version changes
- Added version change detection via SharedPreferences
- Clears 24-hour cache when app version doesn't match stored version
- Ensures force update mechanism works reliably for security fixes

**7. Signup Buttons Android Fix** (Implemented January 2026)

- Fixed Terms & Privacy links not working on Android signup page
- Added Android 11+ package queries in AndroidManifest.xml
- Changed LaunchMode.platformDefault → LaunchMode.externalApplication
- Unblocked new user signups on Android devices

---

## Feature Implementation Guidance

**When implementing new features**:

1. **Start with Design**:
   - Create user flow diagrams
   - Sketch UI mockups
   - Identify Firestore schema changes

2. **Consider Migration**:
   - Will existing users need data migration?
   - Can new features coexist with old data?
   - Plan backward compatibility strategy

3. **Update Firestore Rules**:
   - Add validation for new fields
   - Maintain security for user data isolation

4. **Localization First** (Arabic-Primary Approach):
   - Add all strings to `app_en.arb` and `app_ar.arb` simultaneously
   - Test RTL layout for Arabic first (primary audience)
   - Use `AppLocalizations.of(context)!` everywhere
   - Consider Arabic text length in UI design (often longer than English)
   - Validate cultural appropriateness for GCC market

5. **Notification Integration**:
   - How does feature affect notification scheduling?
   - Update `medication_notifications.dart` if needed
   - Test all 5 follow-up reminder patterns

6. **Version Management**:
   - Increment minor version for features (e.g., 1.4.4 → 1.5.0)
   - Increment patch version for bugs (e.g., 1.4.4 → 1.4.5)
   - Update both iOS and Android simultaneously

7. **Documentation**:
   - Update copilot-instructions.md with architecture details
   - Document new database fields
   - Add code examples for complex logic

---

**Priority Recommendations**:

**Quick Wins (Implement Soon)**:

- Medication Notes (low complexity, high user value)
- Optional End Date (low complexity, common use case)
- Alternative Edit/Delete Methods (accessibility improvement)

**Medium-Term Goals**:

- Google/Apple Sign-In (higher conversion, better UX, fits GCC market)
- Multiple Daily Reminders (fills scheduling gap, cleaner than interval-based)
- Choose Your Own Medication Icons (personalization, user engagement)
- Medication Log/Progress Bar/Streaks (gamification, adherence tracking)

**Long-Term Investments**:

- AutoFill Medication Information (requires API partnership, Arabic medication names)
- Caregiver Mode (requires significant architecture changes)
- Pharmacy Partnership (Kuwait-focused makes this more feasible than global approach)

---

## Monetization Strategy

**Last Updated**: January 12, 2026

**Core Principle**: DawaTime is positioned as a **public health initiative** first, commercial product second. Monetization must never compromise user trust, medication safety, or Kuwait MOH partnership opportunities.

### Current Status (v1.4.4+50)

- **100% Free**: No ads, no paywalls, no premium tiers
- **User Base**: Building trust and market validation
- **Focus**: Growth, MOH partnership, user acquisition
- **Revenue**: $0 (intentional)

### Phase 1: Free-to-Grow (2026-2027)

**Strategy**: Stay completely free to maximize user base and establish market presence.

**Current Status** (February 2026 - Day 44): 118 registered users (113 real + 5 dev/test accounts | 68 pre-testing + 15 closed testing + 35 post-launch)

**Growth Milestones** (Conditional Timeline):

- **Q1 2026** (Jan-Mar): Production launch → **Target: 200-300 users** (recalibrated based on historical 19.6/month average, 0.48/day organic post-campaign)
- **Q2 2026** (Apr-Jun): MOH partnership + minor features → **Target: 400-600 users** (4 quick-win features improve retention, MOH partnership boost)
- **Q3 2026** (Jul-Sep): AutoFill implementation → **Target: 800-1,200 users** (AutoFill differentiation drives acquisition)
- **Q4 2026** (Oct-Dec): Evaluate freemium readiness → **Decision Point: 1,200-1,800 users realistic by year-end**

**Decision Framework (Q4 2026)** (Revised - Realistic Thresholds):

- ✅ **If 1,500+ users**: Proceed to Phase 2 freemium development (Q3-Q4 2027 launch, extended timeline)
- ⏸️ **If 800-1,500 users**: Delay freemium to 2028, focus on sustained growth through 2027
- ❌ **If <800 users**: Reassess product-market fit, consider pivot or niche positioning

**Goals**:

- Reach critical mass in Kuwait market (1,500+ by year-end 2026, 3,000+ by mid-2027)
- Secure Kuwait MOH partnership for drug database (Q2 2026)
- Build reputation as trusted public health tool
- Validate product-market fit with strong retention metrics (40%+ 30-day retention)
- Achieve sustainable organic growth (3-5 users/day baseline by Q4 2026)

**Why No Monetization Yet**: MOH partnership easier non-commercial, user trust critical (ads erode immediately), App Store reviews higher, word-of-mouth stronger for "truly free", current user base insufficient for viable freemium conversion (need 1,500+ minimum).

### Phase 2: Freemium Launch (Conditional: Q1 2028+)

**Strategy**: Introduce gentle freemium model with generous free tier.

**Prerequisite Milestones** (Must hit BEFORE launching freemium):

- ✅ **2,500-3,000+ active users** (minimum viable conversion pool)
- ✅ **4.5+ App Store rating** (50+ reviews minimum)
- ✅ **40%+ 30-day retention** (users find value)
- ✅ **Premium features built** (Caregiver Mode, Medication Log)
- ✅ **MOH partnership secured** (optional but strengthens positioning)

**If Prerequisites Not Met**: Stay free, continue growing, reassess quarterly.

**Free Tier** (Forever Free):

- **4 medications** (covers 70-80% of users - most take 1-3 regular medications)
- All core reminder features (5 follow-ups, weekday scheduling)
- Refill tracking and low-stock alerts
- Arabic/English bilingual support
- Theme customization
- Basic app functionality

**Premium Tier** ("DawaTime Plus" - 1-2 KWD/month, ~$3-6 USD):

- **12+ medications** (unlimited, or higher cap like 25)
- **Caregiver Mode**: Manage medications for family members
- **Medication Log**: Full history and adherence tracking
- **Progress Bar/Streaks**: Gamification and adherence insights
- **Priority Support**: Email/WhatsApp support channel
- **Custom Icons**: Personalize medication appearance
- **Export Reports**: PDF medication schedules for doctors
- **"Ad-Free Forever" Badge**: Marketing (even though free tier has no ads)

**Pricing Strategy (Kuwait Market)**:

- **Monthly**: 1.5 KWD (~$5 USD)
- **Annual**: 15 KWD (~$50 USD) - save 17% (2 months free)
- **Kuwait Purchasing Power**: Very affordable (coffee costs 1-2 KWD)
- **GCC Expansion**: Same pricing in KWD across Kuwait, Saudi, UAE, Qatar, Bahrain

**Why 4-Medication Limit Works**:

- ✅ **Generous enough**: Most users (70-80%) take 1-3 medications regularly
- ✅ **Clear value prop**: Users with chronic conditions (5+ meds) see immediate need for premium
- ✅ **Not exploitative**: 4 medications is substantial - not artificially restrictive
- ✅ **Caregiver upsell**: Families managing elderly parents need more slots = premium

**Implementation Considerations**:

- Grandfather existing users: Anyone with 5+ medications before freemium launch gets free premium for 1 year
- Clear messaging: "DawaTime will always have a generous free tier"
- App Store compliance: Clearly communicate limitations before download
- Revenue sharing: 30% to Apple/Google, 70% to DawaTime

### Phase 3: B2B Revenue (Conditional: 2029+)

**Strategy**: Enterprise licensing to healthcare providers and insurers.

**Prerequisite** (Must validate consumer model first):

- ✅ **Freemium launched and stable** for 6+ months
- ✅ **5%+ conversion rate validated** (proving value proposition)
- ✅ **1,000+ paying subscribers** (demonstrates market demand)
- ✅ **<5% monthly churn** (sustainable retention)

**If Prerequisites Not Met**: Focus on improving freemium conversion before B2B outreach.

**Target Customers**:

1. **Kuwait Health Insurance Companies**:
   - Medication adherence tracking for insured members
   - Reduces costs (non-adherence = more hospital visits)
   - Pricing: 2-3 KWD per user/year

2. **Healthcare Providers** (Hospitals, Clinics):
   - White-label DawaTime for patient discharge
   - Post-surgery medication compliance tracking
   - Pricing: 5-10 KWD per patient

3. **Employers** (Wellness Programs):
   - Employee health benefits
   - Chronic disease management for staff
   - Pricing: 1-2 KWD per employee/year

4. **Pharmacy Chains** (Partnership Model):
   - Small commission (0.25-0.5 KWD) per successful refill order
   - Featured pharmacy listings (not ads)
   - Win-win: Users get convenience, pharmacies get customers

**Why B2B Works Long-Term**: Higher revenue potential than consumer subscriptions, app remains free/cheap for users, aligns with public health mission, validates DawaTime as serious healthcare tool.

### Alternative Monetization (Considered & Rejected)

**❌ In-App Advertising**:

- **Rejected**: Damages trust in health apps
- **Rejected**: Undermines MOH partnership positioning
- **Rejected**: Poor user experience for time-sensitive reminders
- **Rejected**: Ethical concerns (advertising to chronically ill users)
- **Rejected**: Low revenue (CPM rates poor in Kuwait market)

**❌ Selling User Data**:

- **Rejected**: Illegal under Kuwait/GCC health data regulations
- **Rejected**: Complete trust violation
- **Rejected**: Destroys public health positioning

**✅ Optional Donations** (Phase 1-2):

- "Buy us a coffee" button in Settings
- One-time or recurring monthly donations
- Transparency: "100% goes to server costs and development"
- Non-intrusive, builds community goodwill

**✅ Government Grants** (Phase 1-3):

- Kuwait Foundation for the Advancement of Sciences (KFAS)
- Kuwait Ministry of Health public health initiatives
- GCC health innovation grants
- Position: "Reducing medication non-adherence saves healthcare system millions"

### Financial Projections (Rough Estimates)

**Current State** (February 2026 - Day 44): 118 users (113 real + 5 excluded accounts), $0 revenue

**2026** (Phase 1 - Free Growth):

- Revenue: $0
- Costs: ~$2,000-3,000/year (Firebase, hosting, developer time)
- Goal: User growth, not profit
- **Target**: 118 → 1,200-1,800 users by year end (realistic based on 0.48/day organic baseline + feature improvements + marketing campaigns)

**2027** (Phase 1 - Continued Free Growth):

- Revenue: $0
- Costs: ~$2,000-3,000/year (Firebase, hosting, developer time)
- Goal: Reach 3,000+ users for freemium viability
- **Target**: 1,500 (end of 2026) → 2,500-3,000 users by mid-2027

**Q1 2028** (Phase 2 - Conditional Freemium):

- **Assumption**: Freemium launches if 2,500-3,000+ users achieved by Q3 2027
- **Scenario A** (2,500 users, 5% conversion = 125 paying):
  - MRR: 125 × 1.5 KWD × $3.30 = ~$618/month (~$7,416/year)
  - After App Store fees: ~$5,200/year
  - Net Profit: ~$2,200/year (after costs)
- **Scenario B** (3,000 users, 5% conversion = 150 paying):
  - MRR: 150 × 1.5 KWD × $3.30 = ~$742/month (~$8,900/year)
  - After App Store fees: ~$6,200/year
  - Net Profit: ~$3,200/year (after costs)

**2029** (Phase 2 - Mature Freemium):

- **Assumption**: 10,000 active users (if growth continues)
- **Conversion Rate**: 5-10% to premium (500-1,000 paying users)
- **MRR**: 500 users × 1.5 KWD × $3.30 = ~$2,475/month (~$30,000/year)
- **After App Store fees**: ~$21,000/year
- **Net Profit**: ~$18,000/year (after costs)

**2029+** (Phase 3 - B2B Launch):

- **Assumption**: 1 insurance company partnership (50,000 members)
- **Pricing**: 2 KWD per user/year × $3.30 = $6.60/user
- **Annual Revenue**: 50,000 × $6.60 = $330,000/year
- **Combined with consumer**: ~$350,000/year total

**Note**: All projections conditional on hitting user growth milestones. Kuwait market has high smartphone penetration (99%) and willingness to pay for quality apps.

### Implementation Timeline (Milestone-Driven)

**Current State** (February 2026 - Day 44): 118 users (68 pre-testing + 15 closed testing + 35 post-launch), production launched Day 15

**Q1 2026** (Jan-Mar): **Production Launch & Stability**

- Focus: Production approval, bug fixes, user feedback
- Marketing: Instagram, Kuwait forums, word-of-mouth
- Monetization: None
- **Milestone Target**: 200-300 users (recalibrated based on historical growth: 19.6 users/month average, 0.48 users/day organic post-campaign)
- **Current Progress (Day 44)**: 118 users (113 real + 5 excluded accounts: personal hamad_alkhalaf_99, testing hamad@dawatime, Apple/Google testing, designer design@dawatime), 7-day ad campaign complete (289 website visits, 61 store downloads during campaign period), iOS total downloads: 57 (Jan 20-Feb 18)
- **Decision Point**: If <200 users by March 31, maintain free growth through Q2 and reassess marketing strategy

**Q2 2026** (Apr-Jun): **MOH Partnership & Quick Wins**

- Focus: Submit MOH partnership request (2-4 weeks approval)
- Build: **Optional Medication Notifications** (NEW #1 priority - prevents notification fatigue), Optional End Date, Google/Apple Sign-In, Medication Notes
- Monetization: Optional donations button (soft ask)
- **Milestone Target**: 400-600 users (from ~250 Q1 end, need 150-350 new in 90 days = 1.7-3.9/day)
- **Decision Point**: If <400 users by June 30, reassess feature-market fit and marketing effectiveness
- **Rationale**: All 4 features are "quick wins" (2-3 days each), improve retention, support Phase 1 growth goals

**Q3 2026** (Jul-Sep): **AutoFill Development**

- Focus: Implement AutoFill Medication (with MOH approval)
- Build: Multiple Daily Reminders, Alternative Edit/Delete Methods
- Marketing: AutoFill as unique selling point (Kuwait MOH database integration)
- **Milestone Target**: 800-1,200 users (from ~500 Q2 end, need 300-700 new in 92 days = 3.3-7.6/day)
- **Decision Point**: If <800 users by September 30, evaluate AutoFill feature adoption and user acquisition effectiveness

**Q4 2026** (Oct-Dec): **CRITICAL DECISION POINT**

- **Evaluate**: Year-end user count and growth trajectory
  - ✅ **STRONG (1,500+ users)**: Proceed to Phase 2 freemium development (Q3-Q4 2027 launch)
    - Realistic path to 3,000+ by mid-2027
    - Start building: Caregiver Mode, Medication Log, subscription system
    - **Note**: Business registration still blocked by MEW employment
  - ⏸️ **MODERATE (800-1,500 users)**: Delay freemium to 2028, continue free growth through 2027
    - Focus on retention optimization and organic acquisition
    - Evaluate marketing ROI and feature adoption
  - ❌ **WEAK (<800 users)**: Reassess product-market fit and strategic direction
    - Analyze why growth stalled despite feature improvements
    - Consider niche positioning (chronic illness, elderly care focus)
    - Evaluate pivot opportunities or Kuwait-specific partnerships

**MEW Employment Impact on Freemium**: Kuwait government employees cannot register commercial businesses. Freemium model can still launch via personal developer accounts, but B2B partnerships (Phase 3) would require business registration and thus leaving MEW employment.

**Q3-Q4 2027** (Conditional): **Freemium Development** (if 1,500+ users by Q4 2026)

- Build: Caregiver Mode (3-4 weeks), Medication Log (2-3 weeks)
- Implement: App Store subscriptions, Google Play Billing
- Test: Pricing, messaging, grandfather logic
- Marketing: Announce "New premium features coming!"
- **Prerequisite**: Sustained growth to 2,500-3,000+ users by Q3 2027

**Q1 2028** (Conditional): **Freemium Launch** (if prerequisites met)

- Launch: 4-medication free tier, premium tier with pricing
- Monitor: Conversion rates, churn, user feedback
- Iterate: Adjust pricing/features based on data
- **Milestone Target**: 5% conversion rate (125-150 paying users minimum from 2,500-3,000 user base)

**2028**: **Freemium Optimization**

- Analyze: What drives conversions? What causes churn?
- Improve: Premium features based on feedback
- Market: Premium tier value proposition
- **Milestone Target**: 1,000+ paying subscribers

**2029+** (Conditional): **B2B Outreach** (if freemium validated)

- Outreach: Kuwait health insurers, healthcare providers
- Goal: First enterprise partnership
- Prerequisite: Proven consumer model with stable revenue
- **CRITICAL BLOCKER**: Requires business registration → **Must leave MEW employment first** (Kuwait government employees cannot register commercial businesses)
- Timeline dependent on career transition from government to private sector

### Key Success Metrics

**Phase 1** (Free Growth) - **MOST CRITICAL**:

- **User Growth Rate**: Q1: 200-300 | Q2: 400-600 | Q3: 800-1,200 | Q4: 1,200-1,800 (2026 targets)
- **User Retention**: 30-day retention >40% (users find value)
- **App Store Rating**: 4.5+ stars (50+ reviews minimum)
- **DAU/MAU Ratio**: >30% (users open app regularly)
- **MOH Partnership Status**: Approved by Q2-Q3 2026
- **Quarterly Milestone Tracking**: Hit/miss targets trigger strategic adjustments

**Phase 2** (Freemium):

- Conversion rate (free → premium)
- Monthly Recurring Revenue (MRR)
- Customer Lifetime Value (LTV)
- Churn rate (target: <5% monthly)

**Phase 3** (B2B):

- Enterprise contracts signed
- Annual Recurring Revenue (ARR)
- B2B customer retention

### Guiding Principles

1. **User Trust First**: Never compromise medication safety for revenue
2. **Generous Free Tier**: 4 medications covers most users, not artificially restrictive
3. **Clear Value Proposition**: Premium features justify cost (Caregiver Mode, unlimited meds)
4. **Kuwait Market Fit**: Pricing affordable for local purchasing power
5. **Public Health Mission**: Monetization supports sustainability, not exploitation
6. **MOH Partnership**: Commercial strategy doesn't undermine government relationship
7. **Ethical Marketing**: No dark patterns, no aggressive upselling, transparent pricing

---
