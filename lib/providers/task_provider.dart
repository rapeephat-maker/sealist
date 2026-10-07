import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task_item.dart';
import '../services/notification_service.dart';

/// Holds all tasks, saved to the device as JSON (via `shared_preferences`)
/// so they survive closing the app — no backend, no accounts, just a local
/// file under the hood.
class TaskProvider extends ChangeNotifier {
  TaskProvider() {
    _load();
  }

  static const _prefsKey = 'sealist.tasks.v1';

  // v1.1: starts empty — no more sample tasks. Everything here comes from
  // what the person adds themselves (via QuickAddSheet / EditTaskScreen).
  // v1.2: loaded from / saved to disk, see `_load` and `_save` below.
  final List<TaskItem> _tasks = [];

  /// True while the very first load from disk hasn't finished yet — lets the
  /// UI avoid flashing an empty state before saved tasks show up.
  bool isLoading = true;

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefsKey);
      if (raw != null) {
        final decoded = jsonDecode(raw) as List;
        for (final entry in decoded) {
          // Skip a single corrupted entry instead of losing everything.
          try {
            _tasks.add(TaskItem.fromJson(Map<String, dynamic>.from(entry as Map)));
          } catch (_) {}
        }
      }
    } catch (_) {
      // Corrupt/unreadable prefs -> start empty rather than crash.
    }
    isLoading = false;
    rescheduleAll();
    notifyListeners();
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = jsonEncode(_tasks.map((t) => t.toJson()).toList());
      await prefs.setString(_prefsKey, raw);
    } catch (_) {
      // Best-effort: a failed save shouldn't crash the app, just means
      // this particular change might not survive a restart.
    }
  }

  List<TaskItem> get all => List.unmodifiable(_tasks);

  TaskItem? byId(String id) {
    for (final t in _tasks) {
      if (t.id == id) return t;
    }
    return null;
  }

  /// Late tasks. Ones finished *today* stay visible (soft + struck through)
  /// so ticking something off never makes it vanish under your finger.
  List<TaskItem> get overdue =>
      _tasks.where((t) => t.isPast && (!t.isDone || t.wasCompletedToday)).toList()
        ..sort(_compare);

  List<TaskItem> get today => _tasks.where((t) => t.isToday).toList()..sort(_compare);

  List<TaskItem> get upcoming {
    final list = _tasks.where((t) => !t.isPast && !t.isToday).toList();
    list.sort((a, b) {
      if (a.isDone != b.isDone) return a.isDone ? 1 : -1;
      final ad = a.dueDate ?? DateTime(2100);
      final bd = b.dueDate ?? DateTime(2100);
      return ad.compareTo(bd);
    });
    return list;
  }

  int get doneTodayCount => today.where((t) => t.isDone).length;
  int get totalTodayCount => today.length;

  bool get isEmpty => _tasks.isEmpty;

  /// Not-done first, then by reminder time.
  int _compare(TaskItem a, TaskItem b) {
    if (a.isDone != b.isDone) return a.isDone ? 1 : -1;
    return _byReminder(a, b);
  }

  int _byReminder(TaskItem a, TaskItem b) {
    final ar = a.reminderAt;
    final br = b.reminderAt;
    if (ar == null && br == null) return 0;
    if (ar == null) return 1;
    if (br == null) return -1;
    return ar.compareTo(br);
  }

  void addTask(TaskItem task) {
    _tasks.add(task);
    NotificationService.instance.scheduleReminder(task);
    notifyListeners();
    _save();
  }

  void updateTask(TaskItem updated) {
    final i = _tasks.indexWhere((t) => t.id == updated.id);
    if (i == -1) return;
    _tasks[i] = updated;
    NotificationService.instance.scheduleReminder(updated);
    notifyListeners();
    _save();
  }

  void toggleDone(String id) {
    final i = _tasks.indexWhere((t) => t.id == id);
    if (i == -1) return;
    final nowDone = !_tasks[i].isDone;
    _tasks[i] = _tasks[i].copyWith(
      isDone: nowDone,
      completedAt: nowDone ? DateTime.now() : null,
      clearCompletedAt: !nowDone,
    );
    // Done -> cancels the reminder; un-done -> schedules it again.
    NotificationService.instance.scheduleReminder(_tasks[i]);
    notifyListeners();
    _save();
  }

  void deleteTask(String id) {
    _tasks.removeWhere((t) => t.id == id);
    NotificationService.instance.cancelReminder(id);
    notifyListeners();
    _save();
  }

  void clearCompleted() {
    final completedIds = _tasks.where((t) => t.isDone).map((t) => t.id).toList();
    for (final id in completedIds) {
      NotificationService.instance.cancelReminder(id);
    }
    _tasks.removeWhere((t) => t.isDone);
    notifyListeners();
    _save();
  }

  /// Re-applies every reminder (used when notifications are switched on/off).
  void rescheduleAll() {
    for (final t in _tasks) {
      NotificationService.instance.scheduleReminder(t);
    }
  }
}
