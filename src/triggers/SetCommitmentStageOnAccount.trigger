trigger SetCommitmentStageOnAccount on Commitment__c (after update, after insert) {
	Map <String,String> accCommStageMap = new Map <String,String>();
    
    for (Commitment__c comm : Trigger.new) {
        if (comm.Commitment_Stage__c!=null && comm.Account__c!=null) {
            accCommStageMap.put(comm.Account__c,comm.Commitment_Stage__c);
        }
    }
    if (!accCommStageMap.isEmpty()){
        List <Account> accs = new List <Account>();
        accs = [select id, Last_Commitment_Stage__c, Owner.Account_Id__c from account where id in: accCommStageMap.keySet()];
        String NUid = [select id from User where name='Neil Underwood' and Profile.name='System Administrator' limit 1].Id;
        for (Account a: accs){
            a.Last_Commitment_Stage__c = accCommStageMap.get(a.Id);
            if (a.Owner.Account_Id__c!=null){
                a.OwnerId = NUid;
            }
        }
        update accs;
    }
    
}