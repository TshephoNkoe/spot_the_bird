import 'dart:io';

import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {

  static Database? _database;

  static const String _databaseName = "MyDatabase.db";

  static const String _tableName = "my_table";

  static const String _columnId = "id";

  static const String birdName = "birdName";
  static const String birdDescription = "birdDescription";
  static const String picture = "picture";
  static const String latitude = "latitude";
  static const String longitude = "longitude";



  static const int _databaseVersion = 1;


  // Creates singleton
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance  = DatabaseHelper._privateConstructor();

  Future<Database?> get database async {

    if (_database != null) return _database;

    _database = await _initDatabase();

    return _database;

  }

  _initDatabase() async {

    Directory docDirectory = await getApplicationDocumentsDirectory();

    String path = "$docDirectory$_databaseName";

    return await openDatabase(path, version: _databaseVersion, onCreate: (Database db, int version) async {
      await db.execute(
        '''
        CREATE TABLE $_tableName (
        $_columnId INTEGER PRIMARY KEY, 
        $birdName TEXT NOT NULL, 
        $birdDescription TEXT NOT NULL,
        $picture BLOB NOT NULL, 
        $latitude REAL NOT NULL,
        $longitude REAL NOT NULL
        ) 
        '''
      );
    });
  }

  // Insert method
 Future<int> insert(Map<String, dynamic> row) async {

    Database? db = await instance.database;

    return await db!.insert(_tableName, row);

 }

 Future<List<Map<String, dynamic>>> queryAllRows() async {
    Database? db = await instance.database;
    return await db!.query(_tableName);
 }

 Future<int> delete(int id) async {

    Database? db = await instance.database;

    return await db!.delete(_tableName, where: "$_columnId = ?", whereArgs: [id]);

 }


}
