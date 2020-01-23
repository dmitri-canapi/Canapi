({
    handleSubmit: function (component, event, helper) {
        console.log('save');
        //component.find("editForm").submit();
        //console.log(component.find("editForm"));
    },
    handleSuccessMessage: function (component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type": "success",
            "title": "Success!",
            "message": "The record has been updated successfully."
        });
        toastEvent.fire();

        $A.get('e.force:refreshView').fire();
        /*
                component.find('popuplib').showCustomPopover({
                    body: "User Is Updated",
                    referenceSelector: ".mypopover",
                    cssClass: "slds-popover slds-nubbin_left"
                }).then(function (overlay) {
                    setTimeout(function () {
                        //close the popover after 3 seconds
                        overlay.close();
                    }, 300);
                });
        */
        component.find("popuplib").notifyClose();
    },
})