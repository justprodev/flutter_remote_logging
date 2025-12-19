// Created by alex@justprodev.com on 19.12.2025.

// export by platform
export 'impl/empty_tags.dart'
    if (dart.library.io) 'impl/io_tags.dart'
    if (dart.library.html) 'impl/web_tags.dart';
