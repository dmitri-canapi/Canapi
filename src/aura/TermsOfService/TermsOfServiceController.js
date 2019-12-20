({
    doInit: function (component, event, helper) { 
        var action = component.get("c.getTermsState");
        action.setCallback(this, function (response) {
            // commented out by DK on 12-11-2019
            component.set("v.termsAccepted", true); //response.getReturnValue().TermsState);
            component.set("v.terms", response.getReturnValue().Terms);
        });
        $A.enqueueAction(action);
    },
    acceptTermsJS: function (component, event, helper) {
        var action = component.get("c.acceptTerms");
        $A.enqueueAction(action);
        component.set("v.termsAccepted", true);

    }
})