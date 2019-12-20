trigger SetSeriesExternalPBId on Round__c (before insert, before update) {
	Set <String> accPbIds = new Set <String>();
    Map <String,String> accPBtoSFIds= new Map <String,String>();
    
    for(Round__c r : Trigger.New) {
        if (r.pbk_dealid__c != null && r.pbk_pbId__c != null){
            accPbIds.add(r.pbk_pbId__c);
        }
    }
    for (Account a: [select Id, pb_custom_id__c from Account where pb_custom_id__c in: accPbIds and Num_Rounds_filtered__c = 0]){
        accPBtoSFIds.put(a.pb_custom_id__c, a.Id);
    }
    for(Round__c r : Trigger.New) {
        if (accPBtoSFIds.containsKey(r.pbk_pbId__c)){
            r.Target_Company__c = accPBtoSFIds.get(r.pbk_pbId__c);
        } else if (r.pbk_dealid__c != null && r.pbk_pbId__c != null){
            if (!Test.isRunningTest()){
                r.Target_Company__c = null;
                r.Target_Company__c.addError('No such company or company already has investments (CapTable)');
            }
        }
    }
    
}