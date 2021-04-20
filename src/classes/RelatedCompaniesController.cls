public with sharing class RelatedCompaniesController {
    @AuraEnabled
    public static List<Account> getAccounts(String recId){
        return [select id, Name, Type, External_Logo__c, External_Logo2__c, External_Logo3__c from Account where parentid =: recId];
    }
}