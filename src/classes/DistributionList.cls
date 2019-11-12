public class DistributionList {
 	@AuraEnabled
    public static String getRecords(){
        List <Account> accList = new List <Account>();
        accList = [select id,name,
                   (select id, Commitment_Stage__c, Target_Commitment__c, Fund__r.name,Fund__r.Total_Commitment__c, Account__r.name from Commitments__r),
                   (select id, FirstName, LastName,Title, email,Account.Name from Contacts)
                  from Account where /*Id IN (SELECT Account__c FROM Commitment__c where Commitment_Stage__c='Interested' or Commitment_Stage__c='Verbal' or Commitment_Stage__c='Letter' or Commitment_Stage__c='Closed' or Commitment_Stage__c='Closing')
                   and */Id IN ( Select AccountId from Contact where Canapi_Role__c includes ('ALL_LPs')) order by name asc
                  ];
        return JSON.serialize(accList);
    }
}