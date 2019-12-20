({
    doInit: function (component, event, helper) {
        var action = component.get("c.getReports");

        action.setCallback(this, function (response) {
            var Reports = [];
            console.log(response.getReturnValue());
            var Reports = response.getReturnValue();

            component.set("v.Reports", Reports);

        });
        $A.enqueueAction(action);
    },
    updateSubscriptionDivJS: function (component, event, helper) {

        if (event.target) {
            var action = component.get("c.updateSubscription");
            console.log(event.target.id);
            action.setParams({ reportId: event.target.id, subscription: component.get("v.tempSubsValue") });
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (component.isValid() && state == 'SUCCESS') {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title: 'Success',
                        message: 'Subscription Saved!',
                        type: 'Success',
                        mode: 'pester'
                    });
                    toastEvent.fire();
                } else {
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

    },
    updateSubscriptionJS: function (component, event, helper) {
        component.set("v.tempSubsValue", event.getParam("value"));
        console.log(event.getParam("value"));
    }
})