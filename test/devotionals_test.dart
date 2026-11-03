import 'package:ancora_devocional/data/devotionals.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await DevotionalLibrary.load();
  });

  test('carrega os 366 devocionais', () {
    expect(DevotionalLibrary.isLoaded, isTrue);
    expect(devotionalCount, 366);
  });

  test('todos os devocionais têm conteúdo essencial', () {
    for (var dia = 1; dia <= 366; dia++) {
      final d = DevotionalLibrary.forDayOfYear(dia);
      expect(d.title, isNotEmpty, reason: 'dia $dia sem título');
      expect(d.verse, isNotEmpty, reason: 'dia $dia sem versículo');
      expect(d.verseRef, isNotEmpty, reason: 'dia $dia sem referência');
      expect(d.body, isNotEmpty, reason: 'dia $dia sem reflexão');
      expect(d.prayer, isNotEmpty, reason: 'dia $dia sem oração');
      expect(d.crossReferences.length, 2, reason: 'dia $dia sem 2 complementos');
    }
  });

  test('seleciona pelo mês e dia (inclusive 29 de fevereiro)', () {
    final anoNovo = devotionalForDate(DateTime(2027, 1, 1));
    expect(anoNovo.title, 'O Primeiro Passo da Fé com Deus');

    final bissexto = devotionalForDate(DateTime(2028, 2, 29));
    expect(bissexto.month, 2);
    expect(bissexto.dayOfMonth, 29);

    final novembro = devotionalForDate(DateTime(2026, 11, 3));
    expect(novembro.month, 11);
    expect(novembro.dayOfMonth, 3);
  });
}
