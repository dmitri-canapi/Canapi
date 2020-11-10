global class UpdateEventAccount implements Schedulable {
    global void execute(SchedulableContext sc) {
        Account a = [select id from Account where name = '-' limit 1];
        List <Event> evToUpdate = [select id from event where WhoId!=null and (WhatId = null or WhatId =:a.Id) limit 10000];
        update evToUpdate;
    }
}