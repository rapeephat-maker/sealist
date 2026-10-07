import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../app/colors.dart';
import '../../app/text_styles.dart';
import '../../models/task_item.dart';
import '../../providers/task_provider.dart';
import '../../widgets/soft_card.dart';
import 'edit_task_screen.dart';

class TaskDetailScreen extends StatelessWidget {
  const TaskDetailScreen({super.key, required this.taskId});

  final String taskId;

  @override
  Widget build(BuildContext context) {
    final task = context.watch<TaskProvider>().byId(taskId);

    if (task == null) {
      // Task was deleted while this screen was open (e.g. via clear completed).
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted && Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      });
      return const Scaffold(body: SizedBox.shrink());
    }

    final dueText = task.dueDate == null
        ? 'ยังไม่กำหนด'
        : DateFormat('d MMM y', 'th').format(task.dueDate!);
    final reminderText = task.reminderAt == null
        ? 'ไม่ตั้งเตือน'
        : DateFormat("d MMM · HH:mm 'น.'", 'th').format(task.reminderAt!);

    return Scaffold(
      appBar: AppBar(
        title: const Text('รายละเอียดงาน'),
        leading: const BackButton(),
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => EditTaskScreen(taskId: task.id)),
            ),
            icon: const Icon(Icons.edit_rounded, size: 16),
            label: const Text('แก้ไข'),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
        children: [
          SoftCard(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _Chip(
                      text: task.isDone ? '✅ เสร็จแล้ว' : '🌊 ยังไม่เสร็จ',
                      bg: task.isDone ? AppColors.seafoam : AppColors.sky,
                      fg: AppColors.deepOcean,
                    ),
                    if (task.tag != null)
                      _Chip(
                        text: '${tagEmoji(task.tag!)} ${task.tag!}',
                        bg: AppColors.lavenderSoft,
                        fg: const Color(0xFF5B21B6),
                      ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  task.title,
                  style: AppText.heading(size: 21, height: 1.45).copyWith(
                    decoration: task.isDone ? TextDecoration.lineThrough : null,
                  ),
                ),
                if (task.description.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    task.description,
                    style: const TextStyle(fontSize: 15, color: AppColors.mutedText, height: 1.7),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 14),
          SoftCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Column(
              children: [
                _DetailRow(icon: '📅', label: 'วันที่', value: dueText),
                const Divider(height: 1),
                _DetailRow(icon: '⏰', label: 'เตือนความจำ', value: reminderText),
                const Divider(height: 1),
                _DetailRow(
                  icon: '🌊',
                  label: 'ความสำคัญ',
                  value: task.priority.label,
                  valueBg: task.priority.bgColor,
                  valueFg: task.priority.fgColor,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                context.read<TaskProvider>().toggleDone(task.id);
                Navigator.of(context).pop();
              },
              icon: Icon(task.isDone ? Icons.replay_rounded : Icons.check_rounded),
              label: Text(task.isDone ? 'ทำเป็นยังไม่เสร็จ' : 'ทำเสร็จแล้ว'),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.danger,
                side: const BorderSide(color: AppColors.dangerSoft, width: 1.5),
              ),
              onPressed: () => _confirmDelete(context, task.id),
              child: const Text('ลบงานนี้'),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, String id) {
    final tasks = context.read<TaskProvider>();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('ลบงานนี้ไหม'),
        content: const Text('ลบแล้วกู้คืนไม่ได้นะ'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('ยกเลิก'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop(); // close the dialog
              Navigator.of(context).pop(); // leave this screen
              tasks.deleteTask(id);
            },
            child: const Text('ลบ', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.text, required this.bg, required this.fg});

  final String text;
  final Color bg;
  final Color fg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Text(
        text,
        style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: fg),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueBg,
    this.valueFg,
  });

  final String icon;
  final String label;
  final String value;
  final Color? valueBg;
  final Color? valueFg;

  @override
  Widget build(BuildContext context) {
    final valueText = Text(
      value,
      style: TextStyle(
        fontSize: 14.5,
        fontWeight: FontWeight.w600,
        color: valueFg ?? AppColors.darkText,
      ),
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          SizedBox(width: 26, child: Text(icon, style: const TextStyle(fontSize: 16))),
          const SizedBox(width: 6),
          Expanded(
            child: Text(label, style: const TextStyle(fontSize: 14.5, color: AppColors.mutedText)),
          ),
          if (valueBg == null)
            valueText
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
              decoration: BoxDecoration(color: valueBg, borderRadius: BorderRadius.circular(999)),
              child: valueText,
            ),
        ],
      ),
    );
  }
}
