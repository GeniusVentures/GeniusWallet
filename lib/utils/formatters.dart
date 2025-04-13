import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class Formatters {
  static final allowDecimals =
      FilteringTextInputFormatter.allow(RegExp(r'^\d+(\.\d*)?'));

  static final allowIntegers =
      FilteringTextInputFormatter.allow(RegExp(r'^\d+'));
}

final DateFormat dateFormatter = DateFormat.yMEd().add_jms();
