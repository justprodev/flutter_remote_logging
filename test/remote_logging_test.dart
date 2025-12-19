// Created by alex@justprodev.com on 19.12.2025.

import 'package:remote_logging/remote_logging.dart';
import 'package:remote_logging/src/remote/tags/tags.dart';
import 'package:test/test.dart';

void main() {
  setUp(() {
    Logger.root.clearListeners();
  });

  test('collector verbose', () async {
    final collector = _TestLogCollector();
    initRemoteLogging(collector, verboseLoggers: ['test']);
    Logger('test').info('Test message');
    expect(collector.messages.length, 1);
    expect(collector.messages.first, 'Test message');
  });

  test('collector severe', () async {
    final collector = _TestLogCollector();
    initRemoteLogging(collector);
    Logger('test').severe('Test message');
    expect(collector.messages.length, 1);
    expect(collector.messages.first, 'Test message');
    Logger.root.severe('Test message 2');
    expect(collector.messages.length, 2);
    expect(collector.messages[1], 'Test message 2');
  });

  test('collector severe exception', () async {
    final collector = _TestLogCollector();
    initRemoteLogging(collector);
    final stacktrace = StackTrace.current;
    Logger('test').severe('Test message', Exception('test exception'), stacktrace);
    expect(collector.messages.first.contains('Test message'), isTrue);
    expect(collector.messages.first.contains('test exception'), isTrue);
  });

  test('collector severe stacktrace', () async {
    final collector = _TestLogCollector();
    initRemoteLogging(collector, includeStackTrace: true);
    final stacktrace = StackTrace.current;
    Logger('test').severe('Test message', Exception('test exception'), stacktrace);
    expect(collector.messages.first.contains(stacktrace.toString()), isTrue);
  });

  test('collector tags', () async {
    final collector = _TestLogCollector();
    initRemoteLogging(collector, tagsProvider: (_) => ['tag1', 'tag2']);
    Logger('logger').severe('Test message');
    expect(collector.messages.length, 1);
    expect(collector.messages.first, 'Test message');
    expect(collector.tags.length, 1);
    expect(collector.tags.first.contains('SEVERE'), isTrue);
    expect(collector.tags.first.contains('logger'), isTrue);
    expect(defaultTags.every((tag) => collector.tags.first.contains(tag)), isTrue);
    expect(collector.tags.first.contains('tag1'), isTrue);
    expect(collector.tags.first.contains('tag2'), isTrue);
  });

  test('output', () async {
    final collector = _TestLogCollector();
    final outputs = <String>[];
    final records = <LogRecord>[];
    initRemoteLogging(collector, output: (record, message) {
      outputs.add(message);
      records.add(record);
    });
    Logger('logger').info('Test message');
    expect(collector.messages.length, 0);
    expect(outputs.length, 1);
    expect(outputs.first.contains('logger'), isTrue);
    expect(outputs.first.contains('Test message'), isTrue);
    expect(records.length, 1);
    expect(records.first.loggerName, 'logger');
    expect(records.first.message, 'Test message');
  });

  group('tasks', () {
    test('concurrency', () async {
      initRemoteLogging(_DelayLogCollector(), verboseLoggers: ['test']);
      final logger = Logger('test');

      logger.info('100');
      logger.info('200');
      logger.info('300');

      expect(tasks.length, 3, reason: 'Three tasks should be queued');
      await Future.delayed(const Duration(milliseconds: 100));
      expect(tasks.length, 2, reason: 'One task should be completed after 100ms');
      await Future.delayed(const Duration(milliseconds: 100));
      expect(tasks.length, 1, reason: 'Two tasks should be completed after 200ms');
      await Future.delayed(const Duration(milliseconds: 100));
      expect(tasks.length, 0, reason: 'All tasks should be completed after 300ms');
    });

    test('wait tasks', () async {
      initRemoteLogging(_ErrorLogCollector());
      Logger.root.severe('Test message');
      Logger.root.severe('Test message');
      Logger.root.severe('Test message');
      expect(tasks.length, 3, reason: 'Three tasks should be queued');
      await expectLater(waitForLoggingTasks(), completes, reason: 'Tasks should complete without throwing');
      expect(tasks.length, 0, reason: 'All tasks should be completed');
    });
  });
}

/// A log collector that delays for a number of milliseconds specified in the message
class _DelayLogCollector extends LogCollector {
  @override
  Future<void> collect(String message, {List<String>? tags}) async {
    await Future.delayed(Duration(milliseconds: int.parse(message)));
  }
}

class _ErrorLogCollector extends LogCollector {
  @override
  Future<void> collect(String message, {List<String>? tags}) async {
    await Future.delayed(Duration(milliseconds: 100));
    throw Exception('Test exception');
  }
}

/// A log collector that collects messages and tags for testing
class _TestLogCollector extends LogCollector {
  final tags = <List<String>>[];
  final messages = <String>[];

  @override
  Future<void> collect(String message, {List<String>? tags}) async {
    if (tags != null) this.tags.add(tags);
    messages.add(message);
  }
}
