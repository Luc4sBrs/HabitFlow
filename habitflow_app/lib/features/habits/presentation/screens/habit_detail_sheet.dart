// lib/features/habits/presentation/screens/habit_detail_sheet.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/habit_model.dart';
import '../../logic/habit_controller.dart';
import '../../../pomodoro/logic/pomodoro_controller.dart';

class HabitDetailSheet extends ConsumerWidget {
  final HabitModel habit;
  final VoidCallback? onStartPomodoro;

  const HabitDetailSheet({
    super.key,
    required this.habit,
    this.onStartPomodoro,
  });

  static Future<void> show(BuildContext context, HabitModel habit, {VoidCallback? onStartPomodoro}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => HabitDetailSheet(
        habit: habit,
        onStartPomodoro: onStartPomodoro,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final habitColor = Color(habit.colorValue);
    final streak = habit.calculateStreak();
    final totalCompleted = habit.completedDates.length;

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

          // Cabeçalho do Hábito
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: habitColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(Icons.bolt, color: habitColor, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      habit.title,
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    if (habit.description.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        habit.description,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Métricas do Hábito
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  context,
                  title: 'Sequência Atual',
                  value: '$streak dias',
                  icon: Icons.local_fire_department,
                  iconColor: Colors.orangeAccent,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  context,
                  title: 'Total Realizado',
                  value: '$totalCompleted vezes',
                  icon: Icons.check_circle_outline,
                  iconColor: habitColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Ação 1: Iniciar Foco Pomodoro Direto
          FilledButton.icon(
            onPressed: () {
              HapticFeedback.mediumImpact();
              Navigator.pop(context);
              // Vincula o hábito ativo no timer e dispara o início
              ref.read(pomodoroProvider.notifier).resetTimer();
              ref.read(pomodoroProvider.notifier).startTimer(habitId: habit.id);
              onStartPomodoro?.call();
            },
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              backgroundColor: habitColor,
            ),
            icon: const Icon(Icons.timer_outlined, color: Colors.white),
            label: const Text(
              'Iniciar Pomodoro Neste Hábito',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 12),

          // Ação 2: Excluir Hábito com confirmação
          OutlinedButton.icon(
            onPressed: () {
              HapticFeedback.heavyImpact();
              Navigator.pop(context);
              ref.read(habitControllerProvider.notifier).removeHabit(habit.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Hábito "${habit.title}" removido.'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              foregroundColor: theme.colorScheme.error,
              side: BorderSide(color: theme.colorScheme.error.withOpacity(0.4)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            icon: const Icon(Icons.delete_outline),
            label: const Text('Excluir Hábito'),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  title,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}