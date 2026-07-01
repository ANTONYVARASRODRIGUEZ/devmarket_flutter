// lib/screens/chat_room_screen.dart
import 'package:flutter/material.dart';
import '../models/message.dart';
import 'package:devmarket_app/data/services/socket_service.dart';
import 'package:devmarket_app/data/services/api_service.dart'; 

class ChatRoomScreen extends StatefulWidget {
  final ChatModel chat;
  final String? participantId; 
  final String myUserId;       

  const ChatRoomScreen({
    super.key, 
    required this.chat, 
    this.participantId,
    required this.myUserId, 
  });

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final TextEditingController _messageController = TextEditingController();
  final SocketService _socketService = SocketService();
  final ApiService _apiService = ApiService(); 
  
  final List<Map<String, dynamic>> _messages = [];
  bool _isOtherUserTyping = false;
  bool _isLoadingHistory = true; 

  @override
  void initState() {
    super.initState();
    _initSocketListeners();
    _loadMessageHistory(); 
  }

  Future<void> _loadMessageHistory() async {
    if (widget.chat.id.isEmpty) {
      setState(() => _isLoadingHistory = false);
      return;
    }

    try {
      final historicalMessages = await _apiService.getMensajesConversacion(widget.chat.id);
      
      if (mounted) {
        setState(() {
          _messages.clear(); 
          final reversedList = historicalMessages.reversed.toList();

          for (var msg in reversedList) {
            String formattedTime = '';
            if (msg['createdAt'] != null) {
              try {
                final parsedDate = DateTime.parse(msg['createdAt'].toString()).toLocal();
                formattedTime = "${parsedDate.hour.toString().padLeft(2, '0')}:${parsedDate.minute.toString().padLeft(2, '0')}";
              } catch (_) {}
            }

            _messages.add({
              'text': msg['content'] ?? '',
              'time': formattedTime.isNotEmpty ? formattedTime : _formatCurrentTime(),
              // Comparamos directamente contra el widget.myUserId inyectado
              'isMe': (msg['senderId'] ?? msg['sender_id'] ?? msg['sender']?['id'] ?? '')
                  .toString().trim().toLowerCase() == widget.myUserId.trim().toLowerCase(),
            });
          }
          _isLoadingHistory = false;
        });
      }
    } catch (e) {
      debugPrint("🚨 Error cargando historial en la pantalla: $e");
      if (mounted) {
        setState(() => _isLoadingHistory = false);
      }
    }
  }

