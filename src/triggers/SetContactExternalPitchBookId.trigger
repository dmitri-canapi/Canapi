trigger SetContactExternalPitchBookId on Contact (before insert, before update) {

    if (Trigger.isUpdate){
        for(Contact c : Trigger.New) {
            Contact oldCon = Trigger.oldMap.get(c.Id);
            if (c.pbk__pbId__c != null &&  oldCon.pbk__pbId__c != c.pbk__pbId__c){
                c.PrimaryContactPBId__c = c.pbk__pbId__c;
            }
        }
    }
    if (Trigger.isInsert){
        for(Contact c : Trigger.New) {
            if (c.pbk__pbId__c != null){
                c.PrimaryContactPBId__c = c.pbk__pbId__c;
            }
            if (c.PrimaryContactPBId__c != null){
                c.pbk__pbId__c = c.PrimaryContactPBId__c;
            }
        }
    }
 
}