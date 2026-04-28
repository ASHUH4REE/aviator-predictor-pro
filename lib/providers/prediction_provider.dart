import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/prediction_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/prediction_engine.dart';
import '../core/constants.dart';

/// Drives the live predictor screen: round timer, current engine result,
/// rolling chart history, lifetime accuracy.
class PredictionProvider extends ChangeNotifier {
  PredictionProvider();

  final PredictionEngine _engine = PredictionEngine();

  Timer? _timer;
  int _round = 1;
  int _secondsLeft = AppConstants.roundDuration.inSeconds;
  EngineResult? _current;
  final List<double> _history = <double>[];
  int _onlineUsers = 1832;
  int _totalPredictions = 0;
  int _wins = 0;

  // ---------- Getters ----------
  int get round => _round;
  int get secondsLeft => _secondsLeft;
  EngineResult? get current => _current;
  List<double> get history => List<double>.unmodifiable(_history);
  int get onlineUsers => _onlineUsers;
  int get totalPredictions => _totalPredictions;
  bool get isRunning => _timer?.isActive ?? false;

  double get accuracy {
    if (_totalPredictions == 0) return 0;
    return (_wins / _totalPredictions) * 100;
  }

  // ---------- Engine control ----------
  void start() {
    if (_timer?.isActive ?? false) return;
    _generateRound();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    notifyListeners();
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    notifyListeners();
  }

  void _tick() {
    _secondsLeft -= 1;
    // Slowly drift online users for "live" feel.
    _onlineUsers += [-3, -1, 0, 0, 1, 2, 4][DateTime.now().second % 7];
    if (_onlineUsers < 800) _onlineUsers = 800;
    if (_secondsLeft <= 0) {
      _generateRound();
    }
    notifyListeners();
  }

  Future<void> _generateRound() async {
    _current = _engine.generate();
    _round += 1;
    _secondsLeft = AppConstants.roundDuration.inSeconds;
    _history.add(_current!.actualMultiplier);
    if (_history.length > 24) _history.removeAt(0);
    _totalPredictions += 1;
    if (_current!.win) _wins += 1;

    final String? uid = AuthService.instance.currentUser?.uid;
    if (uid != null) {
      final PredictionModel model = PredictionModel(
        id: '',
        uid: uid,
        round: _round,
        entryAt: _current!.entryAt,
        exitAt: _current!.exitAt,
        actualMultiplier: _current!.actualMultiplier,
        confidence: _current!.confidence,
        risk: _current!.risk,
        players: _current!.players,
        poolAmount: _current!.poolAmount,
        timestamp: DateTime.now(),
        win: _current!.win,
      );
      // Fire-and-forget — UI doesn't block on the persistence step.
      // ignore: discarded_futures
      FirestoreService.instance.savePrediction(model);
    }
  }

  /// Manual single round (used by the "Generate" button).
  void generateOnce() => _generateRound();

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
