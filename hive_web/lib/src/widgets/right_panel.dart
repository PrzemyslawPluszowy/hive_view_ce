import 'package:flutter/material.dart';
import 'package:hive_web/src/extension/string_paraser.dart';
import 'package:hive_web/src/models/dynamic_data_model.dart';
import 'package:hive_web/src/services/web_socket_service.dart';
import 'package:hive_web/src/utils/app_styles.dart';

class RightPanel extends StatelessWidget {
  final WebSocketService webSocketService;
  final String? selectedBox;
  final DynamicDataModel dataModel;

  const RightPanel({
    required this.webSocketService,
    required this.selectedBox,
    required this.dataModel,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (selectedBox == null) {
      return const Center(
        child: Text('Choose a box from the left panel'),
      );
    }

    final selectedData = dataModel.data[selectedBox];
    if (selectedData == null || selectedData.isEmpty) {
      return const Center(
        child: Text('No data in selected box'),
      );
    }

    return Column(
      children: [
        Container(
          width: double.infinity,
          color: Colors.blueGrey[800],
          padding: const EdgeInsets.all(8),
          child: Text(
            'Box: $selectedBox',
            style: AppStyles.boxTitleStyle,
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: selectedData.length,
            itemBuilder: (context, index) {
              final sortedEntries = selectedData.entries.toList()
                ..sort((a, b) => a.key.compareTo(b.key));
              final key = sortedEntries[index].key;
              final value = sortedEntries[index].value;

              return ExpansionTile(
                title: Text(
                  'Box key: $key',
                  style: AppStyles.listItemStyle,
                ),
                subtitle: Text('Box value: $value'),
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: value.toString().toRichText(),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        StreamBuilder<String>(
          stream: webSocketService.eventLogStream,
          builder: (context, snapshot) {
            final eventLog = snapshot.data ?? 'No events yet';
            return Container(
              width: double.infinity,
              color: Colors.blueGrey[800],
              padding: const EdgeInsets.all(8),
              child: Text(
                'Last event: $eventLog',
                style: AppStyles.eventLogStyle,
              ),
            );
          },
        ),
      ],
    );
  }
}
