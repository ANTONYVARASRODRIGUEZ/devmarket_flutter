// lib/screens/auth/register_screen.dart
import 'package:flutter/material.dart';
import 'package:devmarket_app/data/services/api_service.dart'; 
import 'package:google_sign_in/google_sign_in.dart'; 
import 'package:devmarket_app/data/services/socket_service.dart'; 
import 'package:devmarket_app/screens/freelancer/freelancer_main_layout.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final ApiService _apiService = ApiService();
  
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  bool _obscurePassword = true;
  bool _isLoading = false; 

  String _selectedRole = 'CLIENT'; 

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleRegistration() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final emailText = _emailController.text.trim();

        await _apiService.register(
          name: _nameController.text.trim(),
          username: _usernameController.text.trim(),
          email: emailText,
          password: _passwordController.text,
          role: _selectedRole, 
        );

        if (!mounted) return;

        _showSnackBar('¡Cuenta creada con éxito! Por favor, inicia sesión.', const Color(0xFF00E676));

Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);

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

  void _handleGoogleAuth() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _googleSignIn.initialize(
        serverClientId: '421953722744-6ff80ol3ekua2o94s0adqo9mq8istfm0.apps.googleusercontent.com',
      );
      
      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate(
        scopeHint: <String>['email', 'profile'],
      );

      final GoogleSignInAuthentication googleAuth = googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        throw Exception('No se pudo obtener el ID Token de Google.');
      }

      final response = await _apiService.loginWithGoogle(
        googleIdToken: idToken,
      );

      if (!mounted) return;

      SocketService().disconnect();
      await SocketService().connect();

      _showSnackBar('¡Autenticación con Google exitosa!', const Color(0xFF00E676));

      var dataContainer = response['data'] ?? response;
      final user = dataContainer['user'];
      
      if (user == null || user['role'] == null || user['username'] == null || user['username'].toString().startsWith('google_')) {
        if (!mounted) return;
        Navigator.pushNamedAndRemoveUntil(context, '/oauth_onboarding', (route) => false);
        return;
      }

      final String userRole = user['role'].toString().toLowerCase();

      if (!mounted) return;
      if (userRole == 'freelancer') {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const FreelancerMainLayout()),
          (route) => false,
        );
      } else {
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false, arguments: userRole);
      }

    } catch (error) {
      if (!mounted) return;
      
      String errorMsg = error.toString();
      if (errorMsg.contains('canceled') || errorMsg.contains('developer_error')) {
        errorMsg = 'Inicio de sesión cancelado o interrumpido.';
      } else {
        errorMsg = errorMsg.replaceAll('Exception: ', '');
      }

      _showSnackBar(errorMsg, Colors.redAccent);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
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
                      'Create Account',
                      style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Únete a la comunidad de DevMarket',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                    const SizedBox(height: 30),

                    _buildLabel('Quiero registrarme como:'),
                    Row(
                      children: [
                        Expanded(
                          child: _buildRoleCard(
                            title: 'Cliente',
                            icon: Icons.business_center_outlined,
                            value: 'CLIENT',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildRoleCard(
                            title: 'Freelancer',
                            icon: Icons.code_rounded,
                            value: 'FREELANCER',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    _buildLabel('Nombre Completo'),
                    TextFormField(
                      controller: _nameController,
                      enabled: !_isLoading,
                      style: const TextStyle(color: Colors.white),
                      decoration: _buildInputDecoration(hintText: 'Ej. Martín Pérez', prefixIcon: Icons.badge_outlined),
                      validator: (value) => value == null || value.trim().isEmpty ? 'Ingresa tu nombre completo' : null,
                    ),
                    const SizedBox(height: 16),

                    _buildLabel('Nombre de usuario único'),
                    TextFormField(
                      controller: _usernameController,
                      enabled: !_isLoading,
                      style: const TextStyle(color: Colors.white),
                      decoration: _buildInputDecoration(hintText: 'Ej. dev_martin', prefixIcon: Icons.person_outline),
                      validator: (value) => value == null || value.trim().length < 3 ? 'Mínimo 3 caracteres' : null,
                    ),
                    const SizedBox(height: 16),

                    _buildLabel('Correo electrónico'),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      enabled: !_isLoading,
                      style: const TextStyle(color: Colors.white),
                      decoration: _buildInputDecoration(hintText: 'tu@email.com', prefixIcon: Icons.mail_outline),
                      validator: (value) => value == null || !value.contains('@') ? 'Ingresa un correo válido' : null,
                    ),
                    const SizedBox(height: 16),

                    _buildLabel('Contraseña'),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      enabled: !_isLoading,
                      style: const TextStyle(color: Colors.white),
                      decoration: _buildInputDecoration(hintText: 'Mínimo 8 caracteres', prefixIcon: Icons.lock_outline).copyWith(
                        suffixIcon: IconButton(
                          icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: Colors.grey),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                      validator: (value) => value == null || value.length < 8 ? 'Mínimo 8 caracteres' : null,
                    ),
                    const SizedBox(height: 30),

                    ElevatedButton(
                      onPressed: _isLoading ? null : _handleRegistration,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00E676),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                          : const Text('Crear cuenta', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 16),

                    // 🔵 Botón de Google Estilizado
                    OutlinedButton.icon(
                      onPressed: _isLoading ? null : _handleGoogleAuth,
                      style: OutlinedButton.styleFrom(
                        backgroundColor: const Color(0xFF121214),
                        side: const BorderSide(color: Color(0xFF27272A)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      icon: const Icon(Icons.g_mobiledata, color: Colors.white, size: 24),
                      label: const Text('Registrarse con Google', style: TextStyle(color: Colors.white)),
                    ),
                    const SizedBox(height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('¿Ya tienes cuenta? ', style: TextStyle(color: Colors.grey)),
                        GestureDetector(
                          onTap: _isLoading ? null : () => Navigator.pushReplacementNamed(context, '/login'),
                          child: const Text('Inicia sesión', style: TextStyle(color: Color(0xFF00E676), fontWeight: FontWeight.bold)),
                        ),
                      ],
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Text(text, style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500)),
    );
  }

  InputDecoration _buildInputDecoration({required String hintText, required IconData prefixIcon}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: Colors.grey),
      prefixIcon: Icon(prefixIcon, color: Colors.grey),
      filled: true,
      fillColor: const Color(0xFF121214),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF27272A))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF00E676))),
    );
  }

  Widget _buildRoleCard({required String title, required IconData icon, required String value}) {
    final isSelected = _selectedRole == value;
    return GestureDetector(
      onTap: _isLoading ? null : () => setState(() => _selectedRole = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1A2E22) : const Color(0xFF121214),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF00E676) : const Color(0xFF27272A),
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? const Color(0xFF00E676) : Colors.grey, size: 28),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}