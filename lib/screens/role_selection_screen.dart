import 'package:flutter/material.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  String? _selectedRole;

  void _handleSelection() {
    if (_selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecciona un rol para continuar.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    // 🚀 RETORNA EL ROL: Cierra esta pantalla y le devuelve el rol a la de Registro
    Navigator.pop(context, _selectedRole);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 450),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    '¿Cómo deseas unirte?',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Selecciona tu rol en DevMarket. Podrás cambiar o gestionar esto más adelante.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 15),
                  ),
                  const SizedBox(height: 40),

                  _buildRoleCard(
                    roleId: 'cliente',
                    title: 'Quiero contratar',
                    subtitle: 'Busco los mejores freelancers para desarrollar mis proyectos y startups.',
                    icon: Icons.business_center_outlined,
                    accentColor: const Color(0xFF2563EB),
                  ),
                  const SizedBox(height: 20),

                  _buildRoleCard(
                    roleId: 'freelancer',
                    title: 'Quiero trabajar',
                    subtitle: 'Soy desarrollador y busco clientes o empresas para ofrecer mis servicios.',
                    icon: Icons.code_rounded,
                    accentColor: const Color(0xFF00E676),
                  ),
                  const SizedBox(height: 50),

                  ElevatedButton(
                    onPressed: _handleSelection,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedRole != null ? const Color(0xFF00E676) : const Color(0xFF1E1E1F),
                      foregroundColor: _selectedRole != null ? Colors.black : Colors.grey,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text('Unirme ahora', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward_rounded, size: 18),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required String roleId,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
  }) {
    final isSelected = _selectedRole == roleId;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedRole = roleId;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          color: const Color(0xFF121214),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? accentColor : const Color(0xFF27272A),
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: accentColor.withOpacity(0.15), blurRadius: 15, offset: const Offset(0, 8))]
              : [],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? accentColor.withOpacity(0.1) : const Color(0xFF1A1A1E),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, size: 28, color: isSelected ? accentColor : Colors.grey[400]),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(color: isSelected ? Colors.white : Colors.grey[300], fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text(subtitle, style: TextStyle(color: Colors.grey[500], fontSize: 13, height: 1.4)),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 4),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: isSelected ? accentColor : const Color(0xFF45454A), width: 2),
                color: isSelected ? accentColor : Colors.transparent,
              ),
              child: isSelected ? const Icon(Icons.check, size: 12, color: Colors.black) : null,
            ),
          ],
        ),
      ),
    );
  }
}