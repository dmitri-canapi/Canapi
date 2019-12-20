({
    fetchData: function (cmp, event, helper) {
        var action = cmp.get("c.getUsers");
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
            }
            // error handling when state is "INCOMPLETE" or "ERROR"
        });
        $A.enqueueAction(action);
    },
    getRowActions: function (cmp, row, doneCallback) {
        console.log(row);
        var actions = [];

        if (row.rowType == 'Contact') {
            actions.push({ label: 'Invite To Portal', name: 'Invite', 'iconName': 'utility: groups' });
        } else {
            actions.push({ label: 'Edit User', name: 'Edit', 'iconName': 'utility: edit' });
            actions.push({ label: 'Send password reset link', name: 'resetPass', 'iconName': 'utility: edit' });
        }


        // simulate a trip to the server
        setTimeout($A.getCallback(function () {
            doneCallback(actions);
        }), 50);
    },
    openmodalForGrid: function (component, rowId) {
        var cmpTarget = component.find('Modalbox');
        var cmpBack = component.find('Modalbackdrop');
        $A.util.addClass(cmpTarget, 'slds-fade-in-open');
        $A.util.addClass(cmpBack, 'slds-backdrop--open');

        if (rowId) {
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
            });
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
        $A.createComponent("c:TeamManagementUserEdit", { recordId: rowId },
            function (content, status) {
                console.log(status);
                if (status === "SUCCESS") {
                    component.find('overlayLib').showCustomModal({
                        header: "User  Edit",
                        body: content,
                        showCloseButton: true,
                        cssClass: "mymodal",

                    })
                }
            });
    },
    createUser: function (component, event, helper) {
        var record = component.get("v.newUser");
        if (record.Email == '' || record.LastName == '') {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title: 'Error',
                message: 'Please, complete all required fields.',
                type: 'error',
                mode: 'pester'
            });
            toastEvent.fire();
        } else {
            var data = component.get("v.contactsData");
            var isDupl = false;
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
                var conf = confirm("Contact " + record.FirstName + " " + record.LastName + " already exists. Would you like to invite them to the Portal");
                if (conf == true) {
                    isDupl = false;
                }
            }
            if (!isDupl) {
                var action = component.get("c.saveRecordContr");
                action.setParams({ UserRec: JSON.stringify(component.get("v.newUser")) });
                action.setCallback(this, function (response) {
                    var state = response.getState();
                    if (component.isValid() && state == 'SUCCESS') {
                        $A.get('e.force:refreshView').fire();
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