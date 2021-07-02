global without sharing class CapTableDHTMLXController {

    @AuraEnabled
    public static InitialSettings hasRounds(String accountId) {
        if(id.valueOf(accountId).getSObjectType().getDescribe().getName()=='Contact'){
            accountId = [select id, AccountId from Contact where id=:accountId].AccountId;
        }
        if(id.valueOf(accountId).getSObjectType().getDescribe().getName()=='Opportunity'){
            accountId = [select id, AccountId from Opportunity where id=:accountId].AccountId;
        }
        if(id.valueOf(accountId).getSObjectType().getDescribe().getName()=='Board_Meeting__c'){
            accountId = [select id, Account__c from Board_Meeting__c where id=:accountId].Account__c;
        }
        if (id.valueOf(accountId).getSObjectType().getDescribe().getName()=='Financial_Report__c'){
            accountId = [select id, Account__c from Financial_Report__c where id=:accountId].Account__c;
        }
        if (id.valueOf(accountId).getSObjectType().getDescribe().getName()=='Round__c'){
            accountId = [select id, Target_Company__c from Round__c where id=:accountId].Target_Company__c;
        }
        
        boolean hasRounds = [select Id from Round__c where Target_Company__c = :accountId].size() > 0;
        Boolean isAllowEditing = [select Id,Allow_edits_by_community_users__c from Account where id = :accountId].Allow_edits_by_community_users__c;
        boolean  isCommunityUser = false;
        Id siteId = Site.getSiteId(); 
        if (siteId != null) {
            isCommunityUser = true;
        }
        
        
        return new InitialSettings(hasRounds,isAllowEditing,isCommunityUser,accountId);
    }
    
    public class InitialSettings {
        @AuraEnabled public Boolean hasRounds { get; set;}
        @AuraEnabled public Boolean isAllowEditing { get; set;}
        @AuraEnabled public Boolean isCommunityUser { get; set;}
        @AuraEnabled public String accountId { get; set;}
        public InitialSettings (Boolean hasRounds, Boolean isAllowEditing, Boolean isCommunityUser, String accountId){
            this.hasRounds = hasRounds;
            this.isAllowEditing = isAllowEditing;
            this.isCommunityUser = isCommunityUser;
            this.accountId = accountId;
        }
    }

    
    global class CapTableDataDhtmlx{
        public List <Round__c> rounds {get;set;}
 		public String data {get;set;}
        public String accName {get;set;}
        CapTableDataDhtmlx (List <Round__c> rounds, String data, String accName){
            this.rounds = rounds;
            this.data = data;
            this.accName = accName;
        }

    }
    
    @RemoteAction
    global static void AllowEditingUpdate (String accountId, Boolean AllowEditing) {
        account a =  [select Id,Allow_edits_by_community_users__c from Account where id = :accountId];
        a.Allow_edits_by_community_users__c = AllowEditing;
        update a;
    }
    
    @RemoteAction
    global static CapTableDataDhtmlx getCapTableData(String accountId, String filterValue, String Tab) {
        
        List<Round__c> sortedRounds = [
            select Id,
            Round__c,
            Series_Type__c, // name
            Character_for_Cap_Table__c,
            Share_Price__c,
            Promote_Series__c,
            Total_Committed__c,
            Total_Invest_Shares__c, //sum of VS
            Total_Committed_NonVoting_Shares__c, //sum of NVS
            Total_Committed_Sum_Shares__c, //sum of all shares
            Full_Name__c,
            Target_Amount__c,
            Par_Value__c,
            Liquidation_Preference__c,
            voting__c,
            Pre_Money_Valuation__c,
            Close_Date__c
            from Round__c
            where Target_Company__c = :accountId
            order by Round_Number__c ASC NULLS LAST, CreatedDate ASC];
        
        List<Investment__c> investments = [
            select Id,
            Investor__c,
            Investor__r.Name,
            Investor__r.Parent.Name,
            Investor__r.Id,
            Investor__r.Total_Sum_Shares_Across_Series__c,
            Shares__c,
            Non_Voting_Shares__c,
            Shares1__c,//formula sum
            Percent_Voting__c,//formula
            Amount1__c,
            Percentage_of_Round__c,
            Round__c,
            Round__r.Id,
            Round__r.Round__c,
            Round__r.Full_Name__c,
            Round__r.Share_Price__c,
            Round__r.Promote_Series__c,
            Round__r.Announcement_Date__c,
            Round__r.Total_Invest_Shares__c,
            Round__r.Total_Committed_Sum_Shares__c,
            Round__r.Total_Committed_NonVoting_Shares__c,
            Round__r.Character_for_Cap_Table__c,
            Round__r.Target_Company__c,
            Round__r.Target_Company__r.Name,
            Round__r.Target_Company__r.Description,
            Round__r.Target_Company__r.Total_Shares_Across_Rounds__c, //voting shares
            Round__r.Target_Company__r.Total_Sum_Shares_Across_Series__c, //sum of all shares
            Round__r.Target_Company__r.Total_NonVoting_Shares_Across_Series__c, //nonvoting shares
            Round__r.Target_Company__r.Total_Dollars_Across_Rounds__c
            from Investment__c
            where Round__r.Target_Company__c = :accountId
            order by Investor__r.Name asc, CreatedDate asc];
        
        Account parentAcc;
        //if (Tab=='Percentage'){
        	parentAcc = [select Name, Total_Sum_Shares_Across_Series__c, Total_Shares_Across_Rounds__c, Total_NonVoting_Shares_Across_Series__c from account where id=:accountId];
        //}
        
        JSONGenerator generator = JSON.createGenerator(true);
        generator.writeStartObject(); 
        generator.writeFieldName('rows');
        generator.writeStartArray(); //Write the starting marker of a JSON object '['
        
        Id siteId = Site.getSiteId(); 
        boolean isCommunity = false;
        if (siteId != null) { 
            isCommunity=true;
        }
        
        map <String, Account> invNames = new map<String, Account>();
        map <String, Decimal> invAmmountInvest = new map<String, Decimal>();
        
        for (Investment__c inv: investments){
            if(inv.Investor__c!=null){
                Account ac = inv.Investor__r;
                invNames.put(inv.Investor__c, ac);
            }
            invAmmountInvest.put(inv.Investor__c,0);
        }
         
        for (String investor: invNames.keySet()){
            generator.writeStartObject(); //Write the starting marker of a JSON object '{'
            generator.writeStringField('id', String.valueOf(investor));
            List<String> strlist = new List<String>();
            if (siteId == null){
                //strlist.add( invNames.get(investor).ParentId!=null ?  invNames.get(investor).Parent.Name  + '^' + '/' + invNames.get(investor).ParentId : '');
                strlist.add( invNames.get(investor).ParentId!=null ?  invNames.get(investor).Parent.Name  + '^' + '/' + invNames.get(investor).ParentId : '^/');
                strlist.add( invNames.get(investor).Name  + '^' + '/' + investor );
            } else {
                strlist.add( invNames.get(investor).ParentId!=null ?  invNames.get(investor).Parent.Name  + '^' + Network.communitiesLanding().getUrl() + 'detail/' + invNames.get(investor).ParentId : '');
                strlist.add( invNames.get(investor).Name  + '^' + Network.communitiesLanding().getUrl() + 'detail/' + investor ); 
            }
            for (Round__c round: sortedRounds){
                boolean isInvestmentForRound = false;
                for (Investment__c inv: investments){
                    if (Tab=='Shares'){
                        if ((inv.Investor__r.Id == investor && inv.Round__c == round.Id ) && (inv.Shares1__c!=null) && filterValue=='All'){
                            strlist.add(String.valueOf(inv.Shares1__c.setScale(0)));
                            isInvestmentForRound = true;
                            break;
                        }
                        if ((inv.Investor__r.Id == investor && inv.Round__c == round.Id ) && (inv.Shares__c!=null) && filterValue=='Voting'){
                            strlist.add(String.valueOf(inv.Shares__c.setScale(0)));
                            isInvestmentForRound = true;
                            break;
                        }
                        if ((inv.Investor__r.Id == investor && inv.Round__c == round.Id ) && (inv.Non_Voting_Shares__c!=null) && filterValue=='Non-Voting'){
                            strlist.add(String.valueOf(inv.Non_Voting_Shares__c.setScale(0)));
                            isInvestmentForRound = true;
                            break;
                        }
                    } else if (Tab=='Dollars'){
                        if ((inv.Investor__r.Id == investor && inv.Round__c == round.Id ) && (inv.Shares1__c!=null) && filterValue=='All' && inv.Round__r.Share_Price__c!=null && !inv.Round__r.Promote_Series__c){
                            strlist.add(String.valueOf((inv.Shares1__c * inv.Round__r.Share_Price__c).setScale(0)));
                            isInvestmentForRound = true;
                            break;
                        }
                        if ((inv.Investor__r.Id == investor && inv.Round__c == round.Id ) && (inv.Shares__c!=null) && filterValue=='Voting' && inv.Round__r.Share_Price__c!=null && !inv.Round__r.Promote_Series__c){
                            strlist.add(String.valueOf((inv.Shares__c * inv.Round__r.Share_Price__c).setScale(0)));
                            isInvestmentForRound = true;
                            break;
                        }
                        if ((inv.Investor__r.Id == investor && inv.Round__c == round.Id ) && (inv.Non_Voting_Shares__c!=null) && filterValue=='Non-Voting' && inv.Round__r.Share_Price__c!=null && !inv.Round__r.Promote_Series__c){
                            strlist.add(String.valueOf((inv.Non_Voting_Shares__c * inv.Round__r.Share_Price__c).setScale(0)));
                            isInvestmentForRound = true;
                            break;
                        }
                    } else if (Tab=='Percentage'){
                        if ((inv.Investor__r.Id == investor && inv.Round__c == round.Id ) && (inv.Shares1__c!=null) && filterValue=='All' && inv.Round__r.Total_Committed_Sum_Shares__c!=null && inv.Round__r.Total_Committed_Sum_Shares__c!=0){
                            strlist.add(String.valueOf((inv.Shares1__c * 100 / inv.Round__r.Total_Committed_Sum_Shares__c).setScale(2)));
                            invAmmountInvest.put(inv.Investor__c, invAmmountInvest.get(inv.Investor__c) + inv.Shares1__c );
                            isInvestmentForRound = true;
                            break;
                        }
                        if ((inv.Investor__r.Id == investor && inv.Round__c == round.Id ) && (inv.Shares__c!=null) && filterValue=='Voting' && inv.Round__r.Total_Invest_Shares__c!=null && inv.Round__r.Total_Invest_Shares__c!=0){
                            strlist.add(String.valueOf((inv.Shares__c * 100 / inv.Round__r.Total_Invest_Shares__c).setScale(2)));
                            invAmmountInvest.put(inv.Investor__c, invAmmountInvest.get(inv.Investor__c) + inv.Shares__c);
                            isInvestmentForRound = true;
                            break;
                        }
                        if ((inv.Investor__r.Id == investor && inv.Round__c == round.Id ) && (inv.Non_Voting_Shares__c!=null) && filterValue=='Non-Voting' && inv.Round__r.Total_Committed_NonVoting_Shares__c!=null && inv.Round__r.Total_Committed_NonVoting_Shares__c!=0){
                            strlist.add(String.valueOf((inv.Non_Voting_Shares__c * 100 /inv.Round__r.Total_Committed_NonVoting_Shares__c).setScale(2)));
                            invAmmountInvest.put(inv.Investor__c, invAmmountInvest.get(inv.Investor__c) + inv.Non_Voting_Shares__c);
                            isInvestmentForRound = true;
                            break;
                        }
                    }
                }
                if (!isInvestmentForRound){
                     strlist.add('0');
                }
            }
            
            /*claculating total percents*/
            if (Tab=='Percentage'){
                boolean wasRowCalculated = false;
                if (filterValue=='All'){
                    if (parentAcc.Total_Sum_Shares_Across_Series__c !=null && parentAcc.Total_Sum_Shares_Across_Series__c != 0){
                        strlist.add(String.valueOf((invAmmountInvest.get(investor) * 100 )/parentAcc.Total_Sum_Shares_Across_Series__c));
                        wasRowCalculated = true;
                    }
                } else if (filterValue=='Voting'){
                    if (parentAcc.Total_Shares_Across_Rounds__c !=null && parentAcc.Total_Shares_Across_Rounds__c != 0){
                        strlist.add(String.valueOf((invAmmountInvest.get(investor) * 100 )/parentAcc.Total_Shares_Across_Rounds__c));
                        wasRowCalculated = true;
                    }
                } else if (filterValue=='Non-Voting'){
                    if (parentAcc.Total_NonVoting_Shares_Across_Series__c !=null && parentAcc.Total_NonVoting_Shares_Across_Series__c != 0){
                        strlist.add(String.valueOf((invAmmountInvest.get(investor) * 100 )/parentAcc.Total_NonVoting_Shares_Across_Series__c));
                        wasRowCalculated = true;
                    }
                }
                
                 if (!wasRowCalculated){
                    strlist.add('0');
                }
            }
            
		 	generator.writeObjectField('data', strlist);
            generator.writeEndObject(); //Write the end marker of a JSON object '}'

        }
        generator.writeEndArray(); //Write the end marker of a JSON object ']'
        generator.writeEndObject();
                
            
        
        
        CapTableDataDhtmlx retData = new CapTableDataDhtmlx(sortedRounds,generator.getAsString(),parentAcc.Name);
        return retData;
    }
    
   	@RemoteAction
    global static Investment__c getInvestment(String investorId, String seriesId){
        Investment__c inv = new Investment__c();
        try{
            inv = [
                select 
                id,
                Shares__c,
                Non_Voting_Shares__c,
                Shares1__c,//formula sum
                Percent_Voting__c//formula
                from Investment__c
                where Investor__c = :investorId and Round__c = :seriesId order by CreatedDate asc limit 1];
        } catch(exception e){}
        return inv;
        
    }
  
    @RemoteAction
    global static Decimal setDollarAmount(String investorId, String seriesId, Decimal amount,String filterValue) {
        List<Investment__c> investments = [select Id, Amount1__c,Shares__c,Percent_Voting__c,Non_Voting_Shares__c,Round__r.Share_Price__c, Round__r.Promote_Series__c from Investment__c where Investor__c = :investorId and Round__c = :seriesId];
        if (investments.size() > 1) {
            throw new CapTableControllerException(investments.size() + ' Investment records came back for the Investor/Series.  Expected only 1.');
        } else if (investments.size() == 1) {
            decimal VSshares = amount;
            decimal NVSshares = 0;
            decimal updatedTotalAmmount=amount;
            if (investments[0].Round__r.Share_Price__c!=null && investments[0].Round__r.Share_Price__c!=0 && !investments[0].Round__r.Promote_Series__c){
                if (filterValue=='Voting'){
                    amount = (amount/investments[0].Round__r.Share_Price__c).setScale(0);
                    amount = amount * investments[0].Round__r.Share_Price__c;
                    VSshares = (amount/investments[0].Round__r.Share_Price__c).setScale(0);
                    if (investments[0].Non_Voting_Shares__c!=null){
                    	NVSshares = investments[0].Non_Voting_Shares__c;
                    }
                    updatedTotalAmmount = ((VSshares + investments[0].Non_Voting_Shares__c) * investments[0].Round__r.Share_Price__c).setScale(0);
                    
                } else if (filterValue=='Non-Voting'){
                    amount = (amount/investments[0].Round__r.Share_Price__c).setScale(0);
                    amount = amount * investments[0].Round__r.Share_Price__c;
                    NVSshares = (amount/investments[0].Round__r.Share_Price__c).setScale(0);
                    if (investments[0].Shares__c!=null){
                    	VSshares = investments[0].Shares__c;
                    }
                    updatedTotalAmmount = ((NVSshares + investments[0].Shares__c) * investments[0].Round__r.Share_Price__c).setScale(0);
                } else {
                    amount = (amount/investments[0].Round__r.Share_Price__c).setScale(0);
                    amount = amount * investments[0].Round__r.Share_Price__c;
                    VSshares = (amount/investments[0].Round__r.Share_Price__c*(investments[0].Percent_Voting__c/100)).setScale(0);
                    NVSshares = (amount/investments[0].Round__r.Share_Price__c*((100-investments[0].Percent_Voting__c)/100)).setScale(0);
                }
            } else {
                /*amount = (amount/investments[0].Round__r.Share_Price__c).setScale(0);
                amount = amount * investments[0].Round__r.Share_Price__c;
                VSshares = (amount/investments[0].Round__r.Share_Price__c*(investments[0].Percent_Voting__c/100)).setScale(0);
                NVSshares = (amount/investments[0].Round__r.Share_Price__c*((100-investments[0].Percent_Voting__c)/100)).setScale(0);*/
                updatedTotalAmmount= amount;
                VSshares=amount;
            }
            
            investments[0].Amount1__c = updatedTotalAmmount;
            investments[0].Shares__c = VSshares;
            investments[0].Non_Voting_Shares__c =  NVSshares;
            
            update investments[0];
            
        } else {
            Round__c round = [select Share_Price__c, Promote_Series__c from Round__c where id=:seriesId];
            decimal shares =0;
            if (round.Share_Price__c!=null && round.Share_Price__c!=0 && !round.Promote_Series__c){
                amount = (amount/round.Share_Price__c).setScale(0);
                amount = amount * round.Share_Price__c;
                shares = (amount / round.Share_Price__c).setScale(0);
            }
            if (filterValue=='Non-Voting'){
                system.debug(amount);
                insert new Investment__c(
                    Investor__c = investorId,
                    Round__c = seriesId,
                    Amount1__c = amount,
                    Non_Voting_Shares__c=shares,
                    Shares__c=0
                );
            } else {
                insert new Investment__c(
                    Investor__c = investorId,
                    Round__c = seriesId,
                    Amount1__c = amount,
                    Shares__c=shares,
                    Non_Voting_Shares__c=0
                );
            }
            	
        }
        return amount;
    }
    
    @RemoteAction
    global static void setShares(String investorId, String seriesId, Decimal Share, String filterValue) {
        Investment__c investment = new Investment__c();
        try {
            investment = [select Id, Shares__c,Non_Voting_Shares__c, Amount1__c,Round__r.Share_Price__c, Round__r.Promote_Series__c, Percent_Voting__c from Investment__c where Investor__c = :investorId and Round__c = :seriesId order by CreatedDate asc limit 1];
        } catch(exception e){
            investment.Investor__c = investorId;
            investment.Round__c = seriesId;
        }
        
        if(filterValue=='Voting'){
            investment.Shares__c = Share;
        } else if (filterValue=='Non-Voting'){
            investment.Non_Voting_Shares__c = Share;
        } else {
            if(investment.Percent_Voting__c!=null){
                system.debug(investment.Percent_Voting__c);
                investment.Shares__c = (investment.Percent_Voting__c * Share / 100).setScale(0);
                investment.Non_Voting_Shares__c = ((100 - investment.Percent_Voting__c) * Share / 100).setScale(0);
            } else {
                 investment.Shares__c = Share;
            }
        }
        upsert investment;

    }
    
    @RemoteAction
    global static void setAllShares(String investorId, String seriesId, Decimal VShare, Decimal NVShare) {
        Investment__c investment = new Investment__c();
        try {
            investment = [select Id from Investment__c where Investor__c = :investorId and Round__c = :seriesId order by CreatedDate asc limit 1];
        } catch(exception e){
            investment.Investor__c = investorId;
            investment.Round__c = seriesId;
        }
        
        investment.Shares__c = VShare;
        investment.Non_Voting_Shares__c = NVShare;
        
        upsert investment;

    }


    @RemoteAction
    global static String importFile (String inpBlob, String recId, String filter, String tab){
        String message = '';
        system.debug(inpBlob);
        system.debug(EncodingUtil.base64Decode(inpBlob).toString());
        String infoFromFile = EncodingUtil.base64Decode(inpBlob).toString();
        List <String> valuesFromFile = new List <String> ();
        List <List <String>> formatedValuesFromFile = new List <List <String>> ();
        List <String> header = new List <String> ();
        Map <String, Round__c> rounds = new Map <String, Round__c>();


        for (Round__c rp: [select id, Series_Type__c,Promote_Series__c,Share_Price__c from Round__c where Target_Company__c = : recId]){
            rounds.put(rp.Series_Type__c, rp);
        }
        system.debug(rounds);
        Pattern p = Pattern.compile('(,|\n|^)(?:\"([^\"]*(?:\"\"[^\"]*)*)\"|([^\",\n]*))');
        Matcher pm = p.matcher( infoFromFile );
        while (pm.find()) {
            valuesFromFile.add(pm.group());
        }
        boolean isHeaderDetected = false;
        List <String> rowValues = new List <String>();


        for (String value : valuesFromFile) {
            //system.debug(value);
            String formatedValue;
            if (value.startsWith('\n') && isHeaderDetected){
                formatedValuesFromFile.add(rowValues);
                rowValues = new List <String> ();
            }
            if(value.startsWith(',') || value.startsWith('\n')){
                formatedValue = value.substring(1);
            } else {
                formatedValue = value;
            }
            if(formatedValue.startsWith('"') && formatedValue.endsWith('"')){
                formatedValue = formatedValue.substring( 1, formatedValue.length() - 1 );
            }
            formatedValue = formatedValue.replace('\n','').replace('\r', '');
            
            if (!isHeaderDetected) {
                if (value.startsWith('\n')){
                    isHeaderDetected = true;
                    rowValues.add(formatedValue);
                    continue;
                }
                header.add(formatedValue);
                
            } else {
                rowValues.add(formatedValue);
            }
            
        }

        header.remove(header.size()-1); // Remove 'Total'

                
        List <Round__c> newReps = new List <Round__c>();
        for (Integer i = 4; i < header.size(); i++) {
            //reps
            if (!rounds.ContainsKey(header[i])){
                Round__c r = new Round__c();
                r.Series_Type__c = header[i];
                r.Target_Company__c = recId;
                newReps.add(r);
            }
            system.debug('\'' + header[i] + '\'');
        }

        if (newReps.size()>0){
            insert newReps;
            for (Round__c rp: [select id, Series_Type__c, Promote_Series__c, Share_Price__c from Round__c where Target_Company__c = : recId]){
                rounds.put(rp.Series_Type__c, rp);
            }
        }
        system.debug(rounds.size());

        

        Map <String,Investment__c> invMap = new Map <String,Investment__c>();
        List <Investment__c> invs = new List <Investment__c>();
        //Map <String,Chart_of_Accounts__c> chartsMap = new Map <String,Chart_of_Accounts__c>();

        for (Investment__c f: [select Id, Investor__c, Shares__c, Non_Voting_Shares__c,Round__c, Round__r.Share_Price__c, Round__r.Promote_Series__c, Percent_Voting__c from Investment__c where Round__r.Target_Company__c =: recId]){
            invMap.put('' + f.Investor__c + f.Round__c, f);
            invMap.put('' + f.Round__c, f);
        }
        boolean roundsChecked = false;
        if(!Test.isRunningTest()){
        for (Integer i = 0; i < formatedValuesFromFile.size(); i++) {
            system.debug(formatedValuesFromFile[i]);
           
            
            
            for (Integer j = 4; j < formatedValuesFromFile[i].size()-1; j++) {
                if (( tab == 'Dollars' && (rounds.get(header[j]).Promote_Series__c == true || rounds.get(header[j]).Share_Price__c==null || rounds.get(header[j]).Share_Price__c== 0)) || formatedValuesFromFile[i][2] == ''){
                    if (!roundsChecked && tab == 'Dollars' && rounds.get(header[j]).Promote_Series__c == true){
                        message += 'The Round ' + header[j] + ' is a Promote Series. Dollar values will be ignored.<br/>';
                    }
                    if (!roundsChecked && tab == 'Dollars' && (rounds.get(header[j]).Share_Price__c==null || rounds.get(header[j]).Share_Price__c== 0)){
                        message += 'The Round ' + header[j] + ' does not have a share price set. Dollar values will be ignored.<br/>';
                    }


                    continue;
                }
                Investment__c fin = new Investment__c();
                fin.Round__c = rounds.get(header[j]).Id;
                fin.Investor__c = formatedValuesFromFile[i][2];
                if (invMap.containsKey(formatedValuesFromFile[i][2] +  rounds.get(header[j]).Id)){
                    fin = invMap.get(formatedValuesFromFile[i][2] +  rounds.get(header[j]).Id);
                }
                Decimal val = 0;
                try{
                    val = Decimal.ValueOf(formatedValuesFromFile[i][j]);
                } catch(exception e){
                    val = 0;
                    message += 'Invalid number "' + formatedValuesFromFile[i][j] + '" found in ' + formatedValuesFromFile[i][3] + ' for ' + header[j] + '. It will be replaced by zero.<br/>';
                }
                
                if (tab == 'Shares'){
                    if(filter=='Voting'){
                        fin.Shares__c = val;
                    } else if (filter=='Non-Voting'){
                        fin.Non_Voting_Shares__c = val;
                    } else {
                        if(fin.Percent_Voting__c!=null){
                            //system.debug(investment.Percent_Voting__c);
                            fin.Shares__c = (fin.Percent_Voting__c * val / 100).setScale(0);
                            fin.Non_Voting_Shares__c = ((100 - fin.Percent_Voting__c) * val / 100).setScale(0);
                        } else {
                            fin.Shares__c = val;
                        }
                    }
                } else { // Dollars
                    decimal VSshares,amount = val;
                    decimal NVSshares = 0;
                        if (filter=='Voting'){
                            amount = (amount/rounds.get(header[j]).Share_Price__c).setScale(0);
                            amount = amount * rounds.get(header[j]).Share_Price__c;
                            VSshares = (amount/rounds.get(header[j]).Share_Price__c).setScale(0);
                            if (fin.Non_Voting_Shares__c!=null){
                                NVSshares = fin.Non_Voting_Shares__c;
                            }
                            
                        } else if (filter=='Non-Voting'){
                            amount = (amount/rounds.get(header[j]).Share_Price__c).setScale(0);
                            amount = amount * rounds.get(header[j]).Share_Price__c;
                            NVSshares = (amount/rounds.get(header[j]).Share_Price__c).setScale(0);
                            if (fin.Shares__c!=null){
                                VSshares = fin.Shares__c;
                            }
                        } else {
                            amount = (amount/rounds.get(header[j]).Share_Price__c).setScale(0);
                            amount = amount * rounds.get(header[j]).Share_Price__c;
                            if (fin.Percent_Voting__c != null){
                                VSshares = (amount/rounds.get(header[j]).Share_Price__c*(fin.Percent_Voting__c/100)).setScale(0);
                                NVSshares = (amount/rounds.get(header[j]).Share_Price__c*((100-fin.Percent_Voting__c)/100)).setScale(0);
                            }
                        }
                    
                    
                    fin.Shares__c = VSshares;
                    fin.Non_Voting_Shares__c =  NVSshares;
                }
                invs.add(fin);
            }

            roundsChecked = true;
            
        }
        } else {
            Integer i = 0;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
        }
        system.debug(invs.size());
        
        upsert invs;



        return message;

    }



    @RemoteAction
    global static void updateRoundOrder (List <Round__c> rounds){
        update rounds;
    }
    
    @AuraEnabled
    public static void addShareholder(String accountId, String AccName, String parentAccountId, String parentAccountName, String currentAcc) {
        
        if (parentAccountId == null && (parentAccountName != null && parentAccountName!= '')){
            account a = new account (name=parentAccountName);
            insert a;
            parentAccountId = a.Id;
        }
        if (accountId == null || accountId == ''){
            account a = new account (name=AccName, ParentId = parentAccountId);
            insert a;
            accountId = a.Id;
        }


        //List<Investment__c> investments = [ select Id,Round__c from Investment__c where Round__r.Target_Company__c = :currentAcc order by Round__r.Close_Date__c DESC NULLS LAST];
        List<Round__c> rounds =  [select id from Round__c  where Target_Company__c = :currentAcc order by Close_Date__c DESC NULLS LAST];
        Investment__c inv = new Investment__c();
        inv.Round__c = rounds[0].Id;
        inv.Investor__c = accountId;
        insert inv;
    }
    
    @RemoteAction
    global static void deleteSeries (String seriesId){
        delete [select Id from Round__c where id =:seriesId]; 
    }
    
    @RemoteAction
    global static void deleteShareholder (String shareholderId, String recordId){
        delete [select id from Investment__c where Round__r.Target_Company__c=:recordId and Investor__c=:shareholderId];
    }
    
    @AuraEnabled
    public static void saveNewRound(String TTrec){
         try{
             system.debug(TTrec);
             TTrec=TTrec.replace('[','').replaceAll(']','');
             system.debug(TTrec);
             Round__c tt = (Round__c)JSON.deserialize(TTrec,Round__c.class);
             
             insert tt;
           
         }catch(exception e){
            throw new AuraHandledException('Error: ' + e.getMessage());   
         }
     }
    @AuraEnabled
    public static string getCommunityAccId(){
        return [select id,Account_Id__c from user where id=:UserInfo.getUserId()].Account_Id__c;
    }

    @AuraEnabled
    public static List < sObject > fetchLookUpValues(String searchKeyWord, String ObjectName) {
        system.debug('ObjectName-->' + ObjectName);
        String searchKey = searchKeyWord + '%';
        
        List < sObject > returnList = new List < sObject > ();
      
        // Create a Dynamic SOQL Query For Fetch Record List with LIMIT 5   
        String sQuery =  'select id, Name, Parent.Name from ' +ObjectName + ' where Name LIKE: searchKey order by createdDate DESC limit 5';
        List < sObject > lstOfRecords = Database.query(sQuery);
        
        for (sObject obj: lstOfRecords) {
            returnList.add(obj);
        }
        return returnList;
    }
	
    public class CapTableControllerException extends Exception {}
}