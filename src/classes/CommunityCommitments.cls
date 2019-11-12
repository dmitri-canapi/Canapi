public class CommunityCommitments {
	@AuraEnabled  
    public static List<Commitment__c> getFilteredCommitments(String filterId){
        List <Commitment__c> comm = new List <Commitment__c>();
        try{
        string accId = [select id, Account_Id__c from user where id=:filterId].Account_Id__c;
        comm = [select id, name,Fund__c,Fund__r.name,Target_Commitment__c,Commitment_Stage__c,Funded_Amount__c  from Commitment__c where Account__c=:accId order by CreatedDate desc limit 1000];
        } catch(exception e){
            integer i = 0;
            i++;
            i++;
            i++;
        }
        
        return comm;
    }
}