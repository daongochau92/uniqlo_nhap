// ignore_for_file: avoid_print

import 'package:sqflite/sqflite.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart';
import 'package:uniqlo_nhap/model/box.dart';
import 'package:uniqlo_nhap/model/ctn.dart';
import 'package:uniqlo_nhap/model/loading.dart';
import 'package:uniqlo_nhap/model/save.dart';
import 'package:uniqlo_nhap/model/scan.dart';

const String dbname = 'nippon.db';

//tb box
const String dbtable = 'tbbox';
const String colId = '_id';
const String colno = 'no';
const String colitemCD = 'itemCD';
const String colyear = 'year';
const String colserialNo = 'serialNo';
const String colcolor = 'color';
const String colsize = 'size';
const String colpatlength = 'patlength';
const String colassortCD = 'assortCD';
const String colplu = 'plu';
const String colshipment = 'shipment';
const String colctn = 'ctn';
const String colcountCTN = 'countCTN';
const String colflagNew = 'flagNew';

//tb dictionary carton
const String dbctn = 'tbctn';
const String colKey = 'key';
const String colctnno = 'ctnno';

//tb save
const String dbsave = 'tbsave';
const String colFontsize = 'fondsize';

//tb save
const String dbscan = 'tbscan';
const String colscan = 'scan';
const String colbarcode = 'barcode';

//tb loading
const String dbloading = 'tbloading';
const String colStoreCode = 'storeCode';
const String colStoreName = 'storeName';
const String colDeliveryDate = 'deliveryDate';
const String colRefNo = 'refNo';
const String colscanned = 'scanned';

class MyDatabase {
  Database _database;

  MyDatabase._();

  static final MyDatabase instance = MyDatabase._();

  Future<Database> get getdatabase async {
    if (_database == null) {
      String databasesPath = await getDatabasesPath();
      String dbPath = join(databasesPath, dbname);
      print(dbPath);
      _database = await openDatabase(dbPath, version: 1, onCreate: populateDb);
    }
    return _database;
  }

  void populateDb(Database database, int version) async {
    await database.execute(
      "CREATE TABLE $dbtable ("
      "$colId INTEGER PRIMARY KEY AUTOINCREMENT,"
      "$colno TEXT,"
      "$colitemCD TEXT,"
      "$colyear INTEGER,"
      "$colserialNo INTEGER,"
      "$colcolor INTEGER,"
      "$colsize INTEGER,"
      "$colpatlength INTEGER,"
      "$colassortCD TEXT,"
      "$colplu TEXT,"
      "$colshipment TEXT,"
      "$colctn INTEGER,"
      "$colcountCTN INTEGER,"
      "$colflagNew TEXT"
      ")",
    );

    await database.execute(
      "CREATE TABLE $dbctn ("
      "$colId INTEGER PRIMARY KEY AUTOINCREMENT,"
      "$colKey TEXT,"
      "$colctnno TEXT"
      ")",
    );

    await database.execute(
      "CREATE TABLE $dbsave ("
      "$colId INTEGER PRIMARY KEY,"
      "$colFontsize INTEGER"
      ")",
    );

    await database.execute(
      "CREATE TABLE $dbscan ("
      "$colId INTEGER PRIMARY KEY AUTOINCREMENT,"
      "$colscan TEXT,"
      "$colbarcode TEXT"
      ")",
    );

    await database.execute(
      "CREATE TABLE $dbloading ("
      "$colId INTEGER PRIMARY KEY AUTOINCREMENT,"
      "$colStoreCode INTEGER,"
      "$colStoreName TEXT,"
      "$colRefNo TEXT,"
      "$colDeliveryDate TEXT,"
      "$colscanned TEXT"
      ")",
    );
  }

  Future<List<Ctn>> getListCTN(String key, String strctn) async {
    Database db = await instance.getdatabase;
    List<Map> maps = await db.query(
      dbctn,
      columns: [colId, colKey, colctnno],
      where: '$colKey = ? and $colctnno = ?',
      whereArgs: [key, strctn],
    );
    // ignore: prefer_is_empty
    if (maps.length > 0) {
      return maps.map((e) => Ctn.fromMap(e)).toList();
    }
    return [];
  }

