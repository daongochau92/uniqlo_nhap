import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../../database/database.dart';
import '../../../model/save.dart';
import '../../../model/sts.dart';
import '../../../util/util.dart';
import '../controllers/checksts_controller.dart';

// ignore: use_key_in_widget_constructors, must_be_immutable
class CheckstsView extends GetView<CheckstsController> {
  FocusNode focusScan;
  @override
  Widget build(BuildContext context) {
    focusScan = FocusNode();
    return Scaffold(
      appBar: AppBar(
        title: Obx(
          (() => Center(
                child: Text(
                  "${controller.count.value} / ${controller.total.value}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 35,
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
                  child: Text("Set size"),
                ),
              ];
            },
            onSelected: (value) async {
              if (value == 0) {
                // ignore: avoid_print
                Uint8List uint8list = await getDir();
                if (uint8list != null) {
                  // ignore: avoid_print
                  print('ko get duoc file');
                }
                int size = await readFileExcelCheckSTS(uint8list);
                if (size == 0) {
                } else {
                  controller.count.value = 0;
                  controller.total.value = size;
                  controller.getList();
                  clearfield();
                  controller.scanController.text = '';
                  focusScan.requestFocus();
                  controller.scanController.selection = TextSelection(
                    baseOffset: 0,
                    extentOffset: controller.scanController.text.length,
                  );
                }
              } else if (value == 1) {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text("Set Size"),
                    content: TextField(
                      controller: controller.sizeController,
                    ),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                        },
                        child: const Text("Cancel"),
                      ),
                      TextButton(
                        onPressed: () {
                          MyDatabase m = MyDatabase.instance;
                          Save s = Save(
                              id: 2,
                              fontSize: parseStringToInt(
                                  controller.sizeController.text));
                          m.updateSave(s);
                          controller.fontSize.value =
                              parseStringToInt(controller.sizeController.text);
                          Navigator.of(ctx).pop();
                        },
                        child: const Text("Ok"),
                      ),
                    ],
                  ),
                );
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
              height: 50,
              child: TextField(
                controller: controller.scanController,
                focusNode: focusScan,
                decoration: const InputDecoration(
                  hintText: 'Scan',
                ),
                onSubmitted: (value) {
                  scan(value);
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 50),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  // ignore: prefer_const_literals_to_create_immutables
                  children: [
                    const SizedBox(
                      height: 5,
                    ),
                    // Obx(
                    //   () => Row(
                    //     children: [
                    //       (Text(
                    //         "CTN: ${controller.ctn.value.toString()} / ${controller.tctn.value.toString()}",
                    //         style: const TextStyle(
                    //           backgroundColor: Colors.yellow,
                    //           fontSize: 30,
                    //         ),
                    //         textAlign: TextAlign.left,
                    //       )),
                    //     ],
                    //   ),
                    // ),
                    // const SizedBox(
                    //   height: 5,
                    // ),
                    Obx(
                      () => (Row(
                        children: [
                          Expanded(
                              flex: 10,
                              child: Text(
                                "${controller.arrivalDate}",
                                style: const TextStyle(fontSize: 30),
                              )),
                          Expanded(
                              flex: 8,
                              child: Text(
                                "${controller.countStore}/${controller.totalStore}",
                                style: const TextStyle(
                                    color: Colors.blueAccent, fontSize: 35),
                                textAlign: TextAlign.right,
                              )),
                        ],
                      )),
                    ),
                    Obx(
                      () => (Text(
                        controller.store.value.toString(),
                        style: TextStyle(
                            fontSize: controller.fontSize.value.toDouble()),
                      )),
                    ),
                    Container(
                      color: Colors.blue.withOpacity(0.3),
                      child: Row(
                        children: const [
                          Expanded(
                            flex: 1,
                            child: Text(
                              'From Store',
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              'To Store',
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Expanded(
                            flex: 2,
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
                                    child:
                                        Text(controller.list[index].shipfrom)),
                                Expanded(
                                    child:
                                        Text(controller.list[index].shiptocd)),
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

  Future<void> scan(String value) async {
    clearfield();
    if (value.length < 3) {
      focusScan.requestFocus();
      controller.scanController.selection = TextSelection(
        baseOffset: 0,
        extentOffset: controller.scanController.text.length,
      );
      return;
    }
    String ref = value.substring(1, value.length - 1);
    Sts sts = await controller.getSts(ref);
    if (sts == null) {
      playSoundError();
    } else {
      if (sts.flagNew == "Y") {
        controller.store.value = sts.shiptocd;
        sts.flagNew = "Y";
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
        controller.store.value = sts.shiptocd;
        sts.flagNew = "Y";
        MyDatabase m = MyDatabase.instance;
        m.updateSts(sts);
        controller.getList();
      }
      MyDatabase m = MyDatabase.instance;
      controller.totalStore.value = await m.getTotalbySTS(sts.shiptocd);
      controller.countStore.value = await m.getTotalbyStsScanned(sts.shiptocd);
      controller.arrivalDate.value = sts.arrivalDate;
    }

    focusScan.requestFocus();
    controller.scanController.selection = TextSelection(
      baseOffset: 0,
      extentOffset: controller.scanController.text.length,
    );
  }

  String padLeftZeros(String s, int length) {
    if (s.length >= length) {
      return s;
    }
    String sb = '';
    while (sb.length < length - s.length) {
      // ignore: prefer_interpolation_to_compose_strings
      sb = sb + '0';
    }
    sb = sb + s;
    return sb;
  }

  void clearfield() {
    controller.totalStore.value = 0;
    controller.countStore.value = 0;
    controller.store.value = 'N/A';
    controller.arrivalDate.value = '';
    controller.oldnew.value = '';
  }

  int parseStringToInt(String s) {
    if (s.trim() == "") {
      return 0;
    }
    try {
      return int.parse(s);
    } catch (e) {
      return 0;
    }
  }
}
