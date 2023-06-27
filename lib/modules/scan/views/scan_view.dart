import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uniqlo_nhap/database/database.dart';
import 'package:uniqlo_nhap/model/box.dart';

import '../../../model/ctn.dart';
import '../../../model/save.dart';
import '../../../model/scan.dart';
import '../../../util/util.dart';
import '../controllers/scan_controller.dart';

// ignore: must_be_immutable, use_key_in_widget_constructors
class ScanView extends GetView<ScanController> {
  FocusNode focusScan;
  FocusNode focusPallet;
  @override
  Widget build(BuildContext context) {
    focusScan = FocusNode();
    focusPallet = FocusNode();
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
                int size = await readFileExcelArrival1(uint8list);
                if (size == 0) {
                } else {
                  controller.count.value = 0;
                  // controller.total.value = size;
                  controller.getList();
                  clearfield();
                  controller.scanController.text = '';
                  focusPallet.requestFocus();
                  controller.palletController.selection = TextSelection(
                    baseOffset: 0,
                    extentOffset: controller.palletController.text.length,
                  );
                }
              } else if (value == 1) {
                createCSV1();
                focusScan.requestFocus();
                controller.scanController.selection = TextSelection(
                  baseOffset: 0,
                  extentOffset: controller.scanController.text.length,
                );
              } else if (value == 2) {
                createCsvQR1();
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
                              id: 3,
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
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: SizedBox(
                  height: 50,
                  child: TextField(
                    controller: controller.palletController,
                    focusNode: focusPallet,
                    decoration: const InputDecoration(
                      hintText: 'Pallet',
                    ),
                    onSubmitted: (value) {
                      pallet(value);
                    },
                  ),
                ),
              ),
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
            ],
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
                              'Item',
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              'Deparment',
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
                                    child: Text(controller.list[index].itemCD)),
                                Expanded(
                                    child:
                                        Text(controller.list[index].shipment)),
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

  pallet(String value) {
    if (controller.palletController.text.trim() == '') {
      playSoundError();
      showdialog(title: "error", content: "Please input pallet");
      focusPallet.requestFocus();
      controller.palletController.selection = TextSelection(
        baseOffset: 0,
        extentOffset: controller.palletController.text.length,
      );
      return;
    }
    focusScan.requestFocus();
    controller.scanController.selection = TextSelection(
      baseOffset: 0,
      extentOffset: controller.scanController.text.length,
    );
  }

  scan(String value) {
    if (controller.palletController.text.trim() == '') {
      playSoundError();
      showdialog(title: "error", content: "Please input pallet");
      focusPallet.requestFocus();
      controller.palletController.selection = TextSelection(
        baseOffset: 0,
        extentOffset: controller.palletController.text.length,
      );
      return;
    }
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
      case 33:
        getsolid33(value);
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
    Box box = await database.getListBoxforAssort1(itemCd, year, serial, assort);
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

      List<Ctn> lstctn = await database.getListCTN1(key, carton);
      if (lstctn.isNotEmpty) {
      } else {
        Ctn ctn = Ctn(key: key, ctnno: carton);
        database.insertCTN1(ctn);

        box.countCTN = box.countCTN + 1;
        controller.tctn.value = box.ctn;
        controller.ctn.value = box.countCTN;
        box.pallet = controller.palletController.text.trim();

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
        Scan scan = Scan(
          scan: s,
          barcode: barcode,
          pallet: controller.palletController.text.trim(),
          plu: box.plu,
        );
        database.insertScan1(scan);
      }
      controller.tctn.value = box.ctn;
      controller.ctn.value = box.countCTN;
      database.updateBox1(box);
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
    String carton = s.substring(24, 29);
    MyDatabase database = MyDatabase.instance;
    Box box = await database.getListBoxforAssort1(itemCd, year, serial, assort);
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

      List<Ctn> lstctn = await database.getListCTN1(key, carton);
      if (lstctn.isNotEmpty) {
      } else {
        Ctn ctn = Ctn(key: key, ctnno: carton);
        database.insertCTN1(ctn);

        box.countCTN = box.countCTN + 1;
        box.pallet = controller.palletController.text.trim();
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
        Scan scan = Scan(
          scan: s,
          barcode: barcode,
          pallet: controller.palletController.text.trim(),
          plu: box.plu,
        );
        database.insertScan1(scan);
      }
      controller.tctn.value = box.ctn;
      controller.ctn.value = box.countCTN;

      database.updateBox1(box);
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
    Box box = await database.getListBoxforAssort1(itemCd, year, serial, assort);
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

      List<Ctn> lstctn = await database.getListCTN1(key, carton);
      if (lstctn.isNotEmpty) {
      } else {
        Ctn ctn = Ctn(key: key, ctnno: carton);
        database.insertCTN1(ctn);

        box.countCTN = box.countCTN + 1;
        controller.tctn.value = box.ctn;
        controller.ctn.value = box.countCTN;
        box.pallet = controller.palletController.text.trim();

        controller.count++;

        Scan scan = Scan(
          scan: s,
          barcode: s,
          pallet: controller.palletController.text.trim(),
          plu: box.plu,
        );
        database.insertScan1(scan);
      }
      controller.tctn.value = box.ctn;
      controller.ctn.value = box.countCTN;
      database.updateBox1(box);
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
    Box box = await database.getListBoxforSolid1(
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

      List<Ctn> lstctn = await database.getListCTN1(key, carton);
      if (lstctn.isNotEmpty) {
      } else {
        Ctn ctn = Ctn(key: key, ctnno: carton);
        database.insertCTN1(ctn);

        box.countCTN = box.countCTN + 1;
        controller.tctn.value = box.ctn;
        controller.ctn.value = box.countCTN;
        box.pallet = controller.palletController.text.trim();

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
        Scan scan = Scan(
          scan: s,
          barcode: barcode,
          pallet: controller.palletController.text.trim(),
          plu: box.plu,
        );
        database.insertScan1(scan);
      }
      controller.tctn.value = box.ctn;
      controller.ctn.value = box.countCTN;
      database.updateBox1(box);
      controller.getList();
    } else {
      playSoundError();
    }
  }

  getsolid33(String s) async {
    s = s.toUpperCase();
    String itemCd = s.substring(4, 10);
    String po = s.substring(10, 13);
    int year = parseStringToInt(s.substring(15, 17));
    int serial = parseStringToInt(s.substring(17, 20));
    int color = parseStringToInt(s.substring(20, 22));
    int size = parseStringToInt(s.substring(22, 25));
    int length = parseStringToInt(s.substring(25, 28));

    String key = itemCd +
        po +
        year.toString() +
        serial.toString() +
        color.toString() +
        size.toString() +
        length.toString();
    String carton = s.substring(28, 33);
    MyDatabase database = MyDatabase.instance;
    Box box = await database.getListBoxforSolid1(
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

      List<Ctn> lstctn = await database.getListCTN1(key, carton);
      if (lstctn.isNotEmpty) {
      } else {
        Ctn ctn = Ctn(key: key, ctnno: carton);
        database.insertCTN1(ctn);

        box.countCTN = box.countCTN + 1;
        controller.tctn.value = box.ctn;
        controller.ctn.value = box.countCTN;
        box.pallet = controller.palletController.text.trim();

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
        Scan scan = Scan(
          scan: s,
          barcode: barcode,
          pallet: controller.palletController.text.trim(),
          plu: box.plu,
        );
        database.insertScan1(scan);
      }
      controller.tctn.value = box.ctn;
      controller.ctn.value = box.countCTN;
      database.updateBox1(box);
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
    Box box = await database.getListBoxforSolid1(
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

      List<Ctn> lstctn = await database.getListCTN1(key, carton);
      if (lstctn.isNotEmpty) {
      } else {
        Ctn ctn = Ctn(key: key, ctnno: carton);
        database.insertCTN1(ctn);

        box.countCTN = box.countCTN + 1;
        controller.tctn.value = box.ctn;
        controller.ctn.value = box.countCTN;
        box.pallet = controller.palletController.text.trim();

        controller.count++;
        // ignore: prefer_interpolation_to_compose_strings

        Scan scan = Scan(
          scan: s,
          barcode: s,
          pallet: controller.palletController.text.trim(),
          plu: box.plu,
        );
        database.insertScan1(scan);
      }
      controller.tctn.value = box.ctn;
      controller.ctn.value = box.countCTN;
      database.updateBox1(box);
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
