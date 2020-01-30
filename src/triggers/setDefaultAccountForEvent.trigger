trigger setDefaultAccountForEvent on Event (after insert, after update) {
    Account a = [select id from Account where name = '-' limit 1];
    List <Event> evToUpdate = new  List <Event>();
    Set <Id> contIds = new Set <Id>();
    Map <Id,Id> contactAccountIdsMap = new  Map <Id,Id> ();
    
    for (Event ev : Trigger.new) {
        if ((ev.WhoId!= null && ev.WhoId.getSObjectType().getDescribe().getName()=='Contact') && ev.WhatId == null){
            contIds.add(ev.WhoId);
        }
    }
    
    for (Contact c: [select id, AccountId from Contact where id in: contIds]){
        contactAccountIdsMap.put(c.Id, c.AccountId);
    }
    
    for (Event ev : Trigger.new) {
        if (ev.WhoId == null && ev.WhatId == null){
            Event e = new Event();
            e.WhatId = a.Id;
            e.Id = ev.Id;
            evToUpdate.add(e);
        } else if ((ev.WhoId!= null && ev.WhoId.getSObjectType().getDescribe().getName()=='Contact') && (ev.WhatId == null || ev.WhatId == a.Id)){
            Event e = new Event();
            e.WhatId = contactAccountIdsMap.get(ev.WhoId);
            e.Id = ev.Id;
            evToUpdate.add(e);
        }
    }
    update evToUpdate;
}