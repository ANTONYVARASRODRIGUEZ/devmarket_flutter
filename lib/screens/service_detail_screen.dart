// lib/screens/service_detail_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/service.dart';

class ServiceDetailScreen extends StatefulWidget {
  final ServiceModel service;

  const ServiceDetailScreen({super.key, required this.service});

  @override
  State<ServiceDetailScreen> createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen> {
  bool _isProcessing = false;

  // 1. NUEVA FUNCIÓN: PANEL DE ÉXITO FINAL
  void _showSuccessPanel(BuildContext context) {
    const accentColor = Color(0xFF10B981);
    const panelBgColor = Color(0xFF121214);

    showDialog(
      context: context,
      barrierDismissible: false, // Obliga a interactuar con el botón
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
          child: Dialog(
            backgroundColor: panelBgColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icono de Check en Círculo Verde
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: accentColor, width: 3),
                    ),
                    child: const Icon(Icons.check, color: accentColor, size: 45),
                  ),
                  const SizedBox(height: 24),
                  
                  // Título
                  const Text(
                    'Pago Exitoso!',
                    style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  
                  // Descripción
                  Text(
                    'Tu proyecto ha sido creado. El freelancer comenzará a trabajar pronto.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[400], fontSize: 16, height: 1.4),
                  ),
                  const SizedBox(height: 32),
                  
                  // Botón "Ver mis proyectos"
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context); // Cierra el diálogo de éxito
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                      ),
                      child: const Text(
                        'Ver mis proyectos',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // 2. FUNCIÓN: PANEL DE CONFIRMACIÓN DE CONTRATACIÓN
  void _showConfirmationPanel(BuildContext context) {
    const accentColor = Color(0xFF10B981);
    const cardColor = Color(0xFF1C1C1E);
    const panelBgColor = Color(0xFF121214);

    final double commission = widget.service.price * 0.05;
    final double total = widget.service.price + commission;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 6.0, sigmaY: 6.0),
              child: Container(
                decoration: const BoxDecoration(
                  color: panelBgColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Confirmar Contratacion',
                          style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.grey),
                          onPressed: _isProcessing ? null : () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundImage: NetworkImage(widget.service.developerAvatarUrl),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      widget.service.developerName,
                                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(width: 6),
                                    const Icon(Icons.star, color: Colors.amber, size: 16),
                                    const SizedBox(width: 4),
                                    Text(
                                      widget.service.rating.toString(),
                                      style: const TextStyle(color: Colors.white, fontSize: 14),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  widget.service.title,
                                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  widget.service.subtitle,
                                  style: TextStyle(color: Colors.grey[400], fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Servicio', style: TextStyle(color: Colors.grey[400], fontSize: 15)),
                              Text('\$${widget.service.price}', style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500)),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Comision plataforma (5%)', style: TextStyle(color: Colors.grey[400], fontSize: 15)),
                              Text('\$${commission.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500)),
                            ],
                          ),
                          const SizedBox(height: 14),
                          const Divider(color: Color(0xFF2C2C2E)),
                          const SizedBox(height: 14),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Total', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                              Text(
                                '\$${total.toStringAsFixed(0)}',
                                style: const TextStyle(color: accentColor, fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        const Icon(Icons.shield_outlined, color: accentColor, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Pago seguro. Tu dinero está protegido hasta que apruebes el trabajo.',
                            style: TextStyle(color: Colors.grey[400], fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isProcessing
                            ? null
                            : () async {
                                setModalState(() => _isProcessing = true);
                                
                                await Future.delayed(const Duration(seconds: 3));

                                if (context.mounted) {
                                  setModalState(() => _isProcessing = false);
                                  Navigator.pop(context); // Cierra modal de pago
                                  
                                  // DISPARA LA VENTANA DE ÉXITO
                                  _showSuccessPanel(context);
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isProcessing ? const Color(0xFF065F46) : accentColor,
                          disabledBackgroundColor: const Color(0xFF065F46),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        ),
                        child: _isProcessing
                            ? const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF10B981)),
                                  ),
                                  SizedBox(width: 12),
                                  Text('Procesando pago...', style: TextStyle(fontSize: 16, color: Colors.grey)),
                                ],
                              )
                            : Text('Pagar \$${total.toStringAsFixed(0)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const accentColor = Color(0xFF10B981);
    const cardColor = Color(0xFF121214);

    return Scaffold(
      backgroundColor: const Color(0xFF080808),
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.45,
            child: Image.network(widget.service.imageUrl, fit: BoxFit.cover),
          ),
          Positioned(
            top: 40,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20)),
              child: Text(widget.service.category, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ),
          Positioned(
            top: 40,
            left: 16,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const CircleAvatar(backgroundColor: Colors.black54, child: Icon(Icons.arrow_back, color: Colors.white)),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.38,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(color: cardColor, borderRadius: BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32))),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.service.title, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        CircleAvatar(radius: 20, backgroundImage: NetworkImage(widget.service.developerAvatarUrl)),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.service.developerName, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                            Row(
                              children: [
                                const Icon(Icons.star, color: Colors.amber, size: 16),
                                Text(' ${widget.service.rating} (234 reseñas)', style: TextStyle(color: Colors.grey[500], fontSize: 14)),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        const Icon(Icons.access_time, color: Colors.grey, size: 18),
                        Text('  ${widget.service.deliveryTime}   ', style: const TextStyle(color: Colors.white70)),
                        const Icon(Icons.check_circle_outline, color: accentColor, size: 18),
                        Text('  ${widget.service.revisions}', style: const TextStyle(color: Colors.white70)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Divider(color: Colors.white12),
                    const Text('Descripcion', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Text(widget.service.description, style: TextStyle(color: Colors.grey[400], fontSize: 15, height: 1.5)),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              color: const Color(0xFF0F0F11),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Precio', style: TextStyle(color: Colors.grey, fontSize: 12)),
                      Text('\$${widget.service.price}', style: const TextStyle(color: accentColor, fontSize: 26, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () => _showConfirmationPanel(context),
                    style: ElevatedButton.styleFrom(backgroundColor: accentColor, foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24))),
                    child: const Text('Contratar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}