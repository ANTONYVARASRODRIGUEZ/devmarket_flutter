// lib/screens/freelancer/freelancer_settings_screen.dart
import 'package:flutter/material.dart';

class FreelancerSettingsScreen extends StatelessWidget {
  const FreelancerSettingsScreen({super.key});

  static const bgDark = Color(0xFF080808);
  static const cardColor = Color(0xFF121214);
  static const textMuted = Color(0xFF71717A);
  static const borderDark = Color(0xFF1C1C1E);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgDark,
      appBar: AppBar(
        backgroundColor: bgDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Configuracion',
          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==========================================
            // SECCIÓN: CUENTA
            // ==========================================
            const Padding(
              padding: EdgeInsets.only(left: 4, bottom: 12),
              child: Text(
                'Cuenta',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderDark.withAlpha(128)),
              ),
              child: Column(
                children: [
                  _buildSettingOption(Icons.security_outlined, 'Seguridad'),
                  _buildDivider(),
                  _buildSettingOption(Icons.credit_card_rounded, 'Metodos de Pago'),
                  _buildDivider(),
                  _buildSettingOption(Icons.visibility_outlined, 'Privacidad'),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // ==========================================
            // SECCIÓN: SOPORTE
            // ==========================================
            const Padding(
              padding: EdgeInsets.only(left: 4, bottom: 12),
              child: Text(
                'Soporte',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderDark.withAlpha(128)),
              ),
              child: Column(
                children: [
                  _buildSettingOption(Icons.help_outline_rounded, 'Centro de Ayuda'),
                  _buildDivider(),
                  _buildSettingOption(Icons.chat_bubble_outline_rounded, 'Contactar Soporte'),
                ],
              ),
            ),
            const SizedBox(height: 48),

            // ==========================================
            // PIE DE PÁGINA: VERSION
            // ==========================================
            const Center(
              child: Text(
                'DevMarket v1.0.0',
                style: TextStyle(color: textMuted, fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingOption(IconData icon, String title) {
    return ListTile(
      onTap: () {
        // Lógica para cada opción de configuración
      },
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Icon(icon, color: Colors.white, size: 22),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500),
      ),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, color: textMuted, size: 14),
    );
  }

  Widget _buildDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 1,
      color: borderDark,
    );
  }
}