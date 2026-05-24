// lib/screens/freelancer/freelancer_chats_screen.dart
import 'package:flutter/material.dart';
// 🚀 IMPORTACIÓN LOCAL IMPECABLE: Al estar en la misma carpeta, no hay errores de rutas
import 'chat_detail_screen.dart';

class FreelancerChatsScreen extends StatefulWidget {
  final bool isFreelancer;
  final ValueChanged<bool> onRoleChanged;

  const FreelancerChatsScreen({
    super.key,
    required this.isFreelancer,
    required this.onRoleChanged,
  });

  @override
  State<FreelancerChatsScreen> createState() => _FreelancerChatsScreenState();
}

class _FreelancerChatsScreenState extends State<FreelancerChatsScreen> {
  static const bgDark = Color(0xFF080808);
  static const cardColor = Color(0xFF121214);
  static const accentColor = Color(0xFF10B981);
  static const textMuted = Color(0xFF71717A);

  final List<Map<String, dynamic>> _chats = [
    {
      'name': 'TechCorp Inc.',
      'message': '¿Cómo va el avance del proyecto?',
      'time': '11:45',
      'unreadCount': 1,
      'avatarUrl': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=200&auto=format&fit=crop',
    },
    {
      'name': 'FoodRush',
      'message': 'Te envío los requisitos actualizados',
      'time': '10:00',
      'unreadCount': 3,
      'avatarUrl': 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?q=80&w=200&auto=format&fit=crop',
    },
    {
      'name': 'Warehouse Pro',
      'message': 'Excelente trabajo, gracias!',
      'time': 'Ayer',
      'unreadCount': 0,
      'avatarUrl': 'https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?q=80&w=200&auto=format&fit=crop',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgDark,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                      Text('Cliente', style: TextStyle(color: widget.isFreelancer ? Colors.grey : accentColor, fontSize: 12)),
                      Switch(
                        value: widget.isFreelancer,
                        activeThumbColor: accentColor,
                        activeTrackColor: accentColor.withAlpha((0.3 * 255).round()),
                        onChanged: widget.onRoleChanged,
                      ),
                      Text('Freelancer', style: TextStyle(color: widget.isFreelancer ? accentColor : Colors.grey, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Mensajes',
                    style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Tus conversaciones activas',
                    style: TextStyle(color: textMuted, fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: _chats.length,
                itemBuilder: (context, index) {
                  final chat = _chats[index];
                  return _buildChatCard(chat);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatCard(Map<String, dynamic> chat) {
    final bool hasUnread = chat['unreadCount'] > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatDetailScreen(
                name: chat['name'],
                avatarUrl: chat['avatarUrl'],
              ),
            ),
          );
        },
        leading: Stack(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: const Color(0xFF1C1C1E),
              backgroundImage: NetworkImage(chat['avatarUrl']),
            ),
            if (hasUnread)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: accentColor,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 20,
                    minHeight: 20,
                  ),
                  child: Text(
                    '${chat['unreadCount']}',
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
              chat['name'],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              chat['time'],
              style: const TextStyle(
                color: textMuted,
                fontSize: 13,
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            chat['message'],
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: hasUnread ? Colors.white70 : textMuted,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}