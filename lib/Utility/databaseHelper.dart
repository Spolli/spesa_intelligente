import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:spesa_intelligente/Model/Spese.dart';

final String tableSpese = "spese";
final String columnId = "id";
final String columnDtSpesa = "dt_spesa";
final String columnDescr = "descrizione_spesa";
final String columnCosto = "costo_spesa";

class DatabaseHelper {
  static final DatabaseHelper _instance = new DatabaseHelper.internal();
  factory DatabaseHelper() => _instance;

  static Database _db;

  Future<Database> get db async {
    if (_db != null) {
      return _db;
    }
    _db = await initDb();
    return _db;
  }

  DatabaseHelper.internal();

  initDb() async {
    Directory documentDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentDirectory.path, "lib/Assets/contoSpese.db");
    print("Path: " + path);
    var ourDb = await openDatabase(path, version: 1, onCreate: _onCreate);
    return ourDb;
  }

  void _onCreate(Database db, int version) async {
    await db.execute("""
            create table $tableSpese ( 
              $columnId integer primary key autoincrement, 
              $columnDtSpesa TEXT not null,
              $columnCosto NUMERIC not null,
              $columnDescr TEXT not null)
            """);
    print("Table is created");
  }

//insertion
  Future<int> insert(Spesa spesa) async {
    var dbClient = await db;
    int res = await dbClient.insert(tableSpese, spesa.toMap());
    return res;
  }

  //deletion
  Future<int> delete(int id) async {
    var dbClient = await db;
    int res = await dbClient.delete(tableSpese, where: "$columnId = ?", whereArgs: [id]);
    return res;
  }

  Future<Spesa> getRecordById(int id) async {
    List<Map> maps = await _db.query(tableSpese,
        columns: [columnId, columnDtSpesa, columnCosto, columnDescr],
        where: "$columnId = ?",
        whereArgs: [id]);
    if (maps.length > 0) {
      return new Spesa.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Spesa>> getAll() async {
    //print(await _db.rawQuery("select * from spese"));
    print(await _db.query(tableSpese, columns: [columnId, columnDtSpesa, columnCosto, columnDescr]));
    return null;
    /*
    List<Map<String, dynamic>> maps = await _db.query(tableSpese, columns: [columnId, columnDtSpesa, columnCosto, columnDescr]);
    if (maps.length > 0) {
      print(maps);
      return maps;
    }
    return null;
    */
  }
  /*
  Future<int> update(Spesa spesa) async {
    return await _db.update(tableSpese, spesa.toMap(),
        where: "$columnId = ?", whereArgs: [spesa._id]);
  }
  */
  Future<Null> close() async => _db.close();
}