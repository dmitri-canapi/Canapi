({
    doInit: function (component, event, helper) {
        window.addEventListener("message", function (event) {
            try {
                var pass_data = JSON.parse(event.data);
                console.log(pass_data);
                if (pass_data.func)
                    if (pass_data.func == 'link') {
                        helper.openLinkPopup(component, event, pass_data.RIid);
                    } else if (pass_data.func == 'edit') {
                        helper.openEditPopup(component, event, pass_data.RIid);
                    } else if (pass_data.func == 'setBaseUrl') {
                        component.set("v.BaseUrl", pass_data.RIid);
                    } else if (pass_data.func == 'fakeCall') {
                        helper.fakeCall(component, event);
                    }
            } catch (e) { }
        });

        component.set("v.isCreateable", false);
        var action = component.get("c.isReviewItemCreateable");
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.isCreateable", response.getReturnValue());
            }
        });
        $A.enqueueAction(action);


    },
    createRecord: function (component, event, helper) {
        var createRecordEvent = $A.get("e.force:createRecord");
        createRecordEvent.setParams({
            "entityApiName": "review_item__c",
            "defaultFieldValues": {
                "Assessment__c": component.get("v.recordId")
            }
        });
        createRecordEvent.fire();
    }

})