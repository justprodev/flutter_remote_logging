// Created by alex@justprodev.com on 27.05.2022.

import 'http_collector.dart';

/// Loggly log collector
/// See: https://www.loggly.com/docs/http-endpoint/
class LogglyCollector extends HttpCollector {
  LogglyCollector(
    String token, {
    host = defaultHost,
    super.client,
  }) : super(
          url: Uri.parse('https://$host/inputs/$token'),
          headers: {'Content-type': 'text/plain; charset=utf-8'},
        );

  @override
  Future<void> collect(String message, {List<String>? tags}) {
    return client.post(
      url,
      body: message,
      headers: {
        ...headers,
        'X-LOGGLY-TAG': tags?.join(',') ?? '',
      },
    );
  }

  static const defaultHost = 'logs-01.loggly.com';
}
