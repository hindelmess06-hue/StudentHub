# Student Hub (UEMF)

A Flutter app that puts university announcements, events, clubs and campus
information in one place. Dark, glassy, animated UI with four switchable accent
colours.

## What's inside

| Area | What it does |
| --- | --- |
| **Sign-up / Sign-in** | Only `@ueuromed.org` (and subdomains) accepted. Live email validation, typo suggestions ("Did you mean @ueuromed.org?"), password strength meter. |
| **Email verification** | Nobody enters the app until the email is verified. A non-existent address never receives the message, so it can never be verified. |
| **Home** | Greeting, pinned announcement, stats, latest news carousel, upcoming events, clubs to discover, global search. |
| **News** | Categories, search, unread dots, save/bookmark, detail page. Publishers can post. |
| **Events** | 14-day date strip with event dots, category filter, "I'm going" agenda, detail page. |
| **Clubs** | Category filter, follow/unfollow, club page with updates timeline, upcoming events, contact. |
| **Campus** | Services with live "Open / Closed" status, hours, locations, useful contacts. |
| **Profile** | Verified badge, counters, accent colour picker, sign out. |

## 1. Run it (Demo mode, 5 minutes)

Demo mode needs no backend. Accounts live on the phone and the verification
"email" is a 6-digit code shown on screen. **No real email is sent in this mode.**

```bash
# 1. Install Flutter: https://docs.flutter.dev/get-started/install
# 2. In this folder, generate the Android project files:
flutter create . --platforms=android --org ma.ueuromed --project-name student_hub
# 3. Get packages and run on an emulator or a USB-connected phone:
flutter pub get
flutter run
```

Tip: sign up as `admin@ueuromed.org` in Demo mode to see the **Publisher**
features (the "+" button on the News tab).

## 2. Real email verification (Firebase)

This is what makes "the email must exist" real. Firebase sends a verification
link to the address; the app stays locked until it is opened.

1. Create a project at https://console.firebase.google.com
2. **Authentication → Sign-in method → Email/Password → Enable**
3. In this folder:
   ```bash
   dart pub global activate flutterfire_cli
   firebase login
   flutterfire configure        # choose your project, platform: Android
   ```
   This overwrites `lib/firebase_options.dart` with your real settings.
4. Open `android/app/build.gradle(.kts)` and make sure `minSdk` is at least **23**.
5. Run with Firebase switched on:
   ```bash
   flutter run --dart-define=USE_FIREBASE=true
   ```

Optional: customise the verification email text in Firebase console →
Authentication → Templates.

## 3. Hardening (do this before a real launch)

The domain check inside the app gives instant feedback but **can be bypassed**
by someone talking to Firebase directly. The real guarantees are:

- **Verified email required.** The app already blocks unverified accounts.
- **Server-side rules.** Whatever data you store (Firestore, Storage), require:
  `request.auth.token.email_verified == true &&
  request.auth.token.email.matches('.*@ueuromed[.]org')`
- **Block other domains at creation.** Firebase Auth *blocking functions*
  (`beforeCreate`, needs Identity Platform) can reject any non-UEMF email.
- **Publisher rights.** `AppConfig.publisherEmails` is a prototype shortcut.
  In production, use Firebase custom claims set by an admin.

## 4. Build the APK

Make sure `android/app/src/main/AndroidManifest.xml` contains
`<uses-permission android:name="android.permission.INTERNET"/>` (release
builds need it for Firebase and fonts), then:

```bash
flutter build apk --release --dart-define=USE_FIREBASE=true
# result: build/app/outputs/flutter-apk/app-release.apk
```

## Important notes

- **Sample content.** Announcements, events, clubs, opening hours and contact
  emails in `lib/data/seed_data.dart` are placeholders. Replace them with the
  university's real data.
- **Data is local.** Follows, "going", bookmarks and posts published from the
  app are stored on the device. To share content between students and let
  admins publish for everyone, move the content to a shared backend
  (Cloud Firestore is the natural next step; `AppState` is the only file that
  would need to change).
- **Fonts** (Space Grotesk, Inter) load through `google_fonts` on first use.
  To work fully offline, bundle them as assets.
- **Not verified on a device by the author.** This project was written without a
  Flutter toolchain available, so it has not been compiled or run. Expect to
  fix a few small compile errors on first build (run `flutter analyze` and
  `flutter test`).

## Project layout

```
lib/
  main.dart                 app entry, routes by auth status
  app_config.dart           domains, publishers, Demo/Firebase switch
  firebase_options.dart     placeholder, overwritten by flutterfire configure
  theme/app_theme.dart      colours, fonts, accent palettes
  models/models.dart        Announcement, CampusEvent, Club, CampusService...
  data/seed_data.dart       sample content
  services/
    email_rules.dart        UEMF-only validation + typo suggestions
    auth_service.dart       Firebase + Demo implementations
  state/app_state.dart      session, follows, going, saved, publishing
  widgets/                  shared UI (aurora background, cards, nav bar...)
  screens/                  auth, verify, home, news, events, clubs, campus, profile, search
test/widget_test.dart       unit tests for the email rules
```

## Ideas for next steps

Push notifications for followed clubs, add-to-calendar, a real campus map,
Arabic / French / English localisation, club admin dashboards, event QR
check-in, and a Firestore backend.
=======
# StudentHub
>>>>>>> 0ddad2e3ef1102ba4994084c2a3507de4f86aa56
