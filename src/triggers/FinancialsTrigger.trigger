trigger FinancialsTrigger on Financials__c (after insert, after update, after delete) {
	if(FF_CalculateFormulas.firstRun){
        FF_CalculateFormulas.firstRun = false;
        if(Trigger.isDelete){
            FF_CalculateFormulas.recalculate (trigger.old[0].Chart_of_Accounts_AccId__c);
        } else {
            FF_CalculateFormulas.recalculate (trigger.new[0].Chart_of_Accounts_AccId__c);
        }
    }
}