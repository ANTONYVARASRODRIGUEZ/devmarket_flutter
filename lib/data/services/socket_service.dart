import 'package:flutter/material.dart'; 
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'api_service.dart';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  IO.Socket? _socket;
  bool _isConnected = false;

  IO.Socket? get socket => _socket;
  bool get isConnected => _isConnected;

 
  Future<void> connect() async {
    if (_socket != null && _socket!.connected) return;

    final token = await ApiService().getToken();
    if (token == null) {
      
      debugPrint("🚨 Sockets: No se puede conectar porque no hay un token de autenticación.");
      return;
    }

    // Usamos la IP del emulador apuntando a tu backend puerto 4000
    _socket = IO.io('https://tecsup-fiver-backend.onrender.com', IO.OptionBuilder()
      .setTransports(['websocket']) // Crucial para evitar problemas de CORS/Polling
      .enableAutoConnect()        // 🟢 MEJORA: Permite que el cliente intente reconectar automáticamente si cae el server
      .setAuth({'token': token})   // Envía el token igual que lo espera tu backend en socket.handshake.auth
      .build()
    );

    _socket!.connect();

    _socket!.onConnect((_) {
      _isConnected = true;
      // 🟢 Cambiado a debugPrint
      debugPrint('🚀 Sockets: ¡Conectado exitosamente en tiempo real con el backend!');
    });

    _socket!.onDisconnect((_) {
      _isConnected = false;
      // 🟢 Cambiado a debugPrint
      debugPrint('🛑 Sockets: Desconectado del servidor.');
    });
    
    // 🟢 Agregado por seguridad para debugging de errores de conexión
    _socket!.onConnectError((data) {
      debugPrint('🚨 Sockets Error de Conexión: $data');
    });
  }

  void disconnect() {
    _socket?.disconnect();
    _socket = null;
    _isConnected = false;
  }
}