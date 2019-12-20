trigger SetInvetsmentsExtPBId on Investment__c (before insert, before update) {
	Set <String> roundPbIds = new Set <String>();
    Map <String,String> roundPBtoSFIds= new Map <String,String>();
    
    for(Investment__c i : Trigger.New) {
        if (i.pbk_dealid__c != null && i.pbk_pbId__c != null){
            roundPbIds.add(i.pbk_dealid__c);
        }
    }
    for (Round__c r: [select Id, pbk_dealid__c from Round__c where pbk_dealid__c in: roundPbIds]){
        roundPBtoSFIds.put(r.pbk_dealid__c, r.Id);
    }
    for(Investment__c i : Trigger.New) {
        if (roundPBtoSFIds.containsKey(i.pbk_dealid__c)){
            i.Round__c = roundPBtoSFIds.get(i.pbk_dealid__c);
        } else if (i.pbk_dealid__c != null && i.pbk_pbId__c != null){
            if (!Test.isRunningTest()){
                i.Round__c = null;
            	i.Round__c.addError('No such round.');
            }
        }
    }
    
}