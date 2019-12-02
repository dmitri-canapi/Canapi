trigger FinancialsTrigger on Financials__c (after insert, after update) {
	if(FF_CalculateFormulas.firstRun){
        FF_CalculateFormulas.firstRun = false;
        FF_CalculateFormulas.recalculate (trigger.new[0].Chart_of_Accounts_AccId__c);
    }
}