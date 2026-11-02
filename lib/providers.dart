import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models.dart';

/// Preferências compartilhadas (injetadas no main).
final sharedPrefsProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('sharedPrefsProvider precisa de override no main'),
);

// ---------------------------------------------------------------------------
// Premium (assinatura fictícia por enquanto)
// ---------------------------------------------------------------------------
class PremiumNotifier extends Notifier<bool> {
  static const _key = 'premium';

  @override
  bool build() => ref.read(sharedPrefsProvider).getBool(_key) ?? false;

  void set(bool value) {
    state = value;
    ref.read(sharedPrefsProvider).setBool(_key, value);
  }
}

final premiumProvider = NotifierProvider<PremiumNotifier, bool>(
  PremiumNotifier.new,
);

// ---------------------------------------------------------------------------
// Nome do usuário
// ---------------------------------------------------------------------------
class NameNotifier extends Notifier<String> {
  static const _key = 'name';

  @override
  String build() => ref.read(sharedPrefsProvider).getString(_key) ?? '';

  void set(String value) {
    state = value;
    ref.read(sharedPrefsProvider).setString(_key, value);
  }
}

final nameProvider = NotifierProvider<NameNotifier, String>(NameNotifier.new);

// ---------------------------------------------------------------------------
// Anotações
// ---------------------------------------------------------------------------
class NotesNotifier extends Notifier<List<Note>> {
  static const _key = 'notes';

  @override
  List<Note> build() {
    final raw = ref.read(sharedPrefsProvider).getString(_key);
    if (raw == null || raw.isEmpty) return const [];
    final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    return list.map(Note.fromJson).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  void _persist() {
    final list = state.map((n) => n.toJson()).toList();
    ref.read(sharedPrefsProvider).setString(_key, jsonEncode(list));
  }

  Note? noteForDate(String date) {
    for (final n in state) {
      if (n.date == date) return n;
    }
    return null;
  }

  void upsert(String id, String date, String content) {
    final note = Note(
      id: id,
      date: date,
      content: content,
      createdAt: DateTime.now(),
    );
    state = [...state.where((n) => n.id != id), note]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    _persist();
  }

  void remove(String id) {
    state = state.where((n) => n.id != id).toList();
    _persist();
  }
}

final notesProvider = NotifierProvider<NotesNotifier, List<Note>>(
  NotesNotifier.new,
);

// ---------------------------------------------------------------------------
// Sequência (streak) de dias seguidos
// ---------------------------------------------------------------------------
class StreakNotifier extends Notifier<int> {
  static const _streakKey = 'streak';
  static const _lastKey = 'lastReadDate';

  @override
  int build() => ref.read(sharedPrefsProvider).getInt(_streakKey) ?? 0;

  /// Atualiza a sequência ao abrir o devocional do dia (só conta 1x por dia).
  void markRead(DateTime today) {
    final prefs = ref.read(sharedPrefsProvider);
    final todayStr = dateKey(today);
    final last = prefs.getString(_lastKey);
    if (last == todayStr) return;

    final yesterdayStr = dateKey(today.subtract(const Duration(days: 1)));
    final next = last == yesterdayStr ? state + 1 : 1;

    state = next;
    prefs.setInt(_streakKey, next);
    prefs.setString(_lastKey, todayStr);
  }
}

final streakProvider = NotifierProvider<StreakNotifier, int>(StreakNotifier.new);
