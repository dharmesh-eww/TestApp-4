import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import '../data/local_database.dart';
import '../data/paw_repository.dart';
import '../domain/pet.dart';
final databaseProvider=Provider<LocalDatabase>((ref)=>throw UnimplementedError());
final appControllerProvider=ChangeNotifierProvider<AppController>((ref){final c=AppController(PawRepository(ref.watch(databaseProvider)));ref.onDispose(c.dispose);return c;});
class AppController extends ChangeNotifier {
 AppController(this.repository){refresh();}
 final PawRepository repository;
 final Map<String,List<Map<String,dynamic>>> _data={};
 String? selectedPetId;String weightUnit='lb',distanceUnit='mi',temperatureUnit='°F',locale='en-US';
 bool onboardingComplete=false,quietHoursEnabled=false;String quietStart='22:00',quietEnd='07:00';
 List<Pet> get pets=>(_data['pets']??[]).map((e)=>Pet.fromMap(Map<String,Object?>.from(e))).toList();
 Pet? get selectedPet {for(final p in pets){if(p.id==selectedPetId&&!p.archived)return p;}return pets.where((p)=>!p.archived).firstOrNull;}
 List<Map<String,dynamic>> items(String table)=>List.unmodifiable(_data[table]??const []);
 Future<void> refresh()async{for(final t in PawRepository.tables){_data[t]=await repository.list(t);}selectedPetId=await repository.db.getPreference('selected_pet');weightUnit=await repository.db.getPreference('weight_unit')??'lb';distanceUnit=await repository.db.getPreference('distance_unit')??'mi';temperatureUnit=await repository.db.getPreference('temperature_unit')??'°F';onboardingComplete=(await repository.db.getPreference('onboarding_complete'))=='1';notifyListeners();}
 Future<void> save(String table,Map<String,Object?> value)async{await repository.save(table,value);await refresh();}
 Future<void> delete(String table,String id)async{await repository.delete(table,id);await refresh();}
 Future<void> selectPet(String? id)async{selectedPetId=id;if(id==null){notifyListeners();return;}await repository.db.setPreference('selected_pet',id);notifyListeners();}
 Future<void> saveUnits({String? weight,String? distance,String? temperature})async{if(weight!=null)weightUnit=weight;if(distance!=null)distanceUnit=distance;if(temperature!=null)temperatureUnit=temperature;await repository.db.setPreference('weight_unit',weightUnit);await repository.db.setPreference('distance_unit',distanceUnit);await repository.db.setPreference('temperature_unit',temperatureUnit);notifyListeners();}
 Future<void> completeOnboarding()async{onboardingComplete=true;await repository.db.setPreference('onboarding_complete','1');notifyListeners();}
 Future<String> exportData()=>repository.exportAll();\n Future<Map<String,List<Map<String,dynamic>>>> validateBackup(String source)=>repository.validateImport(source);\n Future<void> restoreBackup(Map<String,List<Map<String,dynamic>>> data,{required bool replaceExisting})async{await repository.restore(data,replaceExisting:replaceExisting);await refresh();}
}
