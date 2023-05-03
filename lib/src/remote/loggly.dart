
import 'package:flutter/foundation.dart';
import 'package:http/http.dart';

/// Created by alex@justprodev.com on 27.05.2022.

import 'web_tags.dart'
  if (dart.library.io) 'mobile_tags.dart';

Future<void> loggly(Uri url, String message, {List<String>? tags}) async {
  final headers = {"Content-type": "text/plain; charset=utf-8"};

  headers["X-LOGGLY-TAG"] = [...defaultTags, ...(tags ?? [])].join(',');

  try {
    await post(url, body: message, headers: headers);
  } catch (e, trace) {
    if (kDebugMode) debugPrint("Error sending message to loggly $e $trace");
  }
}