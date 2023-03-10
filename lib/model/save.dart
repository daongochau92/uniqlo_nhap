import 'package:uniqlo_nhap/database/database.dart';

class Save {
  int id;
  int fontSize;

  Save({this.id, this.fontSize});

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = <String, dynamic>{
      colId: id,
      colFontsize: fontSize,
    };
    return map;
  }

  Save.fromMap(Map<String, dynamic> map) {
    id = map[colId];
    fontSize = map[colFontsize];
  }
}
