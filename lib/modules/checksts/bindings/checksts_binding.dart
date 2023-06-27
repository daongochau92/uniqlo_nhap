import 'package:get/get.dart';

import '../controllers/checksts_controller.dart';

class CheckstsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CheckstsController>(
      () => CheckstsController(),
    );
  }
}
