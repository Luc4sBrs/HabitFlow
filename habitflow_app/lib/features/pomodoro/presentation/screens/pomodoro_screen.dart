// lib/features/pomodoro/presentation/screens/pomodoro_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitflow_app/features/habits/logic/habit_controller.dart';
import 'package:habitflow_app/features/pomodoro/logic/pomodoro_controller.dart';

class PomodoroScreen extends ConsumerWidget {
  const PomodoroScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pomodoro = ref.watch(pomodoroProvider);
    final habitsAsync = ref.watch(habitControllerProvider);
    final theme = Theme.of(context);
    final isRunning = pomodoro.status == PomodoroStatus.running;

    const presets = [15, 25, 45, 60];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Foco Pomodoro', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      // SingleChildScrollView protege contra qualquer estouro vertical
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Column(
            children: [
              // 1. Seletor de Hábito
              habitsAsync.maybeWhen(
                data: (habits) => DropdownButtonFormField<String>(
                  value: pomodoro.activeHabitId,
                  isExpanded: true, // Evita overflow de nomes longos
                  decoration: InputDecoration(
                    labelText: 'Vincular ao Hábito',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    prefixIcon: const Icon(Icons.link_rounded),
                  ),
                  hint: const Text('Selecione um hábito para pontuar'),
                  items: habits.map((h) {
                    return DropdownMenuItem(
                      value: h.id,
                      child: Text(h.title, overflow: TextOverflow.ellipsis),
                    );
                  }).toList(),
                  onChanged: isRunning
                      ? null
                      : (id) => ref.read(pomodoroProvider.notifier).startTimer(habitId: id),
                ),
                orElse: () => const SizedBox.shrink(),
              ),
              const SizedBox(height: 12),

              // 2. Presets de Tempo
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: presets.map((mins) {
                    final isSelected = pomodoro.totalSeconds == mins * 60;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ChoiceChip(
                        label: Text('${mins} min'),
                        selected: isSelected,
                        onSelected: isRunning
                            ? null
                            : (selected) {
                                if (selected) {
                                  ref.read(pomodoroProvider.notifier).setCustomDuration(mins);
                                }
                              },
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 28),

              // 3. Indicador Circular Responsivo
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 220,
                    height: 220,
                    child: CircularProgressIndicator(
                      value: pomodoro.progress,
                      strokeWidth: 10,
                      strokeCap: StrokeCap.round,
                      backgroundColor: theme.colorScheme.surfaceContainerHighest,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        pomodoro.formattedTime,
                        style: theme.textTheme.displayMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          letterSpacing: -1.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          isRunning
                              ? 'FOCO ATIVO'
                              : pomodoro.status == PomodoroStatus.paused
                                  ? 'PAUSADO'
                                  : 'PRONTO',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 36),

              // 4. Controles de Ação
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton.filledTonal(
                    iconSize: 28,
                    icon: const Icon(Icons.refresh_rounded),
                    tooltip: 'Reiniciar Bloco',
                    onPressed: () => ref.read(pomodoroProvider.notifier).resetTimer(pomodoro.totalSeconds),
                  ),
                  const SizedBox(width: 20),
                  FloatingActionButton.large(
                    elevation: 3,
                    onPressed: () {
                      if (isRunning) {
                        ref.read(pomodoroProvider.notifier).pauseTimer();
                      } else {
                        ref.read(pomodoroProvider.notifier).startTimer();
                      }
                    },
                    child: Icon(
                      isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      size: 40,
                    ),
                  ),
                  const SizedBox(width: 20),
                  IconButton.filledTonal(
                    iconSize: 28,
                    icon: const Icon(Icons.coffee_rounded),
                    tooltip: 'Pausa Curta (5m)',
                    onPressed: () => ref.read(pomodoroProvider.notifier).setCustomDuration(5),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}