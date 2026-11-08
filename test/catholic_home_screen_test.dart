import 'package:ancora_devocional/app/theme.dart';
import 'package:ancora_devocional/data/devotionals.dart';
import 'package:ancora_devocional/features/home/home_screen.dart';
import 'package:ancora_devocional/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await DevotionalLibrary.load();
  });

  testWidgets('home católica mostra liturgia, propósito e desafio', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'religion': 'catolico'});
    final prefs = await SharedPreferences.getInstance();

    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPrefsProvider.overrideWithValue(prefs)],
        child: MaterialApp(theme: AppTheme.light(), home: const HomeScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Liturgia do dia'), findsOneWidget);
    expect(find.textContaining('em breve'), findsNothing);

    await tester.dragUntilVisible(
      find.text('Propósito do dia'),
      find.byType(ListView),
      const Offset(0, -300),
    );
    await tester.pumpAndSettle();
    expect(find.text('Propósito do dia'), findsOneWidget);

    await tester.dragUntilVisible(
      find.text('Desafio da semana'),
      find.byType(ListView),
      const Offset(0, -400),
    );
    await tester.pumpAndSettle();
    expect(find.text('Desafio da semana'), findsOneWidget);

    await tester.dragUntilVisible(
      find.text('Toque em "Ouvir" para escutar o devocional do dia.'),
      find.byType(ListView),
      const Offset(0, -500),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
