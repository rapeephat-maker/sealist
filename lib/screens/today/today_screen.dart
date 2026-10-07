import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../app/colors.dart';
import '../../app/text_styles.dart';
import '../../models/task_item.dart';
import '../../providers/task_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/gradient_fab.dart';
import '../../widgets/sea_mascot.dart';
import '../../widgets/wave_header.dart';
import '../task/task_detail_screen.dart';
import 'widgets/progress_ring.dart';
import 'widgets/quick_add_sheet.dart';
import 'widgets/task_tile.dart';

class TodayScreen extends StatelessWidget {
  const TodayScreen({super.key});

  static String _greeting(int hour) {
    if (hour < 5) return 'ดึกแล้วนะ ค่อย ๆ พักบ้าง 🌙';
    if (hour < 12) return 'อรุณสวัสดิ์ วันนี้ค่อย ๆ ไปนะ ☀️';
    if (hour < 17) return 'บ่ายนี้ใจเย็น ๆ นะ 🌊';
    if (hour < 21) return 'ตอนเย็นแล้ว พักหายใจลึก ๆ ✨';
    return 'ค่ำแล้ว เหลืออีกนิดเดียวเอง 🌙';
  }

  @override
  Widget build(BuildContext context) {
    final tasks = context.watch<TaskProvider>();
    final now = DateTime.now();
    final dateLabel = DateFormat("EEEE'ที่' d MMMM", 'th').format(now);
    final total = tasks.totalTodayCount;
    final done = tasks.doneTodayCount;
    final allDone = total > 0 && done == total;

    return Scaffold(
      floatingActionButton: GradientFab(
        tooltip: 'เพิ่มเรื่องใหม่',
        onPressed: () => QuickAddSheet.show(context),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: WaveHeader(
              child: SafeArea(
                bottom: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                dateLabel,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.mutedText,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(_greeting(now.hour), style: AppText.heading(size: 22, height: 1.4)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        SeaMascot(size: 84, mood: allDone ? SeaMood.happy : SeaMood.calm),
                      ],
                    ),
                    if (total > 0) ...[
                      const SizedBox(height: 14),
                      _ProgressCard(done: done, total: total),
                    ],
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 110),
            sliver: SliverList(
              delegate: SliverChildListDelegate(_buildBody(context, tasks)),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildBody(BuildContext context, TaskProvider tasks) {
    // Briefly true right after launch while saved tasks are still loading
    // from disk — skip the empty state so it doesn't flash before they appear.
    if (tasks.isLoading) return const [];

    if (tasks.isEmpty) {
      return const [
        EmptyState(
          mood: SeaMood.sleepy,
          title: 'ทะเลสงบมากเลย',
          subtitle: 'ยังไม่มีเรื่องให้ทำ\nกดปุ่ม + เพื่อจดเรื่องแรกได้เลยนะ',
        ),
      ];
    }

    final widgets = <Widget>[];

    void section(String emoji, String label, List<TaskItem> items, {bool overdue = false}) {
      if (items.isEmpty) return;
      widgets.add(_SectionLabel(emoji: emoji, text: label, count: items.length, overdue: overdue));
      widgets.add(const SizedBox(height: 10));
      for (final t in items) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: TaskTile(
              task: t,
              overdueStyle: overdue,
              onToggle: () {
                HapticFeedback.lightImpact();
                context.read<TaskProvider>().toggleDone(t.id);
              },
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => TaskDetailScreen(taskId: t.id)),
              ),
            ),
          ),
        );
      }
      widgets.add(const SizedBox(height: 6));
    }

    section('⏳', 'เลยกำหนด', tasks.overdue, overdue: true);
    section('🌊', 'วันนี้', tasks.today);
    section('🐚', 'เร็ว ๆ นี้', tasks.upcoming);

    if (widgets.isEmpty) {
      widgets.add(const EmptyState(
        mood: SeaMood.happy,
        title: 'วันนี้จัดการเรียบร้อยแล้ว ✨',
        subtitle: 'ไม่มีอะไรต้องรีบแล้วนะ พักสมองได้แล้ว',
      ));
    }

    return widgets;
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({required this.done, required this.total});

  final int done;
  final int total;

  @override
  Widget build(BuildContext context) {
    final allDone = done == total;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.deepOcean.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          ProgressRing(done: done, total: total),
          const SizedBox(width: 12),
          Expanded(
            child: allDone
                ? const Text(
                    'ทำครบทุกเรื่องแล้ว เก่งมากเลย 🎉',
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkText,
                    ),
                  )
                : Text.rich(
                    TextSpan(
                      style: const TextStyle(fontSize: 14, color: AppColors.mutedText),
                      children: [
                        const TextSpan(text: 'วันนี้ทำไปแล้ว '),
                        TextSpan(
                          text: '$done จาก $total',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.darkText,
                          ),
                        ),
                        const TextSpan(text: ' เรื่อง สบาย ๆ นะ'),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({
    required this.emoji,
    required this.text,
    required this.count,
    this.overdue = false,
  });

  final String emoji;
  final String text;
  final int count;
  final bool overdue;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 6),
          Text(
            text,
            style: AppText.heading(
              size: 15,
              color: overdue ? AppColors.overdue : AppColors.deepOcean,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
            decoration: BoxDecoration(
              color: overdue ? AppColors.sunnySoft : AppColors.seafoam,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: overdue ? AppColors.overdue : AppColors.deepOcean,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
