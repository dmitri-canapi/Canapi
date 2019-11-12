trigger RepPeriodTrigger on Report_Period__c (after insert) {
	if(FF_CalculateFormulas.firstRun){
        FF_CalculateFormulas.firstRun = false;
        FF_CalculateFormulas.recalculate (trigger.new[0].Account__c);
    }
}