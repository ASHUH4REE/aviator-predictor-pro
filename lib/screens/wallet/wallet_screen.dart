import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants.dart';
import '../../models/transaction_model.dart';
import '../../models/user_model.dart';
import '../../providers/user_provider.dart';
import '../../services/firestore_service.dart';
import '../../utils/formatters.dart';
import '../../widgets/glow_card.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/section_header.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final TextEditingController _coupon = TextEditingController();
  bool _redeeming = false;

  @override
  void dispose() {
    _coupon.dispose();
    super.dispose();
  }

  Future<void> _applyCoupon(AppUser user) async {
    final String code = _coupon.text.trim();
    if (code.isEmpty) return;
    setState(() => _redeeming = true);
    try {
      final double? amount =
          await FirestoreService.instance.redeemCoupon(code);
      if (!mounted) return;
      if (amount == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid coupon code.')),
        );
        return;
      }
      await FirestoreService.instance.adjustBalance(
        user.uid,
        amount,
        note: 'Coupon $code',
      );
      await FirestoreService.instance.addTransaction(
        TransactionModel(
          id: '',
          uid: user.uid,
          amount: amount,
          type: TxnType.coupon,
          timestamp: DateTime.now(),
          note: 'Coupon $code',
        ),
      );
      _coupon.clear();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Applied ${Fmt.money(amount)} to your wallet.')),
      );
    } finally {
      if (mounted) setState(() => _redeeming = false);
    }
  }

  Future<void> _purchaseVip(AppUser user, Membership tier, double price) async {
    if (user.walletBalance < price) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Insufficient balance.')),
      );
      return;
    }
    await FirestoreService.instance
        .adjustBalance(user.uid, -price, note: 'VIP ${tier.label}');
    await FirestoreService.instance.grantMembership(user.uid, tier);
    await FirestoreService.instance.addTransaction(
      TransactionModel(
        id: '',
        uid: user.uid,
        amount: -price,
        type: TxnType.vipPurchase,
        timestamp: DateTime.now(),
        note: tier.label,
      ),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${tier.label} activated.')),
    );
  }

  Future<void> _simulateRecharge(AppUser user, double amount) async {
    await FirestoreService.instance.adjustBalance(user.uid, amount);
    await FirestoreService.instance.addTransaction(
      TransactionModel(
        id: '',
        uid: user.uid,
        amount: amount,
        type: TxnType.recharge,
        timestamp: DateTime.now(),
        note: 'In-app recharge',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppUser? user = context.watch<UserProvider>().profile;
    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Wallet & VIP',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 14),
            GlowCard(
              glow: true,
              gradient: AppColors.surfaceGradient,
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    'CURRENT BALANCE',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      letterSpacing: 1.6,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    Fmt.money(user.walletBalance),
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 40,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.6,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: <Widget>[
                      const Icon(Icons.workspace_premium_rounded,
                          size: 16, color: AppColors.accent),
                      const SizedBox(width: 4),
                      Text(
                        'Membership: ${user.membership.label}',
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: PrimaryButton(
                          label: 'Recharge \$50',
                          icon: Icons.add_rounded,
                          onPressed: () => _simulateRecharge(user, 50),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: PrimaryButton(
                          gradient: false,
                          label: 'Recharge \$200',
                          icon: Icons.add_rounded,
                          onPressed: () => _simulateRecharge(user, 200),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            const SectionHeader(title: 'VIP Plans'),
            _vipCard(user, 'Silver VIP', Membership.silver, 99,
                'Daily premium predictions.'),
            const SizedBox(height: 10),
            _vipCard(user, 'Gold VIP', Membership.gold, 199,
                'Priority signals + risk filter.'),
            const SizedBox(height: 10),
            _vipCard(user, 'Platinum VIP', Membership.platinum, 399,
                'All features + 1:1 support.'),
            const SizedBox(height: 22),
            const SectionHeader(title: 'Apply coupon'),
            GlowCard(
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: _coupon,
                      textCapitalization: TextCapitalization.characters,
                      decoration: const InputDecoration(
                        hintText: 'Enter code',
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        filled: false,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  PrimaryButton(
                    label: 'Apply',
                    icon: Icons.local_offer_rounded,
                    expanded: false,
                    loading: _redeeming,
                    onPressed: () => _applyCoupon(user),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            const SectionHeader(title: 'Recent transactions'),
            StreamBuilder<List<TransactionModel>>(
              stream: FirestoreService.instance.userTransactions(user.uid),
              builder: (BuildContext context,
                  AsyncSnapshot<List<TransactionModel>> snap) {
                final List<TransactionModel> txs =
                    snap.data ?? <TransactionModel>[];
                if (txs.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(18),
                    child: Text('No transactions yet.',
                        style: TextStyle(color: AppColors.textMuted)),
                  );
                }
                return Column(
                  children: txs
                      .map((TransactionModel t) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _txnRow(t),
                          ))
                      .toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _vipCard(
      AppUser user, String title, Membership tier, double price, String desc) {
    final bool isCurrent = user.membership == tier;
    return GlowCard(
      glow: tier == Membership.platinum,
      borderColor:
          isCurrent ? AppColors.accent.withOpacity(.6) : AppColors.border,
      child: Row(
        children: <Widget>[
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: AppColors.accentGradient,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.workspace_premium_rounded,
                color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(desc,
                    style: const TextStyle(
                        color: AppColors.textMuted, fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Text(
                Fmt.money(price),
                style: const TextStyle(
                  color: AppColors.accent,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              ElevatedButton(
                onPressed: isCurrent ? null : () => _purchaseVip(user, tier, price),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  textStyle: const TextStyle(fontSize: 12),
                ),
                child: Text(isCurrent ? 'Current' : 'Choose'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _txnRow(TransactionModel t) {
    final bool credit = t.amount >= 0;
    final Color color = credit ? AppColors.success : AppColors.danger;
    return GlowCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: <Widget>[
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withOpacity(.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              credit ? Icons.south_west_rounded : Icons.north_east_rounded,
              color: color,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(t.type.label,
                    style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700)),
                Text(Fmt.date(t.timestamp),
                    style: const TextStyle(
                        color: AppColors.textMuted, fontSize: 11)),
              ],
            ),
          ),
          Text(
            '${credit ? '+' : ''}${Fmt.money(t.amount)}',
            style: TextStyle(color: color, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}
