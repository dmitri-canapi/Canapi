({
    loadSaved : function(component, path) {
        var action = component.get("c.loadSaved");
        action.setCallback(this, function(response) { 
            var state = response.getState();
            if (state === "SUCCESS") {
                var fullList = JSON.parse(response.getReturnValue());

                component.set("v.linkedinSelectedList", fullList[0]);
                if(fullList[0].length == 3) {
                    this.hideSearch(component, 'linkedinSearchBox');
                }
            }
        });
	 	$A.enqueueAction(action);
    },
    
    saveSelectedUsers : function(component, linkedinList, path) {
        var action = component.get("c.saveSelected");
        action.setParams({
            "linkedinListString" : JSON.stringify(linkedinList)
        });
        action.setCallback(this, function(response) { 
            var state = response.getState();
            if (state === "SUCCESS") {
                //this.back(component);
                document.location.href = 'https://canapi--dk.lightning.force.com/one/one.app#/n/LinkedIn_Outh';
            }
        });
	 	$A.enqueueAction(action);
    },
    

    
    
    getLinkedin : function(component, token) {
        var action = component.get("c.linkedinSearch");
        action.setParams({
            "searchString" : document.getElementById('linkedinSearch').value.split(' ').join('+'),
            "token" : token
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var newList = this.findAlreadySelected(component.get("v.linkedinSelectedList"), JSON.parse(response.getReturnValue()));
                component.set("v.linkedinList", newList);
            }
        });
	 	$A.enqueueAction(action);
    },
    
    authorizeLinkedin: function(component) {
    	var action = component.get("c.authorizationLinkedinStep1");
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                window.location.href = response.getReturnValue();
            }
        });
	 	$A.enqueueAction(action);
    },
    
    
    
    readCookie : function(component, name) {
        var nameEQ = name + "=";
        var ca = document.cookie.split(';');
        for(var i=0;i < ca.length;i++) {
            var c = ca[i];
            while (c.charAt(0)==' ') c = c.substring(1,c.length);
            if (c.indexOf(nameEQ) == 0) return c.substring(nameEQ.length,c.length);
        }
        return null;
    },
    
    hideSearch : function(component, boxId) {
        document.getElementById(boxId).style = 'display:none;';
    },
    
    removeListItem : function(component, list, itemId) {
        for(var i = 0; i < list.length; i++) {
            if(list[i]['system_name'] == itemId) {
                list.splice(i, 1);
            }
        }
        return list;
    },
    
    findAlreadySelected : function(selectedList, newList) {
        for(var i = 0; i < selectedList.length; i++) {
            for(var j = 0; j < newList.length; j++) {
                if(selectedList[i]['system_name'] == newList[j]['system_name']) {
                    newList.splice(j, 1);
                }
            }
        }
        return newList;
    }
})