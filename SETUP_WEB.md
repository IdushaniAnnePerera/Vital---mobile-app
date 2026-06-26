# Vital — Web Setup Guide

## What changed

| Before | After |
|--------|-------|
| SQLite (mobile only) | Firebase Firestore (web + mobile + sync) |
| Local notifications | Stub (web) / ready for mobile |
| No auth | Google Sign-In via Firebase |
| Mobile navigation bar | Responsive: sidebar on wide screens, bar on mobile |

---

## Step 1 — Add the web platform

Run this once in the project root to generate the `web/` folder:

```bash
flutter create --platforms=web .
```

---

## Step 2 — Create a Firebase project

1. Go to [console.firebase.google.com](https://console.firebase.google.com/)
2. **Create project** (or use an existing one)
3. **Authentication → Sign-in method → Google** → Enable it
4. **Firestore Database → Create database** → start in **test mode** for now
5. **Project Settings → Your apps → Add app → Web (</> icon)**
   - Copy the `firebaseConfig` values shown

---

## Step 3 — Configure Firebase in the app

**Fastest method — FlutterFire CLI (recommended):**

```bash
# Install once
dart pub global activate flutterfire_cli

# Run in your project directory
flutterfire configure --project=YOUR_PROJECT_ID
```

This auto-generates `lib/firebase_options.dart` with all the correct values.

**Manual method:**

Open `lib/firebase_options.dart` and replace every `YOUR_*` placeholder with the values from Firebase Console → Project Settings.

---

## Step 4 — Install dependencies

```bash
flutter pub get
```

---

## Step 5 — Run on web

```bash
flutter run -d chrome
```

Or build for production:

```bash
flutter build web
```

---

## Step 6 — Firestore security rules (before going live)

Replace the default test-mode rules in Firebase Console → Firestore → Rules:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{uid}/{document=**} {
      allow read, write: if request.auth != null && request.auth.uid == uid;
    }
  }
}
```

---

## Notes

- **Medication reminders** are a no-op on web (browser doesn't support local push). The time is stored in Firestore and shows in the UI. Re-adding mobile notifications is straightforward using `flutter_local_notifications` once you target Android/iOS.
- **Data sync**: because data lives in Firestore, signing in on any device shows the same history.
- **Offline**: Firestore has built-in offline caching — the app keeps working when the connection drops.
