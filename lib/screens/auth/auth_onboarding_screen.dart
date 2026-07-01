// lib/screens/auth/auth_onboarding_screen.dart
import 'package:flutter/material.dart';
import 'package:devmarket_app/data/services/api_service.dart';

class AuthOnboardingScreen extends StatefulWidget {
  const AuthOnboardingScreen({super.key});

  @override
  State<AuthOnboardingScreen> createState() => _AuthOnboardingScreenState();
}

class _AuthOnboardingScreenState extends State<AuthOnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final ApiService _apiService = ApiService(); // 🚀 Usamos tu ApiService directamente
  
  String? _selectedRole; // Almacena 'CLIENT' o 'FREELANCER'
  bool _isLoading = false; // Control de carga local

  void _submitOnboarding() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedRole == null) {
        _showSnackBar('Por favor, selecciona un rol para continuar.', Colors.amber);
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        // 📡 Enviamos la data directo a tu backend mediante el ApiService
        // Nota: Asegúrate de que tu ApiService exponga un método similar o adáptalo a su firma exacta.
        final bool guardadoExitoso = await _apiService.completarOnboarding(
          username: _usernameController.text.trim(),
          role: _selectedRole!,
        );

        if (!mounted) return;

        if (guardadoExitoso) {
          _showSnackBar('¡Perfil configurado correctamente! Bienvenid@', const Color(0xFF00E676));
          
          final String roleLower = _selectedRole!.toLowerCase().trim();

          // Redirección inteligente basada en el rol seleccionado
          if (roleLower == 'freelancer') {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/freelancer_dashboard',
              (route) => false,
            );
          } else {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/home',
              (route) => false,
              arguments: roleLower,
            );
          }
        } else {
          _showSnackBar('Error al guardar. El nombre de usuario podría estar tomado.', Colors.redAccent);
        }
      } catch (error) {
        if (!mounted) return;
        _showSnackBar(error.toString().replaceAll('Exception: ', ''), Colors.redAccent);
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 450),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      '¡Casi listo!',
                      style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Completa estos dos últimos datos para personalizar tu experiencia.',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                    const SizedBox(height: 40),

                    _buildLabel('Elige un nombre de usuario único'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _usernameController,
                      enabled: !_isLoading,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'ej: dev_martin',
                        hintStyle: const TextStyle(color: Colors.grey),
                        prefixIcon: const Icon(Icons.alternate_email, color: Colors.grey),
                        filled: true,
                        fillColor: const Color(0xFF121214),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF27272A))),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF00E676))),
                        disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF1A1A1E))),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) return 'El usuario es obligatorio';
                        if (value.trim().length < 3) return 'Mínimo 3 caracteres';
                        return null;
                      },
                    ),
                    const SizedBox(height: 30),

                    _buildLabel('¿Cuál será tu rol principal?'),
                    const SizedBox(height: 10),
                    
                    // Tarjeta de Opción: CLIENTE
                    _buildRoleCard(
                      roleValue: 'CLIENT',
                      title: 'Quiero contratar servicios',
                      subtitle: 'Buscaré freelancers para mis proyectos',
                      icon: Icons.business_center_outlined,
                      isSelected: _selectedRole == 'CLIENT',
                      enabled: !_isLoading,
                    ),
                    const SizedBox(height: 16),

                    // Tarjeta de Opción: FREELANCER
                    _buildRoleCard(
                      roleValue: 'FREELANCER',
                      title: 'Quiero ofrecer mis servicios',
                      subtitle: 'Soy desarrollador/diseñador buscando proyectos',
                      icon: Icons.code_rounded,
                      isSelected: _selectedRole == 'FREELANCER',
                      enabled: !_isLoading,
                    ),
                    const SizedBox(height: 40),

                    ElevatedButton(
                      onPressed: _isLoading ? null : _submitOnboarding,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00E676),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2),
                            )
                          : const Text(
                              'Finalizar Registro',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500),
    );
  }

  Widget _buildRoleCard({
    required String roleValue,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required bool enabled,
  }) {
    return InkWell(
      onTap: enabled ? () => setState(() => _selectedRole = roleValue) : null,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF121214),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF00E676) : const Color(0xFF27272A),
            width: isSelected ? 2.0 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? const Color(0xFF00E676) : Colors.grey, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: Color(0xFF00E676))
            else
              const Icon(Icons.radio_button_off, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}