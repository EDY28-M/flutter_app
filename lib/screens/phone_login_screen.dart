import 'dart:ui';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/auth_service.dart';
import 'auth_wrapper.dart';

class _Colors {
  static const primary = Color(0xFFEC5B13);
  static const primaryMid = Color(0xFF9A3412);
  static const backgroundDark = Color(0xFF221610);
  static const phoneGreen = Color(0xFF25D366);
  static const peruRed = Color(0xFFD91023);
}

class PhoneLoginScreen extends StatefulWidget {
  const PhoneLoginScreen({super.key});

  @override
  State<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends State<PhoneLoginScreen> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  bool _otpSent = false;
  bool _sendingOtp = false;
  String? _otpError;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  static const String _defaultCountryCode = '51';

  String _formatPhone(String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return '';
    if (digits.length <= 3) return digits;
    if (digits.length <= 6) return '${digits.substring(0, 3)} ${digits.substring(3)}';
    return '${digits.substring(0, 3)} ${digits.substring(3, 6)} ${digits.substring(6)}';
  }

  String _toE164(String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 9) return '';
    return '+$_defaultCountryCode$digits';
  }

  Future<void> _sendOtp() async {
    final digits = _phoneController.text.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 9) {
      setState(() => _otpError = 'Ingresa un número de 9 dígitos (ej: 987 654 321)');
      return;
    }
    final phone = _toE164(_phoneController.text);

    setState(() {
      _sendingOtp = true;
      _otpError = null;
    });

    try {
      final res = await AuthService.sendOtp(
        target: phone,
        channel: 'sms',
        purpose: 'login',
      );
      if (mounted) {
        setState(() {
          _otpSent = true;
          _sendingOtp = false;
        });
        // Modo desarrollo: backend devuelve dev_code cuando OTP_PROVIDER=local
        final devCode = res['dev_code']?.toString();
        if (devCode != null && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Código OTP (dev): $devCode'),
              duration: const Duration(seconds: 10),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _otpError = e.toString().replaceFirst('Exception: ', '');
          _sendingOtp = false;
        });
      }
    }
  }

  Future<void> _verifyAndLogin() async {
    final phone = _toE164(_phoneController.text);
    final code = _otpController.text.trim();

    if (code.length != 6) {
      setState(() => _otpError = 'El código debe tener 6 dígitos');
      return;
    }

    final auth = context.read<AuthProvider>();
    final success = await auth.loginWithOtp(phone, code);

    if (mounted && success) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const AuthWrapper()),
        (route) => false,
      );
    } else if (mounted && auth.error != null) {
      final msg = auth.error!;
      if (msg.contains('Credenciales inválidas') || msg.contains('inválidas')) {
        _showRegisterDialog(phone);
      }
    }
  }

  void _showRegisterDialog(String phone) {
    final nameController = TextEditingController();
    final lastNameController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Completa tu registro'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'No encontramos una cuenta con este número. Ingresa tu nombre para registrarte.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre',
                hintText: 'Juan',
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: lastNameController,
              decoration: const InputDecoration(
                labelText: 'Apellido',
                hintText: 'Pérez',
              ),
              textCapitalization: TextCapitalization.words,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              final firstName = nameController.text.trim();
              final lastName = lastNameController.text.trim();
              if (firstName.isEmpty) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(content: Text('Ingresa tu nombre')),
                );
                return;
              }
              Navigator.pop(ctx);

              final auth = context.read<AuthProvider>();
              final success = await auth.registerWithPhone(
                phone,
                firstName,
                lastName,
              );

              if (mounted && success) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const AuthWrapper()),
                  (route) => false,
                );
              }
            },
            child: const Text('Registrarme'),
          ),
        ],
      ),
    );
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                          const SizedBox(height: 32),
                          Text(
                            'Ingresa tu celular',
                            style: GoogleFonts.publicSans(
                              color: Colors.white,
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Te enviaremos un código de verificación por SMS',
                            style: GoogleFonts.publicSans(
                              color: Colors.white.withOpacity(0.75),
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 40),
                          _buildPhoneInput(),
                          if (_otpSent) ...[
                            const SizedBox(height: 24),
                            _buildOtpInput(),
                            const SizedBox(height: 12),
                            TextButton(
                              onPressed: _sendingOtp ? null : _sendOtp,
                              child: Text(
                                _sendingOtp ? 'Enviando...' : 'Reenviar código',
                                style: GoogleFonts.publicSans(color: Colors.white.withOpacity(0.9)),
                              ),
                            ),
                          ],
                          if (_otpError != null) ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.black26,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _otpError!,
                                style: GoogleFonts.publicSans(color: Colors.white, fontSize: 14),
                              ),
                            ),
                          ],
                          const SizedBox(height: 32),
                          _buildContinueButton(),
                        ],
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

  Widget _buildPhoneInput() {
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
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(color: Colors.white.withOpacity(0.1)),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const _PeruFlagIcon(width: 24, height: 16),
                    const SizedBox(width: 10),
                    Text(
                      '+51',
                      style: GoogleFonts.publicSans(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  enabled: !_otpSent,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    TextInputFormatter.withFunction((old, newText) {
                      final digits = newText.text.replaceAll(RegExp(r'\D'), '');
                      if (digits.length > 9) return old;
                      final formatted = _formatPhone(digits);
                      return TextEditingValue(
                        text: formatted,
                        selection: TextSelection.collapsed(offset: formatted.length),
                      );
                    }),
                  ],
                  style: GoogleFonts.publicSans(color: Colors.white, fontSize: 20),
                  decoration: InputDecoration(
                    hintText: 'Número de teléfono',
                    hintStyle: GoogleFonts.publicSans(color: Colors.white.withOpacity(0.4), fontSize: 18),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOtpInput() {
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
          child: TextField(
            controller: _otpController,
            keyboardType: TextInputType.number,
            maxLength: 6,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: GoogleFonts.publicSans(
              color: Colors.white,
              fontSize: 24,
              letterSpacing: 12,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              hintText: '000000',
              hintStyle: GoogleFonts.publicSans(
                color: Colors.white.withOpacity(0.4),
                letterSpacing: 12,
              ),
              counterText: '',
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 20),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContinueButton() {
    final isOtpStep = _otpSent;
    return Material(
      color: _Colors.phoneGreen,
      borderRadius: BorderRadius.circular(16),
      elevation: 8,
      shadowColor: _Colors.phoneGreen.withOpacity(0.3),
      child: InkWell(
        onTap: _sendingOtp
            ? null
            : () {
                if (isOtpStep) {
                  _verifyAndLogin();
                } else {
                  _sendOtp();
                }
              },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 64,
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _sendingOtp
                    ? 'Enviando...'
                    : isOtpStep
                        ? 'Verificar y continuar'
                        : 'Continuar',
                style: GoogleFonts.publicSans(
                  color: const Color(0xFF172211),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (!_sendingOtp) ...[
                const SizedBox(width: 8),
                Icon(Icons.arrow_forward, color: const Color(0xFF172211), size: 22),
              ],
            ],
          ),
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

class _PeruFlagIcon extends StatelessWidget {
  final double width;
  final double height;

  const _PeruFlagIcon({this.width = 24, this.height = 16});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(2),
      child: SizedBox(
        width: width,
        height: height,
        child: Row(
          children: [
            Expanded(child: Container(color: _Colors.peruRed)),
            Expanded(child: Container(color: Colors.white)),
            Expanded(child: Container(color: _Colors.peruRed)),
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
