import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../app/colors.dart';
import '../../../models/note_item.dart';
import '../../../widgets/soft_card.dart';

/// A little pastel sticky note. The tint is picked from the note's id, so
/// every note keeps its own color for good.
class NoteCard extends StatelessWidget {
  const NoteCard({super.key, required this.note, required this.onTap});

  final NoteItem note;
  final VoidCallback onTap;

  static Color tintFor(NoteItem note) {
    final tints = AppColors.noteTints;
    return tints[note.id.hashCode.abs() % tints.length];
  }

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      color: tintFor(note),
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  note.title.isEmpty ? 'ไม่มีหัวข้อ' : note.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkText,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (note.isPinned) ...[
                const SizedBox(width: 6),
                const Text('📌', style: TextStyle(fontSize: 14)),
              ],
            ],
          ),
          if (note.content.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              note.content,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13.5, color: AppColors.mutedText, height: 1.55),
            ),
          ],
          const SizedBox(height: 10),
          Text(
            'แก้ไขล่าสุด ${DateFormat('d MMM', 'th').format(note.updatedAt)}',
            style: const TextStyle(fontSize: 12, color: AppColors.mutedText),
          ),
        ],
      ),
    );
  }
}
