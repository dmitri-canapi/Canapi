trigger ChartOfAccountTrigger on Chart_of_Accounts__c (after insert, after update, before insert, before update) {
	if(FF_CalculateFormulas.firstRun && Trigger.IsAfter){
        FF_CalculateFormulas.firstRun = false;
        FF_CalculateFormulas.recalculate (trigger.new[0].Account__c);
    }

    if(Trigger.IsBefore){
        Map<id, Set <String>> accsWithChartNames = new Map<id, Set <String>>();
        Set <String> chIds = new Set <String>();
        for (Chart_of_Accounts__c ch: trigger.new){
            accsWithChartNames.put(ch.Account__c, New Set<String> ());
            if (Trigger.IsUpdate){
                chIds.add(ch.Id);
            }
        }
        
        

        for (Chart_of_Accounts__c ch: [select Name,Account__c from Chart_of_Accounts__c where Account__c in: accsWithChartNames.keySet() and Id NOT in : chIds]){
            Set <String> temp = accsWithChartNames.get(ch.Account__c);
            temp.add(ch.Name);
            accsWithChartNames.put(ch.Account__c, temp);
        }

        for (Chart_of_Accounts__c ch: trigger.new){
            if ((accsWithChartNames.get(ch.Account__c)).contains(ch.Name)){
                String operation = (Trigger.IsInsert) ? 'create' : 'rename';
                if (!Test.IsRunningTest()) ch.Name.addError('Unable to ' + operation  + ' account. Account named "' + ch.Name + '" already exists. Please delete or rename existing account and try again.');
            }
        }
    }
}