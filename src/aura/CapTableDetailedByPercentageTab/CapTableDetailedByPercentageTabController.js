({
    sortTable : function (component, event, helper) {
        var column;
        if (event!=null){
            column	= event.srcElement.getAttribute('data-id');
        } else {
            column	= component.get("v.sortField");
            
        }
        var isNumberDataType =true;
        
        if (column!=null){    
            if (Number.isInteger(Number(column))){
                component.set("v.sortField", Number(column));
            } else {
                component.set("v.sortField", -1);
            }
        }
        
        if (column=='0'){
            column=0;
            isNumberDataType=false;
        } else if (column=='total'|| column=='-1'){
            column=(component.get("v.rawCapTableData.rounds").length)+2;
        }
        
        if (column!=null){
            var n=column;
            var table, rows, switching, i, x, y, shouldSwitch, dir, switchcount = 0;
            table = document.getElementById("PercentageTable");
            switching = true;
            // Set the sorting direction to ascending:
            //dir = "asc"; 
            dir = component.get("v.sortDirection");
            /* Make a loop that will continue until
                      no switching has been done: */
            while (switching) {
                // Start by saying: no switching is done:
                switching = false;
                rows = table.rows;
                /* Loop through all table rows (except the
                        first, which contains table headers): */
                for (i = 1; i < (rows.length - 2); i++) {
                    // Start by saying there should be no switching:
                    shouldSwitch = false;
                    /* Get the two elements you want to compare,
                          one from current row and one from the next: */
                    x = rows[i].getElementsByTagName("TD")[n].childNodes[0];
                    y = rows[i + 1].getElementsByTagName("TD")[n].childNodes[0];
                    /* Check if the two rows should switch place,
                          based on the direction, asc or desc: */
                    if (dir == "asc") {
                        if (isNumberDataType){
                            if (Number(x.innerHTML) > Number(y.innerHTML)) {
                                // If so, mark as a switch and break the loop:
                                shouldSwitch = true;
                                break;
                            }
                        } else {
                            if (x.innerHTML.toLowerCase() > y.innerHTML.toLowerCase()) {
                                // If so, mark as a switch and break the loop:
                                shouldSwitch = true;
                                break;
                            }
                        }
                        
                    } else if (dir == "desc") {
                        if (isNumberDataType){
                            if (Number(x.innerHTML) < Number(y.innerHTML)) {
                                // If so, mark as a switch and break the loop:
                                shouldSwitch = true;
                                break;
                            }
                        } else {
                            if (x.innerHTML.toLowerCase() < y.innerHTML.toLowerCase()) {
                                // If so, mark as a switch and break the loop:
                                shouldSwitch = true;
                                break;
                            }
                        }
                    }
                }
                if (shouldSwitch) {
                    /* If a switch has been marked, make the switch
                          and mark that a switch has been done: */
                    rows[i].parentNode.insertBefore(rows[i + 1], rows[i]);
                    switching = true;
                    // Each time a switch is done, increase this count by 1:
                    switchcount ++; 
                } else {
                    /* If no switching has been done AND the direction is "asc",
                          set the direction to "desc" and run the while loop again. */
                    if (switchcount == 0 && dir == "asc") {
                        dir = "desc";
                        switching = true;
                    }
                }
            }
            if (component.get("v.sortDirection")=='asc'){
                component.set("v.sortDirection", 'desc');   
            } else {
                component.set("v.sortDirection", 'asc');   
            }
        }

    },
    init : function (component, event, helper) {
		if (component.get("v.isCommunityUser") == false || (component.get("v.isCommunityUser") == true && component.get("v.isAllowEditing") == true)){
            component.set("v.showPlus", true);
        } else {
            component.set("v.showPlus", false);
        }
        var action = component.get("c.getCapTableData");
        action.setParams({ accountId : component.get("v.recordId"),filterValue: component.get("v.filterValue") });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var rawCapTableData = response.getReturnValue();
                component.set("v.rawCapTableData", rawCapTableData);
                helper.initData(component, rawCapTableData);   
                setTimeout(function() {
                  var sortT = component.get('c.sortTable');
                  $A.enqueueAction(sortT);
                  $A.enqueueAction(sortT);
                },200); 
            } else {
                alert(response);
            }
        });
        $A.enqueueAction(action);
    },
    navToShareholder : function(component, event, helper) {
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": event.srcElement.getAttribute('data-shareholderId')
        });
        navEvt.fire();
    },
    addShareholder : function (component, event, helper) {
        var compEvents = component.getEvent("addRecord");
        compEvents.setParams({ "ShowNewShareHolder" : true });
        compEvents.fire();
    },
    addSeries: function (component, event, helper) {
        var compEvents = component.getEvent("addRecord");
        compEvents.setParams({ "ShowNewRound" : true,"ShowNewShareHolder":false });
        compEvents.fire();
    },
    removeRound: function(component, event, helper) {
        if (component.get("v.isCommunityUser") == false || (component.get("v.isCommunityUser") == true && component.get("v.isAllowEditing") == true)){
            var isConfirmed = confirm("Proceed with deleting " + event.srcElement.getAttribute('data-roundName') + " series from the CapTable?");
            if (isConfirmed){
                var action = component.get("c.deleteSeries");
                action.setParams({
                    seriesId : event.srcElement.getAttribute('data-roundId')
                });
                action.setCallback(this, function(response){
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        var dataChangedEvent = $A.get("e.c:CapTableDataChanged");
                        dataChangedEvent.fire();
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
    },
    removeShareholder: function(component, event, helper) {
        if (component.get("v.isCommunityUser") == false || (component.get("v.isCommunityUser") == true && component.get("v.isAllowEditing") == true)){
            var isConfirmed = confirm("Proceed with deleting " + event.srcElement.getAttribute('data-roundName') + " shareholder from the CapTable?");
            if (isConfirmed){
                var action = component.get("c.deleteShareholder ");
                action.setParams({
                    shareholderId : event.srcElement.getAttribute('data-roundId'),
                    recordId : component.get("v.recordId")
                });
                action.setCallback(this, function(response){
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        var dataChangedEvent = $A.get("e.c:CapTableDataChanged");
                        dataChangedEvent.fire();
                    }
                });
                $A.enqueueAction(action);
            }
        }
    },
    navToRound : function(component, event, helper) {
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": event.srcElement.getAttribute('data-roundId')
        });
        navEvt.fire();
    },
    showShareHolderTooltip: function(component, event, helper) {
        
            var index = event.target.getAttribute('data-record');
            var tooltips = component.find("shareHolderTooltip");
            if(!Array.isArray(tooltips)){
                var tooltipsTemp =  tooltips;
                tooltips = [];
                tooltips.push(tooltipsTemp);
            }
            $A.util.removeClass(tooltips[index], "slds-hide");
            $A.util.addClass(tooltips[index], "slds-show");
    },
    hideShareHolderTooltip : function(component, event, helper) {
       
            var index = event.target.getAttribute('data-record');
            var tooltips = component.find("shareHolderTooltip");
            if(!Array.isArray(tooltips)){
                var tooltipsTemp =  tooltips;
                tooltips = [];
                tooltips.push(tooltipsTemp);
            }
            $A.util.addClass(tooltips[index], "slds-hide");
            $A.util.removeClass(tooltips[index], "slds-show");
    },
    showRoundTooltip : function(component, event, helper) {
        var index = event.target.getAttribute('data-record');
        var tooltips = component.find("roundTooltip");
        if(!Array.isArray(tooltips)){
            var tooltipsTemp =  tooltips;
            tooltips = [];
            tooltips.push(tooltipsTemp);
        }
        $A.util.removeClass(tooltips[index], "slds-hide");
        $A.util.addClass(tooltips[index], "slds-show");
    },
    hideRoundTooltip : function(component, event, helper) {
        var index = event.target.getAttribute('data-record');
        var tooltips = component.find("roundTooltip");
        if(!Array.isArray(tooltips)){
            var tooltipsTemp =  tooltips;
            tooltips = [];
            tooltips.push(tooltipsTemp);
        }
        $A.util.addClass(tooltips[index], "slds-hide");
        $A.util.removeClass(tooltips[index], "slds-show");
    },
    showSpinner: function(component, event, helper) {
        component.set("v.Spinner", true); 
   },
    hideSpinner : function(component,event,helper){    
       component.set("v.Spinner", false);
    }
})