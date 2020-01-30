({

    doInit: function (component, event, helper) {

        if (window.location.href.includes('https://canapi.force.com/alliance/s/settings/' + $A.get("$SObjectType.CurrentUser.Id"))) {
            component.set("v.renderMenu", false);
        }

        var action = component.get("c.getGroups");

        action.setCallback(this, function (response) {
            var groups = [];
            groups = response.getReturnValue();



            var menus = [];
            var childmmenus = [];
            childmmenus.push(helper.createObj('Feed', '18-Canapi-Icons-32.svg', 'fintech-companies', null, 12));
            childmmenus.push(helper.createObj('Subscriptions', '18-Canapi-Icons-10.svg', 'subscriptions', null, 11));
            menus.push(helper.createObj('Home', '18-Canapi-Icons-28.svg', 'https://canapi.force.com/alliance/s/', childmmenus, 0));

            var childmmenus = [];
            childmmenus.push(helper.createObj('Fintech Companies', '18-Canapi-Icons-32.svg', 'fintech-companies', null, 1));
            childmmenus.push(helper.createObj('Portfolio Companies', '18-Canapi-Icons-05.svg', 'portfolio', null, 2));
            childmmenus.push(helper.createObj('Maps', '18-Canapi-Icons-42.svg', 'map', null, 3));
            childmmenus.push(helper.createObj('Alliance Contacts', '18-Canapi-Icons-10.svg', 'people', null, 4));
            childmmenus.push(helper.createObj('Canapi Contacts', '18-Canapi-Icons-10.svg', 'canapi-contacts'));
            childmmenus.push(helper.createObj('Connections', '18-Canapi-Icons-10.svg', 'connections'));
            menus.push(helper.createObj('Fintech Directory', '18-Canapi-Icons-32.svg', 'fintech-companies', childmmenus, 1));

            childmmenus = [];
            for (let gr of groups) {
                childmmenus.push(helper.createObj(gr.Name, '18-Canapi-Icons-08.svg', 'group/' + gr.Id));
            }

            menus.push(helper.createObj('Forums', '18-Canapi-Icons-08.svg', '#news2', childmmenus));

            menus.push(helper.createObj('Messages', '18-Canapi-Icons-16.svg', 'messages/Home'));
            menus.push(helper.createObj('Calendar', 'Calendar.png', 'calendar'));

            menus.push(helper.createObj('Reports', '18-Canapi-Icons-32.svg', 'reports'));//report/Report/Recent/Report/?queryScope=everything
            menus.push(helper.createObj('Dashboards', '18-Canapi-Icons-39.svg', 'dashboard/01Z6A000000Cc3PUAS', null, 7));

            childmmenus = [];
            var userId = $A.get("$SObjectType.CurrentUser.Id");
            childmmenus.push(helper.createObj('My Profile', '18-Canapi-Icons-14.svg', 'profile/' + userId, null, 9));
            childmmenus.push(helper.createObj('My Settings', '18-Canapi-Icons-09.svg', 'mysettings'));
            childmmenus.push(helper.createObj('My Company', '18-Canapi-Icons-31.svg', 'MY', null, 14));
            childmmenus.push(helper.createObj('Alliance Enrollment', '18-Canapi-Icons-27.svg', 'AllianceEnrollment', null, 13));
            menus.push(helper.createObj('Setup', '18-Canapi-Icons-09.svg', 'settings/' + userId, childmmenus));

            menus.push(helper.createObj('Logout', '18-Canapi-Icons-06.svg', '../secur/logout.jsp', null, 'logout'));

            component.set('v.menus', menus);

            var a = component.get('c.switchMenuState'); // open by default
            $A.enqueueAction(a);



        });
        $A.enqueueAction(action);

        action = component.get("c.hasTags");

        action.setCallback(this, function (response) {
            component.set('v.UserHasTags', response.getReturnValue());

        });
        $A.enqueueAction(action);
    },

    onClick: function (component, event, helper) {
        var id = event.target.dataset.menuItemId;
        if (id) {
            var menus = component.get('v.menus');
            for (let menu of menus) {
                menu.active = false;
                if (menu.Id != null && menu.Id == id) {
                    menu.active = true;
                }
                if (menu.menus) {
                    for (let childmenu of menu.menus) {
                        childmenu.active = false;
                        if (childmenu.Id != null && childmenu.Id == id) {
                            childmenu.active = true;
                        }
                    }
                }
            }
            component.set("v.menus", menus);

            if (id == 'logout') {
                var urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({
                    "url": 'https://canapi.force.com/alliance/secur/logout.jsp'
                });
                urlEvent.fire();
            } else if (id == 'settings') {
                var userId = $A.get("$SObjectType.CurrentUser.Id");
                var urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({
                    "url": 'https://canapi.force.com/alliance/s/settings/' + userId
                });
                urlEvent.fire();
            } else {
                component.getSuper().navigate(id);
            }
        } else {
            var menus = component.get('v.menus');
            for (let menu of menus) {
                menu.active = false;
                if (menu.link != null && menu.link == event.target.dataset.menuItemLink) {
                    menu.active = true;
                }
                if (menu.menus) {
                    for (let childmenu of menu.menus) {
                        childmenu.active = false;
                        if (childmenu.link != null && childmenu.link == event.target.dataset.menuItemLink) {
                            childmenu.active = true;
                        }
                    }
                }
            }
            component.set("v.menus", menus);
            console.log(event.target.dataset.menuItemLink);
            var urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({
                "url": event.target.dataset.menuItemLink
            });
            if ((component.get("v.UserHasTags") == true && event.target.dataset.menuItemLink == 'https://canapi.force.com/alliance/s/connections') || event.target.dataset.menuItemLink != 'https://canapi.force.com/alliance/s/connections') {
                urlEvent.fire();
            }
        }
    },
    showLabels: function (component, event, helper) {
        var lbls = component.find('itemLabel');
        for (var cmp in lbls) {
            $A.util.removeClass(lbls[cmp], 'slds-hide');
            $A.util.addClass(lbls[cmp], 'slds-show');
        }
    },
    hideLabels: function (component, event, helper) {
        var lbls = component.find('itemLabel');
        for (var cmp in lbls) {
            $A.util.addClass(lbls[cmp], 'slds-hide');
            $A.util.removeClass(lbls[cmp], 'slds-show');
        }
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