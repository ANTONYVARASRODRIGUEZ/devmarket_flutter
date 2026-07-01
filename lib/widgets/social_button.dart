import 'package:flutter/material.dart';

class SocialButton extends StatelessWidget {
  final String label;
  final IconData fallbackIcon;
  final VoidCallback onPressed;

  const SocialButton({
    super.key,
    required this.label,
    required this.fallbackIcon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: const Color(0xFF121214),
        side: const BorderSide(color: const Color(0xFF27272A), width: 1),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(fallbackIcon, color: Colors.white, size: 22),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}