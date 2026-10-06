// lib/features/analytics/presentation/screens/analytics_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../habits/logic/habit_controller.dart';
import '../../data/models/ai_insight_model.dart';
import '../../logic/analytics_controller.dart';
import '../widgets/consistency_heatmap.dart';
import 'ai_chat_screen.dart';

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  bool _isAnalyzing = false;

  Future<void> _runAiDiagnostic() async {
    HapticFeedback.mediumImpact();
    setState(() => _isAnalyzing = true);

    await Future.delayed(const Duration(milliseconds: 700));
    await ref.read(analyticsControllerProvider.notifier).generateDeepAiAnalysis();

    if (mounted) {
      setState(() => _isAnalyzing = false);
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.auto_awesome, color: Colors.white, size: 20),
              SizedBox(width: 10),
              Text('Diagnóstico de Hábitos atualizado pelo Kai!'),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final analytics = ref.watch(analyticsControllerProvider);
    final habits = ref.watch(habitControllerProvider).valueOrNull ?? [];
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kai • Routine Coach', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: _isAnalyzing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh_rounded),
            tooltip: 'Recalcular Análise',
            onPressed: _isAnalyzing ? null : _runAiDiagnostic,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        children: [
          // Banner para Abrir o Chat com o Kai
          Container(
            margin: const EdgeInsets.only(bottom: 20),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.tertiary,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.chat_bubble_outline_rounded, color: Colors.white, size: 32),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Converse com o Kai',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Seu mentor Kaizen de foco e disciplina diária.',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: theme.colorScheme.primary,
                  ),
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AiChatScreen()),
                    );
                  },
                  child: const Text('Conversar', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),

          // Card de Score Geral
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.surfaceContainerHighest.withOpacity(0.6),
                  theme.colorScheme.surfaceContainerHighest.withOpacity(0.2),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(color: theme.colorScheme.outlineVariant.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ÍNDICE DE CONSISTÊNCIA',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${analytics.consistencyScore.toStringAsFixed(1)}%',
                        style: theme.textTheme.displayMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${analytics.totalCompletionsThisWeek} conclusões nos últimos 7 dias',
                        style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 70,
                  height: 70,
                  child: CircularProgressIndicator(
                    value: analytics.consistencyScore / 100,
                    strokeWidth: 8,
                    strokeCap: StrokeCap.round,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Heatmap de Consistência (Estilo GitHub)
          ConsistencyHeatmap(habits: habits),
          const SizedBox(height: 24),

          // Botão Interativo de Ação com IA
          FilledButton.icon(
            onPressed: _isAnalyzing ? null : _runAiDiagnostic,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            icon: _isAnalyzing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : const Icon(Icons.auto_awesome),
            label: Text(
              _isAnalyzing ? 'Kai analisando padrões...' : 'Gerar Análise Profunda com Kai',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 24),

          // Seção de Insights da IA
          Row(
            children: [
              Icon(Icons.psychology_rounded, color: theme.colorScheme.primary, size: 24),
              const SizedBox(width: 8),
              Text(
                'Diagnósticos do Kai',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),

          ...analytics.insights.map((insight) => _buildInsightCard(context, insight)),

          const SizedBox(height: 24),

          // Métricas por Hábito
          Text(
            'Performance por Hábito',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          if (habits.isEmpty)
            const Text('Cadastre hábitos para ver a pontuação individual.')
          else
            ...habits.map((h) {
              final streak = h.calculateStreak();
              return Card.filled(
                margin: const EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Color(h.colorValue).withOpacity(0.2),
                    child: Icon(Icons.bolt, color: Color(h.colorValue)),
                  ),
                  title: Text(h.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text('${h.completedDates.length} dias totais concluídos'),
                  trailing: Chip(
                    label: Text('$streak dias 🔥'),
                    backgroundColor: theme.colorScheme.surface,
                    side: BorderSide.none,
                  ),
                ),
              );
            }),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildInsightCard(BuildContext context, AiInsightModel insight) {
    final theme = Theme.of(context);
    final isWarning = insight.type == InsightType.warning;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isWarning
            ? theme.colorScheme.errorContainer.withOpacity(0.35)
            : theme.colorScheme.primaryContainer.withOpacity(0.25),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isWarning
              ? theme.colorScheme.error.withOpacity(0.3)
              : theme.colorScheme.primary.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  insight.title,
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  insight.scoreTag,
                  style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            insight.message,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}