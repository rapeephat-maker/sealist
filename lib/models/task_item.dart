import 'package:flutter/material.dart';
import '../app/colors.dart';

enum Priority { low, medium, high }

extension PriorityX on Priority {
  String get label => switch (this) {
        Priority.low => 'น้อย',
        Priority.medium => 'ปานกลาง',
        Priority.high => 'มาก',
      };

  Color get bgColor => switch (this) {
        Priority.low => AppColors.priorityLowBg,
        Priority.medium => AppColors.priorityMedBg,
        Priority.high => AppColors.priorityHighBg,
      };

  Color get fgColor => switch (this) {
        Priority.low => AppColors.deepOcean,
        Priority.medium => const Color(0xFF854D0E),
        Priority.high => const Color(0xFF991B1B),
      };
}

enum ReminderType { none, atTime, custom }

/// Built-in tags, each with its own little emoji.
const Map<String, String> kTagEmojis = {
  'บ้าน': '🏠',
  'งาน': '💼',
  'เงิน': '💰',
  'โทรศัพท์': '📞',
  'สุขภาพ': '💪',
};

/// Emoji for a tag — custom tags the user typed get a generic label emoji.
String tagEmoji(String tag) => kTagEmojis[tag] ?? '🏷️';

DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

class TaskItem {
  TaskItem({
    required this.id,
    required this.title,
    this.description = '',
    this.dueDate,
    this.reminderAt,
    this.reminderType = ReminderType.none,
    this.priority = Priority.medium,
    this.tag,
    this.isDone = false,
    this.completedAt,
  });

  final String id;
  String title;
  String description;
  DateTime? dueDate;
  DateTime? reminderAt;
  ReminderType reminderType;
  Priority priority;
  String? tag;
  bool isDone;

  /// When the task was ticked off (null while it is not done).
  DateTime? completedAt;

  /// Due date is before today (whether or not it has been finished).
  bool get isPast {
    final d = dueDate;
    if (d == null) return false;
    return _dateOnly(d).isBefore(_dateOnly(DateTime.now()));
  }

  /// Overdue = has a due date before today and is not done yet.
  bool get isOverdue => !isDone && isPast;

  /// How many days late (0 if not late).
  int get daysOverdue {
    final d = dueDate;
    if (d == null) return 0;
    final diff = _dateOnly(DateTime.now()).difference(_dateOnly(d)).inDays;
    return diff < 0 ? 0 : diff;
  }

  bool get isToday {
    final d = dueDate;
    if (d == null) return false;
    return _dateOnly(d) == _dateOnly(DateTime.now());
  }

  bool get isUpcoming {
    final d = dueDate;
    if (d == null) return true; // no date yet -> treat as "someday / upcoming"
    return _dateOnly(d).isAfter(_dateOnly(DateTime.now()));
  }

  /// Finished today — used to keep freshly completed (late) tasks visible
  /// for the rest of the day instead of making them vanish.
  bool get wasCompletedToday {
    final c = completedAt;
    if (!isDone || c == null) return false;
    return _dateOnly(c) == _dateOnly(DateTime.now());
  }

  /// `copyWith` can't tell "keep the old value" from "set to null", so the
  /// nullable fields have explicit `clearXxx` switches.
  TaskItem copyWith({
    String? title,
    String? description,
    DateTime? dueDate,
    bool clearDueDate = false,
    DateTime? reminderAt,
    bool clearReminderAt = false,
    ReminderType? reminderType,
    Priority? priority,
    String? tag,
    bool clearTag = false,
    bool? isDone,
    DateTime? completedAt,
    bool clearCompletedAt = false,
  }) {
    return TaskItem(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: clearDueDate ? null : (dueDate ?? this.dueDate),
      reminderAt: clearReminderAt ? null : (reminderAt ?? this.reminderAt),
      reminderType: reminderType ?? this.reminderType,
      priority: priority ?? this.priority,
      tag: clearTag ? null : (tag ?? this.tag),
      isDone: isDone ?? this.isDone,
      completedAt: clearCompletedAt ? null : (completedAt ?? this.completedAt),
    );
  }

  /// Plain-JSON shape used to save this task to disk (see `TaskProvider`).
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'dueDate': dueDate?.toIso8601String(),
        'reminderAt': reminderAt?.toIso8601String(),
        'reminderType': reminderType.name,
        'priority': priority.name,
        'tag': tag,
        'isDone': isDone,
        'completedAt': completedAt?.toIso8601String(),
      };

  factory TaskItem.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic v) => v == null ? null : DateTime.parse(v as String);

    return TaskItem(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      dueDate: parseDate(json['dueDate']),
      reminderAt: parseDate(json['reminderAt']),
      reminderType: ReminderType.values.asNameMap()[json['reminderType']] ??
          ReminderType.none,
      priority: Priority.values.asNameMap()[json['priority']] ?? Priority.medium,
      tag: json['tag'] as String?,
      isDone: json['isDone'] as bool? ?? false,
      completedAt: parseDate(json['completedAt']),
    );
  }
}
