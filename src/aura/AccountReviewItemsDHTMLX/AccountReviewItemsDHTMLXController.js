({
    doInit: function (component, event, helper) {
        console.log('init');
        window.addEventListener("message", function (event) {
            try {
                var pass_data = JSON.parse(event.data);
                console.log(pass_data);
                if (pass_data.func)
                    if (pass_data.func == 'link') {
                        helper.openLinkPopup(component, event, pass_data.RIid, pass_data.RIName, pass_data.highlightedDoc);
                    } else if (pass_data.func == 'edit') {
                        helper.openEditPopup(component, event, pass_data.RIid);
                    } else if (pass_data.func == 'setBaseUrl') {
                        component.set("v.BaseUrl", pass_data.RIid);
                    } else if (pass_data.func == 'showFilePrevRI') {
                        $A.get('e.lightning:openFiles').fire({
                            recordIds: [pass_data.RIid]
                        });
                    } else if (pass_data.func == 'fakeCall') {
                        helper.fakeCall(component, event);
                    } else if (pass_data.func == 'setDDNameLabel') {
                        component.set("v.DDLabel", pass_data.RIid);
                    } else if (pass_data.func == 'openNewRICreatingPopup') {
                        var createRecordEvent = $A.get("e.force:createRecord");
                        createRecordEvent.setParams({
                            "entityApiName": "review_item__c",
                            "defaultFieldValues": {
                                "Assessment__c": pass_data.RIid
                            }
                        });
                        createRecordEvent.fire();
                    } else if (pass_data.func == 'navigateTo') {
                        var navEvt = $A.get("e.force:navigateToSObject");
                        navEvt.setParams({
                            "recordId": pass_data.RIid,
                            "slideDevName": "detail"
                        });
                        navEvt.fire();
                    }
            } catch (e) { }
        });

        if (component.get("v.ShowDDchecklist") == 'Yes') {
            var cheight = parseInt(component.get("v.componentHeight"));
            component.set("v.componentHeight", cheight + 400);
        }

        component.set("v.isCreateable", false);
        var action = component.get("c.getInitValuesWrapper");
        action.setParams({
            "recId": component.get("v.recordId")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.isCreateable", response.getReturnValue().isCreateable);
                component.set("v.accId", response.getReturnValue().accId);
                component.set("v.ddId", response.getReturnValue().ddId);
                console.log(response.getReturnValue());
            }
        });
        $A.enqueueAction(action);


    },

    changeViewStyle: function (component, event, helper) {
        var pass_data = { 'func': 'changeViewStyle', 'style': component.get("v.mode") };

        try {
            var vfWindow = component.find("ariFrame").getElement().contentWindow;
            vfWindow.postMessage(JSON.stringify(pass_data), component.get("v.BaseUrl"));
        } catch (e) {
            var vfWindow = document.getElementById("ariFrame").contentWindow;
            vfWindow.postMessage(JSON.stringify(pass_data), component.get("v.BaseUrl"));
        }

    },
    sendRefreshDD: function (component, event, helper) {
        var pass_data = { 'func': 'updateDDGrid' };

        try {
            var vfWindow = component.find("ariFrame").getElement().contentWindow;
            vfWindow.postMessage(JSON.stringify(pass_data), component.get("v.BaseUrl"));
        } catch (e) {
            var vfWindow = document.getElementById("ariFrame").contentWindow;
            vfWindow.postMessage(JSON.stringify(pass_data), component.get("v.BaseUrl"));
        }

    },
    createRecord: function (component, event, helper) {
        var createRecordEvent = $A.get("e.force:createRecord");
        createRecordEvent.setParams({
            "entityApiName": "Assessment__c",
            "defaultFieldValues": {
                "Account__c": component.get("v.accId")
            }
        });
        /*createRecordEvent.setParams({
            "entityApiName": "review_item__c",
            "defaultFieldValues": {
                "Assessment__c": component.get("v.recordId")
            }
        });*/
        createRecordEvent.fire();
    }

})