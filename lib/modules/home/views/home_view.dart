import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:uniqlo_nhap/database/database.dart';
import 'package:uniqlo_nhap/model/box.dart';
import 'package:uniqlo_nhap/model/ctn.dart';
import 'package:uniqlo_nhap/model/save.dart';
import 'package:uniqlo_nhap/model/scan.dart';

import '../../../util/util.dart';
import '../controllers/home_controller.dart';

// ignore: use_key_in_widget_constructors, must_be_immutable
class HomeView extends GetView<HomeController> {
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
                    fontSize: 55,
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
                  child: Text("Download"),
                ),
                const PopupMenuItem<int>(
                  value: 2,
                  child: Text("Download barcode"),
                ),
                const PopupMenuItem<int>(
                  value: 3,
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
                int size = await readFileExcelArrival(uint8list);
                if (size == 0) {
                } else {
                  controller.count.value = 0;
                  // controller.total.value = size;
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
                createCSV();
                focusScan.requestFocus();
                controller.scanController.selection = TextSelection(
                  baseOffset: 0,
                  extentOffset: controller.scanController.text.length,
                );
              } else if (value == 2) {
                createCsvQR();
                focusScan.requestFocus();
                controller.scanController.selection = TextSelection(
                  baseOffset: 0,
                  extentOffset: controller.scanController.text.length,
                );
              } else if (value == 3) {
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
                              id: 1,
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
                    Obx(
                      () => Row(
                        children: [
                          (Text(
                            "CTN: ${controller.ctn.value.toString()} / ${controller.tctn.value.toString()}",
                            style: const TextStyle(
                              backgroundColor: Colors.yellow,
                              fontSize: 30,
                            ),
                            textAlign: TextAlign.left,
                          )),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Obx(
                      () => (Row(
                        children: [
                          Expanded(
                              child: Text(
                            "${controller.solasort}",
                            style: const TextStyle(fontSize: 45),
                          )),
                          Expanded(
                              child: Text(
                            "${controller.oldnew}",
                            style: const TextStyle(
                                color: Colors.blueAccent, fontSize: 45),
                            textAlign: TextAlign.right,
                          )),
                        ],
                      )),
                    ),
                    Obx(
                      () => (Text(
                        controller.no.value.toString(),
                        style: TextStyle(
                            fontSize: controller.fontSize.value.toDouble()),
                      )),
                    ),
                    Container(
                      color: Colors.blue.withOpacity(0.3),
                      child: Row(
                        children: const [
                          Expanded(
                            child: Text(
                              'No',
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              'PLU',
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
                                    child: Text(controller.list[index].no)),
                                Expanded(
                                    child: Text(controller.list[index].plu)),
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

  scan(String value) {
    clearfield();

    switch (value.length) {
      case 28:
        getAssort(value);
        break;
      case 29:
        getAssort29(value);
        break;
      case 32:
        getsolid(value);
        break;
      case 36:
        getAssortQR(value);
        break;
      case 42:
        getsolidQR(value);
        break;

      default:
        playSoundError();
    }
    focusScan.requestFocus();
    controller.scanController.selection = TextSelection(
      baseOffset: 0,
      extentOffset: controller.scanController.text.length,
    );
  }

  getAssort(String s) async {
    s = s.toUpperCase();
    String itemCd = s.substring(4, 10);
    String po = s.substring(10, 13);
    int year = parseStringToInt(s.substring(15, 17));
    int serial = parseStringToInt(s.substring(17, 19));
    String assort = s.substring(19, 23);

    String key = itemCd + po + year.toString() + serial.toString() + assort;
    String carton = s.substring(23, 28);
    MyDatabase database = MyDatabase.instance;
    Box box = await database.getListBoxforAssort(itemCd, year, serial, assort);
    // ignore: prefer_is_empty
    if (box != null) {
      controller.solasort.value = 'Assort';
      controller.no.value = box.no;
      if (box.flagNew == 'N') {
        box.flagNew = 'Y';
        controller.oldnew.value = 'NEW';
      } else {
        controller.oldnew.value = 'OLD';
      }

      List<Ctn> lstctn = await database.getListCTN(key, carton);
      if (lstctn.isNotEmpty) {
      } else {
        Ctn ctn = Ctn(key: key, ctnno: carton);
        database.insertCTN(ctn);

        box.countCTN = box.countCTN + 1;
        controller.tctn.value = box.ctn;
        controller.ctn.value = box.countCTN;

        controller.count++;
        // ignore: prefer_interpolation_to_compose_strings
        String barcode = 'D' +
            s.substring(0, 4) +
            '-' +
            itemCd +
            '-' +
            s.substring(10, 13) +
            '-' +
            s.substring(13, 15) +
            '@' +
            padLeftZeros(year.toString(), 2) +
            '-' +
            padLeftZeros(serial.toString(), 2) +
            '@' +
            assort +
            '@' +
            carton;
        Scan scan = Scan(scan: s, barcode: barcode);
        database.insertScan(scan);
      }
      controller.tctn.value = box.ctn;
      controller.ctn.value = box.countCTN;
      database.updateBox(box);
      controller.getList();
    } else {
      playSoundError();
    }
  }

  getAssort29(String s) async {
    s = s.toUpperCase();
    String itemCd = s.substring(4, 10);
    String po = s.substring(10, 13);
    int year = parseStringToInt(s.substring(15, 17));
    int serial = parseStringToInt(s.substring(17, 20));
    String assort = s.substring(20, 24);

    String key = itemCd + po + year.toString() + serial.toString() + assort;
    String carton = s.substring(23, 28);
    MyDatabase database = MyDatabase.instance;
    Box box = await database.getListBoxforAssort(itemCd, year, serial, assort);
    // ignore: prefer_is_empty
    if (box != null) {
      controller.solasort.value = 'Assort';
      controller.no.value = box.no;
      if (box.flagNew == 'N') {
        box.flagNew = 'Y';
        controller.oldnew.value = 'NEW';
      } else {
        controller.oldnew.value = 'OLD';
      }

      List<Ctn> lstctn = await database.getListCTN(key, carton);
      if (lstctn.isNotEmpty) {
      } else {
        Ctn ctn = Ctn(key: key, ctnno: carton);
        database.insertCTN(ctn);

        box.countCTN = box.countCTN + 1;
        controller.tctn.value = box.ctn;
        controller.ctn.value = box.countCTN;

        controller.count++;
        // ignore: prefer_interpolation_to_compose_strings
        String barcode = 'D' +
            s.substring(0, 4) +
            '-' +
            itemCd +
            '-' +
            s.substring(10, 13) +
            '-' +
            s.substring(13, 15) +
            '@' +
            padLeftZeros(year.toString(), 2) +
            '-' +
            padLeftZeros(serial.toString(), 2) +
            '@' +
            assort +
            '@' +
            carton;
        Scan scan = Scan(scan: s, barcode: barcode);
        database.insertScan(scan);
      }
      controller.tctn.value = box.ctn;
      controller.ctn.value = box.countCTN;
      database.updateBox(box);
      controller.getList();
    } else {
      playSoundError();
    }
  }

  getAssortQR(String s) async {
    s = s.toUpperCase();
    String itemCd = s.substring(6, 12);
    String po = s.substring(13, 16);
    int year = parseStringToInt(s.substring(20, 22));
    int serial = parseStringToInt(s.substring(23, 25));
    String assort = s.substring(26, 30);

    String key = itemCd + po + year.toString() + serial.toString() + assort;
    String carton = s.substring(31, 36);
    MyDatabase database = MyDatabase.instance;
    Box box = await database.getListBoxforAssort(itemCd, year, serial, assort);
    // ignore: prefer_is_empty
    if (box != null) {
      controller.solasort.value = 'Assort';
      controller.no.value = box.no;
      if (box.flagNew == 'N') {
        box.flagNew = 'Y';
        controller.oldnew.value = 'NEW';
      } else {
        controller.oldnew.value = 'OLD';
      }

      List<Ctn> lstctn = await database.getListCTN(key, carton);
      if (lstctn.isNotEmpty) {
      } else {
        Ctn ctn = Ctn(key: key, ctnno: carton);
        database.insertCTN(ctn);

        box.countCTN = box.countCTN + 1;
        controller.tctn.value = box.ctn;
        controller.ctn.value = box.countCTN;

        controller.count++;

        Scan scan = Scan(scan: s, barcode: s);
        database.insertScan(scan);
      }
      controller.tctn.value = box.ctn;
      controller.ctn.value = box.countCTN;
      database.updateBox(box);
      controller.getList();
    } else {
      playSoundError();
    }
  }

  getsolid(String s) async {
    s = s.toUpperCase();
    String itemCd = s.substring(4, 10);
    String po = s.substring(10, 13);
    int year = parseStringToInt(s.substring(15, 17));
    int serial = parseStringToInt(s.substring(17, 19));
    int color = parseStringToInt(s.substring(19, 21));
    int size = parseStringToInt(s.substring(21, 24));
    int length = parseStringToInt(s.substring(24, 27));

    String key = itemCd +
        po +
        year.toString() +
        serial.toString() +
        color.toString() +
        size.toString() +
        length.toString();
    String carton = s.substring(27, 32);
    MyDatabase database = MyDatabase.instance;
    Box box = await database.getListBoxforSolid(
        itemCd, year, serial, color, size, length);
    // ignore: prefer_is_empty
    if (box != null) {
      controller.solasort.value = 'Solid';
      controller.no.value = box.no;
      if (box.flagNew == 'N') {
        box.flagNew = 'Y';
        controller.oldnew.value = 'NEW';
      } else {
        controller.oldnew.value = 'OLD';
      }

      List<Ctn> lstctn = await database.getListCTN(key, carton);
      if (lstctn.isNotEmpty) {
      } else {
        Ctn ctn = Ctn(key: key, ctnno: carton);
        database.insertCTN(ctn);

        box.countCTN = box.countCTN + 1;
        controller.tctn.value = box.ctn;
        controller.ctn.value = box.countCTN;

        controller.count++;
        // ignore: prefer_interpolation_to_compose_strings
        String barcode = 'D' +
            s.substring(0, 4) +
            '-' +
            s.substring(4, 4) +
            '-' +
            s.substring(10, 13) +
            '-' +
            s.substring(13, 15) +
            '@' +
            padLeftZeros(year.toString(), 2) +
            '-' +
            padLeftZeros(serial.toString(), 2) +
            '@' +
            padLeftZeros(color.toString(), 2) +
            '-' +
            padLeftZeros(length.toString(), 3) +
            '-' +
            padLeftZeros(size.toString(), 3) +
            '@' +
            carton;
        Scan scan = Scan(scan: s, barcode: barcode);
        database.insertScan(scan);
      }
      controller.tctn.value = box.ctn;
      controller.ctn.value = box.countCTN;
      database.updateBox(box);
      controller.getList();
    } else {
      playSoundError();
    }
  }

  getsolidQR(String s) async {
    s = s.toUpperCase();
    String itemCd = s.substring(6, 12);
    String po = s.substring(13, 16);
    int year = parseStringToInt(s.substring(20, 22));
    int serial = parseStringToInt(s.substring(23, 25));
    int color = parseStringToInt(s.substring(26, 28));
    int size = parseStringToInt(s.substring(29, 32));
    int length = parseStringToInt(s.substring(33, 36));

    String key = itemCd +
        po +
        year.toString() +
        serial.toString() +
        color.toString() +
        size.toString() +
        length.toString();
    String carton = s.substring(37, 42);
    MyDatabase database = MyDatabase.instance;
    Box box = await database.getListBoxforSolid(
        itemCd, year, serial, color, size, length);
    // ignore: prefer_is_empty
    if (box != null) {
      controller.solasort.value = 'Solid';
      controller.no.value = box.no;
      if (box.flagNew == 'N') {
        box.flagNew = 'Y';
        controller.oldnew.value = 'NEW';
      } else {
        controller.oldnew.value = 'OLD';
      }

      List<Ctn> lstctn = await database.getListCTN(key, carton);
      if (lstctn.isNotEmpty) {
      } else {
        Ctn ctn = Ctn(key: key, ctnno: carton);
        database.insertCTN(ctn);

        box.countCTN = box.countCTN + 1;
        controller.tctn.value = box.ctn;
        controller.ctn.value = box.countCTN;

        controller.count++;
        // ignore: prefer_interpolation_to_compose_strings

        Scan scan = Scan(scan: s, barcode: s);
        database.insertScan(scan);
      }
      controller.tctn.value = box.ctn;
      controller.ctn.value = box.countCTN;
      database.updateBox(box);
      controller.getList();
    } else {
      playSoundError();
    }
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
    controller.ctn.value = 0;
    controller.tctn.value = 0;
    controller.no.value = 'N/A';
    controller.solasort.value = '';
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
