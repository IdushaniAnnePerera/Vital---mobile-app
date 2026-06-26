# Vital — a personal health companion

A cross-platform mobile app that brings five everyday health habits into one calm, offline-first place: **step logging, workout planning, meal/calorie tracking, medication reminders, and sleep tracking.**

Built with Flutter. All data is stored locally on the device with SQLite — no account, no backend, no internet required.

---

## Features

| Domain | What it does |
|---|---|
| **Steps** | Log daily steps against a goal, see a 7-day bar chart and goal progress. |
| **Workouts** | Plan sessions (run, strength, cycling, yoga, swim, walk) with duration and calories; running totals. |
| **Meals** | Log meals by type with calories, track against a daily goal with live "remaining" feedback. |
| **Medication** | Add medications with a dosage and time; get a **scheduled daily local notification**. |
| **Sleep** | Log hours and a 1–5 quality rating; view a 7-night trend line and weekly average. |

A home dashboard summarises today across all five domains at a glance.

## Tech stack

- **Flutter** (Material 3, custom design system)
- **SQLite** via `sqflite` for local persistence
- **fl_chart** for the weekly bar and line charts
- **flutter_local_notifications** + `timezone` for daily medication reminders
- **intl** for date and number formatting

## Architecture

```
lib/
├── main.dart                 # App entry + bottom-nav shell
├── theme/app_theme.dart      # Design tokens (colors, type, components)
├── models/models.dart        # Plain data models (one per domain)
├── services/
│   ├── database_service.dart # Single SQLite DB, one table per domain
│   └── notification_service.dart # Scheduled local notifications
├── screens/                  # One screen per domain + dashboard
└── widgets/common.dart       # Shared UI (cards, stat blocks, empty states)
```

A clean **UI → service → SQLite** separation: screens never touch the database directly except through `DatabaseService`, which keeps each table's logic in one place.

## Run it locally

```bash
flutter pub get
flutter run
```

Requires Flutter 3.3+ and a connected device or emulator. See `RUN_GUIDE.md` for step-by-step setup including Android/iOS notification permissions.

## Possible extensions

- Cloud sync (Firebase) for multi-device use
- Health platform integration (Google Fit / Apple Health) for automatic step import
- Weekly insight summaries and trend detection
- Export to CSV / PDF health report

---

Built by **H.I.A. Perera** · BSc (Hons) Computer Science, University of Kelaniya.
