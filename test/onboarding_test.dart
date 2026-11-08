import 'package:ancora_devocional/features/onboarding/onboarding_screen.dart';
import 'package:ancora_devocional/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('primeiro login exige escolher católico ou evangélico', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    final router = GoRouter(
      initialLocation: '/onboarding',
      routes: [
        GoRoute(
          path: '/onboarding',
          builder: (context, state) => const OnboardingScreen(),
        ),
        GoRoute(
          path: '/',
          builder: (context, state) => const Scaffold(body: Text('home')),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPrefsProvider.overrideWithValue(prefs)],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    // Sem escolha, o botão fica desabilitado e o app pede uma opção.
    expect(find.text('Escolha uma opção para continuar.'), findsOneWidget);
    var botao = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'Começar'),
    );
    expect(botao.onPressed, isNull);

    // Escolhe católico e confirma.
    await tester.tap(find.text('Católico'));
    await tester.pumpAndSettle();

    botao = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'Começar'),
    );
    expect(botao.onPressed, isNotNull);

    await tester.tap(find.text('Começar'));
    await tester.pumpAndSettle();

    expect(find.text('home'), findsOneWidget);
    expect(prefs.getString('religion'), 'catolico');
  });
}
