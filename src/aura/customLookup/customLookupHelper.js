({
    searchHelper: function (component, event, getInputkeyWord, objectAPIField) {
        console.log('searching');
        // call the apex class method 
        var action = component.get("c.fetchLookUpValues");
        // set param to method  
        action.setParams({
            'searchKeyWord': getInputkeyWord,
            'ObjectName': component.get("v.objectAPIName"),
            'objectAPIField': objectAPIField ? objectAPIField : component.get("v.objectAPIField"),
            'accId': component.get("v.accId")
        });
        // set a callBack    
        action.setCallback(this, function (response) {
            $A.util.removeClass(component.find("mySpinner"), "slds-show");
            var state = response.getState();
            console.log(state);
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                console.log(storeResponse);
                // if storeResponse size is equal 0 ,display No Result Found... message on screen.                }
                if (storeResponse.length == 0) {
                    component.set("v.Message", 'No Result Found...');
                } else {
                    component.set("v.Message", '');
                }
                // set searchResult list with return value from server.
                component.set("v.listOfSearchRecords", storeResponse);

            }

        });
        // enqueue the Action  
        console.log('searching2');
        $A.enqueueAction(action);

        console.log('searching3');
    },
    serverSideCall: function (component, action) {
        return new Promise(function (resolve, reject) {
            action.setCallback(this,
                function (response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        resolve(response.getReturnValue());
                    } else {
                        reject(new Error(response.getError()));
                    }
                });
            $A.enqueueAction(action);
        });
    }
})