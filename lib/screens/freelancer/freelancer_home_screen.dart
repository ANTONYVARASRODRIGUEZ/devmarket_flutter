import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../data/services/api_service.dart'; // Ajusta la ruta según tu proyecto
import 'package:devmarket_app/widgets/custom_header.dart'; // 👈 Import de tu componente

class SellerDashboardPage extends StatefulWidget {
  const SellerDashboardPage({super.key});

  @override
  State<SellerDashboardPage> createState() => _SellerDashboardPageState();
}

class _SellerDashboardPageState extends State<SellerDashboardPage> {
  final ApiService _apiService = ApiService();
  
  bool _isLoading = true;
  String _userName = 'Freelancer';
  
  double _earnings = 0.0;
  int _activeOrdersCount = 0;
  double _averageRating = 0.0;
  int _totalReviews = 0;
  List<dynamic> _recentOrders = [];

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    try {
      setState(() => _isLoading = true);

      // 1. Intentar obtener el ID del usuario actual para su perfil/nombre
      final userId = await _apiService.getUserId();
      if (userId != null) {
        final profile = await _apiService.getFreelancerProfile(userId);
        if (profile != null) {
          setState(() {
            _userName = profile['name'] ?? profile['username'] ?? 'Freelancer';
          });
        }
      }

      // 2. Disparar las peticiones HTTP del Dashboard en paralelo (eficiencia pura)
      final results = await Future.wait([
        _apiService.getEarningsSummary(),
        _apiService.getReceivedOrders(),
        _apiService.getMyServices(),
      ]);

      final earningsData = results[0] as Map<String, dynamic>;
      final allOrders = results[1] as List<dynamic>;
      final myServices = results[2] as List<dynamic>;

      // 3. Filtrar pedidos activos (Progreso < 100 y que no estén CANCELLED)
      final activeOrders = allOrders.where((order) {
        final progress = order['progress'] ?? 0;
        final status = order['status'] ?? '';
        return progress < 100 && status != 'CANCELLED';
      }).toList();

      // 4. Calcular calificación global (Fórmula idéntica a tu Web)
      double totalStars = 0.0;
      int totalReviewsCount = 0;

      for (var service in myServices) {
        final reviewsCount = service['reviewsCount'] ?? 0;
        final averageRating = (service['averageRating'] ?? 0.0).toDouble();

        if (reviewsCount > 0) {
          totalStars += (averageRating * reviewsCount);
          totalReviewsCount += reviewsCount as int;
        }
      }

      final globalRating = totalReviewsCount > 0 ? (totalStars / totalReviewsCount) : 0.0;

      setState(() {
        _earnings = (earningsData['total'] ?? 0.0).toDouble();
        _activeOrdersCount = activeOrders.length;
        _averageRating = globalRating;
        _totalReviews = totalReviewsCount;
        _recentOrders = allOrders.take(4).toList();
        _isLoading = false;
      });

    } catch (e) {
      debugPrint("🚨 Error cargando el dashboard de Flutter: $e");
      setState(() => _isLoading = false);
    }
  }

  String _formatMoney(double amount) {
    return amount.toStringAsFixed(2).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFF0C0C0E);
    const cardColor = Color(0xFF121214);
    const borderColor = Color(0xFF27272A); // zinc-800
    const primaryColor = Color(0xFF00E676); // Verde brillante

    if (_isLoading) {
      return const Scaffold(
        backgroundColor: backgroundColor,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadDashboardData,
          color: primaryColor,
          backgroundColor: cardColor,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 12.0), // Ajustado para el padding interno de CustomHeader
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                
                // 🟢 REEMPLAZADO: Tu CustomHeader dinámico con detector de roles y sockets
                CustomHeader(
                  title: 'Panel de vendedor',
                  subtitle: 'Bienvenido de nuevo, $_userName.',
                ),

                const SizedBox(height: 12),

                // TARJETAS / INDICADORES SUPERIORES
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      _buildStatCard(
                        title: 'GANANCIAS TOTALES',
                        value: 'S/ ${_formatMoney(_earnings)}',
                        subtitle: 'Calculado de ventas reales',
                        subtitleColor: primaryColor,
                        icon: LucideIcons.dollarSign,
                        cardColor: cardColor,
                        borderColor: borderColor,
                      ),
                      const SizedBox(height: 12),
                      _buildStatCard(
                        title: 'PEDIDOS ACTIVOS',
                        value: '$_activeOrdersCount',
                        subtitle: 'En progreso actualmente',
                        subtitleColor: Colors.blueAccent,
                        icon: LucideIcons.briefcase,
                        cardColor: cardColor,
                        borderColor: borderColor,
                      ),
                      const SizedBox(height: 12),
                      _buildStatCard(
                        title: 'CALIFICACIÓN GLOBAL',
                        value: _averageRating > 0 ? _averageRating.toStringAsFixed(1) : '0.0',
                        subtitle: 'Basado en $_totalReviews reseñas reales',
                        subtitleColor: Colors.grey,
                        icon: LucideIcons.star,
                        cardColor: cardColor,
                        borderColor: borderColor,
                      ),
                      const SizedBox(height: 28),

                      // SECCIÓN: PEDIDOS RECIENTES
                      Container(
                        decoration: BoxDecoration(
                          color: cardColor,
                          border: Border.all(color: borderColor.withValues(alpha: 0.8)),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Pedidos recientes',
                                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(height: 2),
                                      Text(
                                        'Gestiona tus proyectos actuales',
                                        style: TextStyle(color: Colors.grey, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      // TODO: Navegar a pantalla completa de pedidos recibidos
                                    },
                                    child: const Row(
                                      children: [
                                        Text('Ver todos ', style: TextStyle(color: Colors.grey, fontSize: 12)),
                                        Icon(LucideIcons.arrowRight, color: Colors.grey, size: 14),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                            const Divider(color: borderColor, height: 1),
                            
                            // LISTADO DE PEDIDOS O ESTADO VACÍO
                            if (_recentOrders.isEmpty)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 40.0),
                                child: Center(
                                  child: Column(
                                    children: [
                                      Icon(LucideIcons.package, color: borderColor, size: 48),
                                      SizedBox(height: 12),
                                      Text(
                                        'Aún no tienes pedidos.',
                                        style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 14),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            else
                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                padding: const EdgeInsets.all(16),
                                itemCount: _recentOrders.length,
                                separatorBuilder: (_, __) => const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  final order = _recentOrders[index];
                                  final isFinished = (order['progress'] ?? 0) == 100;
                                  final serviceTitle = order['service']?['title'] ?? 'Servicio Contratado';
                                  final clientName = order['client']?['name'] ?? order['client']?['username'] ?? 'Cliente';
                                  final double price = (order['price'] ?? 0.0).toDouble();

                                  return Container(
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF0A0A0A),
                                      border: Border.all(color: borderColor),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 44,
                                          height: 44,
                                          decoration: BoxDecoration(
                                            color: isFinished ? primaryColor.withValues(alpha: 0.1) : Colors.blue.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(
                                              color: isFinished ? primaryColor.withValues(alpha: 0.2) : Colors.blue.withValues(alpha: 0.2),
                                            ),
                                          ),
                                          child: Icon(
                                            isFinished ? LucideIcons.checkCircle2 : LucideIcons.clock,
                                            color: isFinished ? primaryColor : Colors.blueAccent,
                                            size: 20,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                serviceTitle,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                'Cliente: $clientName',
                                                style: const TextStyle(color: Colors.grey, fontSize: 11),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              'S/ ${_formatMoney(price)}',
                                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 15),
                                            ),
                                            const SizedBox(height: 4),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: isFinished ? primaryColor.withValues(alpha: 0.1) : Colors.blue.withValues(alpha: 0.1),
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                isFinished ? 'COMPLETADO' : 'EN PROCESO',
                                                style: TextStyle(
                                                  color: isFinished ? primaryColor : Colors.blueAccent,
                                                  fontSize: 8,
                                                  fontWeight: FontWeight.w900,
                                                ),
                                              ),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  );
                                },
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required Color subtitleColor,
    required IconData icon,
    required Color cardColor,
    required Color borderColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        border: Border.all(color: borderColor.withValues(alpha: 0.8)),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(color: subtitleColor, fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          Icon(icon, color: Colors.grey.withValues(alpha: 0.4), size: 24),
        ],
      ),
    );
  }
}