// main.dart
import 'package:flutter/material.dart';
import 'screens/explore_screen.dart';
import 'screens/my_orders_screen.dart'; 
import 'screens/chats_screen.dart'; 
import 'screens/profile_screen.dart'; 
import 'screens/freelancer/freelancer_home_screen.dart'; 
import 'screens/freelancer/freelancer_projects_screen.dart'; 
import 'screens/freelancer/freelancer_chats_screen.dart'; 
// 🔑 IMPORTACIÓN NUEVA: Tu pantalla de perfil especializada para freelancer
import 'screens/freelancer/freelancer_profile_screen.dart'; 

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DevMarket',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF080808),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF10B981),
          surface: const Color(0xFF080808),
        ),
        useMaterial3: true,
      ),
      home: const MainLayout(), 
    );
  }
}

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;
  
  // 🔄 ESTADO GLOBAL DEL ROL (Empieza en falso = Cliente)
  bool _isFreelancer = false; 

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // 🎯 FUNCIÓN PARA CAMBIAR EL ROL DESDE CUALQUIER PANTALLA
  void _toggleRole(bool value) {
    setState(() {
      _isFreelancer = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    const accentColor = Color(0xFF10B981);

    // 👥 PANTALLAS EN MODO CLIENTE
    final List<Widget> clientScreens = [
      ExploreScreen(isFreelancer: _isFreelancer, onRoleChanged: _toggleRole),   
      MyOrdersScreen(isFreelancer: _isFreelancer, onRoleChanged: _toggleRole),  
      ChatsScreen(isFreelancer: _isFreelancer, onRoleChanged: _toggleRole),     
      ProfileScreen(isFreelancer: _isFreelancer, onRoleChanged: _toggleRole),
    ];

    // 🛠️ PANTALLAS EN MODO FREELANCER
    final List<Widget> freelancerScreens = [
      FreelancerHomeScreen(isFreelancer: _isFreelancer, onRoleChanged: _toggleRole), 
      FreelancerProjectsScreen(isFreelancer: _isFreelancer, onRoleChanged: _toggleRole), 
      FreelancerChatsScreen(isFreelancer: _isFreelancer, onRoleChanged: _toggleRole),     
      
      // 🚀 VINCULACIÓN EXITOSA: Cambiamos la pantalla genérica por la exclusiva del Freelancer
      FreelancerProfileScreen(isFreelancer: _isFreelancer, onRoleChanged: _toggleRole),
    ];

    // Selecciona el set de pantallas correcto en base al Switch global
    final currentScreens = _isFreelancer ? freelancerScreens : clientScreens;

    return Scaffold(
      body: currentScreens[_selectedIndex], 
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.business_center_outlined), activeIcon: Icon(Icons.business_center), label: 'Proyectos'),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), activeIcon: Icon(Icons.chat_bubble), label: 'Chats'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Perfil'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: accentColor,
        unselectedItemColor: Colors.grey,
        backgroundColor: const Color(0xFF121214), // Mantiene la consistencia de diseño premium
        type: BottomNavigationBarType.fixed, 
        onTap: _onItemTapped,
      ),
    );
  }
}