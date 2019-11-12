({
	initData : function(component, rawCapTableData) {
		
        var investorInfoMap = {};
        for (var investment of rawCapTableData["investments"]) {
            if (investment["investorId"]) {
                var investorInfo = investorInfoMap[investment["investorId"]];
                if (!investorInfo) {
                    investorInfo = {
                        id : investment["investorId"],
                        shareholder : investment["investorName"]
                    }
                    investorInfoMap[investment["investorId"]] = investorInfo;
                }
                
                var currentRoundDollarsFieldName = investment["seriesId"] + 'Dollars';
                var dollarsForThisInvestment = investment["totalDollarAmount"];
                if (!investorInfo[currentRoundDollarsFieldName]) {
                    investorInfo[currentRoundDollarsFieldName] = dollarsForThisInvestment;
                } else {
                    investorInfo[currentRoundDollarsFieldName] += dollarsForThisInvestment;
                }
                
                if (!investorInfo["totalDollars"]) {
                    investorInfo["totalDollars"] = dollarsForThisInvestment;
                } else {
                    investorInfo["totalDollars"] += dollarsForThisInvestment;
                }
            }

        }
        
            // loop through all the investors and set the "roundInvestments" array
            // appropriately so it can be looped through in order in the component
            for (var investorInfo of Object.values(investorInfoMap)) {
                investorInfo["roundInvestments"] = [];
                for (var i=0; i<rawCapTableData["allRoundNames"].length; i++) {
                    var investedInThisRound = investorInfo[rawCapTableData["allRoundIds"][i] + 'Dollars'];
                    if (investedInThisRound) {
                        investorInfo["roundInvestments"].push(investedInThisRound);
                    } else {
                        investorInfo["roundInvestments"].push(0);
                    }
                }
            }

        component.set("v.calculatedInvestorInfo", Object.values(investorInfoMap));
	},
    
    doKeypress : function(component, event, runSave) {
     //console.log(runSave);
       //console.log(event.key); 
        if (event.key === 'Escape') {
            var editBoxes = component.find("editBox");
            if(Array.isArray(editBoxes)){
                for (var i=0; i<editBoxes.length; i++) {
                    $A.util.addClass(editBoxes[i], "slds-hide");
                    $A.util.removeClass(editBoxes[i], "slds-show");
                }
            } else {
                 $A.util.addClass(editBoxes, "slds-hide");
                $A.util.removeClass(editBoxes, "slds-show");
            }
        } else if (event.key === 'Enter' ) {
            var editBoxes = component.find("editBox");
            if(Array.isArray(editBoxes)){
                for (var i=0; i<editBoxes.length; i++) {
                    component.find("editBoxInput")[i].getElement().blur();
                }
            } else {
                component.find("editBoxInput").getElement().blur();
            }
             
        } else if (runSave) {
            /*var editBoxes = component.find("editBox");
            for (var i=0; i<editBoxes.length; i++) {
                $A.util.addClass(editBoxes[i], "slds-hide");
                $A.util.removeClass(editBoxes[i], "slds-show");
            }*/
            var newVal = event.target.value;
            if (!newVal.match(/^(0|[1-9][0-9]*)(\.[0-9]{1,2})?$/)) {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type" : "error",
                    "message": "Bad format - only digits and and optional 2 decimal places"
                });
                toastEvent.fire();
                return;
            }
            
            var colIdx = event.target.getAttribute('data-colIdx');
            var investorId = event.target.getAttribute('data-investorId');
    
            var rawCapTableData = component.get("v.rawCapTableData");
            var roundId = rawCapTableData.rounds[colIdx].id;
    		//console.log('SAVE DOLLARS');
            var action = component.get("c.setDollarAmount");
            action.setParams({
                investorId : investorId,
                seriesId : roundId,
                amount : newVal,
                filterValue: component.get("v.filterValue")
            });
            action.setCallback(this, function(response){
                var state = response.getState();
                if (state === "SUCCESS") {
                    document.getElementById("td-" + event.srcElement.id).classList.add("changedValue");
                    console.log(document.getElementById("td-" + event.srcElement.id).getElementsByTagName('div')[0].innerHTML = "$" + newVal);
                        
                    // this is now handled via registered event handler
                    //$A.enqueueAction(component.get('c.init'));

                    // fire the CapTableDataChanged event so that components that
                    // show relevant can catch an refresh
                    // 
                    
                    /*var dataChangedEvent = $A.get("e.c:CapTableDataChanged");
                    dataChangedEvent.fire();*/
                    //updating will fire on button press
                    
                    if (response.getReturnValue()!=newVal){
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "type" : "info",
                            "title": "Information",
                            "message": "Amount adjusted to avoid partial shares."
                        });
                        toastEvent.fire();
                    }
                    
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type" : "success",
                        "title": "Success!",
                        "message": "Investment record updated successfully."
                    });
                    toastEvent.fire();
                    
                } else {
                    var errorMsg = 'Unknown error';
                    if (response.getError() && response.getError()[0] && response.getError()[0].message) {
                        errorMsg = response.getError()[0].message;
                    }
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type" : "error",
                        "message": errorMsg
                    });
                    toastEvent.fire();
                }
            });
            $A.enqueueAction(action);
        }
}
    
})