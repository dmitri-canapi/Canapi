({
	doInit : function(component, event, helper) {
		var action = component.get("c.getMyGroups");
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var apexResponse=response.getReturnValue();
                    component.set("v.groups",apexResponse);
                }
            });
            $A.enqueueAction(action);
        $A.createComponent(
            "forceChatter:publisher", {
                "context": "GLOBAL",
                "aura:id": "publisher"
            },function(recordFeed) {
                if (component.isValid()) {
                    var body = component.get("v.body");
                    body.push(recordFeed);
                    component.set("v.body", body);
                }
            }); 
	},
    onChange: function (component, event, helper) {

        component.find("publisher").destroy();
        
        var selPickListValue = event.getSource().get("v.value");
        console.log(selPickListValue);
        if (selPickListValue=='GLOBAL'){
            component.set("v.context","GLOBAL");
            $A.createComponent(
                "forceChatter:publisher", {
                    "context": "GLOBAL",
                    "aura:id": "publisher"
                },function(recordFeed) {
                    if (component.isValid()) {
                        var body = component.get("v.body");
                        body.push(recordFeed);
                        component.set("v.body", body);
                    }
                }); 
        } else {
            component.set("v.context","RECORD");
            $A.createComponent(
                "forceChatter:publisher", {
                    "context": "RECORD",
                    "recordId": component.get("v.group"),
                    "aura:id": "publisher"
                },function(recordFeed) {
                    if (component.isValid()) {
                        var body = component.get("v.body");
                        body.push(recordFeed);
                        component.set("v.body", body);
                    }
                }); 
        }
    }
})