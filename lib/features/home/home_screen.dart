import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../data/devotionals.dart';
import '../../providers.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(streakProvider.notifier).markRead(DateTime.now());
    });
  }

  String _todayLabel() {
    const weekdays = [
      'Segunda-feira', 'Terça-feira', 'Quarta-feira', 'Quinta-feira',
      'Sexta-feira', 'Sábado', 'Domingo',
    ];
    const months = [
      'janeiro', 'fevereiro', 'março', 'abril', 'maio', 'junho',
      'julho', 'agosto', 'setembro', 'outubro', 'novembro', 'dezembro',
    ];
    final now = DateTime.now();
    return '${weekdays[now.weekday - 1]}, ${now.day} de ${months[now.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    final devotional = devotionalForDate(DateTime.now());
    final streak = ref.watch(streakProvider);
    final name = ref.watch(nameProvider);
    final religion = ref.watch(religionProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.anchor_rounded, color: AppColors.gold, size: 22),
            SizedBox(width: 6),
            Text('Âncora', style: TextStyle(fontWeight: FontWeight.w800)),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.goldSoft,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '🔥 $streak dias',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.navy,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          if (religion == 'catolico') ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.goldSoft,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.gold),
              ),
              child: const Row(
                children: [
                  Icon(Icons.church_rounded, color: AppColors.navy, size: 22),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Conteúdo católico em breve! Por enquanto, você verá o devocional evangélico.',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.navy,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
          Text(
            _todayLabel(),
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          if (name.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              'Bom dia, $name! ☀️',
              style: const TextStyle(
                color: AppColors.navy,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
          const SizedBox(height: 16),

          // Plano de leitura do dia
          if (devotional.reading.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.menu_book_rounded,
                    size: 18,
                    color: AppColors.gold,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Plano de leitura',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      devotional.reading,
                      textAlign: TextAlign.end,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.navy,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],

          // Cartão do versículo
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: AppColors.navyGradient,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.navy.withValues(alpha: 0.25),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  devotional.verseRef,
                  style: const TextStyle(
                    color: AppColors.gold,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  '“${devotional.verse}”',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    height: 1.35,
                    fontWeight: FontWeight.w600,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  devotional.title,
                  style: const TextStyle(
                    color: AppColors.gold,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Reflexão
          const _SectionTitle('Reflexão'),
          const SizedBox(height: 10),
          _Paragraphs(devotional.body),
          const SizedBox(height: 20),

          // Frase de impacto
          if (devotional.impact.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.goldSoft,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.gold),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.format_quote_rounded,
                    color: AppColors.navy,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      devotional.impact,
                      style: const TextStyle(
                        color: AppColors.navy,
                        fontSize: 14,
                        height: 1.45,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Oração
          if (devotional.prayer.isNotEmpty) ...[
            const _SectionTitle('Oração'),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.volunteer_activism_rounded,
                    color: AppColors.gold,
                    size: 22,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    devotional.prayer,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 15,
                      height: 1.55,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Leituras complementares
          if (devotional.crossReferences.isNotEmpty) ...[
            const _SectionTitle('Leituras complementares'),
            const SizedBox(height: 10),
            ...devotional.crossReferences.map(
              (ref) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '“${ref.text}”',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                          height: 1.45,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        ref.reference,
                        style: const TextStyle(
                          color: AppColors.gold,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
          ],

          // Ações: Ouvir + Anotar
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => context.push('/notes'),
                  icon: const Icon(Icons.edit_note_rounded),
                  label: const Text('Anotar'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => context.push('/audio'),
                  icon: const Icon(Icons.headphones_rounded),
                  label: const Text('Ouvir'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Toque em "Ouvir" para escutar o devocional do dia.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textMuted, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: AppColors.gold,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.navy,
            ),
          ),
        ),
      ],
    );
  }
}

class _Paragraphs extends StatelessWidget {
  const _Paragraphs(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final paragraphs = text
        .split(RegExp(r'\n\s*\n'))
        .map((p) => p.trim())
        .where((p) => p.isNotEmpty)
        .toList(growable: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < paragraphs.length; i++) ...[
          if (i > 0) const SizedBox(height: 12),
          Text(
            paragraphs[i],
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 15,
              height: 1.6,
            ),
          ),
        ],
      ],
    );
  }
}
