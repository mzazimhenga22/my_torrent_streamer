// test/my_torrent_streamer_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:my_torrent_streamer/my_torrent_streamer.dart';

void main() {
  group('MyTorrentStreamer Tests', () {
    final streamer = MyTorrentStreamer();

    test('Initialization', () async {
      await streamer.init();
      expect(streamer, isNotNull);
      await streamer.stopStreaming();
    });
  });
}
