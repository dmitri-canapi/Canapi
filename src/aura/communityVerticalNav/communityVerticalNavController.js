({

  doInit: function(component, event, helper) {
      var menus = [];
      var childmmenus = [];
      childmmenus.push(helper.createObj('Feed', '18-Canapi-Icons-32.svg','fintech-companies', null, 12));
      childmmenus.push(helper.createObj('Subscriptions', '18-Canapi-Icons-10.svg','subscriptions', null, 11));
      menus.push(helper.createObj('Home', '18-Canapi-Icons-28.svg','https://canapi.force.com/alliance/s/', childmmenus, 0));
      
      var childmmenus = [];
      childmmenus.push(helper.createObj('Fintech Companies', '18-Canapi-Icons-32.svg','fintech-companies', null, 1));
      childmmenus.push(helper.createObj('Portfolio Companies', '18-Canapi-Icons-05.svg','portfolio', null, 2));
      childmmenus.push(helper.createObj('Maps', '18-Canapi-Icons-42.svg','map', null, 3));
      childmmenus.push(helper.createObj('Alliance Contacts', '18-Canapi-Icons-10.svg','people', null, 4));
      menus.push(helper.createObj('Fintech Directory', '18-Canapi-Icons-32.svg','fintech-companies',childmmenus, 1));
      
      childmmenus = [];
      childmmenus.push(helper.createObj('Canapi Calendar', '18-Canapi-Icons-36.svg','calendar', null, 8));
      childmmenus.push(helper.createObj('Canapi News', '18-Canapi-Icons-08.svg','group/0F93u000000m1A2CAI/canapi-news-announcements'));
      childmmenus.push(helper.createObj('Industry News', '18-Canapi-Icons-08.svg','group/0F93u000000m19dCAA/industry-news'));
      childmmenus.push(helper.createObj('Fintech Alliance Forum', '18-Canapi-Icons-08.svg','group/0F93u000000m19nCAA/fintech-alliance-forum'));
      childmmenus.push(helper.createObj('Alliance Contacts', '18-Canapi-Icons-10.svg','report/00O6A000006MlwCUAS/alliance-contacts?queryScope=userFolders'));
      childmmenus.push(helper.createObj('Canapi Contacts', '18-Canapi-Icons-10.svg','report/00O3u000006YINmEAO/canapi-contacts?queryScope=userFolders'));
      menus.push(helper.createObj('News', '18-Canapi-Icons-08.svg','#news2',childmmenus));
      
      /*childmmenus = [];
      childmmenus.push(helper.createObj('Fund Docs', '18-Canapi-Icons-11.svg','files', null, 5));
      childmmenus.push(helper.createObj('Quarterly Reports', '18-Canapi-Icons-15.svg','#QR'));
      menus.push(helper.createObj('Files', '18-Canapi-Icons-11.svg','files',childmmenus, 5));*/
      
      menus.push(helper.createObj('Reports', '18-Canapi-Icons-32.svg','report/Report/Recent?queryScope=mru', null, 6));
      menus.push(helper.createObj('Dashboards', '18-Canapi-Icons-39.svg','dashboard/01Z6A000000Cc3PUAS', null, 7));
      /*childmmenus = [];
      childmmenus.push(helper.createObj('Reports', '18-Canapi-Icons-32.svg','report/Report/Recent?queryScope=mru', null, 6));
      childmmenus.push(helper.createObj('Dashboards', '18-Canapi-Icons-39.svg','dashboard/01Z6A000000Cc3PUAS', null, 7));
      menus.push(helper.createObj('Business Intelligence', '18-Canapi-Icons-32.svg','#BI',childmmenus));*/
      
      childmmenus = [];
      var userId = $A.get( "$SObjectType.CurrentUser.Id" );
      childmmenus.push(helper.createObj('My Profile', '18-Canapi-Icons-14.svg', 'profile/' + userId, null, 9));
      childmmenus.push(helper.createObj('My Settings', '18-Canapi-Icons-09.svg','settings/' + userId, null, 'settings'));
      childmmenus.push(helper.createObj('My Company', '18-Canapi-Icons-31.svg','MY',null,14));
      //childmmenus.push(helper.createObj('Subscriptions', '18-Canapi-Icons-10.svg','subscriptions', null, 11));
      childmmenus.push(helper.createObj('Vendor Mapping', '18-Canapi-Icons-27.svg','AllianceEnrollment',null,13));
      menus.push(helper.createObj('Setup','18-Canapi-Icons-09.svg',  'settings/' + userId,childmmenus));
      
      menus.push(helper.createObj('Logout', '18-Canapi-Icons-06.svg','../secur/logout.jsp', null, 'logout'));

      component.set('v.menus', menus);
      
      var a = component.get('c.switchMenuState'); // open by default
      $A.enqueueAction(a);
      
  },
    
   onClick : function(component, event, helper) {
       var id = event.target.dataset.menuItemId;
       if (id) {
           var menus = component.get('v.menus');
           for (let menu of menus){
               menu.active = false;
               if (menu.Id != null && menu.Id == id){
                   menu.active = true;
               }
               if (menu.menus) {
                   for (let childmenu of menu.menus){
                       childmenu.active = false;
                       if (childmenu.Id != null && childmenu.Id == id){
                           childmenu.active = true;
                       }
                   }
               }
           }
           component.set("v.menus", menus);
           
           if (id == 'logout'){
               var urlEvent = $A.get("e.force:navigateToURL");
               urlEvent.setParams({
                   "url": 'https://canapi.force.com/alliance/secur/logout.jsp'
               });
               urlEvent.fire();
           } else if (id == 'settings'){
               var userId = $A.get( "$SObjectType.CurrentUser.Id" );
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
           for (let menu of menus){
               menu.active = false;
               if (menu.link != null && menu.link == event.target.dataset.menuItemLink){
                   menu.active = true;
               }
               if (menu.menus) {
                   for (let childmenu of menu.menus){
                       childmenu.active = false;
                       if (childmenu.link != null && childmenu.link == event.target.dataset.menuItemLink){
                           childmenu.active = true;
                       }
                   }
               }
           }
           component.set("v.menus", menus);
           
           var urlEvent = $A.get("e.force:navigateToURL");
           urlEvent.setParams({
               "url": event.target.dataset.menuItemLink
           });
           urlEvent.fire();
       }
  },
    showLabels : function(component, event, helper) {
        var lbls = component.find('itemLabel');
        for(var cmp in lbls) {
        	$A.util.removeClass(lbls[cmp], 'slds-hide');
            $A.util.addClass(lbls[cmp], 'slds-show');
        }
    },
    hideLabels: function(component, event, helper) {
        var lbls = component.find('itemLabel');
        for(var cmp in lbls) {
        	$A.util.addClass(lbls[cmp], 'slds-hide');
            $A.util.removeClass(lbls[cmp], 'slds-show');
        }
    },
    switchMenuState: function(component, event, helper) {
        var lbls = component.find('itemLabel');
        var customNav  = component.find('customNav');
        if( component.get('v.showMenu')== true ){
            for(var cmp in lbls) {
                $A.util.addClass(lbls[cmp], 'slds-hide');
                $A.util.removeClass(lbls[cmp], 'slds-show');
            }
             $A.util.removeClass(customNav, 'menuExpanded');
            component.set('v.showMenu', false);
        } else {
            for(var cmp in lbls) {
                $A.util.removeClass(lbls[cmp], 'slds-hide');
                $A.util.addClass(lbls[cmp], 'slds-show');
            }
            $A.util.addClass(customNav, 'menuExpanded');
            component.set('v.showMenu', true);
        }
    }
})