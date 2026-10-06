// lib/features/analytics/data/models/chat_message_model.dart

import 'package:flutter/foundation.dart';

@immutable
class ChatMessageModel {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;

  const ChatMessageModel({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}