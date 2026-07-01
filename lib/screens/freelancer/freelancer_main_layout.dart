// lib/screens/freelancer/freelancer_main_layout.dart
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:devmarket_app/screens/freelancer/freelancer_home_screen.dart'; 
import 'package:devmarket_app/screens/freelancer/freelancer_projects_screen.dart';
import 'package:devmarket_app/screens/freelancer/freelancer_chats_screen.dart'; 
import 'package:devmarket_app/screens/freelancer/freelancer_services_screen.dart'; // 🟢 INTEGRADA: Tu pantalla de gestión de servicios
import 'package:devmarket_app/screens/freelancer/freelancer_profile_screen.dart'; // 🟢 1. IMPORTADO: Tu perfil real sin providers

// Placeholder temporal solo para Perfil (hasta que lo crees)
class FreelancerProfilePage extends StatelessWidget { const FreelancerProfilePage({super.key}); @override Widget build(BuildContext context) => const Scaffold(backgroundColor: Color(0xFF0C0C0E), body: Center(child: Text('Perfil', style: TextStyle(color: Colors.white)))); }

class FreelancerMainLayout extends StatefulWidget {
  const FreelancerMainLayout({super.key});

  @override
  State<FreelancerMainLayout> createState() => _FreelancerMainLayoutState();
}

class _FreelancerMainLayoutState extends State<FreelancerMainLayout> {
  int _currentIndex = 0;

  // 🟢 Mapeo dinámico de las páginas según el índice actual
  Widget _buildPage(int index) {
    switch (index) {
      case 0:
        return const SellerDashboardPage();      // 0: Inicio / Dashboard
      case 1:
        return const FreelancerServicesScreen(); // 🟢 1: ¡AQUÍ ESTÁ! Tus servicios justo después de Inicio
      case 2:
        return const FreelancerProjectsScreen(); // 2: Proyectos / Pedidos en curso
      case 3:
        return const FreelancerChatsScreen();    // 3: Chats en tiempo real
      case 4:
        return const FreelancerProfileScreen();  // 🟢 2. INTEGRADO: Cambiado el placeholder por tu pantalla real
      default:
        return const SellerDashboardPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFF0C0C0E);
    const navBarColor = Color(0xFF121214); 
    const primaryColor = Color(0xFF00E676);  

    return Scaffold(
      backgroundColor: backgroundColor,
      body: _buildPage(_currentIndex),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: Color(0xFF1C1C1E), width: 1.0), 
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: navBarColor,
          selectedItemColor: primaryColor,
          unselectedItemColor: Colors.grey.shade600,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          iconSize: 22,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(LucideIcons.home),
              label: 'Inicio',
            ),
            // 🟢 ÍNDICE 1: Pestaña "Servicios" agregada correctamente después de Inicio
            BottomNavigationBarItem(
              icon: Icon(LucideIcons.wrench), // Usamos un icono de herramienta para servicios
              label: 'Servicios',
            ),
            BottomNavigationBarItem(
              icon: Icon(LucideIcons.folder), 
              label: 'Proyectos',
            ),
            BottomNavigationBarItem(
              icon: Icon(LucideIcons.messageSquare),
              label: 'Chats',
            ),
            BottomNavigationBarItem(
              icon: Icon(LucideIcons.user),
              label: 'Perfil',
            ),
          ],
        ),
      ),
    );
  }
}