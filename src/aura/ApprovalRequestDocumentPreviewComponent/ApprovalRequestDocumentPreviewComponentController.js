({
    doInit: function (component, event, helper) {
        var action = component.get("c.getFileId");
        action.setParams({ recordId: component.get("v.recordId") });
        action.setCallback(this, function (response) {
            component.set("v.fileId", response.getReturnValue());
        });
        $A.enqueueAction(action);
    },
    openmodal: function (component, event, helper) {
        $A.get('e.lightning:openFiles').fire({
            recordIds: [component.get("v.fileId")]
        });
    }
})