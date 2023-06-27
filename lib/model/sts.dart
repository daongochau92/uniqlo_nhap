import '../database/database.dart';

class Sts {
  int id;
  String refNo;
  String arrivalDate;
  String shipfrom;
  String shiptocd;
  String flagNew;
  String refTrim;

  Sts({
    this.refNo,
    this.arrivalDate,
    this.shipfrom,
    this.shiptocd,
    this.flagNew,
    this.refTrim,
  });

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = <String, dynamic>{
      colId: id,
      colRefNo: refNo,
      colArrivalDate: arrivalDate,
      colShipfrom: shipfrom,
      colShiptoCD: shiptocd,
      colflagNew: flagNew,
      colRefTrim: refTrim,
    };
    return map;
  }

  Sts.fromMap(Map<String, dynamic> map) {
    id = map[colId];
    refNo = map[colRefNo];
    arrivalDate = map[colArrivalDate];
    shipfrom = map[colShipfrom];
    shiptocd = map[colShiptoCD];
    flagNew = map[colflagNew];
    refTrim = map[colRefTrim];
  }
}
