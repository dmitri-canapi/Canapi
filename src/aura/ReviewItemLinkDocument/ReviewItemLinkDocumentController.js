({
	doInit : function(component, event, helper) {
		var action = component.get("c.isCommunity");
        action.setCallback(this, function(response) {
        component.set("v.IsCommunity", response.getReturnValue());
          console.log(response.getReturnValue());  
        });
        $A.enqueueAction(action);
        
        window.addEventListener("message", function(event) {
            if (event.data == 'CloseLightningPopupFromVF') {
            	component.find("overlayLib").notifyClose();
            } else if (event.data.includes('showFilePreview')){
                var fileId = event.data.split('-del-')[1];
                 $A.get('e.lightning:openFiles').fire({
                    recordIds: [fileId]
                });
                
            }
        }, false);
	}
   
})