// lib/features/analytics/logic/ai_chat_controller.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../habits/data/models/habit_model.dart';
import '../../habits/logic/habit_controller.dart';
import '../data/models/chat_message_model.dart';

class AiChatState {
  final List<ChatMessageModel> messages;
  final bool isTyping;

  const AiChatState({
    required this.messages,
    required this.isTyping,
  });

  AiChatState copyWith({
    List<ChatMessageModel>? messages,
    bool? isTyping,
  }) {
    return AiChatState(
      messages: messages ?? this.messages,
      isTyping: isTyping ?? this.isTyping,
    );
  }
}

final aiChatControllerProvider =
    NotifierProvider<AiChatController, AiChatState>(() {
  return AiChatController();
});

class AiChatController extends Notifier<AiChatState> {
  @override
  AiChatState build() {
    return AiChatState(
      isTyping: false,
      messages: [
        ChatMessageModel(
          id: const Uuid().v4(),
          text: 'Fala! Eu sou o Kai, seu mentor de hábitos.\n\nMinha missão é te ajudar a ser 1% melhor a cada dia (filosofia Kaizen). Em qual meta ou dificuldade nós vamos focar hoje?',
          isUser: false,
          timestamp: DateTime.now(),
        ),
      ],
    );
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMsg = ChatMessageModel(
      id: const Uuid().v4(),
      text: text.trim(),
      isUser: true,
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, userMsg],
      isTyping: true,
    );

    // Tempo de raciocínio do Kai
    await Future.delayed(const Duration(milliseconds: 900));

    final habits = ref.read(habitControllerProvider).valueOrNull ?? [];
    final reply = _generateKaiResponse(text.trim(), habits);

    final aiMsg = ChatMessageModel(
      id: const Uuid().v4(),
      text: reply,
      isUser: false,
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, aiMsg],
      isTyping: false,
    );
  }

  String _generateKaiResponse(String input, List<HabitModel> habits) {
    final lower = input.toLowerCase();
    final now = DateTime.now();
    final pending = habits.where((h) => !h.isCompletedOn(now)).toList();
    final completed = habits.where((h) => h.isCompletedOn(now)).toList();

    // Saudação
    if (lower == 'oi' || lower == 'olá' || lower == 'ola' || lower.startsWith('bom dia') || lower.startsWith('boa tarde') || lower.startsWith('boa noite')) {
      return 'E aí! Aqui é o Kai. Hoje você já garantiu ${completed.length} hábito(s) e ainda temos ${pending.length} pela frente. Bora buscar seus 1% de progresso agora?';
    }

    // Quem é você?
    if (lower.contains('quem é você') || lower.contains('quem e voce') || lower.contains('seu nome')) {
      return 'Eu sou o Kai! Meu nome vem de "Kaizen", a arte japonesa do progresso contínuo sem pressa. Estou aqui para analisar seus hábitos, te puxar a orelha com empatia e não deixar seu foco morrer.';
    }

    // Preguiça / Cansaço
    if (lower.contains('preguiça') || lower.contains('cansad') || lower.contains('desanim') || lower.contains('sem vontade') || lower.contains('difícil')) {
      if (pending.isNotEmpty) {
        final habit = pending.first;
        return 'O Kai te entende: motivação é passageira, sistema é o que fica. Não tente fazer o hábito "${habit.title}" perfeito hoje. Aplique a Regra dos 2 Minutos: faça só o começo dele agora. Aceita o desafio de 2 minutos?';
      }
      return 'Cansaço legítimo após a missão cumprida! Seus hábitos de hoje já estão todos feitos. Descanse com orgulho.';
    }

    // Pedido de plano / por onde começar
    if (lower.contains('por onde') || lower.contains('o que fazer') || lower.contains('começar') || lower.contains('plano')) {
      if (pending.isNotEmpty) {
        return 'Plano do Kai para agora:\n\n1. Selecione "${pending.first.title}".\n2. Vá na nossa aba Pomodoro e coloque 15 minutos.\n3. Esqueça o celular e vença esses 15 minutos. Eu garanto que o resto flui!';
      }
      return 'Você já zerou seus hábitos hoje! Aproveite para recarregar as energias ou ler algo inspirador para amanhã.';
    }

    // Análise da rotina
    if (lower.contains('analis') || lower.contains('status') || lower.contains('como estou') || lower.contains('desempenho')) {
      final maxStreak = habits.map((h) => h.calculateStreak()).fold(0, (a, b) => a > b ? a : b);
      return 'Relatório do Kai sobre você:\n• Total de hábitos: ${habits.length}\n• Seu recorde atual: $maxStreak dias em chamas 🔥\n• Hoje: ${completed.length}/${habits.length} concluídos.\n\nConstância bate talento qualquer dia da semana. Mantenha o ritmo!';
    }

    // Sugestão de hábitos
    if (lower.contains('sugest') || lower.contains('ideia') || lower.contains('novo hábito')) {
      return 'Ideias do Kai baseadas em neurociência:\n\n1. 💧 Hidratação matinal (500ml ao acordar)\n2. 🚶 15 min de caminhada sem telas\n3. 📖 10 páginas de leitura antes de dormir\n\nQual desses você acha que complementaria melhor sua rotina?';
    }

    // Citação de hábito específico pelo nome
    for (final habit in habits) {
      if (lower.contains(habit.title.toLowerCase())) {
        final isDone = habit.isCompletedOn(now);
        final streak = habit.calculateStreak();
        return 'Falando de "${habit.title}": você já acumulou $streak dia(s) de sequência. ${isDone ? 'Ele já está no bolso hoje! Parabéns pela disciplina.' : 'Ainda está pendente. Vamos matar essa pendência agora com um Pomodoro rápido?'}';
      }
    }

    return 'Entendi perfeitamente o seu ponto sobre "$input". Como seu mentor Kai, te pergunto: qual micro-passo prático você pode dar nos próximos 5 minutos para transformar isso em ação?';
  }
}