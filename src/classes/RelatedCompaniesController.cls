public with sharing class RelatedCompaniesController {
    @AuraEnabled
    public static List<Related_Account__c> getAccounts(String recId){
        //return [select id, Name, Type, External_Logo__c, External_Logo2__c, External_Logo3__c from Account where id in (select Child__c from Related_Account__c where Parent__c =: recId)];
        return [select Relationship__c, Child__c, Child__r.Name, Child__r.External_Logo__c, Child__r.External_Logo2__c, Child__r.External_Logo3__c from Related_Account__c where Parent__c =: recId];
        
    }
}