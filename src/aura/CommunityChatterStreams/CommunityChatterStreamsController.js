({
	init: function (cmp, event, helper) {
        var action=cmp.get('c.getStreams');
        action.setCallback(this,$A.getCallback(function(response){
            var state=response.getState();
            if(state==="SUCCESS"){
                var oResponse=response.getReturnValue();
                cmp.set("v.streams",oResponse);
            }else if(state==="ERROR"){
                var errors=response.getError();
                console.error(errors);
            }
        }
         ));
        $A.enqueueAction(action);
    }
})