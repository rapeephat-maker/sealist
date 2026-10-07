import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../app/colors.dart';
import '../../app/text_styles.dart';
import '../../models/note_item.dart';
import '../../providers/note_provider.dart';
import '../../widgets/soft_card.dart';
import 'edit_note_screen.dart';
import 'widgets/note_card.dart';

class NoteDetailScreen extends StatelessWidget {
  const NoteDetailScreen({super.key, required this.noteId});

  final String noteId;

  @override
  Widget build(BuildContext context) {
    final note = context.watch<NoteProvider>().byId(noteId);

    if (note == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted && Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      });
      return const Scaffold(body: SizedBox.shrink());
    }

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        actions: [
          TextButton.icon(
            onPressed: () => context.read<NoteProvider>().togglePin(note.id),
            icon: Icon(
              note.isPinned ? Icons.push_pin_rounded : Icons.push_pin_outlined,
              size: 17,
              color: AppColors.turquoise,
            ),
            label: Text(
              note.isPinned ? 'เลิกปักหมุด' : 'ปักหมุด',
              style: const TextStyle(color: AppColors.turquoise),
            ),
          ),
          TextButton.icon(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => EditNoteScreen(noteId: note.id)),
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
            color: NoteCard.tintFor(note),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  note.title.isEmpty ? 'ไม่มีหัวข้อ' : note.title,
                  style: AppText.heading(size: 21, height: 1.45),
                ),
                const SizedBox(height: 6),
                Text(
                  'สร้างเมื่อ ${DateFormat('d MMM', 'th').format(note.createdAt)} · แก้ไขล่าสุด ${DateFormat('d MMM', 'th').format(note.updatedAt)}',
                  style: const TextStyle(fontSize: 12, color: AppColors.mutedText),
                ),
                const SizedBox(height: 18),
                Text(
                  note.content.isEmpty ? 'ยังไม่มีเนื้อหา' : note.content,
                  style: TextStyle(
                    fontSize: 15.5,
                    color: note.content.isEmpty ? AppColors.faintText : AppColors.darkText,
                    height: 1.75,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.danger,
                side: const BorderSide(color: AppColors.dangerSoft, width: 1.5),
              ),
              onPressed: () => _confirmDelete(context, note),
              child: const Text('ลบโน้ตนี้'),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, NoteItem note) {
    final notes = context.read<NoteProvider>();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('ลบโน้ตนี้ไหม'),
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
              notes.deleteNote(note.id);
            },
            child: const Text('ลบ', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
  }
}
