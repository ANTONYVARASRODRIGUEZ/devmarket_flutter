// lib/models/message.dart

import 'dart:convert';

/// ✉️ MODELO PARA CADA MENSAJE INDIVIDUAL (Tu tabla Message de Postgres)
class MessageModel {
  final String id;
  final String content;
  final bool isRead;
  final String senderId;
  final String conversationId;
  final DateTime createdAt;

  const MessageModel({
    required this.id,
    required this.content,
    required this.isRead,
    required this.senderId,
    required this.conversationId,
    required this.createdAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] ?? '',
      content: json['content'] ?? '',
      isRead: json['isRead'] ?? false,
      senderId: json['senderId'] ?? '',
      conversationId: json['conversationId'] ?? '',
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'isRead': isRead,
      'senderId': senderId,
      'conversationId': conversationId,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

/// 👥 MODELO PARA LA LISTA GENERAL DE CONVERSACIONES (El que te faltaba)
class ChatModel {
  final String id;
  final String name;
  final String avatarUrl;
  final String lastMessage;
  final String time;
  final int unreadCount;

  const ChatModel({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.lastMessage,
    required this.time,
    required this.unreadCount,
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      id: json['id'] ?? json['conversationId'] ?? '',
      name: json['name'] ?? json['username'] ?? 'Usuario',
      avatarUrl: json['avatarUrl'] ?? '',
      lastMessage: json['lastMessage'] ?? json['content'] ?? '',
      time: json['time'] ?? '',
      unreadCount: json['unreadCount'] ?? 0,
    );
  }
}