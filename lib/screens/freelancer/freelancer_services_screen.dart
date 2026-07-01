import 'package:flutter/material.dart';
import '../../../data/services/api_service.dart';
import '../../widgets/custom_header.dart';

class FreelancerServicesScreen extends StatefulWidget {
  const FreelancerServicesScreen({super.key});

  @override
  State<FreelancerServicesScreen> createState() => _FreelancerServicesScreenState();
}

class _FreelancerServicesScreenState extends State<FreelancerServicesScreen> {
  final ApiService _apiService = ApiService();

  bool _isLoading = true;
  List<dynamic> _myServices = [];
  Map<String, dynamic>? _subscriptionData;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  /// 🔄 Carga reactiva unificada usando los endpoints reales de Express
  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        _apiService.getMyServices(),
        _apiService.getMyPlanDetails(), // 👈 Trae el plan real desde Prisma
      ]);

      setState(() {
        _myServices = results[0] as List<dynamic>;
        _subscriptionData = results[1] as Map<String, dynamic>?;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showCustomToast('Error al sincronizar datos con el servidor', isError: true);
    }
  }

  Future<void> _handleDeleteService(String serviceId) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF121214),
        title: const Text('¿Eliminar servicio?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text('Esta acción eliminará de forma permanente el servicio en tu base de datos.', style: TextStyle(color: Colors.grey)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar', style: TextStyle(color: Colors.grey))),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Eliminar', style: TextStyle(color: Colors.redAccent))),
        ],
      ),
    );

    if (confirm == true) {
      final success = await _apiService.deleteService(serviceId);
      if (success) {
        _showCustomToast('Servicio eliminado correctamente');
        _loadDashboardData();
      } else {
        _showCustomToast('Error al eliminar servicio', isError: true);
      }
    }
  }

  void _showCustomToast(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: isError ? Colors.redAccent : const Color(0xFF00E676),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _openCreateServiceModal() {
    int currentCount = _myServices.length;
    int maxLimit = _subscriptionData?['limits']?['maxServices'] ?? 5; // Default de tu enum FREE

    // Validación estricta basada en la lógica de tu 'canCreateService' del Backend
    if (currentCount >= maxLimit) {
      _showCustomToast('Límite excedido. Tu plan actual solo permite un máximo de $maxLimit servicios.', isError: true);
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF121214),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: _ServiceFormModal(
            title: 'Crear Nuevo Servicio',
            onSave: (formData) async => await _apiService.createService(formData),
          ),
        );
      },
    ).then((value) {
      if (value == true) _loadDashboardData();
    });
  }

  void _openEditServiceModal(Map<String, dynamic> service) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF121214),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: _ServiceFormModal(
            title: 'Editar Servicio',
            service: service,
            onSave: (formData) async {
              final String serviceId = service['id'].toString();
              return await _apiService.updateService(serviceId, formData);
            },
          ),
        );
      },
    ).then((value) {
      if (value == true) _loadDashboardData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      // 🟢 Eliminamos el appBar e introducimos SafeArea en el body
      body: SafeArea( 
        child: RefreshIndicator(
        onRefresh: _loadDashboardData,
        color: const Color(0xFF00E676),
        backgroundColor: const Color(0xFF121214),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF00E676)))
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 🟢 Agregamos tu CustomHeader al inicio de la lista
                    const CustomHeader(
                      title: 'Mis Servicios',
                      subtitle: 'Gestiona tu catálogo y ofertas activas',
                    ),
                    const SizedBox(height: 16),
                    
                    _buildStatsGrid(),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Catálogo Activo', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        ElevatedButton.icon(
                          onPressed: _openCreateServiceModal,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00E676),
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          ),
                          icon: const Icon(Icons.add, size: 18, fontWeight: FontWeight.bold),
                          label: const Text('Crear Nuevo', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _myServices.isEmpty ? _buildEmptyState() : _buildServicesList(),
                  ],
                ),
              ),
        ),
      ), // 👈 Cierre del SafeArea
    );
  }

  Widget _buildStatsGrid() {
    final int currentCount = _myServices.length;
    
    // Extrae de forma dinámica los campos que envía tu 'subscriptionService.ts'
    final String userTier = _subscriptionData?['tier']?.toString() ?? 'FREE';
    final int maxServices = _subscriptionData?['limits']?['maxServices'] ?? 5;

    Color tierColor = Colors.grey;
    if (userTier == 'PRO') tierColor = Colors.blueAccent;
    if (userTier == 'ELITE') tierColor = Colors.amber;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard('Servicios Activos', '$currentCount / $maxServices', Icons.work_outline, const Color(0xFF00E676)),
        _buildStatCard('Plan de Cuenta', userTier, Icons.star_border, tierColor),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color accentColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF121214),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF27272A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(color: Colors.grey, fontSize: 13)),
              Icon(icon, color: accentColor, size: 20),
            ],
          ),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
      decoration: BoxDecoration(color: const Color(0xFF121214), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFF27272A))),
      child: Column(
        children: [
          Icon(Icons.assignment_late_outlined, size: 64, color: Colors.grey.shade700),
          const SizedBox(height: 16),
          const Text('No hay servicios en tu catálogo', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildServicesList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _myServices.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final service = _myServices[index] as Map<String, dynamic>;
        final categoryMap = service['category'];
        final String categoryName = categoryMap is Map ? (categoryMap['name'] ?? 'General') : 'General';
        final bool isPublished = service['isPublished'] ?? true;

        return Container(
          decoration: BoxDecoration(color: const Color(0xFF121214), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF27272A))),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 52,
                height: 52,
                color: const Color(0xFF1E1E22),
                // ANTES: errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, color: Colors.grey)
// CAMBIALO POR:
child: service['image'] != null && service['image'].toString().isNotEmpty
    ? Image.network(
        service['image'], 
        fit: BoxFit.cover, 
        errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, color: Colors.grey), // 👈 Más limpio así
      )
    : const Icon(Icons.image, color: Colors.grey),
              ),
            ),
            title: Text(service['title'] ?? 'Sin título', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(color: const Color(0xFF1E1E22), borderRadius: BorderRadius.circular(6)),
                    child: Text(categoryName, style: const TextStyle(color: Colors.grey, fontSize: 11)),
                  ),
                  const SizedBox(width: 8),
                  Text('S/ ${(service['price'] ?? 0)}', style: const TextStyle(color: Color(0xFF00E676), fontWeight: FontWeight.bold)),
                  const SizedBox(width: 8),
                  Icon(Icons.circle, size: 8, color: isPublished ? const Color(0xFF00E676) : Colors.orangeAccent),
                ],
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(icon: const Icon(Icons.edit_outlined, color: Colors.grey, size: 22), onPressed: () => _openEditServiceModal(service)),
                IconButton(icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 22), onPressed: () => _handleDeleteService(service['id'].toString())),
              ],
            ),
          ),
        );
      },
    );
  }
}

