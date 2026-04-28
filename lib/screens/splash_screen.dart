import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../core/constants.dart';
import '../core/router.dart';
import '../services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    // Min splash time so the brand is felt.
    await Future<void>.delayed(const Duration(milliseconds: 1600));
    if (!mounted) return;
    final bool signedIn = AuthService.instance.currentUser != null;
    Navigator.of(context).pushReplacementNamed(
      signedIn ? AppRouter.home : AppRouter.login,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            radius: 0.9,
            colors: <Color>[
              Color(0xFF1B0606),
              AppColors.background,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _LogoMark(),
              const SizedBox(height: 24),
              Text(
                AppConstants.appName.toUpperCase(),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 4,
                  color: AppColors.textPrimary,
                ),
              )
                  .animate()
                  .fadeIn(duration: 600.ms, delay: 400.ms)
                  .slideY(begin: 0.2, end: 0),
              const SizedBox(height: 6),
              Text(
                AppConstants.appTagline,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  letterSpacing: 1.2,
                  fontSize: 12,
                ),
              ).animate().fadeIn(duration: 700.ms, delay: 700.ms),
              const SizedBox(height: 50),
              const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LogoMark extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 96,
      width: 96,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppColors.accentGradient,
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: AppColors.accentGlow,
            blurRadius: 40,
            spreadRadius: 4,
          ),
        ],
      ),
      child: const Icon(
        Icons.flight_takeoff_rounded,
        color: Colors.white,
        size: 48,
      ),
    )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .scale(
          begin: const Offset(1, 1),
          end: const Offset(1.06, 1.06),
          duration: 1400.ms,
          curve: Curves.easeInOut,
        );
  }
}
