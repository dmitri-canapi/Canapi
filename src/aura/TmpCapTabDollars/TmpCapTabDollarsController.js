({
    init : function (component, event, helper) {

        var action = component.get("c.getCapTableData");
        action.setParams({ accountId : component.get("v.recordId") });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var rawCapTableData = response.getReturnValue();
                component.set("v.rawCapTableData", rawCapTableData);
                helper.initData(component, rawCapTableData);        
            } else {
                alert(response);
            }
        });
        $A.enqueueAction(action);
    }
})