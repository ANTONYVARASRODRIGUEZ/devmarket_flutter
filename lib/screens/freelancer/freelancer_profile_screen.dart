// lib/screens/freelancer/freelancer_profile_screen.dart
import 'package:flutter/material.dart';
import 'freelancer_edit_profile_screen.dart';
import 'freelancer_portfolio_screen.dart'; 
import 'freelancer_settings_screen.dart'; 
import 'freelancer_notifications_screen.dart'; // 🚀 ¡IMPORTACIÓN AGREGADA! Vinculamos la pantalla de notificaciones

class FreelancerProfileScreen extends StatefulWidget {
  final bool isFreelancer;
  final ValueChanged<bool> onRoleChanged;

  const FreelancerProfileScreen({
    super.key,
    required this.isFreelancer,
    required this.onRoleChanged,
  });

  @override
  State<FreelancerProfileScreen> createState() => _FreelancerProfileScreenState();
}

class _FreelancerProfileScreenState extends State<FreelancerProfileScreen> {
  // Paleta de colores exacta de tus capturas
  static const bgDark = Color(0xFF080808);
  static const cardColor = Color(0xFF121214);
  static const accentColor = Color(0xFF10B981);
  static const textMuted = Color(0xFF71717A);
  static const borderDark = Color(0xFF1C1C1E);
  static const errorRed = Color(0xFFEF4444);

  // 🛠️ Variables de estado reactivas (Vinculadas con la pantalla de edición)
  String _nombre = "María López";
  String _email = "maria.dev@email.com";
  String _telefono = "+51 987 654 321";
  String _titulo = "Top Rated Freelancer";
  String _skills = "Flutter, Dart, UI/UX";

  // Balance disponible mutable
  double _balanceDisponible = 18675.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgDark,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ==========================================
              // HEADER CON SWITCH DE ROL
              // ==========================================
              Row(
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
              const SizedBox(height: 32),

              // ==========================================
              // TARJETA DE PERFIL (Dinamizada con las variables)
              // ==========================================
              CircleAvatar(
                radius: 50,
                backgroundColor: borderDark,
                child: ClipOval(
                  child: Image.network(
                    'https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=200&auto=format&fit=crop',
                    fit: BoxFit.cover,
                    width: 100,
                    height: 100,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _nombre, 
                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                _email, 
                style: const TextStyle(color: textMuted, fontSize: 14),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF062F22),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _titulo, 
                  style: const TextStyle(color: accentColor, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 32),

              // ==========================================
              // SECCIÓN: ESTADÍSTICAS
              // ==========================================
              Align(
                alignment: Alignment.centerLeft,
                child: const Text(
                  'Estadísticas',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Row(
                  children: [
                    _buildStatItem('48', 'Proyectos'),
                    Container(width: 1, height: 40, color: borderDark),
                    Expanded(
                      child: InkWell(
                        onTap: () => _showRetirarFondosModal(context),
                        child: Column(
                          children: [
                            Text(
                              '\$${(_balanceDisponible / 1000).toStringAsFixed(1)}K',
                              style: const TextStyle(color: accentColor, fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            const Text('Ganado', style: TextStyle(color: textMuted, fontSize: 13)),
                          ],
                        ),
                      ),
                    ),
                    Container(width: 1, height: 40, color: borderDark),
                    _buildStatItem('5.0', 'Rating'),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ==========================================
              // LISTA DE OPCIONES DE CONFIGURACIÓN
              // ==========================================
              _buildMenuButton(
                Icons.person_outline_rounded, 
                'Editar Perfil',
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FreelancerEditProfileScreen(
                        currentName: _nombre,
                        currentEmail: _email,
                        currentPhone: _telefono,
                        currentTitle: _titulo,
                        currentSkills: _skills,
                      ),
                    ),
                  );

                  if (result != null && result is Map<String, String>) {
                    setState(() {
                      _nombre = result['name']!;
                      _email = result['email']!;
                      _telefono = result['phone']!;
                      _titulo = result['title']!;
                      _skills = result['skills']!;
                    });
                  }
                },
              ),
              
              _buildMenuButton(
                Icons.folder_open_rounded, 
                'Portfolio',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FreelancerPortfolioScreen(),
                    ),
                  );
                },
              ),
              
              _buildMenuButton(
                Icons.settings_outlined, 
                'Configuración', 
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FreelancerSettingsScreen(),
                    ),
                  );
                },
              ),

