// lib/screens/profile_screen.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../data/services/api_service.dart';
import '../widgets/custom_header.dart'; // 👈 1. IMPORTACIÓN DEL HEADER REPETIDO

class ProfileScreen extends StatefulWidget {
  final ApiService apiService;

  const ProfileScreen({super.key, required this.apiService});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  bool _isUpdating = false;

  Map<String, dynamic>? _profileData;
  String _currentRole = 'CLIENT'; 

  final _usernameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bioController = TextEditingController();
  String _selectedLocation = '';
  String? _avatarBase64;

  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _showCurrentPass = false;
  bool _showNewPass = false;
  bool _showConfirmPass = false;

  final List<String> _latamCountries = [
    "Argentina", "Bolivia", "Brasil", "Chile", "Colombia", "Costa Rica", 
    "Cuba", "Ecuador", "El Salvador", "Guatemala", "Honduras", "México", 
    "Nicaragua", "Panamá", "Paraguay", "Perú", "Puerto Rico", 
    "República Dominicana", "Uruguay", "Venezuela"
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadProfileData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _usernameController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _loadProfileData() async {
    try {
      setState(() => _isLoading = true);
      final data = await widget.apiService.getUserProfile(); 
      
      if (data != null) {
        setState(() {
          _profileData = data;
          _usernameController.text = data['username'] ?? data['name'] ?? '';
          _phoneController.text = data['phone'] ?? '';
          _bioController.text = data['bio'] ?? '';
          _selectedLocation = data['location'] ?? '';
          _avatarBase64 = data['avatar'];
          _currentRole = (data['role'] ?? 'CLIENT').toString().toUpperCase(); 
        });
      }
    } catch (e) {
      debugPrint("🚨 Error cargando perfil: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    
    if (pickedFile != null) {
      final bytes = await File(pickedFile.path).readAsBytes();
      setState(() {
        _avatarBase64 = "data:image/png;base64,${base64Encode(bytes)}";
      });
    }
  }

  Future<void> _savePersonalData() async {
    try {
      setState(() => _isUpdating = true);
      
      final body = {
        "username": _usernameController.text,
        "phone": _phoneController.text,
        "location": _selectedLocation,
        "bio": _bioController.text,
        "avatar": _avatarBase64
      };

      final success = await widget.apiService.updateUserProfile(body);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Perfil actualizado con éxito'), backgroundColor: Color(0xFF00E676)),
        );
        _loadProfileData();
      }
    } catch (e) {
      debugPrint("🚨 Error actualizando perfil: $e");
    } finally {
      setState(() => _isUpdating = false);
    }
  }

  Future<void> _saveNewPassword() async {
    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Las contraseñas no coinciden'), backgroundColor: Colors.redAccent),
      );
      return;
    }

