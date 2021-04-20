trigger FinancialsRequestTrigger on Financials_Change_Request__c (after update) {

    
    List <Financials__c> financials = new List <Financials__c>();


    List <Financials_Verification__c> verifications = [select id,
    Value__c, 
    TextValue__c, 
    DateValue__c,
    Financials__c, 
    Financials__r.Value__c, 
    Financials__r.TextValue__c,  
    Financials__r.DateValue__c,
    Financials_Change_Request__r.Status__c 
    from Financials_Verification__c
    where 
    Financials_Change_Request__c in: Trigger.newMap.KeySet() and 
    Financials_Change_Request__r.Status__c != null and 
    Financials__c!= null ];
    
    for(Financials_Verification__c fcr : verifications){
        if (fcr.Financials_Change_Request__r.Status__c == 'Rejected'){
            financials.add(new Financials__c(id = fcr.Financials__c, 
            Value__c = fcr.Value__c,
            TextValue__c = fcr.TextValue__c,
            DateValue__c = fcr.DateValue__c
            ));
        }
    }
    update financials;
    delete verifications;
}