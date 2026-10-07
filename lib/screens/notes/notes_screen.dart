import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/colors.dart';
import '../../app/text_styles.dart';
import '../../providers/note_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/gradient_fab.dart';
import '../../widgets/sea_mascot.dart';
import 'edit_note_screen.dart';
import 'note_detail_screen.dart';
import 'widgets/note_card.dart';

class NotesScreen extends StatelessWidget {
  const NotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notes = context.watch<NoteProvider>();

    void openNote(String id) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => NoteDetailScreen(noteId: id)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('โน้ตของฉัน 📝'),
        automaticallyImplyLeading: false,
      ),
      floatingActionButton: GradientFab(
        tooltip: 'โน้ตใหม่',
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const EditNoteScreen()),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              onChanged: (v) => context.read<NoteProvider>().setQuery(v),
              decoration: const InputDecoration(
                hintText: 'ค้นหาโน้ต',
                prefixIcon: Icon(Icons.search_rounded, color: AppColors.mutedText, size: 22),
              ),
            ),
            const SizedBox(height: 6),
            Expanded(
              // Briefly true right after launch while saved notes are still
              // loading from disk — show nothing rather than flash "empty".
              child: notes.isLoading
                  ? const SizedBox.shrink()
                  : notes.isEmpty
                  ? const Center(
                      child: SingleChildScrollView(
                        child: EmptyState(
                          mood: SeaMood.sleepy,
                          title: 'ไม่มีอะไรต้องรีบแล้วนะ',
                          subtitle: 'ยังไม่มีโน้ต ลองจดอะไรเล็ก ๆ ที่อยากจำไว้ดูสิ',
                        ),
                      ),
                    )
                  : notes.filteredIsEmpty
                      ? const Center(
                          child: SingleChildScrollView(
                            child: EmptyState(
                              emoji: '🔍',
                              title: 'ไม่เจอโน้ตที่ค้นหา',
                              subtitle: 'ลองพิมพ์คำอื่นดูนะ',
                            ),
                          ),
                        )
                      : ListView(
                          padding: const EdgeInsets.only(bottom: 110),
                          children: [
                            if (notes.pinned.isNotEmpty) ...[
                              const _GroupTitle('📌 ปักหมุด'),
                              ...notes.pinned.map(
                                (n) => Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: NoteCard(note: n, onTap: () => openNote(n.id)),
                                ),
                              ),
                            ],
                            if (notes.others.isNotEmpty) ...[
                              const _GroupTitle('🐚 ทั้งหมด'),
                              ...notes.others.map(
                                (n) => Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: NoteCard(note: n, onTap: () => openNote(n.id)),
                                ),
                              ),
                            ],
                          ],
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GroupTitle extends StatelessWidget {
  const _GroupTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 10),
      child: Text(text, style: AppText.heading(size: 14.5, color: AppColors.deepOcean)),
    );
  }
}
