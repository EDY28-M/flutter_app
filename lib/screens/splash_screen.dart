import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'auth_wrapper.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fastController;
  late AnimationController _goController;
  late AnimationController _outController;
  late Animation<double> _fastOpacity;
  late Animation<double> _goOpacity;
  late Animation<Offset> _goSlide;
  late Animation<double> _outOpacity;

  @override
  void initState() {
    super.initState();
    _fastController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _goController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );
    _outController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fastOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fastController, curve: Curves.easeOut),
    );
    _goOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _goController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
      ),
    );
    _goSlide = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _goController,
        curve: const Interval(0.1, 1.0, curve: Curves.easeOutCubic),
      ),
    );
    _outOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _outController, curve: Curves.easeIn),
    );

    _fastController.forward();
    Future.delayed(const Duration(milliseconds: 250), () {
      _goController.forward();
    });

    Future.delayed(const Duration(milliseconds: 3200), () {
      if (mounted) _outController.forward();
    });

    Future.delayed(const Duration(milliseconds: 4200), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const AuthWrapper(),
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 400),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _fastController.dispose();
    _goController.dispose();
    _outController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: Color(0xFF0D0D0D),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _outOpacity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                FadeTransition(
                  opacity: _fastOpacity,
                  child: Text(
                    'Fast',
                    style: GoogleFonts.publicSans(
                      color: Colors.white,
                      fontSize: 56,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                SlideTransition(
                  position: _goSlide,
                  child: FadeTransition(
                    opacity: _goOpacity,
                    child: Text(
                      'Go',
                      style: GoogleFonts.publicSans(
                        color: const Color(0xFFEC5B13),
                        fontSize: 56,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
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
}
