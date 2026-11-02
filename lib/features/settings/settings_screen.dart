import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = ref.watch(nameProvider);
    final isPremium = ref.watch(premiumProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _SectionTitle('Perfil'),
          Card(
            child: ListTile(
              leading: const Icon(Icons.person_outline_rounded, color: AppColors.gold),
              title: const Text('Nome'),
              subtitle: Text(name.isEmpty ? 'Não definido' : name),
              onTap: () => _editName(context, ref),
            ),
          ),
          const SizedBox(height: 16),

          _SectionTitle('Assinatura'),
          Card(
            child: ListTile(
              leading: Icon(
                isPremium ? Icons.workspace_premium_rounded : Icons.lock_rounded,
                color: AppColors.gold,
              ),
              title: Text(isPremium ? 'Premium ativo' : 'Plano gratuito'),
              subtitle: const Text('Áudio ilimitado, histórico e sem anúncios'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => context.push('/premium'),
            ),
          ),
          const SizedBox(height: 16),

          _SectionTitle('Sobre'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.info_outline_rounded, color: AppColors.gold),
                  title: const Text('Sobre o Âncora'),
                  subtitle: const Text('Devocional diário com versículo, áudio e reflexão.'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.privacy_tip_outlined, color: AppColors.gold),
                  title: const Text('Política de Privacidade'),
                  subtitle: const Text('Seus dados ficam no seu aparelho.'),
                  onTap: () => _showPrivacy(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Âncora: Devocional · v1.0.0',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textMuted, fontSize: 12),
          ),
        ],
      ),
    );
  }

  void _editName(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController(text: ref.read(nameProvider));
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Seu nome'),
        content: TextField(
          controller: controller,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(hintText: 'Como podemos te chamar?'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              ref.read(nameProvider.notifier).set(controller.text.trim());
              Navigator.pop(ctx);
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  void _showPrivacy(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Política de Privacidade'),
        content: const Text(
          'Suas anotações e dados ficam armazenados localmente no seu aparelho. '
          'Não compartilhamos seus dados pessoais. Os anúncios são exibidos de '
          'forma não personalizada.',
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Entendi'),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
