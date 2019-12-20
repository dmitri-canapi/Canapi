({
    init: function (cmp, event, helper) {

        /*var actions = [
            { label: 'Edit User', name: 'Edit' }
        ];*/
        var actions = helper.getRowActions.bind(this, cmp);

        cmp.set('v.columns', [
            /*{label: 'Id', fieldName: 'Id', type: 'text' },*/
            { label: 'Name', fieldName: 'linkName', type: 'url', typeAttributes: { label: { fieldName: 'Name' }, target: '_self' } },
            { label: 'Title', fieldName: 'Title', type: 'text' },
            { label: 'Phone', fieldName: 'Phone', type: 'phone' },
            { label: 'Email', fieldName: 'Email', type: 'email' },
            { label: 'Type', fieldName: 'rowType', type: 'text' },
            { type: 'action', typeAttributes: { rowActions: actions } }

        ]);
        helper.fetchData(cmp, event, helper);
        cmp.addValueProvider(
            'storage',
            {
                get: function (key, comp) {
                    return sessionStorage.getItem(key);
                },
                set: function (key, value, comp) {
                    sessionStorage.setItem(key, value);
                }
            }
        );
        console.log(cmp.get("storage.value"));
        if (cmp.get("storage.value")) {
            cmp.set('v.viewStyle', cmp.get("storage.value"));
        }

    },
    storeViewStyle: function (component, event, helper) {
        console.log(component.get("v.viewStyle"));
        component.set("storage.value", component.get("v.viewStyle"));
    },
    handleRowAction: function (cmp, event, helper) {
        var row = {};
        try {
            row.Id = event.target.getAttribute("data-rowId");

        } catch (e) {
            row = event.getParam('row');

        }
        console.log('row' + row.Id);

        try {
            var action = event.getParam('action');
            console.log(action.name);
        } catch (e) {
            helper.createTeamManagementUserEditComponent(cmp, row.Id);
        }


        switch (action.name) {

            case 'Invite':
                helper.openmodalForGrid(cmp, row.Id);
                break;
            case 'Edit':
                helper.createTeamManagementUserEditComponent(cmp, row.Id);
                break;
            case 'resetPass':
                helper.resetPass(cmp, row.Id);
                break;
        }
    },

    resetPassjs: function (component, event, helper) {
        helper.resetPass(component, event.target.getAttribute("data-rowId"));
    },

    closeModal: function (component, event, helper) {
        var cmpTarget = component.find('Modalbox');
        var cmpBack = component.find('Modalbackdrop');
        $A.util.removeClass(cmpBack, 'slds-backdrop--open');
        $A.util.removeClass(cmpTarget, 'slds-fade-in-open');
        $A.get('e.force:refreshView').fire();
    },
    openmodal: function (component, event, helper) {

        var cmpTarget = component.find('Modalbox');
        var cmpBack = component.find('Modalbackdrop');
        $A.util.addClass(cmpTarget, 'slds-fade-in-open');
        $A.util.addClass(cmpBack, 'slds-backdrop--open');

        //try {

        var a = event.getSource();
        var id = a.get("v.name");
        if (id) {
            var data = component.get("v.contactsData");
            data.forEach(function (record) {
                if (record.Id == id) {
                    component.set("v.newUser.FirstName", record.FirstName);
                    component.set("v.newUser.LastName", record.LastName);
                    component.set("v.newUser.Phone", record.Phone);
                    component.set("v.newUser.Email", record.Email);
                    component.set("v.newUser.Title", record.Title);
                    component.set("v.newUser.ContactId", id);
                    return;
                }
            });
        }

        //} catch (e) { }


    },
    createUser: function (component, event, helper) {
        helper.createUser(component, event, helper);
    }
})