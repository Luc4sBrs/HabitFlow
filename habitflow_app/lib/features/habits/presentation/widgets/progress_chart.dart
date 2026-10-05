// lib/features/habits/presentation/widgets/progress_chart.dart

import 'package:flutter/material.dart';
import '../../data/models/habit_model.dart';

class ProgressChart extends StatelessWidget {
  final List<HabitModel> habits;

  const ProgressChart({super.key, required this.habits});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();

    final last7Days = List.generate(7, (index) {
      return now.subtract(Duration(days: 6 - index));
    });

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Visão Geral dos Últimos 7 Dias',
            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: last7Days.map((day) {
              final completedCount = habits.where((h) => h.isCompletedOn(day)).length;
              final maxHabits = habits.isEmpty ? 1 : habits.length;
              final ratio = completedCount / maxHabits;
              final dayLetters = ['D', 'S', 'T', 'Q', 'Q', 'S', 'S'];
              final label = dayLetters[day.weekday % 7];

              return Column(
                children: [
                  Container(
                    height: 50,
                    width: 14,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      height: 50 * ratio,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    label,
                    style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}