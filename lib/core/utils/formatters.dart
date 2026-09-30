import 'package:intl/intl.dart';

/// Utilitaires de formatage de dates, nombres et devises.
class Formatters {
  Formatters._();

  static String formatDate(DateTime? date) {
    if (date == null) return '';
    return DateFormat('dd/MM/yyyy').format(date);
  }

  static String formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return '';
    return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
  }

  static String formatNumber(num? value) {
    if (value == null) return '0';
    return NumberFormat('#,###', 'fr_FR').format(value);
  }
}
