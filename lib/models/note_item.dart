class NoteItem {
  NoteItem({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    this.isPinned = false,
  });

  final String id;
  String title;
  String content;
  final DateTime createdAt;
  DateTime updatedAt;
  bool isPinned;

  NoteItem copyWith({
    String? title,
    String? content,
    bool? isPinned,
    DateTime? updatedAt,
  }) {
    return NoteItem(
      id: id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isPinned: isPinned ?? this.isPinned,
    );
  }

  /// Plain-JSON shape used to save this note to disk (see `NoteProvider`).
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'content': content,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'isPinned': isPinned,
      };

  factory NoteItem.fromJson(Map<String, dynamic> json) => NoteItem(
        id: json['id'] as String,
        title: json['title'] as String? ?? '',
        content: json['content'] as String? ?? '',
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
        isPinned: json['isPinned'] as bool? ?? false,
      );
}
