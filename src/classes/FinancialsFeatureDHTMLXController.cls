global class FinancialsFeatureDHTMLXController {
    
    global FinancialsFeatureDHTMLXController(ApexPages.StandardController controller){
}
    
    global class CapTableDataDhtmlx{
        public List <Report_Period__c> rounds {get;set;}
        public String data {get;set;}
        public List <String> rows {get;set;}
        public Boolean isCommunity {get;set;}
        public Boolean allowEditByCommUser {get;set;}
        CapTableDataDhtmlx (List <Report_Period__c> rounds, String data, List  <String> rows, Boolean isCommunity, Boolean allowEditByCommUser){
            this.rounds = rounds;
            this.data = data;
            this.rows = rows;
            this.isCommunity = isCommunity;
            this.allowEditByCommUser = allowEditByCommUser;
        }
        
    }
    
    @RemoteAction
    global static void deleteReportPeriod (String ReportPeriodId){
        delete [select Id from Report_Period__c where id =:ReportPeriodId]; 
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
        account a =  new Account (Id = accountId, Allow_edits_by_community_users__c = AllowEditing);
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
            ORDER by Category__c, Name ASC, Id ASC
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

        /*if(charts.isEmpty()){
            List<String> requiredCharts = new List<String> {'Booking ACV', 'Total Rev', 'COGS'};
            for(String name :requiredCharts){
                Chart_of_Accounts__c newChart = new Chart_of_Accounts__c();
                newChart.Account__c = accountId;
                newChart.Name = name;
                newChart.Category__c = 'Revenue';
                charts.add(newChart);
            }
            insert charts;
        }*/
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
        
        account a =  [select Id,Allow_edits_by_community_users__c from Account where id = :accountId];
        
        CapTableDataDhtmlx retData = new CapTableDataDhtmlx(periods,generator.getAsString(),rows, isCommunity, a.Allow_edits_by_community_users__c);
        return retData;
    }
   
    
    @RemoteAction
    global static void deleteChartOfAccounts (String chId){
        delete [select id from Chart_of_Accounts__c WHERE id =:chId];
    }
    
    public class CapTableControllerException extends Exception {}
}