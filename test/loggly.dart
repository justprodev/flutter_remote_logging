// Created by alex@justprodev.com on 22.07.2024.

import 'dart:io';

import 'package:remote_logging/src/remote/loggly.dart';
import 'package:test/test.dart';
import 'package:fake_http_client/fake_http_client.dart';

class TestHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(_) {
    return FakeHttpClient((request, client) async {
      final seconds = int.parse(request.bodyText);
      await Future.delayed(Duration(seconds: seconds));
      // The default response is an empty 200.
      return FakeHttpResponse();
    });
  }
}

void main() {
  setUp(() {
    // Overrides all HttpClients.
    HttpOverrides.global = TestHttpOverrides();
  });

  test('logglyTasks', () async {
    loggly(Uri.parse('https://test.com'), '1');
    loggly(Uri.parse('https://test.com'), '2');
    loggly(Uri.parse('https://test.com'), '3');
    expect(logglyTasks.length, 3);
    await Future.delayed(const Duration(milliseconds: 1100));
    expect(logglyTasks.length, 2);
    await Future.delayed(const Duration(seconds: 1));
    expect(logglyTasks.length, 1);
    await Future.delayed(const Duration(seconds: 1));
    expect(logglyTasks.length, 0);
  });
}
