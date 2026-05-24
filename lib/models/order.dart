// lib/models/order.dart
class OrderModel {
  final String title;
  final String developerName;
  final String developerAvatarUrl;
  final String deliveryDate;
  final double price;
  final double progress; // Valor entre 0.0 y 1.0
  final String status;   // 'Pendiente', 'En Proceso', 'Entregado'

  OrderModel({
    required this.title,
    required this.developerName,
    required this.developerAvatarUrl,
    required this.deliveryDate,
    required this.price,
    required this.progress,
    required this.status,
  });
}