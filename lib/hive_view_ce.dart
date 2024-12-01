import 'package:hive_ce/hive.dart';
import 'package:hive_view_ce/src/hive_logger.dart';
import 'package:hive_view_ce/src/web_http_server.dart';
import 'package:hive_view_ce/src/web_socket_server.dart';

/// A class that initializes and manages the monitoring of Hive boxes
/// and serves their data over a WebSocket server.
class HiveViewCe {
  final bool debug;
  final void Function(String message)? logCallback;
  late final HiveLogger _interpreter;
  late final WebSocketServer _server;
  late final WebHttpServer _httpServer;

  /// Creates an instance of [HiveViewCe].
  ///
  /// The [debug] parameter enables or disables debug logging.
  /// The [logCallback] is a function that handles log messages to customize logging like Talker, Logger, etc.

  HiveViewCe({this.debug = true, this.logCallback}) {
    _interpreter =
        HiveLogger.getInstance(debug: debug, logCallback: logCallback);
  }

  /// Initializes the monitoring of the provided [boxes] and starts
  /// the WebSocket server to serve their data.
  ///
  /// This method sets up the interpreter to monitor changes in the
  /// specified Hive boxes and starts the WebSocket server to serve
  /// the data to connected clients.
  Future<void> init({required Map<String, Box> boxes}) async {
    if (boxes.isEmpty) {
      throw ArgumentError('At least one box must be provided');
    }
    if (debug) {
      _interpreter.logCallback = logCallback;
      await _interpreter.monitorBoxes(boxes);
    }
    _server = WebSocketServer(boxes: boxes);
    _httpServer = WebHttpServer();
    await _server.start();
    await _httpServer.start();
  }
}
