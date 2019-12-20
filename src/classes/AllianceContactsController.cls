global without sharing class AllianceContactsController {
    @AuraEnabled
    global static List<Contact> getContacts(String filter, String order){
        String q ='Select Id, Name,Title, Phone, Email, Account.Name, Account.External_Logo__c, Account.External_Logo2__c, Account.External_Logo3__c from Contact where FTA__c = true ';
        if (filter != null && filter != '') q += 'and ' + order + ' like \'%' + filter + '%\'';
        q+= ' order by ' + order + ' asc nulls last';
        return Database.query(q);
        
    }
}