({

    fetchData: function (cmp, event, helper) {
        var action = cmp.get("c.getContacts");
        action.setParams({
            'filter': cmp.get("v.filter"),
            'order': cmp.get("v.order")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                cmp.set('v.data', data);
            }
            // error handling when state is "INCOMPLETE" or "ERROR"
        });
        $A.getCallback(function () {
            $A.enqueueAction(action);
        })();
    }
})