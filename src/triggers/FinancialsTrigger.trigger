trigger FinancialsTrigger on Financials__c (after insert, after update) {
    boolean isCommunity = Site.getSiteId()!=null;
    system.debug('firstRun - ' + FF_CalculateFormulas.firstRun);
	
    if ((isCommunity || Test.isRunningTest()) && (Trigger.isInsert || (Trigger.isUpdate && FF_CalculateFormulas.firstRun))){
        Set <Id> finIds = new Set <Id>();
        List <Financials_Verification__c> verList = new List<Financials_Verification__c>();
        system.debug([select id, Value__c, DateValue__c, TextValue__c from Financials__c where Chart_of_Accounts__r.Financial_Category__r.Type__c = 'Static' and id in: Trigger.newMap.KeySet() and id NOT in (select Financials__c from Financials_Verification__c where Financials__c in: Trigger.newMap.KeySet() and CreatedById =: UserInfo.getUserId() and Request_Created__c = false)]);
        system.debug([select id, Value__c, DateValue__c, TextValue__c from Financials__c where id in: Trigger.newMap.KeySet() and id NOT in (select Financials__c from Financials_Verification__c where Financials__c in: Trigger.newMap.KeySet())]);
        for (Financials__c f : [select id, Value__c, DateValue__c, TextValue__c from Financials__c where Chart_of_Accounts__r.Financial_Category__r.Type__c = 'Static' and id in: Trigger.newMap.KeySet() and id NOT in (select Financials__c from Financials_Verification__c where Financials__c in: Trigger.newMap.KeySet() and CreatedById =: UserInfo.getUserId() and Request_Created__c = false)]) {
            finIds.add(f.Id);
            if ((Trigger.isInsert && ((f.Value__c != null &&  f.Value__c !=0) || (f.TextValue__c != null &&  f.TextValue__c !='') || f.DateValue__c != null)) || (Trigger.isUpdate && (trigger.oldMap.get(f.Id).Value__c != f.Value__c || trigger.oldMap.get(f.Id).TextValue__c != f.TextValue__c || trigger.oldMap.get(f.Id).DateValue__c != f.DateValue__c))){
                
                Financials_Verification__c vo = new Financials_Verification__c();
                vo.Financials__c = f.Id;
                if (Trigger.isUpdate){
                    if (trigger.oldMap.get(f.Id).Value__c != f.Value__c) vo.Value__c = trigger.oldMap.get(f.Id).Value__c;
                    if (trigger.oldMap.get(f.Id).TextValue__c != f.TextValue__c) vo.TextValue__c = trigger.oldMap.get(f.Id).TextValue__c;
                    if (trigger.oldMap.get(f.Id).DateValue__c != f.DateValue__c) vo.DateValue__c = trigger.oldMap.get(f.Id).DateValue__c;
                }
                verList.add(vo);
            }
        }
        insert verList;
    }
    
    if(FF_CalculateFormulas.firstRun){
        FF_CalculateFormulas.firstRun = false;
        FF_CalculateFormulas.recalculate (trigger.new[0].Chart_of_Accounts_AccId__c);
    }
}