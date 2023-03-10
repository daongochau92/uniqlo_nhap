import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/scan_controller.dart';

// ignore: must_be_immutable, use_key_in_widget_constructors
class ScanView extends GetView<ScanController> {
  @override
  Widget build(BuildContext context) {
    var data = Get.arguments;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [Text(data.toString())],
        ),
      ),
    );
  }
}
