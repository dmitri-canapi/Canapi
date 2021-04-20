public without sharing class FinancialsLogoController {
    @AuraEnabled
    public static Account getAccData() {
        String accId = [select id,Account_Id__c from user where id=:UserInfo.getUserId()].Account_Id__c;
        if (accId == null){
            accId = [select id from Account where Name = 'Canapi' limit 1].Id;
        }

       
        return [SELECT Id, Name,PhotoUrl__c,External_Logo__c,External_Logo2__c,External_Logo3__c  FROM Account  where id =:accId];
        
    }

}