    try {
      setState(() => _isUpdating = true);
      final success = await widget.apiService.updatePassword(
        _currentPasswordController.text, 
        _newPasswordController.text
      );

      if (success && mounted) {
        _currentPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('🔒 Contraseña cambiada con éxito'), backgroundColor: Color(0xFF00E676)),
        );
      }
    } catch (e) {
      debugPrint("🚨 Error en contraseña: $e");
    } finally {
      setState(() => _isUpdating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const accentColor = Color(0xFF00E676);
    const cardColor = Color(0xFF121214);
    const bgDark = Color(0xFF0C0C0E);

    final provider = _profileData?['provider'] ?? "EMAIL"; 
    final bool isGoogleAccount = provider == "GOOGLE";

    if (_isLoading) {
      return const Scaffold(
        backgroundColor: bgDark,
        body: Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(accentColor))),
      );
    }

    return Scaffold(
      backgroundColor: bgDark,
      body: SafeArea(
        child: SingleChildScrollView(
          // Se redujo el padding vertical de 24.0 a 12.0 para que acople orgánicamente con el CustomHeader
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🚀 2. INTEGRACIÓN DEL CUSTOM HEADER DINÁMICO (Sustituye la fila estática anterior)
              const CustomHeader(
                title: 'Mi Perfil',
                subtitle: 'Gestiona tu identidad y credenciales',
              ),
              const SizedBox(height: 16),

              // --- TARJETA DE PERFIL ---
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
                ),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 64,
                          backgroundColor: const Color(0xFF0A0A0A),
                          backgroundImage: (_avatarBase64 != null && _avatarBase64!.contains(','))
                              ? MemoryImage(base64Decode(_avatarBase64!.split(',')[1]))
                              : null,
                          child: _avatarBase64 == null 
                              ? const Icon(Icons.person, size: 64, color: Colors.grey) 
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: InkWell(
                            onTap: _pickImage,
                            child: const CircleAvatar(
                              radius: 18,
                              backgroundColor: accentColor,
                              child: Icon(Icons.camera_alt, size: 16, color: Colors.black),
                            ),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(_usernameController.text, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                    Text(_profileData?['email'] ?? 'sin-email@domain.com', style: const TextStyle(color: Colors.grey, fontSize: 14)),
                    const SizedBox(height: 12),
                    
                    if (isGoogleAccount)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.g_mobiledata, color: Colors.blue, size: 20),
                            Text('Google Account', style: TextStyle(color: Colors.blue, fontSize: 10, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    
                    const Divider(color: Colors.grey, height: 32, thickness: 0.1),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatBox('${_profileData?['ordersCount'] ?? 0}', 'Pedidos'),
                        _buildStatBox('${_profileData?['reviewsCount'] ?? 0}', 'Reseñas'),
                        _buildStatBox('Jun 2026', 'Miembro'),
                      ],
                    )
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // --- SELECTOR DE PESTAÑAS (TABS) ---
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(color: const Color(0xFF0A0A0A), borderRadius: BorderRadius.circular(16)),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(color: const Color(0xFF1F1F22), borderRadius: BorderRadius.circular(12)),
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.grey,
                  labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1),
                  tabs: const [
                    Tab(text: 'PERSONAL'),
                    Tab(text: 'CAMBIAR CONTRASEÑA'),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // --- VISTAS DE LAS PESTAÑAS ---
              SizedBox(
                height: 440, 
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildPersonalTab(accentColor),
                    _buildPasswordTab(isGoogleAccount, accentColor),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatBox(String val, String label) {
    return Column(
      children: [
        Text(val, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildPersonalTab(Color accent) {
    return Column(
      children: [
        _buildTextField('Nombre de Usuario', _usernameController, false),
        const SizedBox(height: 16),
        _buildTextField('Teléfono', _phoneController, false),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          initialValue: _selectedLocation.isNotEmpty && _latamCountries.contains(_selectedLocation) ? _selectedLocation : null,
          dropdownColor: const Color(0xFF0A0A0A),
          style: const TextStyle(color: Colors.white),
          decoration: _inputDecoration('Ubicación'),
          items: _latamCountries.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
          onChanged: (val) => setState(() => _selectedLocation = val ?? ''),
        ),
        const SizedBox(height: 16),
        _buildTextField('Biografía', _bioController, false, maxLines: 2),
        const Spacer(),
        ElevatedButton(
          onPressed: _isUpdating ? null : _savePersonalData,
          style: ElevatedButton.styleFrom(
            backgroundColor: accent,
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          child: _isUpdating 
              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
              : const Text('GUARDAR CAMBIOS', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        )
      ],
    );
  }

  Widget _buildPasswordTab(bool isGoogle, Color accent) {
    if (isGoogle) {
      return Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: const Color(0xFF0A0A0A), borderRadius: BorderRadius.circular(20)),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.shield_outlined, color: Colors.blue, size: 48),
              SizedBox(height: 16),
              Text('Cuenta vinculada con Google', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('Tu autenticación se administra externamente. Cambia los ajustes desde tu cuenta de Google.', 
                textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 13)),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        _buildTextField('Contraseña Actual', _currentPasswordController, !_showCurrentPass, 
            suffix: IconButton(icon: Icon(_showCurrentPass ? Icons.visibility : Icons.visibility_off), onPressed: () => setState(() => _showCurrentPass = !_showCurrentPass))),
        const SizedBox(height: 16),
        _buildTextField('Nueva Contraseña', _newPasswordController, !_showNewPass, 
            suffix: IconButton(icon: Icon(_showNewPass ? Icons.visibility : Icons.visibility_off), onPressed: () => setState(() => _showNewPass = !_showNewPass))),
        const SizedBox(height: 16),
        _buildTextField('Confirmar Contraseña', _confirmPasswordController, !_showConfirmPass, 
            suffix: IconButton(icon: Icon(_showConfirmPass ? Icons.visibility : Icons.visibility_off), onPressed: () => setState(() => _showConfirmPass = !_showConfirmPass))),
        const Spacer(),
        ElevatedButton(
          onPressed: _isUpdating ? null : _saveNewPassword,
          style: ElevatedButton.styleFrom(
            backgroundColor: accent,
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          child: _isUpdating 
              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
              : const Text('ACTUALIZAR CONTRASEÑA', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        )
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, bool obscure, {int maxLines = 1, Widget? suffix}) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: _inputDecoration(label).copyWith(suffixIcon: suffix, suffixIconColor: Colors.grey),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label.toUpperCase(),
      labelStyle: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
      filled: true,
      fillColor: const Color(0xFF0A0A0A),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF1F1F22))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF1F1F22))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF00E676))),
    );
  }
}