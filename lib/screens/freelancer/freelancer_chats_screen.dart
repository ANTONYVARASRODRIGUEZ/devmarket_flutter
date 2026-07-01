// lib/screens/freelancer/freelancer_chats_screen.dart
import 'package:flutter/material.dart';
import '../../data/services/api_service.dart'; 
import 'chat_detail_screen.dart';
import 'package:devmarket_app/widgets/custom_header.dart'; 

class FreelancerChatsScreen extends StatefulWidget {
  const FreelancerChatsScreen({super.key});

  @override
  State<FreelancerChatsScreen> createState() => _FreelancerChatsScreenState();
}

class _FreelancerChatsScreenState extends State<FreelancerChatsScreen> {
  final ApiService _apiService = ApiService();

  static const bgDark = Color(0xFF080808);
  static const cardColor = Color(0xFF121214);
  static const accentColor = Color(0xFF00E676); 
  static const textMuted = Color(0xFF71717A);

  bool _isLoading = true;
  List<dynamic> _conversations = [];
  String? _currentUserId; 

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final userId = await _apiService.getUserId();
      final chats = await _apiService.getChats();
      
      if (!mounted) return;
      setState(() {
        _currentUserId = userId;
        _conversations = chats;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al conectar con el servidor: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgDark,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CustomHeader(
              title: 'Mensajes',
              subtitle: 'Tus conversaciones activas',
            ),
            
            const SizedBox(height: 10), 

            // --- LISTA DE CHATS ---
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(accentColor)))
                  : _conversations.isEmpty
                      ? _buildEmptyState()
                      : RefreshIndicator(
                          color: accentColor,
                          backgroundColor: cardColor,
                          onRefresh: _fetchData,
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            itemCount: _conversations.length,
                            itemBuilder: (context, index) {
                              final chat = _conversations[index];
                              return _buildChatCard(chat);
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.forum_outlined, size: 64, color: textMuted.withAlpha(100)),
          const SizedBox(height: 16),
          const Text(
            'No hay conversaciones',
            style: TextStyle(color: textMuted, fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildChatCard(dynamic chat) {
    // 🟢 IDENTIFICACIÓN DE PARTICIPANTE ALINEADA CON PRISMA SCHEMA
    final String currentId = _currentUserId?.toString().trim() ?? '';
    final String participantAId = chat['participantAId']?.toString().trim() ?? '';
    
    // Si participantAId no es el mío, significa que el cliente es la relación participantA.
    // En caso contrario, el cliente es la relación participantB.
    final bool isParticipantATheOther = participantAId != currentId;
    final dynamic otherUser = isParticipantATheOther ? chat['participantA'] : chat['participantB'];

    final String contactName = otherUser?['name'] ?? 'Usuario DevMarket';
    final String? avatarUrl = otherUser?['avatar'];
    
    final String lastMessage = chat['messages'] != null && (chat['messages'] as List).isNotEmpty
        ? (chat['messages'][0]['content'].toString().contains('res.cloudinary.com') 
            ? '📎 Archivo adjunto' 
            : chat['messages'][0]['content'])
        : 'Sin mensajes en la conversación';
        
    final int unreadCount = chat['unreadCount'] ?? 0;
    final bool hasUnread = unreadCount > 0;
    
    String timeStr = '--:--';
    if (chat['updatedAt'] != null) {
      final parsedDate = DateTime.tryParse(chat['updatedAt']);
      if (parsedDate != null) {
        final localDate = parsedDate.toLocal();
        timeStr = "${localDate.hour.toString().padLeft(2, '0')}:${localDate.minute.toString().padLeft(2, '0')}";
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        onTap: () {
          final String receiverId = otherUser?['id']?.toString() ?? '';

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatDetailScreen(
                chatId: chat['id'].toString(), 
                name: contactName,
                avatarUrl: avatarUrl ?? '', 
                receiverId: receiverId, 
              ),
            ),
          ).then((_) {
            if (mounted) _fetchData(); 
          });
        },
        leading: Stack(
          clipBehavior: Clip.none,
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: const Color(0xFF1C1C1E),
              backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty
                  ? NetworkImage(avatarUrl) 
                  : NetworkImage("https://ui-avatars.com/api/?name=$contactName&background=0a0a0a&color=00e676") as ImageProvider,
            ),
            if (hasUnread)
              Positioned(
                top: -2,
                right: -2,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: accentColor,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 20,
                    minHeight: 20,
                  ),
                  child: Center(
                    child: Text(
                      '$unreadCount',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
          ],
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                contactName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              timeStr,
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
            lastMessage,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: hasUnread ? Colors.white70 : textMuted,
              fontSize: 14,
              fontWeight: hasUnread ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}