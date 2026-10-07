import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/note_item.dart';

/// Holds all notes, saved to the device as JSON (via `shared_preferences`)
/// so they survive closing the app — no backend, no accounts.
class NoteProvider extends ChangeNotifier {
  NoteProvider() {
    _load();
  }

  static const _prefsKey = 'sealist.notes.v1';

  // v1.1: starts empty — no more sample notes. Everything here comes from
  // what the person writes themselves (via EditNoteScreen).
  // v1.2: loaded from / saved to disk, see `_load` and `_save` below.
  final List<NoteItem> _notes = [];
  String _query = '';

  /// True while the very first load from disk hasn't finished yet — lets the
  /// UI avoid flashing an empty state before saved notes show up.
  bool isLoading = true;

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefsKey);
      if (raw != null) {
        final decoded = jsonDecode(raw) as List;
        for (final entry in decoded) {
          // Skip a single corrupted entry instead of losing everything.
          try {
            _notes.add(NoteItem.fromJson(Map<String, dynamic>.from(entry as Map)));
          } catch (_) {}
        }
      }
    } catch (_) {
      // Corrupt/unreadable prefs -> start empty rather than crash.
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = jsonEncode(_notes.map((n) => n.toJson()).toList());
      await prefs.setString(_prefsKey, raw);
    } catch (_) {
      // Best-effort: a failed save shouldn't crash the app, just means
      // this particular change might not survive a restart.
    }
  }

  String get query => _query;

  void setQuery(String q) {
    _query = q;
    notifyListeners();
  }

  List<NoteItem> get _filtered {
    if (_query.trim().isEmpty) return _notes;
    final q = _query.trim().toLowerCase();
    return _notes
        .where((n) =>
            n.title.toLowerCase().contains(q) || n.content.toLowerCase().contains(q))
        .toList();
  }

  List<NoteItem> get pinned => _filtered.where((n) => n.isPinned).toList()
    ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

  List<NoteItem> get others => _filtered.where((n) => !n.isPinned).toList()
    ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

  /// Looks a note up ignoring the search filter (so a note never "disappears"
  /// from its own detail/edit screen just because of what's typed in search).
  NoteItem? byId(String id) {
    for (final n in _notes) {
      if (n.id == id) return n;
    }
    return null;
  }

  bool get isEmpty => _notes.isEmpty;
  bool get filteredIsEmpty => _filtered.isEmpty;

  void addNote(NoteItem note) {
    _notes.add(note);
    notifyListeners();
    _save();
  }

  void updateNote(NoteItem updated) {
    final i = _notes.indexWhere((n) => n.id == updated.id);
    if (i == -1) return;
    _notes[i] = updated;
    notifyListeners();
    _save();
  }

  void deleteNote(String id) {
    _notes.removeWhere((n) => n.id == id);
    notifyListeners();
    _save();
  }

  void togglePin(String id) {
    final i = _notes.indexWhere((n) => n.id == id);
    if (i == -1) return;
    _notes[i] = _notes[i].copyWith(isPinned: !_notes[i].isPinned);
    notifyListeners();
    _save();
  }
}
