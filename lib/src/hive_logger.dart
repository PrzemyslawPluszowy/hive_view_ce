import 'dart:async';

import 'package:hive_ce_flutter/hive_flutter.dart';

/// A singleton class that monitors changes in Hive boxes and provides a stream of [BoxEvent]s.
class HiveLogger<K, V> {
  bool debug;
  void Function(String message)? logCallback;

  // Private constructor
  HiveLogger._privateConstructor({this.debug = true, this.logCallback});

  // Singleton instance
  static final HiveLogger _instance = HiveLogger._privateConstructor();

  /// Returns the singleton instance of [HiveLogger].
  ///
  /// Optionally, [debug] can be set to enable or disable debug logging,
  /// and [logCallback] can be provided to handle log messages.
  static HiveLogger getInstance(
      {bool debug = true, void Function(String message)? logCallback}) {
    _instance.debug = debug;
    _instance.logCallback = logCallback;
    return _instance;
  }

  /// Starts monitoring the provided [boxes] for changes.
  ///
  /// For each box in [boxes], this method listens for changes and adds
  /// the corresponding [BoxEvent] to the stream. If [debug] is true,
  /// it logs the changes using [logCallback] if provided.
  Future<void> monitorBoxes(Map<String, Box<V>> boxes) async {
    for (var entry in boxes.entries) {
      final boxName = entry.key;
      final box = entry.value;

      box.watch().listen((event) {
        final message =
            'Box $boxName changed: key: ${event.key} : data: ${event.value}';
        // Log the message if debug is enabled
        if (debug) {
          _log(message);
        }
        // call logCallback if available to handle custom logging
        if (logCallback != null) {
          logCallback!(message);
        }
      });
    }
  }

  /// Logs the provided [message] using [logCallback] if available,
  /// otherwise prints to the console.
  void _log(String message) {
    logCallback!(message);
  }
}
