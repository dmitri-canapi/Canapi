({
    doInit : function(component, event, helper){
        console.log('test');
        component.set('v.mycolumns', [
            {label: 'Deal Name', fieldName: 'linkName', type: 'url',typeAttributes: {label: { fieldName: 'Name'}, target: '_self'}},
            {label: 'Account Name', fieldName: 'AccountId', type: 'url',typeAttributes: {label: { fieldName: 'AccName'}, target: '_self'}},
            {label: 'Stage', fieldName: 'StageName', type: 'text'},
            {label: 'Close Date', fieldName: 'CloseDate', type: 'date'},
            {label: 'Deal Owner Alias', fieldName: 'OwnerAlias', type: 'text'},
            /*{label: 'Amount', fieldName: 'Amount', type: 'currency'},
            {label: 'Probability', fieldName: 'Probability', type: 'percent'},
            {label: 'Type', fieldName: 'Type', type: 'text'},
            {label: 'Lead Source', fieldName: 'LeadSource', type: 'text'}*/
           
        ]);
        
        var action = component.get("c.getFilteredDeals");
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log(response.getReturnValue());
                var rows = response.getReturnValue();
                rows.forEach(function(record){
                    record.linkName = '/fintech/s/dealdetail?id=' + record.Id;
                    record.Probability = record.Probability/100;
                    record.AccountId = '/fintech/'+ record.AccountId;
                    record.AccName = record.Account.Name;
            		record.OwnerAlias = record.Owner.Alias;
                });
                component.set('v.Opportunities', rows);
            }
        });
        $A.enqueueAction(action); 
    }
    
})