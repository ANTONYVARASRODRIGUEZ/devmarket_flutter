// lib/screens/freelancer/freelancer_home_screen.dart
import 'package:flutter/material.dart';

class FreelancerHomeScreen extends StatefulWidget {
  // 📥 Parámetros globales recibidos desde main.dart
  final bool isFreelancer;
  final ValueChanged<bool> onRoleChanged;

  const FreelancerHomeScreen({
    super.key,
    required this.isFreelancer,
    required this.onRoleChanged,
  });

  @override
  State<FreelancerHomeScreen> createState() => _FreelancerHomeScreenState();
}

class _FreelancerHomeScreenState extends State<FreelancerHomeScreen> {
  // Constantes de diseño
  static const bgDark = Color(0xFF080808);
  static const cardColor = Color(0xFF121214);
  static const accentColor = Color(0xFF10B981);
  static const borderColor = Color(0xFF1C1C1E);
  static const textMuted = Color(0xFF71717A);
  
  // Balance máximo inicializado
  double _totalBalance = 18675.00;

  // Lista de movimientos fija basada en tu diseño
  final List<Map<String, dynamic>> _movements = [
    {
      'title': 'E-commerce React - Milestone 1',
      'time': 'Hace 2 días',
      'amount': '+\$800',
    },
    {
      'title': 'Sistema de Inventario - Final',
      'time': 'Hace 5 días',
      'amount': '+\$1,200',
    },
    {
      'title': 'Landing Page - Completo',
      'time': 'Hace 1 semana',
      'amount': '+\$450',
    },
    {
      'title': 'Bot Discord - Setup',
      'time': 'Hace 2 semanas',
      'amount': '+\$140',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgDark,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. CABECERA UNIFORME CONECTADA AL ESTADO GLOBAL
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
                        activeTrackColor: accentColor.withValues(alpha: 0.3),
                        onChanged: widget.onRoleChanged,
                      ),
                      Text('Freelancer', style: TextStyle(color: widget.isFreelancer ? accentColor : Colors.grey, fontSize: 12)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // --- TITULO DE LA PANTALLA ---
              const Text(
                'Finanzas',
                style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text(
                'Tu resumen financiero',
                style: TextStyle(color: textMuted, fontSize: 16),
              ),
              const SizedBox(height: 24),

              // --- TARJETA DE BALANCE TOTAL ---
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Balance Total',
                      style: TextStyle(color: textMuted, fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '\$${_totalBalance.toStringAsFixed(0)}',
                      style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.arrow_upward_rounded, color: accentColor, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '+8% este mes',
                          style: TextStyle(color: accentColor.withValues(alpha: 0.9), fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // --- BOTÓN RETIRAR FONDOS ---
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () => _showWithdrawModal(context), 
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    foregroundColor: Colors.black,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: const Icon(Icons.monetization_on_outlined, size: 20),
                  label: const Text(
                    'RETIRAR FONDOS',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // --- SECCIÓN MOVIMIENTOS RECIENTES ---
              const Text(
                'Movimientos Recientes',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _movements.length,
                separatorBuilder: (context, index) => const Divider(color: borderColor, height: 28, thickness: 1),
                itemBuilder: (context, index) {
                  final item = _movements[index];
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['title'],
                              style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item['time'],
                              style: const TextStyle(color: textMuted, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        item['amount'],
                        style: const TextStyle(color: accentColor, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // 🔥 MODAL INTERACTIVO DE RETIRO (BOTTOM SHEET)
  // ==========================================
  void _showWithdrawModal(BuildContext context) {
    const modalBg = Color(0xFF0F0F11);
    const modalItemBg = Color(0xFF18181B);
    const modalActiveBtn = Color(0xFF27272A);

    final TextEditingController amountController = TextEditingController();
    String selectedMethod = 'bank'; 
    double amountToWithdraw = 0.0;
    bool isProcessing = false; // 🔄 Estado local para rastrear la carga de la petición

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: modalBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            
            void updateAmount(double value) {
              if (isProcessing) return; // Bloquear si está cargando
              setModalState(() {
                amountToWithdraw = value > _totalBalance ? _totalBalance : value;
                amountController.text = amountToWithdraw == 0.0 
                    ? '' 
                    : amountToWithdraw.toStringAsFixed(0);
              });
            }

            return Padding(
              padding: EdgeInsets.only(
                top: 24,
                left: 16,
                right: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24, 
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
                        style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: textMuted),
                        onPressed: isProcessing ? null : () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: modalItemBg,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Balance disponible',
                          style: TextStyle(color: textMuted, fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '\$${_totalBalance.toStringAsFixed(0)}',
                          style: const TextStyle(color: accentColor, fontSize: 28, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  const Text(
                    'Cantidad a retirar',
                    style: TextStyle(color: textMuted, fontSize: 13),
                  ),
                  const SizedBox(height: 8),

                  TextField(
                    controller: amountController,
                    enabled: !isProcessing, // Deshabilitar escritura al procesar
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    onChanged: (value) {
                      final parsed = double.tryParse(value) ?? 0.0;
                      setModalState(() {
                        amountToWithdraw = parsed > _totalBalance ? _totalBalance : parsed;
                      });
                    },
                    decoration: InputDecoration(
                      prefixText: '\$ ',
                      prefixStyle: const TextStyle(color: textMuted, fontSize: 20, fontWeight: FontWeight.bold),
                      hintText: '0.00',
                      hintStyle: const TextStyle(color: textMuted),
                      filled: true,
                      fillColor: modalItemBg,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildQuickAmountButton('\$100', () => updateAmount(100), modalItemBg),
                      _buildQuickAmountButton('\$500', () => updateAmount(500), modalItemBg),
                      _buildQuickAmountButton('\$1000', () => updateAmount(1000), modalItemBg),
                      _buildQuickAmountButton('Todo', () => updateAmount(_totalBalance), modalItemBg),
                    ],
                  ),
                  const SizedBox(height: 24),

                  const Text(
                    'Método de pago',
                    style: TextStyle(color: textMuted, fontSize: 13),
                  ),
                  const SizedBox(height: 12),

                  _buildPaymentMethodTile(
                    id: 'bank',
                    title: 'Transferencia Bancaria',
                    subtitle: '2-3 días',
                    icon: Icons.credit_card_rounded,
                    isSelected: selectedMethod == 'bank',
                    modalItemBg: modalItemBg,
                    onTap: isProcessing ? () {} : () => setModalState(() => selectedMethod = 'bank'),
                  ),
                  const SizedBox(height: 12),
                  _buildPaymentMethodTile(
                    id: 'paypal',
                    title: 'PayPal',
                    subtitle: 'Instantáneo',
                    icon: Icons.account_balance_wallet_rounded,
                    isSelected: selectedMethod == 'paypal',
                    modalItemBg: modalItemBg,
                    onTap: isProcessing ? () {} : () => setModalState(() => selectedMethod = 'paypal'),
                  ),
                  const SizedBox(height: 12),
                  _buildPaymentMethodTile(
                    id: 'crypto',
                    title: 'Criptomoneda',
                    subtitle: '10-30 min',
                    icon: Icons.currency_bitcoin_rounded,
                    isSelected: selectedMethod == 'crypto',
                    modalItemBg: modalItemBg,
                    onTap: isProcessing ? () {} : () => setModalState(() => selectedMethod = 'crypto'),
                  ),
                  const SizedBox(height: 28),

                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      // Bloquea interacción si el monto es 0 o si ya está procesando
                      onPressed: (amountToWithdraw > 0 && !isProcessing)
                          ? () async {
                              // 1. Cambiar visualmente al estado "Procesando..."
                              setModalState(() {
                                isProcessing = true;
                              });

                              // 2. Simular tiempo de respuesta del servidor (2 segundos)
                              await Future.delayed(const Duration(seconds: 2));

                              // 3. Modificar el estado de la pantalla detrás del modal (restar balance)
                              setState(() {
                                _totalBalance -= amountToWithdraw;
                              });

                              // 4. Cerrar el modal actual de retiro de fondos
                              if (context.mounted) Navigator.pop(context);

                              // 5. Desplegar de inmediato el segundo modal de confirmación exitosa
                              if (context.mounted) _showSuccessModal(context);
                            }
                          : null, 
                      style: ElevatedButton.styleFrom(
                        backgroundColor: amountToWithdraw > 0 ? modalActiveBtn : const Color(0xFF202023),
                        foregroundColor: amountToWithdraw > 0 ? Colors.white : textMuted,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      child: isProcessing 
                          ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(textMuted),
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text(
                                  'Procesando...',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textMuted),
                                ),
                              ],
                            )
                          : Text(
                              'Retirar \$${amountToWithdraw.toStringAsFixed(0)}',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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

  // ==========================================
  // 🎉 NUEVO: MODAL DE RETIRO PROCESADO EXITOSAMENTE
  // ==========================================
  void _showSuccessModal(BuildContext context) {
    const modalBg = Color(0xFF0F0F11);

    showModalBottomSheet(
      context: context,
      backgroundColor: modalBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Círculo verde con checkmark idéntico a tu diseño
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: accentColor,
                  size: 40,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Retiro Procesado!',
                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                'Tu retiro está en camino. Recibirás una confirmación por email.',
                textAlign: TextAlign.center,
                style: TextStyle(color: textMuted, fontSize: 15, height: 1.4),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    foregroundColor: Colors.black,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    'Entendido',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickAmountButton(String label, VoidCallback onTap, Color cardColor) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: SizedBox(
          height: 40,
          child: ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: cardColor,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentMethodTile({
    required String id,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required Color modalItemBg,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: modalItemBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? accentColor : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? accentColor : const Color(0xFF71717A)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(color: Color(0xFF71717A), fontSize: 12)),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.check_circle_rounded : Icons.radio_button_off_rounded,
              color: isSelected ? accentColor : const Color(0xFF27272A),
            ),
          ],
        ),
      ),
    );
  }
}