import 'package:logging/logging.dart';

/// Created by alex@justprodev.com on 27.05.2022.

/// Function that provides tags for a log record
typedef TagsProvider = List<String> Function(LogRecord record);

/// Collects logs and sends them to some remote service
abstract class LogCollector {
  Future<void> collect(String message, {List<String>? tags});
}