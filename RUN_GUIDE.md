# How to run Vital — step by step

This guide takes you from zero to the app running on your phone or an emulator.

---

## 1. Install Flutter (one-time)

1. Download Flutter from https://docs.flutter.dev/get-started/install (pick your OS — Windows is fine).
2. Unzip it somewhere like `C:\src\flutter` (avoid paths with spaces).
3. Add `flutter\bin` to your system PATH.
4. Open a new terminal and check everything:

```bash
flutter doctor
```

Fix anything it flags with a ✗. For Android you'll need **Android Studio** installed (it brings the Android SDK + an emulator). Accept the Android licenses once:

```bash
flutter doctor --android-licenses
```

## 2. Get the project files

Copy the `vital_app` folder (the one with `pubspec.yaml` inside) to your machine, then open a terminal **inside that folder**:

```bash
cd path/to/vital_app
```

## 3. Install dependencies

```bash
flutter pub get
```

This downloads every package listed in `pubspec.yaml` (sqflite, fl_chart, notifications, etc.).

## 4. Add Android permissions for notifications

Open `android/app/src/main/AndroidManifest.xml` (Flutter generates the `android/` folder the first time you build — run `flutter run` once if you don't see it yet, then add this).

Inside `<manifest>` but **above** `<application>`, add:

```xml
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
```

Then inside `<application>`, add this receiver block (lets reminders survive a reboot):

```xml
<receiver android:exported="false" android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver" />
<receiver android:exported="false" android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver">
  <intent-filter>
    <action android:name="android.intent.action.BOOT_COMPLETED"/>
  </intent-filter>
</receiver>
```

## 5. Run the app

**Option A — real Android phone (easiest):**
1. On your phone: Settings → About phone → tap "Build number" 7 times to unlock Developer options.
2. In Developer options, turn on **USB debugging**.
3. Plug the phone into your computer, accept the prompt.
4. Confirm it's detected:

```bash
flutter devices
```

5. Run:

```bash
flutter run
```

**Option B — Android emulator:**
1. Open Android Studio → Device Manager → create a virtual device (e.g. Pixel 7).
2. Start it, then run `flutter run`.

The first build takes a few minutes. After that, save a file and press `r` in the terminal for instant hot reload.

## 6. Try the features

- **Steps**: tap "Log steps", enter a number — watch the bar chart fill over a few days.
- **Workouts**: add a session, see totals update.
- **Meals**: log a meal, watch the "remaining" calories change.
- **Medication**: add one with a time a minute or two ahead — you'll get a real notification. Allow the permission prompt.
- **Sleep**: log hours + quality, see the trend line after two nights.

## 7. Build a release APK (to share or install directly)

```bash
flutter build apk --release
```

The file lands in `build/app/outputs/flutter-apk/app-release.apk`. You can send this to any Android phone to install.

---

## Common issues

- **`flutter: command not found`** → Flutter isn't on your PATH. Redo step 1.4.
- **No devices** → phone not in USB-debugging mode, or emulator not started.
- **Notifications don't fire** → make sure you allowed the permission, and on some phones disable battery optimization for the app.
- **Build fails on first run** → run `flutter clean` then `flutter pub get` and try again.

That's it — you now have a real, installable Flutter app to put on your CV and GitHub.
