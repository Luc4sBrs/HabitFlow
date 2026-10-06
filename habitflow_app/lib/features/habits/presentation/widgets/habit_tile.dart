// lib/features/habits/presentation/widgets/habit_tile.dart

import 'package:flutter/material.dart';
import '../../data/models/habit_model.dart';

class HabitTile extends StatelessWidget {
  final HabitModel habit;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final VoidCallback? onTap; // Novo callback de toque

  const HabitTile({
    super.key,
    required this.habit,
    required this.onToggle,
    required this.onDelete,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDoneToday = habit.isCompletedOn(DateTime.now());
    final habitColor = Color(habit.colorValue);

    return Dismissible(
      key: Key(habit.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          color: theme.colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(Icons.delete_outline, color: theme.colorScheme.onErrorContainer),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDoneToday ? habitColor.withOpacity(0.6) : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: habitColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(_resolveIcon(habit.iconCode), color: habitColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      habit.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        decoration: isDoneToday ? TextDecoration.lineThrough : null,
                        color: isDoneToday
                            ? theme.colorScheme.onSurface.withOpacity(0.5)
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                    if (habit.description.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        habit.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                iconSize: 32,
                onPressed: onToggle,
                icon: Icon(
                  isDoneToday ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: isDoneToday ? habitColor : theme.colorScheme.outline,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _resolveIcon(String code) {
    switch (code) {
      case 'fitness':
        return Icons.fitness_center_rounded;
      case 'book':
        return Icons.menu_book_rounded;
      case 'code':
        return Icons.terminal_rounded;
      case 'water':
        return Icons.water_drop_rounded;
      case 'bed':
        return Icons.bedtime_rounded;
      case 'mind':
        return Icons.self_improvement_rounded;
      default:
        return Icons.star_rounded;
    }
  }
}