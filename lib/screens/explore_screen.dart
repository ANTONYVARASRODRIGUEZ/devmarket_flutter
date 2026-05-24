// lib/screens/explore_screen.dart
import 'package:flutter/material.dart';
import '../models/service.dart';
import '../widgets/service_card.dart';

class ExploreScreen extends StatefulWidget {
  // 📥 RECIBIMOS LOS PARÁMETROS GLOBALES DESDE MAIN.DART
  final bool isFreelancer;
  final ValueChanged<bool> onRoleChanged;

  const ExploreScreen({
    super.key,
    required this.isFreelancer,
    required this.onRoleChanged,
  });

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  // ❌ Se eliminó la variable local "isFreelancer = false" para no duplicar datos
  bool showFilters = false; 

  List<String> selectedCategories = []; 
  int? minPrice;
  int? maxPrice;
  String sortBy = 'Mas recientes'; 

  final TextEditingController _minPriceController = TextEditingController();
  final TextEditingController _maxPriceController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = '';

  final List<ServiceModel> _allServices = [
    ServiceModel(
      title: 'Desarrollo de API REST con Node.js',
      subtitle: 'Backend escalable y seguro',
      developerName: 'Carlos M.',
      developerAvatarUrl: 'https://i.pravatar.cc/150?u=carlos',
      rating: 4.9,
      price: 850,
      imageUrl: 'https://images.unsplash.com/photo-1517694712202-14dd9538aa97',
      category: 'Backend',
      date: DateTime.now().subtract(const Duration(days: 2)),
      description: 'Creación de servicios backend robustos empleando Node.js y Express. Optimización de consultas a bases de datos, seguridad por medio de tokens JWT y despliegue rápido en entornos cloud modernos.',
      deliveryTime: '7 días',
      revisions: '3 revisiones',
    ),
    ServiceModel(
      title: 'App Móvil React Native',
      subtitle: 'iOS y Android desde un solo código',
      developerName: 'Ana R.',
      developerAvatarUrl: 'https://i.pravatar.cc/150?u=ana',
      rating: 5.0,
      price: 1200,
      imageUrl: 'https://images.unsplash.com/photo-1512941937669-90a1b58e7e9c',
      category: 'Mobile',
      date: DateTime.now().subtract(const Duration(days: 5)),
      description: 'Desarrollo móvil híbrido nativo de alto rendimiento para tiendas App Store y Google Play. Configuración de notificaciones push, pasarelas de pago y animaciones fluidas a 60fps.',
      deliveryTime: '14 días',
      revisions: 'Revisiones ilimitadas',
    ),
    ServiceModel(
      title: 'Landing Page Premium',
      subtitle: 'Diseño moderno y conversión alta',
      developerName: 'Miguel S.',
      developerAvatarUrl: 'https://i.pravatar.cc/150?u=miguel',
      rating: 4.8,
      price: 450,
      imageUrl: 'https://images.unsplash.com/photo-1499951360447-b19be8fe80f5',
      category: 'Frontend',
      date: DateTime.now().subtract(const Duration(days: 1)),
      description: 'Landing page optimizada para conversión con diseño premium. Incluye animaciones suaves, optimización SEO, velocidad de carga ultra rápida, formularios de contacto y analytics integrados.',
      deliveryTime: '5 días',
      revisions: 'Revisiones ilimitadas',
    ),
    ServiceModel(
      title: 'Dashboard con Next.js',
      subtitle: 'Panel admin completo y responsive',
      developerName: 'Laura G.',
      developerAvatarUrl: 'https://i.pravatar.cc/150?u=laura',
      rating: 4.7,
      price: 980,
      imageUrl: 'https://images.unsplash.com/photo-1551288049-bebda4e38f71',
      category: 'Fullstack',
      date: DateTime.now().subtract(const Duration(days: 10)),
      description: 'Arquitectura web avanzada con renderizado del lado del servidor (SSR). Gráficos interactivos en tiempo real, gestión de roles de usuario, modo oscuro automático e integración de API de terceros.',
      deliveryTime: '10 días',
      revisions: '5 revisiones',
    ),
    ServiceModel(
      title: 'Integración de Pagos Stripe',
      subtitle: 'Checkout seguro y suscripciones',
      developerName: 'Pedro V.',
      developerAvatarUrl: 'https://i.pravatar.cc/150?u=pedro',
      rating: 4.9,
      price: 350,
      imageUrl: 'https://images.unsplash.com/photo-1563013544-824ae1d704d3',
      category: 'Backend',
      date: DateTime.now().subtract(const Duration(days: 3)),
      description: 'Configuración e implementación completa del ecosistema de Stripe. Soporte para cobros únicos, sistemas recurrentes de membresía, manejo seguro de Webhooks y antifraude (3D Secure).',
      deliveryTime: '3 días',
      revisions: '2 revisiones',
    ),
    ServiceModel(
      title: 'Bot de Discord Personalizado',
      subtitle: 'Automatización y moderación',
      developerName: 'Diego F.',
      developerAvatarUrl: 'https://i.pravatar.cc/150?u=diego',
      rating: 4.6,
      price: 280,
      imageUrl: 'https://images.unsplash.com/photo-1614680376593-902f74fa0d41',
      category: 'Automation',
      date: DateTime.now().subtract(const Duration(days: 12)),
      description: 'Desarrollo de bots interactivos inteligentes utilizando Discord.js / Discord.py. Sistemas de niveles de usuarios, comandos de música premium, moderación automática exhaustiva y juegos integrados.',
      deliveryTime: '4 días',
      revisions: '3 revisiones',
    ),
  ];

