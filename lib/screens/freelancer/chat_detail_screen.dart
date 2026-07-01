// lib/screens/freelancer/chat_detail_screen.dart
import 'package:flutter/material.dart';
import '../../data/services/api_service.dart'; 
import '../../data/services/socket_service.dart';


class ChatDetailScreen extends StatefulWidget {
  final String chatId; 
  final String name;
  final String avatarUrl;
  final String receiverId; 

  const ChatDetailScreen({
    super.key,
    required this.chatId, 
    required this.name,
    required this.avatarUrl,
    required this.receiverId,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _messageController = TextEditingController();
  
  static const bgDark = Color(0xFF080808);
  static const cardColor = Color(0xFF121214);
  static const accentColor = Color(0xFF10B981);
  static const textMuted = Color(0xFF71717A);
  static const borderDark = Color(0xFF1C1C1E);

  bool _isLoading = true;
  List<dynamic> _realMessages = [];
  String? _myUserId;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  // 📡 NUEVO: Flujo de inicialización reactivo y ordenado
  Future<void> _initializeChat() async {
    // 1. Aseguramos que el socket esté conectado con el Backend
    await SocketService().connect();
    
    // 2. Levantamos los listeners de Socket IO ahora que sabemos que existe
    _setupSocketListeners();
    
    // 3. Traemos el historial HTTP persistido en Postgres
    await _loadMessages();
  }

  @override
  void dispose() {
    final socket = SocketService().socket;
    if (socket != null) {
      socket.off('new_message'); 
      socket.off('message_sent'); // 🟢 Se apaga también el de confirmación propia
    }
    _messageController.dispose();
    super.dispose();
  }

  void _setupSocketListeners() {
    final socket = SocketService().socket;
    if (socket == null) {
      debugPrint("🚨 [CHAT DETAIL] No se pudieron montar listeners: El socket sigue siendo null.");
      return;
    }

    // 🟢 NUEVA MEJORA: Remover listeners previos idénticos por seguridad antes de volverlos a prender
    socket.off('new_message');
    socket.off('message_sent');

    // Escuchar mensajes entrantes de la otra parte
    socket.on('new_message', (data) {
      if (!mounted) return;
      
      final String incomingChatId = (data['conversationId'] ?? data['chatId'] ?? '').toString();
      if (incomingChatId != widget.chatId) return; // Filtrar que pertenezcan a este chat

      // Si el mensaje fue enviado por mí, el listener local optimista ya lo manejó
      if (data['senderId']?.toString() == _myUserId?.toString()) return;

      final bool alreadyExists = _realMessages.any((msg) => msg['id'] == data['id']);
      if (!alreadyExists) {
        setState(() {
          _realMessages.insert(0, data); // 🟢 Cambiado .add por .insert(0, data) para modo reverse
        });
      }
    });

    // Escuchar la respuesta del servidor confirmando que se guardó en Postgres
    socket.on('message_sent', (data) {
      if (!mounted) return;
      
      final String incomingChatId = (data['conversationId'] ?? data['chatId'] ?? '').toString();
      if (incomingChatId != widget.chatId) return;

      // Actualizar o insertar el mensaje real con su ID definitivo de Postgres si no existe
      final bool alreadyExists = _realMessages.any((msg) => msg['id'] == data['id']);
      if (!alreadyExists) {
        setState(() {
          _realMessages.insert(0, data); // 🟢 Cambiado .add por .insert(0, data) para modo reverse
        });
      }
    });
  }

  Future<void> _loadMessages() async {
    try {
      final currentId = await _apiService.getUserId();
      final messagesFromApi = await _apiService.getMensajesConversacion(widget.chatId);
      
      if (!mounted) return;

      setState(() {
        _myUserId = currentId;
        // 🟢 Se invierte la lista proveniente de Postgres para que coincida perfectamente con el reverse: true del ListView
        _realMessages = messagesFromApi.reversed.toList(); 
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  void _sendMessage() {
    final String text = _messageController.text.trim();
    if (text.isEmpty) return;
    
    _messageController.clear();
    final socket = SocketService().socket;
    
    // 🟢 AJUSTE EXACTO PARA TU BACKEND: Solo enviamos receiverId y content
    final messagePayload = {
      'receiverId': widget.receiverId,
      'content': text,
    };

    // Imprime esto en tu consola para verificar si el receiverId es un UUID válido de Postgres
    print("📡 [SOCKET PAYLOAD] Enviando a backend: $messagePayload");

    // Objeto temporal local inmediato para pintar rápido en pantalla
    final localRenderPayload = {
      'id': 'temp-${DateTime.now().millisecondsSinceEpoch}',
      'conversationId': widget.chatId,
      'content': text,
      'senderId': _myUserId,
      'createdAt': DateTime.now().toIso8601String(),
    };

    if (mounted) {
      setState(() {
        _realMessages.insert(0, localRenderPayload); // 🟢 Cambiado .add por .insert(0, ...) para modo reverse
      });
    }

    if (socket != null && socket.connected) {
      socket.emit('send_message', messagePayload);
    } else {
      print("🚨 [SOCKET ERROR] No se pudo emitir porque el socket está desconectado.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgDark,
      appBar: AppBar(
        backgroundColor: bgDark,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: borderDark,
              backgroundImage: widget.avatarUrl.isNotEmpty
                  ? NetworkImage(widget.avatarUrl)
                  : NetworkImage("https://ui-avatars.com/api/?name=${widget.name}&background=0a0a0a&color=00e676") as ImageProvider,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.name,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    'Conversación',
                    style: TextStyle(color: textMuted, fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: borderDark, height: 1),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(accentColor)))
                : _realMessages.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        reverse: true, // 🟢 ACTIVADO: El scroll ahora empieza abajo y se ordena cronológicamente hacia arriba
                        itemCount: _realMessages.length,
                        itemBuilder: (context, index) {
                          final msg = _realMessages[index];
                          return _buildMessageBubble(msg);
                        },
                      ),
          ),
          
          Container(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 20),
            decoration: const BoxDecoration(
              color: bgDark,
              border: Border(top: BorderSide(color: borderDark, width: 1)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // Acción de negocio para el freelancer
                    },
                    icon: const Icon(Icons.check_circle_outline_rounded, color: accentColor, size: 20),
                    label: const Text(
                      'Aprobar Proyecto',
                      style: TextStyle(color: accentColor, fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF163E30), width: 1.5),
                      backgroundColor: const Color(0xFF0A1914),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: borderDark),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: TextField(
                          controller: _messageController,
                          style: const TextStyle(color: Colors.white, fontSize: 15),
                          decoration: const InputDecoration(
                            hintText: 'Escribe un mensaje...',
                            hintStyle: TextStyle(color: textMuted, fontSize: 15),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                          onSubmitted: (_) => _sendMessage(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _sendMessage,
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: const BoxDecoration(
                          color: accentColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.send_rounded, color: Colors.black, size: 20),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Text(
        'Escribe un mensaje para iniciar el chat.',
        style: TextStyle(color: textMuted, fontSize: 14),
      ),
    );
  }

  Widget _buildMessageBubble(dynamic msg) {
    final bool isMe = msg['senderId']?.toString() == _myUserId?.toString();
    final String content = msg['content'] ?? msg['text'] ?? '';
    
    String timeStr = '';
    if (msg['createdAt'] != null) {
      final parsedDate = DateTime.tryParse(msg['createdAt']);
      if (parsedDate != null) {
        final localDate = parsedDate.toLocal();
        timeStr = "${localDate.hour.toString().padLeft(2, '0')}:${localDate.minute.toString().padLeft(2, '0')}";
      }
    }

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isMe ? accentColor : cardColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isMe ? 20 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 20),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              content,
              style: TextStyle(
                color: isMe ? Colors.black : Colors.white,
                fontSize: 15,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                timeStr,
                style: TextStyle(
                  color: isMe ? Colors.black.withValues(alpha: 0.5) : textMuted,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}