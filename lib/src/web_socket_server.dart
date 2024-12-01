import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:hive_ce/hive.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_web_socket/shelf_web_socket.dart';

/// A server that listens to changes in Hive boxes and communicates them to clients via WebSocket.
class WebSocketServer {
  /// A map of Hive boxes to monitor.
  final Map<String, Box> boxes;

  /// Stream controller for broadcasting box events.
  final StreamController<BoxEvent> _streamController =
      StreamController<BoxEvent>.broadcast();

  /// Creates an instance of [WebSocketServer] with the provided [boxes].
  WebSocketServer({required this.boxes});

  /// Starts listening to events from all Hive boxes.
  void _listenToBoxEvents() {
    for (var box in boxes.values) {
      box.watch().listen((event) {
        _streamController.add(event);
      });
    }
  }

  /// Starts the WebSocket server and listens for changes in the Hive boxes.
  Future<void> start() async {
    log('HIVE VIEW CE: Starting WebSocket - Listening Hive Boxes');
    _listenToBoxEvents();

    // WebSocket handler
    final handler = webSocketHandler(_handleWebSocketConnection);

    // Start the server on localhost at port 9090
    final server = await shelf_io.serve(handler, '127.0.0.1', 9090);
    log('HIVE VIEW CE: Serving at ws://${server.address.host}:${server.port}');
  }

  /// Handles a new WebSocket connection.
  /// Sends initial data to the client and sets up a listener for box events.
  void _handleWebSocketConnection(dynamic webSocket) {
    log('HIVE VIEW CE: WebSocket connected');

    // Send initial data to the client
    webSocket.sink.add(_encodeInitialData());

    // Subscribe to box events and send updates to the client
    final subscription = _subscribeToBoxEvents(webSocket);

    // Listen for the WebSocket closing
    webSocket.stream.listen(
      null,
      onDone: () {
        log('HIVE VIEW CE: WebSocket disconnected');
        subscription.cancel();
      },
      onError: (error) {
        log('HIVE VIEW CE: WebSocket error: $error');
        subscription.cancel();
      },
    );
  }

  /// Encodes the initial data from all boxes into a JSON string.
  /// Returns a JSON-encoded string containing the initial data.
  String _encodeInitialData() {
    final data = {
      'lastEvent': 'Initial data',
      'data': boxes.map((key, box) => MapEntry(key, box.toMap().toString())),
    };
    return jsonEncode(data);
  }

  /// Subscribes to events from all Hive boxes and sends updates to the [webSocket].
  /// Returns a [StreamSubscription] that can be canceled to stop listening to events.
  StreamSubscription<BoxEvent> _subscribeToBoxEvents(dynamic webSocket) {
    return _streamController.stream.listen(
      (event) {
        final data = _encodeBoxEvent(event);
        webSocket.sink.add(data);
      },
      onError: (error) {
        log('HIVE VIEW CE: Error in Hive stream: $error');
      },
    );
  }

  /// Encodes a [BoxEvent] into a JSON string.
  /// Returns a JSON-encoded string representing the event.
  String _encodeBoxEvent(BoxEvent event) {
    final data = {
      'lastEvent': '${event.key}, ${event.value}',
      'data': boxes.map((key, box) => MapEntry(key, box.toMap().toString())),
    };
    return jsonEncode(data);
  }
}
