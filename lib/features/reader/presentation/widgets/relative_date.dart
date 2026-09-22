import 'package:easy_localization/easy_localization.dart';

String formatRelativeDate(DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final target = DateTime(date.year, date.month, date.day);
  final dayDiff = today.difference(target).inDays;

  if (dayDiff == 0) return 'time.today'.tr();
  if (dayDiff == 1) return 'time.yesterday'.tr();
  if (dayDiff > 1 && dayDiff < 7) {
    return 'time.days_ago'.tr(args: ['$dayDiff']);
  }
  return DateFormat.yMMMd(Intl.getCurrentLocale()).format(date);
}
