import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../../app/colors.dart';
import '../../../app/text_styles.dart';
import '../../../models/note_item.dart';
import '../../../models/task_item.dart';
import '../../../providers/note_provider.dart';
import '../../../providers/task_provider.dart';
import '../../../widgets/sea_mascot.dart';

enum _QuickType { task, note, reminder }

/// Bottom sheet for the "+" button — task / note / reminder, saved in a
/// couple of taps. Kept to a single text field on purpose; anything more
/// specific (priority, tags, exact date) lives in the full edit screen.
class QuickAddSheet extends StatefulWidget {
  const QuickAddSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const QuickAddSheet(),
    );
  }

  @override
  State<QuickAddSheet> createState() => _QuickAddSheetState();
}

class _QuickAddSheetState extends State<QuickAddSheet> {
  _QuickType _type = _QuickType.task;
  final _controller = TextEditingController();
  static const _uuid = Uuid();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String get _hint => switch (_type) {
        _QuickType.task => 'มีอะไรที่ต้องทำบ้าง…',
        _QuickType.note => 'จดอะไรไว้ดีนะ…',
        _QuickType.reminder => 'อยากให้เตือนเรื่องอะไร…',
      };

  void _save() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final now = DateTime.now();
    if (_type == _QuickType.note) {
      context.read<NoteProvider>().addNote(
            NoteItem(id: _uuid.v4(), title: text, content: '', createdAt: now, updatedAt: now),
          );
    } else {
      final isReminder = _type == _QuickType.reminder;
      // A quick reminder goes off in an hour; its due date follows that moment
      // (so late at night it lands on tomorrow instead of "overdue today").
      final reminderAt = isReminder ? now.add(const Duration(hours: 1)) : null;
      final dueBase = reminderAt ?? now;
      context.read<TaskProvider>().addTask(
            TaskItem(
              id: _uuid.v4(),
              title: text,
              dueDate: DateTime(dueBase.year, dueBase.month, dueBase.day),
              reminderAt: reminderAt,
              reminderType: isReminder ? ReminderType.atTime : ReminderType.none,
            ),
          );
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.fromLTRB(22, 10, 22, 26),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 5,
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFDBE6EA),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            Row(
              children: [
                Expanded(child: Text('เพิ่มเรื่องใหม่', style: AppText.heading(size: 18))),
                const SeaMascot(size: 40, bob: false, mood: SeaMood.happy),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _TypeButton(
                  emoji: '✅',
                  label: 'งาน',
                  selected: _type == _QuickType.task,
                  onTap: () => setState(() => _type = _QuickType.task),
                ),
                const SizedBox(width: 8),
                _TypeButton(
                  emoji: '📝',
                  label: 'โน้ต',
                  selected: _type == _QuickType.note,
                  onTap: () => setState(() => _type = _QuickType.note),
                ),
                const SizedBox(width: 8),
                _TypeButton(
                  emoji: '⏰',
                  label: 'เตือนความจำ',
                  selected: _type == _QuickType.reminder,
                  onTap: () => setState(() => _type = _QuickType.reminder),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              autofocus: true,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _save(),
              decoration: InputDecoration(hintText: _hint),
            ),
            if (_type == _QuickType.reminder) ...[
              const SizedBox(height: 8),
              const Text(
                'จะเตือนอีก 1 ชั่วโมงข้างหน้า (ปรับเวลาได้ตอนแก้ไขงาน)',
                style: TextStyle(fontSize: 12.5, color: AppColors.mutedText),
              ),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(onPressed: _save, child: const Text('บันทึก')),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypeButton extends StatelessWidget {
  const _TypeButton({
    required this.emoji,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String emoji;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 6),
          decoration: BoxDecoration(
            color: selected ? AppColors.seafoam : AppColors.sky,
            border: Border.all(
              color: selected ? AppColors.turquoise : Colors.transparent,
              width: 1.6,
            ),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(height: 4),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.deepOcean,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
