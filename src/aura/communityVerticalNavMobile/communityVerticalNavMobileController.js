({

    doInit: function (component, event, helper) {
        if (window.location.href.includes('https://canapi.force.com/alliance')) {
            component.set("v.CommunityName", 'alliance');
        } else {
            component.set("v.CommunityName", 'fintech');
        }

        if (window.location.href.includes('https://canapi.force.com/' + component.get("v.CommunityName") + '/s/settings/' + $A.get("$SObjectType.CurrentUser.Id"))) {
            component.set("v.renderMenu", false);
        }

        var action = component.get("c.getSettings");

        action.setCallback(this, function (response) {
            var groups = [];
            console.log(response.getReturnValue());
            groups = response.getReturnValue().groups;

            var menus = [];

            if (component.get("v.CommunityName") == 'alliance') {
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

            } else if (component.get("v.CommunityName") == 'fintech') {
                menus.push(helper.createObj( 'Home', '18-Canapi-Icons-28.svg', 'https://canapi.force.com/fintech/s/'));
                menus.push(helper.createObj( 'Deals', '18-Canapi-Icons-05.svg', 'deals'));
                childmmenus = [];
                for (let gr of groups) {
                    childmmenus.push(helper.createObj(gr.Name, '18-Canapi-Icons-08.svg', 'group/' + gr.Id));
                }
                menus.push(helper.createObj('Forums', '18-Canapi-Icons-08.svg', '#', childmmenus));
                
                if (response.getReturnValue().recTypeName == 'Fintech' || response.getReturnValue().recTypeName == 'Portfolio Company') {
                    menus.push(helper.createObj( 'DD Checklists', '18-Canapi-Icons-37.svg', 'dd-checklists'));
                }
                if (response.getReturnValue().recTypeName != 'Fintech') {
                    menus.push(helper.createObj( 'Milestones', '18-Canapi-Icons-25.svg', 'milestone/milestone__c/00B6A0000074msgUAA'));
                    menus.push(helper.createObj( 'Cap Table', '18-Canapi-Icons-15.svg', 'cap-table'));
                    //menus.push(helper.createObj( 'DD Checklists', '18-Canapi-Icons-37.svg', 'assessment/Assessment__c/00B6A0000074mJqUAI'));
                    menus.push(helper.createObj( 'Financials', '18-Canapi-Icons-04.svg', 'financials'));
                    menus.push(helper.createObj( 'Pending', '18-Canapi-Icons-31.svg', 'review-item/review_item__c/00B6A000006OfBzUAK'));
                }
            }

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