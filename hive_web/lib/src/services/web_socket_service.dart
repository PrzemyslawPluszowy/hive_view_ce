import 'dart:async';
import 'dart:convert';

import 'package:hive_web/src/models/dynamic_data_model.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketService {
  final String url;
  late WebSocketChannel channel;

  final StreamController<DynamicDataModel?> _dataModelController =
      StreamController<DynamicDataModel?>.broadcast();
  final StreamController<String> _eventLogController =
      StreamController<String>.broadcast();

  WebSocketService(this.url);

  Stream<DynamicDataModel?> get dataModelStream => _dataModelController.stream;
  Stream<String> get eventLogStream => _eventLogController.stream;

  void connect() {
    channel = WebSocketChannel.connect(Uri.parse(url));

    channel.stream.listen(
      (message) {
        final decodedMessage = jsonDecode(message);
        if (decodedMessage['data'] != null) {
          _dataModelController.add(
            DynamicDataModel.fromJson(decodedMessage['data']),
          );
        }
        if (decodedMessage['lastEvent'] != null) {
          _eventLogController.add(decodedMessage['lastEvent']);
        }
      },
      onError: (error) => _eventLogController.add('Error: $error'),
      onDone: () => _eventLogController.add('WebSocket disconnected.'),
    );
  }

  void dispose() {
    channel.sink.close();
    _dataModelController.close();
    _eventLogController.close();
  }
}
