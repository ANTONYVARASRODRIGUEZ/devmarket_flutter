// lib/data/services/api_service.dart
import 'dart:convert'; 
import 'package:dio/dio.dart';
import 'package:flutter/material.dart'; // 🟢 Necesario para debugPrint
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {

  // 👇 SINGLETON PATTERN 👇
  static final ApiService _instance = ApiService._internal();
  
  factory ApiService() {
    return _instance;
  }
  
  ApiService._internal() {
    // 🚀 CAMBIADO: URL base global apuntando a tu backend real en Render con HTTPS
    dio.options.baseUrl = "https://tecsup-fiver-backend.onrender.com/api";

    // 🚀 CAMBIADO: Limpieza de cabeceras para producción (eliminamos el 'Origin' local)
    dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json', 
    };

    // Inicializamos el interceptor para inyectar el token automáticamente
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
      ),
    );
  }
  // 👆 FIN SINGLETON 👆
  
  // Instancia pública de Dio accesible para Sockets u otras configuraciones externas
  final Dio dio = Dio();
  
  // Almacenamiento seguro local
  final _storage = const FlutterSecureStorage();

  /// 💬 OBTENER LISTA DE CHATS DESDE LA API
  Future<List<dynamic>> getChats() async {
    try {
      final response = await dio.get('/chats'); 
      if (response.statusCode == 200) {
        var responseData = response.data;
        if (responseData is String) {
          responseData = jsonDecode(responseData);
        }
        if (responseData is Map && responseData['data'] != null) {
          return responseData['data'] as List<dynamic>;
        }
        if (responseData is List) {
          return responseData;
        }
      }
      return [];
    } catch (_) {
      return [];
    }
  }


  /// 💬 OBTENER HISTORIAL DE MENSAJES DE UNA CONVERSACIÓN ESPECÍFICA
  Future<List<dynamic>> getMensajesConversacion(String conversationId) async {
    try {
      // 🚀 CORREGIDO: Eliminamos '/messages' del final para coincidir con tu backend Express
      final response = await dio.get('/chats/$conversationId'); 
      
      if (response.statusCode == 200) {
        var responseData = response.data;

        if (responseData is String) {
          responseData = jsonDecode(responseData);
        }

        if (responseData is Map && responseData['data'] != null) {
          return responseData['data'] as List<dynamic>;
        }

        if (responseData is List) {
          return responseData;
        }
      }
      return [];
    } catch (e) {
      debugPrint("🚨 Error en ApiService al traer mensajes: $e");
      return [];
    }
  }

  /// 🌟 OBTENER ESTADÍSTICAS DE RESEÑAS Y COMENTARIOS
  Future<Map<String, dynamic>> getServiceReviewsStats(String serviceId) async {
    try {
      final response = await dio.get('/reviews/service/$serviceId');
      
      if (response.statusCode == 200) {
        var responseData = response.data;

        if (responseData is String) {
          responseData = jsonDecode(responseData);
        }

        if (responseData is Map && responseData['data'] != null) {
          final data = responseData['data'] as Map<String, dynamic>;
          return {
            'stats': data['stats'] ?? {'total': 0, 'average': 0.0},
            'reviews': data['reviews'] ?? [] 
          };
        }
      }
      return {'stats': {'total': 0, 'average': 0.0}, 'reviews': []};
    } catch (_) {
      return {'stats': {'total': 0, 'average': 0.0}, 'reviews': []}; 
    }
  }

  /// 🟢 REGISTRO DE USUARIO MODIFICADO
  Future<Map<String, dynamic>> register({
    required String name,
    required String username,
    required String email,
    required String password,
    required String role, // 1. 🟢 Agregamos el rol como parámetro requerido
  }) async {
    try {
      final response = await dio.post(
        '/auth/register',
        data: {
          'name': name,
          'username': username,
          'email': email,
          'password': password,
          'role': role // 2. 🟢 Pasamos la variable dinámica ('CLIENT' o 'FREELANCER')
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return response.data;
      }
      throw Exception('Error en el registro');
    } on DioException catch (e) {
      final backendMessage = e.response?.data['message'] ?? 
                             (e.response?.data['issues'] != null ? e.response?.data['issues'].toString() : null) ?? 
                             'Error en los datos';
                             
      throw Exception(backendMessage);
    }
  }
  

  /// 🟢 VERIFICAR CÓDIGO DE CORREO
  Future<Map<String, dynamic>> verifyEmail({
    required String email,
    required String code,
  }) async {
    try {
      final response = await dio.post(
        '/auth/verify-email', // 👈 Revisa si tu endpoint se llama así en Node
        data: {
          'email': email,
          'code': code,
        },
      );

      if (response.statusCode == 200) {
        return response.data;
      }
      throw Exception('Código inválido o expirado');
    } on DioException catch (e) {
      final backendMessage = e.response?.data['message'] ?? 'Error al verificar el código';
      throw Exception(backendMessage);
    }
  }

  /// 🔵 INICIO DE SESIÓN (LOGIN)
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await dio.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        debugPrint("🔍 RESPUESTA COMPLETA DEL BACKEND EN LOGIN: ${response.data}");

        String? token = response.data['token'];
        String? userId = response.data['user'] != null ? response.data['user']['id'] : null;
        
        // 🟢 NUEVO: Extraer rol inicial desde la raíz si viene ahí
        String? role = response.data['user'] != null ? response.data['user']['role'] : null;
        
        if (token == null && response.data['data'] != null) {
          token = response.data['data']['token'];
          userId = response.data['data']['user'] != null ? response.data['data']['user']['id'] : null;
          
          // 🟢 NUEVO: Extraer rol si la respuesta viene empaquetada dentro de 'data'
          role = response.data['data']['user'] != null ? response.data['data']['user']['role'] : null;
        }
        if (token == null && response.data['user'] != null) {
          token = response.data['user']['token'];
        }

        debugPrint("🔮 TOKEN DETECTADO Y PROCESADO: $token");
        debugPrint("🆔 USER ID DETECTADO: $userId");
        debugPrint("👤 ROL DETECTADO: $role");
        
        if (token != null) {
          await _storage.write(key: 'auth_token', value: token);
        } else {
          debugPrint("🚨 ERROR CRÍTICO: El login fue exitoso pero no se encontró el token.");
        }

        if (userId != null) {
          await _storage.write(key: 'user_id', value: userId.toString());
        }

        // 🟢 NUEVO: Almacenar el rol de forma segura en las preferencias locales si existe
        if (role != null) {
          await _storage.write(key: 'user_role', value: role.toString());
        }
        
        return response.data;
      }
      throw Exception('Credenciales incorrectas');
    } on DioException catch (e) {
      final errorMessage = e.response?.data['message'] ?? 'Error al iniciar sesión';
      throw Exception(errorMessage);
    }
  }

  /// 🔴 INICIO DE SESIÓN CON GOOGLE (MÓVIL)
  Future<Map<String, dynamic>> loginWithGoogle({
    required String googleIdToken,
    String? role, // 'CLIENT' o 'FREELANCER' (Opcional según tu backend)
  }) async {
    try {
      final response = await dio.post(
        '/auth/google',
        data: {
          'token': googleIdToken,
          if (role != null) 'role': role,
        },
      );

      if (response.statusCode == 200) {
        debugPrint("🔍 RESPUESTA COMPLETA DE GOOGLE LOGIN: ${response.data}");

        // El controlador de tu backend devuelve { status: 'success', data: result }
        // result suele traer el token, el user, etc.
        var dataContainer = response.data['data'] ?? response.data;

        String? token = dataContainer['token'];
        String? userId = dataContainer['user'] != null ? dataContainer['user']['id'] : null;
        String? role = dataContainer['user'] != null ? dataContainer['user']['role'] : null;

        // Si tu backend anida el token diferente en flujos OAuth, hacemos fallback igual que en tu login
        if (token == null && dataContainer['user'] != null) {
          token = dataContainer['user']['token'];
        }

        debugPrint("🔮 GOOGLE TOKEN DETECTADO: $token");
        debugPrint("🆔 GOOGLE USER ID DETECTADO: $userId");
        debugPrint("👤 GOOGLE ROL DETECTADO: $role");
        
        if (token != null) {
          await _storage.write(key: 'auth_token', value: token);
        } else {
          debugPrint("🚨 ERROR CRÍTICO OAUTH: Se autenticó con Google pero no llegó un JWT en la respuesta.");
        }

        if (userId != null) {
          await _storage.write(key: 'user_id', value: userId.toString());
        }

        if (role != null) {
          await _storage.write(key: 'user_role', value: role.toString());
        }
        
        return response.data;
      }
      throw Exception('Error al autenticar con Google');
    } on DioException catch (e) {
      final errorMessage = e.response?.data['message'] ?? 'Error al conectar con Google Auth';
      throw Exception(errorMessage);
    }
  }

  /// 🟡 OBTENER SERVICIOS
  Future<List<dynamic>> getServices() async {
    try {
      final response = await dio.get('/freelance/explore');
      
      if (response.statusCode == 200) {
        var responseData = response.data;

        if (responseData is String) {
          try {
            responseData = jsonDecode(responseData);
          } catch (_) {
            throw Exception('El backend devolvió texto plano que no es un JSON válido');
          }
        }

        if (responseData != null) {
          if (responseData is Map && responseData['data'] != null) {
            if (responseData['data'] is List) {
              return responseData['data'];
            }
          }
          if (responseData is List) {
            return responseData;
          }
        }
        return [];
      }
      throw Exception('Error al obtener servicios (Status: ${response.statusCode})');
    } on DioException catch (e) {
      final errorMessage = e.response?.data is Map 
          ? (e.response?.data['message'] ?? 'Error de red')
          : 'Error de servidor (${e.response?.statusCode})';
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('Error interno al procesar los datos: $e');
    }
  }

  /// 💜 OBTENER PERFIL DEL FREELANCER
  Future<Map<String, dynamic>?> getFreelancerProfile(String userId) async {
    try {
      final response = await dio.get('/users/$userId');

      if (response.statusCode == 200) {
        var responseData = response.data;

        if (responseData is String) {
          responseData = jsonDecode(responseData);
        }

        if (responseData is Map && responseData['data'] != null) {
          return responseData['data'] as Map<String, dynamic>;
        }

        if (responseData is Map) {
          return responseData as Map<String, dynamic>;
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// 🛒 OBTENER PEDIDOS DEL CLIENTE AUTENTICADO
  Future<List<dynamic>> getMisPedidos() async {
    try {
      final response = await dio.get('/orders/my-orders');

      if (response.statusCode == 200) {
        var responseData = response.data;

        if (responseData is String) {
          responseData = jsonDecode(responseData);
        }

        if (responseData != null) {
          if (responseData is Map && responseData['data'] != null) {
            if (responseData['data'] is List) {
              return responseData['data'];
            }
          }
          if (responseData is List) {
            return responseData;
          }
        }
        return [];
      }
      throw Exception('Error al obtener pedidos (Status: ${response.statusCode})');
    } on DioException catch (e) {
      final errorMessage = e.response?.data is Map
          ? (e.response?.data['message'] ?? 'Error de red en pedidos')
          : 'Error de servidor en pedidos (${e.response?.statusCode})';
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('Error interno al procesar pedidos: $e');
    }
  }


  // ==========================================
  // 💼 SECCIÓN FREELANCER / VENDEDOR 💼
  // ==========================================

  /// 💰 OBTENER RESUMEN DE GANANCIAS DEL VENDEDOR
  Future<Map<String, dynamic>> getEarningsSummary() async {
    try {
      final response = await dio.get('/earnings/summary'); // Asegúrate de que coincida con tu endpoint de Next.js
      if (response.statusCode == 200) {
        var responseData = response.data;
        if (responseData is String) responseData = jsonDecode(responseData);
        
        if (responseData is Map && responseData['data'] != null) {
          return responseData['data'] as Map<String, dynamic>;
        }
        if (responseData is Map) return responseData as Map<String, dynamic>;
      }
      return {'total': 0.0, 'available': 0.0};
    } catch (e) {
      debugPrint("🚨 Error en getEarningsSummary: $e");
      return {'total': 0.0, 'available': 0.0};
    }
  }

  /// 📦 OBTENER PEDIDOS RECIBIDOS (COMO VENDEDOR / FREELANCER)
  Future<List<dynamic>> getReceivedOrders() async {
    try {
      // 🟢 CORREGIDO: Ahora apunta exactamente a la ruta de tu Express: /orders/my-sales
      final response = await dio.get('/orders/my-sales'); 
      
      if (response.statusCode == 200) {
        var responseData = response.data;
        if (responseData is String) responseData = jsonDecode(responseData);

        // Si tu controlador Express envuelve el resultado en { status: 'success', data: [...] }
        if (responseData is Map && responseData['data'] != null) {
          if (responseData['data'] is List) return responseData['data'];
        }
        
        // Si tu controlador devuelve directamente el arreglo de Prisma (return res.json(orders))
        if (responseData is List) return responseData;
      }
      return [];
    } catch (e) {
      debugPrint("🚨 Error en getReceivedOrders de ApiService: $e");
      return [];
    }
  }


  /// 📈 ACTUALIZAR EL PROGRESO DE UN PEDIDO (FASE DEL PROYECTO)
  Future<bool> updateProgress(String orderId, int progress) async {
    try {
      // 🟢 CORREGIDO: Cambiado de .put a .patch para que haga match con tu backend Express
      final response = await dio.patch(
        '/orders/$orderId/progress',
        data: {
          'progress': progress,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint("✅ Progreso actualizado con éxito a: $progress%");
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("🚨 Error en updateProgress de ApiService: $e");
      return false;
    }
  }

  /// 🛠️ OBTENER MIS SERVICIOS PROPIOS (Para calcular la Calificación Global)
  Future<List<dynamic>> getMyServices() async {
    try {
      final response = await dio.get('/freelance/my-services'); // Cambiar a tu ruta exacta de Next
      if (response.statusCode == 200) {
        var responseData = response.data;
        if (responseData is String) responseData = jsonDecode(responseData);

        if (responseData is Map && responseData['data'] != null) {
          if (responseData['data'] is List) return responseData['data'];
        }
        if (responseData is List) return responseData;
      }
      return [];
    } catch (e) {
      debugPrint("🚨 Error en getMyServices: $e");
      return [];
    }
  }

  /// 🛑 CERRAR SESIÓN (LOGOUT)
  Future<void> logout() async {
    await _storage.delete(key: 'auth_token');
    await _storage.delete(key: 'user_id');
    await _storage.delete(key: 'user_role'); // 🟢 NUEVO: Limpia el rol al desloguearse
  }

  /// 🔑 LEER EL TOKEN GUARDADO
  Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }

  /// 🆔 LEER EL ID DE USUARIO GUARDADO
  Future<String?> getUserId() async {
    return await _storage.read(key: 'user_id');
  }

  /// 👤 NUEVO: LEER EL ROL DE USUARIO GUARDADO (Para consumirse desde CustomHeader)
  Future<String?> getUserRole() async {
    return await _storage.read(key: 'user_role');
  }


  /// 🛡️ VERIFICAR SI EL USUARIO YA COMPRÓ ESTE SERVICIO (Para habilitar el chat)
  Future<bool> checkServiceAccess(String serviceId) async {
    try {
      // Conecta con: http://10.0.2.2:4000/api/payments/check-access/:serviceId
      final response = await dio.get('/payments/check-access/$serviceId');
      
      if (response.statusCode == 200) {
        var responseData = response.data;
        if (responseData is String) {
          responseData = jsonDecode(responseData);
        }
        
        // Adaptado a la estructura estándar de tus respuestas { status: 'success', data: ... }
        if (responseData is Map) {
          return responseData['hasAccess'] ?? responseData['data']?['hasAccess'] ?? false;
        }
      }
      return false;
    } catch (e) {
      debugPrint("⚠️ Error verificando acceso al servicio $serviceId en ApiService: $e");
      return false;
    }
  }



  /// 💳 CREAR INTENTO DE PAGO EN STRIPE
  Future<Map<String, dynamic>?> createPaymentIntent(String serviceId) async {
    try {
      // 🟢 Obtenemos el userId almacenado localmente en el storage seguro
      final userId = await getUserId();

      final response = await dio.post(
        '/payments/create-intent',
        data: { 
          'serviceId': serviceId,
          'userId': userId // 👈 Se lo inyectamos directamente en el body al backend
        },
      );

      if (response.statusCode == 200) {
        var responseData = response.data;
        if (responseData is String) {
          responseData = jsonDecode(responseData);
        }
        
        if (responseData is Map && responseData['success'] == true) {
          return responseData['data'] as Map<String, dynamic>;
        }
      }
      return null;
    } catch (e) {
      debugPrint("🚨 Error en createPaymentIntent de ApiService: $e");
      return null;
    }
  }

  /// 🔵 COMPLETAR ONBOARDING (Actualizar Username y Rol después de OAuth)
  Future<bool> completarOnboarding({
    required String username,
    required String role,
  }) async {
    try {
      final response = await dio.post(
        '/auth/oauth/onboarding', // 🟢 CORREGIDO: Ahora coincide exactamente con el backend de tu amigo (/auth + /oauth/onboarding)
        data: {
          'username': username,
          'role': role,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        var dataContainer = response.data['data'] ?? response.data;
        if (dataContainer is Map && dataContainer['user'] != null) {
          final String? nuevoRole = dataContainer['user']['role'];
          if (nuevoRole != null) {
            await _storage.write(key: 'user_role', value: nuevoRole.toLowerCase());
          }
        } else if (dataContainer is Map && dataContainer['role'] != null) {
          await _storage.write(key: 'user_role', value: dataContainer['role'].toString().toLowerCase());
        } else {
          await _storage.write(key: 'user_role', value: role.toLowerCase());
        }
        return true;
      }
      return false;
    } on DioException catch (e) {
      final errorMessage = e.response?.data['message'] ?? 'Error en el onboarding';
      debugPrint("🚨 Error en completarOnboarding: $errorMessage");
      return false;
    } catch (e) {
      debugPrint("🚨 Error interno en completarOnboarding: $e");
      return false;
    }
  }

  // ==========================================
  // 💼 NUEVOS MÉTODOS COMPLETAMENTE CONECTADOS 💼
  // ==========================================

  /// 💳 OBTENER DETALLES DEL PLAN Y LÍMITES REALES (Ruta: /subscriptions/my-plan)
  Future<Map<String, dynamic>?> getMyPlanDetails() async {
    try {
      final response = await dio.get('/subscriptions/my-plan');
      if (response.statusCode == 200 && response.data != null) {
        final responseData = response.data;
        if (responseData is Map && responseData['data'] != null) {
          return responseData['data'] as Map<String, dynamic>;
        }
      }
      return null;
    } catch (e) {
      debugPrint("🚨 Error al obtener el plan real de /subscriptions/my-plan: $e");
      return null;
    }
  }

  /// 🏷️ OBTENER CATEGORÍAS REALES DESDE EL BACKEND
  Future<List<dynamic>> getCategories() async {
    try {
      final response = await dio.get('/categories');
      if (response.statusCode == 200 && response.data != null) {
        final responseData = response.data;
        if (responseData is Map && responseData['data'] != null) {
          return responseData['data'] as List<dynamic>;
        }
      }
      return [];
    } catch (e) {
      debugPrint("🚨 Error al traer categorías reales: $e");
      return [];
    }
  }

  /// ➕ CREAR UN NUEVO SERVICIO REAL (Ruta corregida a /freelance/create)
  Future<bool> createService(Map<String, dynamic> serviceData) async {
    try {
      final response = await dio.post(
        '/freelance/create', 
        data: serviceData,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint("✅ Servicio creado exitosamente en el backend");
        return true;
      }
      return false;
    } on DioException catch (e) {
      debugPrint("🚨 Error de red al crear servicio: ${e.response?.data}");
      return false;
    } catch (e) {
      return false;
    }
  }

  /// ✏️ ACTUALIZAR / EDITAR UN SERVICIO EXISTENTE (Ruta corregida a /freelance/update/:id)
  Future<bool> updateService(String serviceId, Map<String, dynamic> serviceData) async {
    try {
      final response = await dio.put(
        '/freelance/update/$serviceId', 
        data: serviceData,
      );
      if (response.statusCode == 200 || response.statusCode == 204) {
        debugPrint("✅ Servicio actualizado con éxito");
        return true;
      }
      return false;
    } on DioException catch (e) {
      debugPrint("🚨 Error de red al actualizar servicio: ${e.response?.data}");
      return false;
    } catch (e) {
      return false;
    }
  }

  /// 🗑️ ELIMINAR UN SERVICIO PERMANENTEMENTE (Ruta corregida a /freelance/delete/:id)
  Future<bool> deleteService(String serviceId) async {
    try {
      final response = await dio.delete('/freelance/delete/$serviceId');
      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      }
      return false;
    } on DioException catch (e) {
      debugPrint("🚨 Error de red al eliminar servicio: ${e.response?.data}");
      return false;
    } catch (e) {
      return false;
    }
  }

  
  // ========================================================
  // 👥 SECCIÓN DE PERFIL INTELIGENTE (RUTAS CORREGIDAS) 👥
  // ========================================================

  /// 🔄 OBTENER PERFIL AUTOMÁTICO SEGÚN EL ROL
  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final role = await getUserRole();
      final bool isFreelancer = role?.toUpperCase() == 'FREELANCER';

      // 🚀 CORREGIDO: Freelancer apunta a '/me' y Cliente a '/client'
      final String sufijo = isFreelancer ? '/me' : '/client';
      
      final response = await dio.get('/profile$sufijo');
      
      if (response.statusCode == 200 && response.data != null) {
        var responseData = response.data;
        if (responseData is String) responseData = jsonDecode(responseData);

        if (responseData is Map && responseData['data'] != null) {
          return responseData['data'] as Map<String, dynamic>;
        }
        if (responseData is Map) {
          return responseData as Map<String, dynamic>;
        }
      }
      return null;
    } catch (e) {
      debugPrint("🚨 Error en ApiService al obtener perfil: $e");
      return null;
    }
  }

  /// ✏️ ACTUALIZAR PERFIL AUTOMÁTICO SEGÚN EL ROL
  Future<bool> updateUserProfile(Map<String, dynamic> data) async {
    try {
      final role = await getUserRole();
      final bool isFreelancer = role?.toUpperCase() == 'FREELANCER';

      // 🚀 CORREGIDO: Freelancer usa '/me' y Cliente usa '/client'
      final String sufijo = isFreelancer ? '/me' : '/client';
      
      final response = await dio.put('/profile$sufijo', data: data);
      
      if (response.statusCode == 200) {
        debugPrint("✅ Perfil ($role) actualizado con éxito en la BD.");
        return true;
      }
      return false;
    } on DioException catch (e) {
      debugPrint("🚨 Error de Zod o estructura en tu backend: ${e.response?.data}");
      return false;
    } catch (e) {
      return false;
    }
  }
    
  /// 🔑 ACTUALIZAR CONTRASEÑA EN LA BD
  Future<bool> updatePassword(String currentPassword, String newPassword) async {
    try {
      // 🚀 CONFIGURADO: Coincide perfectamente con router.put('/client/password')
      final response = await dio.put(
        '/profile/client/password', 
        data: {
          "currentPassword": currentPassword,
          "newPassword": newPassword,
        },
      );
      
      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("🚨 Error en ApiService al cambiar contraseña: $e");
      return false;
    }
  }

  /// 📣 CREAR RESEÑA O COMENTARIO PARA UN SERVICIO COMPRADO (CORREGIDO)
  Future<bool> addServiceReview({
    required String serviceId,
    required int rating,
    required String comment,
  }) async {
    try {
      // 🚀 Apuntamos a la raíz del router '/reviews' tal como dice tu backend
      final response = await dio.post(
        '/reviews', 
        data: {
          'serviceId': serviceId, // Enviado en el body
          'rating': rating,
          'comment': comment,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        var responseData = response.data;
        if (responseData is String) {
          responseData = jsonDecode(responseData);
        }
        
        // Tu backend devuelve { status: 'success', data: review }
        if (responseData is Map && responseData['status'] == 'success') {
          return true;
        }
      }
      return false;
    } on DioException catch (e) {
      // Capturamos mensajes personalizados (ej: CONFLICT si ya opinaste o FORBIDDEN si no compraste)
      final backendMessage = e.response?.data['message'] ?? 'Error al enviar reseña';
      debugPrint("🚨 Error controlado del backend en reseña: $backendMessage");
      return false;
    } catch (e) {
      debugPrint("🚨 Error inesperado en addServiceReview: $e");
      return false;
    }
  }
 
}