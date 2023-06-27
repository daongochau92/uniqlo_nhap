import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uniqlo_nhap/model/sts.dart';

import '../../../database/database.dart';
import '../../../model/save.dart';

class CheckstsController extends GetxController {
  RxInt total = 0.obs;
  RxInt count = 0.obs;
  RxInt totalStore = 0.obs;
  RxInt countStore = 0.obs;
  RxInt fontSize = 95.obs;
  RxString arrivalDate = "".obs;
  RxString oldnew = "".obs;
  RxString store = "".obs;
  TextEditingController scanController = TextEditingController();
  TextEditingController sizeController = TextEditingController();
  MyDatabase m;
  RxList list = [].obs;
  @override
  void onClose() {}

  @override
  Future<void> onReady() async {
    m = MyDatabase.instance;

    Future<List<Sts>> tt = m.getListStsAll();
    // tt.then((value) => total.value = value.length);
    tt.then((value) {
      total.value = value.length;
      getList();
    });

    Save s1 = await m.getSave(2);

    if (s1 == null) {
      Save s = Save(id: 2, fontSize: 95);
      m.insertSave(s);
      fontSize.value = 95;
    } else {
      fontSize.value = s1.fontSize;
    }
    sizeController.text = fontSize.toString();

    super.onReady();
  }

  void getList() async {
    m = MyDatabase.instance;
    list.value = await m.getListCheckStsNotScann();

    count.value = total.value - list.length;
  }

  @override
  void onInit() {
    super.onInit();
  }

  Future<Sts> getSts(String ref) async {
    m = MyDatabase.instance;
    return await m.getCheckSts(ref);
  }
}
