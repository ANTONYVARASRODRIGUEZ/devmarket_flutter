// lib/screens/chats_screen.dart
import 'package:flutter/material.dart';
import '../models/message.dart'; 
import 'chat_room_screen.dart'; 
import 'package:devmarket_app/data/services/api_service.dart'; 
import 'package:devmarket_app/data/services/socket_service.dart';
import '../widgets/custom_header.dart';

class ChatsScreen extends StatefulWidget {
  const ChatsScreen({super.key});

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  final ApiService _apiService = ApiService();
  final SocketService _socketService = SocketService();
  
  List<ChatModel> _chats = [];
  bool _isLoading = true;
  String? myUserId;

  // Mapa para almacenar los IDs reales de los freelancers asociados a cada chat
  final Map<String, String> _chatToParticipantIdMap = {};

  @override
  void initState() {
    super.initState();
    _initScreen();
  }

  Future<void> _initScreen() async {
    try {
      // Leemos el ID real del almacenamiento seguro
      final String? storageId = await _apiService.getUserId();
      if (mounted) {
        setState(() {
          myUserId = storageId;
        });
        // Una vez asegurado tu ID, cargamos los chats y sockets
        await _loadConversations();
        _initSocketListeners();
      }
    } catch (e) {
      debugPrint("🚨 Error inicializando IDs en ChatsScreen: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Carga inicial adaptada a la estructura relacional de tu Prisma Service
  Future<void> _loadConversations() async {
    if (myUserId == null || myUserId!.isEmpty) {
      debugPrint("🚨 No se pueden cargar chats porque myUserId es nulo.");
      return;
    }
    
    try {
      final List<dynamic> data = await _apiService.getChats(); 
      
      if (mounted) {
        setState(() {
          _chats = data.map((json) {
            final String conversationId = json['id']?.toString() ?? '';

            // 🟢 EXTRACCIÓN DE IDs BLINDADA (Busca en raíz o dentro del include del participante)
            final String pAId = (json['participantAId'] ?? json['participantA']?['id'] ?? '').toString().trim();
            final String pBId = (json['participantBId'] ?? json['participantB']?['id'] ?? '').toString().trim();
            final String currentUserId = myUserId!.trim();

            // Comparación limpia e inmune a fallos de mayúsculas/minúsculas
            final bool isParticipantAContact = pAId.toLowerCase() != currentUserId.toLowerCase();
            final dynamic targetParticipant = isParticipantAContact ? json['participantA'] : json['participantB'];
            
            final String freelancerName = targetParticipant != null ? (targetParticipant['name'] ?? 'Usuario') : 'Usuario';
            final String freelancerAvatar = targetParticipant != null ? (targetParticipant['avatar'] ?? '') : '';
            final String freelancerId = targetParticipant != null ? (targetParticipant['id'] ?? '').toString().trim() : '';

            // Guardamos el ID del freelancer mapeado a esta conversación para el onTap
            if (conversationId.isNotEmpty && freelancerId.isNotEmpty) {
              _chatToParticipantIdMap[conversationId] = freelancerId;
            } else {
              debugPrint("⚠️ [ALERTA] No se pudo mapear el Freelancer para la conv: $conversationId");
            }

            // EXTRAER EL ÚLTIMO MENSAJE DESDE EL ARRAY 'messages'
            String lastMsgText = 'Sin mensajes';
            String formattedTime = '';
            
            if (json['messages'] != null && (json['messages'] as List).isNotEmpty) {
              final lastMessageObj = json['messages'][0];
              lastMsgText = lastMessageObj['content'] ?? '';
              
              if (lastMessageObj['createdAt'] != null) {
                try {
                  final parsedDate = DateTime.parse(lastMessageObj['createdAt'].toString()).toLocal();
                  formattedTime = "${parsedDate.hour.toString().padLeft(2, '0')}:${parsedDate.minute.toString().padLeft(2, '0')}";
                } catch (_) {}
              }
            }

            // CONTADOR DE NO LEÍDOS DE TU AGREGACIÓN DE BACKEND
            final int unreads = json['_count']?['messages'] ?? 0;

            return ChatModel(
              id: conversationId,
              name: freelancerName, 
              avatarUrl: freelancerAvatar,
              lastMessage: lastMsgText, 
              time: formattedTime,
              unreadCount: unreads,
            );
          }).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("🚨 Error cargando conversaciones: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Escucha activa de sockets
  void _initSocketListeners() {
    final socket = _socketService.socket;
    if (socket == null) return;

    socket.on('new_message', (data) => _handleIncomingMessageUpdate(data));
    socket.on('message_sent', (data) => _handleIncomingMessageUpdate(data));
  }

  // Actualización inteligente de la lista en tiempo real
  void _handleIncomingMessageUpdate(dynamic data) {
    if (!mounted) return;
    
    final String content = data['content'] ?? '';
    final String conversationId = data['conversationId'] ?? data['chatId'] ?? ''; 
    
    setState(() {
      final int index = _chats.indexWhere((c) => c.id == conversationId); 
      
      if (index != -1) {
        final now = DateTime.now();
        final String formattedTime = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";

        final updatedChat = ChatModel(
          id: _chats[index].id, 
          name: _chats[index].name,
          avatarUrl: _chats[index].avatarUrl,
          lastMessage: content,
          time: formattedTime,
          unreadCount: _chats[index].unreadCount + 1, 
        );

        _chats.removeAt(index);
        _chats.insert(0, updatedChat); 
      } else {
        _loadConversations();
      }
    });
  }

  @override
  void dispose() {
    _socketService.socket?.off('new_message');
    _socketService.socket?.off('message_sent');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const accentColor = Color(0xFF10B981);
    const cardColor = Color(0xFF121214);

    return Scaffold(
      backgroundColor: const Color(0xFF080808),
      body: SafeArea(
        child: Column(
          children: [
            const CustomHeader(
              title: 'Mensajes',
              subtitle: 'Tus conversaciones activas',
            ),
            const SizedBox(height: 20),

            // LISTA DINÁMICA
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(accentColor)))
                  : _chats.isEmpty
                      ? const Center(child: Text("No tienes mensajes aún.", style: TextStyle(color: Colors.grey)))
                      : ListView.builder(
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
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(20)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Stack(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: const Color(0xFF1C1C1E),
              child: Text(
                chat.name.isNotEmpty ? chat.name[0].toUpperCase() : '?', 
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)
              ),
            ),
            if (chat.unreadCount > 0)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle),
                  constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                  child: Text(
                    '${chat.unreadCount}',
                    style: const TextStyle(color: Colors.black, fontSize: 11, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(chat.name, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            Text(chat.time, style: TextStyle(color: chat.unreadCount > 0 ? Colors.grey[400] : Colors.grey[600], fontSize: 13)),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            chat.lastMessage,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: chat.unreadCount > 0 ? Colors.grey[300] : Colors.grey[500], fontSize: 14),
          ),
        ),
        onTap: () {
          // Extraemos de forma segura el ID del freelancer desde nuestro mapa blindado
          final targetFreelancerId = _chatToParticipantIdMap[chat.id];

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatRoomScreen(
                chat: chat,
                participantId: targetFreelancerId,
                myUserId: myUserId!,
              ),
            ),
          ).then((_) {
            _loadConversations();
          });
        },
      ),
    );
  }
}