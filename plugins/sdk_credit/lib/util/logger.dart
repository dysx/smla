import 'package:logger/logger.dart';

class Log {
  static final Log _singleton = Log._internal();

  factory Log() {
    return _singleton;
  }

  Log._internal();

  final _logger = Logger();

  void LogD(String msg, {String tag = 'Debug'}) {
    _logger.d("$tag || $msg");
  }

  void LogW(String msg, {String tag = 'Warn'}) {
    _logger.w("$tag || $msg");
  }

  void LogE(String msg, {String tag = "Error"}) {
    _logger.e("$tag || $msg");
  }
}
