import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../app/colors.dart';
import '../../../models/task_item.dart';
import '../../../widgets/soft_card.dart';

/// One task row.
/// Completed tasks turn soft & strike-through instead of disappearing,
/// so finishing something still leaves a small, comforting trace.
class TaskTile extends StatelessWidget {
  const TaskTile({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onTap,
    this.overdueStyle = false,
  });

  final TaskItem task;
  final VoidCallback onToggle;
  final VoidCallback onTap;
  final bool overdueStyle;

  @override
  Widget build(BuildContext context) {
    final done = task.isDone;
    final showLate = overdueStyle && !done && task.daysOverdue > 0;
    final showHigh = task.priority == Priority.high && !done;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: done ? 0.6 : 1,
      child: SoftCard(
        onTap: onTap,
        padding: const EdgeInsets.fromLTRB(10, 12, 14, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Generous tap target around the little circle.
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onToggle,
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 26,
                  height: 26,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: done ? AppColors.turquoise : Colors.transparent,
                    border: Border.all(
                      color: done ? AppColors.turquoise : const Color(0xFFB9D9E0),
                      width: 2,
                    ),
                  ),
                  child: AnimatedScale(
                    scale: done ? 1 : 0,
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutBack,
                    child: const Icon(Icons.check_rounded, size: 17, color: Colors.white),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 3),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w600,
                        color: done
                            ? const Color(0xFF9FB3BA)
                            : (overdueStyle ? AppColors.overdue : AppColors.darkText),
                        decoration: done ? TextDecoration.lineThrough : null,
                        height: 1.4,
                      ),
                    ),
                    if (task.reminderAt != null || task.tag != null || showLate || showHigh) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          if (showLate)
                            _Pill(
                              text: 'เลยมา ${task.daysOverdue} วัน',
                              bg: AppColors.sunnySoft,
                              fg: AppColors.overdue,
                            ),
                          if (showHigh)
                            const _Pill(
                              text: '🔥 สำคัญมาก',
                              bg: AppColors.coralSoft,
                              fg: Color(0xFF9F1239),
                            ),
                          if (task.reminderAt != null)
                            _Pill(
                              text: '⏰ ${_reminderLabel(task)}',
                              bg: AppColors.sky,
                              fg: AppColors.oceanBlue,
                            ),
                          if (task.tag != null)
                            _Pill(
                              text: '${tagEmoji(task.tag!)} ${task.tag!}',
                              bg: AppColors.seafoam,
                              fg: AppColors.deepOcean,
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _reminderLabel(TaskItem task) {
    final r = task.reminderAt!;
    final now = DateTime.now();
    final isToday = r.year == now.year && r.month == now.month && r.day == now.day;
    final time = DateFormat('HH:mm').format(r);
    if (isToday) return time;
    return '${DateFormat('d MMM', 'th').format(r)} · $time';
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.text, required this.bg, required this.fg});

  final String text;
  final Color bg;
  final Color fg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Text(
        text,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: fg),
      ),
    );
  }
}
