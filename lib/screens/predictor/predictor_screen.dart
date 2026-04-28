import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../core/constants.dart';
import '../../models/prediction_model.dart';
import '../../providers/prediction_provider.dart';
import '../../utils/formatters.dart';
import '../../widgets/glow_card.dart';
import '../../widgets/multiplier_chart.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/section_header.dart';

class PredictorScreen extends StatefulWidget {
  const PredictorScreen({super.key});

  @override
  State<PredictorScreen> createState() => _PredictorScreenState();
}

class _PredictorScreenState extends State<PredictorScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PredictionProvider>().start();
    });
  }

  Color _riskColor(RiskLevel r) {
    switch (r) {
      case RiskLevel.low:
        return AppColors.success;
      case RiskLevel.medium:
        return AppColors.warning;
      case RiskLevel.high:
        return AppColors.danger;
    }
  }

  @override
  Widget build(BuildContext context) {
    final PredictionProvider p = context.watch<PredictionProvider>();
    final result = p.current;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Text(
                  'Live Predictor',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.cardHigh,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Row(
                    children: <Widget>[
                      const Icon(Icons.timer_outlined,
                          color: AppColors.accent, size: 14),
                      const SizedBox(width: 6),
                      Text(
                        '${p.secondsLeft}s',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            GlowCard(
              glow: true,
              gradient: AppColors.surfaceGradient,
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Text(
                        'ROUND #${p.round}',
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 11,
                          letterSpacing: 1.6,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      if (result != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: _riskColor(result.risk).withOpacity(.18),
                            borderRadius: BorderRadius.circular(50),
                            border: Border.all(
                                color:
                                    _riskColor(result.risk).withOpacity(.6)),
                          ),
                          child: Text(
                            '${result.risk.label} risk',
                            style: TextStyle(
                              color: _riskColor(result.risk),
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    result == null
                        ? '—'
                        : Fmt.multiplier(result.exitAt),
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 60,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1.2,
                    ),
                  )
                      .animate(target: 1)
                      .fadeIn(duration: 300.ms)
                      .scale(begin: const Offset(0.96, 0.96)),
                  const Text(
                    'Recommended exit',
                    style: TextStyle(color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 22),
                  Row(
                    children: <Widget>[
                      _MetricChip(
                        icon: Icons.login_rounded,
                        label: 'Entry',
                        value: result == null
                            ? '—'
                            : Fmt.multiplier(result.entryAt),
                      ),
                      const SizedBox(width: 10),
                      _MetricChip(
                        icon: Icons.logout_rounded,
                        label: 'Exit',
                        value: result == null
                            ? '—'
                            : Fmt.multiplier(result.exitAt),
                      ),
                      const SizedBox(width: 10),
                      _MetricChip(
                        icon: Icons.psychology_rounded,
                        label: 'Confidence',
                        value: result == null
                            ? '—'
                            : Fmt.percent(result.confidence),
                        highlight: true,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const SectionHeader(title: 'Live multiplier'),
            GlowCard(
              padding: const EdgeInsets.all(16),
              child: MultiplierChart(values: p.history),
            ),
            const SizedBox(height: 18),
            Row(
              children: <Widget>[
                Expanded(
                  child: _MiniStat(
                    label: 'Players',
                    value:
                        result == null ? '—' : Fmt.compact(result.players),
                    icon: Icons.people_alt_rounded,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MiniStat(
                    label: 'Pool',
                    value: result == null
                        ? '—'
                        : Fmt.money(result.poolAmount),
                    icon: Icons.savings_rounded,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MiniStat(
                    label: 'Last Run',
                    value: result == null
                        ? '—'
                        : Fmt.multiplier(result.actualMultiplier),
                    icon: Icons.show_chart_rounded,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            PrimaryButton(
              label: 'Generate prediction',
              icon: Icons.auto_awesome_rounded,
              onPressed: p.generateOnce,
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({
    required this.icon,
    required this.label,
    required this.value,
    this.highlight = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: highlight
              ? AppColors.accent.withOpacity(.15)
              : AppColors.cardHigh,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: highlight
                ? AppColors.accent.withOpacity(.5)
                : AppColors.border,
          ),
        ),
        child: Column(
          children: <Widget>[
            Icon(icon,
                size: 16,
                color: highlight ? AppColors.accent : AppColors.textSecondary),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 10,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return GlowCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, size: 16, color: AppColors.accent),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            label,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
