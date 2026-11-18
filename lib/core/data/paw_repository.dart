import 'dart:convert';
import 'local_database.dart';

class PawRepository {
  PawRepository(this.db);
  final LocalDatabase db;
  static const tables = ['pets','reminders','care_logs','pet_records','feeding_entries','activity_entries','contacts','checklists','favorites','collections','reading_history'];

  Future<void> save(String table, Map<String,Object?> value) async {
    if (!tables.contains(table)) throw ArgumentError('Unsupported table');
    await db.put(table, value['id'] as String, value['petId'] as String?, jsonEncode(value));
  }

  Future<List<Map<String,dynamic>>> list(String table,{String? petId}) async {
    if (!tables.contains(table)) throw ArgumentError('Unsupported table');
    final rows = await db.all(table, petId: petId);
    return rows.map((r)=>Map<String,dynamic>.from(jsonDecode(r['payload'] as String) as Map)).toList();
  }

  Future<void> delete(String table,String id) => db.remove(table,id);
  Future<void> deletePet(String id) => db.removePet(id);

  int _depth(Object? value) {
    if (value is Map) {
      if (value.isEmpty) return 1;
      return 1 + value.values.map(_depth).reduce((a,b)=>a>b?a:b);
    }
    if (value is List) {
      if (value.isEmpty) return 1;
      return 1 + value.map(_depth).reduce((a,b)=>a>b?a:b);
    }
    return 0;
  }

