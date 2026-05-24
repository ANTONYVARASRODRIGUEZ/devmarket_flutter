// lib/screens/freelancer/freelancer_edit_profile_screen.dart
import 'package:flutter/material.dart';

class FreelancerEditProfileScreen extends StatefulWidget {
  // 🚀 Recibe los datos actuales para que la pantalla no aparezca con datos vacíos o genéricos
  final String currentName;
  final String currentEmail;
  final String currentPhone;
  final String currentTitle;
  final String currentSkills;

  const FreelancerEditProfileScreen({
    super.key,
    this.currentName = "María López",
    this.currentEmail = "maria.dev@email.com",
    this.currentPhone = "+51 987 654 321",
    this.currentTitle = "Top Rated Freelancer",
    this.currentSkills = "Flutter, Dart, UI/UX",
  });

  @override
  State<FreelancerEditProfileScreen> createState() => _FreelancerEditProfileScreenState();
}

class _FreelancerEditProfileScreenState extends State<FreelancerEditProfileScreen> {
  static const bgDark = Color(0xFF080808);
  static const cardColor = Color(0xFF121214);
  static const accentColor = Color(0xFF10B981);
  static const borderColor = Color(0xFF1C1C1E);
  static const textMuted = Color(0xFF71717A);

  // Clave para validar los campos del formulario
  final _formKey = GlobalKey<FormState>();

  // Controladores enlazados dinámicamente al estado inicial del widget
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _titleController;
  late TextEditingController _skillsController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentName);
    _emailController = TextEditingController(text: widget.currentEmail);
    _phoneController = TextEditingController(text: widget.currentPhone);
    _titleController = TextEditingController(text: widget.currentTitle);
    _skillsController = TextEditingController(text: widget.currentSkills);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _titleController.dispose();
    _skillsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgDark,
      appBar: AppBar(
        backgroundColor: bgDark,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Editar Perfil',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 📸 Sección de Foto de Perfil Grande
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: borderColor, width: 2),
                      ),
                      child: const CircleAvatar(
                        radius: 55,
                        backgroundColor: cardColor,
                        backgroundImage: NetworkImage('https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=200&auto=format&fit=crop'),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: accentColor,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.camera_alt_rounded, color: Colors.black, size: 18),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // 📝 Formulario con validaciones y nuevos campos solicitados
                _buildInputField(
                  label: 'Nombre Completo',
                  controller: _nameController,
                  icon: Icons.person_outline_rounded,
                  validator: (val) => val!.trim().isEmpty ? 'El nombre es obligatorio' : null,
                ),
                const SizedBox(height: 20),

                _buildInputField(
                  label: 'Correo Electrónico',
                  controller: _emailController,
                  icon: Icons.alternate_email_rounded,
                  keyboardType: TextInputType.emailAddress,
                  validator: (val) => !val!.contains('@') ? 'Ingresa un email válido' : null,
                ),
                const SizedBox(height: 20),

                _buildInputField(
                  label: 'Número de Teléfono',
                  controller: _phoneController,
                  icon: Icons.phone_android_rounded,
                  keyboardType: TextInputType.phone,
                  validator: (val) => val!.trim().isEmpty ? 'El teléfono es obligatorio' : null,
                ),
                const SizedBox(height: 20),

                _buildInputField(
                  label: 'Título Profesional',
                  controller: _titleController,
                  icon: Icons.work_outline_rounded,
                  validator: (val) => val!.trim().isEmpty ? 'El título es obligatorio' : null,
                ),
                const SizedBox(height: 20),

                _buildInputField(
                  label: 'Habilidades (Separadas por comas)',
                  controller: _skillsController,
                  icon: Icons.code_rounded,
                  maxLines: 3,
                ),
                const SizedBox(height: 40),

                // 💾 Botón de Guardar Cambios con Retorno de Datos Efectivo
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        // Muestra confirmación estética en la base
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Cambios guardados con éxito'),
                            backgroundColor: accentColor,
                            duration: Duration(seconds: 2),
                          ),
                        );

                        // 🚀 AQUÍ OCURRE LA MAGIA DEL GUARDADO VERDADERO:
                        // Enviamos los datos de regreso dentro de un Mapa estructurado.
                        Navigator.pop(context, {
                          'name': _nameController.text.trim(),
                          'email': _emailController.text.trim(),
                          'phone': _phoneController.text.trim(),
                          'title': _titleController.text.trim(),
                          'skills': _skillsController.text.trim(),
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
                      foregroundColor: Colors.black,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Guardar Cambios',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.3),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 🛠️ Widget dinámico compatible con validaciones nativas de Flutter Form
  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: textMuted, fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          style: const TextStyle(color: Colors.white, fontSize: 15),
          decoration: InputDecoration(
            filled: true,
            fillColor: cardColor,
            prefixIcon: Icon(icon, color: textMuted, size: 22),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            errorStyle: const TextStyle(color: Colors.redAccent),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: borderColor, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: accentColor, width: 1.2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1.2),
            ),
          ),
        ),
      ],
    );
  }
}