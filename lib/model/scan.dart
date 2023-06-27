import 'package:uniqlo_nhap/database/database.dart';

class Scan {
  int id;
  String scan;
  String barcode;
  String pallet;
  String plu;

  Scan({this.scan, this.barcode, this.pallet, this.plu});

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = <String, dynamic>{
      colId: id,
      colscan: scan,
      colbarcode: barcode,
      colpallet: pallet,
      colplu: plu
    };
    return map;
  }

  Scan.fromMap(Map<String, dynamic> map) {
    id = map[colId];
    scan = map[colscan];
    barcode = map[colbarcode];
    pallet = map[colpallet];
    plu = map[colplu];
  }
}
