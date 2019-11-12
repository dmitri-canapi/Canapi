trigger ChartOfAccountTrigger on Chart_of_Accounts__c (after insert, after update) {
	if(FF_CalculateFormulas.firstRun){
        FF_CalculateFormulas.firstRun = false;
        FF_CalculateFormulas.recalculate (trigger.new[0].Account__c);
    }
}