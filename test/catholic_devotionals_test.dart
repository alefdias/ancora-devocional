import 'package:ancora_devocional/data/devotionals.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await DevotionalLibrary.load();
  });

  test('carrega os 366 devocionais católicos', () {
    expect(DevotionalLibrary.isCatholicLoaded, isTrue);
    expect(devotionalCountFor('catolico'), 366);
    expect(devotionalCountFor('evangelico'), 366);
  });

  test('todos os dias católicos têm os campos litúrgicos', () {
    for (var dia = 1; dia <= 366; dia++) {
      final d = DevotionalLibrary.forDayOfYear(dia, religion: 'catolico');
      expect(d.isCatholic, isTrue, reason: 'dia $dia não é católico');
      expect(d.celebration, isNotEmpty, reason: 'dia $dia sem celebração');
      expect(
        d.liturgicalTime,
        isNotEmpty,
        reason: 'dia $dia sem tempo litúrgico',
      );
      expect(
        d.liturgicalColor,
        isNotEmpty,
        reason: 'dia $dia sem cor litúrgica',
      );
      expect(d.readings, isNotEmpty, reason: 'dia $dia sem leituras');
      expect(d.gospel, isNotEmpty, reason: 'dia $dia sem Evangelho');
      expect(d.saint, isNotEmpty, reason: 'dia $dia sem santo');
      expect(d.purpose, isNotEmpty, reason: 'dia $dia sem propósito');
      expect(d.verse, isNotEmpty, reason: 'dia $dia sem versículo');
      expect(d.body, isNotEmpty, reason: 'dia $dia sem reflexão');
      expect(d.prayer, isNotEmpty, reason: 'dia $dia sem oração');
    }
  });

  test('desafio semanal cobre os dias 8 a 366', () {
    for (var dia = 1; dia <= 7; dia++) {
      expect(
        DevotionalLibrary.forDayOfYear(dia, religion: 'catolico').challenge,
        isNull,
        reason: 'dia $dia não deveria ter desafio',
      );
    }
    for (var dia = 8; dia <= 366; dia++) {
      final c =
          DevotionalLibrary.forDayOfYear(dia, religion: 'catolico').challenge;
      expect(c, isNotNull, reason: 'dia $dia sem desafio');
      expect(c!.title, isNotEmpty);
      expect(c.goal, isNotEmpty);
    }
  });

  test(
    'seleciona o conteúdo católico pela data, sem misturar com o evangélico',
    () {
      final catolico = devotionalForDate(
        DateTime(2027, 1, 1),
        religion: 'catolico',
      );
      expect(catolico.celebration, 'Santa Maria, Mãe de Deus');
      expect(catolico.gospel, 'Lc 2,16-21');
      expect(catolico.liturgicalTime, 'Tempo do Natal');
      expect(catolico.liturgicalColor, 'Branco');

      final evangelico = devotionalForDate(
        DateTime(2027, 1, 1),
        religion: 'evangelico',
      );
      expect(evangelico.title, 'O Primeiro Passo da Fé com Deus');
      expect(evangelico.isCatholic, isFalse);

      // 29 de fevereiro existe na trilha católica.
      final bissexto = devotionalForDate(
        DateTime(2028, 2, 29),
        religion: 'catolico',
      );
      expect(bissexto.month, 2);
      expect(bissexto.dayOfMonth, 29);
    },
  );

  test('narração católica inclui liturgia, Evangelho e desafio', () {
    final d = DevotionalLibrary.forDayOfYear(8, religion: 'catolico');
    final texto = d.narrationText;
    expect(texto, contains('Evangelho:'));
    expect(texto, contains('Propósito do dia:'));
    expect(texto, contains('Desafio da semana:'));
  });
}
