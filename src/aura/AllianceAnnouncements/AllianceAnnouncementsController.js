({
	init: function (cmp, event, helper) {
        var action=cmp.get('c.getNews');
        action.setCallback(this,$A.getCallback(function(response){
            var state=response.getState();
            if(state==="SUCCESS"){
                var oResponse = response.getReturnValue();
                cmp.set("v.news", oResponse);
            }        
        }));
        $A.enqueueAction(action);
    }
})