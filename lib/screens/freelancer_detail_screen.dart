import 'package:flutter/material.dart';
import '../models/freelancer.dart';
import '../models/service.dart';
import '../widgets/service_card.dart';
import '../data/services/api_service.dart';

class FreelancerDetailScreen extends StatefulWidget {
  final FreelancerModel freelancer;
  final List<ServiceModel> allServices;

  const FreelancerDetailScreen({
    super.key,
    required this.freelancer,
    required this.allServices,
  });

  @override
  State<FreelancerDetailScreen> createState() => _FreelancerDetailScreenState();
}

class _FreelancerDetailScreenState extends State<FreelancerDetailScreen> {
  // Variables dinámicas mapeadas con MongoDB y tu Web
  String location = "Cargando...";
  String bio = "Sincronizando biografía con la web...";
  String professionalTitle = "Freelancer Profesional";
  List<String> skills = [];
  int completedOrders = 0;
  
  // Estadísticas calculadas en tiempo real de MongoDB
  double averageRating = 0.0;
  int totalReviews = 0;
  List<dynamic> realReviewsList = []; 

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRealProfileAndReviews();
  }

  /// 🚀 SINCRONIZACIÓN TOTAL CON DEVMARKET WEB
  Future<void> _fetchRealProfileAndReviews() async {
    try {
      final api = ApiService();
      
      // 1. Obtener Perfil del Freelancer (Bio, Habilidades, Ubicación, Proyectos)
      final profileData = await api.getFreelancerProfile(widget.freelancer.id);
      
      if (profileData != null && mounted) {
        setState(() {
          location = profileData['location'] ?? 'No especificada';
          bio = profileData['bio'] ?? 'Este freelancer aún no ha escrito su biografía.';
          professionalTitle = profileData['professionalTitle'] ?? 'Freelancer Profesional';
          completedOrders = profileData['completedOrders'] ?? 0;

          if (profileData['skills'] != null) {
            skills = List<String>.from(profileData['skills']);
          } else {
            skills = [];
          }
        });
      }

      // 2. Filtrar servicios en la app
      // NOTA: Para máxima precisión, se recomienda usar ids si tu modelo en Flutter lo soporta:
      // s.developerId == widget.freelancer.id
      final myServices = widget.allServices
          .where((s) => s.developerName == widget.freelancer.name) 
          .toList();

      // 3. Obtener e integrar Reseñas en tiempo real (Equivalente al Promise.all de Next.js)
      int calculatedTotal = 0;
      double ratingSum = 0.0;
      List<dynamic> tempReviews = [];

      for (var service in myServices) {
        // Consumimos el método de tu ApiService actual
        final reviewData = await api.getServiceReviewsStats(service.id);
        
        if (reviewData.isNotEmpty) {
          final List<dynamic> reviews = reviewData['reviews'] ?? [];
          final Map<String, dynamic> stats = reviewData['stats'] ?? {};
          
          // Sumamos el total de reseñas de este servicio particular
          int serviceTotalReviews = stats['total'] ?? reviews.length;
          calculatedTotal += serviceTotalReviews;
          
          // Procesamos cada review individual para la lista inferior de la UI
          for (var r in reviews) {
            ratingSum += (r['rating'] ?? 0).toDouble();
            tempReviews.add({
              ...r,
              'serviceTitle': service.title, // Inyectamos el título para saber de qué servicio hablan
            });
          }
        }
      }

      if (mounted) {
        setState(() {
          totalReviews = calculatedTotal;
          // Evitamos división entre cero si no tiene reseñas
          averageRating = calculatedTotal > 0 ? (ratingSum / tempReviews.length) : 0.0;
          realReviewsList = tempReviews;
          isLoading = false;
        });
      }

    } catch (e) {
      print("⚠️ Error sincronizando datos con DevMarket Web: $e");
      _useFallbackData();
    }
  }

  void _useFallbackData() {
    if (mounted) {
      setState(() {
        location = "No disponible";
        bio = "No se pudo sincronizar la descripción en tiempo real con la web.";
        skills = ['Developer'];
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const accentColor = Color(0xFF00E676);
    const cardBgColor = Color(0xFF121214);
    const backgroundColor = Color(0xFF0A0A0A);

    // Filtrado de servicios para la sección intermedia de la UI
    final freelancerServices = widget.allServices
        .where((service) => service.developerName == widget.freelancer.name)
        .toList();

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '@${widget.freelancer.username}',
          style: const TextStyle(color: Colors.grey, fontSize: 15, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: isLoading 
        ? const Center(child: CircularProgressIndicator(color: accentColor))
        : SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                
                // --- TARJETA DE PERFIL (DISEÑO WEB ADAPTADO) ---
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: cardBgColor,
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(color: const Color(0xFF1C1C1E)),
                  ),
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 54,
                            backgroundColor: const Color(0xFF1C1C1E),
                            backgroundImage: NetworkImage(widget.freelancer.avatarUrl ?? 'https://ui-avatars.com/api/?name=${widget.freelancer.name}&background=0a0a0a&color=00e676'),
                          ),
                          Positioned(
                            bottom: 4,
                            right: 4,
                            child: Container(
                              width: 18,
                              height: 18,
                              decoration: BoxDecoration(
                                color: accentColor,
                                shape: BoxShape.circle,
                                border: Border.all(color: cardBgColor, width: 3),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      Text(
                        widget.freelancer.name,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        professionalTitle.toUpperCase(),
                        style: const TextStyle(color: accentColor, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                      ),
                      const SizedBox(height: 20),
                      
                      const Divider(color: Color(0xFF1C1C1E), height: 1),
                      const SizedBox(height: 16),

                      // Estadísticas Reales unificadas de MongoDB
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.star, color: accentColor, size: 18),
                                  const SizedBox(width: 4),
                                  Text(
                                    averageRating.toStringAsFixed(1),
                                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text('RESEÑAS ($totalReviews)', style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          Container(width: 1, height: 30, color: const Color(0xFF1C1C1E)),
                          Column(
                            children: [
                              Text(
                                '$completedOrders', 
                                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900),
                              ),
                              const SizedBox(height: 2),
                              const Text('PROYECTOS', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(color: Color(0xFF1C1C1E), height: 1),
                      const SizedBox(height: 16),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.location_on_outlined, color: Colors.grey, size: 16),
                              SizedBox(width: 6),
                              Text('Ubicación', style: TextStyle(color: Colors.grey, fontSize: 13)),
                            ],
                          ),
                          Text(location, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // --- SECCIÓN SOBRE MÍ ---
                const Text('Sobre mí', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: cardBgColor,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFF1C1C1E)),
                  ),
                  child: Text(bio, style: const TextStyle(color: Color(0xFFE5E5EA), fontSize: 14, height: 1.5)),
                ),
                const SizedBox(height: 24),

                // --- SECCIÓN HABILIDADES ---
                if (skills.isNotEmpty) ...[
                  const Row(
                    children: [
                      Icon(Icons.terminal, color: accentColor, size: 20),
                      SizedBox(width: 8),
                      Text('Habilidades', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: skills.map((skill) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: cardBgColor,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFF1C1C1E)),
                        ),
                        child: Text(
                          skill,
                          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 28),
                ],

                // --- SERVICIOS PUBLICADOS ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Servicios disponibles', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1C1C1E),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${freelancerServices.length} Activos',
                        style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                freelancerServices.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24.0),
                        child: Center(
                          child: Text('Este freelancer no tiene servicios activos.', style: TextStyle(color: Colors.grey)),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(), 
                        itemCount: freelancerServices.length,
                        itemBuilder: (context, index) {
                          final service = freelancerServices[index];
                          return ServiceCard(service: service);
                        },
                      ),
                const SizedBox(height: 24),

                // --- SECCIÓN: LO QUE DICEN LOS CLIENTES (RESEÑAS REALES DE TU WEB) ---
                if (realReviewsList.isNotEmpty) ...[
                  const Row(
                    children: [
                      Icon(Icons.chat_bubble_outline, color: accentColor, size: 20),
                      SizedBox(width: 8),
                      Text('Lo que dicen los clientes', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: realReviewsList.length,
                    itemBuilder: (context, index) {
                      final review = realReviewsList[index];
                      final int rating = review['rating'] ?? 5;
                      
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: cardBgColor,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFF1C1C1E)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  review['clientName'] ?? 'Cliente Anónimo',
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                                ),
                                Row(
                                  children: List.generate(5, (starIndex) {
                                    return Icon(
                                      Icons.star,
                                      size: 14,
                                      color: starIndex < rating ? accentColor : const Color(0xFF2C2C2E),
                                    );
                                  }),
                                )
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Servicio: ${review['serviceTitle'] ?? 'Desarrollo'}",
                              style: const TextStyle(color: accentColor, fontSize: 11, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              review['comment'] ?? '',
                              style: const TextStyle(color: Color(0xFFD1D1D6), fontSize: 13, height: 1.4),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
    );
  }
}