import 'package:flutter/foundation.dart';

bool isTest = kDebugMode;

void cOut(dynamic message, [String tag = 'xq_i18n', StackTrace? current]) {
  if (isTest) {
    if (current != null) {
      final CCustomTrace programInfo = CCustomTrace(current);
      _printLog((tag == null || tag.isEmpty) ? 'cOut' : tag, '  v  :',
          'fileName: ${programInfo.fileName}, lineNumber: ${programInfo.lineNumber}, message: $message');
      return;
    }
    _printLog(
        (tag == null || tag.isEmpty) ? 'cOut' : tag, '  v  :', '$message');
  } else {
    // print('xq_test_print_out    $message');
  }
}

void _printLog(String tag, String stag, Object object) {
  StringBuffer sb = StringBuffer();
  sb.write('### $tag ###');
  sb.write(stag);
  sb.write(object);
  if (kDebugMode) {
    print(sb.toString());
  }
}

/*
* 获取打印 Log 文件位置信息
* */
class CCustomTrace {
  final StackTrace _trace;

  late String fileName;
  late int lineNumber;
  late int columnNumber;

  CCustomTrace(this._trace) {
    _parseTrace();
  }

  void _parseTrace() {
    final traceString = _trace.toString().split('\n')[0];
    final indexOfFileName = traceString.indexOf(RegExp(r'[A-Za-z_]+.dart'));
    final fileInfo = traceString.substring(indexOfFileName);
    final listOfInfo = fileInfo.split(':');
    fileName = listOfInfo[0];
    lineNumber = int.parse(listOfInfo[1]);
    var columnStr = listOfInfo[2];
    columnStr = columnStr.replaceFirst(')', '');
    columnNumber = int.parse(columnStr);
  }
}
