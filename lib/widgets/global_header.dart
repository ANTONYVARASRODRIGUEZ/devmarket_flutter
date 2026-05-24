// lib/widgets/global_header.dart
import 'package:flutter/material.dart';

class GlobalHeader extends StatelessWidget implements PreferredSizeWidget {
  final bool isFreelancer;
  final ValueChanged<bool> onRoleChanged;

  const GlobalHeader({
    super.key,
    required this.isFreelancer,
    required this.onRoleChanged,
  });

  @override
  Widget build(BuildContext context) {
    const accentColor = Color(0xFF10B981);

    return AppBar(
      backgroundColor: const Color(0xFF080808),
      elevation: 0,
      automaticallyImplyLeading: false, // Evita flechas de regreso automáticas
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // LOGO DEVMARKET
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
                  style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'DevMarket',
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          
          // SWITCH DE ROL GLOBAL
          Row(
            children: [
              Text(
                'Cliente', 
                style: TextStyle(color: isFreelancer ? Colors.grey : accentColor, fontSize: 12),
              ),
              Switch(
                value: isFreelancer,
                activeThumbColor: accentColor,
                activeTrackColor: accentColor.withValues(alpha: 0.3),
                onChanged: onRoleChanged, // Notifica al main.dart al hacer click
              ),
              Text(
                'Freelancer', 
                style: TextStyle(color: isFreelancer ? accentColor : Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}