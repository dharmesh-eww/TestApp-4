import 'dart:convert';
import 'local_database.dart';
class PawRepository {
 PawRepository(this.db);final LocalDatabase db;
 static const tables=['pets','reminders','care_logs','pet_records','feeding_entries','activity_entries','contacts','checklists','favorites','collections','reading_history'];
 Future<void> save(String table,Map<String,Object?> value)async{if(!tables.contains(table))throw ArgumentError('Unsupported table');await db.put(table,value['id'] as String,value['petId'] as String?,jsonEncode(value));}
 Future<List<Map<String,dynamic>>> list(String table,{String? petId})async{if(!tables.contains(table))throw ArgumentError('Unsupported table');final rows=await db.all(table,petId:petId);return rows.map((r)=>Map<String,dynamic>.from(jsonDecode(r['payload'] as String) as Map)).toList();}
 Future<void> delete(String table,String id)=>db.remove(table,id);
 Future<void> deletePet(String id)=>db.removePet(id);
 Future<String> exportAll()async{final data=<String,dynamic>{'schema_version':2,'app':'PawPal','exported_at':DateTime.now().toUtc().toIso8601String()};for(final table in tables){data[table]=await list(table);}return const JsonEncoder.withIndent('  ').convert(data);}
}
