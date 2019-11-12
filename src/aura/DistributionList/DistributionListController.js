({
	loadData : function(component, event, helper) {
		var action = component.get("c.getRecords");
        /*action.setParams({
            sObjectName: component.get("v.sObjectName"),
            fieldSetName: component.get("v.fieldSetName")
        });*/

        action.setCallback(this, function(response) {
            var jslist = JSON.parse(response.getReturnValue());
            //component.set("v.tableRecords", jslist);
            
            

            for (var i = 0; i < jslist.length; i++) {
                var row = jslist[i];
                var tot =0;
                if (row.Commitments__r) {
                    for(var k=0; k < row.Commitments__r.records.length; k++){ 
                        if (row.Commitments__r.records[k].Target_Commitment__c)
                    	tot+=row.Commitments__r.records[k].Target_Commitment__c;
                    }
                }
                row.totalComm = tot;
            }

            console.log(jslist);
            component.set("v.tableRecords", jslist);
            
        })
        $A.enqueueAction(action);
	},
    downloadCsv : function(component,event,helper){
        var jslist = component.get("v.tableRecords");
        console.log(jslist[0].Id);
        var csv = 'Fund,Total Commitment,Account Name,First Name,Last Name,Title,Email\n';
        var columnDivider = ',';
        var lineDivider =  '\n';
        for(var i=0; i < jslist.length; i++){ 
            
        	for(var j=0; j < jslist[i].Contacts.records.length; j++){  
                var tot =0;
                if (jslist[i].Commitments__r){
                    for(var k=0; k < jslist[i].Commitments__r.records.length; k++){ 
                    	csv= csv + jslist[i].Commitments__r.records[k].Fund__r.Name + ';';
                    }
                    csv = csv.slice(0, -1);
                    csv+=columnDivider;
                    for(var k=0; k < jslist[i].Commitments__r.records.length; k++){ 
                    	//csv= csv + jslist[i].Commitments__r.records[k].Fund__r.Total_Commitment__c + ';';
                    	if (jslist[i].Commitments__r.records[k].Target_Commitment__c)
                    		tot+=jslist[i].Commitments__r.records[k].Target_Commitment__c;
                    }
                    csv= csv + tot;
                    //csv = csv.slice(0, -1);
                    csv+=columnDivider;
                } else {
                    csv= csv + '[No Commitments Found]' + columnDivider + '0' + columnDivider;
                }
                csv= csv + jslist[i].Contacts.records[j].Account.Name + columnDivider;
                if (jslist[i].Contacts.records[j].FirstName){
                    csv= csv + jslist[i].Contacts.records[j].FirstName + columnDivider;
                } else {
                    csv+=columnDivider;
                }
                if (jslist[i].Contacts.records[j].LastName){
                    csv= csv + jslist[i].Contacts.records[j].LastName + columnDivider;
                } else {
                    csv+=columnDivider;
                }
                if (jslist[i].Contacts.records[j].Title){
                    csv= csv + jslist[i].Contacts.records[j].Title + columnDivider;
                } else {
                    csv+=columnDivider;
                }
                 if (jslist[i].Contacts.records[j].Email){
                    csv= csv + jslist[i].Contacts.records[j].Email + columnDivider;
                } else {
                    csv+=columnDivider;
                }
                
            	csv+=lineDivider;
            }
            
        }
        
        console.log(csv);
        csv=csv.replace(null,'');
        console.log(csv);
        var hiddenElement = document.createElement('a');
        hiddenElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csv);
        hiddenElement.target = '_self'; // 
        hiddenElement.download = 'ExportData.csv';  // CSV file Name* you can change it.[only name not .csv] 
        document.body.appendChild(hiddenElement); // Required for FireFox browser
        hiddenElement.click(); // using click() js function to download csv file
    }
})