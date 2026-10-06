// lib/features/analytics/presentation/widgets/consistency_heatmap.dart

import 'package:flutter/material.dart';
import '../../../habits/data/models/habit_model.dart';

class ConsistencyHeatmap extends StatelessWidget {
  final List<HabitModel> habits;

  const ConsistencyHeatmap({super.key, required this.habits});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();

    final days = List.generate(35, (index) {
      return now.subtract(Duration(days: 34 - index));
    });

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.35),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.colorScheme.outlineVariant.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Wrap responsivo: se a tela for estreita, a legenda quebra a linha sem dar erro
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              Text(
                'Mapa de Calor (35 Dias)',
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Menos', style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.outline)),
                  const SizedBox(width: 4),
                  _buildLegendBox(theme, 0.1),
                  _buildLegendBox(theme, 0.4),
                  _buildLegendBox(theme, 0.7),
                  _buildLegendBox(theme, 1.0),
                  const SizedBox(width: 4),
                  Text('Mais', style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.outline)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Grid dos 35 dias
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 35,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              crossAxisSpacing: 6,
              mainAxisSpacing: 6,
            ),
            itemBuilder: (context, index) {
              final day = days[index];
              final completedCount = habits.where((h) => h.isCompletedOn(day)).length;
              final maxHabits = habits.isEmpty ? 1 : habits.length;
              final ratio = habits.isEmpty ? 0.0 : (completedCount / maxHabits);

              Color boxColor;
              if (completedCount == 0) {
                boxColor = theme.colorScheme.surfaceContainerHighest.withOpacity(0.6);
              } else if (ratio <= 0.33) {
                boxColor = theme.colorScheme.primary.withOpacity(0.35);
              } else if (ratio <= 0.66) {
                boxColor = theme.colorScheme.primary.withOpacity(0.65);
              } else {
                boxColor = theme.colorScheme.primary;
              }

              return Tooltip(
                message: '${day.day}/${day.month}: $completedCount de $maxHabits concluídos',
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: boxColor,
                    borderRadius: BorderRadius.circular(6),
                    border: day.day == now.day && day.month == now.month
                        ? Border.all(color: theme.colorScheme.onSurface, width: 1.5)
                        : null,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLegendBox(ThemeData theme, double opacity) {
    return Container(
      width: 10,
      height: 10,
      margin: const EdgeInsets.symmetric(horizontal: 1.5),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(opacity),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}