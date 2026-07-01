// lib/screens/auth/login_screen.dart
import 'package:flutter/material.dart';
import 'package:devmarket_app/data/services/api_service.dart'; 
import 'package:devmarket_app/screens/freelancer/freelancer_main_layout.dart';
import 'package:devmarket_app/data/services/socket_service.dart';
import 'package:google_sign_in/google_sign_in.dart'; 

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final ApiService _apiService = ApiService();

  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  bool _obscurePassword = true;
  bool _isLoading = false; 

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true; 
      });

      try {
        final response = await _apiService.login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

        if (!mounted) return;

        final dataContainer = response['data'];
        final user = dataContainer != null ? dataContainer['user'] : null;
        
        final String role = user != null && user['role'] != null 
            ? user['role'].toString().toLowerCase().trim() 
            : 'client';
            
        final String username = user != null ? user['username'] ?? 'Usuario' : 'Usuario';

        _showSnackBar('¡Bienvenido a DevMarket, $username!', const Color(0xFF00E676));
        
        SocketService().disconnect();
        await SocketService().connect();
        
        if (role == 'freelancer') {
          if (!mounted) return;
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const FreelancerMainLayout()),
            (route) => false,
          );
        } else {
          if (!mounted) return;
          Navigator.pushNamedAndRemoveUntil(
            context, 
            '/home', 
            (route) => false, 
            arguments: role,
          );
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
      if (errorMsg.contains('canceled') || errorMsg.contains('interrupted')) {
        errorMsg = 'Inicio de sesión cancelado.';
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
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: const Color(0xFF00E676),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(Icons.code, size: 45, color: Colors.black),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'DevMarket',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Conecta con los mejores freelancers',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                    const SizedBox(height: 40),

                    if (_isLoading) ...[
                      const LinearProgressIndicator(
                        backgroundColor: Color(0xFF121214),
                        color: Color(0xFF00E676),
                      ),
                      const SizedBox(height: 20),
                    ],

                    _buildLabel('Correo electrónico'),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      enabled: !_isLoading,
                      style: const TextStyle(color: Colors.white),
                      decoration: _buildInputDecoration(hintText: 'tu@email.com', prefixIcon: Icons.mail_outline),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Ingresa tu correo';
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
                          return 'Ingresa un correo válido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    _buildLabel('Contraseña'),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      enabled: !_isLoading,
                      style: const TextStyle(color: Colors.white),
                      decoration: _buildInputDecoration(hintText: 'Tu contraseña', prefixIcon: Icons.lock_outline).copyWith(
                        suffixIcon: IconButton(
                          icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: Colors.grey),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Ingresa tu contraseña';
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),

                    ElevatedButton(
                      onPressed: _isLoading ? null : _handleLogin,
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
                              child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2)
                            )
                          : const Text('Iniciar Sesión', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 24),

                    Row(
                      children: const [
                        Expanded(child: Divider(color: Color(0xFF27272A))),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text('o continua con', style: TextStyle(color: Colors.grey, fontSize: 14)),
                        ),
                        Expanded(child: Divider(color: Color(0xFF27272A))),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // 🔴 Botón de Google expandido en ancho completo sin el de GitHub
                    _buildSocialButton(
                      label: 'Google',
                      icon: Image.asset('assets/logos/google_logo.png', height: 20, errorBuilder: (context, error, stackTrace) => const Icon(Icons.g_mobiledata, color: Colors.white)),
                      onPressed: _isLoading ? null : _handleGoogleAuth, 
                    ),
                    const SizedBox(height: 32),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('¿No tienes cuenta? ', style: TextStyle(color: Colors.grey)),
                        GestureDetector(
                          onTap: _isLoading 
                              ? null 
                              : () => Navigator.pushNamed(context, '/register'),
                          child: const Text('Crear cuenta', style: TextStyle(color: Color(0xFF00E676), fontWeight: FontWeight.bold)),
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
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(text, style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500)),
    );
  }

  InputDecoration _buildInputDecoration({required String hintText, required IconData prefixIcon}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: Colors.grey, fontSize: 15),
      prefixIcon: Icon(prefixIcon, color: Colors.grey),
      filled: true,
      fillColor: const Color(0xFF121214),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF27272A))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF00E676))),
      disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF1A1A1E))),
    );
  }

  Widget _buildSocialButton({required String label, required Widget icon, required VoidCallback? onPressed}) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: const Color(0xFF121214),
        side: const BorderSide(color: Color(0xFF27272A)),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon,
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}