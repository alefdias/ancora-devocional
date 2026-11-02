import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'providers.dart';
import 'services/ad_service.dart';
import 'services/tts_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase: no Linux/desktop não existe, então o app continua mesmo se falhar.
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase não inicializado nesta plataforma: $e');
  }

  final prefs = await SharedPreferences.getInstance();

  // Anúncios e TTS: inicializam de forma segura.
  await AdService.instance.initialize();
  await TtsService.instance.init();

  runApp(
    ProviderScope(
      overrides: [sharedPrefsProvider.overrideWithValue(prefs)],
      child: const AncoraApp(),
    ),
  );
}
