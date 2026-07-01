// lib/screens/service_detail_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart'; // 💳 NUEVO: Importación para pasarela nativa
import '../models/service.dart';
import '../data/services/api_service.dart';

class ServiceDetailScreen extends StatefulWidget {
  final ServiceModel service;

  const ServiceDetailScreen({super.key, required this.service});

  @override
  State<ServiceDetailScreen> createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen> {
  final ApiService _apiService = ApiService();

  // Controladores de estado
  bool _isLoading = true;
  bool _isProcessing = false;
  bool _hasPaid = false;
  bool _isOwner = false;
  bool _isStartingChat = false;

  // Variables para asegurar la data fresca de MongoDB en esta pantalla
  late double _liveRating;
  late int _liveReviewsCount;

  @override
  void initState() {
    super.initState();
    // Inicializamos con lo que viene del constructor para no ver pantallas vacías
    _liveRating = widget.service.rating;
    _liveReviewsCount = widget.service.reviewsCount;
    _checkAccessAndOwnership();
  }

  Future<void> _checkAccessAndOwnership() async {
    setState(() => _isLoading = true);
    try {
      // 🆔 1. Recuperamos el ID del usuario real autenticado desde el Secure Storage
      final currentUserId = await _apiService.getUserId();
      
      // 👥 2. Validación de Dueño adaptada al rol
      final currentUserRole = await _apiService.getUserRole();
      
      if (currentUserRole == 'freelancer') {
        _isOwner = false; // Seteable o comparable si tu modelo tuviera un sellerId físico
      } else {
        _isOwner = false;
      }

      // 💳 3. CONSULTA REAL A TU BACKEND EXPRESS: Verificamos si ya pagó por este servicio
      if (!_isOwner && currentUserId != null) {
        _hasPaid = await _apiService.checkServiceAccess(widget.service.id);
      } else if (_isOwner) {
        _hasPaid = false;
      }

      // 🚀 4. Consulta de estadísticas de reseñas originales
      final response = await _apiService.getServiceReviewsStats(widget.service.id);
      if (response.isNotEmpty) {
        final stats = response['stats'] as Map<String, dynamic>?;
        if (stats != null && mounted) {
          setState(() {
            _liveRating = double.tryParse(stats['average']?.toString() ?? '5.0') ?? 5.0;
            _liveReviewsCount = int.tryParse(stats['total']?.toString() ?? '0') ?? 0;
          });
        }
      }

    } catch (e) {
      debugPrint("⚠️ Error verificando accesos o estadísticas en Detalle: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// 💳 FLUJO REAL DE PAGO CON STRIPE SDK
  Future<void> _processPayment(BuildContext modalContext, StateSetter setModalState) async {
    setModalState(() => _isProcessing = true);

    try {
      // 1. Comunicar con Express para registrar Orden y conseguir Intent data
      final intentData = await _apiService.createPaymentIntent(widget.service.id);

      if (intentData == null || intentData['clientSecret'] == null) {
        throw Exception("El servidor no retornó un clientSecret válido.");
      }

      final String clientSecret = intentData['clientSecret'];

      // 2. Inicializar la hoja de pago nativa de Stripe
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'DevMarket',
          style: ThemeMode.dark, // Consistente con tu diseño oscuro
        ),
      );

      // 3. Presentar el formulario flotante nativo de tarjeta
      await Stripe.instance.presentPaymentSheet();

      // 4. ¡Éxito! Cerramos el modal de confirmación y abrimos el panel de éxito
      if (mounted) {
        setModalState(() => _isProcessing = false);
        Navigator.pop(modalContext); // Cierra BottomSheet
        _showSuccessPanel(context);  // Abre modal de éxito
      }

    } on StripeException catch (e) {
      debugPrint("❌ Stripe cancelado o fallido: ${e.error.localizedMessage}");
      if (mounted) {
        setModalState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Pago cancelado: ${e.error.localizedMessage}")),
        );
      }
    } catch (e) {
      debugPrint("🚨 Error general procesando pago: $e");
      if (mounted) {
        setModalState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error al procesar el pago: $e")),
        );
      }
    }
  }

