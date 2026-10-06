// lib/features/habits/data/models/habit_model.dart

import 'package:flutter/foundation.dart';

@immutable
class HabitModel {
  final String id;
  final String title;
  final String description;
  final String iconCode; // Identificador textual do ícone
  final int colorValue; // Valor ARGB hexadecimal para cor
  final List<String> completedDates; // Lista no formato ISO 'YYYY-MM-DD'
  final DateTime createdAt;

  const HabitModel({
    required this.id,
    required this.title,
    required this.description,
    required this.iconCode,
    required this.colorValue,
    required this.completedDates,
    required this.createdAt,
  });

  /// Verifica se o hábito foi concluído em uma data específica ('YYYY-MM-DD')
  bool isCompletedOn(DateTime date) {
    final dateKey = _toDateKey(date);
    return completedDates.contains(dateKey);
  }

  /// Retorna a sequência atual ininterrupta (streak em dias)
  int calculateStreak() {
    if (completedDates.isEmpty) return 0;

    completedDates
        .map((d) => DateTime.parse(d))
        .toList()
      .sort((a, b) => b.compareTo(a));

    final today = DateTime.now();
    final todayKey = _toDateKey(today);
    final yesterdayKey = _toDateKey(today.subtract(const Duration(days: 1)));

    // Se não completou hoje nem ontem, o streak atual é zero
    if (!completedDates.contains(todayKey) && !completedDates.contains(yesterdayKey)) {
      return 0;
    }

    int streak = 0;
    DateTime checkDate = completedDates.contains(todayKey)
        ? today
        : today.subtract(const Duration(days: 1));

    while (completedDates.contains(_toDateKey(checkDate))) {
      streak++;
      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    return streak;
  }

  HabitModel copyWith({
    String? id,
    String? title,
    String? description,
    String? iconCode,
    int? colorValue,
    List<String>? completedDates,
    DateTime? createdAt,
  }) {
    return HabitModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      iconCode: iconCode ?? this.iconCode,
      colorValue: colorValue ?? this.colorValue,
      completedDates: completedDates ?? this.completedDates,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'iconCode': iconCode,
      'colorValue': colorValue,
      'completedDates': completedDates,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory HabitModel.fromJson(Map<String, dynamic> map) {
    return HabitModel(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String? ?? '',
      iconCode: map['iconCode'] as String? ?? 'check',
      colorValue: map['colorValue'] as int? ?? 0xFF6366F1,
      completedDates: List<String>.from(map['completedDates'] ?? const []),
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  static String _toDateKey(DateTime date) {
    return "${date.year.toString().padLeft(4, '0')}-"
        "${date.month.toString().padLeft(2, '0')}-"
        "${date.day.toString().padLeft(2, '0')}";
  }
}