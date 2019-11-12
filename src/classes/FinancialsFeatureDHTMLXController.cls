global class FinancialsFeatureDHTMLXController {
    
    global FinancialsFeatureDHTMLXController(ApexPages.StandardController controller){
}
    
    global class CapTableDataDhtmlx{
        public List <Report_Period__c> rounds {get;set;}
        public String data {get;set;}
        public List <String> rows {get;set;}
        CapTableDataDhtmlx (List <Report_Period__c> rounds, String data, List  <String> rows){
            this.rounds = rounds;
            this.data = data;
            this.rows = rows;
        }
        
    }
    
    @RemoteAction
    global static void deleteReportPeriod (String ReportPeriodId){
        delete [select Id from Report_Period__c where id =:ReportPeriodId]; 
    }
    
    @RemoteAction
    global static map<String, String> getBoardGradeOption (String objectApi_name, String field_name){
        system.debug('$$$$$$$$$$$$$$$$$');
        Map <String,String> piclisValues = new Map<String, String>();
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(objectApi_name);
        Sobject Object_name = targetType.newSObject();
  		Schema.sObjectType sobject_type = Object_name.getSObjectType(); //grab the sobject that was passed
    	Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe(); //describe the sobject
    	Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap(); //get a map of fields for the passed sobject
    	List<Schema.PicklistEntry> pick_list_values = field_map.get(Field_name).getDescribe().getPickListValues(); //grab the list of picklist values for the passed field on the sobject
        for (Schema.PicklistEntry a : pick_list_values) { //for all values in the picklist list
          piclisValues.put(a.getValue(), a.getLabel());
       }
        system.debug(piclisValues);
        return piclisValues;
    }
    
    @RemoteAction
    global static void createReportPeriod(String body, String accountId){
        Report_Period__c repPeriod  = (Report_Period__c)JSON.deserialize(body, Report_Period__c.class);
        repPeriod.Account__c = accountId;
        insert repPeriod;
    }
    
    @RemoteAction
    global static void createChartOfAccounts(String name, String Cat, String formula, String chAccId, String id){
        Chart_of_Accounts__c chart = new Chart_of_Accounts__c();
        chart.Name = name;
        chart.Account__c = id;
        chart.Category__c = Cat;
        chart.Formula__c = formula;
        if (chAccId!=null) chart.Id = chAccId;
        upsert chart; 
    }
    
    @RemoteAction
    global static void setFinancials(String chartId, String repId, Decimal Share) {
        Financials__c fin = new Financials__c();
        try {
            fin = [select Id  from Financials__c where Report_Period__c = :repId and Chart_of_Accounts__c = :chartId order by CreatedDate asc limit 1];
        } catch(exception e){
            fin.Report_Period__c = repId;
            fin.Chart_of_Accounts__c = chartId;
        }
        fin.Value__c = Share;
        upsert fin;
        
    }

    
    @RemoteAction
    global static void AllowEditingUpdate (String accountId, Boolean AllowEditing) {
        account a =  [select Id,Allow_edits_by_community_users__c from Account where id = :accountId];
        a.Allow_edits_by_community_users__c = AllowEditing;
        update a;
    }
    
    @RemoteAction
    global static CapTableDataDhtmlx getCapTableData(String accountId) {
        
        List<Report_Period__c> periods = [
            SELECT Id, 
            IsDeleted,
            Name,
            Date__c
            FROM Report_Period__c
            WHERE Account__c = :accountId
            ORDER by Date__c ASC, CreatedDate ASC
        ];
        
        List<Chart_of_Accounts__c> charts = [
            SELECT Id, 
            Name,
            Category__c,
            Formula__c
            FROM Chart_of_Accounts__c
            WHERE Account__c = :accountId
            ORDER by Name ASC, Id ASC
        ];
        
        List<Financials__c> financials =[
            Select id,
            Chart_of_Accounts__c,
            Chart_of_Accounts__r.Name,
            Report_Period__c,
            Value__c
            FROM Financials__c
            WHERE  Report_Period__r.Account__c = :accountId
            AND Chart_of_Accounts__r.Account__c = :accountId
            order by Chart_of_Accounts__r.Name asc, CreatedDate asc
        ];
        
        JSONGenerator generator = JSON.createGenerator(true);
        generator.writeStartObject(); 
        generator.writeFieldName('rows');
        generator.writeStartArray(); 

        boolean isCommunity = Site.getSiteId()!=null;

        if(charts.isEmpty()){
            List<String> requiredCharts = new List<String> {'Booking ACV', 'Total Rev', 'COGS'};
            for(String name :requiredCharts){
                Chart_of_Accounts__c newChart = new Chart_of_Accounts__c();
                newChart.Account__c = accountId;
                newChart.Name = name;
                newChart.Category__c = 'Revenue';
                charts.add(newChart);
            }
            insert charts;
        }
        List <String> rows = new  List <String> ();
        for (Chart_of_Accounts__c chr: charts){
            generator.writeStartObject(); 
            generator.writeStringField('id', chr.Id);
            
            generator.writeFieldName('userdata');
            generator.writeStartObject();
            generator.writeStringField('Formula', chr.Formula__c != null ? chr.Formula__c : '');
            generator.writeEndObject();
            
            List<String> strlist = new List<String>();
            if (isCommunity){
                strlist.add( chr.Name  + '^' + Network.communitiesLanding().getUrl() + 'detail/' + chr.Id ); 
               
            } else {
                strlist.add( chr.Name  + '^' + '/' + chr.Id );
            }
            rows.add(chr.Name);
            strlist.add(chr.Category__c);
            for (Report_Period__c rp: periods){
                boolean isInvestmentForRound = false;
                for (Financials__c fin: financials){
                    if ((fin.Chart_of_Accounts__c == chr.Id && fin.Report_Period__c == rp.Id ) && (fin.Value__c!=null)){
                        strlist.add(String.valueOf(fin.Value__c.setScale(0)));
                        isInvestmentForRound = true;
                        break;
                    }   
                }
                if (!isInvestmentForRound){
                    strlist.add('0');
                }
            }
            
            generator.writeObjectField('data', strlist);
            generator.writeEndObject(); //Write the end marker of a JSON object '}'
            
        }
        generator.writeEndArray(); //Write the end marker of a JSON object ']'
        generator.writeEndObject(); 
        CapTableDataDhtmlx retData = new CapTableDataDhtmlx(periods,generator.getAsString(),rows);
        return retData;
    }
   
    
    @RemoteAction
    global static void deleteChartOfAccounts (String chId){
        delete [select id from Chart_of_Accounts__c WHERE id =:chId];
    }
    
    
    
    public class CapTableControllerException extends Exception {}
}