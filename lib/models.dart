/// Modelos do Âncora: Devocional.
library;

/// Chave de data no formato yyyy-MM-dd.
String dateKey(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

/// Passagem complementar de um devocional.
class CrossReference {
  final String text;
  final String reference;

  const CrossReference({required this.text, required this.reference});

  factory CrossReference.fromJson(Map<String, dynamic> json) => CrossReference(
    text: json['text'] as String? ?? '',
    reference: json['ref'] as String? ?? '',
  );
}

/// Um devocional diário: versículo, reflexão, oração e frases de apoio.
class Devotional {
  final int dayOfYear; // 1..366
  final int month; // 1..12
  final int dayOfMonth; // 1..31
  final String monthName;
  final String reading; // plano de leitura, ex.: "Gênesis 1–2"
  final String title;
  final String verse;
  final String verseRef; // ex.: "Salmos 46:1"
  final String body; // reflexão
  final String prayer;
  final String impact; // frase de impacto
  final List<CrossReference> crossReferences;

  const Devotional({
    required this.dayOfYear,
    required this.month,
    required this.dayOfMonth,
    required this.monthName,
    required this.reading,
    required this.title,
    required this.verse,
    required this.verseRef,
    required this.body,
    required this.prayer,
    required this.impact,
    this.crossReferences = const [],
  });

  factory Devotional.fromJson(Map<String, dynamic> json) => Devotional(
    dayOfYear: json['day'] as int? ?? 1,
    month: json['month'] as int? ?? 1,
    dayOfMonth: json['dayOfMonth'] as int? ?? 1,
    monthName: json['monthName'] as String? ?? '',
    reading: json['reading'] as String? ?? '',
    title: json['title'] as String? ?? '',
    verse: json['verse'] as String? ?? '',
    verseRef: json['reference'] as String? ?? '',
    body: json['reflection'] as String? ?? '',
    prayer: json['prayer'] as String? ?? '',
    impact: json['impact'] as String? ?? '',
    crossReferences: (json['crossRefs'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(CrossReference.fromJson)
        .toList(growable: false),
  );

  /// Texto completo para narração (TTS).
  String get narrationText {
    final buffer = StringBuffer()
      ..writeln('$title.')
      ..writeln()
      ..writeln('Leitura bíblica: $reading.')
      ..writeln()
      ..writeln('$verseRef. $verse')
      ..writeln()
      ..writeln(body)
      ..writeln();
    if (prayer.isNotEmpty) {
      buffer
        ..writeln('Oração:')
        ..writeln(prayer)
        ..writeln();
    }
    if (impact.isNotEmpty) {
      buffer.writeln(impact);
    }
    return buffer.toString().trim();
  }
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
