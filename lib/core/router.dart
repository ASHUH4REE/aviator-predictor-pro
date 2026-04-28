import 'package:flutter/material.dart';

import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/auth/phone_login_screen.dart';
import '../screens/home/home_shell.dart';
import '../screens/predictor/predictor_screen.dart';
import '../screens/history/history_screen.dart';
import '../screens/wallet/wallet_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/admin/admin_screen.dart';
import '../screens/splash_screen.dart';

/// Centralised navigation. All routes are typed strings to keep imports tidy.
class AppRouter {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String phoneLogin = '/phone-login';
  static const String home = '/home';
  static const String predictor = '/predictor';
  static const String history = '/history';
  static const String wallet = '/wallet';
  static const String profile = '/profile';
  static const String admin = '/admin';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    Widget page;
    switch (settings.name) {
      case splash:
        page = const SplashScreen();
        break;
      case login:
        page = const LoginScreen();
        break;
      case register:
        page = const RegisterScreen();
        break;
      case forgotPassword:
        page = const ForgotPasswordScreen();
        break;
      case phoneLogin:
        page = const PhoneLoginScreen();
        break;
      case home:
        page = const HomeShell();
        break;
      case predictor:
        page = const PredictorScreen();
        break;
      case history:
        page = const HistoryScreen();
        break;
      case wallet:
        page = const WalletScreen();
        break;
      case profile:
        page = const ProfileScreen();
        break;
      case admin:
        page = const AdminScreen();
        break;
      default:
        page = const SplashScreen();
    }

    // Smooth premium transition: fade + small upward slide.
    return PageRouteBuilder<dynamic>(
      settings: settings,
      transitionDuration: const Duration(milliseconds: 380),
      reverseTransitionDuration: const Duration(milliseconds: 240),
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, Animation<double> animation, __, Widget child) {
        final CurvedAnimation curve = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        return FadeTransition(
          opacity: curve,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.04),
              end: Offset.zero,
            ).animate(curve),
            child: child,
          ),
        );
      },
    );
  }
}
