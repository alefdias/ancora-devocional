import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../models.dart';

/// Biblioteca dos devocionais reais (366 dias), carregada do asset
/// `assets/data/devotionals.json` — gerado a partir do livro "Âncora Devocional".
class DevotionalLibrary {
  DevotionalLibrary._();

  static const _assetPath = 'assets/data/devotionals.json';

  static List<Devotional> _all = const [];
  static Map<int, Devotional> _byMonthDay = const {};

  static bool get isLoaded => _all.isNotEmpty;
  static int get count => _all.length;

  /// Carrega o JSON uma única vez. Chamado no `main()` antes do `runApp`.
  static Future<void> load({AssetBundle? bundle}) async {
    if (_all.isNotEmpty) return;
    try {
      final raw = await (bundle ?? rootBundle).loadString(_assetPath);
      final decoded = jsonDecode(raw) as List<dynamic>;
      final list = decoded
          .whereType<Map<String, dynamic>>()
          .map(Devotional.fromJson)
          .toList(growable: false);
      if (list.isEmpty) return;
      _all = list;
      _byMonthDay = {
        for (final d in list) d.month * 100 + d.dayOfMonth: d,
      };
    } catch (e) {
      debugPrint('Falha ao carregar devocionais: $e');
    }
  }

  /// Devocional do dia (busca por mês/dia; funciona em anos bissextos e comuns).
  static Devotional forDate(DateTime date) {
    if (_byMonthDay.isEmpty) return _fallback;

    final exact = _byMonthDay[date.month * 100 + date.day];
    if (exact != null) return exact;

    // Segurança: se faltar o dia exato, usa o dia do ano mais próximo.
    final dayOfYear = date.difference(DateTime(date.year, 1, 1)).inDays + 1;
    final index = (dayOfYear - 1).clamp(0, _all.length - 1);
    return _all[index];
  }

  /// Devocional por número do dia no ano (1..366).
  static Devotional forDayOfYear(int day) {
    if (_all.isEmpty) return _fallback;
    final index = (day - 1).clamp(0, _all.length - 1);
    return _all[index];
  }

  /// Usado apenas se o asset não puder ser lido (nunca deve acontecer em uso normal).
  static const Devotional _fallback = Devotional(
    dayOfYear: 1,
    month: 1,
    dayOfMonth: 1,
    monthName: 'Janeiro',
    reading: '',
    title: 'Âncora da Alma',
    verse: 'Temos esta esperança como âncora da alma, firme e segura.',
    verseRef: 'Hebreus 6:19',
    body:
        'As ondas da vida vêm e vão, mas a esperança em Deus é uma âncora que não se move. '
        'Mesmo quando tudo parece instável, há algo firme para segurar. '
        'Agarre-se a essa âncora e deixe que ela mantenha o seu coração em paz.',
    prayer:
        'Senhor, firma o meu coração na Tua esperança e guarda os meus passos. Amém.',
    impact: 'A esperança em Deus é a âncora que mantém a alma firme.',
  );
}

/// Retorna o devocional do dia, baseado na data.
Devotional devotionalForDate(DateTime date) => DevotionalLibrary.forDate(date);

/// Quantidade de devocionais disponíveis.
int get devotionalCount => DevotionalLibrary.count;
