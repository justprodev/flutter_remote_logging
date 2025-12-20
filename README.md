# Dart package `remote_logging`

Sending [Logger()](https://pub.dev/packages/logging) messages to various remote logging services,
like [Loggly](https://www.loggly.com/docs/http-endpoint/), [Splunk](https://docs.splunk.com/Documentation/Splunk/latest/Data/UsetheHTTPEventCollector), etc.

```dart
import 'package:remote_logging/remote_logging.dart';

void main() async {
  final logglyCollector = LogglyCollector(logglyToken);
  initRemoteLogging(
    logglyCollector,
    verboseLoggers: ['logger1', 'logger2'],
    tagsProvider: (_) => ['tag1','tag2'],
  );

  // https://pub.dev/packages/logging
  Logger('logger1').info('info on logger1');
  Logger('logger2').info('info on logger2');
  Logger.root.severe('error on any logger', Error());
}
```
