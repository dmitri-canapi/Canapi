global without sharing class AllianceContactsController {
    @AuraEnabled
    global static List<Contact> getContacts(){
        return [Select Id, Name,Title, Phone, Email, Account.Name from Contact where FTA__c = true order by name asc]; 
    }
}