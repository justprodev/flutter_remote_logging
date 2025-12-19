// Created by alex@justprodev.com on 20.12.2025.

import 'dart:convert';
import 'http_collector.dart';

/// Splunk log collector
///
/// See: https://docs.splunk.com/Documentation/Splunk/latest/Data/UsetheHTTPEventCollector
class SplunkCollector extends HttpCollector {
  SplunkCollector(String token, {required String host, super.client})
      : super(
          url: Uri.parse('https://$host/services/collector/event'),
          headers: {
            'Authorization': 'Splunk $token',
            'Content-Type': 'application/json',
          },
        );

  @override
  Future<void> collect(String message, {List<String>? tags}) {
    final data = {
      'event': message,
      if (tags != null && tags.isNotEmpty) 'fields': {'tags': tags},
    };

    return client.post(url, body: jsonEncode(data), headers: headers);
  }
}
