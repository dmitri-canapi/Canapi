({
    doInit: function (component, event, helper) {
        var querystring = location.search.substr(1);
        var paramValue = {};
        querystring.split("&").forEach(function (part) {
            var param = part.split("=");
            paramValue[param[0]] = decodeURIComponent(param[1]);
        });

        console.log(paramValue);
        component.set("v.functionContId", paramValue.id);

        var action = component.get("c.getFunctionContactStatus");
        action.setParams({ functionConId: paramValue.id });
        action.setCallback(this, function (response) {
            console.log(response.getReturnValue());
            let obj = JSON.parse(JSON.stringify(response.getReturnValue()));
            console.log(obj);
            component.set("v.functionContact", obj);
            component.set("v.userRegistrationStatus", (obj.Function_Status__c == 'Planned' || obj.Function_Status__c == 'Invited') ? 'NotRegistered' : 'Registered');

        });
        $A.enqueueAction(action);


    },
    register: function (component, event, helper) {
        var action = component.get("c.addRegistrant");

        action.setParams({ functionConId: component.get("v.functionContId") });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.userRegistrationStatus", 'Registered');

                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title: 'Success',
                    message: 'Thank you for registering!',
                    type: 'success',
                    mode: 'pester'
                });
                toastEvent.fire();
            } else {
                console.log('Failed with state: ' + state);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title: 'Error',
                    message: response.getError()[0].message,
                    type: 'error',
                    mode: 'pester'
                });
                toastEvent.fire();

            }
        });
        $A.enqueueAction(action);
    }
})