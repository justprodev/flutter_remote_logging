// Created by alex@justprodev.com on 27.05.2022.

import 'package:logging/logging.dart';
import 'package:remote_logging/src/model.dart';

import 'remote/loggly.dart';

///
/// Watch the root [Logger] and then send messages addressed [verboseLoggers] to loggly
/// [verboseLoggers] name of loggers that will be sent to loggly verbosely - i.e. INFO messages, etc
/// [tagsProvider] tags for loggly
/// [printToConsole] print message with [debugPrint]
void initLogging(
  String logglyToken, {
  List<String>? verboseLoggers,
  TagsProvider? tagsProvider,
  bool Function()? printToConsole,
  String Function(String loggerName, String message)? preProcess,
  bool includeStackTrace = false,
}) {
  final logglyUrl = Uri.parse("https://logs-01.loggly.com/inputs/$logglyToken");

  processRecord(LogRecord record) {
    String message = preProcess != null ? preProcess(record.loggerName, record.message) : record.message;

    if (record.error != null) {
      message += '\n${record.error.toString()}';
      if (includeStackTrace && record.stackTrace != null) {
        message += '\n${record.stackTrace}';
      }
    }

    final tags = <String>[record.level.name, if (record.loggerName.isNotEmpty) record.loggerName];

    if (tagsProvider != null) tags.addAll(tagsProvider.call(record));

    // SEVERE messages will be sent to loggly anyway in
    if (record.level == Level.SEVERE || (verboseLoggers?.contains(record.loggerName) == true)) {
      loggly(logglyUrl, message, tags: tags);
    }

    if (printToConsole?.call() == true) {
      // ignore: avoid_print
      print('${record.loggerName} $message ${record.stackTrace ?? ''}');
    }
  }

  // init handlers
  hierarchicalLoggingEnabled = true;
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen(processRecord);
}
