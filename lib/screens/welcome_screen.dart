import 'dart:ui';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/auth_provider.dart';
import 'phone_login_screen.dart';
import 'email_login_screen.dart';
import 'home_screen.dart';

class _AppColors {
  static const primary = Color(0xFFEC5B13);
  static const primaryMid = Color(0xFF9A3412);
  static const backgroundDark = Color(0xFF221610);
  static const brandYellow = Color(0xFFFFD700);
  static const phoneGreen = Color(0xFF25D366);
  static const slate700 = Color(0xFF334155); // Tailwind slate-700
  static const slate900 = Color(0xFF0F172A);
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

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
              _AppColors.primary,
              _AppColors.primaryMid,
              _AppColors.backgroundDark,
            ],
          ),
        ),
        child: Stack(
          children: [
            _buildBackgroundOverlay(),
            SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 24),
                    child: _buildLogo(),
                  ),
                  const Spacer(),
                  SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _buildContent(context),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundOverlay() {
    return Positioned.fill(
      child: IgnorePointer(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            return Stack(
              children: [
                Opacity(
                  opacity: 0.2,
                  child: Stack(
                    children: [
                      Positioned(top: 40, left: 40, child: _overlayImage(_overlayUrls[0], 120, true)),
                      Positioned(top: 140, right: -15, child: Transform.rotate(angle: 0.2, child: _overlayImage(_overlayUrls[1], 160, false, 12))),
                      Positioned(top: 240, left: 25, child: Transform.rotate(angle: -0.08, child: _overlayImage(_overlayUrls[2], 100, true))),
                      Positioned(top: 320, right: 30, child: Transform.rotate(angle: -0.18, child: _overlayImage(_overlayUrls[3], 110, false, 10))),
                    ],
                  ),
                ),
                CustomPaint(
                  size: Size(w, constraints.maxHeight * 0.5),
                  painter: _PatternPainter(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  static const _overlayUrls = [
    'https://lh3.googleusercontent.com/aida-public/AB6AXuAHlyTpHl7vr4PWj9z1vZX7aKm_nRUts567UckxBp-M44EE08C7v1FkXcEPqXNxMDFtM75goz47822aAmQ12RX2k2E2Tr-Z_5fCP3yHqOnG-BNI0s9Y-NLNkh997l1dXWIr_S1WLsmaw9wJVjnQrrDI5gBzQGwBB0CHuVG9hqxPK7N7MLS4yglPrG8TPg-RrYduB7jYLyfcw3lnmSZ7cSeVFjbnzYGUcvSe1vIUdaSvnoGY9-tUkgzuRowQ5ZpjDih75tSIZNFbM3iN',
    'https://lh3.googleusercontent.com/aida-public/AB6AXuD4G9QAST9hNt2hH4pBOFMZTrlVN71WmepPANZVfeANoD8TTv1Y_FIIie09WEGumdxahF2mCKFNjgyYA1dgegH3wWoPcKHiTiXnURaiLK7K365sUKhZLeDOndtXVYVXKFrPYN7G9ZEwrkBPuWzFS-waE2o82x7TonuBu9I3bRoVxKFPdhXDjfVDZLKYC_23jLMdGAyp1jSIE6gSUtxnbLHd2ID4RE8PCO5pHWPIVI6t806iGVwLgDxL0UGWL_qtEiGXSMmDWiSxCokQ',
    'https://lh3.googleusercontent.com/aida-public/AB6AXuAxW9hYCseKUv_C6OrcaYNCLhtkZOBopXfEh9gLcWcvMj9Deb_WxOyvyIwx8wryyMS0Xl00jcL8cnAvN1IusF6sVZGXf0Pfj8Hvv6zjGnGj1T4Bkx7XDbevHMDK72l07y93c2BtENdnyc_7dnhJzDqrzBpMfkXw57LVN677h4Xvhyw1dG5aVmghOTQrXCcBsl2aTQF06KhXxJQu1nuoQky2LwBNIynR05xpOF2K3fKTYV-5McAlC4E0kpb4wy8OUpGH6xLQMYrbFvXt',
    'https://lh3.googleusercontent.com/aida-public/AB6AXuDDUgYAgPT9mCScyJDDlVPAKNs5fMElj6AbXIcMuyUeawjLytthYGIAODDwiBkvjM7JELoPZQUVHILCzoSwBo8Fu3uBWft_GmMQ6UJmhKMvTD_lhZWAVTeKOZYM1CICQyb3NSlCn21bG_1yIkjBZ1wLOhm1G5eH9vh37BRtIj14Ozh1Mce2i9ls32BeG-jrZfWMn9XXAg-B6mIJsDCwMxyb-V7-8p47-fY8aanKklidNPX9rppk-l_Fb3hoUe-BiXSgnb6ipeSUEHjt',
  ];

  Widget _overlayImage(String url, double size, bool circle, [double radius = 12]) {
    return ClipRRect(
      borderRadius: circle ? BorderRadius.circular(size / 2) : BorderRadius.circular(radius),
      child: SizedBox(
        width: size,
        height: size,
        child: CachedNetworkImage(
          imageUrl: url,
          fit: BoxFit.cover,
          placeholder: (_, __) => Container(color: Colors.white.withOpacity(0.25)),
          errorWidget: (_, __, ___) => Container(color: Colors.white.withOpacity(0.2)),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: const Icon(Icons.speed, color: Colors.white, size: 48),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: GoogleFonts.publicSans(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold, height: 1.2, letterSpacing: -0.5),
                children: [
                  const TextSpan(text: 'Obtén envíos '),
                  TextSpan(
                    text: 'GRATIS',
                    style: GoogleFonts.publicSans(color: _AppColors.brandYellow, fontSize: 36, fontWeight: FontWeight.bold),
                  ),
                  const TextSpan(text: ' en todo Tingo Maria'),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '*Válido para usuarios nuevos en FastGo',
              textAlign: TextAlign.center,
              style: GoogleFonts.publicSans(color: Colors.white.withOpacity(0.8), fontSize: 14),
            ),
            const SizedBox(height: 24),
            _buildAuthButtons(context),
            const SizedBox(height: 20),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: GoogleFonts.publicSans(color: Colors.white.withOpacity(0.4), fontSize: 12),
                children: [
                  const TextSpan(text: 'Al continuar, aceptas nuestros '),
                  TextSpan(
                    text: 'Términos y Condiciones',
                    style: GoogleFonts.publicSans(color: Colors.white.withOpacity(0.4), fontSize: 12, decoration: TextDecoration.underline),
                    recognizer: TapGestureRecognizer()..onTap = () {},
                  ),
                  const TextSpan(text: ' y '),
                  TextSpan(
                    text: 'Política de Privacidad',
                    style: GoogleFonts.publicSans(color: Colors.white.withOpacity(0.4), fontSize: 12, decoration: TextDecoration.underline),
                    recognizer: TapGestureRecognizer()..onTap = () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthButtons(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Column(
      children: [
        if (auth.error != null) ...[
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.amber[200], size: 24),
                const SizedBox(width: 12),
                Expanded(child: Text(auth.error!, style: GoogleFonts.publicSans(color: Colors.white, fontSize: 13))),
              ],
            ),
          ),
        ],
        _AuthButton(label: 'Continúa con Google', leading: _GoogleLogo(), backgroundColor: Colors.white, textColor: _AppColors.slate900, elevation: 8, onPressed: auth.isLoading ? null : () => _handleGoogleSignIn(context)),
        const SizedBox(height: 12),
        _AuthButton(label: 'Continúa con tu celular', leading: const Icon(Icons.phone_iphone, size: 24, color: Colors.white), backgroundColor: _AppColors.phoneGreen, textColor: Colors.white, elevation: 8, onPressed: auth.isLoading ? null : () => _navigateToPhoneLogin(context)),
        const SizedBox(height: 12),
        _AuthButton(label: 'Continúa con tu correo', leading: const Icon(Icons.mail, size: 24, color: Colors.white), backgroundColor: _AppColors.slate700, textColor: Colors.white, elevation: 8, onPressed: auth.isLoading ? null : () => _navigateToEmailLogin(context)),
        const SizedBox(height: 12),
        _AuthButton(label: 'Otros métodos de ingreso', leading: null, backgroundColor: _AppColors.slate900.withOpacity(0.5), textColor: _AppColors.phoneGreen, border: Border.all(color: Colors.white.withOpacity(0.1)), elevation: 0, useBlur: true, onPressed: auth.isLoading ? null : () => _showOtherMethods(context)),
        if (auth.isLoading) const Padding(padding: EdgeInsets.only(top: 24), child: CircularProgressIndicator(color: Colors.white)),
      ],
    );
  }

  Future<void> _handleGoogleSignIn(BuildContext context) async {
    final auth = context.read<AuthProvider>();
    final success = await auth.signInWithGoogle();
    if (context.mounted && success) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
    }
  }

  void _navigateToPhoneLogin(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PhoneLoginScreen()));
  }

  void _navigateToEmailLogin(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const EmailLoginScreen()));
  }

  void _showOtherMethods(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Otros métodos', style: GoogleFonts.publicSans(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ListTile(leading: const Icon(Icons.phone), title: const Text('Iniciar con celular'), onTap: () { Navigator.pop(ctx); if (context.mounted) _navigateToPhoneLogin(context); }),
            ListTile(leading: const Icon(Icons.email), title: const Text('Iniciar con correo'), onTap: () { Navigator.pop(ctx); if (context.mounted) _navigateToEmailLogin(context); }),
          ],
        ),
      ),
    );
  }
}

