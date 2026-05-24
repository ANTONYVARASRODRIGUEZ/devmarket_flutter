// lib/models/service.dart
class ServiceModel {
  final String title;
  final String subtitle;
  final String developerName;
  final String developerAvatarUrl;
  final double rating;
  final int price; 
  final String imageUrl;
  final String category; 
  final DateTime date; 
  // Nuevos campos para la pantalla de detalle
  final String description;
  final String deliveryTime;
  final String revisions;

  ServiceModel({
    required this.title,
    required this.subtitle,
    required this.developerName,
    required this.developerAvatarUrl,
    required this.rating,
    required this.price,
    required this.imageUrl,
    required this.category,
    required this.date,
    required this.description,
    required this.deliveryTime,
    required this.revisions,
  });
}