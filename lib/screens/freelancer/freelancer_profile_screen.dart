import 'package:flutter/material.dart';
import 'package:devmarket_app/data/services/api_service.dart'; 
import 'package:devmarket_app/widgets/custom_header.dart'; // 🚀 IMPORTACIÓN DEL HEADER

class FreelancerProfileScreen extends StatefulWidget {
  const FreelancerProfileScreen({super.key});

  @override
  State<FreelancerProfileScreen> createState() => _FreelancerProfileScreenState();
}

class _FreelancerProfileScreenState extends State<FreelancerProfileScreen> {
  final ApiService _apiService = ApiService();

  // 🚀 PALETA DE COLORES
  static const bgDark = Color(0xFF0C0C0E);
  static const cardDark = Color(0xFF121214);
  static const inputBg = Color(0xFF0A0A0A);
  static const accentGreen = Color(0xFF00E676);
  static const textMuted = Color(0xFF71717A);
  static const borderDark = Color(0xFF27272A);

  // 🚀 TABS
  String _activeTab = 'profesional';

  // 🚀 CONTROL DE ESTADOS DE RED
  bool _isLoading = true;
  bool _isSaving = false;
  String? _error;
  String? _successMsg;

  // Campos del Perfil (Se llenan dinámicamente desde la BD)
  String _name = "";
  String _email = "";
  String _professionalTitle = "";
  String _location = "";
  String _hourlyRate = "";
  String _bio = "";
  String _yearsOfExperience = "";
  String _portfolioUrl = "";
  String? _avatarUrl; 
  String _provider = "EMAIL"; 

  // Listas dinámicas vinculadas
  List<Map<String, String>> _languages = []; 
  List<String> _skills = [];
  List<String> _education = [];

  // Inputs para agregar elementos dinámicos
  String _selectedLangName = 'Español';
  String _selectedLangLevel = 'BÁSICO';
  final TextEditingController _skillController = TextEditingController();
  final TextEditingController _eduController = TextEditingController();

  // 🚀 ESTADOS PARA CONTRASEÑAS (Pestaña Seguridad)
  final TextEditingController _currentPassCtrl = TextEditingController();
  final TextEditingController _newPassCtrl = TextEditingController();
  final TextEditingController _confirmPassCtrl = TextEditingController();
  bool _showCurrentPass = false;
  bool _showNewPass = false;
  bool _showConfirmPass = false;
  
  String? _passError;
  String? _passSuccess;
  bool _passLoading = false;

  // Listas de opciones estáticas
  final List<String> _availableLanguages = ['Español', 'Inglés', 'Portugués', 'Alemán', 'Francés', 'Italiano', 'Chino', 'Japonés'];
  final List<String> _allowedLevels = ['BÁSICO', 'INTERMEDIO', 'AVANZADO', 'NATIVO'];
  final List<String> _countries = ['Perú', 'Colombia', 'México', 'Argentina', 'Chile', 'Ecuador', 'España', 'Estados Unidos'];

  @override
  void initState() {
    super.initState();
    _loadProfileData(); // 🔄 Llamada automática al cargar la pantalla
  }

