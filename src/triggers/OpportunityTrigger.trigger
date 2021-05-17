trigger OpportunityTrigger on Opportunity (after insert, after update) {
    if (FF_CalculateFormulas.firstRun){
        FF_CalculateFormulas.firstRun = false;
        Map <String,String> accountContactMap = new Map <String,String>();
        Set <String> accs = new Set <String>();

        List <Opportunity> opps = [select id, AccountId from Opportunity where id in: Trigger.NewMap.KeySet()];
        for (Opportunity opp: opps){
            accs.add(opp.AccountId);
        }

        for (AccountContactRelation acr: [select AccountId, ContactId from AccountContactRelation where accountId in:accs and Roles includes ('Board (Observer)') ]){
            accountContactMap.put(acr.AccountId, acr.ContactId);
        }

        for (Opportunity opp: opps){
            if (accountContactMap.containsKey(opp.AccountId)){
                opp.Observer__c = accountContactMap.get(opp.AccountId);
            } else {
                opp.Observer__c = null;
            }
        }
        update opps;
        
    }

}