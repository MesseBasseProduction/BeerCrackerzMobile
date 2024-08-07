import 'dart:math';

import 'package:intl/intl.dart';

class GlobalUtils {
  static String readableFileSize(
    double number,
    bool base1024,
  ) {
    final base = base1024 ? 1024 : 1000;
    if (number <= 0) return '0 B';
    final units = ['B', 'KB', 'MB', 'GB', 'TB'];
    int digitGroups = (log(number) / log(base)).round();
    return '${NumberFormat("#,##0.#").format(number / pow(base, digitGroups))} ${units[digitGroups]}';
  }
}
