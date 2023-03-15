import '../database/database.dart';

class Loading {
  int id;
  int storeCode;
  String storeName;
  String deliveryDate;
  String refNo;
  String scanned;

  Loading(
      {this.storeCode,
      this.storeName,
      this.deliveryDate,
      this.refNo,
      this.scanned});

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = <String, dynamic>{
      colId: id,
      colStoreCode: storeCode,
      colStoreName: storeName,
      colDeliveryDate: deliveryDate,
      colRefNo: refNo,
      colscanned: scanned
    };
    return map;
  }

  Loading.fromMap(Map<String, dynamic> map) {
    id = map[colId];
    storeCode = map[colStoreCode];
    storeName = map[colStoreName];
    deliveryDate = map[colDeliveryDate];
    refNo = map[colRefNo];
    scanned = map[colscanned];
  }
}
