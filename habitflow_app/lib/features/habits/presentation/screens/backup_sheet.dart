// lib/features/habits/presentation/screens/backup_sheet.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../logic/habit_controller.dart';

class BackupSheet extends ConsumerWidget {
  const BackupSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => const BackupSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 20,
        bottom: MediaQuery.of(context).padding.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Barra de Arraste Superior
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          Row(
            children: [
              Icon(Icons.shield_outlined, color: theme.colorScheme.primary),
              const SizedBox(width: 10),
              Text(
                'Privacidade & Backup',
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Seus hábitos estão salvos apenas no seu aparelho. Exporte uma cópia em texto para salvar no seu Bloco de Notas ou restaurar quando quiser.',
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 24),

          // Opção 1: Exportar / Copiar JSON
          FilledButton.tonalIcon(
            onPressed: () async {
              HapticFeedback.mediumImpact();
              final backupString = await ref.read(habitControllerProvider.notifier).exportBackup();
              await Clipboard.setData(ClipboardData(text: backupString));

              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Backup copiado para a área de transferência!'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            icon: const Icon(Icons.copy_rounded),
            label: const Text('Exportar Dados (Copiar Backup)'),
          ),
          const SizedBox(height: 12),

          // Opção 2: Restaurar Backup
          OutlinedButton.icon(
            onPressed: () => _showRestoreDialog(context, ref),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            icon: const Icon(Icons.download_rounded),
            label: const Text('Restaurar de um Backup'),
          ),
          const SizedBox(height: 12),

          // Opção 3: Zerar Dados
          TextButton.icon(
            onPressed: () => _confirmReset(context, ref),
            style: TextButton.styleFrom(foregroundColor: theme.colorScheme.error),
            icon: const Icon(Icons.delete_forever_outlined),
            label: const Text('Zerar Todos os Hábitos'),
          ),
        ],
      ),
    );
  }

  void _showRestoreDialog(BuildContext context, WidgetRef ref) {
    final textController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Restaurar Backup'),
        content: TextField(
          controller: textController,
          maxLines: 6,
          decoration: const InputDecoration(
            hintText: 'Cole o texto do JSON do seu backup aqui...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              final text = textController.text.trim();
              if (text.isEmpty) return;

              final success = await ref.read(habitControllerProvider.notifier).restoreBackup(text);
              if (ctx.mounted) Navigator.pop(ctx);
              if (context.mounted) Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    success ? 'Hábitos restaurados com sucesso!' : 'Erro: Formato de backup inválido.',
                  ),
                  backgroundColor: success ? Colors.green : Colors.red,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Restaurar'),
          ),
        ],
      ),
    );
  }

  void _confirmReset(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Zerar todos os dados?'),
        content: const Text('Esta ação apagará todos os seus hábitos e históricos do aparelho. Não pode ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Theme.of(ctx).colorScheme.error),
            onPressed: () {
              ref.read(habitControllerProvider.notifier).resetAllData();
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('Zerar Tudo'),
          ),
        ],
      ),
    );
  }
}