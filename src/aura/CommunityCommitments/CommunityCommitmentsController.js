({
    doInit : function(component, event, helper){
        component.set('v.mycolumns', [
            {label: 'Name', fieldName: 'Name', type: 'text'},
            {label: 'Fund', fieldName: 'FundName', type: 'text'},
            {label: 'Target Commitment', fieldName: 'Target_Commitment__c', type: 'currency'},
            {label: 'Commitment Stage', fieldName: 'Commitment_Stage__c', type: 'text'},
            {label: 'Funded Amount', fieldName: 'Funded_Amount__c', type: 'currency'}
        ]);
        var userId = $A.get("$SObjectType.CurrentUser.Id");
		console.log(userId);
        var action = component.get("c.getFilteredCommitments");
        action.setParams({filterId : userId});
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var rows = response.getReturnValue();
                for (var i = 0; i < rows.length; i++) {
                    var row = rows[i];
                    if (row.Fund__c) row.FundName = row.Fund__r.Name;
                }
                component.set('v.Commitments', rows);
                
            }
        });
        $A.enqueueAction(action); 
    }
    
})