import 'dart:math';

import '../core/constants.dart';
import '../models/prediction_model.dart';

/// Single round result produced by the engine.
class EngineResult {
  EngineResult({
    required this.entryAt,
    required this.exitAt,
    required this.actualMultiplier,
    required this.confidence,
    required this.risk,
    required this.players,
    required this.poolAmount,
  });

  final double entryAt;
  final double exitAt;
  final double actualMultiplier;
  final double confidence;
  final RiskLevel risk;
  final int players;
  final double poolAmount;

  bool get win => actualMultiplier >= exitAt;
}

/// Simulated, weighted prediction engine.
///
/// IMPORTANT: This is a **simulation only** — for entertainment and educational
/// use. It does not predict the outcome of any real third-party game.
///
/// The multiplier distribution is loosely modeled on a heavy-tailed log-uniform
/// to mimic the "many small wins, occasional huge spike" feel of crash games.
class PredictionEngine {
  PredictionEngine({Random? rng}) : _rng = rng ?? Random();

  final Random _rng;

  /// Generate a single round.
  EngineResult generate() {
    final double actualMultiplier = _sampleMultiplier();

    // Recommended exit ALWAYS conservative when AI confidence is low.
    final double confidence = _confidenceFor(actualMultiplier);
    final RiskLevel risk = _riskFor(actualMultiplier);

    // Entry recommendation: small early entry under 1.50x for safer rounds.
    final double entryAt = _round(1.05 + _rng.nextDouble() * 0.40);

    // Exit target shrinks as risk rises.
    final double exitTarget = _exitTarget(actualMultiplier, risk);

    final int players = 800 + _rng.nextInt(8400);
    final double poolAmount =
        _round(players * (3 + _rng.nextDouble() * 18), digits: 2);

    return EngineResult(
      entryAt: entryAt,
      exitAt: exitTarget,
      actualMultiplier: _round(actualMultiplier),
      confidence: confidence,
      risk: risk,
      players: players,
      poolAmount: poolAmount,
    );
  }

  /// Heavy-tailed sample with a long tail up to maxMultiplier.
  double _sampleMultiplier() {
    final double u = _rng.nextDouble();
    // 65% of rounds end below 2x, 30% between 2x-10x, 5% above 10x.
    if (u < 0.65) {
      return AppConstants.minMultiplier + _rng.nextDouble() * (2.0 - 1.01);
    } else if (u < 0.95) {
      return 2.0 + _rng.nextDouble() * 8.0;
    } else {
      // Long tail: log-uniform between 10x and maxMultiplier.
      final double a = log(10);
      final double b = log(AppConstants.maxMultiplier);
      return exp(a + _rng.nextDouble() * (b - a));
    }
  }

  double _confidenceFor(double m) {
    // Higher multipliers = lower confidence. Map [1.01, 120] → [0.95, 0.45].
    final double t =
        ((m - AppConstants.minMultiplier) / (AppConstants.maxMultiplier - 1.01))
            .clamp(0.0, 1.0);
    final double base = 0.95 - t * 0.50;
    final double jitter = (_rng.nextDouble() - 0.5) * 0.06;
    return ((base + jitter) * 100).clamp(40.0, 99.0);
  }

  RiskLevel _riskFor(double m) {
    if (m < 1.6) return RiskLevel.low;
    if (m < 4.5) return RiskLevel.medium;
    return RiskLevel.high;
  }

  double _exitTarget(double m, RiskLevel r) {
    switch (r) {
      case RiskLevel.low:
        return _round(min(m, 1.45));
      case RiskLevel.medium:
        return _round(min(m, 2.30));
      case RiskLevel.high:
        return _round(min(m, 3.50));
    }
  }

  double _round(double v, {int digits = 2}) {
    final num p = pow(10, digits);
    return (v * p).round() / p;
  }
}
