({
    doInit : function(component, event, helper) {
    	function getParameterByName(name, url) {
            if (!url) {
                url = window.location.href;
            }
            name = name.replace(/[\[\]]/g, "\\$&");
            var regex = new RegExp("[?&]" + name + "(=([^&#]*)|&|#|$)"),
                results = regex.exec(url);
            if (!results) return null;
            if (!results[2]) return '';
            return decodeURIComponent(results[2].replace(/\+/g, " "));
        }
        var linkedin_token = getParameterByName('linkedin_token');

     
        if(linkedin_token != null && linkedin_token != '') {
            document.cookie = 'linkedinToken=' + escape(linkedin_token) + '; path=/';
        }
    
        helper.loadSaved(component);
    },
    
    rendered : function(component, event, helper) {
        var device = $A.get("$Browser.formFactor");
        var loginImages = document.getElementsByClassName('loginImage');

		var visible = 'width:150px;';
        if(device == 'DESKTOP') {
            for(var i=0;i<loginImages.length;i++) {
                loginImages[i].style = 'width:250px;';
            }
            visible = 'width:250px;';
            var containerSelected = document.getElementsByClassName('selectedContainer');
            for(var i=0;i<containerSelected.length;i++) {
                containerSelected[i].style = 'display:flex;';
            }
        }
        
        var linkedinListLength = component.get("v.linkedinSelectedList").length;
        var disp = 'display:none;';
        if(helper.readCookie(component, 'linkedinToken') != null) {
            document.getElementById('linkedinLoginImage').style = disp;
            if(linkedinListLength < 3) {
            	document.getElementById('linkedinSearchBox').style = '';
            }
        } else {
            document.getElementById('linkedinSelected').style = disp;
            document.getElementById('linkedinLoginImage').style = visible;
            document.getElementById('linkedinSearchBox').style = disp;
        }
    },
    
    linkedinLogin : function(component, event, helper) {
        helper.authorizeLinkedin(component);
    },
    
    saveAndBack : function(component, event, helper) {
        var linkedinList = component.get("v.linkedinSelectedList");
        helper.saveSelectedUsers(component,linkedinList);
    },
    
    search : function(component, event, helper) {
        var siteSearch = event.target.id;
        

        helper.getLinkedin(component, helper.readCookie(component, 'linkedinToken'));
        document.getElementById('linkedinResult').style = '';

    },
    
    stopSearch : function(component, event, helper) {
        document.getElementById('linkedinResult').style = 'display:none;';
    },
    
    selectItem : function(component, event, helper) {
        var selectedItemId = event.target.id;
        var splitedId = selectedItemId.split('_');
        for(var i = 2; i < splitedId.length; i++) {
            splitedId[1] = splitedId[1] + '_' + splitedId[i];
        }
        var selectedItemName = document.getElementById(selectedItemId).innerText;
        var newSelectedItem = {};
        newSelectedItem['name'] = selectedItemName;
        newSelectedItem['system_name'] = splitedId[1];
        

        var companyList = component.get("v.linkedinList");
        for(var i = 0; i < companyList.length; i++) {
            if(companyList[i]['system_name'] == newSelectedItem['system_name'])
                newSelectedItem = companyList[i];
        }
        var linkedinSelectedList = component.get("v.linkedinSelectedList");
        if(linkedinSelectedList.length < 3) {
            linkedinSelectedList[linkedinSelectedList.length] = newSelectedItem;
            component.set("v.linkedinSelectedList", linkedinSelectedList);
            var newList = helper.removeListItem(component, component.get("v.linkedinList"), newSelectedItem['system_name']);
            component.set("v.linkedinList", newList);
        }
        if(linkedinSelectedList.length == 3) {
            helper.hideSearch(component, 'linkedinSearchBox');
        }
        
    },
    
    removeSelectedItem : function(component, event, helper) {
        var selectedItemId = event.target.id;
        var splitedId = selectedItemId.split('_');
        
        
        var linkedinList = component.get("v.linkedinSelectedList");
        linkedinList = helper.removeListItem(component, linkedinList, splitedId[1]);
        component.set("v.linkedinSelectedList", linkedinList);
        
    }
})