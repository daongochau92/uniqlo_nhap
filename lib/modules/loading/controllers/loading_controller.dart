import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uniqlo_nhap/model/loading.dart';

import '../../../database/database.dart';

class LoadingController extends GetxController {
  var count = 0.obs;
  var total = 0.obs;
  TextEditingController scanController = TextEditingController();
  TextEditingController storeController = TextEditingController();
  RxString no = "".obs;
  RxString delivery = "".obs;
  RxList list = [].obs;
  var storeName = "".obs;
  MyDatabase m;
  @override
  void onInit() {
    super.onInit();
  }

  @override
  Future<void> onReady() async {
    super.onReady();
  }

  Future<String> getName(int store) async {
    m = MyDatabase.instance;
    return await m.getStoreName(store);
  }

  Future<Loading> getLoading(int store, String ref) async {
    m = MyDatabase.instance;
    return await m.getLoading(store, ref);
  }

  void getList(int store) async {
    m = MyDatabase.instance;

    int total1 = await m.getTotalLoading(store);
    total.value = total1;

    list.value = await m.getListLoading(store);
    count.value = total1 - list.length;
  }

  @override
  void onClose() {
    super.onClose();
  }
}
