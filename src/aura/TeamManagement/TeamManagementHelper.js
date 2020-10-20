({
    fetchData: function (cmp, event, helper) {
        var action = cmp.get("c.getUsers");
        action.setParams({ recordId: cmp.get("v.recordId") });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();

                data.users.forEach(function (record) {
                    record.linkName = '/detail/' + record.Id;
                    record.rowType = 'Portal User';
                });
                data.contacts.forEach(function (record) {
                    record.linkName = '/detail/' + record.Id;
                    record.rowType = 'Contact';
                });
                cmp.set('v.usersData', data.users);
                cmp.set('v.contactsData', data.contacts);
                cmp.set('v.data', data.users.concat(data.contacts));
                cmp.set('v.RTname', data.RTname);
            }
            // error handling when state is "INCOMPLETE" or "ERROR"
        });
        $A.enqueueAction(action);
    },
    openEditContactModal: function (component, rowId) {
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
        user.ContactId = null;
        user.Manager__c = null;
        component.set("v.newUser", user);
        console.log(rowId);

        if (rowId) {
            var action = component.get("c.getContact");
            action.setParams({ cId: rowId });
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (component.isValid() && state == 'SUCCESS') {
                    var record = response.getReturnValue();
                    component.set("v.newUser.FirstName", record.FirstName);
                    component.set("v.newUser.LastName", record.LastName);
                    component.set("v.newUser.Phone", record.Phone);
                    component.set("v.newUser.Email", record.Email);
                    component.set("v.newUser.Title", record.Title);
                    component.set("v.newUser.ContactId", rowId);
                }
            });
            $A.enqueueAction(action);
            /*
            var data = component.get("v.contactsData");
            data.forEach(function (record) {
                if (record.Id == rowId) {
                    component.set("v.newUser.FirstName", record.FirstName);
                    component.set("v.newUser.LastName", record.LastName);
                    component.set("v.newUser.Phone", record.Phone);
                    component.set("v.newUser.Email", record.Email);
                    component.set("v.newUser.Title", record.Title);
                    component.set("v.newUser.ContactId", rowId);
                    return;
                }
            });*/
        }
    },
    resetPass: function (component, rowId) {
        var conf = confirm("Reset password for this user?");
        console.log(rowId);
        if (conf == true) {
            var action = component.get("c.resetPass");
            action.setParams({ UserId: rowId });
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (component.isValid() && state == 'SUCCESS') {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title: 'Success!',
                        message: 'Password reset link was sent',
                        type: 'success',
                        mode: 'pester'
                    });
                    toastEvent.fire();
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
    createTeamManagementUserEditComponent: function (component, rowId) {

        //var modalBody;
        try {
            $A.createComponent("c:TeamManagementUserEdit", { recordId: rowId },
                function (content, status) {
                    console.log(status);
                    if (status === "SUCCESS") {
                        component.find('overlayLib').showCustomModal({
                            header: "User Edit",
                            body: content,
                            showCloseButton: true,
                            cssClass: "mymodal"

                        })
                    }
                });
        } catch (e) {
            $A.createComponent("c:TeamManagementUserEdit", { recordId: rowId },
                function (content, status) {
                    console.log(status);
                    if (status === "SUCCESS") {
                        component.find('overlayLib').showCustomModal({
                            header: "User Edit",
                            body: content,
                            showCloseButton: true,
                            cssClass: "mymodal"

                        })
                    }
                });
        }

    },
    createUser: function (component, event, helper) {
        var record = component.get("v.newUser");
        if (record.Email == '' || record.Email == null || record.LastName == '') {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title: 'Error',
                message: 'Please, complete all required fields.',
                type: 'error',
                mode: 'pester'
            });
            toastEvent.fire();
        } else {

            var isDupl = false;
            if (component.get("v.ContactInviteType") == 'Invite to Portal') {
                var data = component.get("v.contactsData");
                data.forEach(function (contact) {
                    contact.FirstName = contact.FirstName ? contact.FirstName : '';
                    console.log(contact.LastName + contact.FirstName);
                    console.log(record.LastName + record.FirstName);
                    if (contact.LastName == record.LastName && contact.FirstName == record.FirstName) {
                        isDupl = true;
                        return;
                    }
                });

                if (isDupl) {
                    var conf = confirm("This will send an email invite to  " + record.FirstName + " " + record.LastName + ". Please select OK to continue");
                    if (conf == true) {
                        isDupl = false;
                    }
                }
            }
            if (!isDupl) {
                console.log(JSON.stringify(component.get("v.newUser")));
                var action = component.get("c.saveRecordContr");
                action.setParams({ UserRec: JSON.stringify(component.get("v.newUser")), InviteType: component.get("v.ContactInviteType"), recordId: component.get("v.recordId") });
                action.setCallback(this, function (response) {
                    var state = response.getState();
                    if (component.isValid() && state == 'SUCCESS') {
                        $A.get('e.force:refreshView').fire();
                        helper.fetchData(component, event, helper);
                        //location.reload();
                        var pass_data = { 'func': 'refreshData' };
                        var vfWindow = component.find("vfFrame").getElement().contentWindow;
                        vfWindow.postMessage(JSON.stringify(pass_data), component.get("v.BaseUrl") + 'apex/TeamManagementDHTMLX?recordId=' + component.get("v.recordId"));

                        var cmpTarget = component.find('Modalbox');
                        var cmpBack = component.find('Modalbackdrop');
                        $A.util.removeClass(cmpBack, 'slds-backdrop--open');
                        $A.util.removeClass(cmpTarget, 'slds-fade-in-open');

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
        }
    }
})