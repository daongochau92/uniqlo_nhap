import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:uniqlo_nhap/routes/app_pages.dart';

import '../controllers/menu_controller.dart';

// ignore: use_key_in_widget_constructors
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
              SizedBox(
                width: 100,
                child: TextButton(
                  onPressed: () => Get.toNamed(Routes.HOME),
                  style: TextButton.styleFrom(
                    backgroundColor:
                        const Color.fromARGB(255, 238, 57, 57).withOpacity(0.8),
                  ),
                  child: const Text(
                    'Arrival',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              SizedBox(
                width: 100,
                child: TextButton(
                  onPressed: () => Get.toNamed(Routes.LOADING),
                  style: TextButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 243, 222, 33)
                        .withOpacity(0.8),
                  ),
                  child: const Text(
                    'Loading',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              SizedBox(
                width: 100,
                child: TextButton(
                  onPressed: () => Get.toNamed(Routes.CHECKSTS),
                  style: TextButton.styleFrom(
                    backgroundColor:
                        const Color.fromARGB(255, 82, 243, 33).withOpacity(0.8),
                  ),
                  child: const Text(
                    'Check STS',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              SizedBox(
                width: 100,
                child: TextButton(
                  onPressed: () => Get.toNamed(Routes.SCAN),
                  style: TextButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 33, 243, 103)
                        .withOpacity(0.8),
                  ),
                  child: const Text(
                    'TransferWH',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
