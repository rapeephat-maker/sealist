import 'package:flutter/material.dart';
import '../services/notification_service.dart';

/// Simple in-memory settings for V1.
/// Swap for `shared_preferences` later if you want these to persist
/// between app launches — the widgets only talk to this provider.
class SettingsProvider extends ChangeNotifier {
  bool notificationsEnabled = true;
  TimeOfDay defaultReminderTime = const TimeOfDay(hour: 9, minute: 0);
  bool hasAskedNotificationPermission = false;

  void setNotificationsEnabled(bool value) {
    notificationsEnabled = value;
    // The scheduler checks this flag, so turning it off really stops reminders.
    NotificationService.instance.enabled = value;
    notifyListeners();
  }

  void setDefaultReminderTime(TimeOfDay time) {
    defaultReminderTime = time;
    notifyListeners();
  }

  void markPermissionAsked() {
    hasAskedNotificationPermission = true;
    notifyListeners();
  }

  String get defaultReminderLabel {
    final h = defaultReminderTime.hour.toString().padLeft(2, '0');
    final m = defaultReminderTime.minute.toString().padLeft(2, '0');
    return '$h:$m น.';
  }
}
