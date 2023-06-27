import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../database/database.dart';
import '../../../model/save.dart';
import '../../../model/scan.dart';

class ScanController extends GetxController {
  RxInt total = 0.obs;
  RxInt count = 0.obs;
  RxInt ctn = 0.obs;
  RxInt tctn = 0.obs;
  RxInt fontSize = 95.obs;
  RxString solasort = "".obs;
  RxString oldnew = "".obs;
  RxString no = "".obs;
  TextEditingController scanController = TextEditingController();
  TextEditingController palletController = TextEditingController();
  TextEditingController sizeController = TextEditingController();
  MyDatabase m;
  RxList list = [].obs;
  @override
  void onClose() {}

  @override
  Future<void> onReady() async {
    m = MyDatabase.instance;

    Future<List<Scan>> l1 = m.getListScan1();
    l1.then((value) => count.value = value.length);

    getList();

    Save s1 = await m.getSave(3);

    if (s1 == null) {
      Save s = Save(id: 3, fontSize: 95);
      m.insertSave(s);
      fontSize.value = 95;
    } else {
      fontSize.value = s1.fontSize;
    }
    sizeController.text = fontSize.toString();

    super.onReady();
  }

  void getTotal() {}

  void getList() async {
    Future<int> tt = m.getTotalCTN1();
    tt.then((value) => total.value = value);

    m = MyDatabase.instance;
    list.value = await m.getListBoxAllBoxNotScann1();
  }

  @override
  void onInit() {
    super.onInit();
  }
}
