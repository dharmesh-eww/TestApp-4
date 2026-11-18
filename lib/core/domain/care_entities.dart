class Reminder {
 const Reminder({required this.id,required this.petId,required this.title,required this.category,required this.dueAt,this.repeat='once',this.weekdays=const [],this.intervalDays=1,this.monthEndPolicy='last_day',this.note='',this.enabled=true,this.completed=false,this.snoozedUntil});
 final String id,petId,title,category,repeat,monthEndPolicy,note;final DateTime dueAt;final List<int> weekdays;final int intervalDays;final bool enabled,completed;final DateTime? snoozedUntil;
 Map<String,Object?> toMap()=>{'id':id,'petId':petId,'title':title,'category':category,'dueAt':dueAt.toIso8601String(),'repeat':repeat,'weekdays':weekdays.join(','),'intervalDays':intervalDays,'monthEndPolicy':monthEndPolicy,'note':note,'enabled':enabled?1:0,'completed':completed?1:0,'snoozedUntil':snoozedUntil?.toIso8601String()};
 factory Reminder.fromMap(Map<String,Object?> m)=>Reminder(id:m['id'] as String,petId:m['petId'] as String,title:m['title'] as String,category:m['category'] as String,dueAt:DateTime.parse(m['dueAt'] as String),repeat:m['repeat'] as String? ?? 'once',weekdays:(m['weekdays'] as String? ?? '').split(',').where((e)=>e.isNotEmpty).map(int.parse).toList(),intervalDays:m['intervalDays'] as int? ?? 1,monthEndPolicy:m['monthEndPolicy'] as String? ?? 'last_day',note:m['note'] as String? ?? '',enabled:m['enabled']==1,completed:m['completed']==1,snoozedUntil:m['snoozedUntil']==null?null:DateTime.parse(m['snoozedUntil'] as String));
}
class CareLog {
 const CareLog({required this.id,required this.petId,required this.type,required this.title,required this.at,this.value,this.unit='',this.note='',this.attachmentPath=''});
 final String id,petId,type,title,unit,note,attachmentPath;final DateTime at;final double? value;
 Map<String,Object?> toMap()=>{'id':id,'petId':petId,'type':type,'title':title,'at':at.toIso8601String(),'value':value,'unit':unit,'note':note,'attachmentPath':attachmentPath};
 factory CareLog.fromMap(Map<String,Object?> m)=>CareLog(id:m['id'] as String,petId:m['petId'] as String,type:m['type'] as String,title:m['title'] as String,at:DateTime.parse(m['at'] as String),value:(m['value'] as num?)?.toDouble(),unit:m['unit'] as String? ?? '',note:m['note'] as String? ?? '',attachmentPath:m['attachmentPath'] as String? ?? '');
}
class PetRecord {
 const PetRecord({required this.id,required this.petId,required this.type,required this.title,required this.eventDate,this.followUpDate,this.clinic='',this.notes='',this.attachmentPath=''});
 final String id,petId,type,title,clinic,notes,attachmentPath;final DateTime eventDate;final DateTime? followUpDate;
 Map<String,Object?> toMap()=>{'id':id,'petId':petId,'type':type,'title':title,'eventDate':eventDate.toIso8601String(),'followUpDate':followUpDate?.toIso8601String(),'clinic':clinic,'notes':notes,'attachmentPath':attachmentPath};
 factory PetRecord.fromMap(Map<String,Object?> m)=>PetRecord(id:m['id'] as String,petId:m['petId'] as String,type:m['type'] as String,title:m['title'] as String,eventDate:DateTime.parse(m['eventDate'] as String),followUpDate:m['followUpDate']==null?null:DateTime.parse(m['followUpDate'] as String),clinic:m['clinic'] as String? ?? '',notes:m['notes'] as String? ?? '',attachmentPath:m['attachmentPath'] as String? ?? '');
}
