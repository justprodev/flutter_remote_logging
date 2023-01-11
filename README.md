# flutter_remote_logging
Send [Logger()](https://pub.dev/packages/logging) messages to loggly.com

```dart

import 'package:remote_logging/remote_logging.dart';

void main() async {
  initLogging(logglyToken, verboseLoggers: ['logger1', 'logger2'], tagsProvider: (record) {
    return [
      'tag1',
      'tag2',
    ];
  });
  
  // https://pub.dev/packages/logging
  Logger('logger1').info('info on logger1');
  Logger('logger2').info('info on logger2');
  Logger.root.severe('error on any logger', Error());
}
```
