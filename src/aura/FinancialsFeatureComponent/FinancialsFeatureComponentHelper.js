({
	handlerEvent : function(cmp, data) {
        var windowHash = window.location.hash;
        var createRecordEvent = $A.get("e.force:createRecord");
        createRecordEvent.setParams({
            "entityApiName": "Board_Meeting__c",
            "panelOnDestroyCallback": function(event) {
             window.location.href = "https://www.google.com";
    },
            "defaultFieldValues": {
                'Account__c' : data.recordId
            }
            
        });
    createRecordEvent.fire();
	}
})