  Future<Save> getSave() async {
    Database db = await instance.getdatabase;
    List<Map> maps = await db.query(
      dbsave,
      columns: [colId, colFontsize],
      where: '$colId = ?',
      whereArgs: [1],
    );
    // ignore: prefer_is_empty
    if (maps.length > 0) {
      return Save.fromMap(maps.first);
    }

    return null;
  }

  Future<int> insertBox(Box box) async {
    Database db = await instance.getdatabase;
    var result = await db.insert(dbtable, box.toMap());
    return result;
  }

  Future<int> insertLoading(Loading loading) async {
    Database db = await instance.getdatabase;
    var result = await db.insert(dbloading, loading.toMap());
    return result;
  }

  Future<int> insertScan(Scan scan) async {
    Database db = await instance.getdatabase;
    var result = await db.insert(dbscan, scan.toMap());
    return result;
  }

  Future<int> insertSave(Save save) async {
    Database db = await instance.getdatabase;
    var result = await db.insert(dbsave, save.toMap());
    return result;
  }

  Future<int> insertCTN(Ctn ctn) async {
    Database db = await instance.getdatabase;
    var result = await db.insert(dbctn, ctn.toMap());
    return result;
  }

  Future<List<Box>> getListBoxAllBox() async {
    Database db = await instance.getdatabase;
    List<Map> maps = await db.query(
      dbtable,
      columns: [
        colId,
        colno,
        colitemCD,
        colyear,
        colserialNo,
        colcolor,
        colsize,
        colpatlength,
        colassortCD,
        colplu,
        colshipment,
        colctn,
        colcountCTN,
        colflagNew
      ],
      // where: '$colScaned = ?',
      // whereArgs: ['scanned'],
    );
    // ignore: prefer_is_empty
    if (maps.length > 0) {
      return maps.map((e) => Box.fromMap(e)).toList();
    }
    return [];
  }

  Future<List<Box>> getListBoxAllBoxNotScann() async {
    Database db = await instance.getdatabase;
    List<Map> maps = await db.query(
      dbtable,
      columns: [
        colId,
        colno,
        colitemCD,
        colyear,
        colserialNo,
        colcolor,
        colsize,
        colpatlength,
        colassortCD,
        colplu,
        colshipment,
        colctn,
        colcountCTN,
        colflagNew
      ],
      where: '$colflagNew = ?',
      whereArgs: ['N'],
    );
    // ignore: prefer_is_empty
    if (maps.length > 0) {
      return maps.map((e) => Box.fromMap(e)).toList();
    }
    return [];
  }

  Future<List<Loading>> getListLoading(int store) async {
    Database db = await instance.getdatabase;
    List<Map> maps = await db.query(
      dbloading,
      columns: [
        colId,
        colStoreCode,
        colStoreName,
        colDeliveryDate,
        colRefNo,
        colscanned
      ],
      where: '$colscanned = ? and $colStoreCode = ?',
      whereArgs: ['N', store],
    );
    // ignore: prefer_is_empty
    if (maps.length > 0) {
      return maps.map((e) => Loading.fromMap(e)).toList();
    }
    return [];
  }

  Future<Loading> getLoading(int store, String refno) async {
    Database db = await instance.getdatabase;
    List<Map> maps = await db.query(
      dbloading,
      columns: [
        colId,
        colStoreCode,
        colStoreName,
        colDeliveryDate,
        colRefNo,
        colscanned
      ],
      where: '$colStoreCode = ? and $colRefNo = ?',
      whereArgs: [store, refno],
    );
    // ignore: prefer_is_empty
    if (maps.length > 0) {
      return Loading.fromMap(maps.first);
    }
    return null;
  }

  Future<String> getStoreName(int storecode) async {
    Database db = await instance.getdatabase;
    List<Map> maps = await db.query(
      dbloading,
      columns: [colStoreName],
      where: '$colStoreCode = ?',
      whereArgs: [storecode],
    );
    // ignore: prefer_is_empty
    if (maps.length > 0) {
      return maps.first[colStoreName];
    }
    return '';
  }

  Future<int> getTotalLoading(int store) async {
    Database db = await instance.getdatabase;
    List<Map> maps = await db.query(
      dbloading,
      columns: ['count(*) as count'],
      where: '$colStoreCode = ?',
      whereArgs: [store],
    );
    // ignore: prefer_is_empty
    if (maps.length > 0) {
      return maps.first['count'];
    }
    return 0;
  }

