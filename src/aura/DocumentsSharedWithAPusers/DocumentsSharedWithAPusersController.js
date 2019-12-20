({
    doInit: function (component, event, helper) {
        var action = component.get("c.getSharings");

        action.setCallback(this, function (response) {
            var docs = [];
            console.log(response.getReturnValue());
            var docs = response.getReturnValue();

            component.set("v.docs", docs);

        });
        $A.enqueueAction(action);
    }
})