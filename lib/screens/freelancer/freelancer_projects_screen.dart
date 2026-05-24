// lib/screens/freelancer/freelancer_projects_screen.dart
import 'dart:ui'; // 🔑 Necesario para el ImageFilter.blur
import 'package:flutter/material.dart';

class FreelancerProjectsScreen extends StatefulWidget {
  final bool isFreelancer;
  final ValueChanged<bool> onRoleChanged;

  const FreelancerProjectsScreen({
    super.key,
    required this.isFreelancer,
    required this.onRoleChanged,
  });

  @override
  State<FreelancerProjectsScreen> createState() => _FreelancerProjectsScreenState();
}

class _FreelancerProjectsScreenState extends State<FreelancerProjectsScreen> {
  static const bgDark = Color(0xFF080808);
  static const cardColor = Color(0xFF121214);
  static const accentColor = Color(0xFF10B981);
  static const borderColor = Color(0xFF1C1C1E);
  static const textMuted = Color(0xFF71717A);

  // 🛠️ FIX: Se agregaron las llaves 'deliveryDate' y 'budget' que faltaban y hacían explotar la pantalla
  final List<Map<String, dynamic>> _projects = [
    {
      'title': 'E-commerce React',
      'client': 'TechCorp Inc.',
      'avatarUrl': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=200&auto=format&fit=crop',
      'status': 'En Proceso',
      'statusColor': const Color(0xFF1D4ED8),
      'progress': 0.5,
      'deliveryDate': '15 Jun 2026',
      'budget': '2,500',
    },
    {
      'title': 'App de Delivery',
      'client': 'FoodRush',
      'avatarUrl': 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?q=80&w=200&auto=format&fit=crop',
      'status': 'Pendiente',
      'statusColor': const Color(0xB3B45309),
      'progress': 0.0,
      'deliveryDate': '02 Jul 2026',
      'budget': '1,800',
    },
    {
      'title': 'Sistema de Inventario',
      'client': 'Warehouse Pro',
      'avatarUrl': 'https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?q=80&w=200&auto=format&fit=crop',
      'status': 'Entregado',
      'statusColor': const Color(0xFF6B21A8),
      'progress': 1.0,
      'deliveryDate': '20 May 2026',
      'budget': '3,200',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgDark,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabecera uniforme
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
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
                      Text('Cliente', style: TextStyle(color: widget.isFreelancer ? Colors.grey : accentColor, fontSize: 12)),
                      Switch(
                        value: widget.isFreelancer,
                        activeThumbColor: accentColor,
                        activeTrackColor: accentColor.withAlpha((0.3 * 255).round()),
                        onChanged: widget.onRoleChanged,
                      ),
                      Text('Freelancer', style: TextStyle(color: widget.isFreelancer ? accentColor : Colors.grey, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),

            // Título
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Proyectos Activos',
                    style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Gestiona tus proyectos',
                    style: TextStyle(color: textMuted, fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),

            // Listado de proyectos
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 24.0),
                itemCount: _projects.length,
                itemBuilder: (context, index) {
                  final project = _projects[index];
                  return _buildProjectCard(project, index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectCard(Map<String, dynamic> project, int index) {
    // 🛡️ Safe fallbacks para evitar que cualquier nulo imprevisto rompa la UI
    final String title = project['title'] ?? 'Proyecto Sin Título';
    final String client = project['client'] ?? 'Cliente Anónimo';
    final String avatarUrl = project['avatarUrl'] ?? '';
    final String status = project['status'] ?? 'Pendiente';
    final Color statusColor = project['statusColor'] ?? const Color(0xB3B45309);
    final double progress = project['progress'] ?? 0.0;
    final String deliveryDate = project['deliveryDate'] ?? 'Por definir';
    final String budget = project['budget'] ?? '0';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: borderColor,
                backgroundImage: avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
                child: avatarUrl.isEmpty ? const Icon(Icons.business, color: textMuted) : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      client,
                      style: const TextStyle(color: textMuted, fontSize: 14),
                    ),
                  ],
                ),
              ),
              
              PopupMenuButton<String>(
                offset: const Offset(0, 40),
                color: const Color(0xFF161618),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: borderColor, width: 1),
                ),
                elevation: 8,
                onSelected: (String newValue) {
                  setState(() {
                    _projects[index]['status'] = newValue;
                    
                    if (newValue == 'Pendiente') {
                      _projects[index]['statusColor'] = const Color(0xB3B45309);
                      _projects[index]['progress'] = 0.0;
                    } else if (newValue == 'En Proceso') {
                      _projects[index]['statusColor'] = const Color(0xFF1D4ED8);
                      _projects[index]['progress'] = 0.5;
                    } else if (newValue == 'Entregado') {
                      _projects[index]['statusColor'] = const Color(0xFF6B21A8);
                      _projects[index]['progress'] = 1.0;
                    }
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withAlpha((0.15 * 255).round()),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        status,
                        style: TextStyle(color: statusColor, fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.keyboard_arrow_down_rounded, color: statusColor, size: 16),
                    ],
                  ),
                ),
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'Pendiente',
                    child: Row(
                      children: [
                        Icon(Icons.access_time_rounded, color: Color(0xB3B45309), size: 18),
                        SizedBox(width: 12),
                        Text('Pendiente', style: TextStyle(color: Color(0xB3B45309), fontWeight: FontWeight.bold, fontSize: 14)),
                      ],
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'En Proceso',
                    child: Row(
                      children: [
                        Icon(Icons.token_outlined, color: Color(0xFF1D4ED8), size: 18),
                        SizedBox(width: 12),
                        Text('En Proceso', style: TextStyle(color: Color(0xFF1D4ED8), fontWeight: FontWeight.bold, fontSize: 14)),
                      ],
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'Entregado',
                    child: Row(
                      children: [
                        Icon(Icons.assignment_turned_in_outlined, color: Color(0xFF6B21A8), size: 18),
                        SizedBox(width: 12),
                        Text('Entregado', style: TextStyle(color: Color(0xFF6B21A8), fontWeight: FontWeight.bold, fontSize: 14)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Progreso', style: TextStyle(color: textMuted, fontSize: 14)),
              Text(
                '${(progress * 100).toInt()}%',
                style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // 📈 Barra de progreso animada de forma fluida
          LayoutBuilder(
            builder: (context, constraints) {
              return Container(
                width: constraints.maxWidth,
                height: 8,
                decoration: BoxDecoration(
                  color: const Color(0xFF242427),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Stack(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 450),
                      curve: Curves.easeInOutCubic,
                      width: constraints.maxWidth * progress,
                      height: 8,
                      decoration: BoxDecoration(
                        color: accentColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text('Entrega: ', style: TextStyle(color: textMuted, fontSize: 15)),
                  Text(
                    deliveryDate,
                    style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              Text(
                '\$$budget',
                style: const TextStyle(color: accentColor, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          SizedBox(
            width: double.infinity,
            height: 46,
            child: OutlinedButton(
              onPressed: () => _showCancelProjectModal(context, title, budget, index),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: borderColor, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                foregroundColor: Colors.white,
              ),
              child: const Text(
                'Abandonar Proyecto',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 0.3),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 🔥 MODAL INFERIOR CON EFECTO BORROSO (BLUR)
  // ==========================================
  void _showCancelProjectModal(BuildContext context, String title, String budget, int index) {
    const modalBg = Color(0xFF0F0F11);
    const alertBg = Color(0xFF1C1214);
    const alertBorder = Color(0xFF3F161A);
    const alertText = Color(0xFFFCA5A5);
    const itemBg = Color(0xFF18181B);

    showModalBottomSheet(
      context: context,
      backgroundColor: modalBg,
      barrierColor: Colors.black.withAlpha((0.6 * 255).round()), 
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
          child: Padding(
            padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Cancelar Proyecto',
                      style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: textMuted),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: alertBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: alertBorder, width: 1),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 22),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Esta accion no se puede deshacer',
                              style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'El proyecto será cancelado y no podrás recuperarlo.',
                              style: TextStyle(color: alertText, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: itemBg,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '\$$budget',
                        style: const TextStyle(color: textMuted, fontSize: 14),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: borderColor, width: 1.5),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Volver', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _projects.removeAt(index);
                            });
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFEF4444),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                          ),
                          child: const Text('Cancelar Proyecto', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}