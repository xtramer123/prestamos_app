import 'package:intl/intl.dart';

class AppFormat {
  AppFormat._();

  static final NumberFormat _money = NumberFormat.currency(
    locale: 'en_US',
    symbol: r'$',
    decimalDigits: 2,
  );

  static final NumberFormat _moneyCompact = NumberFormat.compactCurrency(
    locale: 'en_US',
    symbol: r'$',
    decimalDigits: 1,
  );

  static final DateFormat _date = DateFormat('d MMM yyyy', 'es');
  static final DateFormat _dateShort = DateFormat('d MMM', 'es');
  static final DateFormat _month = DateFormat('MMM', 'es');
  static final DateFormat _fullDate = DateFormat("EEEE d 'de' MMMM", 'es');

  static String money(num value) => _money.format(value);

  static String moneyCompact(num value) {
    if (value.abs() < 1000) return _money.format(value);
    return _moneyCompact.format(value);
  }

  static String date(DateTime value) => _date.format(value);

  static String dateShort(DateTime value) => _dateShort.format(value);

  static String month(DateTime value) => _month.format(value);

  static String fullDate(DateTime value) => _fullDate.format(value);

  static String percent(double value) => '${(value * 100).round()}%';

  static String initials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts[1].substring(0, 1))
        .toUpperCase();
  }
}
