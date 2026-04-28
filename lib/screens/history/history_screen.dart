import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants.dart';
import '../../models/prediction_model.dart';
import '../../providers/user_provider.dart';
import '../../services/firestore_service.dart';
import '../../utils/formatters.dart';
import '../../widgets/glow_card.dart';
import '../../widgets/section_header.dart';

enum _ResultFilter { all, wins, losses }

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  _ResultFilter _filter = _ResultFilter.all;
  DateTime? _searchDate;

  @override
  Widget build(BuildContext context) {
    final String? uid = context.watch<UserProvider>().profile?.uid;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Your History',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                _filterChip('All', _ResultFilter.all),
                const SizedBox(width: 8),
                _filterChip('Wins', _ResultFilter.wins),
                const SizedBox(width: 8),
                _filterChip('Losses', _ResultFilter.losses),
                const Spacer(),
                IconButton(
                  tooltip: 'Search by date',
                  onPressed: _pickDate,
                  icon: const Icon(Icons.calendar_month_rounded,
                      color: AppColors.accent),
                ),
              ],
            ),
            if (_searchDate != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: <Widget>[
                    Text(
                      'Showing ${Fmt.dateOnly(_searchDate!)}',
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () => setState(() => _searchDate = null),
                      child: const Icon(Icons.close_rounded,
                          size: 16, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
            const SectionHeader(title: 'Records'),
            Expanded(
              child: uid == null
                  ? const Center(child: CircularProgressIndicator())
                  : StreamBuilder<List<PredictionModel>>(
                      stream: FirestoreService.instance.userPredictions(uid),
                      builder: (BuildContext context,
                          AsyncSnapshot<List<PredictionModel>> snap) {
                        if (snap.connectionState == ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        final List<PredictionModel> records =
                            (snap.data ?? <PredictionModel>[])
                                .where(_passesFilter)
                                .toList();
                        if (records.isEmpty) {
                          return const _Empty();
                        }
                        return ListView.separated(
                          padding: const EdgeInsets.only(bottom: 24),
                          itemCount: records.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (_, int i) =>
                              _HistoryRow(record: records[i]),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(String label, _ResultFilter v) {
    final bool selected = _filter == v;
    return GestureDetector(
      onTap: () => setState(() => _filter = v),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.accent : AppColors.cardHigh,
          borderRadius: BorderRadius.circular(50),
          border: Border.all(
            color: selected ? AppColors.accent : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : AppColors.textSecondary,
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  bool _passesFilter(PredictionModel r) {
    if (_filter == _ResultFilter.wins && !r.win) return false;
    if (_filter == _ResultFilter.losses && r.win) return false;
    if (_searchDate != null) {
      return r.timestamp.year == _searchDate!.year &&
          r.timestamp.month == _searchDate!.month &&
          r.timestamp.day == _searchDate!.day;
    }
    return true;
  }

  Future<void> _pickDate() async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now,
      initialDate: _searchDate ?? now,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.accent,
              surface: AppColors.card,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _searchDate = picked);
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({required this.record});

  final PredictionModel record;

  @override
  Widget build(BuildContext context) {
    final Color badge = record.win ? AppColors.success : AppColors.danger;
    return GlowCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: <Widget>[
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: badge.withOpacity(.18),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              record.win
                  ? Icons.trending_up_rounded
                  : Icons.trending_down_rounded,
              color: badge,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Round #${record.round}  •  ${Fmt.multiplier(record.exitAt)} target',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${Fmt.date(record.timestamp)}  •  ${record.risk.label} risk',
                  style:
                      const TextStyle(color: AppColors.textMuted, fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: badge.withOpacity(.18),
              borderRadius: BorderRadius.circular(50),
              border: Border.all(color: badge.withOpacity(.5)),
            ),
            child: Text(
              record.win ? 'WIN' : 'LOSS',
              style: TextStyle(
                color: badge,
                fontWeight: FontWeight.w800,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const <Widget>[
            Icon(Icons.history_toggle_off_rounded,
                size: 56, color: AppColors.textMuted),
            SizedBox(height: 12),
            Text('No predictions yet.',
                style: TextStyle(color: AppColors.textSecondary)),
            SizedBox(height: 6),
            Text('Open the live predictor to start logging rounds.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
