import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants.dart';
import '../../models/user_model.dart';
import '../../providers/user_provider.dart';
import '../../services/firestore_service.dart';
import '../../utils/formatters.dart';
import '../../widgets/glow_card.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/section_header.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  @override
  Widget build(BuildContext context) {
    final UserProvider me = context.watch<UserProvider>();
    if (!me.isAdmin) {
      return Scaffold(
        appBar: AppBar(title: const Text('Admin')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Access denied. Admin privileges required.',
              style: TextStyle(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Admin Panel')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SectionHeader(title: 'Activity (last 7 days)'),
              GlowCard(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  height: 180,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      titlesData: const FlTitlesData(show: false),
                      borderData: FlBorderData(show: false),
                      gridData: const FlGridData(show: false),
                      barGroups: <BarChartGroupData>[
                        for (int i = 0; i < 7; i++)
                          BarChartGroupData(x: i, barRods: <BarChartRodData>[
                            BarChartRodData(
                              toY: (40 + (i * 13) % 80).toDouble(),
                              gradient: AppColors.accentGradient,
                              width: 18,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ]),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: <Widget>[
                  Expanded(
                    child: PrimaryButton(
                      gradient: false,
                      label: 'Send broadcast',
                      icon: Icons.notifications_active_rounded,
                      onPressed: _broadcastDialog,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              const SectionHeader(title: 'Users'),
              StreamBuilder<List<AppUser>>(
                stream: FirestoreService.instance.allUsers(),
                builder: (BuildContext context,
                    AsyncSnapshot<List<AppUser>> snap) {
                  final List<AppUser> users = snap.data ?? <AppUser>[];
                  if (users.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(20),
                      child: Text('No users yet.',
                          style: TextStyle(color: AppColors.textMuted)),
                    );
                  }
                  return Column(
                    children: users
                        .map((AppUser u) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: _userTile(u),
                            ))
                        .toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _userTile(AppUser u) {
    return GlowCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.cardHigh,
                backgroundImage:
                    u.avatar != null ? NetworkImage(u.avatar!) : null,
                child: u.avatar == null
                    ? Text(
                        u.name.characters.first.toUpperCase(),
                        style: const TextStyle(
                          color: AppColors.accent,
                          fontWeight: FontWeight.w700,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(u.name,
                        style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700)),
                    Text(u.email,
                        style: const TextStyle(
                            color: AppColors.textMuted, fontSize: 12)),
                  ],
                ),
              ),
              Text(Fmt.money(u.walletBalance),
                  style: const TextStyle(
                    color: AppColors.accent,
                    fontWeight: FontWeight.w800,
                  )),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: <Widget>[
              _smallChip(u.membership.label),
              if (u.isAdmin) ...<Widget>[
                const SizedBox(width: 6),
                _smallChip('ADMIN', color: AppColors.warning),
              ],
              const Spacer(),
              IconButton(
                tooltip: 'Adjust balance',
                icon: const Icon(Icons.payments_rounded,
                    color: AppColors.accent),
                onPressed: () => _adjustBalance(u),
              ),
              IconButton(
                tooltip: 'Grant VIP',
                icon: const Icon(Icons.workspace_premium_rounded,
                    color: AppColors.accent),
                onPressed: () => _grantVip(u),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _smallChip(String label, {Color color = AppColors.accent}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(.15),
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: color.withOpacity(.5)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 10,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Future<void> _adjustBalance(AppUser u) async {
    final TextEditingController c = TextEditingController();
    final String? value = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.card,
        title: Text('Adjust balance for ${u.name}',
            style: const TextStyle(color: AppColors.textPrimary)),
        content: TextField(
          controller: c,
          keyboardType:
              const TextInputType.numberWithOptions(signed: true, decimal: true),
          decoration: const InputDecoration(
            labelText: 'Delta amount (use negative to deduct)',
          ),
        ),
        actions: <Widget>[
          TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel',
                  style: TextStyle(color: AppColors.textMuted))),
          ElevatedButton(
              onPressed: () => Navigator.of(context).pop(c.text),
              child: const Text('Apply')),
        ],
      ),
    );
    if (value == null) return;
    final double? delta = double.tryParse(value);
    if (delta == null) return;
    await FirestoreService.instance
        .adjustBalance(u.uid, delta, note: 'Admin adjust');
  }

  Future<void> _grantVip(AppUser u) async {
    final Membership? tier = await showModalBottomSheet<Membership>(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: Membership.values
              .map((Membership m) => ListTile(
                    leading: const Icon(Icons.workspace_premium_rounded,
                        color: AppColors.accent),
                    title: Text(m.label,
                        style: const TextStyle(color: AppColors.textPrimary)),
                    onTap: () => Navigator.of(context).pop(m),
                  ))
              .toList(),
        ),
      ),
    );
    if (tier == null) return;
    await FirestoreService.instance.grantMembership(u.uid, tier);
  }

  Future<void> _broadcastDialog() async {
    final TextEditingController title = TextEditingController();
    final TextEditingController body = TextEditingController();
    final bool? send = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.card,
        title: const Text('Send broadcast',
            style: TextStyle(color: AppColors.textPrimary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextField(
              controller: title,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: body,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Message'),
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel',
                  style: TextStyle(color: AppColors.textMuted))),
          ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Send')),
        ],
      ),
    );
    if (send != true) return;
    await FirestoreService.instance.broadcastNotification(
      title: title.text,
      body: body.text,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Broadcast queued.')),
    );
  }
}
