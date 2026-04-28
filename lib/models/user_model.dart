import 'package:cloud_firestore/cloud_firestore.dart';

/// Membership tiers shown on the profile and wallet pages.
enum Membership { free, silver, gold, platinum }

extension MembershipX on Membership {
  String get label {
    switch (this) {
      case Membership.free:
        return 'Free';
      case Membership.silver:
        return 'Silver VIP';
      case Membership.gold:
        return 'Gold VIP';
      case Membership.platinum:
        return 'Platinum VIP';
    }
  }

  static Membership fromString(String? value) {
    switch (value) {
      case 'silver':
        return Membership.silver;
      case 'gold':
        return Membership.gold;
      case 'platinum':
        return Membership.platinum;
      default:
        return Membership.free;
    }
  }

  String get value => name;
}

/// Application user — mirrors the `users/{uid}` Firestore document.
class AppUser {
  AppUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.createdAt,
    this.membership = Membership.free,
    this.walletBalance = 0,
    this.avatar,
    this.isAdmin = false,
  });

  final String uid;
  final String name;
  final String email;
  final String phone;
  final DateTime createdAt;
  final Membership membership;
  final double walletBalance;
  final String? avatar;
  final bool isAdmin;

  AppUser copyWith({
    String? name,
    String? email,
    String? phone,
    Membership? membership,
    double? walletBalance,
    String? avatar,
    bool? isAdmin,
  }) {
    return AppUser(
      uid: uid,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      createdAt: createdAt,
      membership: membership ?? this.membership,
      walletBalance: walletBalance ?? this.walletBalance,
      avatar: avatar ?? this.avatar,
      isAdmin: isAdmin ?? this.isAdmin,
    );
  }

  Map<String, dynamic> toMap() => <String, dynamic>{
        'uid': uid,
        'name': name,
        'email': email,
        'phone': phone,
        'createdAt': Timestamp.fromDate(createdAt),
        'membership': membership.value,
        'walletBalance': walletBalance,
        'avatar': avatar,
        'isAdmin': isAdmin,
      };

  factory AppUser.fromMap(Map<String, dynamic> map) {
    final dynamic ts = map['createdAt'];
    final DateTime created = ts is Timestamp
        ? ts.toDate()
        : DateTime.tryParse(ts?.toString() ?? '') ?? DateTime.now();
    return AppUser(
      uid: map['uid'] as String,
      name: (map['name'] ?? '') as String,
      email: (map['email'] ?? '') as String,
      phone: (map['phone'] ?? '') as String,
      createdAt: created,
      membership: MembershipX.fromString(map['membership'] as String?),
      walletBalance: (map['walletBalance'] ?? 0).toDouble(),
      avatar: map['avatar'] as String?,
      isAdmin: (map['isAdmin'] ?? false) as bool,
    );
  }
}
