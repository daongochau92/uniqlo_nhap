import 'package:uniqlo_nhap/database/database.dart';

class Box {
  int id;
  String no;
  String itemCD;
  int year;
  int serialNo;
  int color;
  int size;
  int patlength;
  String assortCD;
  String plu;
  String shipment;
  int ctn;
  int countCTN;
  String flagNew;

  Box(
      {this.no,
      this.itemCD,
      this.year,
      this.serialNo,
      this.color,
      this.size,
      this.patlength,
      this.assortCD,
      this.plu,
      this.shipment,
      this.ctn,
      this.countCTN,
      this.flagNew});

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = <String, dynamic>{
      colId: id,
      colno: no,
      colitemCD: itemCD,
      colyear: year,
      colserialNo: serialNo,
      colcolor: color,
      colsize: size,
      colpatlength: patlength,
      colassortCD: assortCD,
      colplu: plu,
      colshipment: shipment,
      colctn: ctn,
      colcountCTN: countCTN,
      colflagNew: flagNew,
    };
    return map;
  }

  Box.fromMap(Map<String, dynamic> map) {
    id = map[colId];
    no = map[colno];
    itemCD = map[colitemCD];
    year = map[colyear];
    serialNo = map[colserialNo];
    color = map[colcolor];
    size = map[colsize];
    patlength = map[colpatlength];
    assortCD = map[colassortCD];
    plu = map[colplu];
    shipment = map[colshipment];
    ctn = map[colctn];
    countCTN = map[colcountCTN];
    flagNew = map[colflagNew];
  }
}