  Future<void> _handleStartChat() async {
    setState(() => _isStartingChat = true);
    
    await Future.delayed(const Duration(milliseconds: 800)); 
    
    if (mounted) {
      setState(() => _isStartingChat = false);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Abriendo chat de trabajo con ${widget.service.developerName}...'),
          backgroundColor: const Color(0xFF10B981),
        ),
      );
    }
  }

  void _showReportModal(BuildContext context) {
    final TextEditingController reportController = TextEditingController();
    const panelBgColor = Color(0xFF121214);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6.0, sigmaY: 6.0),
          child: Container(
            decoration: const BoxDecoration(
              color: panelBgColor,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
            ),
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              left: 24,
              right: 24,
              top: 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.1), // 🟢 Corregido .withOpacity obsoleto
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.flag, color: Colors.redAccent, size: 20),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Reportar Servicio',
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Si consideras que este servicio viola las políticas, descríbenos el motivo. Nuestro equipo lo revisará.',
                  style: TextStyle(color: Colors.grey[400], fontSize: 13),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: reportController,
                  maxLines: 3,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Ej: El servicio es una estafa o contiene material inapropiado...',
                    hintStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
                    filled: true,
                    fillColor: const Color(0xFF080808),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.redAccent)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.white12)),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
                      ),
                    ),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Reporte enviado. Revisaremos el caso a la brevedad.'), backgroundColor: Colors.redAccent),
                          );
                        },
                        child: const Text('Enviar Reporte', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  void _showReviewModal(BuildContext context) {
  int selectedRating = 5;
  final TextEditingController commentController = TextEditingController();
  const accentColor = Color(0xFF10B981);
  const panelBgColor = Color(0xFF121214);

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
                borderRadius: BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
              ),
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                left: 24,
                right: 24,
                top: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Calificar Servicio',
                    style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Cuéntanos tu experiencia trabajando con ${widget.service.developerName}.',
                    style: TextStyle(color: Colors.grey[400], fontSize: 14),
                  ),
                  const SizedBox(height: 20),
                  
                  // ⭐ selector interactivo de estrellas
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(5, (index) {
                        return IconButton(
                          icon: Icon(
                            Icons.star,
                            size: 36,
                            color: index < selectedRating ? Colors.amber : Colors.grey[700],
                          ),
                          onPressed: () {
                            setModalState(() {
                              selectedRating = index + 1;
                            });
                          },
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // ✍️ Campo de texto para el comentario
                  TextField(
                    controller: commentController,
                    maxLines: 3,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Escribe tu opinión sobre el resultado final...',
                      hintStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
                      filled: true,
                      fillColor: const Color(0xFF080808),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: accentColor)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.white12)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // 🚀 Botones de Acción
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
                        ),
                      ),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accentColor,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () async {
                            // 📡 CONEXIÓN EXPRESS: Llamas a tu ApiService enviando la data
                            final success = await _apiService.addServiceReview(
                              serviceId: widget.service.id,
                              rating: selectedRating,
                              comment: commentController.text,
                            );

                            if (mounted) {
                              Navigator.pop(context); // Cierra el modal
                              if (success) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('¡Reseña publicada con éxito!'), backgroundColor: accentColor),
                                );
                                // Forzamos recarga de la vista para actualizar el promedio y la lista en tiempo real
                                _checkAccessAndOwnership();
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Error al enviar la reseña. Inténtalo de nuevo.'), backgroundColor: Colors.redAccent),
                                );
                              }
                            }
                          },
                          child: const Text('Publicar', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

  void _showSuccessPanel(BuildContext context) {
    const accentColor = Color(0xFF10B981);
    const panelBgColor = Color(0xFF121214);

    showDialog(
      context: context,
      barrierDismissible: false,
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
                  const Text(
                    'Pago Exitoso!',
                    style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Tu proyecto ha sido creado. El freelancer comenzará a trabajar pronto.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[400], fontSize: 16, height: 1.4),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        setState(() {
                          _hasPaid = true; 
                        });
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

  void _showConfirmationPanel(BuildContext context) {
    const accentColor = Color(0xFF10B981);
    const cardColor = Color(0xFF1C1C1E);
    const panelBgColor = Color(0xFF121214);

    
    // POR ESTO:
final double total = widget.service.price.toDouble();

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
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
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
                          'Confirmar Contratación',
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
                      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(20)),
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
                                      _liveRating.toStringAsFixed(1),
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
  decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(20)),
  child: Column(
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Servicio', style: TextStyle(color: Colors.grey[400], fontSize: 15)),
          Text('S/ ${widget.service.price.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500)),
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
            'S/ ${total.toStringAsFixed(2)}',
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
                            : () => _processPayment(context, setModalState), // 🟢 CONECTADO AL FLUJO REAL
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
                                  Spacer(),
                                  Text('Procesando pago...', style: TextStyle(fontSize: 16, color: Colors.grey)),
                                  Spacer(),
                                ],
                              )
                            : Text('Pagar S/ ${total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
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

    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF080808),
        body: Center(child: CircularProgressIndicator(color: accentColor)),
      );
    }

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
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(widget.service.developerName, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                                  const SizedBox(width: 6),
                                  const Icon(Icons.star, color: Colors.amber, size: 16),
                                  Text(
                                    ' ${_liveRating.toStringAsFixed(1)} ($_liveReviewsCount reseñas)', 
                                    style: TextStyle(color: Colors.grey[500], fontSize: 14)
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        if (!_isOwner)
                          IconButton(
                            icon: const Icon(Icons.flag_outlined, color: Colors.grey, size: 20),
                            onPressed: () => _showReportModal(context),
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
                    const Text('Descripción', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Text(widget.service.description, style: TextStyle(color: Colors.grey[400], fontSize: 15, height: 1.5)),
                    const SizedBox(height: 32),
const Divider(color: Colors.white12),
const SizedBox(height: 16),
Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    const Text(
      'Reseñas de clientes', 
      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)
    ),
    if (_hasPaid) // 🔒 Solo si ya compró el servicio
      TextButton.icon(
        onPressed: () => _showReviewModal(context),
        icon: const Icon(Icons.rate_review_outlined, color: accentColor, size: 18),
        label: const Text('Calificar', style: TextStyle(color: accentColor, fontWeight: FontWeight.bold)),
      ),
  ],
),
const SizedBox(height: 16),

// 📣 Si no hay reseñas aún en MongoDB, mostramos un estado vacío amigable
_liveReviewsCount == 0
    ? Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Text(
  'Este servicio aún no cuenta con calificaciones. ¡Sé el primero en contratar!',
  style: TextStyle(color: Colors.grey[500], fontSize: 14, fontStyle: FontStyle.italic),
),
      )
    : FutureBuilder<Map<String, dynamic>>(
        future: _apiService.getServiceReviewsStats(widget.service.id), // Volvemos a consultar para mapear el array completo
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: accentColor));
          }

          final reviewsData = snapshot.data?['reviews'] as List<dynamic>? ?? [];

          if (reviewsData.isEmpty) {
            return Text('No se pudieron cargar los comentarios.', style: TextStyle(color: Colors.grey[600]));
          }

          return ListView.separated(
            shrinkWrap: true, // Crucial para que funcione dentro de un SingleChildScrollView
            physics: const NeverScrollableScrollPhysics(), // Evita conflictos de scroll
            itemCount: reviewsData.length,
            separatorBuilder: (context, index) => const Divider(color: Colors.white12, height: 24),
            itemBuilder: (context, index) {
              final review = reviewsData[index];
              final int rating = review['rating'] ?? 5;
              final String comment = review['comment'] ?? '';
              final String clientName = review['clientName'] ?? 'Cliente Anónimo';
              final String clientAvatar = review['clientAvatar'] ?? '';

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.grey[800],
                        backgroundImage: clientAvatar.isNotEmpty ? NetworkImage(clientAvatar) : null,
                        child: clientAvatar.isEmpty ? const Icon(Icons.person, size: 16, color: Colors.white) : null,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          clientName,
                          style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                      ),
                      // Genera las estrellitas amarillas de la reseña específica
                      Row(
                        children: List.generate(5, (starIndex) {
                          return Icon(
                            Icons.star,
                            size: 14,
                            color: starIndex < rating ? Colors.amber : Colors.grey[700],
                          );
                        }),
                      )
                    ],
                  ),
                  if (comment.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.only(left: 42.0), // Alineado perfectamente abajo del nombre
                      child: Text(
                        comment,
                        style: TextStyle(color: Colors.grey[300], fontSize: 14, height: 1.4),
                      ),
                    ),
                  ],
                ],
              );
            },
          );
        },
      ),
                    const SizedBox(height: 120), 
                  ],
                ),
              ),
            ),
          ),
          
          // --- BARRA FIJA INFERIOR ADAPTATIVA ---
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
                      Text('S/ ${widget.service.price.toStringAsFixed(2)}', style: const TextStyle(color: accentColor, fontSize: 26, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 24.0),
                      child: Builder(
                        builder: (context) {
                          if (_hasPaid) {
                            return ElevatedButton.icon(
                              onPressed: _isStartingChat ? null : _handleStartChat,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: accentColor,
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                              ),
                              icon: _isStartingChat
                                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                                  : const Icon(Icons.chat_bubble_outline, size: 18),
                              label: const Text('Ir al Chat', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                            );
                          } else if (_isOwner) {
                            return ElevatedButton.icon(
                              onPressed: null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1C1C1E),
                                disabledBackgroundColor: const Color(0xFF1C1C1E),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                              ),
                              icon: const Icon(Icons.lock_outline, color: Colors.grey, size: 18),
                              label: const Text('Tu servicio', style: TextStyle(fontSize: 15, color: Colors.grey, fontWeight: FontWeight.bold)),
                            );
                          } else {
                            return ElevatedButton(
                              onPressed: () => _showConfirmationPanel(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: accentColor,
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                              ),
                              child: const Text('Contratar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            );
                          }
                        },
                      ),
                    ),
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