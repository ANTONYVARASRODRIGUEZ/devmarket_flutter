// lib/screens/auth/verify_screen.dart
import 'package:flutter/material.dart';
import 'package:devmarket_app/data/services/api_service.dart';

class VerifyScreen extends StatefulWidget {
  final String email; // Recibimos el email del registro

  const VerifyScreen({super.key, required this.email});

  @override
  State<VerifyScreen> createState() => _VerifyScreenState();
}

class _VerifyScreenState extends State<VerifyScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _codeController = TextEditingController();
  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _handleVerification() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        await _apiService.verifyEmail(
          email: widget.email,
          code: _codeController.text.trim(),
        );

        if (!mounted) return;

        _showSnackBar('¡Cuenta verificada con éxito! Ya puedes iniciar sesión.', const Color(0xFF00E676));
        
        // Lo mandamos al login limpiando el historial de pantallas
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);

      } catch (error) {
        if (!mounted) return;
        _showSnackBar(error.toString().replaceAll('Exception: ', ''), Colors.redAccent);
      } finally { // 🟢 CORREGIDO: Cambiado 'select' por 'finally'
        if (mounted) {
          setState(() => _isLoading = false);
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
                    const Icon(Icons.mark_email_unread_outlined, color: Color(0xFF00E676), size: 64),
                    const SizedBox(height: 24),
                    const Text(
                      'Verifica tu cuenta',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Hemos enviado un código a:\n${widget.email}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey, fontSize: 15),
                    ),
                    const SizedBox(height: 36),

                    const Text('Código de Verificación', style: TextStyle(color: Colors.white70, fontSize: 14)),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _codeController,
                      enabled: !_isLoading,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontSize: 24, letterSpacing: 8, fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        hintText: '000000',
                        hintStyle: const TextStyle(color: Colors.grey, letterSpacing: 0),
                        filled: true,
                        fillColor: const Color(0xFF121214),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF27272A))),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF00E676))),
                      ),
                      validator: (value) => value == null || value.trim().isEmpty ? 'Ingresa el código' : null,
                    ),
                    const SizedBox(height: 30),

                    ElevatedButton(
                      onPressed: _isLoading ? null : _handleVerification,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00E676),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      child: _isLoading
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                          : const Text('Verificar Código', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
}