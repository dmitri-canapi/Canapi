({
    doInit: function (component, event, helper) {
        var action = component.get("c.getTerms");
        action.setCallback(this, function (response) {
            component.set("v.terms", response.getReturnValue());
        });
        $A.enqueueAction(action);
        var today = $A.localizationService.formatDate(new Date(), "YYYY");
        component.set('v.today', today);
    },
    openModal: function (component, event, helper) {
        component.set("v.showTerms", true);
    },
    closeModal: function (component, event, helper) {
        component.set("v.showTerms", false);
    },
    getInput: function (component,
        event, helper) {

        component.set("v.mylabel1",
            "");

        var validForm = component.find(
            'FormVal').reduce(
                function (validSoFar,
                    inputCmp) {
                    // Displays error messages for invalid fields
                    //inputCmp.showHelpMessageIfInvalid();
                    //alert("dfdf!");
                    return validSoFar &&
                        inputCmp.get(
                            'v.validity'
                        ).valid;
                }, true);
        // If we pass error checking, do some real work
        if (validForm) {

            // Get the Username from Component
            var user = component.get(
                "v.Username");
            var Pass = component.get(
                "v.Password");
            //Calling controller
            // Create the action
            var action = component.get(
                "c.checkPortal");
            action.setParams({
                username: user,
                password: Pass
            });
            // Add callback behavior for when response is received
            action.setCallback(this,
                function (response) {
                    var state =
                        response.getState();
                    var rtnValue =
                        response.getReturnValue();
                    if (rtnValue !==
                        null) {
                        component.set(
                            "v.mylabel",
                            rtnValue
                        );
                        //component.set("v.showError",true);
                    }
                });

            // Send action off to be executed
            $A.enqueueAction(action);
        }
    },
    resetPass: function (cmp) {
        cmp.set("v.mylabel1", "");
		cmp.set("v.mylabel", "");
        cmp.set("v.isVisible",
            false);
    },

    CancelReset: function (cmp) {
        cmp.set("v.mylabel", "");
		cmp.set("v.mylabel1", "");
        cmp.set("v.isVisible", true);
    },
    submitresetPass: function (
        component, event, helper) {
        component.set("v.mylabel",
            "");

        var validResetForm1 =
            component.find(
                "FormReset").get(
                    "v.validity");
        // If we pass error checking, do some real work
        if (validResetForm1.valid) {
            var Reuser1 = component.get(
                "v.ResetUsername");
            var action = component.get(
                "c.forgotPassowrd"
            );
            action.setParams({
                username: Reuser1
            });
            action.setCallback(this,
                function (a) {
                    var rtnValue =
                        a.getReturnValue();
                    console.log(
                        '<<my return value>>>>>' +
                        rtnValue);
                    // component.set("v.mylabel1",'We’ve sent you an email with a link to finish resetting your password.');

                    if (rtnValue !==
                        null) {
                        if (rtnValue == 'Your password was successfully reset') {
                            component.set("v.mylabel1", rtnValue);
                        } else {
                            component.set("v.mylabel", rtnValue);
                        }

                        // component.set("v.showError",true);
                    }
                });
            $A.enqueueAction(action);
        } else {
            validResetForm1.setCustomValidity("Error message or blank if valid");
            validResetForm1.reportValidity();
        }
    },
    handleLogin: function (component,
        event, helpler) {
        var username = component.find(
            "Username").get(
                "v.Username");
        var password = component.find(
            "password").get(
                "v.value");
        helpler.handleLogin(
            username, password);
    },
    setStartUrl: function (component,
        event, helpler) {
        var startUrl = event.getParam(
            'startURL');
        if (startUrl) {
            component.set(
                "v.startUrl",
                startUrl);
        }
    }
})