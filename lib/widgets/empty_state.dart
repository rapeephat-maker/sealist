import 'package:flutter/material.dart';
import '../app/colors.dart';
import '../app/text_styles.dart';
import 'sea_mascot.dart';

/// Ocean-themed empty state — Sea the seal (or an emoji) plus calm copy,
/// used instead of a generic "no items" message.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.title,
    required this.subtitle,
    this.emoji,
    this.mood = SeaMood.calm,
    this.action,
  });

  final String title;
  final String subtitle;

  /// If given, shown instead of the mascot (e.g. 🔍 for "no search results").
  final String? emoji;
  final SeaMood mood;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (emoji != null)
            Text(emoji!, style: const TextStyle(fontSize: 42))
          else
            SeaMascot(size: 96, mood: mood),
          const SizedBox(height: 14),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppText.heading(size: 17),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.mutedText, fontSize: 14, height: 1.6),
          ),
          if (action != null) ...[
            const SizedBox(height: 16),
            action!,
          ],
        ],
      ),
    );
  }
}
