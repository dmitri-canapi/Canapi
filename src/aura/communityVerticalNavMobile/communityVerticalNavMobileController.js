({

    doInit: function (component, event, helper) {

        var action = component.get("c.getGroups");

        action.setCallback(this, function (response) {
            var groups = [];
            groups = response.getReturnValue();

            var menus = [];

            var childmmenus = [];
            childmmenus.push(helper.createObj('Home', '18-Canapi-Icons-28.svg', 'https://canapi.force.com/alliance/s/'));
            childmmenus.push(helper.createObj('Feed', '18-Canapi-Icons-32.svg', 'fintech-companies'));
            childmmenus.push(helper.createObj('Subscriptions', '18-Canapi-Icons-10.svg', 'subscriptions'));
            menus.push(helper.createObj('Home', '18-Canapi-Icons-28.svg', null, childmmenus));

            var childmmenus = [];
            childmmenus.push(helper.createObj('Fintech Companies', '18-Canapi-Icons-32.svg', 'fintech-companies'));
            childmmenus.push(helper.createObj('Portfolio Companies', '18-Canapi-Icons-05.svg', 'portfolio'));
            childmmenus.push(helper.createObj('Maps', '18-Canapi-Icons-42.svg', 'map'));
            childmmenus.push(helper.createObj('Alliance Contacts', '18-Canapi-Icons-10.svg', 'people'));
            menus.push(helper.createObj('Fintech Directory', '18-Canapi-Icons-32.svg', null, childmmenus));

            childmmenus = [];
            childmmenus.push(helper.createObj('Canapi Calendar', '18-Canapi-Icons-36.svg', 'calendar'));
            for (let gr of groups) {
                childmmenus.push(helper.createObj(gr.Name, '18-Canapi-Icons-08.svg', 'group/' + gr.Id));
            }
            /*childmmenus.push(helper.createObj('Canapi News', '18-Canapi-Icons-08.svg', '#'));
            childmmenus.push(helper.createObj('Industry News', '18-Canapi-Icons-08.svg', '#'));*/
            menus.push(helper.createObj('Forums', '18-Canapi-Icons-08.svg', '#', childmmenus));


            menus.push(helper.createObj('Reports', '18-Canapi-Icons-32.svg', 'report/Report/Recent?queryScope=mru'));
            menus.push(helper.createObj('Dashboards', '18-Canapi-Icons-39.svg', 'dashboard/01Z6A000000Cc3PUAS'));


            childmmenus = [];
            var userId = $A.get("$SObjectType.CurrentUser.Id");
            childmmenus.push(helper.createObj('My Profile', '18-Canapi-Icons-14.svg', 'profile/' + userId));
            childmmenus.push(helper.createObj('My Settings', '18-Canapi-Icons-09.svg', 'settings/' + userId));
            childmmenus.push(helper.createObj('My Company', '18-Canapi-Icons-31.svg', 'my-account'));
            childmmenus.push(helper.createObj('Subscriptions', '18-Canapi-Icons-10.svg', '#'));
            childmmenus.push(helper.createObj('Vendor Mapping', '18-Canapi-Icons-27.svg', '#'));
            menus.push(helper.createObj('Setup', '18-Canapi-Icons-09.svg', 'settings/' + userId, childmmenus));

            menus.push(helper.createObj('Logout', '18-Canapi-Icons-06.svg', '../secur/logout.jsp'));

            component.set('v.menus', menus);
        });
        $A.enqueueAction(action);
    },

    onClick: function (component, event, helper) {
        var id = event.target.dataset.menuItemId;
        if (id) {
            component.getSuper().navigate(id);
        }
    },
    showLabels: function (component, event, helper) {
        var lbls = component.find('itemLabel');
        for (var cmp in lbls) {
            $A.util.removeClass(lbls[cmp], 'slds-hide');
            $A.util.addClass(lbls[cmp], 'slds-show');
        }
        component.set('v.showMenu', false);
    },
    hideLabels: function (component, event, helper) {
        var lbls = component.find('itemLabel');
        for (var cmp in lbls) {
            $A.util.addClass(lbls[cmp], 'slds-hide');
            $A.util.removeClass(lbls[cmp], 'slds-show');
        }
        component.set('v.showMenu', true);
    },

    switchMenuState: function (component, event, helper) {
        var lbls = component.find('itemLabel');
        var customNav = component.find('customNav');
        if (component.get('v.showMenu') == true) {
            for (var cmp in lbls) {
                $A.util.addClass(lbls[cmp], 'slds-hide');
                $A.util.removeClass(lbls[cmp], 'slds-show');
            }
            $A.util.removeClass(customNav, 'menuExpanded');
            component.set('v.showMenu', false);
        } else {
            for (var cmp in lbls) {
                $A.util.removeClass(lbls[cmp], 'slds-hide');
                $A.util.addClass(lbls[cmp], 'slds-show');
            }
            $A.util.addClass(customNav, 'menuExpanded');
            component.set('v.showMenu', true);
        }
    }
})