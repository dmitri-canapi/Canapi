trigger SetExternalPitchBookId on Account (before insert, before update) {

    if (Trigger.isUpdate){
        for(Account a : Trigger.New) {
            Account oldAcc = Trigger.oldMap.get(a.Id);
            if (a.pbk__pbId__c != null &&  oldAcc.pbk__pbId__c != a.pbk__pbId__c){
                a.pb_custom_id__c = a.pbk__pbId__c;
            }
            if(a.Updating_By_Skyvia__c == true && oldAcc.RecordTypeId != a.RecordTypeId){
                a.RecordTypeId = oldAcc.RecordTypeId;
                a.Updating_By_Skyvia__c = false;
            }
        }
    }
    if (Trigger.isInsert){
        for(Account a : Trigger.New) {
            a.Updating_By_Skyvia__c = false;
            if (a.pbk__pbId__c != null){
                a.pb_custom_id__c = a.pbk__pbId__c;
            }
            if (a.pb_custom_id__c != null){
                a.pbk__pbId__c = a.pb_custom_id__c;
            }
        }
    }
 
}