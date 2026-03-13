import 'dart:ui';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'home_screen.dart';

class _Colors {
  static const primary = Color(0xFFEC5B13);
  static const primaryMid = Color(0xFF9A3412);
  static const backgroundDark = Color(0xFF221610);
  static const buttonGreen = Color(0xFF25D366);
}

class EmailLoginScreen extends StatefulWidget {
  const EmailLoginScreen({super.key});

  @override
  State<EmailLoginScreen> createState() => _EmailLoginScreenState();
}

class _EmailLoginScreenState extends State<EmailLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isRegister = false;
  final _nameController = TextEditingController();
  final _lastNameController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();

    if (_isRegister) {
      final success = await auth.registerWithEmail(
        _emailController.text.trim(),
        _passwordController.text,
        _nameController.text.trim(),
        _lastNameController.text.trim(),
      );
      if (mounted && success) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false,
        );
      }
    } else {
      final success = await auth.loginWithEmail(
        _emailController.text.trim(),
        _passwordController.text,
      );
      if (mounted && success) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              _Colors.primary,
              _Colors.primaryMid,
              _Colors.backgroundDark,
            ],
          ),
        ),
        child: Stack(
          children: [
            _buildOverlay(),
            SafeArea(
              child: Column(
                children: [
                  _buildTopNav(),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 400),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 32),
                            Text(
                              _isRegister ? 'Crea tu cuenta' : 'Ingresa tu correo',
                              style: GoogleFonts.publicSans(
                                color: Colors.white,
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _isRegister
                                  ? 'Regístrate con tu correo electrónico y contraseña'
                                  : 'Inicia sesión con tu correo y contraseña',
                              style: GoogleFonts.publicSans(
                                color: Colors.white.withOpacity(0.75),
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 40),
                            if (context.watch<AuthProvider>().error != null) ...[
                              _buildErrorBanner(),
                              const SizedBox(height: 20),
                            ],
                            if (_isRegister) ...[
                              _buildInput(
                                controller: _nameController,
                                label: 'Nombre',
                                hint: 'Juan',
                                icon: Icons.person_outline,
                                validator: (v) =>
                                    (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                              ),
                              const SizedBox(height: 16),
                              _buildInput(
                                controller: _lastNameController,
                                label: 'Apellido',
                                hint: 'Pérez',
                                icon: Icons.person_outline,
                              ),
                              const SizedBox(height: 16),
                            ],
                            _buildInput(
                              controller: _emailController,
                              label: 'Correo electrónico',
                              hint: 'tu@correo.com',
                              icon: Icons.mail_outline,
                              keyboardType: TextInputType.emailAddress,
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) return 'Requerido';
                                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                    .hasMatch(v.trim())) {
                                  return 'Correo inválido';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            _buildInput(
                              controller: _passwordController,
                              label: _isRegister ? 'Contraseña (mín. 6 caracteres)' : 'Contraseña',
                              hint: '••••••••',
                              icon: Icons.lock_outline,
                              obscureText: true,
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'Requerido';
                                if (_isRegister && v.length < 6) {
                                  return 'Mínimo 6 caracteres';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 24),
                            _buildSubmitButton(),
                            const SizedBox(height: 20),
                            _buildToggleMode(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                ),
                  _buildFooter(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverlay() {
    return Positioned.fill(
      child: IgnorePointer(
        child: Opacity(
          opacity: 0.12,
          child: CustomPaint(
            painter: _DotPatternPainter(),
          ),
        ),
      ),
    );
  }

  Widget _buildTopNav() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: const Center(
                    child: Icon(Icons.arrow_back, color: Colors.white, size: 24),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.35),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.amber[200], size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              context.watch<AuthProvider>().error!,
              style: GoogleFonts.publicSans(color: Colors.white, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: obscureText,
            validator: validator,
            style: GoogleFonts.publicSans(color: Colors.white, fontSize: 17),
            decoration: InputDecoration(
              labelText: label,
              hintText: hint,
              labelStyle: GoogleFonts.publicSans(color: Colors.white.withOpacity(0.6)),
              hintStyle: GoogleFonts.publicSans(color: Colors.white.withOpacity(0.35)),
              prefixIcon: Icon(
                icon,
                color: Colors.white.withOpacity(0.6),
                size: 22,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              errorStyle: GoogleFonts.publicSans(color: Colors.amber[200], fontSize: 12),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    final auth = context.watch<AuthProvider>();
    return Material(
      color: _Colors.buttonGreen,
      borderRadius: BorderRadius.circular(16),
      elevation: 8,
      shadowColor: _Colors.buttonGreen.withOpacity(0.3),
      child: InkWell(
        onTap: auth.isLoading ? null : _submit,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 64,
          alignment: Alignment.center,
          child: auth.isLoading
              ? const SizedBox(
                  height: 28,
                  width: 28,
                  child: CircularProgressIndicator(
                    color: Color(0xFF172211),
                    strokeWidth: 2.5,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _isRegister ? 'Registrarme' : 'Continuar',
                      style: GoogleFonts.publicSans(
                        color: const Color(0xFF172211),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.arrow_forward, color: const Color(0xFF172211), size: 22),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildToggleMode() {
    return TextButton(
      onPressed: () {
        setState(() => _isRegister = !_isRegister);
        context.read<AuthProvider>().clearError();
      },
      child: Text(
        _isRegister
            ? '¿Ya tienes cuenta? Inicia sesión'
            : '¿No tienes cuenta? Regístrate',
        style: GoogleFonts.publicSans(
          color: Colors.white.withOpacity(0.9),
          fontSize: 15,
          decoration: TextDecoration.underline,
          decorationColor: Colors.white.withOpacity(0.6),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: GoogleFonts.publicSans(color: Colors.white.withOpacity(0.5), fontSize: 12),
          children: [
            const TextSpan(text: 'Al continuar, aceptas nuestros '),
            TextSpan(
              text: 'Términos y Condiciones',
              style: GoogleFonts.publicSans(decoration: TextDecoration.underline),
              recognizer: TapGestureRecognizer()..onTap = () {},
            ),
            const TextSpan(text: ' y nuestra '),
            TextSpan(
              text: 'Política de Privacidad',
              style: GoogleFonts.publicSans(decoration: TextDecoration.underline),
              recognizer: TapGestureRecognizer()..onTap = () {},
            ),
            const TextSpan(text: '.'),
          ],
        ),
      ),
    );
  }
}

class _DotPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;
    const spacing = 28.0;
    for (var y = 0.0; y < size.height * 0.4; y += spacing) {
      for (var x = 0.0; x < size.width; x += spacing) {
        final offset = ((y / spacing).floor() + (x / spacing).floor()) % 2 == 0 ? 0.0 : spacing / 2;
        canvas.drawCircle(Offset(x + offset, y), 2, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