  void _initSocketListeners() {
    final socket = _socketService.socket;
    if (socket == null) return;

    socket.off('new_message');
    socket.off('message_sent');
    socket.off('user_typing');
    socket.off('user_stopped_typing');
    socket.off('error'); // 👈 Limpiamos también el listener de error previo

    // Escuchar mensajes entrantes de la otra persona
    socket.on('new_message', (data) {
      debugPrint("📥 [SOCKET] Nuevo mensaje recibido: $data");
      
      // 🟢 CONTROL DE SEGURIDAD: Validamos que pertenezca a este chat abierto
      final String incomingConvId = (data['conversationId'] ?? data['chatId'] ?? '').toString();
      if (incomingConvId != widget.chat.id) {
        debugPrint("ℹ️ Mensaje ignorado en UI porque pertenece a otra conversación.");
        return;
      }

      if (mounted) {
        setState(() {
          _messages.insert(0, {
            'text': data['content'] ?? '', 
            'time': _formatCurrentTime(),
            'isMe': false, 
          });
        });
      }
    });

    socket.on('message_sent', (data) {
      debugPrint("⚡ [SOCKET] Confirmación de guardado en base de datos: $data");
    });

    socket.on('user_typing', (data) {
      if (mounted) setState(() => _isOtherUserTyping = true);
    });

    socket.on('user_stopped_typing', (_) {
      if (mounted) setState(() => _isOtherUserTyping = false);
    });

    // 🔴 DETECTOR DE ERRORES DEL BACKEND (Prisma/PostgreSQL)
    socket.on('error', (data) {
      debugPrint("🚨 [SOCKET ERROR DEL BACKEND]: $data");
      
      if (mounted) {
        // Te mostrará una alerta visual abajo en la pantalla si el backend falla
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error del servidor: ${data['message'] ?? data.toString()}'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    });
  }

  String _formatCurrentTime() {
    final now = DateTime.now();
    return "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final socket = _socketService.socket;
    final String finalReceiverId = widget.participantId ?? '';

    if (finalReceiverId.isEmpty) {
      debugPrint("🚨 [ERROR] No se puede enviar el mensaje porque participantId está vacío.");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error interno: Falta el ID del destinatario.')),
      );
      return;
    }

    if (socket != null && socket.connected) {
      final Map<String, dynamic> backendPayload = {
        'receiverId': finalReceiverId, 
        'content': text
      };

      debugPrint("🚀 [SOCKET EMIT] Enviando al Backend: $backendPayload");
      socket.emit('send_message', backendPayload);
      socket.emit('stop_typing', {'receiverId': finalReceiverId});
      
      if (mounted) {
        setState(() {
          _messages.insert(0, {
            'text': text,
            'time': _formatCurrentTime(),
            'isMe': true,
          });
        });
      }
    } else {
      debugPrint("🚨 [SOCKET] Desconectado. No se puede enviar.");
    }

    _messageController.clear();
  }

  void _onTextChanged(String text) {
    final socket = _socketService.socket;
    final String finalReceiverId = widget.participantId ?? '';
    if (socket == null || !socket.connected || finalReceiverId.isEmpty) return;

    if (text.isNotEmpty) {
      socket.emit('typing', {'receiverId': finalReceiverId}); 
    } else {
      socket.emit('stop_typing', {'receiverId': finalReceiverId});
    }
  }

  @override
  void dispose() {
    _socketService.socket?.off('new_message');
    _socketService.socket?.off('message_sent');
    _socketService.socket?.off('user_typing');
    _socketService.socket?.off('user_stopped_typing');
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const accentColor = Color(0xFF10B981);
    const bgDark = Color(0xFF080808);
    const receiverColor = Color(0xFF121214);

    return Scaffold(
      backgroundColor: bgDark,
      appBar: AppBar(
        backgroundColor: bgDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xFF1C1C1E),
              child: Text(
                widget.chat.name.isNotEmpty ? widget.chat.name[0].toUpperCase() : '?', 
                style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.chat.name, 
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Text('En línea', style: TextStyle(color: accentColor, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoadingHistory
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                    ),
                  )
                : _messages.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.chat_bubble_outline, size: 48, color: Color(0xFF27272A)),
                            const SizedBox(height: 12),
                            Text(
                              'Inicio de la conversación con ${widget.chat.name}',
                              style: const TextStyle(color: Color(0xFF71717A), fontSize: 13),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        reverse: true, 
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final msg = _messages[index];
                          return _buildMessageBubble(msg['text'], msg['time'], msg['isMe'], accentColor, receiverColor);
                        },
                      ),
          ),
          if (_isOtherUserTyping)
            const Padding(
              padding: EdgeInsets.only(left: 20, bottom: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Escribiendo...', style: TextStyle(color: accentColor, fontSize: 12, fontStyle: FontStyle.italic)),
              ),
            ),
          Padding(
            padding: EdgeInsets.only(left: 16, right: 16, top: 8, bottom: MediaQuery.of(context).viewInsets.bottom + 20),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(color: const Color(0xFF1C1C1E), borderRadius: BorderRadius.circular(30)),
                    child: TextField(
                      controller: _messageController,
                      onChanged: _onTextChanged,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: 'Escribe un mensaje...',
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 15),
                        border: InputBorder.none,
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: _sendMessage,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(color: accentColor, shape: BoxShape.circle),
                    child: const Icon(Icons.send_rounded, color: Colors.black, size: 24),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(String text, String time, bool isMe, Color accentColor, Color receiverColor) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isMe ? accentColor : receiverColor,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(20),
                topRight: const Radius.circular(20),
                bottomLeft: Radius.circular(isMe ? 20 : 0),
                bottomRight: Radius.circular(isMe ? 0 : 20),
              ),
            ),
            child: Text(text, style: TextStyle(color: isMe ? Colors.black : Colors.white, fontSize: 15, height: 1.3)),
          ),
          const SizedBox(height: 4),
          Text(time, style: const TextStyle(color: Colors.grey, fontSize: 11)),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}