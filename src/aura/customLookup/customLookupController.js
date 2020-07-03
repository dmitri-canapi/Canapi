({
    onfocus: function (component, event, helper) {
        $A.util.addClass(component.find("mySpinner"), "slds-show");
        var forOpen = component.find("searchRes");
        $A.util.addClass(forOpen, 'slds-is-open');
        $A.util.removeClass(forOpen, 'slds-is-close');
        // Get Default 5 Records order by createdDate DESC  
        var getInputkeyWord = component.get("v.SearchKeyWord");
        if ((getInputkeyWord != null && getInputkeyWord != '') || component.get("v.objectAPIField") == 'Title')
            helper.searchHelper(component, event, getInputkeyWord);
    },
    onblur: function (component, event, helper) {

        setTimeout(function () {
            component.set("v.listOfSearchRecords", null);
            var forclose = component.find("searchRes");
            $A.util.addClass(forclose, 'slds-is-close');
            $A.util.removeClass(forclose, 'slds-is-open');
        }, 200);

    },
    clearCustomlookupValue: function (component, event, helper) {

    },
    keyPressController: function (component, event, helper) {
        // get the search Input keyword   
        var getInputkeyWord = component.get("v.SearchKeyWord");
        // check if getInputKeyWord size id more then 0 then open the lookup result List and 
        // call the helper 
        // else close the lookup result List part.   
        if (getInputkeyWord.length > 0 || component.get("v.objectAPIField") == 'Title') {
            var forOpen = component.find("searchRes");
            $A.util.addClass(forOpen, 'slds-is-open');
            $A.util.removeClass(forOpen, 'slds-is-close');
            helper.searchHelper(component, event, getInputkeyWord);
        }
        else {
            component.set("v.listOfSearchRecords", null);
            var forclose = component.find("searchRes");
            $A.util.addClass(forclose, 'slds-is-close');
            $A.util.removeClass(forclose, 'slds-is-open');
        }
        component.set("v.selectedRecord", getInputkeyWord);
        component.set("v.selectedRecordLabel", getInputkeyWord);
    },

    // function for clear the Record Selaction 
    clear: function (component, event, heplper) {
        console.log('clear');
        var pillTarget = component.find("lookup-pill");
        var lookUpTarget = component.find("lookupField");

        $A.util.addClass(pillTarget, 'slds-hide');
        $A.util.removeClass(pillTarget, 'slds-show');

        $A.util.addClass(lookUpTarget, 'slds-show');
        $A.util.removeClass(lookUpTarget, 'slds-hide');

        component.set("v.SearchKeyWord", null);
        component.set("v.listOfSearchRecords", null);
        component.set("v.selectedRecord", {});
        component.set("v.selectedRecordLabel", '');
    },

    // This function call when the end User Select any record from the result list.   
    handleComponentEvent: function (component, event, helper) {

        var selectedAccountGetFromEvent = event.getParam("recordByEvent");
        if (component.get("v.objectAPIField") == 'Title') {
            component.set("v.SearchKeyWord", event.getParam("recordLabel"));
            component.set("v.selectedRecordLabel", event.getParam("recordLabel"));
            component.set("v.selectedRecord", event.getParam("recordLabel"));

            var action = component.get("c.fetchLookUpValues");
            // set param to method  
            action.setParams({
                'searchKeyWord': event.getParam("recordLabel"),
                'ObjectName': component.get("v.objectAPIName"),
                'objectAPIField': 'FirstName',
                'accId': component.get("v.accId")
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                console.log(state);
                if (state === "SUCCESS") {
                    //component.find("inpControl").focus();
                    var storeResponse = response.getReturnValue();
                    console.log(storeResponse);
                    // if storeResponse size is equal 0 ,display No Result Found... message on screen.                }
                    if (storeResponse.length != 0) {
                        component.set("v.listOfSearchRecords", storeResponse);
                    }
                    // set searchResult list with return value from server.


                }

            });

            //$A.enqueueAction(action);

            setTimeout(function () {
                console.log('searching1');
                var forOpen = component.find("searchRes");
                $A.util.addClass(forOpen, 'slds-is-open');
                $A.util.removeClass(forOpen, 'slds-is-close');

                $A.getCallback(function () {
                    try {
                        component.find("inpControl").focus();
                    } catch (e) { }
                    $A.enqueueAction(action);
                })();
                //helper.searchHelper(component, event, event.getParam("recordLabel"), 'FirstName');



                /*helper.serverSideCall(component, action).then(
                    function (res) {
                        component.set("v.listOfSearchRecords", res);
                    }
                ).catch(
                    function (error) {
                        console.log(error);
                    }
                );*/


                setTimeout(function () {
                    //try {
                    //component.find("inpControl").focus();
                    //} catch (e) { }
                }, 250);

            }, 350);

        } else {

            component.set("v.selectedRecord", selectedAccountGetFromEvent);
            component.set("v.selectedRecordLabel", event.getParam("recordLabel"));

            var forclose = component.find("lookup-pill");
            $A.util.addClass(forclose, 'slds-show');
            $A.util.removeClass(forclose, 'slds-hide');

            var forclose = component.find("searchRes");
            $A.util.addClass(forclose, 'slds-is-close');
            $A.util.removeClass(forclose, 'slds-is-open');

            var lookUpTarget = component.find("lookupField");
            $A.util.addClass(lookUpTarget, 'slds-hide');
            $A.util.removeClass(lookUpTarget, 'slds-show');
        }

    },
})