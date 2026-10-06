// lib/features/habits/data/repositories/habit_repository.dart

import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/habit_model.dart';

abstract class IHabitRepository {
  Future<List<HabitModel>> getAllHabits();
  Future<void> saveHabit(HabitModel habit);
  Future<void> updateHabit(HabitModel habit);
  Future<void> deleteHabit(String id);
  Future<String> exportBackupJson(); // <-- NOVO
  Future<bool> importBackupJson(String rawJson); // <-- NOVO
  Future<void> clearAll(); // <-- NOVO
}

final habitRepositoryProvider = Provider<IHabitRepository>((ref) {
  return HabitRepositoryImpl();
});

class HabitRepositoryImpl implements IHabitRepository {
  static const String _storageKey = 'habitflow_ai_habits_store';

  @override
  Future<List<HabitModel>> getAllHabits() async {
    final prefs = await SharedPreferences.getInstance();
    final rawData = prefs.getStringList(_storageKey);

    if (rawData == null || rawData.isEmpty) {
      return _generateInitialSeed();
    }

    return rawData
        .map((entry) => HabitModel.fromJson(jsonDecode(entry) as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> saveHabit(HabitModel habit) async {
    final habits = await getAllHabits();
    habits.add(habit);
    await _persist(habits);
  }

  @override
  Future<void> updateHabit(HabitModel habit) async {
    final habits = await getAllHabits();
    final index = habits.indexWhere((h) => h.id == habit.id);
    if (index != -1) {
      habits[index] = habit;
      await _persist(habits);
    }
  }

  @override
  Future<void> deleteHabit(String id) async {
    final habits = await getAllHabits();
    habits.removeWhere((h) => h.id == id);
    await _persist(habits);
  }

  @override
  Future<String> exportBackupJson() async {
    final habits = await getAllHabits();
    final rawList = habits.map((h) => h.toJson()).toList();
    return const JsonEncoder.withIndent('  ').convert(rawList);
  }

  @override
  Future<bool> importBackupJson(String rawJson) async {
    try {
      final decoded = jsonDecode(rawJson);
      if (decoded is! List) return false;

      final habits = decoded
          .map((item) => HabitModel.fromJson(item as Map<String, dynamic>))
          .toList();

      await _persist(habits);
      return true;
    } catch (_) {
      return false; // Retorna falso se o JSON for inválido
    }
  }

  @override
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }

  Future<void> _persist(List<HabitModel> habits) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = habits.map((h) => jsonEncode(h.toJson())).toList();
    await prefs.setStringList(_storageKey, encoded);
  }

  List<HabitModel> _generateInitialSeed() {
    final now = DateTime.now();
    final todayStr = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    
    return [
      HabitModel(
        id: '1',
        title: 'Meditação Matinal',
        description: '10 minutos de respiração e foco consciente',
        iconCode: 'mind',
        colorValue: 0xFF6366F1,
        completedDates: [todayStr],
        createdAt: now.subtract(const Duration(days: 3)),
      ),
      HabitModel(
        id: '2',
        title: 'Leitura Técnica',
        description: 'Ler 15 páginas de arquitetura de software',
        iconCode: 'book',
        colorValue: 0xFF10B981,
        completedDates: [],
        createdAt: now.subtract(const Duration(days: 2)),
      ),
    ];
  }
}