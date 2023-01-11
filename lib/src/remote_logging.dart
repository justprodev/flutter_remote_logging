import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:remote_logging/src/model.dart';

import 'remote/no_loggly.dart' if (dart.library.io) 'remote/loggly.dart';

/// Created by alex@justprodev.com on 27.05.2022.

///
/// Watch the root [Logger] and then send messages addressed [verboseLoggers] to loggly
void initLogging(String logglyToken, {List<String>? verboseLoggers, TagsProvider? tagsProvider}) {
  final logglyUrl = Uri.parse("https://logs-01.loggly.com/inputs/$logglyToken");

  processRecord(LogRecord record) {
    String message = record.message;
    if(record.error!=null) {
      message += '\n${record.error.toString()}';
    }

    final tags = <String>[record.loggerName, record.level.name];

    if(tagsProvider!=null) tags.addAll(tagsProvider.call(record));

    // SEVERE messages will be sent to loggly anyway in
    if(record.level == Level.SEVERE || (verboseLoggers?.contains(record.loggerName) == true)) {
      loggly(logglyUrl, message, tags: tags);
    }

    if(kDebugMode) debugPrint('${record.loggerName} $message ${record.stackTrace ?? ''}');
  }

  // init handlers
  hierarchicalLoggingEnabled = true;
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen(processRecord);
}


