import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../models.dart';
import '../../providers.dart';
import '../../services/ad_service.dart';

class NotesEditorScreen extends ConsumerStatefulWidget {
  final String date;
  const NotesEditorScreen({super.key, required this.date});

  @override
  ConsumerState<NotesEditorScreen> createState() => _NotesEditorScreenState();
}

class _NotesEditorScreenState extends ConsumerState<NotesEditorScreen> {
  late final TextEditingController _controller;
  late final String _noteId;

  @override
  void initState() {
    super.initState();
    final existing = ref.read(notesProvider.notifier).noteForDate(widget.date);
    _noteId = existing?.id ?? DateTime.now().microsecondsSinceEpoch.toString();
    _controller = TextEditingController(text: existing?.content ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final content = _controller.text.trim();
    if (content.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Escreva algo antes de salvar.')));
      return;
    }

    ref
        .read(notesProvider.notifier)
        .upsert(_noteId, widget.date, content);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Anotação salva ✓')));

    // Intersticial APENAS no 1º salvamento do dia (nunca ao editar de novo).
    final isToday = widget.date == dateKey(DateTime.now());
    if (isToday) {
      final prefs = ref.read(sharedPrefsProvider);
      final today = dateKey(DateTime.now());
      if (prefs.getString('noteSavedDate') != today) {
        await prefs.setString('noteSavedDate', today);
        await AdService.instance.showInterstitial();
      }
    }

    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Anotação do dia'),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text(
              'Salvar',
              style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Sua reflexão de hoje',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 6),
            Text(
              'Registre o que Deus falou ao seu coração. Só você vê isso.',
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TextField(
                controller: _controller,
                expands: true,
                maxLines: null,
                textAlignVertical: TextAlignVertical.top,
                decoration: const InputDecoration(
                  hintText: 'Escreva sua reflexão de hoje...',
                  alignLabelWithHint: true,
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.check_rounded),
              label: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }
}
