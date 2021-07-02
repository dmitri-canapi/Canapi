trigger FunctionTrigger on Function__c (after insert) {
    for(Function__c f: Trigger.new) {
        if (f.Function_Status__c == 'Planned'){
            ZoomApis.createMeetingWapper newWapper = new ZoomApis.createMeetingWapper();
            newWapper.topic = f.Name;
            newWapper.agenda = f.Function_Description__c;
            newWapper.type = 2;
            newWapper.start_time = f.Begin_Date__c.format('yyyy-MM-dd\'T\'HH:mm:ss:Z'); //'2021-06-16T16:54:14Z'
            newWapper.duration = (f.End_Date__c.getTime() - f.Begin_Date__c.getTime()) /1000 / 60;
            newWapper.timezone = 'America/New_York';
            newWapper.password = String.ValueOf(Math.round((Math.random() * (900000) + 100000)));
            newWapper.settings = new ZoomApis.Settings();
            newWapper.settings.registration_type = 1;
            newWapper.settings.approval_type = 0; // 0- auto approve, 1 - manual
            string jsonString = JSON.serialize(newWapper);            
            FunctionTriggerHandler.createMeeting(f.Id,newWapper.password, jsonString);
        }
    }
}