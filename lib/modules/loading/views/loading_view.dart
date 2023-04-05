import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:uniqlo_nhap/database/database.dart';

import '../../../model/loading.dart';
import '../../../util/util.dart';
import '../controllers/loading_controller.dart';

// ignore: use_key_in_widget_constructors, must_be_immutable
class LoadingView extends GetView<LoadingController> {
  FocusNode focusScan;
  FocusNode focusStore;
  @override
  Widget build(BuildContext context) {
    focusScan = FocusNode();
    focusStore = FocusNode();
    return Scaffold(
      appBar: AppBar(
        title: Obx(
          (() => Center(
                child: Text(
                  "${controller.count.value}/${controller.total.value}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 60,
                  ),
                  maxLines: 1,
                ),
              )),
        ),
        centerTitle: true,
        // leadingWidth: 1000,
        actions: [
          PopupMenuButton(
            // add icon, by default "3 dot" icon
            // icon: Icon(Icons.book)
            itemBuilder: (context) {
              return [
                const PopupMenuItem<int>(
                  value: 0,
                  child: Text("Upload file"),
                ),
                const PopupMenuItem<int>(
                  value: 1,
                  child: Text("Clear Data"),
                ),
              ];
            },
            onSelected: (value) async {
              if (value == 0) {
                // ignore: avoid_print
                await readCsv();
              } else if (value == 1) {
                MyDatabase.instance.deleteAllLoading();
                controller.total.value = 0;
                controller.count.value = 0;
                controller.scanController.text = "";
                controller.storeController.text = "";
                controller.delivery.value = "";
                controller.no.value = "";
                controller.getList(9999);
              }
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: SizedBox(
              height: 100,
              child: Column(
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: 100,
                        child: TextField(
                          controller: controller.storeController,
                          focusNode: focusStore,
                          decoration: const InputDecoration(
                            hintText: 'Store',
                          ),
                          onSubmitted: (value) {
                            scanStore(value);
                          },
                        ),
                      ),
                      Expanded(
                          child: Obx(() => Text('${controller.storeName}'))),
                    ],
                  ),
                  TextField(
                    controller: controller.scanController,
                    focusNode: focusScan,
                    decoration: const InputDecoration(
                      hintText: 'Scan',
                    ),
                    onSubmitted: (value) {
                      scanRefNo(value);
                    },
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 100),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  // ignore: prefer_const_literals_to_create_immutables
                  children: [
                    const SizedBox(
                      height: 5,
                    ),
                    Obx(
                      () => Row(
                        children: [
                          const Text('Delivery Date:'),
                          Text('     ${controller.delivery}'),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Obx(
                      () => (Text(
                        controller.no.value.toString(),
                        style: const TextStyle(fontSize: 95),
                      )),
                    ),
                    Container(
                      color: Colors.blue.withOpacity(0.3),
                      child: Row(
                        children: const [
                          Expanded(
                            child: Text(
                              'Store Code',
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              'Ref No',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 300,
                      child: Obx(
                        () => ListView.builder(
                          itemCount: controller.list.length,
                          itemBuilder: (context, index) {
                            return Row(
                              children: [
                                Expanded(
                                    child: Text(controller.list[index].storeCode
                                        .toString())),
                                Expanded(
                                    child: Text(controller.list[index].refNo)),
                              ],
                            );
                          },
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> readCsv() async {
    var dir = await getDirCSV();
    if (dir == null) {
      // ignore: avoid_print
      print('ko get duoc file');
      showdialog(title: 'Error', content: 'Please choose the file');
      return;
    }
    int size = await readFileCSVLoading(dir);
    if (size == 0) {
      showdialog(title: 'Error', content: 'ALready upload 0 row');
      // controller.count.value = 0;
      // controller.total.value = size;
      controller.getList(9999);
      controller.no.value = "N/G";
      controller.delivery.value = "";
      controller.storeName.value = "";
      controller.scanController.text = "";
      controller.storeController.text = '';
      focusStore.requestFocus();
      controller.storeController.selection = TextSelection(
        baseOffset: 0,
        extentOffset: controller.storeController.text.length,
      );
    } else {
      showdialog(
          title: 'Success', content: 'ALready upload ${size.toString()} row');
      // controller.count.value = 0;
      // controller.total.value = size;
      controller.getList(9999);
      controller.no.value = "N/G";
      controller.delivery.value = "";
      controller.storeName.value = "";
      controller.scanController.text = "";
      controller.storeController.text = '';
      focusStore.requestFocus();
      controller.storeController.selection = TextSelection(
        baseOffset: 0,
        extentOffset: controller.storeController.text.length,
      );
    }
  }

  scanStore(String value) async {
    controller.delivery.value = "";
    controller.no.value = "";
    int store = 0;
    try {
      store = parseStringToInt(value.substring(1, 5));
    } catch (e) {
      // ignore: avoid_print
      print(e);
    }
    String name = await controller.getName(store);
    if (name == '') {
      focusStore.requestFocus();
      controller.storeController.selection = TextSelection(
        baseOffset: 0,
        extentOffset: controller.storeController.text.length,
      );
      playSoundError();
    } else {
      controller.getList(store);
      controller.scanController.text = '';
      focusScan.requestFocus();
      controller.scanController.selection = TextSelection(
        baseOffset: 0,
        extentOffset: controller.scanController.text.length,
      );
    }
    controller.storeName.value = name;
  }

  scanRefNo(String value) async {
    controller.no.value = "N/G";
    controller.delivery.value = "";
    if (value.length < 14) {
      playSoundError();
      focusScan.requestFocus();
      controller.scanController.selection = TextSelection(
        baseOffset: 0,
        extentOffset: controller.scanController.text.length,
      );
      return;
    }
    String ref = value.substring(1, 13);

    int store = 0;
    try {
      store = parseStringToInt(controller.storeController.text.substring(1, 5));
    } catch (e) {
      // ignore: avoid_print
      print(e);
    }
    Loading load = await controller.getLoading(store, ref);

    if (load == null) {
      playSoundError();
    } else {
      if (load.scanned == "Y") {
        playSoundError();
        showDialog(
          context: Get.context,
          builder: (context) => AlertDialog(
            title: const Text("Error"),
            content: const Text("Already scan"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("Ok"),
              ),
            ],
          ),
        );
      } else {
        controller.no.value = "OK";
        load.scanned = "Y";
        MyDatabase m = MyDatabase.instance;
        m.updateLoading(load);
        controller.getList(store);
      }
      controller.delivery.value = load.deliveryDate;
    }

    focusScan.requestFocus();
    controller.scanController.selection = TextSelection(
      baseOffset: 0,
      extentOffset: controller.scanController.text.length,
    );
  }
}
