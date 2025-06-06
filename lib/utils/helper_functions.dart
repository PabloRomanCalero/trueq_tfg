import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HelperFunctions{
  static bool isDarkMode(BuildContext context){
    return Theme.of(context).brightness == Brightness.dark;
  }

  static String formatDatetime(dynamic date, [DateTimeFormat format = DateTimeFormat.dateTime]) {
    if (date is! DateTime && date is! String) return "UNKNOWN DATA";
    if (date is String) date = DateTime.parse(date);
    final localDate = date.toLocal();

    final stringFormat = format == DateTimeFormat.dateTime
      ? 'dd/MM/yyyy HH:mm' : (format == DateTimeFormat.date ? 'dd/MM/yyyy' : 'HH:mm');

    final DateFormat formatter = DateFormat(stringFormat);
    return formatter.format(localDate);
  }
}

enum DateTimeFormat {
  dateTime,
  date,
  time
}