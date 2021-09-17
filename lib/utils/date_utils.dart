import 'package:intl/intl.dart';

class DateTimeUtils {
  static String getDateTime(int timestamp) {
    var dt = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateFormat('dd/MM/yyyy, hh:mm a').format(dt);
  }
}
