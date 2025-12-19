// Created by alex@justprodev.com on 20.12.2025.

import 'dart:io';

import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'package:remote_logging/remote_logging.dart';
import 'package:test/test.dart';

void main() {
  test('loggly collector', () async {
    Request? request;
    final collector = LogglyCollector(
      'token',
      host: 'test',
      client: MockClient((r) async {
        request = r;
        return Response('', HttpStatus.ok);
      }),
    );
    await collector.collect('Test message', tags: ['tag1', 'tag2']);
    expect(request, isNotNull);
    expect(request!.url, Uri.parse('https://test/inputs/token'));
    expect(request!.body, 'Test message');
    expect(request!.headers.containsKey('X-LOGGLY-TAG'), true, reason: 'X-LOGGLY-TAG header not found');
    expect(request!.headers['X-LOGGLY-TAG'], 'tag1,tag2');
  });
}