  Future<Map<String,List<Map<String,dynamic>>>> validateImport(String source) async {
    if (utf8.encode(source).length > 10*1024*1024) throw FormatException('Backup is larger than 10 MB.');
    dynamic decoded;
    try { decoded=jsonDecode(source); } catch (_) { throw FormatException('Backup JSON is invalid.'); }
    if (decoded is! Map || _depth(decoded)>32) throw FormatException('Backup structure is invalid or too deeply nested.');
    final root=Map<String,dynamic>.from(decoded);
    final version=root['schema_version']??root['schemaVersion'];
    if (version==1) {
      final legacyPets=(root['pets'] as List? ?? const []).whereType<Map>().map((e)=>Map<String,dynamic>.from(e)).toList();
      final petIds=legacyPets.map((e)=>e['id']?.toString()??'').toSet();
      root['pets']=legacyPets.map((p)=>{'id':p['id'],'name':p['name']??'Pet','species':p['species']??'Dog','breed':p['breed']??'','birthDate':p['birthday']??'','ageEstimated':0,'sex':'','weightValue':double.tryParse(p['weight']?.toString()??''),'weightUnit':root['units']=='Metric'?'kg':'lb','photoPath':'','adoptionDate':'','notes':p['notes']??'','vetName':'','vetPhone':'','archived':0}).toList();
      root['reminders']=(root['tasks'] as List? ?? const []).whereType<Map>().map((t){final m=Map<String,dynamic>.from(t);if(!petIds.contains(m['petId']?.toString()))return null;final repeat=(m['repeat']?.toString()??'once').toLowerCase();return {'id':m['id'],'petId':m['petId'],'title':m['title']??'Care task','category':m['type']??'Custom','dueAt':m['due']??DateTime.now().toIso8601String(),'repeat':repeat,'weekdays':'','intervalDays':1,'monthEndPolicy':'last_day','note':m['note']??'','enabled':1,'completed':m['done']==true?1:0,'snoozedUntil':null};}).whereType<Map<String,dynamic>>().toList();
      root['care_logs']=(root['logs'] as List? ?? const []).whereType<Map>().map((e){final m=Map<String,dynamic>.from(e);if(!petIds.contains(m['petId']?.toString()))return null;return {'id':m['id'],'petId':m['petId'],'type':m['type']??'Custom','title':m['title']??'Care note','at':m['at']??DateTime.now().toIso8601String(),'value':null,'unit':'','note':m['detail']??'','attachmentPath':''};}).whereType<Map<String,dynamic>>().toList();
      for(final table in ['pet_records','feeding_entries','activity_entries','contacts','checklists','favorites','collections','reading_history']){root[table]=root[table]??[];}
      root['preferences']={'selected_pet':root['selected']?.toString()??'','weight_unit':root['units']=='Metric'?'kg':'lb','distance_unit':'mi','temperature_unit':'°F','legacy_preferences_migrated':'1'};
      root['schema_version']=2;
    }
    if(root['schema_version']!=2)throw FormatException('Unsupported backup version.');
    final result=<String,List<Map<String,dynamic>>>{};
    final petIds=<String>{};
    var total=0;
    for(final table in tables){
      final raw=root[table]??const [];
      if(raw is! List||raw.length>20000)throw FormatException('Invalid $table collection.');
      total+=raw.length;if(total>50000)throw FormatException('Backup contains too many records.');
      final values=<Map<String,dynamic>>[];final ids=<String>{};
      for(final item in raw){
        if(item is! Map||item['id'] is! String||(item['id'] as String).isEmpty)throw FormatException('Invalid record in $table.');
        final value=Map<String,dynamic>.from(item);
        if(value.containsKey('photoPath'))value['photoPath']='';
        if(value.containsKey('attachmentPath'))value['attachmentPath']='';
        if(!ids.add(value['id'] as String))throw FormatException('Duplicate ID in $table.');
        values.add(value);
      }
      result[table]=values;
      if(table=='pets')petIds.addAll(values.map((e)=>e['id'] as String));
    }
    for(final table in ['reminders','care_logs','pet_records','feeding_entries','activity_entries','contacts','checklists']){
      for(final item in result[table]??const []){
        final petId=item['petId'];
        if(petId!=null&&(petId is! String||!petIds.contains(petId)))throw FormatException('A $table entry references a missing pet.');
        if(['reminders','care_logs','pet_records','feeding_entries','activity_entries'].contains(table)&&petId==null)throw FormatException('A $table entry must reference a pet.');
      }
    }
    final rawPreferences=root['preferences']??const {};
    if(rawPreferences is! Map)throw FormatException('Invalid preferences section.');
    const allowed={'selected_pet','weight_unit','distance_unit','temperature_unit','locale','onboarding_complete','interest_dog','interest_cat','legacy_preferences_migrated','quiet_hours_enabled','quiet_hours_start','quiet_hours_end'};
    final preferences=<String,dynamic>{};
    for(final entry in rawPreferences.entries){
      if(entry.key is! String||!allowed.contains(entry.key)||entry.value is! String)throw FormatException('Unsupported preference entry.');
      preferences[entry.key as String]=entry.value;
    }
    final selected=preferences['selected_pet'];
    if(selected is String&&selected.isNotEmpty&&!petIds.contains(selected))throw FormatException('Selected pet is not present in this backup.');
    result['__preferences__']=[preferences];
    return result;
  }

  Future<void> restore(Map<String,List<Map<String,dynamic>>> records,{required bool replaceExisting}) async {
    await db.restoreAll(records,replaceExisting:replaceExisting);
  }

  Future<String> exportAll() async {
    final data=<String,dynamic>{'schema_version':2,'app':'PawPal','exported_at':DateTime.now().toUtc().toIso8601String()};
    for(final table in tables){
      final rows=await list(table);
      for(final row in rows){if(row.containsKey('photoPath'))row['photoPath']='';if(row.containsKey('attachmentPath'))row['attachmentPath']='';}
      data[table]=rows;
    }
    const keys=['selected_pet','weight_unit','distance_unit','temperature_unit','locale','onboarding_complete','interest_dog','interest_cat','legacy_preferences_migrated','quiet_hours_enabled','quiet_hours_start','quiet_hours_end'];
    final preferences=<String,String>{};
    for(final key in keys){final value=await db.getPreference(key);if(value!=null)preferences[key]=value;}
    data['preferences']=preferences;
    return const JsonEncoder.withIndent('  ').convert(data);
  }
}
