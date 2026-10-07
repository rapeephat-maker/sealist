import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../app/colors.dart';
import '../../models/note_item.dart';
import '../../providers/note_provider.dart';

/// Pass [noteId] to edit an existing note, or leave it null to create one.
class EditNoteScreen extends StatefulWidget {
  const EditNoteScreen({super.key, this.noteId});

  final String? noteId;

  @override
  State<EditNoteScreen> createState() => _EditNoteScreenState();
}

class _EditNoteScreenState extends State<EditNoteScreen> {
  late final NoteItem? _existing;
  late final TextEditingController _titleCtrl;
  late final TextEditingController _contentCtrl;

  bool get _isNew => widget.noteId == null;

  @override
  void initState() {
    super.initState();
    final id = widget.noteId;
    _existing = id == null ? null : context.read<NoteProvider>().byId(id);
    _titleCtrl = TextEditingController(text: _existing?.title ?? '');
    _contentCtrl = TextEditingController(text: _existing?.content ?? '');
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  void _save() {
    final title = _titleCtrl.text.trim();
    final content = _contentCtrl.text.trim();
    if (title.isEmpty && content.isEmpty) {
      Navigator.of(context).pop();
      return;
    }

    final provider = context.read<NoteProvider>();
    final existing = _existing;
    if (_isNew || existing == null) {
      final now = DateTime.now();
      provider.addNote(NoteItem(
        id: const Uuid().v4(),
        title: title,
        content: content,
        createdAt: now,
        updatedAt: now,
      ));
    } else {
      provider.updateNote(
        existing.copyWith(title: title, content: content, updatedAt: DateTime.now()),
      );
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isNew ? 'โน้ตใหม่ ✨' : 'แก้ไขโน้ต'),
        leading: const BackButton(),
        actions: [
          TextButton(onPressed: _save, child: const Text('บันทึก')),
          const SizedBox(width: 6),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleCtrl,
              autofocus: _isNew,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.darkText),
              decoration: const InputDecoration(border: InputBorder.none, hintText: 'หัวข้อ'),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: TextField(
                controller: _contentCtrl,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                style: const TextStyle(fontSize: 15.5, height: 1.7),
                decoration: const InputDecoration(
                  hintText: 'เขียนอะไรก็ได้ที่อยากจำไว้…',
                  border: InputBorder.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
