// lib/features/analytics/logic/analytics_controller.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../habits/data/models/habit_model.dart';
import '../../habits/logic/habit_controller.dart';
import '../data/models/ai_insight_model.dart';

class AnalyticsState {
  final double consistencyScore;
  final int totalCompletionsThisWeek;
  final List<AiInsightModel> insights;
  final DateTime lastAnalyzedAt;

  const AnalyticsState({
    required this.consistencyScore,
    required this.totalCompletionsThisWeek,
    required this.insights,
    required this.lastAnalyzedAt,
  });
}

final analyticsControllerProvider =
    NotifierProvider<AnalyticsController, AnalyticsState>(() {
  return AnalyticsController();
});

class AnalyticsController extends Notifier<AnalyticsState> {
  int _analysisCycle = 0;

  @override
  AnalyticsState build() {
    final habitsAsync = ref.watch(habitControllerProvider);
    final habits = habitsAsync.valueOrNull ?? [];
    return _computeAnalytics(habits);
  }

  /// Disparado pelo botão "Gerar Análise Profunda com IA"
  Future<void> generateDeepAiAnalysis() async {
    _analysisCycle++;
    final habits = ref.read(habitControllerProvider).valueOrNull ?? [];
    // Recalcula aplicando uma nova perspectiva comportamental
    state = _computeAnalytics(habits, forceCycle: _analysisCycle);
  }

  AnalyticsState _computeAnalytics(List<HabitModel> habits, {int forceCycle = 0}) {
    final now = DateTime.now();

    if (habits.isEmpty) {
      return AnalyticsState(
        consistencyScore: 0.0,
        totalCompletionsThisWeek: 0,
        lastAnalyzedAt: now,
        insights: const [
          AiInsightModel(
            title: 'Ecossistema Vazio',
            message: 'Cadastre seus primeiros hábitos para que a IA possa mapear sua curva de consistência.',
            type: InsightType.suggestion,
            scoreTag: 'Setup',
          ),
        ],
      );
    }

    // 1. Cálculo real dos últimos 7 dias
    int weekCompletions = 0;
    for (int i = 0; i < 7; i++) {
      final day = now.subtract(Duration(days: i));
      weekCompletions += habits.where((h) => h.isCompletedOn(day)).length;
    }

    final totalPossible = habits.length * 7;
    final consistencyScore = totalPossible == 0 ? 0.0 : (weekCompletions / totalPossible) * 100;

    // 2. Identificação dos hábitos mais forte e mais vulnerável
    final sortedByStreak = List<HabitModel>.from(habits)
      ..sort((a, b) => b.calculateStreak().compareTo(a.calculateStreak()));

    final bestHabit = sortedByStreak.first;
    final pendingToday = habits.where((h) => !h.isCompletedOn(now)).toList();
    final completedToday = habits.where((h) => h.isCompletedOn(now)).toList();

    // 3. Montagem dos Insights Nominais e Dinâmicos
    final List<AiInsightModel> generatedInsights = [];

    // Insight 1: O Hábito Campeão
    if (bestHabit.calculateStreak() > 0) {
      generatedInsights.add(AiInsightModel(
        title: 'Seu Hábito Âncora: "${bestHabit.title}"',
        message: 'Você mantém ${bestHabit.calculateStreak()} dias seguidos em "${bestHabit.title}". Utilize esse momento de alta dopamina como gatilho para os seus outros hábitos.',
        type: InsightType.congratulation,
        scoreTag: '🔥 Streak Ativo',
      ));
    }

    // Insight 2: Diagnóstico de Urgência do Dia
    if (pendingToday.isNotEmpty) {
      final target = pendingToday.first;
      generatedInsights.add(AiInsightModel(
        title: 'Foco Imediato: "${target.title}"',
        message: 'Você ainda não concluiu "${target.title}" hoje. Se estiver procrastinando, execute uma microversão de apenas 2 minutos agora.',
        type: InsightType.warning,
        scoreTag: '⚠️ Pendência Crítica',
      ));
    } else {
      generatedInsights.add(const AiInsightModel(
        title: 'Meta Diária Concluída com Excelência',
        message: 'Todos os seus hábitos de hoje foram executados. O descanso consciente faz parte da consolidação de hábitos a longo prazo.',
        type: InsightType.congratulation,
        scoreTag: '🏆 100% Hoje',
      ));
    }

    // Insight 3: Estratégia Comportamental Rotativa (Muda dinamicamente)
    final strategies = [
      AiInsightModel(
        title: 'Técnica: Habit Stacking (Empilhamento)',
        message: completedToday.isNotEmpty
            ? 'Tente executar "${pendingToday.isNotEmpty ? pendingToday.first.title : habits.first.title}" imediatamente após concluir "${completedToday.first.title}".'
            : 'Conecte seu hábito mais difícil a uma ação fixa que você já faz todo dia, como tomar seu café da manhã.',
        type: InsightType.strategic,
        scoreTag: '🧠 Neurociência',
      ),
      AiInsightModel(
        title: 'Análise de Ritmo Circadiano',
        message: 'Sua pontuação semanal é de ${consistencyScore.toStringAsFixed(0)}%. Hábitos de alta fricção cognitiva devem ser feitos na primeira metade do dia para evitar fadiga de decisão.',
        type: InsightType.suggestion,
        scoreTag: '⚡ Otimização',
      ),
      const AiInsightModel(
        title: 'Protocolo de Resiliência (Zero Zero)',
        message: 'Mesmo nos dias mais exaustivos, reduza a meta em vez de zerar. 1 minuto de leitura ou 5 flexões mantém sua identidade comportamental intacta.',
        type: InsightType.strategic,
        scoreTag: '🛡️ Blindagem',
      ),
    ];

    // Alterna a estratégia baseado no ciclo do clique
    generatedInsights.add(strategies[forceCycle % strategies.length]);

    return AnalyticsState(
      consistencyScore: consistencyScore,
      totalCompletionsThisWeek: weekCompletions,
      lastAnalyzedAt: now,
      insights: generatedInsights,
    );
  }
}