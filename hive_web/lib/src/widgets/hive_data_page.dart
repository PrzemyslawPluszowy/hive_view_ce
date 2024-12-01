import 'package:flutter/material.dart';
import 'package:hive_web/src/models/dynamic_data_model.dart';
import 'package:hive_web/src/services/web_socket_service.dart';
import 'package:hive_web/src/widgets/left_panel.dart';
import 'package:hive_web/src/widgets/right_panel.dart';

class HiveDataPage extends StatefulWidget {
  const HiveDataPage({super.key});

  @override
  State<HiveDataPage> createState() => _HiveDataPageState();
}

class _HiveDataPageState extends State<HiveDataPage> {
  final WebSocketService webSocketService =
      WebSocketService('ws://127.0.0.1:9090');
  String? selectedBox;

  @override
  void initState() {
    super.initState();
    webSocketService.connect();
  }

  @override
  void dispose() {
    webSocketService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<DynamicDataModel?>(
        stream: webSocketService.dataModelStream,
        builder: (context, snapshot) {
          final dataModel = snapshot.data;

          if (dataModel == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return Row(
            children: [
              Expanded(
                flex: 1,
                child: LeftPanel(
                  dataModel: dataModel,
                  selectedBox: selectedBox,
                  onBoxSelected: (boxName) {
                    setState(() {
                      selectedBox = boxName;
                    });
                  },
                ),
              ),
              Expanded(
                flex: 3,
                child: RightPanel(
                  webSocketService: webSocketService,
                  selectedBox: selectedBox,
                  dataModel: dataModel,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
