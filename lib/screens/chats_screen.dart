// lib/screens/chats_screen.dart
import 'package:flutter/material.dart';
import '../models/chat.dart'; 
import 'chat_room_screen.dart'; 

class ChatsScreen extends StatefulWidget {
  // 📥 RECIBIMOS LOS PARAMETROS GLOBALES DESDE MAIN.DART
  final bool isFreelancer;
  final ValueChanged<bool> onRoleChanged;

  const ChatsScreen({
    super.key,
    required this.isFreelancer,
    required this.onRoleChanged,
  });

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  // ❌ Se eliminó la variable local "isFreelancer = false" para evitar desincronizaciones

  // Iniciales fijas para evitar dependencias de URLs externas
  final List<ChatModel> _chats = [
    const ChatModel(
      name: 'Carlos M.',
      lastMessage: 'Acabo de subir el último commit...',
      time: '10:30',
      avatarUrl: 'CM', 
      unreadCount: 2,
    ),
    const ChatModel(
      name: 'Miguel S.',
      lastMessage: 'El proyecto está listo para revisión',
      time: '09:15',
      avatarUrl: 'MS',
      unreadCount: 1,
    ),
    const ChatModel(
      name: 'Pedro V.',
      lastMessage: 'Perfecto, empezamos mañana',
      time: 'Ayer',
      avatarUrl: 'PV',
      unreadCount: 0,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    const accentColor = Color(0xFF10B981);
    const cardColor = Color(0xFF121214);

    return Scaffold(
      backgroundColor: const Color(0xFF080808),
      body: SafeArea(
        child: Column(
          children: [
            // 1. CABECERA UNIFORME CONECTADA AL ESTADO GLOBAL
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: accentColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Text(
                          'DM',
                          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'DevMarket',
                        style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      // 🔄 USA WIDGET.ISFREELANCER PARA COLOREAR CORRECTAMENTE EL ROL ACTUAL
                      Text('Cliente', style: TextStyle(color: widget.isFreelancer ? Colors.grey : accentColor, fontSize: 12)),
                      Switch(
                        value: widget.isFreelancer,
                        activeThumbColor: accentColor,
                        activeTrackColor: accentColor.withValues(alpha: 0.3),
                        onChanged: widget.onRoleChanged, // 🎯 PROPAGA EL CAMBIO AL CONTENEDOR PRINCIPAL
                      ),
                      Text('Freelancer', style: TextStyle(color: widget.isFreelancer ? accentColor : Colors.grey, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),

            // 2. TÍTULOS
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mensajes',
                      style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Tus conversaciones activas',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 3. LISTA DE CHATS
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _chats.length,
                itemBuilder: (context, index) {
                  return _buildChatCard(_chats[index], cardColor, accentColor);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatCard(ChatModel chat, Color cardColor, Color accentColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Stack(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: const Color(0xFF1C1C1E),
              child: Text(
                chat.avatarUrl,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            if (chat.unreadCount > 0)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Color(0xFF10B981),
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
                  child: Text(
                    '${chat.unreadCount}',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              chat.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              chat.time,
              style: TextStyle(
                color: chat.unreadCount > 0 ? Colors.grey[400] : Colors.grey[600],
                fontSize: 13,
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            chat.lastMessage,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: chat.unreadCount > 0 ? Colors.grey[300] : Colors.grey[500],
              fontSize: 14,
            ),
          ),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatRoomScreen(chat: chat),
            ),
          );
        },
      ),
    );
  }
}