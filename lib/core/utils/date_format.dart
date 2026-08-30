import 'package:intl/intl.dart';

import '../l10n/app_texts.dart';

/// Datumsformate, die zur Sprache der App passen.
abstract final class MomentoDates {
  static String day(DateTime date, AppTexts t) =>
      DateFormat.yMMMMd(t.localeName).format(date);

  static String shortDay(DateTime date, AppTexts t) =>
      DateFormat.yMMMd(t.localeName).format(date);

  static String time(DateTime date, AppTexts t) =>
      DateFormat.Hm(t.localeName).format(date);

  static String dayAndTime(DateTime date, AppTexts t) =>
      '${day(date, t)}, ${time(date, t)}';

  static String monthYear(DateTime date, AppTexts t) =>
      DateFormat.yMMMM(t.localeName).format(date);

  /// "Heute", "Gestern" oder ein Datum - je nachdem wie lange es her ist.
  static String relativeDay(DateTime date, AppTexts t) {
    final now = DateTime.now();
    final justDate = DateTime(date.year, date.month, date.day);
    final today = DateTime(now.year, now.month, now.day);
    final difference = today.difference(justDate).inDays;
    if (difference == 0) return t.today;
    if (difference == 1) return t.yesterday;
    return day(date, t);
  }

  static String duration(Duration value) {
    final minutes = value.inMinutes;
    final seconds = value.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}
