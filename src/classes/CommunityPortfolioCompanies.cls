public without sharing class CommunityPortfolioCompanies {
    @AuraEnabled
    public static List<Account> getCompanies() {
        return [SELECT Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, PhotoUrl,PhotoUrl__c, Website, PhoneNumber__c  FROM Account  where RecordType.Name='Portfolio Company' LIMIT 50000];
    }

}