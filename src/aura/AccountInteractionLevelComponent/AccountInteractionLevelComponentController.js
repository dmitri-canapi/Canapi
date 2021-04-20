({
    init: function (cmp, event, helper) {
        var action = cmp.get('c.fetchAcc');
        action.setParams({ recId: cmp.get("v.recordId") });

        action.setCallback(this, $A.getCallback(function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var oResponse = response.getReturnValue();
                cmp.set("v.Acc", oResponse);
            } else if (state === "ERROR") {
                var errors = response.getError();
                console.error(errors);
            }
        }
        ));
        $A.enqueueAction(action);
    }
})