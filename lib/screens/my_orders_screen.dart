// lib/screens/my_orders_screen.dart
import 'package:flutter/material.dart';

// 🟢 Importaciones corregidas para resolver los "undefined"
import 'package:devmarket_app/data/services/api_service.dart';
import 'package:devmarket_app/models/message.dart'; // Mapea ChatModel
import 'package:devmarket_app/screens/chat_room_screen.dart'; // Mapea ChatRoomScreen
import 'package:devmarket_app/widgets/custom_header.dart'; // 🚀 Importación del Header Reutilizable

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  final ApiService _apiService = ApiService();

  List<dynamic> _orders = [];
  bool _isLoading = true;
  String _errorMessage = '';
  
  // 🟢 Guardaremos tu ID real dinámicamente sin IDs fijos
  String myUserId = ''; 

  // 🔘 Estado para controlar la pestaña activa igual que en la Web
  String _activeTab = 'TODOS'; 

  @override
  void initState() {
    super.initState();
    _loadCurrentUserId(); // 🟢 Cargamos el ID real desde el storage del teléfono
    _fetchOrders();
  }

  // 🟢 Método asíncrono para leer el ID real que viene del Login
  void _loadCurrentUserId() async {
    final id = await _apiService.getUserId();
    if (mounted && id != null) {
      setState(() {
        myUserId = id;
      });
    }
  }

  Future<void> _fetchOrders() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      final List<dynamic> fetchedOrders = await _apiService.getMisPedidos();

      setState(() {
        _orders = fetchedOrders;
        _isLoading = false;
      });
    } catch (e) {
      // 🟢 Corregido avoid_print usando debugPrint
      debugPrint("🚨 DETALLE DEL ERROR DE PEDIDOS: $e");
      setState(() {
        _errorMessage = 'Error al conectar con el servidor';
        _isLoading = false;
      });
    }
  }

  // 🧭 Filtrado de pedidos IDÉNTICO a la lógica de tu Next.js (Sincronizado con PENDING)
  List<dynamic> get _filteredOrders {
    if (_activeTab == 'TODOS') return _orders;
    if (_activeTab == 'ACTIVOS') {
      return _orders.where((order) {
        final status = order['status']?.toString() ?? '';
        return status == 'PENDING' || status == 'IN_PROGRESS';
      }).toList();
    }
    if (_activeTab == 'COMPLETADOS') {
      return _orders.where((order) {
        return (order['status']?.toString() ?? '') == 'COMPLETED';
      }).toList();
    }
    return _orders;
  }

  // Conteo dinámico para las insignias de los botones (Sincronizado con PENDING)
  int _countOrdersByStatus(String type) {
    if (type == 'TODOS') return _orders.length;
    if (type == 'ACTIVOS') {
      return _orders.where((o) {
        final s = o['status']?.toString() ?? '';
        return s == 'PENDING' || s == 'IN_PROGRESS';
      }).length;
    }
    if (type == 'COMPLETADOS') {
      return _orders.where((o) => (o['status']?.toString() ?? '') == 'COMPLETED').length;
    }
    return 0;
  }

  String _calculateDeliveryDate(String createdAtStr, int deliveryDays) {
    try {
      DateTime createdAt = DateTime.parse(createdAtStr);
      DateTime deliveryDate = createdAt.add(Duration(days: deliveryDays));
      
      final months = ['ene', 'feb', 'mar', 'abr', 'may', 'jun', 'jul', 'ago', 'sep', 'oct', 'nov', 'dic'];
      return '${deliveryDate.day.toString().padLeft(2, '0')} ${months[deliveryDate.month - 1]} ${deliveryDate.year}';
    } catch (_) {
      return 'Fecha indefinida';
    }
  }

  @override
  Widget build(BuildContext context) {
    const accentColor = Color(0xFF00E676); 
    const cardColor = Color(0xFF0C0C0E);   

    return Scaffold(
      backgroundColor: const Color(0xFF080808), 
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🚀 INTEGRACIÓN DEL HEADER NUEVO REUTILIZABLE
            const CustomHeader(
              title: 'Mis pedidos',
              subtitle: 'Gestiona tus proyectos activos y revisa las entregas finales.',
            ),
            const SizedBox(height: 16),

            // 🗂️ TABS DE FILTRADO
            if (!_isLoading && _errorMessage.isEmpty)
              Container(
                height: 48,
                margin: const EdgeInsets.only(bottom: 16),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  children: [
                    _buildTabButton('TODOS', accentColor),
                    const SizedBox(width: 12),
                    _buildTabButton('ACTIVOS', accentColor),
                    const SizedBox(width: 12),
                    _buildTabButton('COMPLETADOS', accentColor),
                  ],
                ),
              ),

            // 🔄 RENDERIZADO CONDICIONAL
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(accentColor)),
                          SizedBox(height: 16),
                          Text('Cargando tus pedidos...', style: TextStyle(color: Color(0xFF71717A), fontSize: 14)),
                        ],
                      ),
                    )
                  : _errorMessage.isNotEmpty
                      ? Center(
                          child: Text(_errorMessage, style: const TextStyle(color: Colors.redAccent)),
                        )
                      : _filteredOrders.isEmpty
                          ? const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.layers_clear_outlined, size: 64, color: Color(0xFF27272A)),
                                  SizedBox(height: 16),
                                  Text('No hay pedidos aquí', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                                  Text('Aún no tienes proyectos en esta categoría.', style: TextStyle(color: Color(0xFF71717A), fontSize: 14)),
                                ],
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: _fetchOrders,
                              color: accentColor,
                              backgroundColor: const Color(0xFF121214),
                              child: ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                itemCount: _filteredOrders.length,
                                itemBuilder: (context, index) {
                                  return _buildOrderCard(context, _filteredOrders[index], accentColor, cardColor);
                                },
                              ),
                            ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(String tabName, Color accentColor) {
    final bool isActive = _activeTab == tabName;
    return InkWell(
      onTap: () => setState(() => _activeTab = tabName),
      borderRadius: BorderRadius.circular(24),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: isActive ? accentColor : const Color(0xFF121214),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: isActive ? accentColor : const Color(0xFF27272A)),
          boxShadow: isActive 
              ? [BoxShadow(color: accentColor.withValues(alpha: 0.3), blurRadius: 15, spreadRadius: 1)] 
              : null,
        ),
        alignment: Alignment.center,
        child: Row(
          children: [
            Text(
              tabName,
              style: TextStyle(
                color: isActive ? Colors.black : const Color(0xFF71717A),
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: isActive ? Colors.black.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.3), 
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${_countOrdersByStatus(tabName)}',
                style: TextStyle(
                  color: isActive ? Colors.black : const Color(0xFF71717A),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, dynamic order, Color accentColor, Color cardColor) {
    final String status = order['status']?.toString() ?? '';
    final service = order['service'] ?? {};
    final seller = order['seller'] ?? {};

    final String title = service['title']?.toString() ?? 'Servicio Personalizado';
    final String freelancerName = seller['name']?.toString() ?? '@usuario';
    final String avatarUrl = seller['avatar']?.toString() ?? '';
    final int deliveryDays = int.tryParse(service['deliveryDays']?.toString() ?? '') ?? 7;
    final String createdAt = order['createdAt']?.toString() ?? DateTime.now().toIso8601String();
    final double price = double.tryParse(order['price']?.toString() ?? '') ?? 0.0;

    // 🔄 Sincronización del progreso dinámico real desde la Base de Datos
    int progressPercent = int.tryParse(order['progress']?.toString() ?? '') ?? 0;
    
    // Fallback por si la base de datos está vacía en progreso pero tiene estados consistentes
    if (progressPercent == 0) {
      if (status == 'IN_PROGRESS') progressPercent = 60; // Mantener consistencia con el fallback de Next.js
      if (status == 'COMPLETED') progressPercent = 100;
    }

    double progressValue = progressPercent / 100.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor, 
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF27272A).withValues(alpha: 0.5)), 
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, 
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: const Color(0xFF121214),
                backgroundImage: avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
                child: avatarUrl.isEmpty 
                    ? Text(
                        freelancerName.isNotEmpty ? freelancerName.substring(0, 1).toUpperCase() : 'U', 
                        style: TextStyle(color: accentColor),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatusTag(status),
                    const SizedBox(height: 6),
                    Text(
                      title, 
                      style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text('Freelancer: $freelancerName', style: const TextStyle(color: Color(0xFF71717A), fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('PROGRESO', style: TextStyle(color: Color(0xFF71717A), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
              Text('$progressPercent%', style: TextStyle(color: accentColor, fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progressValue,
              backgroundColor: const Color(0xFF121214),
              valueColor: AlwaysStoppedAnimation<Color>(accentColor),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 20),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('ENTREGA EST.', style: TextStyle(color: Color(0xFF71717A), fontSize: 10, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text(_calculateDeliveryDate(createdAt, deliveryDays), style: const TextStyle(color: Color(0xFFE4E4E7), fontSize: 14, fontWeight: FontWeight.w500)), 
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('INVERSION', style: TextStyle(color: Color(0xFF71717A), fontSize: 10, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text('S/ ${price.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)), 
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                final String freelancerId = seller['id']?.toString() ?? '';

                if (freelancerId.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('No se pudo encontrar el ID del freelancer')),
                  );
                  return;
                }

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Sincronizando chat de trabajo...'), 
                    duration: Duration(milliseconds: 500)
                  ),
                );

                String conversationId = '';

                try {
                  final List<dynamic> activosChats = await _apiService.getChats(); 

                  final chatExistente = activosChats.firstWhere(
                    (json) {
                      final bool isParticipantAContact = json['participantAId']?.toString() != myUserId;
                      final dynamic targetParticipant = isParticipantAContact ? json['participantA'] : json['participantB'];
                      final String currentFreelancerId = targetParticipant != null ? (targetParticipant['id']?.toString() ?? '') : '';
                      return currentFreelancerId == freelancerId;
                    },
                    orElse: () => null,
                  );

                  if (chatExistente != null) {
                    conversationId = chatExistente['id']?.toString() ?? '';
                  }
                } catch (e) {
                  debugPrint("🧠 Nota: Entrando en modo directo sin historial: $e");
                }

                if (conversationId.isEmpty) {
                  conversationId = order['conversationId']?.toString() ?? '';
                }

                if (!context.mounted) return;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatRoomScreen(
                      chat: ChatModel(
                        id: conversationId, 
                        name: freelancerName,
                        lastMessage: '',
                        avatarUrl: avatarUrl,
                        time: '',
                        unreadCount: 0,
                      ),
                      participantId: freelancerId, 
                      myUserId: myUserId,          
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.chat_bubble_outline, size: 18),
              label: const Text('Abrir Chat de Trabajo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF121214),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: Color(0xFF27272A)),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTag(String status) {
    Color bgColor;
    Color textColor;
    String textLabel;

    switch (status) {
      case 'PENDING': // 🟢 Cambiado PAID por PENDING (Ámbar - Por iniciar)
        bgColor = const Color(0xFFF59E0B).withValues(alpha: 0.1); 
        textColor = const Color(0xFFFBBF24);
        textLabel = 'POR INICIAR';
        break;
      case 'IN_PROGRESS': // 🔵 En proceso pasa a ser Azul para combinar con Next.js
        bgColor = const Color(0xFF3B82F6).withValues(alpha: 0.1); 
        textColor = const Color(0xFF60A5FA);
        textLabel = 'EN PROCESO';
        break;
      case 'COMPLETED': // 🟢 Completado se mantiene verde
        bgColor = const Color(0xFF10B981).withValues(alpha: 0.1); 
        textColor = const Color(0xFF34D399);
        textLabel = 'COMPLETADO';
        break;
      case 'CANCELLED': // 🔴 Manejo del estado Cancelado
        bgColor = const Color(0xFFEF4444).withValues(alpha: 0.1); 
        textColor = const Color(0xFFF87171);
        textLabel = 'CANCELADO';
        break;
      default:
        bgColor = const Color(0xFF27272A);
        textColor = Colors.white;
        textLabel = 'DESCONOCIDO';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(10)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: textColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            textLabel,
            style: TextStyle(color: textColor, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
          ),
        ],
      ),
    );
  }
}