class _PatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.15);
    const spacing = 24.0;
    for (var y = 0.0; y < size.height; y += spacing) {
      for (var x = 0.0; x < size.width; x += spacing) {
        final offset = (y ~/ spacing + x ~/ spacing) % 2 == 0 ? 0.0 : spacing / 2;
        canvas.drawCircle(Offset(x + offset, y), 2.5, paint);
      }
    }
    final softPaint = Paint()..color = Colors.white.withOpacity(0.1);
    canvas.drawCircle(Offset(size.width * 0.15, size.height * 0.15), 90, softPaint);
    canvas.drawCircle(Offset(size.width * 0.88, size.height * 0.2), 70, softPaint);
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.28), 110, softPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

const _googleLogoSvg = '''
<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
  <path d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z" fill="#4285F4"/>
  <path d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z" fill="#34A853"/>
  <path d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z" fill="#FBBC05"/>
  <path d="M12 5.38c1.62 0 3.06.56 4.21 1.66l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z" fill="#EA4335"/>
</svg>
''';

class _GoogleLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20,
      height: 20,
      child: SvgPicture.string(
        _googleLogoSvg,
        fit: BoxFit.contain,
      ),
    );
  }
}

class _AuthButton extends StatelessWidget {
  final String label;
  final Widget? leading;
  final Color backgroundColor;
  final Color textColor;
  final double elevation;
  final Border? border;
  final bool useBlur;
  final VoidCallback? onPressed;

  const _AuthButton({required this.label, this.leading, required this.backgroundColor, required this.textColor, this.elevation = 0, this.border, this.useBlur = false, this.onPressed});

  @override
  Widget build(BuildContext context) {
    Widget child = Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(12),
      elevation: elevation,
      shadowColor: Colors.black26,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: border),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          height: 56,
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (leading != null) ...[leading!, const SizedBox(width: 12)],
              Text(label, style: GoogleFonts.publicSans(fontSize: 16, fontWeight: FontWeight.w600, color: textColor)),
            ],
          ),
        ),
      ),
    );

    if (useBlur) {
      child = ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
          child: child,
        ),
      );
    }

    return SizedBox(width: double.infinity, height: 56, child: child);
  }
}
