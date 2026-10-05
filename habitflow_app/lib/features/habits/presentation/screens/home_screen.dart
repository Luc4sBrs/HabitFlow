// lib/features/habits/presentation/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../logic/habit_controller.dart';
import '../widgets/streak_card.dart';
import '../widgets/habit_tile.dart';
import '../widgets/progress_chart.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsAsync = ref.watch(habitControllerProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('HabitFlow AI', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'Novo Hábito',
            onPressed: () => _showCreateHabitDialog(context, ref),
          ),
        ],
      ),
      body: habitsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
              const SizedBox(height: 12),
              Text('Erro ao sincronizar dados: $err'),
              FilledButton(
                onPressed: () => ref.refresh(habitControllerProvider),
                child: const Text('Tentar Novamente'),
              ),
            ],
          ),
        ),
        data: (habits) {
          if (habits.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.spa_outlined, size: 64, color: theme.colorScheme.outline),
                  const SizedBox(height: 16),
                  Text('Nenhum hábito cadastrado ainda', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  FilledButton.tonal(
                    onPressed: () => _showCreateHabitDialog(context, ref),
                    child: const Text('Criar Meu Primeiro Hábito'),
                  ),
                ],
              ),
            );
          }

          final now = DateTime.now();
          final completedToday = habits.where((h) => h.isCompletedOn(now)).length;
          final maxStreak = habits.map((h) => h.calculateStreak()).fold(0, (a, b) => a > b ? a : b);

          return RefreshIndicator(
            onRefresh: () async => ref.refresh(habitControllerProvider.future),
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                StreakCard(
                  streakDays: maxStreak,
                  completedToday: completedToday,
                  totalHabits: habits.length,
                ),
                const SizedBox(height: 16),
                ProgressChart(habits: habits),
                const SizedBox(height: 24),
                Text(
                  'Seus Hábitos de Hoje',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...habits.map(
                  (habit) => HabitTile(
                    habit: habit,
                    onToggle: () => ref
                        .read(habitControllerProvider.notifier)
                        .toggleHabitCompletion(habit.id, DateTime.now()),
                    onDelete: () => ref
                        .read(habitControllerProvider.notifier)
                        .removeHabit(habit.id),
                  ),
                ),
                const SizedBox(height: 80),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateHabitDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Novo Hábito'),
      ),
    );
  }

  void _showCreateHabitDialog(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    final descController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 24,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Criar Novo Hábito', style: Theme.of(ctx).textTheme.titleLarge),
            const SizedBox(height: 16),
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Título do Hábito',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descController,
              decoration: const InputDecoration(
                labelText: 'Descrição (opcional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () {
                if (titleController.text.trim().isNotEmpty) {
                  ref.read(habitControllerProvider.notifier).createHabit(
                        title: titleController.text.trim(),
                        description: descController.text.trim(),
                        iconCode: 'star',
                        colorValue: 0xFF6366F1,
                      );
                  Navigator.pop(ctx);
                }
              },
              child: const Text('Salvar Hábito'),
            ),
          ],
        ),
      ),
    );
  }
}