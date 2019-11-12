public without sharing class CapTableController {

    public class CapTableData {
        @AuraEnabled
        public String companyName;
        @AuraEnabled
        public String companyDescription;
        @AuraEnabled
        public Decimal totalDollarsInvested;
        @AuraEnabled
        public Decimal totalSharesInvested;
        @AuraEnabled
        public List<Map<String, Object>> rounds = new List<Map<String, Object>>();
        @AuraEnabled
        public List<String> allRoundNames = new List<String>();
        @AuraEnabled
        public List<String> allRoundIds = new List<String>();
        @AuraEnabled
        public List<String> allRoundCharacters = new List<String>();
        @AuraEnabled
        public List<Decimal> allRoundTotalInvestedDollars = new List<Decimal>();
        @AuraEnabled
        public List<Decimal> allRoundTotalInvestedShares = new List<Decimal>();
        @AuraEnabled
        public Map<String, Decimal> roundNameToSharePriceMap = new Map<String, Decimal>();
        @AuraEnabled
		public List<Map<String, Object>> investments = new List<Map<String, Object>>();
    }
    
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
    @AuraEnabled
    public static void AllowEditingUpdate (String accountId, Boolean AllowEditing) {
        account a =  [select Id,Allow_edits_by_community_users__c from Account where id = :accountId];
        a.Allow_edits_by_community_users__c = AllowEditing;
        update a;
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
    
    @TestVisible
    private static void sortRoundRecords(List<Round__c> rounds) {
        List<String> orderedRoundNames = new List<String>();
        for (Schema.PicklistEntry pe : Round__c.Round__c.getDescribe().getPicklistValues()) {
            orderedRoundNames.add(pe.getValue());
        }
        
        // first bubble sort by Round
        for (Integer i=0; i<rounds.size()-1; i++) {
            for (Integer j=0; j<rounds.size()-1; j++) {
                if (orderedRoundNames.indexOf(rounds[j].Round__c) > orderedRoundNames.indexOf(rounds[j+1].Round__c)) {
                    // swap
                    Round__c tmp = rounds[j];
                    rounds[j] = rounds[j+1];
                    rounds[j+1] = tmp;
                }
            }
        }
        for (Round__c round : rounds) {
            System.debug(round.Round__c + round.Series_Type__c);
        }
        
        // Now bubble sort any groups of records with the same Round value.
        // Since everything is sorted by Round__c appropriately now, we use
        // an outer loop to grab the first record, then the inner loop goes
        // moves forward looking for records with the same Round__c, tallying
        // how many there are (numberInGroup).
        Integer numberInGroup = 0; // number of records with the same value for the current "Round__c"
        for (Integer i=0; i<rounds.size()-1; i+=numberInGroup) {
            numberInGroup = 1;  // there's always at least 1 in the group
            while (i+numberInGroup < rounds.size() && rounds[i].Round__c == rounds[i+numberInGroup].Round__c) {
                numberInGroup++;
            }
            
            // Mini-bubble sort of this group on the Series_Type__c value
            if (numberInGroup > 1) {
                for (Integer iterCount=0; iterCount<numberInGroup; iterCount++) {
                    for (Integer indexOffset=0; indexOffset<numberInGroup-1; indexOffset++) {
                        // use native array sort to compare - we could probably make this algorithm quicker
                        // and only call sort once, but in the interest of time we're doing it this way
                        List<String> sorted = new List<String> {
                            rounds[i+indexOffset].Series_Type__c,
                            rounds[i+indexOffset+1].Series_Type__c
                        };
                        sorted.sort();
                        List<String> unsorted = new List<String> {
                            rounds[i+indexOffset].Series_Type__c,
                            rounds[i+indexOffset+1].Series_Type__c
                        };
                        
                        if (sorted != unsorted) {
                            // swap
                            Round__c tmp = rounds[i+indexOffset];
                            rounds[i+indexOffset] = rounds[i+indexOffset+1];
                            rounds[i+indexOffset+1] = tmp;
                        }
                    }
                }
            }
        }
    }
    
    @AuraEnabled
    public static CapTableData getCapTableData(String accountId, String filterValue) {

		CapTableData capData = new CapTableData();
        List<Round__c> sortedRounds = [
            select Id,
                   Round__c,
                   Series_Type__c,
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
          //order by Announcement_Date__c,
            order by Close_Date__c ASC NULLS LAST,
                   Id asc
        ];
        //sortRoundRecords(sortedRounds);
        
        for (Round__c round : sortedRounds) {
            decimal postMV= 0;
            if (round.Total_Committed__c!=null){
                postMV = round.Total_Committed__c;
            }
             if (round.Pre_Money_Valuation__c!=null){
                postMV += round.Pre_Money_Valuation__c;
            }
            capData.rounds.add(new Map<String, Object> {
                'id' => round.Id,
                'name' => round.Round__c,
                'fullName' => round.Full_Name__c,
                'character' => round.Character_for_Cap_Table__c,
                'sharePrice' => round.Share_Price__c,
                'totalInvestedDollars' => round.Total_Committed__c,
                'totalInvestedShares' => round.Total_Invest_Shares__c,
                'targetAmount' => round.Target_Amount__c,
                'parValue' => round.Par_Value__c,
                'liquidationPreference' => round.Liquidation_Preference__c,
                'voting' => round.voting__c,
                'preMoneyValuation' => round.Pre_Money_Valuation__c,
                'CloseDate' => round.Close_Date__c,
                'postMoneyValuation' => postMV
            });
            capData.allRoundNames.add(round.Full_Name__c);
            capData.allRoundIds.add(round.Id);
            capData.allRoundCharacters.add(round.Character_for_Cap_Table__c);
            
            if (round.Share_Price__c!=null /*&& round.Share_Price__c!=0*/ && !round.Promote_Series__c){
                if (filterValue=='Voting'){
                	capData.allRoundTotalInvestedDollars.add((round.Share_Price__c*round.Total_Invest_Shares__c).setScale(0));
                } else if (filterValue=='Non-Voting'){
                    capData.allRoundTotalInvestedDollars.add((round.Total_Committed_NonVoting_Shares__c*round.Share_Price__c).setScale(0));
                } else {
                    capData.allRoundTotalInvestedDollars.add((round.Total_Committed_Sum_Shares__c*round.Share_Price__c).setScale(0));
                }
            } else {
            	capData.allRoundTotalInvestedDollars.add(round.Total_Committed__c);
            }
                        
            if (filterValue=='Voting'){
                capData.allRoundTotalInvestedShares.add(round.Total_Invest_Shares__c);
            } else if (filterValue=='Non-Voting'){
                capData.allRoundTotalInvestedShares.add(round.Total_Committed_NonVoting_Shares__c);
            } else {
                capData.allRoundTotalInvestedShares.add(round.Total_Committed_Sum_Shares__c);
            }
            capData.roundNameToSharePriceMap.put(round.Round__c, round.Share_Price__c);
        }
        
        List<Investment__c> investments = [
            select Id,
                   Investor__c,
                   Investor__r.Name,
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
          order by Investor__r.Name asc
        ];
        
        for (Investment__c currentInvestment : investments) {
            if (capData.companyName == null) {
                capData.companyName = currentInvestment.Round__r.Target_Company__r.Name;
                capData.companyDescription = currentInvestment.Round__r.Target_Company__r.Description;
                
                capData.totalDollarsInvested = 0;//currentInvestment.Round__r.Target_Company__r.Total_Dollars_Across_Rounds__c;    
                
                
                if (filterValue=='Voting'){
                	capData.totalSharesInvested = currentInvestment.Round__r.Target_Company__r.Total_Shares_Across_Rounds__c;
                } else if (filterValue=='Non-Voting'){
                    capData.totalSharesInvested = currentInvestment.Round__r.Target_Company__r.Total_NonVoting_Shares_Across_Series__c;
                } else {
                    capData.totalSharesInvested = currentInvestment.Round__r.Target_Company__r.Total_Sum_Shares_Across_Series__c;
                }
                
            }
            //capData.investments.add(currentInvestment);
            
            decimal amount=0;
            if (currentInvestment.Amount1__c!=null){
                amount=currentInvestment.Amount1__c;
            }
            
            decimal VS=0;
            decimal NVS=0;
            if (currentInvestment.Non_Voting_Shares__c!=null){
                NVS=currentInvestment.Non_Voting_Shares__c;
            }
            if (currentInvestment.Shares__c!=null){
                VS=currentInvestment.Shares__c;
            }
            if (currentInvestment.Round__r.Share_Price__c!=null /*&& currentInvestment.Round__r.Share_Price__c!=0*/ && !currentInvestment.Round__r.Promote_Series__c){
                if (filterValue=='Voting'){
                	amount = (VS*currentInvestment.Round__r.Share_Price__c).setScale(0);
                } else if (filterValue=='Non-Voting'){
                    amount = (NVS*currentInvestment.Round__r.Share_Price__c).setScale(0);
                } else {
                    amount = (currentInvestment.Shares1__c*currentInvestment.Round__r.Share_Price__c).setScale(0);
                }
            }
            capData.totalDollarsInvested +=amount;
            
            decimal perc = 0;
            if (filterValue=='Voting'){
                if (currentInvestment.Round__r.Total_Invest_Shares__c!=null && currentInvestment.Round__r.Total_Invest_Shares__c!=0 && currentInvestment.Shares__c!=null){
                    perc = currentInvestment.Shares__c / currentInvestment.Round__r.Total_Invest_Shares__c*100;
                }
             } else if (filterValue=='Non-Voting'){
             	if (currentInvestment.Round__r.Total_Committed_NonVoting_Shares__c!=null && currentInvestment.Round__r.Total_Committed_NonVoting_Shares__c!=0 && currentInvestment.Non_Voting_Shares__c!=null){
                    perc = currentInvestment.Non_Voting_Shares__c / currentInvestment.Round__r.Total_Committed_NonVoting_Shares__c*100;
                }
             } else {
                 perc = currentInvestment.Percentage_of_Round__c;
             }
            
            
            capData.investments.add(new Map<String, Object> {
                'investmentId' => currentInvestment.Id,
                'investorId' => currentInvestment.Investor__c,
                'investorName' => currentInvestment.Investor__r.Name,
                'seriesId' => currentInvestment.Round__c,
                'seriesName' => currentInvestment.Round__r.Full_Name__c,
                'seriesSharePrice' => currentInvestment.Round__r.Share_Price__c,
                'percentageOfSeries' => perc, //currentInvestment.Percentage_of_Round__c,
                'numberOfShares' => currentInvestment.Shares__c,
                'numberOfNVShares' => currentInvestment.Non_Voting_Shares__c,
                'sumOfShares' => currentInvestment.Shares1__c,
                'percentageOfShares' => currentInvestment.Percent_Voting__c,
                'totalDollarAmount' => amount//currentInvestment.Amount1__c
            });
        }
        System.debug('returning: ' + capData);
        return capData;
    }

    @AuraEnabled
    public static Decimal setDollarAmount(String investorId, String seriesId, Decimal amount,String filterValue) {
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
    
    @AuraEnabled
    public static void setShares(String investorId, String seriesId, Decimal VotingShare, Decimal NonVotingShare) {
        system.debug(investorId);
        system.debug(seriesId);
        system.debug(VotingShare);
        system.debug(NonVotingShare);
        List<Investment__c> investments = [select Id, Shares__c,Non_Voting_Shares__c, Amount1__c,Round__r.Share_Price__c, Round__r.Promote_Series__c from Investment__c where Investor__c = :investorId and Round__c = :seriesId];
        if (investments.size() > 1) {
            throw new CapTableControllerException(investments.size() + ' Investment records came back for the Investor/Series.  Expected only 1.');
        } else if (investments.size() == 1) {
            
            investments[0].Shares__c = VotingShare;
            investments[0].Non_Voting_Shares__c = NonVotingShare;
            if (investments[0].Round__r.Share_Price__c!=null && investments[0].Round__r.Share_Price__c!=0 && !investments[0].Round__r.Promote_Series__c){
            	investments[0].Amount1__c = ((VotingShare + NonVotingShare)*investments[0].Round__r.Share_Price__c).setScale(0);
            } else {
                investments[0].Amount1__c = (VotingShare + NonVotingShare).setScale(0);
            }

            update investments[0];
            
        } else {
            Round__c round = [select Share_Price__c, Promote_Series__c from Round__c where id=:seriesId];
            decimal amount = (VotingShare + NonVotingShare).setScale(0);
            if (round.Share_Price__c!=null && round.Share_Price__c!=0 && !round.Promote_Series__c){
                amount = ((VotingShare + NonVotingShare)*round.Share_Price__c).setScale(0);
            }
            
            insert new Investment__c(
                Investor__c = investorId,
                Round__c = seriesId,
                Shares__c = VotingShare,
                Non_Voting_Shares__c = NonVotingShare,
                Amount1__c = amount
            );
        }

    }
    
    @AuraEnabled
    public static void addShareholder(String accountId, String AccName, String currentAcc) {
        if (AccName!=null && AccName!=''){
            account a = new account (name=AccName);
            insert a;
            accountId=a.Id;
        }
        //List<Investment__c> investments = [ select Id,Round__c from Investment__c where Round__r.Target_Company__c = :currentAcc order by Round__r.Close_Date__c DESC NULLS LAST];
        List<Round__c> rounds =  [select id from Round__c  where Target_Company__c = :currentAcc order by Close_Date__c DESC NULLS LAST];
        Investment__c inv = new Investment__c();
        inv.Round__c = rounds[0].Id;
        inv.Investor__c = accountId;
        insert inv;
    }
    
    @AuraEnabled
    public static void deleteSeries (String seriesId){
        delete [select Id from Round__c where id =:seriesId]; 
    }
    
    @AuraEnabled
    public static void deleteShareholder (String shareholderId, String recordId){
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
	
    public class CapTableControllerException extends Exception {}
}