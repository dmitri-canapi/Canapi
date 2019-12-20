({
	doInit : function(component, event, helper) {
		var action = component.get("c.getCommunityPageHeaderInitValues2");
            action.setParams({ recId : component.get("v.recordId")});
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var ow = response.getReturnValue();
                    if (ow.accDescription!=null){
                        component.set("v.accDescr",ow.accDescription); 
                    }
                }
            });
            $A.enqueueAction(action);
	}
})