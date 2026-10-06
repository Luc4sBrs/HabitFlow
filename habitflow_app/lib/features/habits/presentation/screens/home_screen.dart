// lib/features/habits/presentation/screens/home_screen.dart

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/theme_controller.dart';
import '../../logic/habit_controller.dart';
import '../widgets/streak_card.dart';
import '../widgets/habit_tile.dart';
import '../widgets/progress_chart.dart';
import 'habit_form_sheet.dart';
import 'habit_detail_sheet.dart';
import 'backup_sheet.dart';

enum HabitFilter { all, pending, completed }

final habitFilterProvider = StateProvider<HabitFilter>((ref) => HabitFilter.all);

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late ConfettiController _confettiController;
  bool _hasCelebratedToday = false;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _checkAllCompletedCelebration(int completed, int total) {
    if (total > 0 && completed == total && !_hasCelebratedToday) {
      _hasCelebratedToday = true;
      _confettiController.play();
      HapticFeedback.heavyImpact();
    } else if (completed < total) {
      _hasCelebratedToday = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final habitsAsync = ref.watch(habitControllerProvider);
    final activeFilter = ref.watch(habitFilterProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          habitsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
                  const SizedBox(height: 12),
                  Text('Erro: $err'),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () => ref.refresh(habitControllerProvider),
                    child: const Text('Tentar Novamente'),
                  ),
                ],
              ),
            ),
            data: (habits) {
              final now = DateTime.now();
              final completedHabits = habits.where((h) => h.isCompletedOn(now)).toList();
              final pendingHabits = habits.where((h) => !h.isCompletedOn(now)).toList();

              // Aplicação do filtro selecionado
              final filteredHabits = switch (activeFilter) {
                HabitFilter.all => habits,
                HabitFilter.pending => pendingHabits,
                HabitFilter.completed => completedHabits,
              };

              final completedToday = completedHabits.length;
              final maxStreak = habits.map((h) => h.calculateStreak()).fold(0, (a, b) => a > b ? a : b);
              final isAllCompleted = habits.isNotEmpty && completedToday == habits.length;

              return CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // Cabeçalho Responsivo (Ajustado para não estourar em nenhuma tela)
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 16, 12),
                    sliver: SliverToBoxAdapter(
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'HabitFlow AI',
                                  style: theme.textTheme.headlineMedium?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                Text(
                                  'Construa sua melhor versão',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.shield_outlined),
                                tooltip: 'Backup e Dados',
                                onPressed: () {
                                  HapticFeedback.selectionClick();
                                  BackupSheet.show(context);
                                },
                              ),
                              IconButton(
                                icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
                                tooltip: 'Alternar Tema',
                                onPressed: () {
                                  HapticFeedback.selectionClick();
                                  ref.read(themeControllerProvider.notifier).toggleTheme();
                                },
                              ),
                              const SizedBox(width: 4),
                              IconButton.filled(
                                icon: const Icon(Icons.add),
                                tooltip: 'Novo Hábito',
                                onPressed: () => HabitFormSheet.show(context),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Banner de Celebração de 100%
                  if (isAllCompleted)
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                      sliver: SliverToBoxAdapter(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.amber.shade700, width: 1.5),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.emoji_events_rounded, color: Colors.amber, size: 28),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Meta Diária Cumprida! Todos os hábitos foram concluídos hoje. 🎉',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  // Card de Sequência
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    sliver: SliverToBoxAdapter(
                      child: StreakCard(
                        streakDays: maxStreak,
                        completedToday: completedToday,
                        totalHabits: habits.length,
                      ),
                    ),
                  ),

                  // Gráfico Semanal
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    sliver: SliverToBoxAdapter(
                      child: ProgressChart(habits: habits),
                    ),
                  ),

                  // Barra de Chips de Filtro Reativo
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                    sliver: SliverToBoxAdapter(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        child: Row(
                          children: [
                            FilterChip(
                              label: Text('Todos (${habits.length})'),
                              selected: activeFilter == HabitFilter.all,
                              onSelected: (_) => ref.read(habitFilterProvider.notifier).state = HabitFilter.all,
                            ),
                            const SizedBox(width: 8),
                            FilterChip(
                              label: Text('Pendentes (${pendingHabits.length})'),
                              selected: activeFilter == HabitFilter.pending,
                              onSelected: (_) => ref.read(habitFilterProvider.notifier).state = HabitFilter.pending,
                            ),
                            const SizedBox(width: 8),
                            FilterChip(
                              label: Text('Concluídos (${completedHabits.length})'),
                              selected: activeFilter == HabitFilter.completed,
                              onSelected: (_) => ref.read(habitFilterProvider.notifier).state = HabitFilter.completed,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Lista de Hábitos Filtrada
                  if (filteredHabits.isEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(Icons.filter_list_off, size: 48, color: theme.colorScheme.outline),
                              const SizedBox(height: 12),
                              Text(
                                activeFilter == HabitFilter.pending
                                    ? 'Nenhum hábito pendente! Bom trabalho.'
                                    : 'Nenhum hábito encontrado neste filtro.',
                                style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.outline),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final habit = filteredHabits[index];
                            return HabitTile(
                              habit: habit,
                              onTap: () {
                                HapticFeedback.selectionClick();
                                HabitDetailSheet.show(context, habit);
                              },
                              onToggle: () {
                                HapticFeedback.mediumImpact();
                                ref
                                    .read(habitControllerProvider.notifier)
                                    .toggleHabitCompletion(habit.id, DateTime.now())
                                    .then((_) {
                                  final currentHabits = ref.read(habitControllerProvider).valueOrNull ?? [];
                                  final done = currentHabits.where((h) => h.isCompletedOn(DateTime.now())).length;
                                  _checkAllCompletedCelebration(done, currentHabits.length);
                                });
                              },
                              onDelete: () {
                                HapticFeedback.heavyImpact();
                                ref
                                    .read(habitControllerProvider.notifier)
                                    .removeHabit(habit.id);
                              },
                            );
                          },
                          childCount: filteredHabits.length,
                        ),
                      ),
                    ),

                  const SliverToBoxAdapter(child: SizedBox(height: 40)),
                ],
              );
            },
          ),

          // Canhão de Confetes
          ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: const [
              Colors.green,
              Colors.blue,
              Colors.pink,
              Colors.orange,
              Colors.purple,
              Colors.amber,
            ],
            numberOfParticles: 35,
            gravity: 0.25,
          ),
        ],
      ),
    );
  }
}