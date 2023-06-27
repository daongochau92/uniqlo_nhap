// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:csv/csv.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uniqlo_nhap/database/database.dart';
import 'package:uniqlo_nhap/model/box.dart';
import 'package:uniqlo_nhap/model/loading.dart';
import 'package:uniqlo_nhap/model/scan.dart';
import 'package:uniqlo_nhap/model/sts.dart';

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

Future<String> getDirCSV() async {
  FilePickerResult result = await FilePicker.platform
      .pickFiles(type: FileType.custom, allowedExtensions: ['csv', 'CSV']);

  if (result != null) {
    return result.paths.first;
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

Future<void> playSoundError() async {
  try {
    AudioPlayer player = AudioPlayer();
    await player.play(AssetSource('audio/beep.mp3'));
  } catch (e) {
    print(e.toString());
  }
}

void showdialog({String title, String content}) {
  showDialog(
    context: Get.context,
    builder: (context) => AlertDialog(
      title: Text(title == '' ? 'Error' : title),
      content: Text(content == '' ? '' : content),
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
}

Future<int> readFileExcelArrival(Uint8List uint8list) async {
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
      pallet: '',
    );
    listUpload.add(box);
    myDatabase.insertBox(box);
  }

  return listUpload.length;
}

Future<int> readFileExcelArrival1(Uint8List uint8list) async {
  Excel excel = Excel.decodeBytes(uint8list);
  Map<String, Sheet> table = excel.tables;
  MyDatabase myDatabase = MyDatabase.instance;
  await myDatabase.deleteAll1();
  await myDatabase.deleteAllCtn1();
  await myDatabase.deleteAllScan1();
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
      ctn: getCellNumberValue(dataRow[10]),
      shipment: getCellValue(dataRow[9]),
      countCTN: 0,
      flagNew: 'N',
      pallet: '',
    );
    listUpload.add(box);
    myDatabase.insertBox1(box);
  }

  return listUpload.length;
}

Future<int> readFileExcelCheckSTS(Uint8List uint8list) async {
  Excel excel = Excel.decodeBytes(uint8list);
  Map<String, Sheet> table = excel.tables;
  MyDatabase myDatabase = MyDatabase.instance;
  await myDatabase.deleteAllSts();
  List<Sts> listUpload = [];
  Sheet sheet = table["Sheet1"];
  for (int row = 1; row < sheet.maxRows; row++) {
    List<Data> dataRow = sheet.row(row);
    if (getCellValue(dataRow[5]) == '' || getCellValue(dataRow[6]) == '') {
      continue;
    }

    String arrDate = '';
    try {
      arrDate = getCellValue(dataRow[1]).substring(0, 10);
    } catch (e) {
      print(e.toString());
    }

    Sts sts = Sts(
      refNo: getCellValue(dataRow[5]),
      arrivalDate: arrDate,
      shipfrom: getCellValue(dataRow[6]),
      shiptocd: getCellValue(dataRow[2]),
      flagNew: 'N',
      refTrim: getCellValue(dataRow[5]).replaceAll('-', ''),
    );
    listUpload.add(sts);
    myDatabase.insertCheckSts(sts);
  }

  return listUpload.length;
}

Future<int> readFileCSVLoading(String dir) async {
  MyDatabase myDatabase = MyDatabase.instance;
  List<Loading> listUpload = [];
  try {
    File f = File(dir);
    final input = f.openRead();
    final fields = await input
        .transform(utf8.decoder)
        .transform(const CsvToListConverter())
        .toList();
    for (int row = 1; row < fields.length; row++) {
      var datarow = fields[row];
      if (parseStringToInt(datarow[11].toString()) == 0 ||
          datarow[13].toString().trim() == '') {
        continue;
      }
      Loading loading = Loading(
          storeCode: parseStringToInt(datarow[11].toString()),
          storeName: datarow[12].toString().trim(),
          deliveryDate: datarow[7].toString().trim(),
          refNo: datarow[13].toString().trim(),
          scanned: 'N');

      Loading load =
          await myDatabase.getLoading(loading.storeCode, loading.refNo);
      if (load == null) {
        myDatabase.insertLoading(loading);
      }

      listUpload.add(loading);
    }
  } catch (e) {
    print(e);
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

int parseStringToInt(String data) {
  try {
    int number = 0;
    number = int.parse(data.toString().trim());
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
      File f = File("$dir/Arrival_${format.format(DateTime.now())}.csv");
      f.writeAsStringSync(
          'No, Item, Year, Serial, Color, Size, PatLength, AssortCD, PLU, Shipment, ctn, count ctn, Scanned',
          mode: FileMode.append);
      f.writeAsStringSync('\n', mode: FileMode.append);
      MyDatabase m = MyDatabase.instance;
      List<Box> list = await m.getListBoxAllBox();
      for (var b in list) {
        f.writeAsStringSync(
            '${b.no},${b.itemCD},${b.year},${b.serialNo},${b.color},${b.size},${b.patlength},${b.assortCD},${b.plu},${b.shipment},${b.ctn},${b.countCTN},${b.flagNew}',
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

Future<void> createCSV1() async {
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
      File f = File("$dir/TransferWH_${format.format(DateTime.now())}.csv");
      f.writeAsStringSync(
          'No, Item, Year, Serial, Color, Size, PatLength, AssortCD, PLU, Department, ctn, count ctn, pallet, Scanned',
          mode: FileMode.append);
      f.writeAsStringSync('\n', mode: FileMode.append);
      MyDatabase m = MyDatabase.instance;
      List<Box> list = await m.getListBoxAllBox1();
      for (var b in list) {
        f.writeAsStringSync(
            '${b.no},${b.itemCD},${b.year},${b.serialNo},${b.color},${b.size},${b.patlength},${b.assortCD},${b.plu},${b.shipment},${b.ctn},${b.countCTN},${b.pallet},${b.flagNew}',
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
    File f = File("$dir/Arrival_QR${format.format(DateTime.now())}.csv");
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

Future<void> createCsvQR1() async {
  String dir = await getDirPath();
  if (dir != null) {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }
    var format = DateFormat('yyyymmddhhmmss');
    File f = File("$dir/TransferWH_QR${format.format(DateTime.now())}.csv");
    f.writeAsStringSync('scan, QR, pallet, plu', mode: FileMode.append);
    f.writeAsStringSync('\n', mode: FileMode.append);
    MyDatabase m = MyDatabase.instance;
    List<Scan> list = await m.getListScan1();
    for (var b in list) {
      f.writeAsStringSync('${b.scan},${b.barcode},${b.pallet},${b.plu}',
          mode: FileMode.append);
      f.writeAsStringSync('\n', mode: FileMode.append);
    }
  }
}
