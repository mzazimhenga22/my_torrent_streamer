# My Torrent Streamer

A Flutter package to connect your Flutter app with [dart_torrent_handler](https://pub.dev/packages/dart_torrent_handler) for streaming torrent content. This package allows you to download torrent files using a magnet URL, serve them over a local HTTP server, and stream selected video files.

## Features

- **Torrent Downloading:** Uses `dart_torrent_handler` to download torrent files from a magnet URL.
- **Local Streaming:** Serves downloaded files via a local HTTP server (using `shelf` and `shelf_static`).
- **Video File Filtering:** Filters torrent files to find common video formats (e.g., MP4, MKV, AVI, MOV).
- **Example App:** Includes a sample Flutter app in the `example/` directory to demonstrate usage.

## Getting Started

### Installation

Add the following dependency to your `pubspec.yaml`:

```yaml
dependencies:
  my_torrent_streamer: ^0.1.0
