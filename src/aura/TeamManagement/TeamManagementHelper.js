({
    fetchData: function (cmp,event,helper) {
        var action = cmp.get("c.getUsers");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                data.forEach(function(record){
                    record.linkName = '/detail/' + record.Id;
                });
				console.log(data[0].Account_Id__c);
                cmp.set('v.data',data);
            }
            // error handling when state is "INCOMPLETE" or "ERROR"
        });
        $A.enqueueAction(action);
    },
    createUser: function (component,event,helper) {
        var record = component.get("v.newUser");
        if(record.Email==''|| record.LastName==''){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title : 'Error',
                message: 'Please, complete all required fields.',
                type: 'error',
                mode: 'pester'
            });
            toastEvent.fire();
        } else {
            var action = component.get("c.saveRecordContr");
            action.setParams({ UserRec: JSON.stringify(component.get("v.newUser"))});
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (component.isValid() && state == 'SUCCESS') {   
                    $A.get('e.force:refreshView').fire(); 
                } else {
                    console.log('Failed with state: ' + state);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Error',
                        message: response.getError()[0].message,
                        type: 'error',
                        mode: 'pester'
                    });
                    toastEvent.fire();
                    
                }
            });
            $A.enqueueAction(action);
        }
    }
})