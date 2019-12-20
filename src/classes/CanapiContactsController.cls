global without sharing class CanapiContactsController {
    @AuraEnabled
    global static List<Contact> getContacts(){
        return [Select Id, Name, Title, Phone, MobilePhone, Email, Account.Name, Account.External_Logo__c, Account.External_Logo2__c, Account.External_Logo3__c from Contact where Account.Name = 'Canapi' order by name asc]; 
    }
}