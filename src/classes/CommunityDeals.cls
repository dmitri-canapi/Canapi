public without sharing class CommunityDeals {
	@AuraEnabled  
    public static List<Opportunity> getFilteredDeals(){
        List <Opportunity> opp = new List <Opportunity>();
        string accId = [select id, Account_Id__c from user where id =: userInfo.getUserId()].Account_Id__c;
        opp = [select id, Name,Amount,CloseDate,StageName,Probability,Type,LeadSource,AccountId,Account.Name, Owner.alias  from Opportunity where AccountId=:accId order by CreatedDate desc limit 1000];
        return opp;
    }
    
    @AuraEnabled
    public static map<String,String> getOppMap(String dealId){
        Map<String,String> DealObj = new Map<String,String>();
        Opportunity opp = [select Name, Owner.Name,Account.Name,CloseDate,Type,StageName,Campaign.Name,Probability,
                           Loss_Reason__c, Amount,Pass_Reason__c,Total_Raise__c,Lead_Investor__r.name,NextStep,LeadSource,
                           Description,CreatedDate,CreatedBy.Name,LastmodifiedDate,LastmodifiedBy.Name from Opportunity where id=:dealId];
        DealObj.put('Name',opp.Name);
        DealObj.put('OwnerId',opp.Owner.Name);
        DealObj.put('AccountName',opp.Account.Name);
        DealObj.put('CloseDate',String.ValueOf(opp.CloseDate));
        DealObj.put('Type',opp.Type);
        DealObj.put('StageName',opp.StageName);
        DealObj.put('CampaignName',opp.Campaign.Name);
        DealObj.put('Probability',String.ValueOf(opp.Probability));
        DealObj.put('Loss_Reason__c',opp.Loss_Reason__c);
        DealObj.put('Amount',String.ValueOf(opp.Amount));
        DealObj.put('Pass_Reason__c',opp.Pass_Reason__c);
        DealObj.put('Total_Raise__c',String.ValueOf(opp.Total_Raise__c));
        DealObj.put('Lead_Investor__c',opp.Lead_Investor__r.name);
        DealObj.put('NextStep',opp.NextStep);
        DealObj.put('LeadSource',opp.LeadSource);
        DealObj.put('Description',opp.Description);
        DealObj.put('CreatedBy',opp.CreatedBy.Name + ', ' + opp.CreatedDate);
        DealObj.put('LastmodifiedBy',opp.LastmodifiedBy.Name + ', ' + opp.LastmodifiedDate);
        
        
        return DealObj;
      }

}