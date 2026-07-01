// lib/widgets/service_card.dart
import 'package:flutter/material.dart';
import '../models/service.dart';
import '../screens/service_detail_screen.dart';
import 'package:devmarket_app/data/services/api_service.dart'; // Asegura el acceso a las peticiones

class ServiceCard extends StatefulWidget {
  final ServiceModel service;

  const ServiceCard({super.key, required this.service});

  @override
  State<ServiceCard> createState() => _ServiceCardState();
}

class _ServiceCardState extends State<ServiceCard> {
  final ApiService _apiService = ApiService();
  
  late double _currentRating;
  late int _currentReviewsCount;
  bool _isStatsLoading = true;

  @override
  void initState() {
    super.initState();
    // Cargamos valores iniciales por si acaso o por defecto
    _currentRating = widget.service.rating;
    _currentReviewsCount = widget.service.reviewsCount;
    _fetchLiveReviewsStats();
  }

  Future<void> _fetchLiveReviewsStats() async {
    try {
      // 🚀 Llamado al backend usando el id real mapeado en el paso anterior
      final response = await _apiService.getServiceReviewsStats(widget.service.id);
      
      if (mounted && response.isNotEmpty) {
        // 🟢 CORRECCIÓN CLÍTICA: Extraemos el mapa interno 'stats' devuelto por el ApiService
        final stats = response['stats'] as Map<String, dynamic>?;

        if (stats != null) {
          setState(() {
            // 🟢 CORRECCIÓN CLÍTICA: Las claves correctas de tu backend son 'average' y 'total'
            _currentRating = double.tryParse(stats['average']?.toString() ?? '5.0') ?? 5.0;
            _currentReviewsCount = int.tryParse(stats['total']?.toString() ?? '0') ?? 0;
            _isStatsLoading = false;
          });
        }
      }
    } catch (e) {
      print('⚠️ Error cargando estadísticas en ServiceCard: $e');
      // Si la ruta falla o no hay reseñas registradas aún en Mongo, mantenemos valores iniciales
      if (mounted) {
        setState(() => _isStatsLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const accentColor = Color(0xFF00E676); // Verde neón brillante para el precio
    const tagBgColor = Color(0xFF1E1E1E);   // Gris oscuro para el fondo del tag

    // Generamos una copia optimizada del modelo con los datos obtenidos en tiempo real
    final updatedService = ServiceModel(
      id: widget.service.id,
      title: widget.service.title,
      subtitle: widget.service.subtitle,
      developerName: widget.service.developerName,
      developerAvatarUrl: widget.service.developerAvatarUrl,
      rating: _currentRating,
      reviewsCount: _currentReviewsCount,
      price: widget.service.price,
      imageUrl: widget.service.imageUrl,
      category: widget.service.category,
      date: widget.service.date,
      description: widget.service.description,
      deliveryTime: widget.service.deliveryTime,
      revisions: widget.service.revisions,
    );

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            // 🚀 Pasamos el objeto con las estadísticas frescas al detalle
            builder: (context) => ServiceDetailScreen(service: updatedService),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(left: 16, right: 16, bottom: 28),
        color: Colors.transparent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- CONTENEDOR DE IMAGEN CON ELEMENTOS FLOTANTES ---
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Image.network(
                    widget.service.imageUrl,
                    height: 190,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: 190,
                        color: const Color(0xFF121212),
                        child: const Center(
                          child: CircularProgressIndicator(color: accentColor),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 190,
                        color: const Color(0xFF1A1A1A),
                        child: const Icon(Icons.image_not_supported, color: Colors.grey, size: 40),
                      );
                    },
                  ),
                ),
                
                // 🏷️ Tag de Categoría
                Positioned(
                  top: 14,
                  left: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: tagBgColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      widget.service.category,
                      style: const TextStyle(
                        color: Colors.white, 
                        fontSize: 12, 
                        fontWeight: FontWeight.w600
                      ),
                    ),
                  ),
                ),
                
                // ❤️ Botón de Favorito Circular
                Positioned(
                  top: 14,
                  right: 14,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.black45,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.favorite_border,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            
            // --- TÍTULO DEL SERVICIO ---
            Text(
              widget.service.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white, 
                fontSize: 19, 
                fontWeight: FontWeight.bold,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 4),
            
            // --- SUBTÍTULO / DESCRIPCIÓN CORTA ---
            Text(
              widget.service.subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            
            // --- FILA INFERIOR: METADATOS DEL FREELANCER, PUNTUACIÓN Y PRECIO ---
            Row(
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundImage: NetworkImage(widget.service.developerAvatarUrl),
                  backgroundColor: const Color(0xFF222222),
                ),
                const SizedBox(width: 8),
                
                Expanded(
                  child: Text(
                    widget.service.developerName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.grey[300], 
                      fontSize: 14,
                    ),
                  ),
                ),
                
                // 🌟 Puntuación en Estrellas Dinámica e Integrada
                const Icon(Icons.star, color: Colors.amber, size: 16),
                const SizedBox(width: 4),
                _isStatsLoading
                    ? const SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(color: Colors.amber, strokeWidth: 1.5),
                      )
                    : Text(
                        _currentRating.toStringAsFixed(1),
                        style: const TextStyle(
                          color: Colors.amber, 
                          fontSize: 14, 
                          fontWeight: FontWeight.bold
                        ),
                      ),
                const SizedBox(width: 3),
                
                // 💬 Cantidad de Reseñas Reales del Backend
                Text(
                  '($_currentReviewsCount)',
                  style: TextStyle(
                    color: Colors.grey[400], 
                    fontSize: 13,
                  ),
                ),
                const SizedBox(width: 16),
                
                // Precio resaltado en la moneda Soles (S/)
                Text(
                  'S/ ${widget.service.price}',
                  style: const TextStyle(
                    color: accentColor, 
                    fontSize: 19, 
                    fontWeight: FontWeight.bold
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}