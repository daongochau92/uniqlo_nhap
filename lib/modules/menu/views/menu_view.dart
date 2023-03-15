import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:uniqlo_nhap/routes/app_pages.dart';

import '../controllers/menu_controller.dart';

class MenuView extends GetView<MenuController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Uniqlo Menu'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              const SizedBox(
                height: 50,
              ),
              TextButton(
                onPressed: () => Get.toNamed(Routes.HOME),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.blue.withOpacity(0.8),
                ),
                child: const Text(
                  'Arrival',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              TextButton(
                  onPressed: () => Get.toNamed(Routes.LOADING),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.blue.withOpacity(0.8),
                  ),
                  child: const Text(
                    'Loading',
                    style: TextStyle(color: Colors.white),
                  ))
            ],
          ),
        ),
      ),
    );
  }
}
