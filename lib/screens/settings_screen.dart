// lib/screens/settings_screen.dart
import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const bgDark = Color(0xFF080808);
    const cardColor = Color(0xFF121214);
    const dividerColor = Color(0xFF1C1C1E);

    return Scaffold(
      backgroundColor: bgDark,
      appBar: AppBar(
        backgroundColor: bgDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Configuracion',
          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        titleSpacing: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // --- SECCIÓN: CUENTA ---
              _buildSettingsGroup(
                title: 'Cuenta',
                cardColor: cardColor,
                dividerColor: dividerColor,
                items: [
                  _buildSettingsItem(Icons.shield_outlined, 'Seguridad'),
                  _buildSettingsItem(Icons.credit_card_outlined, 'Metodos de Pago'),
                  _buildSettingsItem(Icons.visibility_outlined, 'Privacidad'),
                ],
              ),
              const SizedBox(height: 20),

              // --- SECCIÓN: SOPORTE ---
              _buildSettingsGroup(
                title: 'Soporte',
                cardColor: cardColor,
                dividerColor: dividerColor,
                items: [
                  _buildSettingsItem(Icons.help_outline_rounded, 'Centro de Ayuda'),
                  _buildSettingsItem(Icons.chat_bubble_outline_rounded, 'Contactar Soporte'),
                ],
              ),
              const SizedBox(height: 32),

              // --- VERSION FOOTER ---
              const Center(
                child: Text(
                  'DevMarket v1.0.0',
                  style: TextStyle(color: Color(0xFF3F3F46), fontSize: 13, fontWeight: FontWeight.w400),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Contenedor agrupador con diseño de tarjeta redondeada
  Widget _buildSettingsGroup({
    required String title,
    required List<Widget> items,
    required Color cardColor,
    required Color dividerColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0, bottom: 12.0),
          child: Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: dividerColor),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (context, index) => Divider(color: dividerColor, height: 1, thickness: 1),
            itemBuilder: (context, index) => items[index],
          ),
        ),
      ],
    );
  }

  // Fila individual de configuración con flecha indicadora
  Widget _buildSettingsItem(IconData icon, String label) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Icon(icon, color: Colors.white, size: 22),
      title: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w400),
      ),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFF52525B), size: 14),
      onTap: () {
        // Enrutamiento futuro para cada opción
      },
    );
  }
}