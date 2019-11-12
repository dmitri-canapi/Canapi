({
	  handleSectionToggle: function (cmp, event) {
        var openSections = event.getParam('openSections');
          cmp.set('v.activeSections',  openSections);
    },
    doInitChild: function (cmp, evt, hlp) {
       if(cmp.get('v.LoadData')){
            console.log('IN@@@@@@@@@@@@@@@@@');
             var localTags = cmp.get('v.localTags');
            if(localTags.length==0){
                hlp.doInitChild(cmp);
            }
        
            
        }
        
    },
    addTag : function(cmp, evt, hlp) {
        var value = evt.getSource().get("v.value");
        var menuValue = evt.detail.menuItem.get("v.value");
        var appEvent = $A.get("e.c:SetTagToParrentComponent"); 
        appEvent.setParams({
            "tag" : value,
            "action" :  menuValue              
                           }); 
        appEvent.fire(); 
    },
    ParentAction: function(cmp, evt, hlp) {
        if(cmp.get('v.LoadData')){
            console.log('IN@@@@@@@@@@@@@@@@@');
             var localTags = cmp.get('v.localTags');
            if(localTags.length==0){
                hlp.doInitChild(cmp);
            }else{
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
            } 
        }else{
            for(var tag of cmp.get('v.localTags')){
                    var value = tag.Name;
                    var menuValue = "Remove";
                    var appEvent = $A.get("e.c:SetTagToParrentComponent"); 
                    appEvent.setParams({
                        "tag" : value,
                        "action" :  menuValue              
                    }); 
                    appEvent.fire(); 
            	}
        }
        
    }
})