import 'package:intl/intl.dart';

class DateTimeUtil {
  DateTimeUtil._();

  static const String _locale = 'id_ID';

  static final DateFormat _date = DateFormat('dd MMMM yyyy', _locale);

  static final DateFormat _dateSlash = DateFormat('dd/MM/yyyy', _locale);

  static final DateFormat _time = DateFormat('HH:mm', _locale);

  static final DateFormat _dateTime = DateFormat('dd MMMM yyyy HH:mm', _locale);

  static final DateFormat _dateTimeSlash = DateFormat(
    'dd/MM/yyyy  HH:mm',
    _locale,
  );

  static final DateFormat _dateTimeSlashDot = DateFormat(
    'dd/MM/yyyy • HH:mm',
    _locale,
  );

  static final DateFormat _database = DateFormat(
    'yyyy-MM-dd HH:mm:ss',
    _locale,
  );

  static final DateFormat _timestamp = DateFormat('yyyyMMddHHmmss');

  static String date(DateTime dateTime) {
    return _date.format(dateTime);
  }

  static String dateSlash(DateTime dateTime) {
    return _dateSlash.format(dateTime);
  }

  static String time(DateTime dateTime) {
    return _time.format(dateTime);
  }

  static String dateTime(DateTime dateTime) {
    return _dateTime.format(dateTime);
  }

  static String dateTimeSlash(DateTime dateTime) {
    return _dateTimeSlash.format(dateTime);
  }

  static String dateTimeSlashDot(DateTime dateTime) {
    return _dateTimeSlashDot.format(dateTime);
  }

  static String database(DateTime dateTime) {
    return _database.format(dateTime);
  }

  static String timestamp(DateTime dateTime) {
    return _timestamp.format(dateTime);
  }

  static String dynamicDayDate(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final current = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (current == today) {
      return "Hari Ini, ${_date.format(dateTime)}";
    }
    if (current == yesterday) {
      return "Kemarin, ${_date.format(dateTime)}";
    }
    return _date.format(dateTime);
  }
}
