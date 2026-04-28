import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../core/constants.dart';
import '../../providers/prediction_provider.dart';
import '../../providers/user_provider.dart';
import '../../utils/formatters.dart';
import '../../widgets/animated_count.dart';
import '../../widgets/glow_card.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/section_header.dart';
import '../../widgets/stat_tile.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PredictionProvider>().start();
    });
  }

  @override
  Widget build(BuildContext context) {
    final UserProvider user = context.watch<UserProvider>();
    final PredictionProvider pred = context.watch<PredictionProvider>();
    final String name = user.profile?.name.split(' ').first ?? 'Player';

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Header
            Row(
              children: <Widget>[
                CircleAvatar(
                  radius: 22,
                  backgroundColor: AppColors.cardHigh,
                  backgroundImage: user.profile?.avatar != null
                      ? NetworkImage(user.profile!.avatar!)
                      : null,
                  child: user.profile?.avatar == null
                      ? Text(
                          name.characters.first.toUpperCase(),
                          style: const TextStyle(
                            color: AppColors.accent,
                            fontWeight: FontWeight.w700,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text(
                      'Welcome back',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                        letterSpacing: 0.6,
                      ),
                    ),
                    Text(
                      name,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(.15),
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(color: AppColors.success.withOpacity(.6)),
                  ),
                  child: Row(
                    children: const <Widget>[
                      Icon(Icons.circle, color: AppColors.success, size: 8),
                      SizedBox(width: 6),
                      Text(
                        'Engine Live',
                        style: TextStyle(
                          color: AppColors.success,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),

            // Hero predictor card
            GlowCard(
              glow: true,
              gradient: AppColors.surfaceGradient,
              borderColor: AppColors.accent.withOpacity(.45),
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      const Icon(Icons.bolt_rounded,
                          color: AppColors.accent, size: 18),
                      const SizedBox(width: 6),
                      const Text(
                        'CURRENT PREDICTION',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 11,
                          letterSpacing: 1.6,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Round #${pred.round}',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      AnimatedCount(
                        value: pred.current?.exitAt ?? 1.45,
                        duration: const Duration(milliseconds: 600),
                        formatter: (v) =>
                            '${v.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 56,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -1,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(bottom: 10, left: 4),
                        child: Text(
                          'x',
                          style: TextStyle(
                            color: AppColors.accent,
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Recommended exit • next round in ${pred.secondsLeft}s',
                    style: const TextStyle(color: AppColors.textMuted),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1, end: 0),

            const SizedBox(height: 20),
            const SectionHeader(title: 'Live Stats'),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.4,
              children: <Widget>[
                StatTile(
                  label: 'AI Accuracy',
                  value: Fmt.percent(pred.accuracy),
                  icon: Icons.psychology_rounded,
                  accent: true,
                ),
                StatTile(
                  label: 'Online players',
                  value: Fmt.compact(pred.onlineUsers),
                  icon: Icons.people_alt_rounded,
                ),
                StatTile(
                  label: 'Predictions made',
                  value: Fmt.compact(pred.totalPredictions),
                  icon: Icons.insights_rounded,
                ),
                StatTile(
                  label: 'Wallet',
                  value: Fmt.money(user.profile?.walletBalance ?? 0),
                  icon: Icons.account_balance_wallet_rounded,
                ),
              ],
            ),
            const SizedBox(height: 20),
            PrimaryButton(
              label: 'Open Live Predictor',
              icon: Icons.flight_takeoff_rounded,
              onPressed: () => Navigator.of(context).pushNamed('/predictor'),
            ),
            const SizedBox(height: 10),
            Row(
              children: <Widget>[
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.bar_chart_rounded,
                        color: AppColors.accent),
                    label: const Text('Live Stats'),
                    onPressed: () =>
                        Navigator.of(context).pushNamed('/history'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.account_balance_wallet_outlined,
                        color: AppColors.accent),
                    label: const Text('Wallet'),
                    onPressed: () => Navigator.of(context).pushNamed('/wallet'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
