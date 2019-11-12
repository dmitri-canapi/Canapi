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
        }
        
        component.set("v.calculatedInvestorInfo", Object.values(investorInfoMap));
	}
})