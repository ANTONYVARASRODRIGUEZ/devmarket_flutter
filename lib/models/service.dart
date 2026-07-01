// lib/models/service.dart
class ServiceModel {
  final String id; // 🚀 NUEVO: Almacena el ID real del servicio de la base de datos
  final String title;
  final String subtitle;
  final String developerName;
  final String developerAvatarUrl;
  final double rating;
  final int reviewsCount; 
  final int price; 
  final String imageUrl;
  final String category; 
  final DateTime date; 
  final String description;
  final String deliveryTime;
  final String revisions;

  ServiceModel({
    required this.id, // 🚀 Requerido
    required this.title,
    required this.subtitle,
    required this.developerName,
    required this.developerAvatarUrl,
    required this.rating,
    required this.reviewsCount, 
    required this.price,
    required this.imageUrl,
    required this.category,
    required this.date,
    required this.description,
    required this.deliveryTime,
    required this.revisions,
  });
}