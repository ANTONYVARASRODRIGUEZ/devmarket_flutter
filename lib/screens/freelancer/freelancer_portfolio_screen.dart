// lib/screens/freelancer/freelancer_portfolio_screen.dart
import 'dart:ui'; // 🚀 ¡SOLUCIÓN! Importación necesaria para que PathMetric funcione
import 'package:flutter/material.dart';

// Modelo de datos para estructurar cada proyecto del portafolio
class PortfolioProject {
  final String title;
  final String category;
  final String imageUrl;

  const PortfolioProject({
    required this.title,
    required this.category,
    required this.imageUrl,
  });
}

class FreelancerPortfolioScreen extends StatefulWidget {
  const FreelancerPortfolioScreen({super.key});

  @override
  State<FreelancerPortfolioScreen> createState() => _FreelancerPortfolioScreenState();
}

class _FreelancerPortfolioScreenState extends State<FreelancerPortfolioScreen> {
  // Paleta de colores consistente de DevMarket
  static const bgDark = Color(0xFF080808);
  static const cardColor = Color(0xFF121214);
  static const textMuted = Color(0xFF71717A);
  static const borderDark = Color(0xFF1C1C1E);
  // 💡 Nota: Se removió 'accentColor' de aquí para limpiar el warning de campo no usado.

  // Lista de proyectos quemados exactamente como en tu captura
  final List<PortfolioProject> _projects = [
    const PortfolioProject(
      title: 'E-commerce Fashion Store',
      category: 'E-commerce',
      imageUrl: 'https://images.unsplash.com/photo-1441986300917-64674bd600d8?q=80&w=400&auto=format&fit=crop',
    ),
    const PortfolioProject(
      title: 'Dashboard Analytics',
      category: 'Dashboard',
      imageUrl: 'https://images.unsplash.com/photo-1551288049-bebda4e38f71?q=80&w=400&auto=format&fit=crop',
    ),
    const PortfolioProject(
      title: 'Mobile Banking App',
      category: 'Mobile',
      imageUrl: 'https://images.unsplash.com/photo-1563986768609-322da13575f3?q=80&w=400&auto=format&fit=crop',
    ),
    const PortfolioProject(
      title: 'SaaS Platform',
      category: 'Web App',
      imageUrl: 'https://images.unsplash.com/photo-1460925895917-afdab827c52f?q=80&w=400&auto=format&fit=crop',
    ),
  ];

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
          'Mi Portfolio',
          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Grid de proyectos (2 columnas de forma dinámica)
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _projects.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 0.85,
              ),
              itemBuilder: (context, index) {
                final project = _projects[index];
                return _buildProjectCard(project);
              },
            ),
            const SizedBox(height: 20),
            
            // Botón inferior para "Agregar Proyecto"
            _buildAddProjectButton(),
          ],
        ),
      ),
    );
  }

  // Widget para construir cada tarjeta del portafolio
  Widget _buildProjectCard(PortfolioProject project) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderDark.withAlpha(128)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                Image.network(
                  project.imageUrl,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha((0.6 * 255).round()),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.open_in_new_rounded, color: Colors.white, size: 16),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  project.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(
                  project.category,
                  style: const TextStyle(color: textMuted, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget para construir el botón "Agregar Proyecto"
  Widget _buildAddProjectButton() {
    return InkWell(
      onTap: () {
        // Tu futura lógica para abrir un formulario de creación
      },
      borderRadius: BorderRadius.circular(16),
      child: CustomPaint(
        painter: _DashedRectPainter(color: borderDark, strokeWidth: 1.5, gap: 4),
        child: Container(
          width: double.infinity,
          height: 100,
          alignment: Alignment.center,
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add, color: textMuted, size: 24),
              SizedBox(height: 8),
              Text(
                'Agregar Proyecto',
                style: TextStyle(color: textMuted, fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Painter personalizado para lograr el efecto de líneas discontinuas
class _DashedRectPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;

  _DashedRectPainter({required this.color, this.strokeWidth = 1.0, this.gap = 5.0});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    const radius = Radius.circular(16);
    final RRect rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      radius,
    );

    final Path path = Path()..addRRect(rrect);
    
    final Path dashPath = Path();
    double distance = 0.0;
    for (final PathMetric measurePath in path.computeMetrics()) {
      while (distance < measurePath.length) {
        dashPath.addPath(
          measurePath.extractPath(distance, distance + gap),
          Offset.zero,
        );
        distance += gap * 2;
      }
    }
    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}