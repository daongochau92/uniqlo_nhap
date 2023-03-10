import 'package:uniqlo_nhap/database/database.dart';

class Ctn {
  int id;
  String key;
  String ctnno;

  Ctn({this.key, this.ctnno});

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = <String, dynamic>{
      colId: id,
      colKey: key,
      colctnno: ctnno
    };
    return map;
  }

  Ctn.fromMap(Map<String, dynamic> map) {
    id = map[colId];
    key = map[colKey];
    ctnno = map[colctnno];
  }
}
