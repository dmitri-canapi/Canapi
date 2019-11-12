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
                
                var currentRoundPercentageFieldName = investment["seriesId"] + 'Percentage';
                var percentageForThisInvestment = investment["percentageOfSeries"] / 100;
                if (!investorInfo[currentRoundPercentageFieldName]) {
                    investorInfo[currentRoundPercentageFieldName] = percentageForThisInvestment;
                } else {
                    investorInfo[currentRoundPercentageFieldName] += percentageForThisInvestment;
                }
                
                //console.log(investment);
                var sharesForThisInvestment = 0;
                if (component.get("v.filterValue")=='Voting'){
                    if (investment["numberOfShares"])
                    sharesForThisInvestment = investment["numberOfShares"];
                } else if (component.get("v.filterValue")=='Non-Voting'){
                    if(investment["numberOfNVShares"])
                    sharesForThisInvestment = investment["numberOfNVShares"];
                } else {
                    sharesForThisInvestment = investment["sumOfShares"];
                }
                
                if (!investorInfo["totalShares"]) {
                    investorInfo["totalShares"] = sharesForThisInvestment;
                } else {
                    investorInfo["totalShares"] += sharesForThisInvestment;
                }

                investorInfo["totalPercentage"] = investorInfo["totalShares"] / rawCapTableData["totalSharesInvested"];
                //console.log(rawCapTableData["totalSharesInvested"]);
            }
            
            // loop through all the investors and set the "roundInvestments" array
            // appropriately so it can be looped through in order in the component
            for (var investorInfo of Object.values(investorInfoMap)) {
                investorInfo["roundInvestments"] = [];
                for (var i=0; i<rawCapTableData["allRoundIds"].length; i++) {
                    var investedInThisRound = investorInfo[rawCapTableData["allRoundIds"][i] + 'Percentage'];
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