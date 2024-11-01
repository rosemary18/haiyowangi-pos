import 'package:intl/intl.dart';

String formatDateFromString(String date, {String format = 'dd/MM/yyyy, kk:mm'}) {
  return DateFormat(format).format(DateTime.parse(date));
}

String formatDateTimeLocale() {
  DateTime now = DateTime.now();
  String formattedDate = now.toIso8601String().replaceFirst('T', ' ').substring(0, 19);
  if (formattedDate.contains(' 24:')) {
    formattedDate = formattedDate.replaceFirst(' 24:', ' 00:');
  }
  return formattedDate;
}

bool isSameOrBeforeIgnoringTime(DateTime date1, DateTime date2) {
  DateTime localDate1 = DateTime(date1.year, date1.month, date1.day);
  DateTime localDate2 = DateTime(date2.year, date2.month, date2.day);
  return localDate1.isAtSameMomentAs(localDate2) || localDate1.isBefore(localDate2);
}

bool isSameOrAfterIgnoringTime(DateTime date1, DateTime date2) {
  DateTime localDate1 = DateTime(date1.year, date1.month, date1.day);
  DateTime localDate2 = DateTime(date2.year, date2.month, date2.day);
  return localDate1.isAtSameMomentAs(localDate2) || localDate1.isAfter(localDate2);
}
