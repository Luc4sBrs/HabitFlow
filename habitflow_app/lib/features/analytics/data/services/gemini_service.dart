// lib/features/analytics/data/services/gemini_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../habits/data/models/habit_model.dart';
import '../models/chat_message_model.dart';

class GeminiService {
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent';

  static Future<String> generateResponse({
    required String apiKey,
    required List<ChatMessageModel> history,
    required List<HabitModel> habits,
  }) async {
    final now = DateTime.now();
    final todayStr = "${now.day}/${now.month}/${now.year}";

    // Contexto que a IA recebe sobre os hábitos do usuário
    final habitsContext = habits.isEmpty
        ? "O usuário ainda não cadastrou nenhum hábito."
        : habits.map((h) {
            final isDone = h.isCompletedOn(now);
            final streak = h.calculateStreak();
            return "- '${h.title}': Status hoje: ${isDone ? 'CONCLUÍDO' : 'PENDENTE'}, Sequência atual: $streak dias.";
          }).join("\n");

    final systemInstruction = """
Você é o HabitFlow AI Coach, um mentor pessoal de hábitos de alto desempenho, disciplina e foco.
Sua comunicação é empática, motivadora, direta e baseada em neurociência (livros como 'Hábitos Atômicos' e 'O Poder do Hábito').

Hoje é dia: $todayStr.
Aqui estão os hábitos reais do usuário no aplicativo neste momento:
$habitsContext

Instruções:
1. Responda em Português de forma conversacional, humana e natural, como o ChatGPT.
2. Reconheça tudo o que o usuário disser e use o contexto dos hábitos dele para personalizar os conselhos.
3. Se o usuário falar sobre desmotivação ou cansaço, seja acolhedor mas dê uma ação prática de 2 minutos.
4. Mantenha as respostas concisas e formatadas para leitura rápida no celular.
""";

    // Converte o histórico de chat no formato esperado pelo Gemini
    final contents = history.map((msg) {
      return {
        "role": msg.isUser ? "user" : "model",
        "parts": [
          {"text": msg.text}
        ]
      };
    }).toList();

    final url = Uri.parse('$_baseUrl?key=$apiKey');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "system_instruction": {
            "parts": [
              {"text": systemInstruction}
            ]
          },
          "contents": contents,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final candidates = data['candidates'] as List?;
        if (candidates != null && candidates.isNotEmpty) {
          final text = candidates[0]['content']['parts'][0]['text'] as String;
          return text.trim();
        }
      } else {
        final errorData = jsonDecode(response.body);
        return "Erro da IA (${response.statusCode}): ${errorData['error']?['message'] ?? 'Verifique sua chave de API.'}";
      }
    } catch (e) {
      return "Erro de conexão: Verifique sua internet ou tente novamente em instantes. ($e)";
    }

    return "Não consegui processar a resposta no momento.";
  }
}