import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../data/devotionals.dart';
import '../../models.dart';
import '../../providers.dart';
import '../../services/ad_service.dart';
import '../../services/tts_service.dart';

class AudioScreen extends ConsumerStatefulWidget {
  const AudioScreen({super.key});

  @override
  ConsumerState<AudioScreen> createState() => _AudioScreenState();
}

class _AudioScreenState extends ConsumerState<AudioScreen> {
  bool _unlocked = false;
  bool _speaking = false;
  late final Devotional _devotional;

  @override
  void initState() {
    super.initState();
    _devotional = devotionalForDate(DateTime.now());
    _unlocked =
        ref.read(sharedPrefsProvider).getString('unlockedAudioDate') ==
        dateKey(DateTime.now());
  }

  @override
  void dispose() {
    TtsService.instance.stop();
    super.dispose();
  }

  Future<void> _toggle() async {
    if (_speaking) {
      await TtsService.instance.stop();
      if (mounted) setState(() => _speaking = false);
      return;
    }

    if (!TtsService.instance.available) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('O áudio funciona no celular (Android/iOS).'),
        ),
      );
      return;
    }

    if (_unlocked) {
      await _speak();
      return;
    }

    // Bloqueado: exige anúncio rewarded (1x por dia).
    await AdService.instance.showRewarded(
      onReward: () async {
        await ref
            .read(sharedPrefsProvider)
            .setString('unlockedAudioDate', dateKey(DateTime.now()));
        if (mounted) setState(() => _unlocked = true);
        await _speak();
      },
    );
  }

  Future<void> _speak() async {
    await TtsService.instance.speak(_devotional.narrationText);
    if (mounted) setState(() => _speaking = true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Devocional em áudio')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 8),
            Text(
              _devotional.verseRef,
              style: const TextStyle(
                color: AppColors.gold,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _devotional.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.navy,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '“${_devotional.verse}”',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                height: 1.4,
                fontStyle: FontStyle.italic,
                color: AppColors.textSecondary,
              ),
            ),
            const Spacer(),
            // Botão central
            InkWell(
              onTap: _toggle,
              borderRadius: BorderRadius.circular(100),
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.navyGradient,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.navy.withValues(alpha: 0.3),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    _speaking
                        ? Icons.stop_rounded
                        : (_unlocked
                            ? Icons.play_arrow_rounded
                            : Icons.lock_rounded),
                    color: Colors.white,
                    size: 56,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              !_unlocked
                  ? 'Toque para assistir um anúncio e liberar o áudio de hoje 🎁'
                  : (_speaking
                      ? 'Toque para parar'
                      : 'Toque para ouvir'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
