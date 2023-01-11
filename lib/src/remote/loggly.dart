import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart';

/// Created by alex@justprodev.com on 27.05.2022.

final List<String> defaultTags = () {
  final tags = <String>[];

  if (Platform.isAndroid) {
    tags.add('android');
  } else if (Platform.isIOS) {
    tags.add('ios');
  }

  return tags;
}();

Future<void> loggly(Uri url, String message, {List<String>? tags}) async {
  final headers = {"Content-type": "text/plain; charset=utf-8"};

  headers["X-LOGGLY-TAG"] = [...defaultTags, ...(tags ?? [])].join(',');

  try {
    await post(url, body: message, headers: headers);
  } catch (e, trace) {
    if (kDebugMode) debugPrint("Error sending message to loggly $e $trace");
  }
}
