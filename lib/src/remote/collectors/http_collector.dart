// Created by alex@justprodev.com on 20.12.2025.

import 'package:http/http.dart';
import 'package:remote_logging/src/model.dart';

/// Base class for HTTP log collectors
abstract class HttpCollector implements LogCollector {
  late final Client client;
  final Uri url;
  final Map<String, String> headers;

  HttpCollector({required this.url, this.headers = const {}, Client? client}) {
    this.client = client ?? Client();
  }
}
