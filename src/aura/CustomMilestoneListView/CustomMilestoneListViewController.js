({
    doInit : function(component, event, helper) {
      var action=  component.get('c.getAccountId');
        action.setCallback(this,function(response) 
        {
                  var state=response.getState();
        if(state=='SUCCESS')
        {
            component.set('v.newTTR.Company__c',response.getReturnValue());
        }                                 
        });
  $A.enqueueAction(action);

 },
	saveRecord: function (component, event, helper) {
        var record = component.get("v.newTTR");
        if(record.Company__c==''||record.Name==''){
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
            action.setParams({ MSrec: JSON.stringify(component.get("v.newTTR"))});
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (component.isValid() && state == 'SUCCESS') {   
                    var sObectEvent = $A.get("e.force:navigateToSObject");
                    sObectEvent .setParams({
                    "recordId": response.getReturnValue(),
                    "slideDevName": "detail"
                  });
                  sObectEvent.fire(); 
                    
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
    },
    closeModal:function(component,event,helper){    
		var cmpTarget = component.find('Modalbox');
		var cmpBack = component.find('Modalbackdrop');
		$A.util.removeClass(cmpBack,'slds-backdrop--open');
		$A.util.removeClass(cmpTarget, 'slds-fade-in-open'); 
    	},
	openmodal:function(component,event,helper) {
		var cmpTarget = component.find('Modalbox');
		var cmpBack = component.find('Modalbackdrop');
		$A.util.addClass(cmpTarget, 'slds-fade-in-open');
		$A.util.addClass(cmpBack, 'slds-backdrop--open'); 
	}
})