import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:devmarket_app/data/services/api_service.dart';
import 'package:devmarket_app/widgets/custom_header.dart';

class FreelancerProjectsScreen extends StatefulWidget {
  const FreelancerProjectsScreen({super.key});

  @override
  State<FreelancerProjectsScreen> createState() => _FreelancerProjectsScreenState();
}

class _FreelancerProjectsScreenState extends State<FreelancerProjectsScreen> {
  final ApiService _apiService = ApiService();

  bool _isLoading = true;
  String _activeTab = 'TODOS'; 
  
  List<dynamic> _allOrders = [];
  String? _isUpdatingOrderId; 

  @override
  void initState() {
    super.initState();
    _fetchReceivedOrders();
  }

  /// 🔄 Carga los pedidos reales desde el Backend
  Future<void> _fetchReceivedOrders() async {
    try {
      if (!mounted) return;
      setState(() => _isLoading = true);
      
      final data = await _apiService.getReceivedOrders();
      
      if (mounted) {
        setState(() {
          _allOrders = data ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("🚨 Error cargando proyectos: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// 📈 Lógica exacta de Fases (0% -> 25% -> 50% -> 75% -> 100%)
  Future<void> _handleProgressStep(String orderId, int currentProgress) async {
    if (_isUpdatingOrderId != null) return; 

    setState(() => _isUpdatingOrderId = orderId);

    try {
      int nextProgress = 25;
      if (currentProgress == 0) {
        nextProgress = 25;
      } else if (currentProgress == 25) {
        nextProgress = 50;
      } else if (currentProgress == 50) {
        nextProgress = 75;
      } else if (currentProgress == 75) {
        nextProgress = 100;
      }

      await _apiService.updateProgress(orderId, nextProgress);
      await _fetchReceivedOrders();
    } catch (e) {
      debugPrint("🚨 Error al avanzar progreso: $e");
    } finally {
      if (mounted) setState(() => _isUpdatingOrderId = null);
    }
  }

  /// 🎨 Mapeo de estilos visuales idénticos a la Web
  Map<String, dynamic> _getButtonState(int progress) {
    if (progress == 0) {
      return {
        'text': 'Iniciar Trabajo',
        'color': const Color(0xFF1F1F22),
        'textColor': Colors.white,
        'icon': LucideIcons.clock,
      };
    }
    if (progress == 25) {
      return {
        'text': 'Avanzar a 50%',
        'color': const Color(0xFF3B82F6).withAlpha(25),
        'textColor': const Color(0xFF60A5FA),
        'icon': LucideIcons.arrowRight,
      };
    }
    if (progress == 50) {
      return {
        'text': 'Avanzar a 75%',
        'color': const Color(0xFFA855F7).withAlpha(25),
        'textColor': const Color(0xFFC084FC),
        'icon': LucideIcons.arrowRight,
      };
    }
    if (progress == 75) {
      return {
        'text': 'Entregar Proyecto',
        'color': const Color(0xFF00E676),
        'textColor': Colors.black,
        'icon': LucideIcons.package,
      };
    }
    return {
      'text': 'Completado',
      'color': const Color(0xFF00E676).withAlpha(25),
      'textColor': const Color(0xFF00E676),
      'icon': LucideIcons.checkCircle2,
    };
  }

  String _getInitials(String name) {
    if (name.isEmpty) return 'US';
    final parts = name.trim().split(' ');
    if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
    return name.substring(0, name.length >= 2 ? 2 : name.length).toUpperCase();
  }

  String _formatMoney(double amount) {
    return amount.toStringAsFixed(2).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  double _parsePrice(dynamic priceRaw) {
    if (priceRaw == null) return 0.0;
    if (priceRaw is num) return priceRaw.toDouble();
    return double.tryParse(priceRaw.toString()) ?? 0.0;
  }

  @override
  Widget build(BuildContext context) {
    const bgDark = Color(0xFF0C0C0E);
    const cardColor = Color(0xFF121214);
    const primaryColor = Color(0xFF00E676);
    const borderColor = Color(0xFF27272A);

    final filteredOrders = _allOrders.where((order) {
      final progress = order['progress'] ?? 0;
      if (_activeTab == 'ACTIVOS') return progress < 100;
      if (_activeTab == 'COMPLETADOS') return progress == 100;
      return true;
    }).toList();

    final double totalActivos = _allOrders.where((o) => (o['progress'] ?? 0) < 100).fold(0.0, (sum, o) {
      return sum + _parsePrice(o['price']);
    });

    return Scaffold(
      backgroundColor: bgDark,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchReceivedOrders,
          color: primaryColor,
          backgroundColor: cardColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CustomHeader(
                title: 'Pedidos recibidos',
                subtitle: 'Gestiona los proyectos de tus clientes.',
              ),

              // Tarjeta Ingresos Activos
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardColor,
                    border: Border.all(color: primaryColor.withAlpha(76)),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'INGRESO ACTIVO (EN CURSO)',
                        style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.1),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'S/ ${_formatMoney(totalActivos)}',
                        style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                ),
              ),

              // Selector de Pestañas (Estilo Web)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor.withAlpha(153)),
                  ),
                  child: Row(
                    children: ['TODOS', 'ACTIVOS', 'COMPLETADOS'].map((tab) {
                      final isSelected = _activeTab == tab;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _activeTab = tab),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFF1F1F22) : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              tab,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.grey,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

              // Listado Principal
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(primaryColor)))
                    : filteredOrders.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              SizedBox(height: MediaQuery.of(context).size.height * 0.15),
                              const Icon(LucideIcons.package, color: borderColor, size: 54),
                              const SizedBox(height: 12),
                              const Text(
                                'No tienes pedidos en esta categoría.',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                            ],
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 24),
                            itemCount: filteredOrders.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 14),
                            itemBuilder: (context, index) {
                              final order = filteredOrders[index];
                              final String orderId = order['id']?.toString() ?? '';
                              final int progress = order['progress'] ?? 0;
                              final bool isCompleted = progress == 100;
                              final double price = _parsePrice(order['price']);
                              
                              final serviceTitle = order['service']?['title'] ?? 'Servicio Personalizado';
                              final clientName = order['client']?['name'] ?? 'Cliente';
                              final clientUsername = order['client']?['username'] ?? 'Usuario';

                              final btnState = _getButtonState(progress);
                              final isThisUpdating = _isUpdatingOrderId == orderId;

                              return Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: cardColor,
                                  borderRadius: BorderRadius.circular(28),
                                  border: Border.all(color: borderColor),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 48,
                                          height: 48,
                                          decoration: BoxDecoration(
                                            color: isCompleted ? primaryColor.withAlpha(38) : const Color(0xFF1A1A1C),
                                            shape: BoxShape.circle,
                                            border: Border.all(color: isCompleted ? primaryColor.withAlpha(76) : borderColor),
                                          ),
                                          child: Center(
                                            child: isCompleted 
                                                ? const Icon(LucideIcons.checkCircle2, color: primaryColor, size: 20)
                                                : Text(_getInitials(clientName), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                                          ),
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                isCompleted ? 'PROYECTO FINALIZADO' : 'EN CURSO',
                                                style: TextStyle(color: isCompleted ? primaryColor : Colors.blueAccent, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                serviceTitle,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                'Cliente: $clientUsername',
                                                style: const TextStyle(color: Colors.grey, fontSize: 13),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 18),
                                    
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text('Progreso', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
                                        Text('$progress%', style: TextStyle(color: isCompleted ? primaryColor : Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    
                                    // 🟢 CORREGIDO: Barra de progreso con LayoutBuilder dinámico y seguro
                                    Container(
                                      width: double.infinity,
                                      height: 8,
                                      decoration: BoxDecoration(color: const Color(0xFF1C1C1E), borderRadius: BorderRadius.circular(4)),
                                      child: LayoutBuilder(
                                        builder: (context, constraints) {
                                          return Row(
                                            children: [
                                              AnimatedContainer(
                                                duration: const Duration(milliseconds: 600),
                                                curve: Curves.easeOutCubic,
                                                width: constraints.maxWidth * (progress / 100),
                                                height: 8,
                                                decoration: BoxDecoration(
                                                  color: isCompleted ? primaryColor : Colors.blueAccent,
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      ),
                                    ),

                                    const SizedBox(height: 20),

                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text('MONTO', style: TextStyle(color: Colors.grey, fontSize: 9, fontWeight: FontWeight.bold)),
                                            Text('S/ ${_formatMoney(price)}', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            IconButton(
                                              onPressed: () {},
                                              icon: const Icon(LucideIcons.messageSquare, size: 18, color: Colors.grey),
                                              style: IconButton.styleFrom(
                                                backgroundColor: const Color(0xFF0C0C0E),
                                                padding: const EdgeInsets.all(12),
                                                side: const BorderSide(color: borderColor),
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            SizedBox(
                                              width: 145, 
                                              child: ElevatedButton(
                                                onPressed: (isCompleted || _isUpdatingOrderId != null)
                                                    ? null 
                                                    : () => _handleProgressStep(orderId, progress),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: btnState['color'],
                                                  foregroundColor: btnState['textColor'],
                                                  disabledBackgroundColor: btnState['color'],
                                                  disabledForegroundColor: btnState['textColor'],
                                                  elevation: 0,
                                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                                ),
                                                child: isThisUpdating
                                                    ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                                    : Row(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                          Text(btnState['text'], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                                          const SizedBox(width: 4),
                                                          Icon(btnState['icon'], size: 14),
                                                        ],
                                                      ),
                                              ),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}