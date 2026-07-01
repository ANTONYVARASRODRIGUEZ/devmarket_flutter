// lib/widgets/custom_header.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import 'package:overlay_support/overlay_support.dart'; // 🟢 Importación para notificaciones flotantes in-app
import 'package:devmarket_app/data/services/api_service.dart'; 
import 'package:devmarket_app/data/services/socket_service.dart';

class CustomHeader extends StatefulWidget {
  final String title;
  final String subtitle;

  const CustomHeader({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  State<CustomHeader> createState() => _CustomHeaderState();
}

class _CustomHeaderState extends State<CustomHeader> {
  final ApiService _apiService = ApiService();
  final SocketService _socketService = SocketService();

  String _myUserId = '';
  String _myRole = 'CLIENT'; // Rol por defecto
  int _unreadNotifications = 0;
  List<dynamic> _chats = []; 
  
  // 🛡️ Filtro anti-bucle: Almacena el ID del último mensaje renderizado con éxito
  String _lastProcessedMessageId = '';

  @override
  void initState() {
    super.initState();
    _initHeaderData();
    _initGlobalSocketListener();
  }

  /// 👤 1. Carga el rol real y calcula los mensajes iniciales sin leer
  Future<void> _initHeaderData() async {
    try {
      final savedId = await _apiService.getUserId();
      final savedRole = await _apiService.getUserRole(); 
      
      final List<dynamic> data = await _apiService.getChats(); 
      int totalUnreads = 0;
      
      for (var json in data) {
        totalUnreads += (json['_count']?['messages'] as int? ?? 0);
      }

      if (mounted) {
        setState(() {
          if (savedId != null) _myUserId = savedId;
          if (savedRole != null) _myRole = savedRole; 
          _unreadNotifications = totalUnreads;
          _chats = data; 
        });
      }
    } catch (e) {
      debugPrint("🧠 Nota al inicializar datos del Header: $e");
    }
  }

  /// 🔔 2. Escucha activa de Sockets optimizada y protegida contra re-renders
  void _initGlobalSocketListener() {
    final socket = _socketService.socket;
    
    if (socket == null) {
      debugPrint("🚨 [RASTREO] El socket es NULO en el Header.");
      return;
    }

    // 🛑 Desactivamos cualquier listener previo duplicado para sanear la memoria
    socket.off('new_message');

    // Escuchamos el evento de forma limpia y controlada
    socket.on('new_message', (data) {
      if (!mounted) return;
      
      final String messageId = data['id'] ?? '';
      final String senderId = data['senderId'] ?? '';
      final String content = data['content'] ?? 'Te envió un mensaje';
      final String senderName = data['sender']?['name'] ?? 'Nuevo mensaje recibido';
      
      // 🛡️ CONTROL DE DUPLICADOS: Si este mensaje exacto ya flotó en pantalla, se ignora
      if (messageId.isNotEmpty && messageId == _lastProcessedMessageId) {
        return;
      }

      // Validación de remitente: No auto-notificar acciones propias
      if (senderId == _myUserId) {
        return;
      }

      // Marcamos el ID actual como procesado antes de mutar estados
      _lastProcessedMessageId = messageId;

      if (mounted) {
        setState(() {
          _unreadNotifications++;
        });
        _initHeaderData(); // Refresca silenciosamente los chats del menú flotante
      }

      // 🟢 BANNER FLOTANTE DE ENTRADA ÚNICA
      showOverlayNotification((context) {
        return SafeArea(
          child: Material(
            color: Colors.transparent,
            child: Card(
              margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              color: const Color(0xFF1C1C1E), 
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 10,
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFF00E676),
                  child: Icon(Icons.chat_bubble_outline, color: Colors.black, size: 18),
                ),
                title: Text(
                  senderName,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                ),
                subtitle: Text(
                  content,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey, size: 16),
                  onPressed: () => OverlaySupportEntry.of(context)?.dismiss(),
                ),
                onTap: () {
                  OverlaySupportEntry.of(context)?.dismiss();
                  Navigator.pushNamed(context, '/chats');
                },
              ),
            ),
          ),
        );
      }, duration: const Duration(milliseconds: 3500));
    });
  }

  /// 🚪 3. Lógica para Cerrar Sesión de forma segura
  Future<void> _handleLogout() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF121214),
        title: const Text('¿Cerrar Sesión?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text('¿Estás seguro de que deseas salir de tu cuenta?', style: TextStyle(color: Colors.grey)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Salir', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        _socketService.socket?.disconnect();
        await _apiService.logout(); 

        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
        }
      } catch (e) {
        debugPrint("🚨 Error al cerrar sesión: $e");
      }
    }
  }

  /// 🔔 4. Desplegar el menú flotante con los chats reales y mapeo relacional idéntico a ChatsScreen
  void _showNotificationsMenu() async {
    HapticFeedback.lightImpact(); 
    
    setState(() {
      _unreadNotifications = 0;
    });

    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay = Navigator.of(context).overlay!.context.findRenderObject() as RenderBox;
    
    final recentChats = _chats.take(3).toList();

    List<PopupMenuEntry> menuItems = [
      const PopupMenuItem(
        enabled: false,
        child: Text(
          'Mensajes Recientes', 
          style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)
        ),
      ),
    ];

    if (recentChats.isEmpty) {
      menuItems.add(
        const PopupMenuItem(
          enabled: false,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text('No tienes mensajes nuevos', style: TextStyle(color: Colors.grey, fontSize: 13)),
          ),
        ),
      );
    } else {
      for (var chat in recentChats) {
        String lastMessage = 'Sin mensajes';
        if (chat['messages'] != null && (chat['messages'] as List).isNotEmpty) {
          lastMessage = chat['messages'][0]['content'] ?? '';
        }
            
        final String pAId = (chat['participantAId'] ?? chat['participantA']?['id'] ?? '').toString().trim();
        final String currentUserId = _myUserId.trim();

        final bool isParticipantAContact = pAId.toLowerCase() != currentUserId.toLowerCase();
        final dynamic targetParticipant = isParticipantAContact ? chat['participantA'] : chat['participantB'];
        
        final String participantName = targetParticipant != null ? (targetParticipant['name'] ?? 'Usuario') : 'Usuario';

        menuItems.add(
          PopupMenuItem(
            onTap: () {
              Navigator.pushNamed(context, '/chats');
            },
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: const Color(0xFF2C2C2E), 
                child: Text(
                  participantName.isNotEmpty ? participantName[0].toUpperCase() : '?',
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
              title: Text(
                participantName, 
                style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                lastMessage, 
                style: const TextStyle(color: Colors.grey, fontSize: 12),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        );
      }
    }

    menuItems.add(
      PopupMenuItem(
        onTap: () => Navigator.pushNamed(context, '/chats'),
        child: const Center(
          child: Text(
            'Ver todos los chats', 
            style: TextStyle(color: Color(0xFF00E676), fontSize: 13, fontWeight: FontWeight.bold)
          )
        ),
      ),
    );

    await showMenu(
      context: context,
      elevation: 8,
      position: RelativeRect.fromRect(
        Rect.fromPoints(
          button.localToGlobal(Offset.zero, ancestor: overlay),
          button.localToGlobal(button.size.bottomLeft(Offset.zero), ancestor: overlay),
        ),
        Offset.zero & overlay.size,
      ),
      items: menuItems, 
    );
  }

  @override
  void dispose() {
    _socketService.socket?.off('new_message');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const accentColor = Color(0xFF00E676);
    
    final String displayRole = _myUserId.isEmpty 
        ? 'Cargando...' 
        : (_myRole.toUpperCase() == 'FREELANCER' ? 'Freelancer' : 'Cliente');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(color: accentColor, shape: BoxShape.circle),
                    child: const Icon(Icons.code, color: Colors.black, size: 20),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'TecsupFiver',
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: _showNotificationsMenu, 
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(color: Color(0xFF1C1C1E), shape: BoxShape.circle),
                          child: Icon(
                            Icons.notifications_none_outlined, 
                            color: _unreadNotifications > 0 ? accentColor : Colors.grey, 
                            size: 22,
                          ),
                        ),
                        if (_unreadNotifications > 0) 
                          Positioned(
                            top: -2,
                            right: -2,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(color: accentColor, shape: BoxShape.circle),
                              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                              child: Text(
                                _unreadNotifications > 9 ? '9+' : '$_unreadNotifications',
                                style: const TextStyle(
                                  color: Colors.black, 
                                  fontSize: 9, 
                                  fontWeight: FontWeight.bold
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1C1C1E),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      displayRole, 
                      style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                  ),
                  const SizedBox(width: 8),

                  GestureDetector(
                    onTap: _handleLogout,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Color(0xFF1C1C1E), 
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.logout_rounded, 
                        color: Colors.redAccent, 
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          Text(
            widget.title,
            style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            widget.subtitle,
            style: const TextStyle(color: Colors.grey, fontSize: 15),
          ),
        ],
      ),
    );
  }
}