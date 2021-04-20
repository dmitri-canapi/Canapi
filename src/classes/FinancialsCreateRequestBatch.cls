global class FinancialsCreateRequestBatch implements Database.Batchable<sobject>, Database.Stateful, Database.AllowsCallouts{
    Map <String,List<Financials_Verification__c>> reqMap = new Map <String,List<Financials_Verification__c>>();
    global Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator('SELECT Id, CreatedByID, CreatedBy.Name, Value__c, TextValue__c, DateValue__c,Financials__c, Financials__r.Chart_of_Accounts__r.Account__r.Name, Financials__r.Chart_of_Accounts__r.Account__c, Financials__r.Value__c, Financials__r.TextValue__c,  Financials__r.DateValue__c FROM Financials_Verification__c where Request_Created__c = false');
    }   
    global void execute(Database.BatchableContext bc, List<Financials_Verification__c> fins){
        for(Financials_Verification__c f : fins){
           if (reqMap.containsKey('' + f.CreatedByID + f.Financials__r.Chart_of_Accounts__r.Account__c)){
                List<Financials_Verification__c> finMapList = reqMap.get('' + f.CreatedByID + f.Financials__r.Chart_of_Accounts__r.Account__c); 
                finMapList.add(f);
                reqMap.put('' + f.CreatedByID + f.Financials__r.Chart_of_Accounts__r.Account__c, finMapList); 
           } else {
            reqMap.put('' + f.CreatedByID + f.Financials__r.Chart_of_Accounts__r.Account__c, new List<Financials_Verification__c> {f}); 
           }
        }
    }
        global void finish(Database.BatchableContext bc){
            //Financials_Change_Request__c
            system.debug(reqMap.size());
            List <Financials_Change_Request__c> fcrList = new List <Financials_Change_Request__c>();
            for(String keys: reqMap.KeySet()){
                fcrList.add(new Financials_Change_Request__c(
                    Account__c = reqMap.get(keys)[0].Financials__r.Chart_of_Accounts__r.Account__c,
                    Requestor__c = reqMap.get(keys)[0].CreatedById
                    ));
            }
            insert fcrList;
            integer i = 0;
            List <Financials_Verification__c> finForUpdate = new List <Financials_Verification__c>();
            Set <String> reqIds = new Set <String>();
            for(String keys: reqMap.KeySet()){
                                    
                for (Financials_Verification__c fin: reqMap.get(keys)){
                    fin.Financials_Change_Request__c = fcrList[i].Id;
                    fin.Request_Created__c = true;
                    finForUpdate.add(fin);
                }

                Approval.ProcessSubmitRequest req1 = 
                    new Approval.ProcessSubmitRequest();
                //req1.setComments('Submitting request for approval.');
                req1.setObjectId(fcrList[i].Id);
                reqIds.add(fcrList[i].Id);
                
                // Submit on behalf of a specific submitter
                //req1.setSubmitterId(user1.Id); 
                
                // Submit the record to specific process and skip the criteria evaluation
                //req1.setProcessDefinitionNameOrId('PTO_Request_Process');
                req1.setSkipEntryCriteria(true);
                
                // Submit the approval request for the account
                Approval.ProcessResult result = Approval.process(req1);
                
                i++;
            }
            update finForUpdate;

            
            FinancialsSaveRequestBatch b = new FinancialsSaveRequestBatch();
            Database.executeBatch(b, 50);
    }


}