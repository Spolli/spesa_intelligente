import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:spesa_intelligente/Model/Spese.dart';
import 'package:sqflite/sqflite.dart';

final String tableSpese = "spese";
final String columnId = "id";
final String columnDtSpesa = "dt_spesa";
final String columnDescr = "descrizione_spesa";
final String columnCosto = "costo_spesa";
final String columnImg = "img";

class DBHelper {
  static final DBHelper _instance = new DBHelper.internal();

  factory DBHelper() => _instance;

  static Database _db;

  Future<Database> get db async {
    if (_db != null) return _db;
    _db = await initDb();
    return _db;
  }

  DBHelper.internal();

  initDb() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "contoSpese.db");

    if (FileSystemEntity.typeSync(path) == FileSystemEntityType.NOT_FOUND) {
      // Load database from asset and copy
      ByteData data = await rootBundle.load(
          join('lib/Assets', 'contoSpese.db'));
      List<int> bytes = data.buffer.asUint8List(
          data.offsetInBytes, data.lengthInBytes);

      // Save copied asset to documents
      await new File(path).writeAsBytes(bytes);
    }
    var theDb = await openDatabase(path, version: 1, onCreate: _onCreate);
    return theDb;
  }

  void _onCreate(Database db, int version) async {
    // When creating the db, create the table
    await db.execute(
        """CREATE TABLE $tableSpese ( $columnId integer PRIMARY KEY AUTOINCREMENT, $columnDtSpesa TEXT NOT NULL, $columnCosto NUMERIC NOT NULL, $columnDescr TEXT, $columnImg BLOB )""");
  }

  Future<int> insert(Spesa spesa) async {
    var dbClient = await db;
    int res = await dbClient.insert(tableSpese, spesa.toMap());
    return res;
  }

  Future<List<Spesa>> getAll() async {
    var dbClient = await db;
    //List<Map> list = await dbClient.execute("SELECT * FROM $tableSpese ORDER BY $columnDtSpesa DESC");
    List<Map> list = await dbClient.rawQuery(
        'SELECT * FROM $tableSpese ORDER BY $columnDtSpesa DESC');
    List<Spesa> employees = new List();
    for (int i = 0; i < list.length; i++) {
      var spesa = new Spesa(
          list[i][columnDtSpesa], list[i][columnCosto], list[i][columnDescr]);
      spesa.setSpesaId(list[i][columnId]);
      employees.add(spesa);
    }
    print(employees.length);
    return employees;
  }

  Future<int> delete(int id) async {
    var dbClient = await db;
    //int res = await dbClient.delete(tableSpese, where: "id = ?", whereArgs: <int>[id]);
    int res = await dbClient.rawDelete(
        'DELETE FROM $tableSpese WHERE id = ?', [id]);
    return res;
  }

  Future<bool> update(Spesa spesa) async {
    var dbClient = await db;
    int res = await dbClient.update(tableSpese, spesa.toMap(),
        where: "id = ?", whereArgs: <int>[spesa.id]);
    return res > 0 ? true : false;
  }

  Future<Null> close() async {
    var dbClient = await db;
    dbClient.close();
  }

  Future<Null> deleteAll() async {
    var dbClient = await db;
    dbClient.rawDelete("DELETE FROM $tableSpese");
  }

  Future<double> spesaTot() async {
    var dbClient = await db;
    Future<List<Map<String, dynamic>>> sum = dbClient.rawQuery("SELECT SUM($columnCosto) as sum FROM $tableSpese");
    sum.then((value){
      return value[0]['sum'];
    }).catchError((error){
      print(error.toString());
    });
    return null;
  }
}