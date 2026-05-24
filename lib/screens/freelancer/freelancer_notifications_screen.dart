// lib/screens/freelancer/freelancer_notifications_screen.dart
import 'package:flutter/material.dart';

class FreelancerNotificationsScreen extends StatelessWidget {
  const FreelancerNotificationsScreen({super.key});

  static const bgDark = Color(0xFF080808);
  static const cardColor = Color(0xFF121214);
  static const accentColor = Color(0xFF10B981);
  static const textMuted = Color(0xFF71717A);
  static const borderDark = Color(0xFF1C1C1E);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgDark,
      appBar: AppBar(
        backgroundColor: bgDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Notificaciones',
          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        children: [
          _buildNotificationCard(
            title: 'Nuevo mensaje',
            description: 'Carlos M. te ha enviado un mensaje',
            time: 'Hace 5 min',
            isUnread: true,
          ),
          _buildNotificationCard(
            title: 'Proyecto actualizado',
            description: 'Tu proyecto ha avanzado al 65%',
            time: 'Hace 1 hora',
            isUnread: true,
          ),
          _buildNotificationCard(
            title: 'Pago recibido',
            description: 'Has recibido \$800 por E-commerce React',
            time: 'Hace 2 días',
            isUnread: false,
          ),
          _buildNotificationCard(
            title: 'Nueva resena',
            description: 'TechCorp te ha dejado una resena de 5 estrellas',
            time: 'Hace 3 días',
            isUnread: false,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard({
    required String title,
    required String description,
    required String time,
    required bool isUnread,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderDark.withAlpha(128)),
      ),
      // ClipRRect para que la barra lateral verde respete el borde redondeado izquierdo
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Contenido de la notificación
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Espaciado extra a la izquierda si tiene la barra verde activa
                  if (isUnread) const SizedBox(width: 6),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          description,
                          style: TextStyle(
                            color: Colors.white.withAlpha(200),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          time,
                          style: const TextStyle(
                            color: textMuted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Punto verde indicador de "no leído" a la derecha
                  if (isUnread)
                    Container(
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
            // Barra lateral verde fosforescente (Solo si no está leída)
            if (isUnread)
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                width: 4,
                child: Container(
                  color: accentColor,
                ),
              ),
          ],
        ),
      ),
    );
  }
}