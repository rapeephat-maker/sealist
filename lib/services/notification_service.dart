import 'package:flutter/foundation.dart'
    show TargetPlatform, debugPrint, defaultTargetPlatform, kIsWeb;
import 'package:flutter/services.dart' show PlatformException;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
// `show` keeps our own `Priority` enum from clashing with the plugin's `Priority`.
import '../models/task_item.dart' show TaskItem;

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  /// Mirrors the "notifications" switch in Settings.
  bool enabled = true;

  /// flutter_local_notifications only does something useful on Android / iOS.
  /// (On web or desktop we quietly skip instead of crashing.)
  bool get _supported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  /// Stable 32-bit notification id for a task id.
  int _idFor(String taskId) => taskId.hashCode & 0x7FFFFFFF;

  Future<void> init() async {
    if (_initialized || !_supported) return;
    try {
      tz_data.initializeTimeZones();

      const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosInit = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );
      const initSettings = InitializationSettings(android: androidInit, iOS: iosInit);
      await _plugin.initialize(initSettings);
      _initialized = true;
    } catch (e) {
      debugPrint('NotificationService.init failed: $e');
    }
  }

  /// Ask the user for permission. Call this from the notification
  /// permission screen — never at cold start, so it never feels pushy.
  Future<bool> requestPermission() async {
    if (!_supported) return true;
    try {
      await init();
      final iosGranted = await _plugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);

      final androidGranted = await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();

      return (iosGranted ?? true) && (androidGranted ?? true);
    } catch (e) {
      debugPrint('NotificationService.requestPermission failed: $e');
      return false;
    }
  }

  Future<void> scheduleReminder(TaskItem task) async {
    if (!_supported) return;
    try {
      await init();
      final at = task.reminderAt;

      // Nothing to remind about (or reminders are off / already in the past):
      // make sure no stale notification is left behind.
      if (!enabled || at == null || task.isDone || !at.isAfter(DateTime.now())) {
        await cancelReminder(task.id);
        return;
      }

      // TZDateTime.from keeps the exact instant, so the reminder fires at the
      // right moment whatever `tz.local` happens to be.
      final when = tz.TZDateTime.from(at, tz.local);
      final body = task.tag == null
          ? 'ถึงเวลาแล้วนะ 🌊'
          : 'ถึงเวลาแล้วนะ · ${task.tag} 🌊';

      const details = NotificationDetails(
        android: AndroidNotificationDetails(
          'sealist_reminders',
          'การเตือนความจำ',
          channelDescription: 'แจ้งเตือนงานและสิ่งที่ต้องทำใน SeaList',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      );

      try {
        await _plugin.zonedSchedule(
          _idFor(task.id),
          task.title,
          body,
          when,
          details,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
      } on PlatformException {
        // Android 12+ may refuse exact alarms unless the user allowed them —
        // fall back to an "about on time" alarm instead of losing the reminder.
        await _plugin.zonedSchedule(
          _idFor(task.id),
          task.title,
          body,
          when,
          details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
      }
    } catch (e) {
      debugPrint('NotificationService.scheduleReminder failed: $e');
    }
  }

  Future<void> cancelReminder(String taskId) async {
    if (!_supported) return;
    try {
      await _plugin.cancel(_idFor(taskId));
    } catch (e) {
      debugPrint('NotificationService.cancelReminder failed: $e');
    }
  }
}
