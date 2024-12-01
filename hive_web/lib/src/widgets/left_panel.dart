import 'package:flutter/material.dart';
import 'package:hive_web/src/models/dynamic_data_model.dart';
import 'package:hive_web/src/utils/app_styles.dart';

class LeftPanel extends StatelessWidget {
  final DynamicDataModel dataModel;
  final String? selectedBox;
  final ValueChanged<String> onBoxSelected;

  const LeftPanel({
    required this.dataModel,
    required this.selectedBox,
    required this.onBoxSelected,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blueGrey[800],
      child: ListView.builder(
        itemCount: dataModel.data.keys.length,
        itemBuilder: (context, index) {
          final boxName = dataModel.data.keys.elementAt(index);
          return ListTile(
            title: Text(
              'Box: $boxName',
              style: AppStyles.boxTitleStyle,
            ),
            selected: selectedBox == boxName,
            onTap: () => onBoxSelected(boxName),
          );
        },
      ),
    );
  }
}
