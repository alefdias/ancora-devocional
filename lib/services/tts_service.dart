import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Narração do devocional via texto-para-voz (TTS).
class TtsService {
  TtsService._();
  static final TtsService instance = TtsService._();

  final FlutterTts _tts = FlutterTts();
  bool _available = true;

  Future<void> init() async {
    try {
      await _tts.setLanguage('pt-BR');
      await _tts.setSpeechRate(0.5);
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);
    } catch (e) {
      debugPrint('TTS indisponível nesta plataforma: $e');
      _available = false;
    }
  }

  bool get available => _available;

  Future<void> speak(String text) async {
    if (!_available) return;
    try {
      await _tts.stop();
      await _tts.speak(text);
    } catch (e) {
      debugPrint('TTS speak erro: $e');
    }
  }

  Future<void> stop() async {
    if (!_available) return;
    try {
      await _tts.stop();
    } catch (e) {
      debugPrint('TTS stop erro: $e');
    }
  }
}
