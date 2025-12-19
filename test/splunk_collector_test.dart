// Created by alex@justprodev.com on 20.12.2025.

import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'package:remote_logging/remote_logging.dart';
import 'package:test/test.dart';

void main() {
  test('splunk collector', () async {
    Request? request;
    final collector = SplunkCollector(
      'token',
      host: 'test',
      client: MockClient((r) async {
        request = r;
        return Response('', HttpStatus.ok);
      }),
    );
    await collector.collect('Test message', tags: ['tag1', 'tag2']);
    expect(request, isNotNull);
    expect(request!.url, Uri.parse('https://test/services/collector/event'));
    expect(request!.headers, containsPair('Authorization', 'Splunk token'));
    final json = jsonDecode(request!.body);
    expect(json['event'], 'Test message');
    expect(json['fields']['tags'], ['tag1', 'tag2']);
  });
}
