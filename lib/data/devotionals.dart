import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../models.dart';

/// Biblioteca dos devocionais, com duas trilhas:
/// - `evangelico`: asset `assets/data/devotionals.json`
/// - `catolico`:   asset `assets/data/devotionals_catolico.json`
///
/// As duas são carregadas no `main()`; a escolha acontece em tempo de execução
/// conforme a afiliação religiosa do usuário (`religionProvider`).
class DevotionalLibrary {
  DevotionalLibrary._();

  static const _assetEvangelical = 'assets/data/devotionals.json';
  static const _assetCatholic = 'assets/data/devotionals_catolico.json';

  static List<Devotional> _evangelical = const [];
  static List<Devotional> _catholic = const [];

  static Map<int, Devotional> _byMonthDayEvangelical = const {};
  static Map<int, Devotional> _byMonthDayCatholic = const {};

  static bool get isLoaded => _evangelical.isNotEmpty;
  static bool get isCatholicLoaded => _catholic.isNotEmpty;

  /// Quantidade da trilha evangélica (compatibilidade).
  static int get count => _evangelical.length;

  static int countFor(String religion) => _listFor(religion).length;

  /// Carrega os dois assets uma única vez. Chamado no `main()` antes do `runApp`.
  static Future<void> load({AssetBundle? bundle}) async {
    if (_evangelical.isEmpty) {
      _evangelical = await _load(_assetEvangelical, bundle);
      _byMonthDayEvangelical = _index(_evangelical);
    }
    if (_catholic.isEmpty) {
      _catholic = await _load(_assetCatholic, bundle);
      _byMonthDayCatholic = _index(_catholic);
    }
  }

  static Future<List<Devotional>> _load(
    String assetPath,
    AssetBundle? bundle,
  ) async {
    try {
      final raw = await (bundle ?? rootBundle).loadString(assetPath);
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(Devotional.fromJson)
          .toList(growable: false);
    } catch (e) {
      debugPrint('Falha ao carregar $assetPath: $e');
      return const [];
    }
  }

  static Map<int, Devotional> _index(List<Devotional> list) => {
    for (final d in list) d.month * 100 + d.dayOfMonth: d,
  };

  static List<Devotional> _listFor(String religion) =>
      religion == 'catolico' && _catholic.isNotEmpty ? _catholic : _evangelical;

  static Map<int, Devotional> _mapFor(String religion) =>
      religion == 'catolico' && _catholic.isNotEmpty
          ? _byMonthDayCatholic
          : _byMonthDayEvangelical;

  /// Devocional do dia (busca por mês/dia; funciona em anos bissextos e comuns).
  static Devotional forDate(DateTime date, {String religion = 'evangelico'}) {
    final map = _mapFor(religion);
    if (map.isEmpty) return _fallback;

    final exact = map[date.month * 100 + date.day];
    if (exact != null) return exact;

    // Segurança: se faltar o dia exato, usa o dia do ano mais próximo.
    final list = _listFor(religion);
    final dayOfYear = date.difference(DateTime(date.year, 1, 1)).inDays + 1;
    final index = (dayOfYear - 1).clamp(0, list.length - 1);
    return list[index];
  }

  /// Devocional por número do dia no ano (1..366).
  static Devotional forDayOfYear(int day, {String religion = 'evangelico'}) {
    final list = _listFor(religion);
    if (list.isEmpty) return _fallback;
    final index = (day - 1).clamp(0, list.length - 1);
    return list[index];
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

/// Retorna o devocional do dia, conforme a trilha escolhida.
Devotional devotionalForDate(DateTime date, {String religion = 'evangelico'}) =>
    DevotionalLibrary.forDate(date, religion: religion);

/// Quantidade de devocionais disponíveis na trilha evangélica.
int get devotionalCount => DevotionalLibrary.count;

/// Quantidade de devocionais disponíveis em uma trilha.
int devotionalCountFor(String religion) => DevotionalLibrary.countFor(religion);
