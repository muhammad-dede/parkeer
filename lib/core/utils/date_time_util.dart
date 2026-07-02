import 'package:intl/intl.dart';

class DateTimeUtil {
  DateTimeUtil._();

  static const String _locale = 'id_ID';

  static final DateFormat _date = DateFormat('dd MMM yyyy', _locale);

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
}
