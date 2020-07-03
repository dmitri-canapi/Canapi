global class FinancialsFeatureDHTMLXController {
    
   
    
    global class CapTableDataDhtmlx{
        public List <Report_Period__c> rounds {get;set;}
        public String data {get;set;}
        public List <String> rows {get;set;}
        public Boolean isCommunity {get;set;}
        public Boolean allowEditByCommUser {get;set;}
        public String accId {get;set;}
        public String accName {get;set;}
        CapTableDataDhtmlx (List <Report_Period__c> rounds, String data, List  <String> rows, Boolean isCommunity, Boolean allowEditByCommUser, String accId, String accName){
            this.rounds = rounds;
            this.data = data;
            this.rows = rows;
            this.isCommunity = isCommunity;
            this.allowEditByCommUser = allowEditByCommUser;
            this.accId = accId;
            this.accName = accName;
        }
        
    }
    
    @RemoteAction
    global static void deleteReportPeriod (String ReportPeriodId){
        delete [select Id from Report_Period__c where id =:ReportPeriodId]; 
    }
     
    @RemoteAction
    global static void createReportPeriod(String body, String accountId, String rpId){
        Report_Period__c repPeriod  = (Report_Period__c)JSON.deserialize(body, Report_Period__c.class);
        repPeriod.Account__c = accountId;
        if (rpId != ''){
            repPeriod.Id = rpId;
        }
        upsert repPeriod;
    }

    @RemoteAction
    global static String getSavedTemplates(){
        JSONGenerator generator = JSON.createGenerator(true);
        generator.writeStartObject(); 
        generator.writeFieldName('options');
        generator.writeStartArray(); //Write the starting marker of a JSON object '['
        
        for (Chart_of_Accounts_Template__c ch: [select id, Name__c from Chart_of_Accounts_Template__c order by Name__c asc]){
            generator.writeStartObject(); //Write the starting marker of a JSON object '{'
            
            generator.writeStringField('value', ch.Id);
            generator.writeStringField('text', ch.Name__c);
            
            generator.writeEndObject(); //Write the end marker of a JSON object '}'
        }

        generator.writeEndArray(); //Write the end marker of a JSON object ']'
        generator.writeEndObject();
        
        return generator.getAsString();
    }

    @RemoteAction
    global static void deleteTemplate (String templId){
        delete [select Id from Chart_of_Accounts_Template__c where id =:templId]; 
    }

    @RemoteAction
    global static void applyTemplate(String templId, String accountId){ 
        List <Chart_of_Accounts__c> newChList = new List <Chart_of_Accounts__c>();
        for (Chart_of_Accounts_Template_Item__c ch: [select Name, Category__c, Formula__c from Chart_of_Accounts_Template_Item__c where Chart_of_Accounts_Template__c =:templId]){
            Chart_of_Accounts__c newCh = new Chart_of_Accounts__c();
            newCh.Name = ch.Name;
            newCh.Category__c = ch.Category__c;
            newCh.Formula__c = ch.Formula__c;
            newCh.Account__c = accountId;
            newChList.add(newCh);
        }
        insert newChList;
    }

    @RemoteAction
    global static void createTemplate(String name, String accountId){
        String templId;

        if(name instanceof Id)  {
            templId = name;
            delete [select id from Chart_of_Accounts_Template_Item__c where Chart_of_Accounts_Template__c =: templId];
        } else {

            String duplName = name + ' (%';
            Set <String> dupl = new Set <String>();
            for(Chart_of_Accounts_Template__c cht: [select id, Name__c from Chart_of_Accounts_Template__c where Name__c like: duplName or Name__c =: name]){
                dupl.add(cht.name__c);
            }
            if(dupl.contains(name)){
                for (Integer i=1; i<100; i++){
                    if (!dupl.contains(name + ' (' + i + ')')){
                        name = name + ' (' + i + ')';
                        break;
                    }
                }
            }

            Chart_of_Accounts_Template__c templ = new Chart_of_Accounts_Template__c (Name__c = name);
            insert templ;
            templId = templ.Id;
        }

        List <Chart_of_Accounts_Template_Item__c> templItemsList = new List <Chart_of_Accounts_Template_Item__c>();
        for (Chart_of_Accounts__c ch: [select Name, Category__c, Formula__c from Chart_of_Accounts__c where Account__c =:accountId]){
            Chart_of_Accounts_Template_Item__c templItem = new Chart_of_Accounts_Template_Item__c();
            templItem.Name = ch.Name;
            templItem.Category__c = ch.Category__c;
            templItem.Formula__c = ch.Formula__c;
            templItem.Chart_of_Accounts_Template__c = templId;
            templItemsList.add(templItem);
        }
        insert templItemsList;

    }
    
    @RemoteAction
    global static String getTemplatesData(){
        JSONGenerator generator = JSON.createGenerator(true);
        generator.writeStartObject(); 
        generator.writeFieldName('rows');
        generator.writeStartArray(); //Write the starting marker of a JSON object '['
        for (Chart_of_Accounts_Template__c ch: [select id, Name__c from Chart_of_Accounts_Template__c order by Name__c asc]){
            generator.writeStartObject(); //Write the starting marker of a JSON object '{'
            generator.writeStringField('id', ch.Id);
            List<String> strlist = new List<String>();
            strlist.add(ch.name__c);
            strlist.add('delete.png');
            generator.writeObjectField('data', strlist);
            generator.writeEndObject(); //Write the end marker of a JSON object '}'
        }
        
        generator.writeEndArray(); //Write the end marker of a JSON object ']'
        generator.writeEndObject();  
        return generator.getAsString();
    }

    
    @RemoteAction
    global static String getTemplatesPreview(String remplId){
        JSONGenerator generator = JSON.createGenerator(true);
        generator.writeStartObject(); 
        generator.writeFieldName('rows');
        generator.writeStartArray(); //Write the starting marker of a JSON object '['
        for (Chart_of_Accounts_Template_Item__c ch: [select id, Name, Category__c from Chart_of_Accounts_Template_Item__c where Chart_of_Accounts_Template__c =: remplId order by Name asc]){
            generator.writeStartObject(); //Write the starting marker of a JSON object '{'
            generator.writeStringField('id', ch.Id);
            List<String> strlist = new List<String>();
            strlist.add(ch.name);
            strlist.add(ch.Category__c);
            generator.writeObjectField('data', strlist);
            generator.writeEndObject(); //Write the end marker of a JSON object '}'
        }
        
        generator.writeEndArray(); //Write the end marker of a JSON object ']'
        generator.writeEndObject();  
        return generator.getAsString();
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
        accountId = accountId != '' ? accountId : getAccountId();
        system.debug(accountId);
        
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
        
        account a =  [select Id,Allow_edits_by_community_users__c, Name from Account where id = :accountId];
        
        CapTableDataDhtmlx retData = new CapTableDataDhtmlx(periods,generator.getAsString(),rows, isCommunity, a.Allow_edits_by_community_users__c, a.Id, a.Name);
        return retData;
    }
    
    private static String getAccountId(){
        String accId;
        accId = [select id,Account_Id__c from user where id=:UserInfo.getUserId()].Account_Id__c;
        if (accId == null){
            accId = [select id from Account where Name = 'Canapi' limit 1].Id;
        }
        return accId;
    }
    
    @RemoteAction
    global static void deleteChartOfAccounts (String chId){
        system.debug(chId);
        delete [select id from Chart_of_Accounts__c WHERE id =:chId];
    }
    
    public class CapTableControllerException extends Exception {}
}