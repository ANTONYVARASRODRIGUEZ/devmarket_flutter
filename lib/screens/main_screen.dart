import 'package:flutter/material.dart';
import 'package:devmarket_app/screens/explore_screen.dart'; 
import 'package:devmarket_app/screens/my_orders_screen.dart';
import 'package:devmarket_app/screens/chats_screen.dart'; 
import 'package:devmarket_app/data/services/socket_service.dart'; 
import 'package:devmarket_app/screens/profile_screen.dart'; // ➕ Importa tu pantalla real
import 'package:devmarket_app/data/services/api_service.dart'; // ➕ Necesario para pasárselo al perfil

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // 🔢 Índice de la pantalla activa
  int _selectedIndex = 0;

  // 📺 Lista de las pantallas reales de tu aplicación
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    
    // 🔥 Conexión en vivo por Sockets
    SocketService().connect();

    // 🎯 Ajustado: Se removió la pantalla de servicios del freelancer
    _screens = [
      const ExploreScreen(),   // 0: Inicio
      const MyOrdersScreen(),  // 1: Proyectos
      const ChatsScreen(),     // 2: Chats
      
      // 🟢 REEMPLAZA EL TEXTO TEMPORAL POR ESTA LÍNEA:
      ProfileScreen(apiService: ApiService()), // 3: Perfil Real Conectado al Backend
    ];
  }

  @override
  Widget build(BuildContext context) {
    const accentColor = Color(0xFF10B981); 

    return Scaffold(
      backgroundColor: const Color(0xFF080808), 
      body: _screens[_selectedIndex],

      // 📦 Barra inferior fija estilo DevMarket
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index; 
          });
        },
        type: BottomNavigationBarType.fixed, 
        backgroundColor: const Color(0xFF121214), 
        selectedItemColor: accentColor, 
        unselectedItemColor: const Color(0xFF71717A), 
        selectedFontSize: 12,
        unselectedFontSize: 12,
        showUnselectedLabels: true, 
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder_open_outlined),
            activeIcon: Icon(Icons.folder),
            label: 'Proyectos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            activeIcon: Icon(Icons.chat_bubble),
            label: 'Chats',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}