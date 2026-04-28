import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../core/constants.dart';

/// Smooth animated line chart showing recent multiplier history.
class MultiplierChart extends StatelessWidget {
  const MultiplierChart({super.key, required this.values});

  final List<double> values;

  @override
  Widget build(BuildContext context) {
    final List<FlSpot> spots = <FlSpot>[];
    for (int i = 0; i < values.length; i++) {
      spots.add(FlSpot(i.toDouble(), values[i]));
    }

    final double maxY = values.isEmpty
        ? 5
        : (values.reduce((a, b) => a > b ? a : b) * 1.2).clamp(2.0, 130.0);

    return SizedBox(
      height: 180,
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: maxY,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: maxY / 4,
            getDrawingHorizontalLine: (_) => FlLine(
              color: AppColors.border.withOpacity(.5),
              strokeWidth: 0.6,
              dashArray: const <int>[6, 6],
            ),
          ),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: <LineChartBarData>[
            LineChartBarData(
              spots: spots,
              isCurved: true,
              curveSmoothness: 0.32,
              color: AppColors.accent,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (FlSpot spot, double xPercentage,
                        LineChartBarData bar, int index) =>
                    FlDotCirclePainter(
                  radius: 3,
                  color: AppColors.accent,
                  strokeColor: Colors.white,
                  strokeWidth: 1.2,
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[
                    AppColors.accent.withOpacity(.30),
                    AppColors.accent.withOpacity(.00),
                  ],
                ),
              ),
            ),
          ],
        ),
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOutCubic,
      ),
    );
  }
}
