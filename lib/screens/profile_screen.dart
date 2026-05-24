// lib/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'edit_profile_screen.dart';
import 'order_history_screen.dart'; 
import 'settings_screen.dart'; 
import 'notifications_screen.dart'; 

class ProfileScreen extends StatefulWidget {
  // Parámetros recibidos desde main.dart para controlar el rol global
  final bool isFreelancer;
  final ValueChanged<bool> onRoleChanged;

  const ProfileScreen({
    super.key,
    required this.isFreelancer,
    required this.onRoleChanged,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Variables de estado del perfil
  String _name = 'Juan García';
  String _email = 'juan@email.com';
  String _phone = '+52 55 1234 5678';
  String _location = 'Ciudad de México';

  @override
  Widget build(BuildContext context) {
    const accentColor = Color(0xFF10B981);
    const cardColor = Color(0xFF121214);
    const bgDark = Color(0xFF080808);

    return Scaffold(
      backgroundColor: bgDark,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // --- CABECERA (SWITCH DE CAMBIO DE ROL) ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: accentColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Text(
                          'DM',
                          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'DevMarket',
                        style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        'Cliente', 
                        style: TextStyle(color: widget.isFreelancer ? Colors.grey : accentColor, fontSize: 12),
                      ),
                      Switch(
                        value: widget.isFreelancer,
                        activeThumbColor: accentColor,
                        activeTrackColor: accentColor.withValues(alpha: 0.3),
                        onChanged: widget.onRoleChanged, // Notifica directamente a main.dart
                      ),
                      Text(
                        'Freelancer', 
                        style: TextStyle(color: widget.isFreelancer ? accentColor : Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // --- TARJETA DE PERFIL ---
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF064E3B), width: 2),
                      ),
                      child: const CircleAvatar(
                        radius: 50,
                        backgroundColor: Color(0xFF1C1C1E),
                        child: Icon(Icons.person, size: 50, color: Colors.grey),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _name,
                      style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _email,
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF022C22),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Cliente Premium',
                        style: TextStyle(color: accentColor, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // --- SECCIÓN ESTADÍSTICAS ---
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Estadísticas',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    IntrinsicHeight(
                      child: Row(
                        children: [
                          _buildStatItem('12', 'Pedidos'),
                          _buildVerticalDivider(),
                          _buildStatItem('\$4.2K', 'Invertido', valueColor: accentColor),
                          _buildVerticalDivider(),
                          _buildStatItem('4.8', 'Rating'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // --- MENÚ DE OPCIONES ---
              _buildMenuOption(Icons.person_outline, 'Editar Perfil'),
              _buildMenuOption(Icons.folder_open_outlined, 'Historial de Pedidos'),
              _buildMenuOption(Icons.settings_outlined, 'Configuración'),
              _buildMenuOption(Icons.notifications_none_outlined, 'Notificaciones'),
              _buildMenuOption(Icons.logout_rounded, 'Cerrar Sesión', isDestructive: true),
            ],
          ),
        ),
      ),
    );
  }

  // Widget helper para cada elemento de estadística
  Widget _buildStatItem(String value, String label, {Color valueColor = Colors.white}) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(color: valueColor, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }

  // Divisor vertical entre estadísticas
  Widget _buildVerticalDivider() {
    return VerticalDivider(color: Colors.grey[900], thickness: 1, indent: 4, endIndent: 4);
  }

  // Widget helper para construir las opciones del menú
  Widget _buildMenuOption(IconData icon, String title, {bool isDestructive = false}) {
    final textColor = isDestructive ? const Color(0xFFEF4444) : Colors.white;
    final iconColor = isDestructive ? const Color(0xFFEF4444) : Colors.white;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF121214),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1C1C1E)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        leading: Icon(icon, color: iconColor, size: 22),
        title: Text(title, style: TextStyle(color: textColor, fontSize: 15, fontWeight: FontWeight.w500)),
        onTap: () async {
          if (title == 'Editar Perfil') {
            final result = await Navigator.push<Map<String, String>>(
              context,
              MaterialPageRoute(
                builder: (context) => EditProfileScreen(
                  currentName: _name,
                  currentEmail: _email,
                  currentPhone: _phone,
                  currentLocation: _location,
                ),
              ),
            );

            if (result != null && mounted) {
              setState(() {
                _name = result['name'] ?? _name;
                _email = result['email'] ?? _email;
                _phone = result['phone'] ?? _phone;
                _location = result['location'] ?? _location;
              });
            }
          } 
          else if (title == 'Historial de Pedidos') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const OrderHistoryScreen(),
              ),
            );
          }
          else if (title == 'Configuración') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SettingsScreen(),
              ),
            );
          }
          else if (title == 'Notificaciones') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const NotificationsScreen(),
              ),
            );
          }
        },
      ),
    );
  }
}