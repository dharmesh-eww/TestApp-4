class ReminderRecurrence {
 static DateTime? next(DateTime current,String rule,{int intervalDays=1,List<int> weekdays=const [],String monthEndPolicy='last_day'}) {
  switch(rule){
   case 'daily':return current.add(const Duration(days:1));
   case 'weekly':return current.add(const Duration(days:7));
   case 'interval':return current.add(Duration(days:intervalDays<1?1:intervalDays));
   case 'weekdays':final days=weekdays.isEmpty?[current.weekday]:weekdays;for(var i=1;i<=7;i++){final candidate=current.add(Duration(days:i));if(days.contains(candidate.weekday))return candidate;}return current.add(const Duration(days:7));
   case 'monthly':final first=DateTime(current.year,current.month+1,1);final last=DateTime(first.year,first.month+1,0).day;final day=monthEndPolicy=='skip'&&current.day>last?null:(current.day>last?last:current.day);return day==null?DateTime(first.year,first.month+1,current.day):DateTime(first.year,first.month,day,current.hour,current.minute);
   default:return null;
  }
 }
}
