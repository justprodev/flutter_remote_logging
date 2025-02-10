// Created by alex@justprodev.com on 22.07.2024.

import 'dart:io';

import 'package:remote_logging/remote_logging.dart';
import 'package:test/test.dart';
import 'package:fake_http_client/fake_http_client.dart';

String? lastBody;
Map<String, List<String>>? lastHeaders;
Uri? lastUri;

const loggers = ['logger1', 'logger2', 'logger3'];
const tags = ['tag1', 'tag2', 'tag3'];

class TestHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(_) {
    return FakeHttpClient((request, client) async {
      lastUri = request.uri;
      lastBody = request.bodyText;
      lastHeaders = {};
      request.headers.forEach((key, value) {
        lastHeaders![key] = value;
      });
      return FakeHttpResponse();
    });
  }
}

void main() {
  setUpAll(() {
    HttpOverrides.global = TestHttpOverrides();
  });

  setUp(() {
    Logger.root.clearListeners();
    lastBody = null;
    lastHeaders = null;
    lastUri = null;
  });

  test('token', () async {
    initLogging('token');
    Logger.root.severe('123');
    await Future.delayed(Duration.zero);
    expect(lastUri, Uri.parse('https://logs-01.loggly.com/inputs/token'));
  });

  test('root severe', () async {
    initLogging('token');
    Logger.root.severe('severe message to root');
    await Future.delayed(Duration.zero);
    expect(lastBody, 'severe message to root');
    expect(lastHeaders?.containsKey('X-LOGGLY-TAG'), true, reason: 'X-LOGGLY-TAG header not found');
    expect(lastHeaders!['X-LOGGLY-TAG']![0], 'SEVERE');
  });

  group('exception', () {
    test('without trace', () async {
      initLogging('token');
      Logger.root.severe('severe message to root', Exception('exception'), StackTrace.current);
      await Future.delayed(Duration.zero);
      expect(lastBody, 'severe message to root\nException: exception');
      expect(lastHeaders?.containsKey('X-LOGGLY-TAG'), true, reason: 'X-LOGGLY-TAG header not found');
      expect(lastHeaders!['X-LOGGLY-TAG']![0], 'SEVERE');
    });

    test('with trace', () async {
      initLogging('token', includeStackTrace: true);
      final currentTrace = StackTrace.current;
      Logger.root.severe('severe message to root', Exception('exception'), currentTrace);
      await Future.delayed(Duration.zero);
      expect(lastBody, 'severe message to root\nException: exception\n$currentTrace');
      expect(lastHeaders!['X-LOGGLY-TAG']![0], 'SEVERE');
    });
  });

  test('tags', () async {
    initLogging('token', tagsProvider: (_) => tags);
    Logger.root.severe('123');
    await Future.delayed(Duration.zero);
    expect(lastHeaders!['X-LOGGLY-TAG']![0], 'SEVERE,${tags.join(',')}');
  });

  test('loggers', () async {
    initLogging('token', verboseLoggers: loggers);

    for(final logger in loggers) {
      Logger(logger).severe('123');
      await Future.delayed(Duration.zero);
      expect(lastHeaders!['X-LOGGLY-TAG']![0], 'SEVERE,$logger');
    }
  });
}
