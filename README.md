# SeaList 🌊

"เคลียร์หัว แล้วไปใช้ชีวิตต่อ" — Clear your mind, then go live your life.

A calm, offline-first Todo + Notes + Reminders app. No Firebase, no login,
no accounts — everything lives on the device.

## Getting started

```bash
flutter pub get
flutter run
```

That's it — no backend, no API keys, no `.env` file. Data currently lives in
memory (see "Persistence" below) and is seeded with a few sample tasks/notes
so the app looks alive on first run.

## Project structure

```
lib/
  main.dart                      entry point (sets up Thai date symbols + notifications)
  app/
    app.dart                     MaterialApp + MultiProvider wiring + Thai localization
    theme.dart                   ThemeData: rounded cards, soft shadows, Mali/Sarabun fonts
    text_styles.dart             AppText.heading (the cute Mali heading style)
    colors.dart                  the ocean + pastel color palette, all in one place
  models/
    task_item.dart                Task model + Priority / ReminderType enums
    note_item.dart                Note model
  providers/
    task_provider.dart            in-memory task state (add/update/delete/toggle)
    note_provider.dart            in-memory note state (add/update/delete/pin/search)
    settings_provider.dart        notification toggle, default reminder time
  services/
    notification_service.dart     flutter_local_notifications wrapper
  widgets/
    main_shell.dart               bottom nav shell (Today / Notes / Settings)
    wave_header.dart               layered waves + bubbles behind the Today greeting
    empty_state.dart               reusable calm empty-state widget (with the mascot)
    sea_mascot.dart                "Sea" the seal, drawn with CustomPaint (no assets)
    soft_card.dart                 the shared rounded/soft-shadow card
    gradient_fab.dart              ocean-gradient "+" button
  screens/
    today/
      today_screen.dart
      widgets/
        task_tile.dart
        progress_ring.dart
        quick_add_sheet.dart      the "+" bottom sheet (Task / Note / Reminder)
    task/
      task_detail_screen.dart
      edit_task_screen.dart
    notes/
      notes_screen.dart
      note_detail_screen.dart
      edit_note_screen.dart       used for both "create" and "edit"
      widgets/
        note_card.dart
    settings/
      settings_screen.dart
    onboarding/
      notification_permission_screen.dart
```

Everything is grouped by feature (`today/`, `task/`, `notes/`, `settings/`,
`onboarding/`), with cross-cutting stuff (`theme`, `models`, `providers`,
`services`, shared `widgets`) pulled out to their own top-level folders —
so if V2 adds a feature, it gets its own folder and doesn't tangle with the
others.

## State management

Just `ChangeNotifier` + `provider` — no Bloc/Riverpod ceremony for a V1 this
size. Three providers: `TaskProvider`, `NoteProvider`, `SettingsProvider`.

## Persistence

V1 keeps everything in memory (resets on app restart) to stay simple and
dependency-light, exactly per the "ไม่ยุ่ง Firebase" brief. When you're ready
to persist between launches, the cleanest next step is swapping the
in-memory lists inside `TaskProvider` / `NoteProvider` for a local store —
`hive` or `sqflite` for structured data, or `shared_preferences` if you just
want to serialize everything to JSON. The public API of both providers
(`addTask`, `updateTask`, `deleteTask`, …) won't need to change.

## Notifications

`NotificationService` wraps `flutter_local_notifications` so reminders are
scheduled locally on-device — no push server needed. Two things to do
before it works on a real device:

- **Android**: add a notification icon and (for Android 13+) the
  `POST_NOTIFICATIONS` permission in `android/app/src/main/AndroidManifest.xml`,
  per the [flutter_local_notifications setup guide](https://pub.dev/packages/flutter_local_notifications).
- **iOS**: enable the "Push Notifications" / "Background Modes" capability
  in Xcode if you want notifications to fire while the app is backgrounded.

Both of those are already done in this project (permissions + receivers in
`AndroidManifest.xml`, core-library desugaring in `android/app/build.gradle.kts`).
Notifications are skipped automatically on web/desktop. If Android refuses exact
alarms, reminders fall back to "about on time" alarms.

Permission is requested from `NotificationPermissionScreen` — never at cold
start — so it never feels pushy, per the app's whole vibe.

## Thai date labels

`main.dart` calls `initializeDateFormatting('th')` from `intl`, so
`DateFormat('d MMM', 'th')` renders Thai month names, and `app.dart` sets the
Thai locale + `flutter_localizations` delegates so the date/time pickers and
dialogs are Thai too.

## Design source

Colors, spacing and copy in this app were translated 1:1 from the SeaList
HTML/CSS prototype (ocean palette, rounded 18px cards, soft shadows, wave
header, calming empty states).

## Changelog — v1.2

- **Data now survives closing the app.** Tasks and notes are saved to the
  device as JSON via `shared_preferences` (package added to `pubspec.yaml`).
  - `TaskItem`/`NoteItem` gained `toJson()` / `fromJson()`.
  - `TaskProvider`/`NoteProvider` load everything from disk on startup
    (`_load()`) and re-save after every add/edit/delete/toggle (`_save()`).
    A single corrupted saved item is skipped rather than losing the whole
    list; a completely unreadable save just starts empty instead of crashing.
  - Both providers expose `isLoading` (true only very briefly on cold start)
    so the Today/Notes screens don't flash the "empty" state before saved
    data has loaded.
  - Task reminders are automatically re-scheduled after loading, the same
    way `rescheduleAll()` already worked when toggling the notifications
    setting.
- Not persisted yet (still resets on reopen): the Settings screen's
  notifications toggle and default reminder time. Say the word if you want
  those saved too — same `shared_preferences` approach, just a couple more
  keys.

## Changelog — v1.1

- Removed all sample/mock tasks and notes. The app now starts completely
  empty for every new install — no `TaskProvider._seed()` /
  `NoteProvider._seed()` anymore. Everything in the list comes from what
  the person adds themselves (via the `+` button on Today, or the note
  editor). The existing empty-state screens (with Sea the seal) already
  covered this case, so no UI changes were needed beyond removing the seed
  data itself.

## Changelog (fix + cute pass)

**Fixes**
- Reminders now compile and work: `zonedSchedule` was missing the required
  `uiLocalNotificationDateInterpretation`; added the Android manifest
  permissions/receivers and core-library desugaring the plugin needs; skipped
  cleanly on web/desktop; exact-alarm refusal falls back to inexact.
- Ticking a task done cancels its reminder (un-ticking schedules it again);
  the notifications switch in Settings really turns reminders off/on.
- Edit-task screen no longer changes the task *before* you press save (it used
  to mutate the live object); dates, reminder and tag can now be cleared.
- "Custom reminder" no longer overwrites the task's due date.
- Quick-add reminder at night lands on tomorrow instead of "overdue".
- Finished tasks in "soon" / late tasks finished today no longer vanish.
- Opening a note while a search is active no longer breaks its detail/edit screen.
- Two stock FABs sharing a Hero tag replaced with a custom FAB; notes FAB no
  longer sticks to the screen edge.
- Card shadows no longer tint the inside of the cards; ripples are visible.
- Default reminder time from Settings is now actually used by the time pickers.

**Cute pass**
- New fonts (Mali headings + Sarabun body — real Thai glyphs), pastel accents.
- "Sea" the seal mascot (header, empty states, sheets, settings) + app icons.
- Layered wave header with bubbles, time-of-day greeting, animated progress ring.
- Pastel sticky-note cards, tag emojis, "เลยมา N วัน" chips, bouncy checkboxes,
  haptics, pill bottom nav, rounded dialogs/pickers/snackbars.