  @override
  void dispose() {
    _skillController.dispose();
    _eduController.dispose();
    _currentPassCtrl.dispose();
    _newPassCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  // 🟢 1. CARGAR DATOS REALES DE LA BASE DE DATOS
  Future<void> _loadProfileData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final profile = await _apiService.getUserProfile();

      if (profile != null) {
        setState(() {
          final userData = profile['data'] ?? profile;

          _name = userData['name'] ?? userData['username'] ?? 'Usuario';
          _email = userData['email'] ?? '';
          _professionalTitle = userData['professionalTitle'] ?? '';
          _location = _countries.contains(userData['location']) ? userData['location'] : '';
          _hourlyRate = userData['hourlyRate'] != null ? userData['hourlyRate'].toString() : ''; 
          _yearsOfExperience = userData['yearsOfExperience'] != null ? userData['yearsOfExperience'].toString() : '';
          _portfolioUrl = userData['portfolioUrl'] ?? '';
          _bio = userData['bio'] ?? '';
          _avatarUrl = userData['avatar']; // 🚀 CORREGIDO: Mapeado con la propiedad 'avatar' de tu Prisma
          _provider = userData['provider'] ?? 'EMAIL';

          // Mapeo seguro de arreglos / listas dinámicas procedentes de tu ORM/BD
          if (userData['skills'] != null) {
            _skills = List<String>.from(userData['skills']);
          } else {
            _skills = [];
          }
          if (userData['education'] != null) {
            _education = List<String>.from(userData['education']);
          } else {
            _education = [];
          }
          if (userData['languages'] != null) {
            _languages = (userData['languages'] as List).map((item) {
              return {
                'name': (item['name'] ?? '').toString(),
                'level': (item['level'] ?? 'BÁSICO').toString().toUpperCase(), // 🚀 Sincronizado con Zod Enum
              };
            }).toList();
          } else {
            _languages = [];
          }
        });
      } else {
        setState(() => _error = "No se pudo obtener la información del perfil.");
      }
    } catch (e) {
      setState(() => _error = "Error de conexión: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // 🟢 2. ENVIAR CAMBIOS REALES DEL PERFIL A LA BD
  Future<void> _handleSave() async {
    setState(() {
      _isSaving = true;
      _error = null;
      _successMsg = null;
    });

    final double? parsedRate = double.tryParse(_hourlyRate);
    final int? parsedExp = int.tryParse(_yearsOfExperience);

    // Estructuramos el JSON limpiando campos vacíos para no romper las validaciones estrictas de Zod
    final Map<String, dynamic> updateData = {
      "name": _name,
      "professionalTitle": _professionalTitle.isEmpty ? null : _professionalTitle,
      "location": _location.isEmpty ? null : _location,
      "rateType": "HOURLY", // Requerido por tu enum de Zod
      "hourlyRate": (parsedRate != null && parsedRate > 0) ? parsedRate : null, 
      "yearsOfExperience": (parsedExp != null && parsedExp >= 0) ? parsedExp : null,
      "portfolioUrl": _portfolioUrl.isEmpty ? null : _portfolioUrl,
      "bio": _bio.isEmpty ? null : _bio,
      "skills": _skills,
      "education": _education,
      "languages": _languages.map((l) => {
        "name": l['name'],
        "level": l['level']!.toUpperCase() // Sincronizado con las opciones de Zod
      }).toList(),
    };

    final bool success = await _apiService.updateUserProfile(updateData);

    if (mounted) {
      setState(() {
        _isSaving = false;
        if (success) {
          _successMsg = "Perfil actualizado con éxito en la BD.";
        } else {
          _error = "Error al guardar: Verifica que los formatos de datos cumplan con las reglas de Zod.";
        }
      });
    }
  }

  // 🟢 3. CAMBIO REAL DE CONTRASEÑA EN LA BD
  Future<void> _handlePasswordSave() async {
    setState(() {
      _passError = null;
      _passSuccess = null;
    });

    if (_currentPassCtrl.text.isEmpty || _newPassCtrl.text.isEmpty || _confirmPassCtrl.text.isEmpty) {
      setState(() => _passError = 'Todos los campos son obligatorios.');
      return;
    }
    if (_newPassCtrl.text.length < 8) {
      setState(() => _passError = 'La nueva contraseña debe tener al menos 8 caracteres.');
      return;
    }
    if (_newPassCtrl.text != _confirmPassCtrl.text) {
      setState(() => _passError = 'Las contraseñas nuevas no coinciden.');
      return;
    }

    setState(() => _passLoading = true);

    final bool success = await _apiService.updatePassword(
      _currentPassCtrl.text,
      _newPassCtrl.text,
    );

    if (mounted) {
      setState(() {
        _passLoading = false;
        if (success) {
          _passSuccess = 'Contraseña actualizada con éxito.';
          _currentPassCtrl.clear();
          _newPassCtrl.clear();
          _confirmPassCtrl.clear();
        } else {
          _passError = 'Contraseña actual incorrecta o error de servidor.';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: bgDark,
        body: Center(child: CircularProgressIndicator(color: accentGreen)),
      );
    }

    final bool isGoogleAccount = _provider.toUpperCase() == "GOOGLE";

    return Scaffold(
      backgroundColor: bgDark,
      body: SafeArea(
        child: RefreshIndicator(
          color: accentGreen,
          backgroundColor: cardDark,
          onRefresh: _loadProfileData, // Permite arrastrar hacia abajo para recargar
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🚀 INTEGRACIÓN DEL CUSTOM HEADER REQUERIDO
                const CustomHeader(
                  title: 'Mi Perfil',
                  subtitle: 'Gestiona tu identidad y habilidades',
                ),
                const SizedBox(height: 16),

                // Avatar y Cabecera de Datos Básicos
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: borderDark,
                        backgroundImage: _avatarUrl != null && _avatarUrl!.isNotEmpty 
                            ? NetworkImage(_avatarUrl!) 
                            : null,
                        child: _avatarUrl == null || _avatarUrl!.isEmpty
                            ? const Icon(Icons.person, size: 50, color: Colors.white) 
                            : null,
                      ),
                      const SizedBox(height: 12),
                      Text(_name, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
                      Text(_email, style: const TextStyle(color: textMuted, fontSize: 14)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Tabs Nav
                Row(
                  children: [
                    _buildTabButton('profesional', 'Profesional'),
                    _buildTabButton('habilidades', 'Habilidades'),
                    _buildTabButton('seguridad', 'Seguridad'),
                  ],
                ),
                const SizedBox(height: 24),

                if (_error != null) _buildStatusMessage(_error!, isError: true),
                if (_successMsg != null) _buildStatusMessage(_successMsg!, isError: false),

                // Renderizado según pestaña activa
                if (_activeTab == 'profesional') _buildProfesionalTab(),
                if (_activeTab == 'habilidades') _buildHabilidadesTab(),
                if (_activeTab == 'seguridad') _buildSeguridadTab(isGoogleAccount),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabButton(String tabKey, String label) {
    final bool isActive = _activeTab == tabKey;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _activeTab = tabKey),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isActive ? accentGreen : borderDark,
                width: isActive ? 2 : 1,
              ),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isActive ? Colors.white : textMuted,
              fontWeight: isActive ? FontWeight.w500 : FontWeight.normal,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfesionalTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField('Título Profesional', initialValue: _professionalTitle, onChanged: (v) => _professionalTitle = v),
        _buildDropdownField('Ubicación / País', _location, _countries, (v) => setState(() => _location = v ?? '')),
        _buildTextField('Tarifa por Hora (USD)', initialValue: _hourlyRate, keyboardType: TextInputType.number, onChanged: (v) => _hourlyRate = v),
        _buildTextField('Años de Experiencia', initialValue: _yearsOfExperience, keyboardType: TextInputType.number, onChanged: (v) => _yearsOfExperience = v),
        _buildTextField('URL de Portafolio', initialValue: _portfolioUrl, onChanged: (v) => _portfolioUrl = v),
        _buildTextField('Biografía', initialValue: _bio, maxLines: 4, onChanged: (v) => _bio = v),
        const SizedBox(height: 24),
        _buildSaveButton(onPressed: _handleSave, isLoading: _isSaving),
      ],
    );
  }

  Widget _buildHabilidadesTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- HABILIDADES ---
        const Text('Habilidades', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _buildSimpleInputField(_skillController, 'Ej. Flutter, Node.js')),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.add_box_rounded, color: accentGreen, size: 40),
              onPressed: () {
                if (_skillController.text.isNotEmpty) {
                  setState(() {
                    _skills.add(_skillController.text.trim());
                    _skillController.clear();
                  });
                }
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: _skills.map((skill) => Chip(
            backgroundColor: cardDark,
            side: const BorderSide(color: borderDark),
            label: Text(skill, style: const TextStyle(color: Colors.white)),
            deleteIcon: const Icon(Icons.close, size: 14, color: Colors.red),
            onDeleted: () => setState(() => _skills.remove(skill)),
          )).toList(),
        ),
        const SizedBox(height: 24),

        // --- IDIOMAS ---
        const Text('Idiomas', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _selectedLangName,
                dropdownColor: cardDark,
                style: const TextStyle(color: Colors.white),
                items: _availableLanguages.map((l) => DropdownMenuItem(value: l, child: Text(l))).toList(),
                onChanged: (v) => setState(() => _selectedLangName = v ?? 'Español'),
                decoration: InputDecoration(filled: true, fillColor: inputBg, enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: borderDark))),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _selectedLangLevel,
                dropdownColor: cardDark,
                style: const TextStyle(color: Colors.white),
                items: _allowedLevels.map((l) => DropdownMenuItem(value: l, child: Text(l))).toList(),
                onChanged: (v) => setState(() => _selectedLangLevel = v ?? 'BÁSICO'),
                decoration: InputDecoration(filled: true, fillColor: inputBg, enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: borderDark))),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add_box_rounded, color: accentGreen, size: 40),
              onPressed: () {
                setState(() {
                  // Validamos duplicados locales simples
                  _languages.removeWhere((l) => l['name'] == _selectedLangName);
                  _languages.add({'name': _selectedLangName, 'level': _selectedLangLevel});
                });
              },
            )
          ],
        ),
        const SizedBox(height: 8),
        ..._languages.map((lang) => Card(
          color: cardDark,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: borderDark)),
          child: ListTile(
            title: Text(lang['name'] ?? '', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            subtitle: Text(lang['level'] ?? '', style: const TextStyle(color: textMuted)),
            trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.redAccent), onPressed: () => setState(() => _languages.remove(lang))),
          ),
        )),
        const SizedBox(height: 24),

        // --- EDUCACIÓN ---
        const Text('Educación', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _buildSimpleInputField(_eduController, 'Ej. Ingeniería de Sistemas - Univ. XYZ')),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.add_box_rounded, color: accentGreen, size: 40),
              onPressed: () {
                if (_eduController.text.isNotEmpty) {
                  setState(() {
                    _education.add(_eduController.text.trim());
                    _eduController.clear();
                  });
                }
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        ..._education.map((edu) => Card(
          color: cardDark,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: borderDark)),
          child: ListTile(
            title: Text(edu, style: const TextStyle(color: Colors.white)),
            trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.redAccent), onPressed: () => setState(() => _education.remove(edu))),
          ),
        )),
        const SizedBox(height: 24),
        _buildSaveButton(onPressed: _handleSave, isLoading: _isSaving),
      ],
    );
  }

  Widget _buildSeguridadTab(bool isGoogleAccount) {
    if (isGoogleAccount) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: cardDark, borderRadius: BorderRadius.circular(12), border: Border.all(color: borderDark)),
        child: const Row(
          children: [
            Icon(Icons.g_mobiledata, color: Colors.red, size: 32),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Tu cuenta está vinculada a Google. La gestión de contraseñas se realiza directamente en tu proveedor de identidad.',
                style: TextStyle(color: textMuted, fontSize: 14),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_passError != null) _buildStatusMessage(_passError!, isError: true),
        if (_passSuccess != null) _buildStatusMessage(_passSuccess!, isError: false),
        _buildPasswordField('Contraseña Actual', _currentPassCtrl, _showCurrentPass, () => setState(() => _showCurrentPass = !_showCurrentPass)),
        _buildPasswordField('Nueva Contraseña', _newPassCtrl, _showNewPass, () => setState(() => _showNewPass = !_showNewPass)),
        _buildPasswordField('Confirmar Nueva Contraseña', _confirmPassCtrl, _showConfirmPass, () => setState(() => _showConfirmPass = !_showConfirmPass)),
        const SizedBox(height: 24),
        _buildSaveButton(onPressed: _handlePasswordSave, isLoading: _passLoading, text: 'Actualizar Contraseña'),
      ],
    );
  }

  Widget _buildTextField(String label, {required String initialValue, required Function(String) onChanged, int maxLines = 1, TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: textMuted, fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          TextFormField(
            key: Key(initialValue), // 🔑 Sincroniza dinámicamente el valor en refrescos o guardados exitosos
            initialValue: initialValue,
            maxLines: maxLines,
            keyboardType: keyboardType,
            style: const TextStyle(color: Colors.white),
            onChanged: onChanged,
            decoration: InputDecoration(
              filled: true,
              fillColor: inputBg,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: borderDark)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: accentGreen)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField(String label, String value, List<String> items, Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: textMuted, fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            value: value.isEmpty ? null : value,
            dropdownColor: cardDark,
            style: const TextStyle(color: Colors.white),
            onChanged: onChanged,
            items: items.map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(),
            decoration: InputDecoration(
              filled: true,
              fillColor: inputBg,
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: borderDark)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: accentGreen)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField(String label, TextEditingController ctrl, bool show, VoidCallback toggle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: textMuted, fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          TextFormField(
            controller: ctrl,
            obscureText: !show,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              filled: true,
              fillColor: inputBg,
              suffixIcon: IconButton(icon: Icon(show ? Icons.visibility : Icons.visibility_off, color: textMuted), onPressed: toggle),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: borderDark)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: accentGreen)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleInputField(TextEditingController ctrl, String hint) {
    return TextFormField(
      controller: ctrl,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: textMuted),
        filled: true,
        fillColor: inputBg,
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: borderDark)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: accentGreen)),
      ),
    );
  }

  Widget _buildStatusMessage(String message, {required bool isError}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isError ? Colors.red.withAlpha(25) : accentGreen.withAlpha(25),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isError ? Colors.red : accentGreen),
      ),
      child: Text(message, style: TextStyle(color: isError ? Colors.red : accentGreen, fontSize: 14)),
    );
  }

  Widget _buildSaveButton({required VoidCallback onPressed, required bool isLoading, String text = 'Guardar Cambios'}) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: accentGreen,
          disabledBackgroundColor: accentGreen.withAlpha(100),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: isLoading 
          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: bgDark, strokeWidth: 2))
          : Text(text, style: const TextStyle(color: bgDark, fontWeight: FontWeight.bold, fontSize: 15)),
      ),
    );
  }
}