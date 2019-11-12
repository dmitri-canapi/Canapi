global without sharing class CanapiContactsController {
    @AuraEnabled
    global static List<Contact> getContacts(){
        return [Select Id, Name, Title, Phone, MobilePhone, Email from Contact where Account.Name = 'Canapi' order by name asc]; 
    }
}