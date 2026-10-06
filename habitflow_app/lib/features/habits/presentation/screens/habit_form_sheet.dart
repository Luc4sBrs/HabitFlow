// lib/features/habits/presentation/screens/habit_form_sheet.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../logic/habit_controller.dart';

class HabitFormSheet extends ConsumerStatefulWidget {
  const HabitFormSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => const HabitFormSheet(),
    );
  }

  @override
  ConsumerState<HabitFormSheet> createState() => _HabitFormSheetState();
}

class _HabitFormSheetState extends ConsumerState<HabitFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  // Paleta de Cores Disponíveis para o Hábito
  static const List<int> _presetColors = [
    0xFF6366F1, // Indigo
    0xFF10B981, // Esmeralda
    0xFFF59E0B, // Âmbar
    0xFFEF4444, // Coral
    0xFF8B5CF6, // Roxo
    0xFFEC4899, // Rosa
    0xFF06B6D4, // Ciano
  ];

  // Ícones Disponíveis com seus Identificadores
  static const List<(String code, IconData icon, String label)> _presetIcons = [
    ('star', Icons.star_rounded, 'Geral'),
    ('fitness', Icons.fitness_center_rounded, 'Treino'),
    ('book', Icons.menu_book_rounded, 'Leitura'),
    ('code', Icons.terminal_rounded, 'Estudo/Código'),
    ('water', Icons.water_drop_rounded, 'Saúde'),
    ('bed', Icons.bedtime_rounded, 'Sono'),
    ('mind', Icons.self_improvement_rounded, 'Foco'),
  ];

  int _selectedColor = _presetColors.first;
  String _selectedIconCode = _presetIcons.first.$1;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      HapticFeedback.mediumImpact();
      ref.read(habitControllerProvider.notifier).createHabit(
            title: _titleController.text.trim(),
            description: _descController.text.trim(),
            iconCode: _selectedIconCode,
            colorValue: _selectedColor,
          );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: mediaQuery.viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Barra de Arraste Superior
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Text(
                'Criar Novo Hábito',
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // Campo de Título
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Nome do Hábito *',
                  hintText: 'Ex: Ler 20 minutos, Beber 2L de água...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  prefixIcon: const Icon(Icons.edit_outlined),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Informe o nome do hábito';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Campo de Descrição
              TextFormField(
                controller: _descController,
                decoration: InputDecoration(
                  labelText: 'Motivo ou Regra (Opcional)',
                  hintText: 'Ex: Sempre logo após o café da manhã',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  prefixIcon: const Icon(Icons.notes_outlined),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 20),

              // Seletor de Cores
              Text(
                'Escolha uma Cor de Destaque',
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 44,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _presetColors.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final colorVal = _presetColors[index];
                    final isSelected = colorVal == _selectedColor;

                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => _selectedColor = colorVal);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Color(colorVal),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? theme.colorScheme.onSurface : Colors.transparent,
                            width: 3,
                          ),
                        ),
                        child: isSelected
                            ? const Icon(Icons.check, color: Colors.white, size: 20)
                            : null,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),

              // Seletor de Ícones
              Text(
                'Identificador Visual',
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 12,
                runSpacing: 10,
                children: _presetIcons.map((item) {
                  final isSelected = _selectedIconCode == item.$1;
                  return ChoiceChip(
                    avatar: Icon(item.$2, size: 18),
                    label: Text(item.$3),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        HapticFeedback.selectionClick();
                        setState(() => _selectedIconCode = item.$1);
                      }
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 28),

              // Botão de Confirmação
              FilledButton.icon(
                onPressed: _submit,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                icon: const Icon(Icons.rocket_launch_outlined),
                label: const Text('Iniciar Hábito', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}