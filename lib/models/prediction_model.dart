import 'package:cloud_firestore/cloud_firestore.dart';

enum RiskLevel { low, medium, high }

extension RiskLevelX on RiskLevel {
  String get label {
    switch (this) {
      case RiskLevel.low:
        return 'Low';
      case RiskLevel.medium:
        return 'Medium';
      case RiskLevel.high:
        return 'High';
    }
  }

  static RiskLevel fromString(String? value) {
    switch (value) {
      case 'high':
        return RiskLevel.high;
      case 'medium':
        return RiskLevel.medium;
      default:
        return RiskLevel.low;
    }
  }
}

/// One simulated prediction round persisted under `predictions/{id}`.
class PredictionModel {
  PredictionModel({
    required this.id,
    required this.uid,
    required this.round,
    required this.entryAt,
    required this.exitAt,
    required this.actualMultiplier,
    required this.confidence,
    required this.risk,
    required this.players,
    required this.poolAmount,
    required this.timestamp,
    this.win = false,
  });

  final String id;
  final String uid;
  final int round;
  final double entryAt;
  final double exitAt;
  final double actualMultiplier;
  final double confidence;
  final RiskLevel risk;
  final int players;
  final double poolAmount;
  final DateTime timestamp;
  final bool win;

  Map<String, dynamic> toMap() => <String, dynamic>{
        'uid': uid,
        'round': round,
        'entryAt': entryAt,
        'exitAt': exitAt,
        'actualMultiplier': actualMultiplier,
        'confidence': confidence,
        'risk': risk.name,
        'players': players,
        'poolAmount': poolAmount,
        'timestamp': Timestamp.fromDate(timestamp),
        'win': win,
      };

  factory PredictionModel.fromDoc(
      DocumentSnapshot<Map<String, dynamic>> snap) {
    final Map<String, dynamic> map = snap.data() ?? <String, dynamic>{};
    final dynamic ts = map['timestamp'];
    final DateTime t = ts is Timestamp
        ? ts.toDate()
        : DateTime.tryParse(ts?.toString() ?? '') ?? DateTime.now();
    return PredictionModel(
      id: snap.id,
      uid: (map['uid'] ?? '') as String,
      round: (map['round'] ?? 0) as int,
      entryAt: (map['entryAt'] ?? 0).toDouble(),
      exitAt: (map['exitAt'] ?? 0).toDouble(),
      actualMultiplier: (map['actualMultiplier'] ?? 0).toDouble(),
      confidence: (map['confidence'] ?? 0).toDouble(),
      risk: RiskLevelX.fromString(map['risk'] as String?),
      players: (map['players'] ?? 0) as int,
      poolAmount: (map['poolAmount'] ?? 0).toDouble(),
      timestamp: t,
      win: (map['win'] ?? false) as bool,
    );
  }
}
