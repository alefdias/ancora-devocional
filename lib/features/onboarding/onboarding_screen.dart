import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../providers.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _nameController = TextEditingController();

  // Começa sem seleção para obrigar o usuário a escolher no primeiro login.
  String? _religion;

  @override
  void initState() {
    super.initState();
    final salva = ref.read(religionProvider);
    _religion = salva.isEmpty ? null : salva;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _start() {
    final religion = _religion;
    if (religion == null) return;
    final name = _nameController.text.trim();
    if (name.isNotEmpty) {
      ref.read(nameProvider.notifier).set(name);
    }
    ref.read(religionProvider.notifier).set(religion);
    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              const Icon(Icons.anchor_rounded, color: AppColors.gold, size: 60),
              const SizedBox(height: 16),
              const Text(
                'Bem-vindo(a) ao Âncora',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: AppColors.navy,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Um devocional por dia, com áudio e um espaço para anotar sua caminhada.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 28),
              TextField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Como podemos te chamar?',
                  hintText: 'Seu nome',
                  prefixIcon: Icon(Icons.person_outline_rounded),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Como você quer seu devocional?',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.navy,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _ReligionCard(
                      title: 'Evangélico',
                      subtitle: 'Versículo + reflexão diária',
                      icon: Icons.menu_book_rounded,
                      selected: _religion == 'evangelico',
                      onTap: () => setState(() => _religion = 'evangelico'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ReligionCard(
                      title: 'Católico',
                      subtitle: 'Liturgia diária',
                      icon: Icons.church_rounded,
                      selected: _religion == 'catolico',
                      onTap: () => setState(() => _religion = 'catolico'),
                    ),
                  ),
                ],
              ),
              if (_religion == null) ...[
                const SizedBox(height: 10),
                const Text(
                  'Escolha uma opção para continuar.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _religion == null ? null : _start,
                child: const Text('Começar'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReligionCard extends StatelessWidget {
  const _ReligionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? AppColors.navy : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppColors.navy : AppColors.border,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 30,
              color: selected ? AppColors.gold : AppColors.textSecondary,
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: selected ? Colors.white : AppColors.navy,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: selected
                    ? Colors.white.withValues(alpha: 0.8)
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
