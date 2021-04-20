({
    init: function (component, event, helper) {
        var action = component.get("c.getAccounts");

        action.setParams({
            'recId': component.get("v.recordId")
        });

        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                component.set('v.data', data);
            }
        });
        $A.getCallback(function () {
            $A.enqueueAction(action);
        })();
    }
})