  List<ServiceModel> get _filteredServices {
    List<ServiceModel> services = List.from(_allServices);

    if (searchQuery.isNotEmpty) {
      services = services.where((s) => s.title.toLowerCase().contains(searchQuery.toLowerCase()) || s.subtitle.toLowerCase().contains(searchQuery.toLowerCase())).toList();
    }

    if (selectedCategories.isNotEmpty) {
      services = services.where((s) => selectedCategories.contains(s.category)).toList();
    }

    if (minPrice != null) {
      services = services.where((s) => s.price >= minPrice!).toList();
    }
    if (maxPrice != null) {
      services = services.where((s) => s.price <= maxPrice!).toList();
    }

    if (sortBy == 'Mas recientes') {
      services.sort((a, b) => b.date.compareTo(a.date));
    } else if (sortBy == 'Menor precio') {
      services.sort((a, b) => a.price.compareTo(b.price));
    } else if (sortBy == 'Mayor precio') {
      services.sort((a, b) => b.price.compareTo(a.price));
    } else if (sortBy == 'Mejor calificados') {
      services.sort((a, b) => b.rating.compareTo(a.rating));
    }

    return services;
  }

  @override
  Widget build(BuildContext context) {
    const accentColor = Color(0xFF10B981);
    const panelBgColor = Color(0xFF121214);

    return Scaffold(
      backgroundColor: const Color(0xFF080808),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(color: accentColor, shape: BoxShape.circle),
                        child: const Text('DM', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 8),
                      const Text('DevMarket', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Row(
                    children: [
                      // 🔄 REEMPLAZADO CON WIDGET.ISFREELANCER PARA LEER EL ESTADO GLOBAL
                      Text('Cliente', style: TextStyle(color: widget.isFreelancer ? Colors.grey : accentColor, fontSize: 12)),
                      Switch(
                        value: widget.isFreelancer,
                        activeThumbColor: accentColor,
                        activeTrackColor: accentColor.withValues(alpha: 0.3),
                        onChanged: widget.onRoleChanged, // 🎯 LLAMA DIRECTAMENTE AL CAMBIO GLOBAL DE MAIN.DART
                      ),
                      Text('Freelancer', style: TextStyle(color: widget.isFreelancer ? accentColor : Colors.grey, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Explorar Servicios', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                    Text('Encuentra el talento perfecto', style: TextStyle(color: Colors.grey, fontSize: 16)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(color: Colors.white),
                      onChanged: (val) => setState(() => searchQuery = val),
                      decoration: InputDecoration(
                        hintText: 'Buscar desarrolladores y servicios...',
                        hintStyle: const TextStyle(color: Colors.grey),
                        prefixIcon: const Icon(Icons.search, color: Colors.grey),
                        filled: true,
                        fillColor: const Color(0xFF1C1C1E),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => setState(() => showFilters = !showFilters),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: showFilters ? accentColor : const Color(0xFF1C1C1E),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Icon(Icons.tune, color: showFilters ? Colors.black : Colors.grey),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            if (showFilters)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: panelBgColor, borderRadius: BorderRadius.circular(24)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Categorías', style: TextStyle(color: Colors.grey, fontSize: 14)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: ['Frontend', 'Backend', 'Mobile', 'Fullstack', 'Automation'].map((cat) {
                        final isSelected = selectedCategories.contains(cat);
                        return InkWell(
                          onTap: () {
                            setState(() {
                              if (isSelected) {
                                selectedCategories.remove(cat);
                              } else {
                                selectedCategories.add(cat);
                              }
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFF2C2C2E) : const Color(0xFF1C1C1E),
                              borderRadius: BorderRadius.circular(20),
                              border: isSelected ? Border.all(color: accentColor, width: 1) : null,
                            ),
                            child: Text(cat, style: TextStyle(color: isSelected ? Colors.white : Colors.grey[400], fontSize: 13)),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    const Text('Rango de precio', style: TextStyle(color: Colors.grey, fontSize: 14)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _minPriceController,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(color: Colors.white),
                            onChanged: (val) => setState(() => minPrice = int.tryParse(val)),
                            decoration: InputDecoration(
                              hintText: '\$ Min',
                              hintStyle: const TextStyle(color: Colors.grey),
                              filled: true,
                              fillColor: const Color(0xFF1C1C1E),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            ),
                          ),
                        ),
                        const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('-', style: TextStyle(color: Colors.grey))),
                        Expanded(
                          child: TextField(
                            controller: _maxPriceController,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(color: Colors.white),
                            onChanged: (val) => setState(() => maxPrice = int.tryParse(val)),
                            decoration: InputDecoration(
                              hintText: '\$ Max',
                              hintStyle: const TextStyle(color: Colors.grey),
                              filled: true,
                              fillColor: const Color(0xFF1C1C1E),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text('Ordenar por', style: TextStyle(color: Colors.grey, fontSize: 14)),
                    const SizedBox(height: 8),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      childAspectRatio: 3,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      children: ['Mas recientes', 'Menor precio', 'Mayor precio', 'Mejor calificados'].map((opt) {
                        final isSelected = sortBy == opt;
                        return InkWell(
                          onTap: () => setState(() => sortBy = opt),
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isSelected ? accentColor : const Color(0xFF1C1C1E),
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Text(opt, style: TextStyle(color: isSelected ? Colors.black : Colors.white, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, fontSize: 13)),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 4),
            Expanded(
              child: _filteredServices.isEmpty
                  ? const Center(child: Text('No hay servicios que coincidan', style: TextStyle(color: Colors.grey)))
                  : ListView.builder(
                      itemCount: _filteredServices.length,
                      itemBuilder: (context, index) {
                        return ServiceCard(service: _filteredServices[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}