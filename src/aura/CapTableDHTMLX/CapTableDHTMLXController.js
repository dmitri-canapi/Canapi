({
    setHasRounds: function (component, event) {
        var recId = component.get("v.recordId");
        if (recId == null) {
            var action = component.get("c.getCommunityAccId");
            action.setCallback(this, function (response) {
                component.set("v.recordId", response.getReturnValue());
                recId = response.getReturnValue();
                var action2 = component.get("c.hasRounds");
                action2.setParams({ accountId: recId });
                action2.setCallback(this, function (response2) {
                    var state = response2.getState();
                    if (state === "SUCCESS") {
                        console.log(response2.getReturnValue());
                        component.set("v.hasRounds", response2.getReturnValue().hasRounds);
                        component.set("v.isCommunityUser", response2.getReturnValue().isCommunityUser);
                        component.set("v.isAllowEditing", response2.getReturnValue().isAllowEditing);
                        component.set("v.series.Target_Company__c", component.get("v.recordId"));
                    } else {
                        alert(response2);
                    }
                });
                $A.enqueueAction(action2);
            });
            $A.enqueueAction(action);
        } else {
            var action = component.get("c.hasRounds");
            action.setParams({ accountId: component.get("v.recordId") });
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    console.log(response.getReturnValue());
                    component.set("v.hasRounds", response.getReturnValue().hasRounds);
                    component.set("v.isCommunityUser", response.getReturnValue().isCommunityUser);
                    component.set("v.isAllowEditing", response.getReturnValue().isAllowEditing);
                    component.set("v.series.Target_Company__c", response.getReturnValue().accountId);
                    if (component.get("v.recordId") != response.getReturnValue().accountId) {
                        component.set("v.recordId", response.getReturnValue().accountId);
                    }

                } else {
                    alert(response);
                }
            });
            $A.enqueueAction(action);
        }

        window.addEventListener("message", function (event) {
            if (event.data && typeof event.data === "string") {
                if (event.data.includes('new_shareholder')) {
                    component.set("v.showNewShareholder", true);
                } else if (event.data.includes('new_series')) {
                    component.set("v.showNewRound", true);
                } else if (event.data.includes('setBaseUrl')) {
                    component.set("v.BaseUrl", event.data.split('-del-')[1]);
                }
            }
        }, false);

    },

    showAddForm: function (component, event) {
        var selAcc = component.find("selectAccForm");
        $A.util.removeClass(selAcc, "slds-show");
        $A.util.addClass(selAcc, "slds-hide");
        var newAcc = component.find("NewAccForm");
        $A.util.removeClass(newAcc, "slds-hide");
        $A.util.addClass(newAcc, "slds-show");

    },

    closeModal: function (component, event, helper) {
        component.set("v.showNewShareholder", false);
        component.set("v.showNewRound", false);
        component.set("v.acc.Name", '');
        component.set("v.isConfirmed", false);
        component.set("v.selectedAcc", null);
        component.set("v.searchTextAccount", null);
        component.set("v.selectedParentAcc", null);
        component.set("v.searchTextParentAccount", null);
    },

    showNewRecord: function (component, event) {
        if (component.get("v.isCommunityUser") == false || (component.get("v.isCommunityUser") == true && component.get("v.isAllowEditing") == true)) {
            component.set("v.showNewShareholder", event.getParam("ShowNewShareHolder"));
            component.set("v.showNewRound", event.getParam("ShowNewRound"));
        }
    },
    changeFilter: function (component, event) {
        console.log('changeFilter');
        var compEvent = $A.get("e.c:Cap_ChangeFilter");

        compEvent.setParams({ "filter": component.get("v.filterValue") });
        compEvent.fire();
    },

    saveSeries: function (component, event, helper) {
        if (component.get("v.series.Series_Type__c") == '') {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title: 'Error',
                message: 'Please, fill in all required fields!',
                type: 'error',
                mode: 'pester'
            });
            toastEvent.fire();
        } else {
            var action = component.get("c.saveNewRound");
            action.setParams({ TTrec: JSON.stringify(component.get("v.series")) });
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    component.set("v.showNewRound", false);
                    try {
                        var vfWindow = component.find("vfFrame").getElement().contentWindow;
                        vfWindow.postMessage('RefreshGrid', component.get("v.BaseUrl") + 'apex/CapTableDHTMLXPage?recordId=' + component.get("v.recordId"));
                    } catch (e) {
                        var vfWindow = document.getElementById("vfFrame").contentWindow;
                        vfWindow.postMessage('RefreshGrid', component.get("v.BaseUrl"));
                    }
                } else {
                    console.log('Failed with state: ' + state);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title: 'Error',
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

    onChange: function (component, event, helper) {
        /*const inputName = event.getSource().get('v.name');
        const inputValue = event.getSource().get('v.value');*/
        console.log(event);
        console.log(event.which);
    },

    saveShareholder: function (component, event, helper) {
        console.log(component.get("v.searchTextAccount"));
        console.log(component.get("v.selectedAcc.Id"));

        if (!component.get("v.selectedAcc.Id") && (!component.get("v.searchTextAccount") || component.get("v.searchTextAccount") == '')) {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title: 'Error',
                message: 'Please, select account.',
                type: 'error',
                mode: 'pester'
            });
            toastEvent.fire();
            return;
        }

        if ((!component.get("v.selectedAcc.Id") && (component.get("v.searchTextAccount") && component.get("v.searchTextAccount") != '') && !component.get("v.isConfirmed"))
        ) {
            var isconfirmed = confirm('Account not found. Would you like to create a new one?');
            if (isconfirmed) {

                component.set("v.isConfirmed", true);
                var selAcc = component.find("selectAccForm");
                $A.util.removeClass(selAcc, "slds-show");
                $A.util.addClass(selAcc, "slds-hide");
                var newAcc = component.find("NewAccForm");
                $A.util.removeClass(newAcc, "slds-hide");
                $A.util.addClass(newAcc, "slds-show");
            }
            return;
        }

        if (component.get("v.selectedAcc.Id") || component.get("v.isConfirmed")) {
            var action = component.get("c.addShareholder");

            action.setParams({ accountId: component.get("v.selectedAcc.Id"), AccName: component.get("v.searchTextAccount"), parentAccountId: component.get("v.selectedParentAcc.Id"), parentAccountName: component.get("v.searchTextParentAccount"), currentAcc: component.get("v.recordId") });
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    component.set("v.showNewShareholder", false);

                    try {
                        var vfWindow = component.find("vfFrame").getElement().contentWindow;
                        vfWindow.postMessage('RefreshGrid', component.get("v.BaseUrl") + 'apex/CapTableDHTMLXPage?recordId=' + component.get("v.recordId"));
                    } catch (e) {
                        var vfWindow = document.getElementById("vfFrame").contentWindow;
                        vfWindow.postMessage('RefreshGrid', component.get("v.BaseUrl"));
                    }
                    component.set("v.selectedAcc", null);
                    component.set("v.searchTextAccount", null);
                    component.set("v.selectedParentAcc", null);
                    component.set("v.searchTextParentAccount", null);
                    component.set("v.isConfirmed", false);
                } else {
                    alert(response);
                }
            });
            $A.enqueueAction(action);
        }

    }
})