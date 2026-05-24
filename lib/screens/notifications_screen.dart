// lib/screens/notifications_screen.dart
import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const bgDark = Color(0xFF080808);
    const cardColor = Color(0xFF121214);
    const accentColor = Color(0xFF10B981);

    // Estructura de datos basada exactamente en tu captura de pantalla
    final List<Map<String, dynamic>> notifications = [
      {
        'title': 'Nuevo mensaje',
        'subtitle': 'Carlos M. te ha enviado un mensaje',
        'time': 'Hace 5 min',
        'isUnread': true,
      },
      {
        'title': 'Proyecto actualizado',
        'subtitle': 'Tu proyecto ha avanzado al 65%',
        'time': 'Hace 1 hora',
        'isUnread': true,
      },
      {
        'title': 'Pago recibido',
        'subtitle': 'Has recibido \$800 por E-commerce React',
        'time': 'Hace 2 días',
        'isUnread': false,
      },
      {
        'title': 'Nueva reseña',
        'subtitle': 'TechCorp te ha dejado una reseña de 5 estrellas',
        'time': 'Hace 3 días',
        'isUnread': false,
      },
    ];

    return Scaffold(
      backgroundColor: bgDark,
      appBar: AppBar(
        backgroundColor: bgDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Notificaciones',
          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        titleSpacing: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final item = notifications[index];
          final bool isUnread = item['isUnread'];

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            height: 95, // Altura fija aproximada para las tarjetas
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
            ),
            // ClipRRect evita que el contenedor interno del borde verde se salga de las esquinas redondeadas
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  // Borde lateral dinámico (Solo si no está leída)
                  if (isUnread)
                    Positioned(
                      left: 0,
                      top: 0,
                      bottom: 0,
                      child: Container(
                        width: 4,
                        color: accentColor,
                      ),
                    ),
                  
                  // Contenido de la notificación
                  Padding(
                    padding: EdgeInsets.only(left: isUnread ? 20.0 : 16.0, right: 16.0, top: 16.0, bottom: 16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['title'],
                                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item['subtitle'],
                                style: const TextStyle(color: Colors.grey, fontSize: 13),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const Spacer(),
                              Text(
                                item['time'],
                                style: const TextStyle(color: Color(0xFF52525B), fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        
                        // Punto indicador dinámico (Solo si no está leída)
                        if (isUnread)
                          Container(
                            //  CORRECTO
                            margin: const EdgeInsets.only(top: 4),
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: accentColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}