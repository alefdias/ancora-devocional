/// Modelos do Âncora: Devocional.
library;

/// Chave de data no formato yyyy-MM-dd.
String dateKey(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

/// Um devocional (versículo + reflexão) exibido em uma data.
class Devotional {
  final int id;
  final String verseRef; // ex.: "Salmos 46:1"
  final String verse;
  final String title;
  final String body;

  const Devotional({
    required this.id,
    required this.verseRef,
    required this.verse,
    required this.title,
    required this.body,
  });

  /// Texto completo para narração (TTS).
  String get narrationText =>
      '$title.\n\n$verseRef\n$verse\n\n$body';
}

/// Anotação pessoal de um dia.
class Note {
  final String id;
  final String date; // yyyy-MM-dd
  final String content;
  final DateTime createdAt;

  const Note({
    required this.id,
    required this.date,
    required this.content,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date,
    'content': content,
    'createdAt': createdAt.toIso8601String(),
  };

  factory Note.fromJson(Map<String, dynamic> json) => Note(
    id: json['id'] as String,
    date: json['date'] as String,
    content: json['content'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String),
  );
}
