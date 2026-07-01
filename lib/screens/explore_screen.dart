import 'package:flutter/material.dart';
import '../models/service.dart';
import '../widgets/service_card.dart';
import 'package:devmarket_app/data/services/api_service.dart'; 
import '../models/freelancer.dart'; 
import 'package:devmarket_app/widgets/custom_header.dart'; // Asegúrate de que la ruta sea la correcta en tu proyecto

import 'freelancer_detail_screen.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  List<String> _dynamicCategories = []; // 🟢 Nueva lista para categorías reales
  final ApiService _apiService = ApiService();

  bool showFilters = false; 
  String activeTab = 'Servicios'; 

  List<ServiceModel> _allServices = [];
  List<FreelancerModel> _allFreelancers = []; 
  bool _isLoading = true;
  String? _errorMessage;

  List<String> selectedCategories = []; 
  int? minPrice;
  int? maxPrice;
  String sortBy = 'Mas recientes'; 

  final TextEditingController _minPriceController = TextEditingController();
  final TextEditingController _maxPriceController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = '';

  final Map<String, String> _developerIdMap = {};

  @override
  void initState() {
    super.initState();
    _fetchServicesFromBackend();
  }

  @override
  void dispose() {
    _minPriceController.dispose();
    _maxPriceController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchServicesFromBackend() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      dynamic rawData;
      try {
        rawData = await _apiService.getServices();
      } catch (serviceError) {
        throw serviceError.toString().replaceAll('Exception: ', '');
      }

      if (rawData is! List) {
        throw "El backend no devolvió una lista válida.";
      }

      final List<dynamic> rawList = rawData;

      final List<ServiceModel> mappedServices = rawList.map((item) {
        if (item is! Map) return null;
        
        final json = Map<String, dynamic>.from(item);
        
        String serviceId = json['_id']?.toString() ?? json['id']?.toString() ?? UniqueKey().toString();

        String devName = 'Desarrollador';
        String devId = json['userId']?.toString() ?? json['id']?.toString() ?? 'unknown_id';

        if (json['seller'] != null && json['seller'] is Map) {
          final sellerMap = Map<String, dynamic>.from(json['seller'] as Map);
          devName = sellerMap['name']?.toString() ?? devName;
          devId = sellerMap['_id']?.toString() ?? sellerMap['id']?.toString() ?? devId;
        }

        if (devName != 'Desarrollador') {
          _developerIdMap[devName] = devId;
        }

        String categoryName = 'General';
        if (json['category'] != null && json['category'] is Map) {
          final catMap = Map<String, dynamic>.from(json['category'] as Map);
          categoryName = catMap['name']?.toString() ?? 'General';
        }

        final double rawRating = double.tryParse(json['rating']?.toString() ?? '0.0') ?? 0.0;
        final int rawReviews = int.tryParse(json['reviewsCount']?.toString() ?? 
                                           json['totalReviews']?.toString() ?? 
                                           '0') ?? 0;

        return ServiceModel(
          id: serviceId, 
          title: json['title']?.toString() ?? 'Servicio sin título',
          subtitle: json['description']?.toString() ?? 'Sin descripción disponible',
          developerName: devName,
          developerAvatarUrl: 'https://i.pravatar.cc/150?u=$devId', 
          rating: rawRating == 0.0 ? 5.0 : rawRating, 
          reviewsCount: rawReviews,                  
          price: (json['price'] != null) ? (double.tryParse(json['price'].toString())?.round() ?? 0) : 0,
          imageUrl: (json['image'] != null && json['image'].toString().isNotEmpty) 
              ? json['image'].toString() 
              : 'https://images.unsplash.com/photo-1517694712202-14dd9538aa97',
          category: categoryName,
          date: json['createdAt'] != null ? (DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()) : DateTime.now(),
          description: json['description']?.toString() ?? '',
          deliveryTime: '${json['deliveryDays'] ?? 1} días de entrega',
          revisions: 'Revisiones ilimitadas',
        );
      })
      .whereType<ServiceModel>()
      .toList();

      final Map<String, FreelancerModel> uniqueSellers = {};
      for (var service in mappedServices) {
        final sellerKey = service.developerName; 
        final realBackendId = _developerIdMap[sellerKey] ?? sellerKey;

        if (!uniqueSellers.containsKey(sellerKey)) {
          uniqueSellers[sellerKey] = FreelancerModel(
            id: realBackendId, 
            name: service.developerName,
            username: service.developerName.toLowerCase().replaceAll(' ', ''),
            avatarUrl: service.developerAvatarUrl,
            serviceCount: 1,
          );
        } else {
          final current = uniqueSellers[sellerKey]!;
          uniqueSellers[sellerKey] = FreelancerModel(
            id: current.id,
            name: current.name,
            username: current.username,
            avatarUrl: current.avatarUrl,
            serviceCount: current.serviceCount + 1,
          );
        }
      }

      // 🚀 REEMPLÁZALO POR ESTE BLOQUE:
      setState(() {
        _allServices = mappedServices;
        _allFreelancers = uniqueSellers.values.toList();
        
        // 🟢 Extrae categorías únicas mapeadas en tiempo real desde la DB
        _dynamicCategories = mappedServices
            .map((s) => s.category)
            .toSet() // Elimina duplicados automáticamente
            .toList()
          ..sort(); // Las ordena alfabéticamente de la A a la Z
          
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  List<ServiceModel> get _filteredServices {
    List<ServiceModel> services = List.from(_allServices);
    if (searchQuery.isNotEmpty) {
      services = services.where((s) => s.title.toLowerCase().contains(searchQuery.toLowerCase()) || s.subtitle.toLowerCase().contains(searchQuery.toLowerCase())).toList();
    }
    if (selectedCategories.isNotEmpty) {
      services = services.where((s) => selectedCategories.contains(s.category)).toList();
    }
    if (minPrice != null) services = services.where((s) => s.price >= minPrice!).toList();
    if (maxPrice != null) services = services.where((s) => s.price <= maxPrice!).toList();

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

  List<FreelancerModel> get _filteredFreelancers {
    List<FreelancerModel> freelancers = List.from(_allFreelancers);

    if (searchQuery.isNotEmpty) {
      freelancers = freelancers.where((f) => 
        f.name.toLowerCase().contains(searchQuery.toLowerCase()) || 
        f.username.toLowerCase().contains(searchQuery.toLowerCase())
      ).toList();
    }

    freelancers.sort((a, b) => b.serviceCount.compareTo(a.serviceCount));
    return freelancers;
  }

  @override
  Widget build(BuildContext context) {
    const accentColor = Color(0xFF00E676); 
    const panelBgColor = Color(0xFF121214);

    return Scaffold(
      backgroundColor: Colors.black, 
      body: SafeArea(
        child: Column(
          children: [
            // 🚀 INTEGRACIÓN DEL HEADER NUEVO REUTILIZABLE
            const CustomHeader(
              title: 'Explorar',
              subtitle: 'Encuentra el talento perfecto',
            ),
            const SizedBox(height: 16),

            // --- BUSCADOR Y FILTRO ---
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
                        hintText: activeTab == 'Servicios' 
                            ? 'Buscar servicios...' 
                            : 'Busca a un freelancer por su nombre...',
                        hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                        prefixIcon: const Icon(Icons.search, color: Colors.grey, size: 22),
                        filled: true,
                        fillColor: const Color(0xFF121214),
                        contentPadding: const EdgeInsets.symmetric(vertical: 14),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25), 
                          borderSide: const BorderSide(color: Color(0xFF1C1C1E)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25), 
                          borderSide: const BorderSide(color: accentColor, width: 1),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),                  
                  GestureDetector(
                    onTap: () {
                      if (activeTab == 'Servicios') {
                        setState(() => showFilters = !showFilters);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF121214),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF1C1C1E)),
                      ),
                      child: Icon(
                        Icons.tune, 
                        color: activeTab == 'Freelancers' 
                            ? Colors.grey.withValues(alpha: 0.2) 
                            : (showFilters ? accentColor : Colors.grey), 
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // --- SELECTOR DE PESTAÑAS ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(color: const Color(0xFF121214), borderRadius: BorderRadius.circular(30)),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => activeTab = 'Servicios'),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: activeTab == 'Servicios' ? accentColor : Colors.transparent,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Text(
                            'Servicios',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: activeTab == 'Servicios' ? Colors.black : Colors.grey, fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() {
                          activeTab = 'Freelancers';
                          showFilters = false; 
                        }),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: activeTab == 'Freelancers' ? accentColor : Colors.transparent,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Text(
                            'Freelancers',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: activeTab == 'Freelancers' ? Colors.black : Colors.grey, fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),

            // --- PANEL DE FILTROS EXPANDIBLE ---
            if (showFilters && activeTab == 'Servicios')
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: panelBgColor, borderRadius: BorderRadius.circular(24)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Categorías', style: TextStyle(color: Colors.grey, fontSize: 14)),
                    const SizedBox(height: 8),
                    // 🚀 Reemplazo del Wrap por un Scroll Horizontal elegante
SizedBox(
  height: 40, // Altura fija del contenedor de botones
  child: ListView.builder(
    scrollDirection: Axis.horizontal,
    itemCount: _dynamicCategories.length,
    itemBuilder: (context, index) {
      final cat = _dynamicCategories[index];
      final isSelected = selectedCategories.contains(cat);
      return Padding(
        padding: const EdgeInsets.only(right: 8.0), // Espacio entre botones
        child: InkWell(
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF2C2C2E) : const Color(0xFF1C1C1E),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? accentColor : Colors.transparent, 
                width: 1
              ),
            ),
            child: Center(
              child: Text(
                cat, 
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey[400], 
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal
                )
              ),
            ),
          ),
        ),
      );
    },
  ),
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
                              hintText: 'S/. Min',
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
                              hintText: 'S/. Max',
                              hintStyle: const TextStyle(color: Colors.grey),
                              filled: true,
                              fillColor: const Color(0xFF1C1C1E),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 4),

            // --- PANEL DE LISTADO ---
            Expanded(
              child: activeTab == 'Servicios'
                  ? _buildServicesSection()
                  : _buildFreelancersSection(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServicesSection() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF00E676)));
    }

    if (_errorMessage != null) {
      return Center(
        child: Text('Error: $_errorMessage', style: const TextStyle(color: Colors.redAccent)),
      );
    }

    if (_filteredServices.isEmpty) {
      return const Center(child: Text('No hay servicios disponibles.', style: TextStyle(color: Colors.grey)));
    }

    return RefreshIndicator(
      onRefresh: _fetchServicesFromBackend,
      color: const Color(0xFF00E676),
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 16, top: 4),
        itemCount: _filteredServices.length,
        itemBuilder: (context, index) {
          final serviceSelected = _filteredServices[index];
          return ServiceCard(service: serviceSelected);
        },
      ),
    );
  }

  Widget _buildFreelancersSection() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF00E676)));
    }

    if (_filteredFreelancers.isEmpty) {
      return const Center(
        child: Text('No encontramos ningún freelancer.', style: TextStyle(color: Colors.grey)),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchServicesFromBackend,
      color: const Color(0xFF00E676),
      child: GridView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,          
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          mainAxisExtent: 215, 
        ),
        itemCount: _filteredFreelancers.length,
        itemBuilder: (context, index) {
          final freelancer = _filteredFreelancers[index];
          
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FreelancerDetailScreen(
                    freelancer: freelancer,
                    allServices: _allServices,
                  ),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(12), 
              decoration: BoxDecoration(
                color: const Color(0xFF121214),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFF1C1C1E)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: const Color(0xFF1C1C1E),
                    backgroundImage: NetworkImage(freelancer.avatarUrl ?? 'https://i.pravatar.cc/150'),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    freelancer.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '@${freelancer.username}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.grey, fontSize: 11),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1C1C1E),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.work_outline, color: Color(0xFF00E676), size: 12),
                        const SizedBox(width: 4),
                        Text(
                          '${freelancer.serviceCount} ${freelancer.serviceCount == 1 ? 'Servicio' : 'Servicios'}',
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}