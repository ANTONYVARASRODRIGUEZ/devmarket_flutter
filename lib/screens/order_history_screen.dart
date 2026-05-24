// lib/screens/order_history_screen.dart
import 'package:flutter/material.dart';

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const bgDark = Color(0xFF080808);
    const cardColor = Color(0xFF121214);
    const accentColor = Color(0xFF10B981);

    // Datos ficticios basados exactamente en tu captura de pantalla
    final List<Map<String, dynamic>> orders = [
      {
        'title': 'E-commerce completo',
        'developer': 'Ana R.',
        'date': '15 Abr 2024',
        'price': '\$2500',
        'status': 'Completado',
        'statusColor': const Color(0xFF064E3B),
        'textColor': accentColor,
        'canDownload': true,
      },
      {
        'title': 'App de gestión',
        'developer': 'Carlos M.',
        'date': '28 Mar 2024',
        'price': '\$1800',
        'status': 'Completado',
        'statusColor': const Color(0xFF064E3B),
        'textColor': accentColor,
        'canDownload': true,
      },
      {
        'title': 'Diseño UI/UX',
        'developer': 'Laura G.',
        'date': '10 Mar 2024',
        'price': '\$650',
        'status': 'Reembolsado',
        'statusColor': const Color(0xFF78350F),
        'textColor': const Color(0xFFFBBF24),
        'canDownload': false,
      },
      {
        'title': 'Bot Telegram',
        'developer': 'Diego F.',
        'date': '22 Feb 2024',
        'price': '\$320',
        'status': 'Completado',
        'statusColor': const Color(0xFF064E3B),
        'textColor': accentColor,
        'canDownload': true,
      },
      {
        'title': 'Landing Page',
        'developer': 'Miguel S.',
        'date': '5 Feb 2024',
        'price': '\$450',
        'status': 'Cancelado',
        'statusColor': const Color(0xFF7F1D1D),
        'textColor': const Color(0xFFEF4444),
        'canDownload': false,
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
          'Historial de Pedidos',
          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        titleSpacing: 0,
      ),
      // ListView.builder genera el scroll vertical eficiente de manera nativa
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF1C1C1E)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Fila Superior: Título + Estado
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        order['title'],
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: order['statusColor'],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        order['status'],
                        style: TextStyle(color: order['textColor'], fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                // Desarrollador
                Text(
                  'Por ${order['developer']}',
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 14),
                // Fecha y Precio
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      order['date'],
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                    Text(
                      order['price'],
                      style: TextStyle(color: order['textColor'], fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                // Botón Condicional de Descarga si está "Completado"
                if (order['canDownload']) ...[
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 38,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF27272A)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        backgroundColor: const Color(0xFF18181B),
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Descargando archivos de "${order['title']}"...'),
                            backgroundColor: accentColor,
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                      icon: const Icon(Icons.file_download_outlined, color: Colors.white, size: 18),
                      label: const Text(
                        'Descargar Archivos',
                        style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}