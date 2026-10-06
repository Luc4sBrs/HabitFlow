// lib/core/widgets/habit_flow_logo.dart

import 'package:flutter/material.dart';

class HabitFlowLogo extends StatelessWidget {
  final double size;
  final bool? isDark;

  const HabitFlowLogo({
    super.key,
    this.size = 48,
    this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(size * 0.22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: size * 0.15,
            offset: Offset(0, size * 0.05),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size * 0.22),
        child: Padding(
          padding: EdgeInsets.all(size * 0.12),
          child: Image.asset(
            'assets/icon/habit_flow_logo.jpg',
            fit: BoxFit.contain,
            // Se o arquivo ainda não foi empacotado, exibe um ícone temporário sem travar o app
            errorBuilder: (context, error, stackTrace) {
              return const Center(
                child: Icon(Icons.bolt, color: Color(0xFF6366F1), size: 28),
              );
            },
          ),
        ),
      ),
    );
  }
}