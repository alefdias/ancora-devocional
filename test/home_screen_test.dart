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

  testWidgets('home renderiza o devocional completo sem overflow', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
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

    final d = devotionalForDate(DateTime.now());
    expect(find.text(d.title), findsOneWidget);

    // Rola até o fim para garantir que o conteúdo longo não estoura o layout.
    await tester.dragUntilVisible(
      find.text('Reflexão'),
      find.byType(ListView),
      const Offset(0, -300),
    );
    await tester.pumpAndSettle();
    expect(find.text('Reflexão'), findsOneWidget);

    await tester.dragUntilVisible(
      find.text('Oração'),
      find.byType(ListView),
      const Offset(0, -400),
    );
    await tester.pumpAndSettle();

    await tester.dragUntilVisible(
      find.text('Toque em "Ouvir" para escutar o devocional do dia.'),
      find.byType(ListView),
      const Offset(0, -400),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
