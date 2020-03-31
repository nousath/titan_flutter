

import 'package:intl/intl.dart';

class FormatUtil{

  static String formatNum(int numValue) {
    return NumberFormat("#,###,###,###").format(numValue);
  }

  static String formatNumDecimal(double numValue) {
    return NumberFormat("#,###,###,###.####").format(numValue);
  }

  static String formatPercent(double doubleValue) {
    doubleValue = doubleValue * 100;
    return NumberFormat("#,###.##").format(doubleValue) + "%";
  }

  static String formatDate(int timestamp, {bool isSecond = true}) {
    var multiple = isSecond ? 1000:1;
    timestamp = timestamp * multiple;
    return DateFormat("yyyy-MM-dd").format(DateTime.fromMillisecondsSinceEpoch(timestamp))??"";
  }

}