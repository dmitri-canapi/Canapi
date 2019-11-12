public without sharing class AllianceAnnouncements {
	@AuraEnabled
    public static List<Alliance_Announcement__c> getNews() {
        return [SELECT Id, Body__c,Headline__c,Release_date__c FROM Alliance_Announcement__c 
                where Release_date__c <=: Datetime.now() and (Expiration_date__c >: Datetime.now() or Expiration_date__c  = null) order by Release_date__c desc LIMIT 50000];
    }
}