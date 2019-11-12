({
	doInitChild : function(cmp) {
        var tags = cmp.get("v.tags");
         var tagsLoad = cmp.get("v.tagsLoad");
        console.log('LOad '+tagsLoad);
        var ids = [];
        for(let tag of tags){
            ids.push(tag.Id);
        }
        if(ids!=null&&ids!=""){
        var action = cmp.get("c.getTagsById");
            action.setBackground();
        action.setParams({ ids : ids,
                          tagsLoad :tagsLoad});
        
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var resp = response.getReturnValue();
                for(let tag of resp){
                    for(let old of tags){
                        if(old.Id==tag.id){
                            old.Tags__r = tag.Tags__r;
                        }
                    }
                    
                }
                cmp.set('v.localTags',resp); 
                for(var tag of cmp.get('v.localTags')){
                    var value = tag.Name;
                    var menuValue = "Add";
                    var appEvent = $A.get("e.c:SetTagToParrentComponent"); 
                    appEvent.setParams({
                        "tag" : value,
                        "action" :  menuValue              
                    }); 
                    appEvent.fire(); 
            	}
            }else if (state === "ERROR") {
                console.log('ERROR');
                var errors = response.getError();
                console.log(errors);
                 console.log(errors[0]);
            this.showErrorToast(component, errors[0].message);
            }
        });
        $A.enqueueAction(action);
        }
	}
})