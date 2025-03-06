import 'package:intl/intl.dart';

class DateFormatter {
  static String formatDate(DateTime date) {
    final formatter = DateFormat('dd/MM/yyyy');
    return formatter.format(date);
  }

  static String formatTime(DateTime time) {
    final formatter = DateFormat('HH:mm');
    return formatter.format(time);
  }

  static String formatDateTime(DateTime dateTime) {
    final dateFormatter = DateFormat('dd/MM/yyyy');
    final timeFormatter = DateFormat('HH:mm');
    return '${dateFormatter.format(dateTime)} à ${timeFormatter.format(dateTime)}';
  }
}
