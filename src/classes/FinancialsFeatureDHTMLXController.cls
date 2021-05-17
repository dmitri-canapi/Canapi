global class FinancialsFeatureDHTMLXController {
    
   
    
    global class CapTableDataDhtmlx{
        public List <Report_Period__c> rounds {get;set;}
        public String data {get;set;}
        public List <String> rows {get;set;}
        public Boolean isCommunity {get;set;}
        public Boolean allowEditByCommUser {get;set;}
        public String accId {get;set;}
        public String accName {get;set;}
        public String RTname {get;set;}
        public List <Financial_Category__c> fins {get;set;}
        CapTableDataDhtmlx (List <Report_Period__c> rounds, String data, List  <String> rows, Boolean isCommunity, Account a){
            this.rounds = rounds;
            this.data = data;
            this.rows = rows;
            this.isCommunity = isCommunity;
            this.allowEditByCommUser = a.Allow_edits_by_community_users__c;
            this.accId = a.Id;
            this.accName = a.Name;
            this.RTname = a.RecordType.Name;
            this.fins = [Select id, Name, Type__c from Financial_Category__c where Account__c =: a.Id order by Name asc];
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
        map <String,Financial_Category__c>  catsMap = new map <String,Financial_Category__c>();
        for (Financial_Category__c finCat: [select id, Name, Type__c from Financial_Category__c where Account__c =: accountId]){
            catsMap.put(finCat.Name, finCat);
        }
        List<Financial_Category__c> newCats = new List<Financial_Category__c>();

        for (Chart_of_Accounts_Template_Item__c ch: [select Category_Name__c, Category_type__c from Chart_of_Accounts_Template_Item__c where Chart_of_Accounts_Template__c =:templId]){
            if (!catsMap.ContainsKey(ch.Category_Name__c)){
                newCats.add(new Financial_Category__c(Name = ch.Category_Name__c, Type__c = ch.Category_type__c, Account__c = accountId));
                catsMap.put(ch.Category_Name__c, new Financial_Category__c());
            }
        }
        insert newCats;

        for (Financial_Category__c finCat: [select id, Name, Type__c from Financial_Category__c where Account__c =: accountId]){
            catsMap.put(finCat.Name, finCat);
        }

        for (Chart_of_Accounts_Template_Item__c ch: [select Name, Category_Name__c, Formula__c, Category_type__c, Type__c,Sequence_Number__c, Internal_Only__c from Chart_of_Accounts_Template_Item__c where Chart_of_Accounts_Template__c =:templId]){
            Chart_of_Accounts__c newCh = new Chart_of_Accounts__c();
            newCh.Name = ch.Name;
            newCh.Financial_Category__c = catsMap.get(ch.Category_Name__c).Id;
            newCh.Formula__c = ch.Formula__c;
            newCh.Account__c = accountId;
            newCh.Type__c = ch.Type__c;
            newCh.Sequence_Number__c = ch.Sequence_Number__c;
            newCh.Internal_Only__c = ch.Internal_Only__c;
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
        for (Chart_of_Accounts__c ch: [select Name, Formula__c, Type__c,Financial_Category__r.Name,Financial_Category__r.Type__c,Sequence_Number__c, Internal_Only__c from Chart_of_Accounts__c where Account__c =:accountId and Default_Line_Item__c = false]){
            Chart_of_Accounts_Template_Item__c templItem = new Chart_of_Accounts_Template_Item__c();
            templItem.Name = ch.Name;
            templItem.Category_Name__c = ch.Financial_Category__r.Name;
            templItem.Category_type__c = ch.Financial_Category__r.Type__c;
            templItem.Type__c = ch.Type__c;
            templItem.Formula__c = ch.Formula__c;
            templItem.Chart_of_Accounts_Template__c = templId;
            templItem.Sequence_Number__c = ch.Sequence_Number__c;
            templItem.Internal_Only__c = ch.Internal_Only__c;
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
            strlist.add('deleteLight.png');
            generator.writeObjectField('data', strlist);
            generator.writeEndObject(); //Write the end marker of a JSON object '}'
        }
        
        generator.writeEndArray(); //Write the end marker of a JSON object ']'
        generator.writeEndObject();  
        return generator.getAsString();
    }

    @RemoteAction
    global static String getCatGridData(String accId){
        JSONGenerator generator = JSON.createGenerator(true);
        generator.writeStartObject(); 
        generator.writeFieldName('rows');
        generator.writeStartArray(); //Write the starting marker of a JSON object '['
        for (Financial_Category__c fc: [select id, Name, Type__c from Financial_Category__c where Account__c=:accId  order by Name asc]){
            generator.writeStartObject(); //Write the starting marker of a JSON object '{'
            generator.writeStringField('id', fc.Id);
            List<String> strlist = new List<String>();
            strlist.add(fc.name);
            strlist.add(fc.Type__c == 'Static' ? '1' : '0');
            strlist.add(fc.Type__c == 'Calculated' ? '1' : '0');
            strlist.add('editLight.png');
            strlist.add('deleteLight.png');
            generator.writeObjectField('data', strlist);
            generator.writeEndObject(); //Write the end marker of a JSON object '}'
        }
        
        generator.writeEndArray(); //Write the end marker of a JSON object ']'
        generator.writeEndObject();  
        return generator.getAsString();
    }

    @RemoteAction
    global static void setCatData(String catId, String cat){
        update new Financial_Category__c(id = catId, Type__c = cat);
    }

    @RemoteAction
    global static void deleteCategory(String catId){
        delete [select id from Chart_of_Accounts__c where Financial_Category__c =: catId];
        delete new Financial_Category__c(id = catId);
    }

    @RemoteAction
    global static void addCategory(String catName, String AccId){
        insert new Financial_Category__c(Name = catName, Account__c = AccId);
    }

    @RemoteAction
    global static void setCategoryName(String catId, String catName){
        update new Financial_Category__c(Id = catId, Name = catName);
    }

    
    @RemoteAction
    global static String getTemplatesPreview(String remplId){
        JSONGenerator generator = JSON.createGenerator(true);
        generator.writeStartObject(); 
        generator.writeFieldName('rows');
        generator.writeStartArray(); //Write the starting marker of a JSON object '['
        for (Chart_of_Accounts_Template_Item__c ch: [select id, Name, Category_Name__c from Chart_of_Accounts_Template_Item__c where Chart_of_Accounts_Template__c =: remplId order by Name asc]){
            generator.writeStartObject(); //Write the starting marker of a JSON object '{'
            generator.writeStringField('id', ch.Id);
            List<String> strlist = new List<String>();
            strlist.add(ch.name);
            strlist.add(ch.Category_Name__c);
            generator.writeObjectField('data', strlist);
            generator.writeEndObject(); //Write the end marker of a JSON object '}'
        }
        
        generator.writeEndArray(); //Write the end marker of a JSON object ']'
        generator.writeEndObject();  
        return generator.getAsString();
    }
    
    @RemoteAction
    global static void createChartOfAccounts(String numb, String name, String Cat, String type, String formula, Boolean IntOnly, String ShowOnGraph, String chAccId, String id){
        system.debug(type);
        Chart_of_Accounts__c chart = new Chart_of_Accounts__c();
        chart.Sequence_Number__c = numb;
        chart.Name = name;
        chart.Account__c = id;
        chart.Financial_Category__c = Cat;
        chart.Formula__c = formula;
        chart.Type__c = type;
        chart.Internal_Only__c = IntOnly;
        chart.Graph_Type__c = ShowOnGraph;
        if (chAccId!=null) chart.Id = chAccId;
        upsert chart; 
    }

    @RemoteAction
    global static List <Document__c> getUserFiles(String recordId){
        return [select id, Name__c from Document__c where Account__c =: recordId and CreatedById =: UserInfo.getUserId() order by createddate asc];
    }

    @RemoteAction
    global static void removeDocument (String docId){
        delete new Document__c(id=docId);
    }

    @RemoteAction
    global static String prepareDocumentForUpload(String filename,String accId, String quarter){
        Document__c doc = new Document__c();
        String trimmedName;
        if (filename.length()>80){
            trimmedName = filename.substring(0,80);
        } else {
            trimmedName=filename;
        }
        doc.Name = trimmedName;
        doc.Name__c = filename;
        doc.Account__c=accId;
        
        insert doc;

        Tag__c tag = new Tag__c();
        Tag__c parentTag = new Tag__c();
        try {
            parentTag = [select id from Tag__c where Account__c=:accId and Name = 'Reports'];
        } catch(exception e){
            parentTag = new Tag__c(Account__c = accId, Name = 'Reports');
            insert parentTag;
        }

        try {
            tag = [select id from Tag__c where Account__c=:accId and Name =: quarter];
        } catch(exception e){
            tag.name = quarter;
            tag.Account__c = accId;
            
            tag.ParentTag__c = parentTag.Id;
            
            insert tag;
        }
        
        
        TagDocumentAssociation__c tda = new TagDocumentAssociation__c(Tag__c=tag.Id,Document__c=doc.Id);
        insert tda;
        
        return doc.Id;
    }
    
    @RemoteAction
    global static void setFinancials(String chartId, String repId, String val, String type) {
        Financials__c fin = new Financials__c();
        try {
            fin = [select Id  from Financials__c where Report_Period__c = :repId and Chart_of_Accounts__c = :chartId order by CreatedDate asc limit 1 ];
        } catch(exception e){
            fin.Report_Period__c = repId;
            fin.Chart_of_Accounts__c = chartId;
        }
        if (type == 'Currency' || type == 'Percentage' || type == 'Number' || type == 'Integer'){
            fin.Value__c = Decimal.ValueOf(val);
        }
        if (type == 'Date'){
            fin.DateValue__c = Date.ValueOf(val);
        }
        if (type == 'Text'){
            fin.TextValue__c = val;
        }
        upsert fin;
        
    }

    /*@RemoteAction
    global static void setSequenceNumber(String chartId, String val) {
        Chart_of_Accounts__c ch = new Chart_of_Accounts__c(id = chartId, Sequence_Number__c = val);
        update ch;
        
    }*/

    @RemoteAction
    global static void saveFinancialReport(List <Financials__c> fins, String accId) { 
        system.debug(fins);
        if (fins.size()>0){
            String rpid = fins[0].Report_Period__c;
            if ((rpid instanceof Id) == false){
                Report_Period__c rp = new Report_Period__c(Quarter__c = fins[0].Report_Period__c, Account__c = accId);
                insert rp;
                for (Financials__c fin: fins){
                    fin.Report_Period__c = rp.Id;
                    
                }
            }

            for (Financials__c dbFin: [select Id,Chart_of_Accounts__c from Financials__c where Report_Period__c = :fins[0].Report_Period__c]){
                for(Financials__c fin: fins){
                    if (fin.Chart_of_Accounts__c == dbFin.Chart_of_Accounts__c){
                        fin.Id = dbFin.Id;
                    }
                    system.debug(String.valueOf(fin.DateValue__c));
                    if ((String.valueOf(fin.DateValue__c) == '1970-01-01')){
                        fin.DateValue__c = null;
                    }
                }
            }
            upsert fins;
        }
    }

    
    @RemoteAction
    global static void AllowEditingUpdate (String accountId, Boolean AllowEditing) {
        account a =  new Account (Id = accountId, Allow_edits_by_community_users__c = AllowEditing);
        update a;
    }

    @RemoteAction
    global static String requestFinReport (String accId) {
        List <Messaging.SingleEmailMessage> messages = new List <Messaging.SingleEmailMessage>();
        String SentToUsers = '';
        EmailTemplate emailTemplate = [Select Id from EmailTemplate where developerName = 'Financial_Report_Request'];

        for(User u: [select id, Name, email from User where accountId=: accId and contact.Financial_Report_Contact__c = true and Profile.Name = 'Community: Fintech Portal']){
            SentToUsers = SentToUsers + u.Name + ' (' + u.Email + ')' + ', ';
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                               
                message.setTargetObjectId(u.Id);
                message.setSaveAsActivity(false);
                message.setUseSignature(false);
                message.setSaveAsActivity(false); 
                message.setTemplateID(emailTemplate.Id);
                messages.add(message);

        }

        if (messages.size() > 0){
            Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
        } 
        return SentToUsers.removeEnd(', ');
    }
    
    @RemoteAction
    global static CapTableDataDhtmlx getCapTableData(String accountId) {
        accountId = accountId != '' ? accountId : getAccountId();
        system.debug(accountId);
        
        List<Report_Period__c> periods = [
            SELECT Id, 
            IsDeleted,
            Name,
            Date__c,
            Quarter__c
            FROM Report_Period__c
            WHERE Account__c = :accountId
            ORDER by Date__c ASC NULLS LAST, CreatedDate ASC 
        ];

        if ([select id from Financial_Category__c where Account__c =: accountId].size() == 0){
            List <Financial_Category__c> finCats = new List <Financial_Category__c>();
            finCats.add(new Financial_Category__c(Name = 'Revenue', Account__c = accountId));
            finCats.add(new Financial_Category__c(Name = 'Expense', Account__c = accountId));
            finCats.add(new Financial_Category__c(Name = 'Other', Account__c = accountId));
            finCats.add(new Financial_Category__c(Name = 'Metric', Account__c = accountId, Type__c = 'Calculated'));
            insert finCats;
        }

        Map <String,String> catToId = new Map <String,String>();
        if ([select id from Chart_of_Accounts__c where Account__c = :accountId and Default_Line_Item__c = true].size() == 0){
            set <String> existingChartNames = new set <String>();
            for (Chart_of_Accounts__c ch: [SELECT Name FROM Chart_of_Accounts__c WHERE Account__c = :accountId]){
                existingChartNames.add(ch.Name);
            }
            List <Financials_Default_Line_Items__mdt> defLineItems = [select id, DeveloperName, Category__c, Internal_Only__c, Sequence_Number__c, Type__c from Financials_Default_Line_Items__mdt where DeveloperName NOT IN: existingChartNames];
            Map <String,String> finCatsMap = new Map <String,String>();
            for(Financial_Category__c fc: [select id,Name from Financial_Category__c where Account__c =: accountId]){
                finCatsMap.put(fc.Name, fc.Id);
            }
            List <Financial_Category__c> finCats = new List <Financial_Category__c>();
            for (Financials_Default_Line_Items__mdt li: defLineItems){
                if(!finCatsMap.ContainsKey(li.Category__c)){
                    finCats.add(new Financial_Category__c(Name = li.Category__c, Account__c = accountId));
                    finCatsMap.put(li.Category__c, '');
                }
            }
            insert finCats;
            for(Financial_Category__c fc: [select id,Name from Financial_Category__c where Account__c =: accountId]){
                finCatsMap.put(fc.Name, fc.Id);
            }

            List<Chart_of_Accounts__c> defCharts = new List<Chart_of_Accounts__c>();
            for (Financials_Default_Line_Items__mdt li: defLineItems){
                defCharts.add(new Chart_of_Accounts__c(Account__c = accountId, TemplateId__c = li.Id, Graph_Type__c  = 'Bar Graph', Default_Line_Item__c = true, Name = li.DeveloperName,  Financial_Category__c = finCatsMap.get(li.Category__c), Internal_Only__c = li.Internal_Only__c, Sequence_Number__c = li.Sequence_Number__c, Type__c = li.Type__c));
            }
            insert defCharts;


        }
        
        List<Chart_of_Accounts__c> charts = [
            SELECT Id, 
            Sequence_Number__c,
            Name,
            Financial_Category__r.Name,
            Financial_Category__r.type__c,
            Formula__c,
            Type__c,
            Internal_Only__c,
            Default_Line_Item__c,
            Graph_Type__c 
            FROM Chart_of_Accounts__c
            WHERE Account__c = :accountId 
            AND Financial_Category__r.Id != null
            ORDER by Financial_Category__r.Name ASC, Sequence_Number__c ASC NULLS LAST, Name ASC, Id ASC
        ];
        
        List<Financials__c> financials =[
            Select id,
            Chart_of_Accounts__c,
            Chart_of_Accounts__r.Name,
            Report_Period__c,
            Value__c,
            TextValue__c,
            DateValue__c
            FROM Financials__c
            WHERE  Report_Period__r.Account__c = :accountId
            AND Chart_of_Accounts__r.Account__c = :accountId
            AND Chart_of_Accounts__r.Financial_Category__c != null
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
            if(isCommunity == false || (chr.Internal_Only__c == false && isCommunity == true)){
            generator.writeStartObject(); 
            generator.writeStringField('id', chr.Id);
            
            generator.writeFieldName('userdata');
            generator.writeStartObject();
            generator.writeStringField('Formula', chr.Formula__c != null ? chr.Formula__c : '');
            generator.writeStringField('Type', chr.Type__c);
            generator.writeStringField('CatType', chr.Financial_Category__r.type__c);
            generator.writeStringField('CatName', chr.Financial_Category__r.Name);
            generator.writeStringField('CatId', chr.Financial_Category__c);
            generator.writeBooleanField('InternalOnly', chr.Internal_Only__c);
            generator.writeBooleanField('DefaultLI', chr.Default_Line_Item__c);
            generator.writeStringField('ShowOnGraph', chr.Graph_Type__c == null ? 'None' : chr.Graph_Type__c);
            generator.writeEndObject();
            
            List<String> strlist = new List<String>();
            strlist.add(chr.Sequence_Number__c != null ? chr.Sequence_Number__c : '');
            if (isCommunity){
                strlist.add( chr.Name  + '^' + Network.communitiesLanding().getUrl() + 'detail/' + chr.Id ); 
               
            } else {
                strlist.add( chr.Name  + '^' + '/' + chr.Id );
            }
            if (chr.Type__c == 'Currency' || chr.Type__c == 'Percentage' || chr.Type__c == 'Number' || chr.Type__c == 'Integer'){
                rows.add(chr.Name);
            }
            strlist.add(chr.Financial_Category__r.Name);
            for (Report_Period__c rp: periods){
                boolean isInvestmentForRound = false;
                for (Financials__c fin: financials){
                    if (fin.Chart_of_Accounts__c == chr.Id && fin.Report_Period__c == rp.Id ){
                        if ((chr.Type__c == 'Currency' || chr.Type__c == 'Percentage' || chr.Type__c == 'Number' || chr.Type__c == 'Integer')  && fin.Value__c!=null){
                            if(chr.Type__c == 'Percentage'){
                                strlist.add(String.valueOf(fin.Value__c.setScale(1)));
                            } else if (chr.Type__c == 'Integer'){
                                strlist.add(String.valueOf(fin.Value__c.setScale(0)));
                            } else {
                                strlist.add(String.valueOf(fin.Value__c));
                            }
                            
                            isInvestmentForRound = true;
                            break;
                        } else if (chr.Type__c == 'Date' && fin.DateValue__c!=null){
                            strlist.add(String.valueOf(fin.DateValue__c));
                            isInvestmentForRound = true;
                            break;
                        } else if (chr.Type__c == 'Text' && fin.TextValue__c!=null){
                            strlist.add(fin.TextValue__c);
                            isInvestmentForRound = true;
                            break;
                        }
                    }   
                }
                if (!isInvestmentForRound){
                   switch on chr.Type__c {
                        when 'Currency', 'Number' {	
                            strlist.add('0.00');
                        }
                        when 'Percentage' {
                            strlist.add('0.0');
                        }	
                        when 'Integer' {
                            strlist.add('0');
                        }
                        when 'Date', 'Text' {
                            strlist.add('');
                        }
                        
                    }

                    /*if (chr.Type__c == 'Currency' || chr.Type__c == 'Percentage' || chr.Type__c == 'Number'){
                       if(chr.Type__c == 'Percentage'){
                            strlist.add('0.0');
                        } else {
                            strlist.add('0.00');
                        }
                    } else if (chr.Type__c == 'Date' || chr.Type__c == 'Text'){
                        strlist.add('');
                    } */
                }
            }
            
            generator.writeObjectField('data', strlist);
            generator.writeEndObject(); //Write the end marker of a JSON object '}'
        }
            
        }
        generator.writeEndArray(); //Write the end marker of a JSON object ']'
        generator.writeEndObject(); 
        
        account a =  [select Id,Allow_edits_by_community_users__c, Name, RecordType.Name from Account where id = :accountId];
        
        CapTableDataDhtmlx retData = new CapTableDataDhtmlx(periods,generator.getAsString(),rows, isCommunity, a);
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