// =========================================================================
// 🛠️ WIDGET MODAL CONTROLADO CON CARGA DE CATEGORÍAS REALES DESDE EL BACKEND
// =========================================================================

class _ServiceFormModal extends StatefulWidget {
  final String title;
  final Map<String, dynamic>? service;
  final Future<bool> Function(Map<String, dynamic>) onSave;

  const _ServiceFormModal({required this.title, required this.onSave, this.service});

  @override
  State<_ServiceFormModal> createState() => _ServiceFormModalState();
}

class _ServiceFormModalState extends State<_ServiceFormModal> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _deliveryDaysController;
  late TextEditingController _imageController;

  List<dynamic> _realCategories = [];
  String? _selectedCategoryId;
  bool _isLoadingCategories = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.service?['title'] ?? '');
    _descriptionController = TextEditingController(text: widget.service?['description'] ?? '');
    _priceController = TextEditingController(text: widget.service?['price']?.toString() ?? '');
    _deliveryDaysController = TextEditingController(text: widget.service?['deliveryDays']?.toString() ?? '1');
    _imageController = TextEditingController(text: widget.service?['image'] ?? '');
    
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    final categories = await _apiService.getCategories();
    if (mounted) {
      setState(() {
        _realCategories = categories;
        _isLoadingCategories = false;

        if (widget.service?['categoryId'] != null) {
          _selectedCategoryId = widget.service!['categoryId'].toString();
        } else if (_realCategories.isNotEmpty) {
          _selectedCategoryId = _realCategories.first['id'].toString();
        }
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _deliveryDaysController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.grey, fontSize: 14),
      prefixIcon: Icon(icon, color: Colors.grey, size: 20),
      filled: true,
      fillColor: const Color(0xFF0A0A0A),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF27272A))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF00E676), width: 1.5)),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Colors.redAccent)),
      focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Colors.redAccent, width: 1.5)),
    );
  }

  void _submit() async {
    if (!_formKey.currentState!.validate() || _selectedCategoryId == null) return;

    setState(() => _isSaving = true);

    final Map<String, dynamic> formData = {
      'title': _titleController.text.trim(),
      'description': _descriptionController.text.trim(),
      'price': double.tryParse(_priceController.text) ?? 0.0,
      'deliveryDays': int.tryParse(_deliveryDaysController.text) ?? 1,
      'image': _imageController.text.trim().isNotEmpty ? _imageController.text.trim() : null,
      'categoryId': _selectedCategoryId,
    };

    final success = await widget.onSave(formData);

    if (mounted) {
      setState(() => _isSaving = false);
      if (success) {
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error guardando el servicio. Verifica los parámetros.'), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(widget.title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  IconButton(icon: const Icon(Icons.close, color: Colors.grey), onPressed: () => Navigator.pop(context)),
                ],
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _titleController,
                style: const TextStyle(color: Colors.white),
                decoration: _buildInputDecoration('Título del servicio', Icons.title),
                validator: (value) => value == null || value.isEmpty ? 'El título es requerido' : null,
              ),
              const SizedBox(height: 16),
              _isLoadingCategories
                  ? const Center(child: Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator(color: Color(0xFF00E676))))
                  : DropdownButtonFormField<String>(
                      value: _selectedCategoryId,
                      dropdownColor: const Color(0xFF121214),
                      style: const TextStyle(color: Colors.white),
                      decoration: _buildInputDecoration('Categoría', Icons.category_outlined),
                      items: _realCategories.map<DropdownMenuItem<String>>((dynamic cat) {
                        return DropdownMenuItem<String>(
                          value: cat['id'].toString(),
                          child: Text(cat['name'] ?? 'Sin nombre'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) setState(() => _selectedCategoryId = value);
                      },
                    ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      style: const TextStyle(color: Colors.white),
                      keyboardType: TextInputType.number,
                      decoration: _buildInputDecoration('Precio (S/)', Icons.monetization_on_outlined),
                      validator: (value) => value == null || value.isEmpty ? 'Requerido' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _deliveryDaysController,
                      style: const TextStyle(color: Colors.white),
                      keyboardType: TextInputType.number,
                      decoration: _buildInputDecoration('Días Entrega', Icons.speed_outlined),
                      validator: (value) => value == null || value.isEmpty ? 'Requerido' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _imageController,
                style: const TextStyle(color: Colors.white),
                decoration: _buildInputDecoration('URL de la Imagen', Icons.image_outlined),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                style: const TextStyle(color: Colors.white),
                maxLines: 3,
                decoration: _buildInputDecoration('Descripción detallada', Icons.description_outlined),
                validator: (value) => value == null || value.isEmpty ? 'La descripción es requerida' : null,
              ),
              const SizedBox(height: 28),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00E676),
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: _isSaving ? null : _submit,
                child: _isSaving
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2.5))
                    : const Text('Confirmar Cambios', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15)),
              )
            ],
          ),
        ),
      ),
    );
  }
}