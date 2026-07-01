// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart'; 
import 'package:overlay_support/overlay_support.dart'; // 🟢 Importación para notificaciones flotantes tipo WhatsApp
import 'package:devmarket_app/screens/login_screen.dart'; 
import 'package:devmarket_app/screens/register_screen.dart'; 
import 'package:devmarket_app/screens/main_screen.dart'; 
import 'package:devmarket_app/screens/freelancer/freelancer_main_layout.dart'; 
import 'package:devmarket_app/screens/auth/auth_onboarding_screen.dart';
import 'package:devmarket_app/screens/chats_screen.dart'; // 🟢 Importación de tu pantalla real de chats

void main() async { 
  WidgetsFlutterBinding.ensureInitialized();

  // 💳 Inicializamos Stripe
  Stripe.publishableKey = "pk_test_51TaOkPKK0OQ7CMIiwZclwHkuu2UQA7Qh1hEc1g3uk77uFDMPND4pn4nczZA6cu9Y26cEebtFszrSSf5wxodbarRx00YMzkxdXR";
  await Stripe.instance.applySettings();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 🟢 Envolvemos todo el árbol con OverlaySupport.global para habilitar los banners in-app
    return OverlaySupport.global(
      child: MaterialApp(
        title: 'DevMarket',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          scaffoldBackgroundColor: Colors.black, 
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF00E676), 
            surface: Colors.black,
          ),
          useMaterial3: true,
        ),
        initialRoute: '/login',
        routes: {
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(), 
          
          '/home': (context) => const MainScreen(), // Layout del Cliente
          
          // 🟢 AGREGADO: Vinculamos la ruta exacta para que la campana y las notis sepan a dónde ir
          '/chats': (context) => const ChatsScreen(), 
          
          // Rutas de redirección que usa tu RegisterScreen:
          '/freelancer-home': (context) => const FreelancerMainLayout(), 
          '/freelancer_dashboard': (context) => const FreelancerMainLayout(), 
          '/oauth_onboarding': (context) => const AuthOnboardingScreen(),
        },
      ),
    );
  }
}

// Pantalla temporal para rutas que aún estén en desarrollo
class TemporaryMockScreen extends StatelessWidget {
  final String title;
  const TemporaryMockScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.transparent, iconTheme: const IconThemeData(color: Colors.white)),
      body: Center(
        child: Text('$title\n(En desarrollo)', textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey, fontSize: 18)),
      ),
    );
  }
}