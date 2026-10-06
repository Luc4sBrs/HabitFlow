// lib/features/pomodoro/logic/pomodoro_controller.dart

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../habits/logic/habit_controller.dart';

enum PomodoroStatus { idle, running, paused, completed }

@immutable
class PomodoroState {
  final int totalSeconds;
  final int remainingSeconds;
  final PomodoroStatus status;
  final String? activeHabitId;

  const PomodoroState({
    required this.totalSeconds,
    required this.remainingSeconds,
    required this.status,
    this.activeHabitId,
  });

  PomodoroState copyWith({
    int? totalSeconds,
    int? remainingSeconds,
    PomodoroStatus? status,
    String? activeHabitId,
  }) {
    return PomodoroState(
      totalSeconds: totalSeconds ?? this.totalSeconds,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      status: status ?? this.status,
      activeHabitId: activeHabitId ?? this.activeHabitId,
    );
  }

  double get progress => totalSeconds == 0 ? 0.0 : 1.0 - (remainingSeconds / totalSeconds);
  
  String get formattedTime {
    final minutes = (remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (remainingSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}

final pomodoroProvider = NotifierProvider<PomodoroController, PomodoroState>(() {
  return PomodoroController();
});

class PomodoroController extends Notifier<PomodoroState> {
  Timer? _ticker;
  static const int defaultDuration = 25 * 60; // 25 minutos

  @override
  PomodoroState build() {
    ref.onDispose(() => _ticker?.cancel());
    return const PomodoroState(
      totalSeconds: defaultDuration,
      remainingSeconds: defaultDuration,
      status: PomodoroStatus.idle,
    );
  }

  void startTimer({String? habitId}) {
    if (state.status == PomodoroStatus.running) return;

    HapticFeedback.lightImpact();

    state = state.copyWith(
      status: PomodoroStatus.running,
      activeHabitId: habitId ?? state.activeHabitId,
    );

    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.remainingSeconds > 1) {
        state = state.copyWith(remainingSeconds: state.remainingSeconds - 1);
      } else {
        _ticker?.cancel();
        _onPomodoroFinished();
      }
    });
  }

  void _onPomodoroFinished() {
    HapticFeedback.heavyImpact();

    state = state.copyWith(
      remainingSeconds: 0,
      status: PomodoroStatus.completed,
    );

    // Conclui o hábito vinculado automaticamente
    if (state.activeHabitId != null) {
      ref.read(habitControllerProvider.notifier).toggleHabitCompletion(
            state.activeHabitId!,
            DateTime.now(),
          );
    }
  }

  void pauseTimer() {
    HapticFeedback.selectionClick();
    _ticker?.cancel();
    state = state.copyWith(status: PomodoroStatus.paused);
  }

  void resetTimer([int newTotalSeconds = defaultDuration]) {
    HapticFeedback.selectionClick();
    _ticker?.cancel();
    state = PomodoroState(
      totalSeconds: newTotalSeconds,
      remainingSeconds: newTotalSeconds,
      status: PomodoroStatus.idle,
      activeHabitId: state.activeHabitId,
    );
  }

  /// Permite alternar o tempo do bloco (ex: 15, 25, 45 ou 60 minutos)
  void setCustomDuration(int minutes) {
    HapticFeedback.selectionClick();
    _ticker?.cancel();
    final total = minutes * 60;
    state = PomodoroState(
      totalSeconds: total,
      remainingSeconds: total,
      status: PomodoroStatus.idle,
      activeHabitId: state.activeHabitId,
    );
  }
}