              // 🚀 ¡SOLUCIÓN! Botón actualizado para abrir la pantalla de Notificaciones
              _buildMenuButton(
                Icons.notifications_none_rounded, 
                'Notificaciones',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FreelancerNotificationsScreen(),
                    ),
                  );
                },
              ),
              
              _buildMenuButton(
                Icons.logout_rounded, 
                'Cerrar Sesión', 
                color: errorRed,
                showArrow: false,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: textMuted, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildMenuButton(IconData icon, String title, {Color color = Colors.white, bool showArrow = true, VoidCallback? onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderDark.withAlpha(128)), 
      ),
      child: ListTile(
        onTap: onTap ?? () {},
        dense: true,
        leading: Icon(icon, color: color, size: 22),
        title: Text(
          title,
          style: TextStyle(color: color, fontSize: 15, fontWeight: FontWeight.w600),
        ),
        trailing: showArrow ? const Icon(Icons.arrow_forward_ios_rounded, color: textMuted, size: 14) : null,
      ),
    );
  }

  // =========================================================================
  // MODAL 1: RETIRAR FONDOS (Se mantiene intacto y accesible desde "Ganado")
  // =========================================================================
  void _showRetirarFondosModal(BuildContext context) {
    String selectedMethod = 'transferencia';
    bool isProcessing = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              decoration: const BoxDecoration(
                color: Color(0xFF0F0F11),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
              ),
              padding: EdgeInsets.only(
                left: 20, 
                right: 20, 
                top: 24, 
                bottom: MediaQuery.of(context).viewInsets.bottom + 24
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Retirar Fondos',
                        style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.close_rounded, color: textMuted),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Balance disponible', style: TextStyle(color: textMuted, fontSize: 13)),
                        const SizedBox(height: 6),
                        Text(
                          '\$${_balanceDisponible.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                          style: const TextStyle(color: accentColor, fontSize: 28, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('Cantidad a retirar', style: TextStyle(color: textMuted, fontSize: 14)),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: const TextField(
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        prefixText: '\$ ',
                        prefixStyle: TextStyle(color: textMuted, fontSize: 18),
                        hintText: '1000',
                        hintStyle: TextStyle(color: textMuted),
                        border: InputBorder.none,
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: ['\$100', '\$500', '\$1000', 'Todo'].map((amount) {
                      return Expanded(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          height: 38,
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Center(
                            child: Text(
                              amount,
                              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  const Text('Método de pago', style: TextStyle(color: textMuted, fontSize: 14)),
                  const SizedBox(height: 12),
                  _buildPaymentMethodTile(
                    methodKey: 'transferencia',
                    currentSelected: selectedMethod,
                    icon: Icons.credit_card_rounded,
                    title: 'Transferencia Bancaria',
                    subtitle: '2-3 días',
                    onTap: () => setModalState(() => selectedMethod = 'transferencia'),
                  ),
                  _buildPaymentMethodTile(
                    methodKey: 'paypal',
                    currentSelected: selectedMethod,
                    icon: Icons.account_balance_wallet_rounded,
                    title: 'PayPal',
                    subtitle: 'Instantáneo',
                    onTap: () => setModalState(() => selectedMethod = 'paypal'),
                  ),
                  _buildPaymentMethodTile(
                    methodKey: 'crypto',
                    currentSelected: selectedMethod,
                    icon: Icons.currency_bitcoin_rounded,
                    title: 'Criptomoneda',
                    subtitle: '10-30 min',
                    onTap: () => setModalState(() => selectedMethod = 'crypto'),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: isProcessing 
                        ? null 
                        : () async {
                            setModalState(() => isProcessing = true);
                            
                            await Future.delayed(const Duration(seconds: 2));
                            
                            if (!context.mounted) return;
                            Navigator.pop(context); 
                            _showRetiroExitosoModal(context);
                          },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor, 
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        elevation: 0,
                      ),
                      child: isProcessing
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2),
                              ),
                              SizedBox(width: 12),
                              Text('Procesando...', style: TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold)),
                            ],
                          )
                        : const Text(
                            'Procesar Retiro',
                            style: TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPaymentMethodTile({
    required String methodKey,
    required String currentSelected,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final bool isSelected = methodKey == currentSelected;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF091F18) : cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? accentColor : borderDark,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? accentColor : textMuted, size: 22),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(color: textMuted, fontSize: 12)),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.check_circle_rounded : Icons.radio_button_off_rounded,
              color: isSelected ? accentColor : textMuted,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // MODAL 2: RETIRO PROCESADO EXITOSAMENTE
  // =========================================================================
  void _showRetiroExitosoModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF0F0F11),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(28),
              topRight: Radius.circular(28),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFF0A291E),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_rounded, color: accentColor, size: 40), 
              ),
              const SizedBox(height: 24),
              const Text(
                '¡Retiro Procesado!',
                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                'Tu retiro está en camino. Recibirás una confirmation por email.',
                textAlign: TextAlign.center,
                style: TextStyle(color: textMuted, fontSize: 15, height: 1.4),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _balanceDisponible -= 1000; 
                    });
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Entendido',
                    style: TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}