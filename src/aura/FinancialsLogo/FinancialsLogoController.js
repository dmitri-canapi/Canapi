({
    init: function (cmp, event, helper) {
        var action = cmp.get('c.getAccData');
        action.setCallback(this, $A.getCallback(function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {

                var oResponse = response.getReturnValue();
                console.log(oResponse);
                console.log(JSON.stringify(oResponse));
                cmp.set("v.acc", oResponse);
            } else if (state === "ERROR") {
                var errors = response.getError();
                console.error(errors);
            }
        }
        ));
        $A.enqueueAction(action);
    }
})