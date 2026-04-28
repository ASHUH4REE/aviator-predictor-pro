import 'package:flutter/material.dart';

/// App-wide constants. Tweak brand identifiers, external links and limits here.
class AppConstants {
  AppConstants._();

  // Brand
  static const String appName = 'Aviator Predictor Pro';
  static const String appTagline = 'Predict. Play. Profit.';

  // External links
  static const String telegramUrl = 'https://t.me/your_channel_here';
  static const String supportEmail = 'support@aviatorpredictor.app';

  // Predictor engine bounds
  static const double minMultiplier = 1.01;
  static const double maxMultiplier = 120.0;
  static const Duration roundDuration = Duration(seconds: 12);

  // Wallet defaults
  static const double signupBonus = 50.0;
  static const String currencySymbol = '\$';
}

/// Centralised palette so screens never hardcode raw hex values.
class AppColors {
  AppColors._();

  static const Color background = Color(0xFF070707);
  static const Color surface = Color(0xFF111114);
  static const Color card = Color(0xFF17171B);
  static const Color cardHigh = Color(0xFF1F1F25);
  static const Color border = Color(0xFF26262E);

  static const Color accent = Color(0xFFFF1E1E);
  static const Color accentSoft = Color(0xFFFF5F5F);
  static const Color accentGlow = Color(0x66FF1E1E);

  static const Color success = Color(0xFF22D38F);
  static const Color warning = Color(0xFFFFB020);
  static const Color danger = Color(0xFFFF4B4B);

  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB6B6C0);
  static const Color textMuted = Color(0xFF6B6B78);

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[Color(0xFFFF1E1E), Color(0xFFB30000)],
  );

  static const LinearGradient surfaceGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[Color(0xFF17171B), Color(0xFF0C0C10)],
  );
}

/// Firestore collection names — single source of truth.
class FirestorePaths {
  FirestorePaths._();
  static const String users = 'users';
  static const String predictions = 'predictions';
  static const String transactions = 'transactions';
  static const String settings = 'settings';
  static const String notifications = 'notifications';
}
