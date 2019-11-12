({
	initData : function(component, rawCapTableData) {        
		//console.log(rawCapTableData);
        var investorInfoMap = {};
        for (var investment of rawCapTableData["investments"]) {
            //console.log(investment);
            if (investment["investorId"]) {
                var investorInfo = investorInfoMap[investment["investorId"]];
                if (!investorInfo) {
                    investorInfo = {
                        id : investment["investorId"],
                        shareholder : investment["investorName"]
                    }
                    investorInfoMap[investment["investorId"]] = investorInfo;
                }
                
                var currentRoundSharesFieldName = investment["seriesId"] + 'Shares';
                if (!investorInfo[currentRoundSharesFieldName]) {
                    investorInfo[currentRoundSharesFieldName] = investment["numberOfShares"];
                } else {
                    investorInfo[currentRoundSharesFieldName] += investment["numberOfShares"];
                }
                
                var currentRoundSharesPerc = investment["seriesId"] + 'Perc';
                if (!investorInfo[currentRoundSharesPerc]) {
                    investorInfo[currentRoundSharesPerc] = investment["percentageOfShares"];
                } else {
                    investorInfo[currentRoundSharesPerc] += investment["percentageOfShares"];
                }
                
                var currentRoundSharesNV = investment["seriesId"] + 'NV';
                if (!investorInfo[currentRoundSharesNV]) {
                    investorInfo[currentRoundSharesNV] = investment["numberOfNVShares"];
                } else {
                    investorInfo[currentRoundSharesNV] += investment["numberOfNVShares"];
                }
                
                var currentRoundSharesTS = investment["seriesId"] + 'TS';
                if (!investorInfo[currentRoundSharesTS]) {
                    investorInfo[currentRoundSharesTS] = investment["sumOfShares"];
                } else {
                    investorInfo[currentRoundSharesTS] += investment["sumOfShares"];
                }
                
                var currentRoundSharesId = investment["seriesId"] + 'Id';
                if (!investorInfo[currentRoundSharesId]) {
                    investorInfo[currentRoundSharesId] = investment["investmentId"];
                } else {
                    investorInfo[currentRoundSharesId] += investment["investmentId"];
                }
                
                if (!investorInfo["totalShares"]) {
                    investorInfo["totalShares"] = investment["sumOfShares"];
                } else {
                    investorInfo["totalShares"] += investment["sumOfShares"];
                }
                
                if (!investorInfo["currentAccNVS"]) {
                    if (investment["numberOfNVShares"]!=null){
                    	investorInfo["currentAccNVS"] = investment["numberOfNVShares"];
                    } else {
                        investorInfo["currentAccNVS"] =0;
                    }
                } else {
                    if (investment["numberOfNVShares"]!=null)
                    investorInfo["currentAccNVS"] += investment["numberOfNVShares"];
                }
                
                if (!investorInfo["currentAccVS"]) {
                    if (investment["numberOfShares"]!=null){
                    	investorInfo["currentAccVS"] = investment["numberOfShares"];
                    } else {
                        investorInfo["currentAccVS"] =0;
                    }
                } else {
                    if (investment["numberOfShares"]!=null)
                    investorInfo["currentAccVS"] += investment["numberOfShares"];
                }
                

            }

            // loop through all the investors and set the "roundInvestments" array
            // appropriately so it can be looped through in order in the component
            for (var investorInfo of Object.values(investorInfoMap)) {
                
                investorInfo["roundInvestments"] = [];
                
                for (var i=0; i<rawCapTableData["allRoundNames"].length; i++) {
                    var investmentObj={};
                    investmentObj.id=null;
                    investmentObj.VotingShares=0;
                    investmentObj.PercVoting=0;
                    investmentObj.TotalShares=0;
                    investmentObj.NonVotingShares=0;
                    investmentObj.StepTS=0;
                    investmentObj.StepVS=0;
                    investmentObj.StepNVS=0;
                        
                    var investedInThisRound = investorInfo[rawCapTableData["allRoundIds"][i] + 'Shares'];
                    if (investedInThisRound) {
                        investmentObj.VotingShares = investedInThisRound;
                        investmentObj.StepVS = Math.round(investedInThisRound*0.1);
                    } 
                    
                    var investedInThisRoundPerc = investorInfo[rawCapTableData["allRoundIds"][i] + 'Perc'];
                    if (investedInThisRoundPerc) {
                        investmentObj.PercVoting = investedInThisRoundPerc;
                    } 
                    
                    var investedInThisRoundNVS = investorInfo[rawCapTableData["allRoundIds"][i] + 'NV'];
                    if (investedInThisRoundNVS) {
                        investmentObj.NonVotingShares = investedInThisRoundNVS;
                        investmentObj.StepNVS = Math.round(investedInThisRoundNVS*0.1);
                    } 
                    
                    var investedInThisRoundTS = investorInfo[rawCapTableData["allRoundIds"][i] + 'TS'];
                    if (investedInThisRoundTS) {
                        investmentObj.TotalShares = investedInThisRoundTS;
                        investmentObj.StepTS = Math.round(investedInThisRoundTS*0.1);
                    }
                    
                    var investedInThisRoundId = investorInfo[rawCapTableData["allRoundIds"][i] + 'Id'];
                    if (investedInThisRoundId) {
                        investmentObj.id = investedInThisRoundId;
                    }
                    
                    //console.log(investmentObj);
                    investorInfo["roundInvestments"].push(investmentObj);
                }
            }
        }
        //console.log(Object.values(investorInfoMap));
        component.set("v.calculatedInvestorInfo", Object.values(investorInfoMap));
        
      
        
	},
    
    doKeypress : function(component, event, runSave) {
        
        var rawCapTableData = component.get("v.rawCapTableData");
        var numRounds = rawCapTableData.rounds.length;
        var colRowIdx = event.target.getAttribute('data-record');
        
        var targetIndex = (parseInt(colRowIdx.split(':')[0]) * numRounds) + parseInt(colRowIdx.split(':')[1]);
        var InputTS=0;
        var InputVS=0;
        var InputNVS=0;
        
        
        var editBoxInput = component.find("editBoxInputVS");
        if(!Array.isArray(editBoxInput)){
            var editBoxInputTemp =  editBoxInput;
            editBoxInput = [];
            editBoxInput.push(editBoxInputTemp);
        }
        
        for (var i=0; i<editBoxInput.length; i++) {
            if (i == targetIndex) {
                InputVS = editBoxInput[i].getElements()[0].value;
            } 
        }
        editBoxInput = component.find("editBoxInputNVS");
        if(!Array.isArray(editBoxInput)){
            var editBoxInputTemp =  editBoxInput;
            editBoxInput = [];
            editBoxInput.push(editBoxInputTemp);
        }
        for (var i=0; i<editBoxInput.length; i++) {
            if (i == targetIndex) {
                InputNVS = editBoxInput[i].getElements()[0].value;
                //console.log(InputNVS);
            } 
        }
        console.log(event.currentTarget.name);
        
        if (event.currentTarget.name==='editBoxInputTS'){
            //var editBoxInput = component.find("editBoxInputTS");
            InputTS = event.currentTarget.value;     
            var oldTotal = 0;   
            oldTotal = Number(InputNVS) + Number(InputVS);
            //console.log(oldTotal);
            if (oldTotal!=0){
                var Vpercent = Number(InputVS) * 100 / oldTotal;
                //console.log(Vpercent);
                var diff = InputTS - oldTotal;
                //console.log(diff);
                
                var newVS = 0;
                newVS = Number(InputVS) + (Vpercent*diff/100);
                //console.log(Math.round((newVS)));
                var newNVS = 0;  
                newNVS = Math.round(Number(InputNVS)+(((100-Vpercent)*diff)/100));
                //console.log(newNVS);
                
                var editBoxInput = component.find("editBoxInputVS");
                if(!Array.isArray(editBoxInput)){
                    var editBoxInputTemp =  editBoxInput;
                    editBoxInput = [];
                    editBoxInput.push(editBoxInputTemp);
                }
                for (var i=0; i<editBoxInput.length; i++) {
                    if (i == targetIndex) {
                        editBoxInput[i].getElements()[0].value=Math.round(newVS);
                    } 
                }
                editBoxInput = component.find("editBoxInputNVS");
                if(!Array.isArray(editBoxInput)){
                    var editBoxInputTemp =  editBoxInput;
                    editBoxInput = [];
                    editBoxInput.push(editBoxInputTemp);
                }
                for (var i=0; i<editBoxInput.length; i++) {
                    if (i == targetIndex) {
                        editBoxInput[i].getElements()[0].value=Math.round(newNVS);
                    } 
                } 
            } else {
                var editBoxInput = component.find("editBoxInputVS");
                if(!Array.isArray(editBoxInput)){
                    var editBoxInputTemp =  editBoxInput;
                    editBoxInput = [];
                    editBoxInput.push(editBoxInputTemp);
                }
                for (var i=0; i<editBoxInput.length; i++) {
                    if (i == targetIndex) {
                        editBoxInput[i].getElements()[0].value=Math.round(InputTS);
                    } 
                }
            }
        } else if (event.currentTarget.name==='editBoxInputVS' || event.currentTarget.name==='editBoxInputNVS'){
            var editBoxInput = component.find("editBoxInputTS");
            if(!Array.isArray(editBoxInput)){
                var editBoxInputTemp =  editBoxInput;
                editBoxInput = [];
                editBoxInput.push(editBoxInputTemp);
            }
            for (var i=0; i<editBoxInput.length; i++) {
                if (i == targetIndex) {
                    editBoxInput[i].getElements()[0].value=Math.round(Number(InputVS)+Number(InputNVS));
                } 
            }
        }
        
        
        if (event.key === 'Escape') {
            var editBoxes = component.find("editBox");
            if(!Array.isArray(editBoxes)){
                var editBoxesTemp =  editBoxes;
                editBoxes = [];
                editBoxes.push(editBoxesTemp);
            }
            for (var i=0; i<editBoxes.length; i++) {
                $A.util.addClass(editBoxes[i], "slds-hide");
                $A.util.removeClass(editBoxes[i], "slds-show");
            }
        } else if (event.key === 'Enter' || runSave ) {
            var editBoxes = component.find("editBox");
             if(!Array.isArray(editBoxes)){
                var editBoxesTemp =  editBoxes;
                editBoxes = [];
                editBoxes.push(editBoxesTemp);
            }
            for (var i=0; i<editBoxes.length; i++) {
                $A.util.addClass(editBoxes[i], "slds-hide");
                $A.util.removeClass(editBoxes[i], "slds-show");
            }
            //var newVal = event.target.value;
            
            var InputVS=0;
            var InputNVS=0;
            
            var editBoxInput = component.find("editBoxInputVS");
             if(!Array.isArray(editBoxInput)){
                var editBoxInputTemp =  editBoxInput;
                editBoxInput = [];
                editBoxInput.push(editBoxInputTemp);
            }
            for (var i=0; i<editBoxInput.length; i++) {
                if (i == targetIndex) {
                    InputVS = editBoxInput[i].getElements()[0].value;
                    //console.log('VS -- ');
                    //console.log(InputVS);
                } 
            }
            editBoxInput = component.find("editBoxInputNVS");
             if(!Array.isArray(editBoxInput)){
                var editBoxInputTemp =  editBoxInput;
                editBoxInput = [];
                editBoxInput.push(editBoxInputTemp);
            }
            for (var i=0; i<editBoxInput.length; i++) {
                if (i == targetIndex) {
                    InputNVS = editBoxInput[i].getElements()[0].value;
                } 
            }
            
    		var colIdx = event.target.getAttribute('data-colIdx');
            var investorId = event.target.getAttribute('data-investorId');
    
            var rawCapTableData = component.get("v.rawCapTableData");
            var roundId = rawCapTableData.rounds[colIdx].id;
            
            
            var action = component.get("c.setShares");
            action.setParams({
                investorId : investorId,
                seriesId : roundId,
                VotingShare : InputVS,
                NonVotingShare : InputNVS
            });
            action.setCallback(this, function(response){
                var state = response.getState();
                if (state === "SUCCESS") {
					document.getElementById("shares-td-" + event.srcElement.id).classList.add("changedValue");
                    var newVal=0;
                    if (component.get("v.filterValue")=='All'){
                        newVal = Number(InputVS) + Number(InputNVS);
                    } else if (component.get("v.filterValue")=='Voting'){
                        newVal = InputVS;
                    } else if (component.get("v.filterValue")=='Non-Voting'){
                        newVal = InputNVS;
                    }
                    console.log(document.getElementById("shares-td-" + event.srcElement.id).getElementsByTagName('div')[0].innerHTML = newVal);
                    /*var dataChangedEvent = $A.get("e.c:CapTableDataChanged");
                    dataChangedEvent.fire();*/
                    //updating will fire on button press
                                        
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