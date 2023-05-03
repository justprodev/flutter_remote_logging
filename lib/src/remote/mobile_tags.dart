import 'dart:io' show Platform;

/// Created by alex@justprodev.com on 23.05.2023.

final List<String> defaultTags = () {
  final tags = <String>[];

  if (Platform.isAndroid) {
    tags.add('android');
  } else if (Platform.isIOS) {
    tags.add('ios');
  }

  return tags;
}();


