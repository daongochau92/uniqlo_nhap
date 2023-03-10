import 'package:uniqlo_nhap/database/database.dart';

class Scan {
  int id;
  String scan;
  String barcode;

  Scan({this.scan, this.barcode});

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = <String, dynamic>{
      colId: id,
      colscan: scan,
      colbarcode: barcode
    };
    return map;
  }

  Scan.fromMap(Map<String, dynamic> map) {
    id = map[colId];
    scan = map[colscan];
    barcode = map[colbarcode];
  }
}
