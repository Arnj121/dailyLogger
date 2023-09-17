import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
class DatabaseHelper{
  static final _databaseName = "MyDatabase.db";
  static final _databaseVersion = 1;

  String table='entries';
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;
    _database = await _initDatabase();
    return _database;
  }

  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(path,
        version: _databaseVersion,
        onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''CREATE TABLE $table (
                id INTEGER PRIMARY KEY,
                entry TEXT,
                date text,
                datetime text
              )''');
    await db.execute('''CREATE TABLE date (
                id INTEGER PRIMARY KEY,
                date text,
                description text,
                productive int,
                bookmarked int,
                planned int
              )''');
    await db.execute('''CREATE TABLE planner (
                id INTEGER PRIMARY KEY,
                entry text,
                date text,
                accomplished int
              )''');
  }

  Future<dynamic> getTodayEntries(int day,int year,int month)async{
    Database db = await database;
    dynamic result = await db.query('entries',where: 'date like ? order by datetime desc',whereArgs: ['${year.toString()}%$month%$day']);
    return result;
  }
  Future<dynamic> getTodayStatus(int day,int year,int month) async{
    Database db = await database;
    dynamic result = await db.query('date',where: 'date like ?',whereArgs: ['${year.toString()}%$month%$day']);
    return result;
  }
  Future<dynamic> getBookmarked(String order)async{
    Database db = await database;
    return await db.query('date',where: 'bookmarked=1 order by date $order');
  }
  Future<dynamic> getProductive(String order)async{
    Database db = await database;
    return await db.query('date',where:'productive=1 order by date $order');
  }
  Future<dynamic> getLogs(int id)async{
    Database db = await database;
    dynamic date = await db.query('date',where: 'id=$id');
    date = date[0]['date'].toString();
    return await db.query('entries',where: 'date=\'$date\' order by date asc');
  }
  Future<dynamic> getPlans(String date)async{
    Database db = await database;
    return await db.query('planner',where: 'date=\'$date\'');
  }
  Future<dynamic> getPlanned()async{
    Database db = await database;
    return await db.query('date',where: 'planned=1 order by date asc');
  }
  Future<dynamic> getHistory()async{
    Database db = await database;
    return await db.query('date',where: '1=1 order by date desc');
  }
  Future<String> getDescript(int id)async{
    Database db = await database;
    dynamic temp = await db.query('date',where: 'id=$id');
    return temp[0]['description'];
  }

  Future<void> addEntry(int id,String date,String entry)async{
    Database db = await database;
    await db.insert(table,{'id':id,'entry':entry,'date':date.substring(0,10),'datetime':date});
  }
  Future<void> addDateStatus(int id,String date,int planned)async{
    Database db = await database;
    await db.insert('date', {'id':id,'date':date.substring(0,10),'productive':0,'bookmarked':0,'planned':planned,'description':''});
  }
  Future<void> addplan(List tasks,String date)async{
    Database db = await database;
    date = date.substring(0,10);
    tasks.forEach((e)async{
      await db.insert('planner',e);
    });
  }
  Future<void> saveDescription(int id,String value)async{
    Database db = await database;
    await db.update('date', {'description':value},where: 'id=$id');
  }

  Future<void> bookmark(int id,int value)async{
    Database db = await database;
    await db.update('date', {'bookmarked':value},where: 'id=$id');
  }
  Future<void> productive(int id,int value)async{
    Database db = await database;
    await db.update('date', {'productive':value},where: 'id=$id');
  }
  Future<void> planaccomp(int id,int value)async{
    Database db = await database;
    await db.update('planner', {'accomplished':value},where: 'id=$id');
  }
  Future<void> togglePlan(String date,int value)async{
    Database db = await database;
    await db.update('date',{'planned':value},where: 'date=\'$date\'');
  }


  Future<void> deleteplan(int id)async{
    Database db = await database;
    await db.delete('planner' ,where: 'id=$id');
  }

  Future<void> clear()async{
    Database db = await database;
    await db.delete(table,where: '1=1');
    await db.delete('date',where: '1=1');
    await db.delete('planner',where: '1=1');
  }


}