import 'package:http/http.dart';

/// Created by alex@justprodev.com on 27.05.2022.

import 'web_tags.dart' if (dart.library.io) 'mobile_tags.dart';

/// Non-completed tasks
final Set<Future> logglyTasks = {};

Future<void> loggly(Uri url, String message, {List<String>? tags}) async {
  final headers = {"Content-type": "text/plain; charset=utf-8"};

  headers["X-LOGGLY-TAG"] = [...defaultTags, ...(tags ?? [])].join(',');

  final task = post(url, body: message, headers: headers);

  try {
    logglyTasks.add(task);
    await task;
  } catch (e, trace) {
    // ignore: avoid_print
    print("Error sending message to loggly $e $trace");
  } finally {
    logglyTasks.remove(task);
  }
}
