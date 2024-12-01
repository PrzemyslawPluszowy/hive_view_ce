import 'package:flutter/material.dart';
import 'package:hive_web/src/widgets/hive_data_page.dart';

void main() {
  runApp(const HiveViewerApp());
}

// ------------------------ Main App ------------------------

class HiveViewerApp extends StatelessWidget {
  const HiveViewerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hive Data Viewer',
      home: HiveDataPage(),
    );
  }
}
