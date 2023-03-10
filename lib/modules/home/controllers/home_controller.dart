import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uniqlo_nhap/database/database.dart';
import 'package:uniqlo_nhap/model/save.dart';
import 'package:uniqlo_nhap/model/scan.dart';

class HomeController extends GetxController {
  RxInt total = 0.obs;
  RxInt count = 0.obs;
  RxInt ctn = 0.obs;
  RxInt tctn = 0.obs;
  RxInt fontSize = 95.obs;
  RxString solasort = "".obs;
  RxString oldnew = "".obs;
  RxString no = "".obs;
  TextEditingController scanController = TextEditingController();
  TextEditingController sizeController = TextEditingController();
  MyDatabase m;
  RxList list = [].obs;
  @override
  void onClose() {}

  @override
  Future<void> onReady() async {
    m = MyDatabase.instance;

    Future<List<Scan>> l1 = m.getListScan();
    l1.then((value) => count.value = value.length);

    getList();

    Save s1 = await m.getSave();

    if (s1 == null) {
      Save s = Save(id: 1, fontSize: 95);
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
    Future<int> tt = m.getTotalCTN();
    tt.then((value) => total.value = value);

    m = MyDatabase.instance;
    list.value = await m.getListBoxAllBoxNotScann();
  }

  Future<void> playSoundError() async {
    try {
      AudioPlayer player = AudioPlayer();
      await player.play(AssetSource('audio/beep.mp3'));
    } catch (e) {
      scanController.text = e + "err sound ";
    }
  }

  @override
  void onInit() {
    super.onInit();
  }
}
