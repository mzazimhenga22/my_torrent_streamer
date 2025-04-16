// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:my_torrent_streamer/my_torrent_streamer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final streamer = MyTorrentStreamer();

  await streamer.init();

  runApp(MyApp(streamer: streamer));
}

class MyApp extends StatelessWidget {
  final MyTorrentStreamer streamer;
  const MyApp({Key? key, required this.streamer}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Torrent Streamer',
      home: TorrentStreamerHome(streamer: streamer),
    );
  }
}

class TorrentStreamerHome extends StatefulWidget {
  final MyTorrentStreamer streamer;
  const TorrentStreamerHome({Key? key, required this.streamer}) : super(key: key);

  @override
  _TorrentStreamerHomeState createState() => _TorrentStreamerHomeState();
}

class _TorrentStreamerHomeState extends State<TorrentStreamerHome> {
  String? streamUrl;
  bool loading = false;
  final magnetController = TextEditingController();

  @override
  void dispose() {
    magnetController.dispose();
    super.dispose();
  }

  Future<void> startStreaming() async {
    setState(() => loading = true);
    try {
      final url = await widget.streamer.startStreaming(magnetController.text.trim());
      setState(() => streamUrl = url);
    } catch (e) {
      setState(() => streamUrl = 'Error: $e');
    } finally {
      setState(() => loading = false);
    }
  }

  Future<void> stopStreaming() async {
    await widget.streamer.stopStreaming();
    setState(() => streamUrl = null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Torrent Streamer')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: magnetController,
              decoration: const InputDecoration(
                labelText: 'Magnet URL',
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: loading ? null : startStreaming,
              child: loading
                  ? const CircularProgressIndicator()
                  : const Text('Start Streaming'),
            ),
            const SizedBox(height: 16),
            if (streamUrl != null) ...[
              const Text('Streaming URL:'),
              SelectableText(streamUrl!),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: stopStreaming,
                child: const Text('Stop Streaming'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
