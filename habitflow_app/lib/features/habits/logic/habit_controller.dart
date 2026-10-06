// lib/features/habits/logic/habit_controller.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../data/models/habit_model.dart';
import '../data/repositories/habit_repository.dart';

final habitControllerProvider =
    AsyncNotifierProvider<HabitController, List<HabitModel>>(() {
  return HabitController();
});

class HabitController extends AsyncNotifier<List<HabitModel>> {
  @override
  Future<List<HabitModel>> build() async {
    final repository = ref.read(habitRepositoryProvider);
    return repository.getAllHabits();
  }

  Future<void> toggleHabitCompletion(String habitId, DateTime date) async {
    final currentHabits = state.valueOrNull ?? [];
    final targetDateKey = "${date.year.toString().padLeft(4, '0')}-"
        "${date.month.toString().padLeft(2, '0')}-"
        "${date.day.toString().padLeft(2, '0')}";

    final updatedHabits = currentHabits.map((habit) {
      if (habit.id == habitId) {
        final List<String> updatedDates = List.from(habit.completedDates);
        if (updatedDates.contains(targetDateKey)) {
          updatedDates.remove(targetDateKey);
        } else {
          updatedDates.add(targetDateKey);
        }
        return habit.copyWith(completedDates: updatedDates);
      }
      return habit;
    }).toList();

    // Atualização otimista da UI
    state = AsyncData(updatedHabits);

    final modifiedHabit = updatedHabits.firstWhere((h) => h.id == habitId);
    final repository = ref.read(habitRepositoryProvider);
    await repository.updateHabit(modifiedHabit);
  }

  Future<void> createHabit({
    required String title,
    required String description,
    required String iconCode,
    required int colorValue,
  }) async {
    final newHabit = HabitModel(
      id: const Uuid().v4(),
      title: title,
      description: description,
      iconCode: iconCode,
      colorValue: colorValue,
      completedDates: const [],
      createdAt: DateTime.now(),
    );

    final previous = state.valueOrNull ?? [];
    state = AsyncData([...previous, newHabit]);

    final repository = ref.read(habitRepositoryProvider);
    await repository.saveHabit(newHabit);
  }

  Future<void> removeHabit(String id) async {
    final previous = state.valueOrNull ?? [];
    state = AsyncData(previous.where((h) => h.id != id).toList());

    final repository = ref.read(habitRepositoryProvider);
    await repository.deleteHabit(id);
  }
  // Adicione esses métodos dentro da classe HabitController:

  Future<String> exportBackup() async {
    final repository = ref.read(habitRepositoryProvider);
    return repository.exportBackupJson();
  }

  Future<bool> restoreBackup(String rawJson) async {
    final repository = ref.read(habitRepositoryProvider);
    final success = await repository.importBackupJson(rawJson);
    if (success) {
      // Recarrega o estado reativo da aplicação imediatamente
      state = AsyncData(await repository.getAllHabits());
    }
    return success;
  }

  Future<void> resetAllData() async {
    final repository = ref.read(habitRepositoryProvider);
    await repository.clearAll();
    state = const AsyncData([]);
  }
}