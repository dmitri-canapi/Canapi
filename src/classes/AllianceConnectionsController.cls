global without sharing class AllianceConnectionsController {
    @AuraEnabled
    global static List<Contact> getContacts(String filter, String order){
        Set <id> userTagIds = new Set <id>();
        Set <Decimal> userTagFirstlevels = new Set <Decimal>();
        Set <Decimal> userTagDependentlevels = new Set <Decimal>();
        for (UserContactTagAssociation__c tagAssoc: [select UserContactTag__c,UserContactTag__r.Hierarchy_Level__c from UserContactTagAssociation__c where User__c =: UserInfo.getUserId()]){
            userTagIds.add(tagAssoc.UserContactTag__c);
            if (tagAssoc.UserContactTag__r.Hierarchy_Level__c !=null) {
                userTagFirstlevels.add(tagAssoc.UserContactTag__r.Hierarchy_Level__c);
            }
        }
        for (Decimal level: userTagFirstlevels){
            userTagDependentlevels.add(level-1);
            userTagDependentlevels.add(level+1);
        }
        userTagDependentlevels.addAll(userTagFirstlevels);
        
        Set <id> contactIds = new Set <id>();
        for (UserContactTagAssociation__c uca: [Select Contact__c from UserContactTagAssociation__c where 
            UserContactTag__c in: userTagIds or UserContactTag__r.Hierarchy_Level__c in: userTagDependentlevels]){
                contactIds.add(uca.Contact__c);
        }

        String q ='Select Id, Name,Title, Phone, Email, Account.Name, Account.External_Logo__c, Account.External_Logo2__c, Account.External_Logo3__c from Contact ';
        q+= 'where id in: contactIds ';
        if (filter != null && filter != '') q += 'and ' + order + ' like \'%' + filter + '%\'';
        q+= ' order by ' + order + ' asc nulls last';
        return Database.query(q);
    }
}