  Future<List<Scan>> getListScan() async {
    Database db = await instance.getdatabase;
    List<Map> maps = await db.query(
      dbscan,
      columns: [colId, colscan, colbarcode],
      // where: '$colScaned = ?',
      // whereArgs: ['scanned'],
    );
    // ignore: prefer_is_empty
    if (maps.length > 0) {
      return maps.map((e) => Scan.fromMap(e)).toList();
    }
    return [];
  }

  Future<int> getTotalCTN() async {
    Database db = await instance.getdatabase;
    List<Map> maps = await db.query(
      dbtable,
      columns: ['sum($colctn) as sum'],
    );
    // ignore: prefer_is_empty
    if (maps.length > 0) {
      return maps.first['sum'];
    }
    return 0;
  }

  Future<Box> getListBoxforAssort(
      String strItemCD, int intYear, int intSerial, String strAssortCD) async {
    Database db = await instance.getdatabase;
    List<Map> maps = await db.query(
      dbtable,
      columns: [
        colId,
        colno,
        colitemCD,
        colyear,
        colserialNo,
        colcolor,
        colsize,
        colpatlength,
        colassortCD,
        colplu,
        colshipment,
        colctn,
        colcountCTN,
        colflagNew
      ],
      where:
          '$colitemCD = ? and $colyear = ? and $colserialNo = ? and $colassortCD = ?',
      whereArgs: [strItemCD, intYear, intSerial, strAssortCD],
    );
    // ignore: prefer_is_empty
    if (maps.length > 0) {
      return Box.fromMap(maps.first);
    }
    return null;
  }

  Future<Box> getListBoxforSolid(String strItemCD, int intYear, int intSerial,
      int color, int size, int length) async {
    Database db = await instance.getdatabase;
    List<Map> maps = await db.query(
      dbtable,
      columns: [
        colId,
        colno,
        colitemCD,
        colyear,
        colserialNo,
        colcolor,
        colsize,
        colpatlength,
        colassortCD,
        colplu,
        colshipment,
        colctn,
        colcountCTN,
        colflagNew
      ],
      where:
          '$colitemCD = ? and $colyear = ? and $colserialNo = ? and $colcolor = ? and $colsize = ? and $colpatlength = ?',
      whereArgs: [strItemCD, intYear, intSerial, color, size, length],
    );
    // ignore: prefer_is_empty
    if (maps.length > 0) {
      return Box.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateBox(Box box) async {
    Database db = await instance.getdatabase;
    return await db.update(
      dbtable,
      box.toMap(),
      where: '$colId = ?',
      whereArgs: [box.id],
    );
  }

  Future<int> updateSave(Save save) async {
    Database db = await instance.getdatabase;
    return await db.update(
      dbsave,
      save.toMap(),
      where: '$colId = ?',
      whereArgs: [save.id],
    );
  }

  Future<int> updateLoading(Loading load) async {
    Database db = await instance.getdatabase;
    return await db.update(
      dbloading,
      load.toMap(),
      where: '$colId = ?',
      whereArgs: [load.id],
    );
  }

  Future<int> deleteAll() async {
    Database db = await instance.getdatabase;
    return await db.delete(
      dbtable,
      // where: '$colId = ?',
      // whereArgs: [box.id],
    );
  }

  Future<int> deleteAllLoading() async {
    Database db = await instance.getdatabase;
    return await db.delete(
      dbloading,
      // where: '$colId = ?',
      // whereArgs: [box.id],
    );
  }

  Future<int> updateCtn(Ctn ctn) async {
    Database db = await instance.getdatabase;
    return await db.update(
      dbctn,
      ctn.toMap(),
      where: '$colId = ?',
      whereArgs: [ctn.id],
    );
  }

  Future<int> deleteAllCtn() async {
    Database db = await instance.getdatabase;
    return await db.delete(
      dbctn,
    );
  }

  Future<int> deleteAllScan() async {
    Database db = await instance.getdatabase;
    return await db.delete(
      dbscan,
    );
  }

  Future close() async => instance.getdatabase.then((value) => value.close());
}
