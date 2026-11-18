import 'dart:convert';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
class LocalDatabase {
 LocalDatabase({this.databasePath});
 final String? databasePath;
 Database? _db;
 Future<void> open() async {if(_db!=null)return;final root=await getDatabasesPath();_db=await openDatabase(databasePath??p.join(root,'pawpal.db'),version:2,onCreate:(db,v)=>_create(db),onUpgrade:(db,old,v)async{if(old<2){await db.execute('CREATE TABLE IF NOT EXISTS preferences (key TEXT PRIMARY KEY, value TEXT NOT NULL)');}});}
 Future<void> _create(Database db)async{for(final table in ['pets','reminders','care_logs','pet_records','feeding_entries','activity_entries','contacts','checklists','favorites','collections','reading_history']){await db.execute('CREATE TABLE $table (id TEXT PRIMARY KEY, pet_id TEXT, payload TEXT NOT NULL, updated_at TEXT NOT NULL)');}await db.execute('CREATE INDEX idx_reminders_pet ON reminders(pet_id)');await db.execute('CREATE INDEX idx_logs_pet ON care_logs(pet_id)');await db.execute('CREATE TABLE preferences (key TEXT PRIMARY KEY, value TEXT NOT NULL)');}
 Database get db {final value=_db;if(value==null)throw StateError('Database has not been opened');return value;}
 Future<void> put(String table,String id,String? petId,String payload)async{await db.insert(table,{'id':id,'pet_id':petId,'payload':payload,'updated_at':DateTime.now().toIso8601String()},conflictAlgorithm:ConflictAlgorithm.replace);}
 Future<List<Map<String,Object?>>> all(String table,{String? petId})=>db.query(table,where:petId==null?null:'pet_id = ?',whereArgs:petId==null?null:[petId],orderBy:'updated_at DESC');
 Future<void> restoreAll(Map<String,List<Map<String,dynamic>>> records,{required bool replaceExisting})async{await db.transaction((txn)async{for(final table in ['pets','reminders','care_logs','pet_records','feeding_entries','activity_entries','contacts','checklists','favorites','collections','reading_history']){if(replaceExisting)await txn.delete(table);for(final value in records[table]??const <Map<String,dynamic>>[]){await txn.insert(table,{'id':value['id'],'pet_id':value['petId'],'payload':jsonEncode(value),'updated_at':DateTime.now().toIso8601String()},conflictAlgorithm:replaceExisting?ConflictAlgorithm.replace:ConflictAlgorithm.ignore);}}});}
 Future<void> remove(String table,String id)async{await db.delete(table,where:'id = ?',whereArgs:[id]);}
 Future<void> removePet(String petId)async{await db.transaction((txn)async{for(final t in ['reminders','care_logs','pet_records','feeding_entries','activity_entries','contacts','checklists']){await txn.delete(t,where:'pet_id = ?',whereArgs:[petId]);}await txn.delete('pets',where:'id = ?',whereArgs:[petId]);});}
 Future<String?> getPreference(String key)async{final rows=await db.query('preferences',columns:['value'],where:'key = ?',whereArgs:[key],limit:1);return rows.isEmpty?null:rows.first['value'] as String;}
 Future<void> setPreference(String key,String value)async{await db.insert('preferences',{'key':key,'value':value},conflictAlgorithm:ConflictAlgorithm.replace);}
 Future<void> close()async{await _db?.close();_db=null;}
}
