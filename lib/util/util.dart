import 'dart:io';
import 'dart:typed_data';

import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uniqlo_nhap/database/database.dart';
import 'package:uniqlo_nhap/model/box.dart';
import 'package:uniqlo_nhap/model/scan.dart';
import 'package:uniqlo_nhap/modules/home/controllers/home_controller.dart';

Future<Uint8List> getDir() async {
  FilePickerResult result = await FilePicker.platform
      .pickFiles(type: FileType.custom, allowedExtensions: ['xlsx']);

  if (result != null) {
    var bytes = File(result.files.single.path).readAsBytesSync();

    return bytes;
  } else {
    // User canceled the picker
  }
  return null;
}

Future<String> getDirPath() async {
  String result = await FilePicker.platform.getDirectoryPath();
  return result;
}

void successSnackbar(String msg) {
  Get.snackbar('msg', "Success !",
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green[400],
      colorText: Colors.white);
}

void errorSnackbar(String msg) {
  Get.snackbar('msg', "Error !",
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red[400],
      colorText: Colors.white);
}

Future<int> readFileExcel(Uint8List uint8list) async {
  Excel excel = Excel.decodeBytes(uint8list);
  Map<String, Sheet> table = excel.tables;
  MyDatabase myDatabase = MyDatabase.instance;
  await myDatabase.deleteAll();
  await myDatabase.deleteAllCtn();
  await myDatabase.deleteAllScan();
  List<Box> listUpload = [];
  Sheet sheet = table["Sheet1"];
  for (int row = 1; row < sheet.maxRows; row++) {
    List<Data> dataRow = sheet.row(row);
    if (getCellValue(dataRow[1]) == '' || getCellValue(dataRow[1]) == '0') {
      continue;
    }

    Box box = Box(
      no: getCellValue(dataRow[0]),
      plu: getCellValue(dataRow[1]),
      itemCD: getCellValue(dataRow[2]),
      year: getCellNumberValue(dataRow[3]),
      serialNo: getCellNumberValue(dataRow[4]),
      color: getCellNumberValue(dataRow[5]),
      size: getCellNumberValue(dataRow[6]),
      patlength: getCellNumberValue(dataRow[7]),
      assortCD: getCellValue(dataRow[8]),
      ctn: getCellNumberValue(dataRow[9]),
      shipment: getCellValue(dataRow[10]),
      countCTN: 0,
      flagNew: 'N',
    );
    listUpload.add(box);
    myDatabase.insertBox(box);
  }

  return listUpload.length;
}

int getCellNumberValue(Data data) {
  try {
    int number = 0;
    number = int.parse(data.value.toString().trim());
    return number;
  } catch (e) {
    return 0;
  }
}

String getCellValue(Data data) {
  try {
    if (data.value.toString() == 'null') {
      return '';
    }
    return data.value.toString().trim().toUpperCase();
  } catch (e) {
    return '';
  }
}

Future<void> createCSV() async {
  String dir = await getDirPath();

  // final homeCOntroller = Get.find<HomeController>();
  // homeCOntroller.scanController.text = dir;
  if (dir != null) {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }
    try {
      var format = DateFormat('yyyymmddhhmmss');
      File f = File("$dir/${format.format(DateTime.now())}.csv");
      f.writeAsStringSync(
          'No, Item, Year, Serial, Color, Size, PatLength, AssortCD, PLU, Shipment, ctn, count ctn, Scanned',
          mode: FileMode.append);
      f.writeAsStringSync('\n', mode: FileMode.append);
      MyDatabase m = MyDatabase.instance;
      List<Box> list = await m.getListBoxAllBox();
      for (var b in list) {
        f.writeAsStringSync(
            '${b.no},${b.itemCD},${b.year},${b.serialNo},${b.color},${b.color},${b.size},${b.patlength},${b.assortCD},${b.shipment},${b.ctn},${b.countCTN},${b.flagNew}',
            mode: FileMode.append);
        f.writeAsStringSync('\n', mode: FileMode.append);
      }
    } catch (e) {
      // homeCOntroller.scanController.text = '${e.toString()}eror';
    }
  } else {
    // homeCOntroller.scanController.text = '${dir}errr';
  }
}

Future<void> createCsvQR() async {
  String dir = await getDirPath();
  if (dir != null) {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }
    var format = DateFormat('yyyymmddhhmmss');
    File f = File("$dir/QR${format.format(DateTime.now())}.csv");
    f.writeAsStringSync('scan, QR', mode: FileMode.append);
    f.writeAsStringSync('\n', mode: FileMode.append);
    MyDatabase m = MyDatabase.instance;
    List<Scan> list = await m.getListScan();
    for (var b in list) {
      f.writeAsStringSync('${b.scan},${b.barcode}', mode: FileMode.append);
      f.writeAsStringSync('\n', mode: FileMode.append);
    }
  }
}
