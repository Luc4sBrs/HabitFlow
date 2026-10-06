// test/features/habits/habit_model_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:habitflow_app/features/habits/data/models/habit_model.dart';

void main() {
  group('HabitModel - Testes de Domínio e Streaks', () {
    final now = DateTime.now();
    String toKey(DateTime d) =>
        "${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";

    test('Deve calcular streak de 3 dias consecutivos corretamente incluindo hoje', () {
      final habit = HabitModel(
        id: '1',
        title: 'Estudar Dart',
        description: '',
        iconCode: 'star',
        colorValue: 0xFF6366F1,
        completedDates: [
          toKey(now),
          toKey(now.subtract(const Duration(days: 1))),
          toKey(now.subtract(const Duration(days: 2))),
        ],
        createdAt: now.subtract(const Duration(days: 10)),
      );

      expect(habit.calculateStreak(), 3);
    });

    test('Deve manter streak se concluído ontem, mesmo que ainda não tenha feito hoje', () {
      final habit = HabitModel(
        id: '2',
        title: 'Treino',
        description: '',
        iconCode: 'star',
        colorValue: 0xFF6366F1,
        completedDates: [
          toKey(now.subtract(const Duration(days: 1))),
          toKey(now.subtract(const Duration(days: 2))),
        ],
        createdAt: now.subtract(const Duration(days: 10)),
      );

      expect(habit.calculateStreak(), 2);
    });

    test('Deve zerar streak se houver intervalo de mais de 1 dia', () {
      final habit = HabitModel(
        id: '3',
        title: 'Corrida',
        description: '',
        iconCode: 'star',
        colorValue: 0xFF6366F1,
        completedDates: [
          toKey(now.subtract(const Duration(days: 2))), // Faltou ontem e hoje
        ],
        createdAt: now.subtract(const Duration(days: 10)),
      );

      expect(habit.calculateStreak(), 0);
    });

    test('Serialização e Desserialização JSON devem preservar os dados intactos', () {
      final habit = HabitModel(
        id: 'test-123',
        title: 'Leitura',
        description: 'Capítulo 4',
        iconCode: 'book',
        colorValue: 0xFF10B981,
        completedDates: ['2025-01-01'],
        createdAt: DateTime(2025, 1, 1),
      );

      final json = habit.toJson();
      final reconstituted = HabitModel.fromJson(json);

      expect(reconstituted.id, habit.id);
      expect(reconstituted.title, habit.title);
      expect(reconstituted.completedDates, habit.completedDates);
      expect(reconstituted.createdAt, habit.createdAt);
    });
  });
}