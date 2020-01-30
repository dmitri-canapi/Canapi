({
    init: function (cmp, event, helper) {
        helper.fetchData(cmp, event, helper);
        window.addEventListener("message", function (event) {
            try {
                var pass_data = JSON.parse(event.data);
                console.log(pass_data);
                if (pass_data.func)
                    if (pass_data.func == 'editUser') {
                        helper.createTeamManagementUserEditComponent(cmp, pass_data.id);
                    } else if (pass_data.func == 'resetPass') {
                        helper.resetPass(cmp, pass_data.id);
                    } else if (pass_data.func == 'inviteToPortal') {
                        cmp.set("v.ContactInviteType", pass_data.type);
                        helper.openEditContactModal(cmp, pass_data.id);
                    } else if (pass_data.func == 'iframeLoaded') {
                        if (cmp.get("v.ifrHeight") != String(pass_data.bodyHeight) && cmp.get("v.reloadAttempts") < 1) {
                            //console.log(cmp.get("v.ifrHeight"));
                            //console.log(String(pass_data.bodyHeight));
                            cmp.set("v.ifrHeight", String(pass_data.bodyHeight));
                            var reloadAttempts = cmp.get("v.reloadAttempts") + 1;
                            cmp.set("v.reloadAttempts", reloadAttempts);

                            window.setTimeout(
                                $A.getCallback(function () {
                                    cmp.set("v.opacity", '1');
                                }), 2000
                            );
                        }


                        /*var a = cmp.get('c.iframeLoaded');
                        $A.enqueueAction(a);*/
                    } else if (pass_data.func == 'setBaseUrl') {
                        cmp.set("v.BaseUrl", pass_data.url);
                    } else if (pass_data.func == 'showMessage') {
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title: 'Success!',
                            message: pass_data.message,
                            type: pass_data.type,
                            mode: 'pester'
                        });
                        toastEvent.fire();
                    } else if (pass_data.func == 'refreshData') {
                        helper.fetchData(cmp, event, helper);
                    } else if (pass_data.func == 'navigateTo') {

                        var navEvt = $A.get("e.force:navigateToSObject");
                        navEvt.setParams({
                            "recordId": pass_data.id,
                            "slideDevName": "detail"
                        });
                        navEvt.fire();
                    }

            } catch (e) { }
        }, false);

        window.onscroll = function () {

            var pass_data = { 'func': 'setScrollTop', 'top': window['scrollY'] };

            try {
                var vfWindow = cmp.find("vfFrame").getElement().contentWindow;
                vfWindow.postMessage(JSON.stringify(pass_data), cmp.get("v.BaseUrl") + 'apex/TeamManagementDHTMLX?recordId=' + cmp.get("v.recordId"));
            } catch (e) {
                //var vfWindow = document.getElementById("vfFrame").contentWindow;
                //vfWindow.postMessage(JSON.stringify(pass_data), cmp.get("v.BaseUrl") + 'apex/TeamManagementDHTMLX?recordId=' + cmp.get("v.recordId"));
            }
        };

    },
    filterData: function (cmp, event, helper) {
        var pass_data = { 'func': 'filterData', 'order': cmp.get("v.order"), 'filterWord': cmp.get("v.filter") };
        try {
            var vfWindow = cmp.find("vfFrame").getElement().contentWindow;
            vfWindow.postMessage(JSON.stringify(pass_data), cmp.get("v.BaseUrl") + 'apex/TeamManagementDHTMLX?recordId=' + cmp.get("v.recordId"));
        } catch (e) { }
    },
    clearFilter: function (component, event, helper) {
        component.set('v.filter', '');
        var a = component.get('c.filterData');
        $A.enqueueAction(a);
    },
    changeViewStyle: function (cmp, event, helper) {
        cmp.set('v.filter', '');
        var a = cmp.get('c.filterData');
        $A.enqueueAction(a);
        var pass_data = { 'func': 'changeViewStyle', 'style': cmp.get("v.viewStyle") };
        var vfWindow = cmp.find("vfFrame").getElement().contentWindow;
        vfWindow.postMessage(JSON.stringify(pass_data), cmp.get("v.BaseUrl") + 'apex/TeamManagementDHTMLX?recordId=' + cmp.get("v.recordId"));
    },

    resetPassjs: function (component, event, helper) {
        helper.resetPass(component, event.target.getAttribute("data-rowId"));
    },

    closeModal: function (component, event, helper) {
        var cmpTarget = component.find('Modalbox');
        var cmpBack = component.find('Modalbackdrop');
        $A.util.removeClass(cmpBack, 'slds-backdrop--open');
        $A.util.removeClass(cmpTarget, 'slds-fade-in-open');
        //$A.get('e.force:refreshView').fire();
    },
    openmodal: function (component, event, helper) {

        var cmpTarget = component.find('Modalbox');
        var cmpBack = component.find('Modalbackdrop');
        $A.util.addClass(cmpTarget, 'slds-fade-in-open');
        $A.util.addClass(cmpBack, 'slds-backdrop--open');

        var user = component.get("v.newUser");
        user.FirstName = '';
        user.LastName = '';
        user.Phone = '';
        user.Email = '';
        user.Title = '';
        user.MobilePhone = '';
        user.Department = '';
        user.ContactId = null;
        user.Manager__c = null;
        component.set("v.newUser", user);
        component.set("v.ContactInviteType", "New Contact");

    },
    createUser: function (component, event, helper) {
        helper.createUser(component, event, helper);
    }
})