import 'package:cloud_firestore/cloud_firestore.dart';

enum TxnType { recharge, vipPurchase, coupon, adminAdjust, refund }

extension TxnTypeX on TxnType {
  String get label {
    switch (this) {
      case TxnType.recharge:
        return 'Recharge';
      case TxnType.vipPurchase:
        return 'VIP Purchase';
      case TxnType.coupon:
        return 'Coupon';
      case TxnType.adminAdjust:
        return 'Admin Adjust';
      case TxnType.refund:
        return 'Refund';
    }
  }

  static TxnType fromString(String? v) {
    switch (v) {
      case 'vipPurchase':
        return TxnType.vipPurchase;
      case 'coupon':
        return TxnType.coupon;
      case 'adminAdjust':
        return TxnType.adminAdjust;
      case 'refund':
        return TxnType.refund;
      default:
        return TxnType.recharge;
    }
  }
}

/// Wallet transaction stored under `transactions/{id}`.
class TransactionModel {
  TransactionModel({
    required this.id,
    required this.uid,
    required this.amount,
    required this.type,
    required this.timestamp,
    this.note,
  });

  final String id;
  final String uid;
  final double amount;
  final TxnType type;
  final DateTime timestamp;
  final String? note;

  Map<String, dynamic> toMap() => <String, dynamic>{
        'uid': uid,
        'amount': amount,
        'type': type.name,
        'timestamp': Timestamp.fromDate(timestamp),
        'note': note,
      };

  factory TransactionModel.fromDoc(
      DocumentSnapshot<Map<String, dynamic>> snap) {
    final Map<String, dynamic> m = snap.data() ?? <String, dynamic>{};
    final dynamic ts = m['timestamp'];
    final DateTime t = ts is Timestamp
        ? ts.toDate()
        : DateTime.tryParse(ts?.toString() ?? '') ?? DateTime.now();
    return TransactionModel(
      id: snap.id,
      uid: (m['uid'] ?? '') as String,
      amount: (m['amount'] ?? 0).toDouble(),
      type: TxnTypeX.fromString(m['type'] as String?),
      timestamp: t,
      note: m['note'] as String?,
    );
  }
}
