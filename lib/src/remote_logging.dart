// Created by alex@justprodev.com on 27.05.2022.

import 'dart:async';

import 'package:logging/logging.dart';
import 'package:remote_logging/src/model.dart';
import 'package:remote_logging/src/remote/tags/tags.dart';

import 'remote/collectors/loggly_collector.dart' show LogglyCollector;

/// Non-completed tasks
final Set<Future> tasks = {};

///
/// Watch the root [Logger] and then send messages addressed [verboseLoggers] to [collectors]
/// [verboseLoggers] name of loggers that will be sent to [collectors] verbosely - i.e. INFO messages, etc
/// [tagsProvider] tags for loggly
/// [output] passes all messages to this function (e.g., for printing to console in custom way)
/// [preProcess] pre-process message before sending to collectors (e.g., hide sensitive info)
/// [includeStackTrace] include stack trace in the message sent to collectors
void initRemoteLogging(
  List<LogCollector> collectors, {
  List<String>? verboseLoggers,
  TagsProvider? tagsProvider,
  Function(LogRecord, String)? output,
  String Function(String loggerName, String message)? preProcess,
  bool includeStackTrace = false,
}) {
  processRecord(LogRecord record) {
    String message = preProcess != null ? preProcess(record.loggerName, record.message) : record.message;

    if (record.error != null) {
      message += '\n${record.error.toString()}';
      if (includeStackTrace && record.stackTrace != null) {
        message += '\n${record.stackTrace}';
      }
    }

    final tags = <String>[
      record.level.name,
      ...defaultTags,
      if (record.loggerName.isNotEmpty) record.loggerName,
      if (tagsProvider != null) ...tagsProvider.call(record),
    ];

    // SEVERE messages will be sent to loggly anyway in
    if (record.level == Level.SEVERE || (verboseLoggers?.contains(record.loggerName) == true)) {
      for (final collector in collectors) {
        final completer = Completer.sync();
        tasks.add(completer.future);
        collector.collect(message, tags: tags).catchError((e, trace) {
          // ignore: avoid_print
          print("Error sending message to collector $e $trace");
        }).whenComplete(() {
          completer.complete();
          tasks.remove(completer.future);
        });
      }
    }

    if (output != null) {
      output(record, '${record.loggerName} $message ${record.stackTrace ?? ''}');
    }
  }

  // init handlers
  hierarchicalLoggingEnabled = true;
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen(processRecord);
}

///
/// Watch the root [Logger] and then send messages addressed [verboseLoggers] to loggly
/// [verboseLoggers] name of loggers that will be sent to loggly verbosely - i.e. INFO messages, etc
/// [tagsProvider] tags for loggly
/// [printToConsole] print message with [debugPrint]
@Deprecated('Use initRemoteLogging instead')
void initLogging(
  String logglyToken, {
  List<String>? verboseLoggers,
  TagsProvider? tagsProvider,
  bool Function()? printToConsole,
  String Function(String loggerName, String message)? preProcess,
  bool includeStackTrace = false,
}) {
  initRemoteLogging(
    [LogglyCollector(logglyToken)],
    verboseLoggers: verboseLoggers,
    tagsProvider: tagsProvider,
    output: printToConsole != null ? (_, message) => print(message) : null,
    preProcess: preProcess,
    includeStackTrace: includeStackTrace,
  );
}
