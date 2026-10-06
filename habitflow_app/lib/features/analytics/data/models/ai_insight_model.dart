// lib/features/analytics/data/models/ai_insight_model.dart

import 'package:flutter/foundation.dart';

enum InsightType { warning, congratulation, suggestion, strategic }

@immutable
class AiInsightModel {
  final String title;
  final String message;
  final InsightType type;
  final String scoreTag;

  const AiInsightModel({
    required this.title,
    required this.message,
    required this.type,
    required this.scoreTag,
  });
}