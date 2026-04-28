import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/constants.dart';
import '../models/prediction_model.dart';
import '../models/transaction_model.dart';
import '../models/user_model.dart';

/// Thin Firestore data layer. Providers/UI use these helpers — never raw queries.
class FirestoreService {
  FirestoreService._();
  static final FirestoreService instance = FirestoreService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ---------- USERS ----------
  Stream<AppUser?> userStream(String uid) {
    return _db
        .collection(FirestorePaths.users)
        .doc(uid)
        .snapshots()
        .map((DocumentSnapshot<Map<String, dynamic>> snap) {
      if (!snap.exists) return null;
      return AppUser.fromMap(snap.data()!);
    });
  }

  Future<AppUser?> fetchUser(String uid) async {
    final DocumentSnapshot<Map<String, dynamic>> snap =
        await _db.collection(FirestorePaths.users).doc(uid).get();
    if (!snap.exists) return null;
    return AppUser.fromMap(snap.data()!);
  }

  Future<void> updateUser(String uid, Map<String, dynamic> data) {
    return _db.collection(FirestorePaths.users).doc(uid).update(data);
  }

  Stream<List<AppUser>> allUsers() {
    return _db
        .collection(FirestorePaths.users)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((QuerySnapshot<Map<String, dynamic>> snap) => snap.docs
            .map((QueryDocumentSnapshot<Map<String, dynamic>> d) =>
                AppUser.fromMap(d.data()))
            .toList());
  }

  Future<void> grantMembership(String uid, Membership m) {
    return updateUser(uid, <String, dynamic>{'membership': m.value});
  }

  Future<void> adjustBalance(String uid, double delta, {String? note}) async {
    final DocumentReference<Map<String, dynamic>> ref =
        _db.collection(FirestorePaths.users).doc(uid);
    await _db.runTransaction((Transaction txn) async {
      final DocumentSnapshot<Map<String, dynamic>> snap = await txn.get(ref);
      final double current = (snap.data()?['walletBalance'] ?? 0).toDouble();
      txn.update(ref, <String, dynamic>{'walletBalance': current + delta});
    });
    final TransactionModel record = TransactionModel(
      id: '',
      uid: uid,
      amount: delta,
      type: TxnType.adminAdjust,
      timestamp: DateTime.now(),
      note: note,
    );
    await _db.collection(FirestorePaths.transactions).add(record.toMap());
  }

  // ---------- PREDICTIONS ----------
  Future<DocumentReference<Map<String, dynamic>>> savePrediction(
      PredictionModel p) {
    return _db.collection(FirestorePaths.predictions).add(p.toMap());
  }

  Stream<List<PredictionModel>> userPredictions(String uid, {int limit = 100}) {
    return _db
        .collection(FirestorePaths.predictions)
        .where('uid', isEqualTo: uid)
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map((QuerySnapshot<Map<String, dynamic>> snap) => snap.docs
            .map(PredictionModel.fromDoc)
            .toList());
  }

  // ---------- TRANSACTIONS ----------
  Future<void> addTransaction(TransactionModel t) =>
      _db.collection(FirestorePaths.transactions).add(t.toMap());

  Stream<List<TransactionModel>> userTransactions(String uid) {
    return _db
        .collection(FirestorePaths.transactions)
        .where('uid', isEqualTo: uid)
        .orderBy('timestamp', descending: true)
        .limit(100)
        .snapshots()
        .map((QuerySnapshot<Map<String, dynamic>> snap) => snap.docs
            .map(TransactionModel.fromDoc)
            .toList());
  }

  // ---------- SETTINGS / COUPONS ----------
  Future<double?> redeemCoupon(String code) async {
    final DocumentSnapshot<Map<String, dynamic>> snap =
        await _db.collection(FirestorePaths.settings).doc('coupons').get();
    if (!snap.exists) return null;
    final Map<String, dynamic> data = snap.data() ?? <String, dynamic>{};
    final dynamic value = data[code.toUpperCase()];
    if (value == null) return null;
    return (value as num).toDouble();
  }

  // ---------- NOTIFICATIONS (admin) ----------
  Future<void> broadcastNotification({
    required String title,
    required String body,
  }) {
    return _db.collection(FirestorePaths.notifications).add(<String, dynamic>{
      'title': title,
      'body': body,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
