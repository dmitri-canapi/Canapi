global without sharing class PortfolioCompanyFinancials {

    @RemoteAction @AuraEnabled(cacheable=true)    
    global static CapTableDataDhtmlx getCapTableData(String quarter) {
        
        
        List <Portfolio_Tab__mdt> metadata = [select id, Graph_Type__c, Line_Item_Name__c, Portfolio_Column__c, Type__c from Portfolio_Tab__mdt order by Portfolio_Column__c asc];
        Set <String> portfChaofAccs = new Set <String>();
        
        for (Portfolio_Tab__mdt pmtd: metadata){
            portfChaofAccs.add(pmtd.Line_Item_Name__c);
        }

        List <Account> portfolioAccs = [select id, name from Account where recordtype.DeveloperName = 'Portfolio_Company' order by name asc];
        system.debug(portfolioAccs);
        Set <Id> accIds = new Set <Id> ();
        Map <String,Map <String,List<Financials__c>>> accFinancialsMap = new Map <String,Map <String,List<Financials__c>>>();


        String [] q = quarter.split(', |%2C+');
        integer currentQuarter = Integer.ValueOf(q[0].removeStart('Q'));
        String prevQuarter;
        Integer currentYear = Integer.ValueOf(q[1]);
        String currentYearSearch =  '%'+currentYear+'%';
        String prevYearSearch =  '%'+(currentYear -1) +'%';

        String thisQuarter = 'Q' + currentQuarter + currentYear;
        if (currentQuarter == 1){
            prevQuarter = 'Q4' + String.valueOf(currentYear-1);
        } else {
            prevQuarter = 'Q' + String.valueOf(currentQuarter - 1) + String.valueOf(currentYear);
        }

        for (Account a: portfolioAccs){
            accIds.add(a.Id);
            accFinancialsMap.put(a.Id, New Map <String,List<Financials__c>> ());
        }
                
        List<Financials__c> financials =[
            Select id,
            Chart_of_Accounts__c,
            Chart_of_Accounts__r.Name,
            Report_Period__c,
            Report_Period__r.Quarter__c,
            Chart_of_Accounts__r.Account__c,
            Value__c
            FROM Financials__c
            WHERE  
            Chart_of_Accounts__r.name in : portfChaofAccs
            AND Value__c != null
            AND Report_Period__r.Account__c in: accIds
            AND (Report_Period__r.quarter__c LIKE: currentYearSearch OR Report_Period__r.quarter__c LIKE: prevYearSearch)
            AND Chart_of_Accounts__r.Account__c in: accIds
            AND Chart_of_Accounts__r.Financial_Category__c != null
            order by Chart_of_Accounts__r.Name asc, CreatedDate asc
        ];

        for (Financials__c f: financials){
            if (!accFinancialsMap.get(f.Chart_of_Accounts__r.Account__c).containsKey(f.Chart_of_Accounts__r.Name)){
                accFinancialsMap.get(f.Chart_of_Accounts__r.Account__c).put(f.Chart_of_Accounts__r.Name,new List<Financials__c>());
            } 
            accFinancialsMap.get(f.Chart_of_Accounts__r.Account__c).get(f.Chart_of_Accounts__r.Name).add(f);
        }
        
        
        JSONGenerator generator = JSON.createGenerator(true);
        generator.writeStartObject(); 
        generator.writeFieldName('rows');
        generator.writeStartArray(); 

        List <String> rows = new  List <String> ();
        for (Account a: portfolioAccs){
            generator.writeStartObject(); 
            generator.writeStringField('id', a.Id);
            List<String> strlist = new List<String>();
            //strlist.add(a.Name);
            strlist.add( a.Name  + '^' + '/' + a.Id );

            
            for (Portfolio_Tab__mdt pmtd: metadata){
                boolean isInvestmentFound = false;

                if (accFinancialsMap.containsKey(a.Id) && accFinancialsMap.get(a.Id).containsKey(pmtd.Line_Item_Name__c)){
                    
                    for (Financials__c f: accFinancialsMap.get(a.Id).get(pmtd.Line_Item_Name__c)){
                        if (f.Report_Period__r.Quarter__c.replaceAll(',', '').deleteWhitespace() == thisQuarter){
                            strlist.add(pmtd.Type__c == 'Percent' ? String.valueOf(f.Value__c.SetScale(1)) : String.valueOf(f.Value__c));
                            isInvestmentFound = true;
                            break;
                        }
                        
                    }
                }
                if (!isInvestmentFound && (pmtd.Type__c == 'Currency' || pmtd.Type__c == 'Number')){
                    strlist.add('0.00');
                } else if (!isInvestmentFound && pmtd.Type__c == 'Percent'){
                    strlist.add('0.0');
                }

            }

            generator.writeObjectField('data', strlist);
            generator.writeEndObject(); //Write the end marker of a JSON object '}'
        }
            
        
        generator.writeEndArray(); //Write the end marker of a JSON object ']'
        generator.writeEndObject(); 

        
        
        CapTableDataDhtmlx retData = new CapTableDataDhtmlx((generator.getAsString()),metadata);
        return retData;
        
    }


    global class CapTableDataDhtmlx{
        @AuraEnabled public String data {get;set;}
        @AuraEnabled public List <Portfolio_Tab__mdt> columns {get;set;}
        CapTableDataDhtmlx (String data, List <Portfolio_Tab__mdt> columns){
            this.data = data;
            this.columns = columns;
        }
        
    }
    
}