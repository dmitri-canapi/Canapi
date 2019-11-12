({
	doInit : function(component, event, helper) {
        
        var action2 = component.get("c.getInitialSettings");
        action2.setParams({ accountId : component.get("v.recordId")});
        action2.setCallback(this, function(response2){
            var state = response2.getState();
            if (state === "SUCCESS") {
                console.log(response2.getReturnValue());
                component.set("v.isBank", response2.getReturnValue().isBank);
                component.set("v.IsCommunity", response2.getReturnValue().isCommunityUser);
                if ( response2.getReturnValue().accountId) {
                    component.set("v.recordId", response2.getReturnValue().accountId);
                }
                 var a = component.get('c.loadData');
           		 $A.enqueueAction(a);

            } else {
                alert(response2);
            }
        });
        $A.enqueueAction(action2);        
	},
    clearVendor: function(component, event, helper) {
        var action = component.get("c.updateVendor");
        var id = event.target.dataset.vendorItemId;
        console.log(id);
        action.setParams( { VCid : id, VendorId: null});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state == 'SUCCESS') {  
                var a = component.get('c.loadData');
       			 $A.enqueueAction(a);
            } else {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Error',
                    message: response.getError()[0].message,
                    type: 'error',
                    mode: 'pester'
                });
                toastEvent.fire();
            }
            
        });
        $A.enqueueAction(action);
        
        
        
        /*var CatalogList = [];
        CatalogList = component.get("v.CatalogList");
        console.log(CatalogList);
        for (var k in CatalogList){
            console.log(CatalogList[k]);
            for (var c in CatalogList[k].value){
                if (c.Id == id){
                    delete c.Vendor__c;
                }
            }
        }
        component.set("v.CatalogList", CatalogList);*/
    },
    
    onClick : function(component, event, helper) {
       var id = event.target.dataset.menuItemId;
        if (id){
            var navEvt = $A.get("e.force:navigateToSObject");
            navEvt.setParams({
                "recordId": id,
                "slideDevName": "related"
            });
            navEvt.fire();
        }
    },
    
    loadData : function(component, event, helper) {
        try{
        var action = component.get("c.getCatalogMap");
           
        action.setParams({ recId : component.get("v.recordId")});
        action.setCallback(this, function(response) {
            var CatalogList = [];
            console.log(response.getReturnValue());
            var conts = response.getReturnValue();
            var types = new Set ();
            for (var key in conts){
				CatalogList.push({value:conts[key], key:key});              
            }
        	component.set("v.CatalogList", CatalogList);
            
        });
        $A.enqueueAction(action);
            }catch(e){}
    },
    
    updateVendorDIVjs: function(component, event, helper) {
        if (event.target){
            var action = component.get("c.updateVendor");
            console.log(event.target.id);
            console.log(component.get("v.tempAccId"));
            action.setParams( { VCid : event.target.id, VendorId: component.get("v.tempAccId")});
            action.setCallback(this, function(response) {
                var state = response.getState();
                    if (component.isValid() && state == 'SUCCESS') { 
                        //var a = component.get('c.loadData');
       					// $A.enqueueAction(a);
                    } else {
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title : 'Error',
                            message: response.getError()[0].message,
                            type: 'error',
                            mode: 'pester'
                        });
                        toastEvent.fire();
                    }
                
            });
            $A.enqueueAction(action);
        }
    },
    updateVendorJs: function(component, event, helper) {
        component.set("v.tempAccId", event.getParam("value")[0]);
    }
    
    
})