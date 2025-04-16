// lib/my_torrent_streamer.dart

import 'dart:io';
import 'package:dart_torrent_handler/dart_torrent_handler.dart';
import 'package:path/path.dart' as path;
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_static/shelf_static.dart';

/// A singleton class to handle torrent streaming.
class MyTorrentStreamer {
  static final MyTorrentStreamer _instance = MyTorrentStreamer._internal();

  factory MyTorrentStreamer() => _instance;

  MyTorrentStreamer._internal();

  DartTorrentHandler? _torrentHandler;
  HttpServer? _server;
  Directory? _tempDir;
  String? _baseUrl;

  /// Initializes the torrent handler.
  Future<void> init() async {
    _torrentHandler = DartTorrentHandler();
    await _torrentHandler!.init();
  }

  /// Starts streaming a torrent from a given magnet link.
  /// Optionally, specify a file path.
  Future<String> startStreaming(String magnetUrl, {String? filePath}) async {
    // Stop any previous streaming sessions.
    await stopStreaming();

    // Create a temporary directory to store torrent downloads.
    _tempDir = await Directory.systemTemp.createTemp('torrent_stream');
    String downloadPath = await _torrentHandler!.start(magnetUrl, _tempDir!.path);

    // Start a local server to serve the downloaded files.
    _baseUrl = await _startLocalServer(downloadPath);

    // Retrieve the list of files from the torrent and filter for video formats.
    final files = await _torrentHandler!.getFiles();
    final videoFiles = _getVideoFiles(files);

    String targetFilePath;
    if (filePath != null) {
      if (videoFiles.any((f) => f == filePath)) {
        targetFilePath = filePath;
      } else {
        throw Exception('Specified file not found in torrent');
      }
    } else {
      final chosenFile = _identifyLargestVideoFile(videoFiles);
      if (chosenFile == null) {
        throw Exception('No video file found in torrent');
      }
      targetFilePath = chosenFile;
    }

    return '$_baseUrl/${path.basename(targetFilePath)}';
  }

  /// Returns the streaming URL for a specified file.
  Future<String> getStreamingUrlForFile(String filePath) async {
    if (_server == null || _baseUrl == null) {
      throw Exception('Streaming not started. Call startStreaming first.');
    }
    final files = await _torrentHandler!.getFiles();
    final videoFiles = _getVideoFiles(files);
    if (!videoFiles.any((f) => f == filePath)) {
      throw Exception('File not found in torrent');
    }
    return '$_baseUrl/${path.basename(filePath)}';
  }

  List<String> _getVideoFiles(List<String> files) {
    const videoExtensions = ['.mp4', '.mkv', '.avi', '.mov'];
    return files.where((f) =>
      videoExtensions.any((ext) => f.toLowerCase().endsWith(ext))
    ).toList();
  }

  /// Simplified: returns the first video file found.
  String? _identifyLargestVideoFile(List<String> files) {
    if (files.isEmpty) return null;
    return files.first;
  }

  Future<String> _startLocalServer(String dirPath) async {
    final handler = createStaticHandler(dirPath);
    _server = await shelf_io.serve(handler, 'localhost', 0);
    return 'http://localhost:${_server!.port}';
  }

  /// Stops torrent download and shuts down the local server.
  Future<void> stopStreaming() async {
    if (_torrentHandler != null) {
      await _torrentHandler!.stop();
      _torrentHandler = null;
    }
    if (_server != null) {
      await _server!.close(force: true);
      _server = null;
    }
    _baseUrl = null;
  }

  /// Cleans up temporary files.
  Future<void> clean() async {
    await stopStreaming();
    if (_tempDir != null && await _tempDir!.exists()) {
      await _tempDir!.delete(recursive: true);
      _tempDir = null;
    }
  }
}
