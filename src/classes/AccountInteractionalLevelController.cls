public without sharing class AccountInteractionalLevelController {
    @AuraEnabled
    public static Account fetchAcc(String recId){
        return [select recordType.Name, Account_Interaction_Level__c from account where id =: recId];
    }
}