import 'package:intl/intl.dart';

/// Human-friendly formatting helpers used across screens.
class Fmt {
  Fmt._();

  static final NumberFormat _money =
      NumberFormat.currency(symbol: '\$', decimalDigits: 2);
  static final NumberFormat _compact = NumberFormat.compact();
  static final NumberFormat _multiplier =
      NumberFormat('0.00', 'en_US');

  static String money(double v) => _money.format(v);
  static String compact(num v) => _compact.format(v);
  static String multiplier(double v) => '${_multiplier.format(v)}x';
  static String percent(double v) => '${v.toStringAsFixed(1)}%';

  static String date(DateTime d) =>
      DateFormat('MMM d, yyyy • HH:mm').format(d);

  static String dateOnly(DateTime d) => DateFormat('MMM d, yyyy').format(d);
}
