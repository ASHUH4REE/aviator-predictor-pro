import 'package:flutter/material.dart';

/// Tween-counts a number from previous → current. Used for live stats.
class AnimatedCount extends StatelessWidget {
  const AnimatedCount({
    super.key,
    required this.value,
    this.duration = const Duration(milliseconds: 700),
    this.formatter,
    this.style,
  });

  final num value;
  final Duration duration;
  final String Function(num v)? formatter;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: value.toDouble()),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (_, double v, __) {
        return Text(
          formatter == null ? v.toStringAsFixed(0) : formatter!(v),
          style: style,
        );
      },
    );
  }
}
