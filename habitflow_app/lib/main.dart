// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/theme_controller.dart';
import 'features/splash/presentation/screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: HabitFlowApp(),
    ),
  );
}

class HabitFlowApp extends ConsumerWidget {
  const HabitFlowApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeControllerProvider);

    return MaterialApp(
      title: 'HabitFlow AI',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      // Tema Claro (Clean, moderno e arejado)
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF8FAFC), // Fundo suave Slate-50
        colorSchemeSeed: const Color(0xFF6366F1),
      ),
      // Tema Escuro Refinado (Midnight Slate em vez de preto puro)
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F172A), // Slate-900 elegante
        colorSchemeSeed: const Color(0xFF818CF8),
      ),
      // lib/main.dart (Linha ~37)
home: const SplashScreen(),
    );
  }
}