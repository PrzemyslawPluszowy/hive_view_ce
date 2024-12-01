import 'dart:developer';

import 'package:flutter/services.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_cors_headers/shelf_cors_headers.dart';

/// A class responsible for serving static assets over HTTP.
/// This server is built using the `shelf` library and supports CORS headers.
class WebHttpServer {
  final int _port;
  final String _host;
  final bool _debug = false;

  /// Creates an instance of [WebHttpServer].
  ///
  /// [host]: The hostname or IP address for the server to bind to (default: '127.0.0.1').
  /// [port]: The port number for the server to listen on (default: 9091).
  WebHttpServer({
    String host = '127.0.0.1',
    int port = 9091,
  })  : _port = port,
        _host = host;

  /// Starts the HTTP server to serve static assets.
  ///
  /// Logs the server status to the console and serves files from the specified asset root.
  Future<void> start() async {
    log('HIVE VIEW CE: Starting HTTP Server');

    // Middleware and handler setup
    final handler = const Pipeline()
        .addMiddleware(corsHeaders()) // Enable CORS headers
        .addHandler(_createAssetHandler(
          defaultDocument: 'index.html',
          assetRoot: 'packages/hive_view_ce/assets/web/',
        ));

    // Start the server
    await shelf_io.serve(
      handler,
      _host,
      _port,
    );

    log('HIVE VIEW CE: HTTP Server started on http://$_host:$_port');
  }

  /// Creates a handler to serve static assets from the specified [assetRoot].
  ///
  /// [assetRoot]: The root directory containing the assets to be served.
  /// [defaultDocument]: The default document (e.g., 'index.html') to serve when no specific file is requested.
  Handler _createAssetHandler({
    required String assetRoot,
    String? defaultDocument,
  }) {
    return (Request request) async {
      if (_debug) {
        log('Received request: ${request.method} ${request.url.path}');
      }

      // Determine the requested asset
      final requestedAsset = request.url.pathSegments.isEmpty
          ? defaultDocument
          : request.url.pathSegments.join('/');
      if (requestedAsset == null) {
        return Response.notFound('Resource not found');
      }

      final assetPath = '$assetRoot$requestedAsset';
      if (_debug) {
        log('Looking for asset: $assetPath');
      }

      try {
        // Load the asset as a byte stream
        final byteData = await rootBundle.load(assetPath);
        final Uint8List body = byteData.buffer.asUint8List();

        // Generate appropriate headers for the asset
        final headers = {
          'Content-Type': _getContentType(assetPath),
          'Content-Length': body.length.toString(),
        };
        if (_debug) log('Serving asset: $assetPath with headers: $headers');

        return Response.ok(body, headers: headers);
      } catch (e) {
        // Handle missing or inaccessible asset
        log('Error loading asset $assetPath: $e');
        return Response.notFound('Resource $requestedAsset not found');
      }
    };
  }

  /// Determines the content type based on the file extension of [filePath].
  ///
  /// Returns a MIME type string suitable for HTTP responses.
  static String _getContentType(String filePath) {
    final extension = filePath.split('.').last.toLowerCase();
    switch (extension) {
      case 'html':
        return 'text/html';
      case 'js':
        return 'application/javascript';
      case 'css':
        return 'text/css';
      case 'png':
        return 'image/png';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'svg':
        return 'image/svg+xml';
      default:
        return 'application/octet-stream'; // Default binary stream
    }
  }
}
