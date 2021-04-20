global class FinancialsSaveRequestBatch implements Database.Batchable<sobject>, Database.Stateful, Database.AllowsCallouts{
    global Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator('SELECT Id  FROM Financials_Change_Request__c where Request_Saved__c = false');
    }   
    global void execute(Database.BatchableContext bc, List<Financials_Change_Request__c> fins){
        List<ContentVersion> attachList = new List <ContentVersion>();
           
            
            for(Financials_Change_Request__c fcr: fins)
           {
                PageReference pdf = Page.FinancialsRequestReport;
                pdf.getParameters().put('id',fcr.Id);
                Blob body;
                
                try {
                    body = pdf.getContent();
                } catch (VisualforceException e) {
                    body = Blob.valueOf('Some Text');
                }

                ContentVersion cv = new ContentVersion(
                    Title = 'Financials Change Request.pdf',
                    PathOnClient = 'Financials Change Request.pdf',
                    VersionData = body, 
                    origin = 'H',
                    FirstPublishLocationId = fcr.Id
                );
                
                attachList.add(cv);
               
                fcr.Request_Saved__c = true;
           }
           insert attachList;
           update fins;
    }

    global void finish(Database.BatchableContext bc){
    
    }
}