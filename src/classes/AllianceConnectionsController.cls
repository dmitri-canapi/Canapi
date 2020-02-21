global without sharing class AllianceConnectionsController {
    @AuraEnabled
    global static List<Contact> getContacts(String filter, String order){
        Set <id> userTagIds = new Set <id>();
        Set <Decimal> userTagFirstlevels = new Set <Decimal>();
        Set <Decimal> userTagDependentlevels = new Set <Decimal>();

        Set <Id> TitleTags = new Set <Id>();
        Set <Id> FunctionTags = new Set <Id>();
        for (UserContactTagAssociation__c tagAssoc: [select UserContactTag__c,UserContactTag__r.Hierarchy_Level__c,UserContactTag__r.Function__c from UserContactTagAssociation__c where User__c =: UserInfo.getUserId()]){
            if (tagAssoc.UserContactTag__r.Function__c == 'Title'){
                TitleTags.add(tagAssoc.UserContactTag__c);
            } else if (tagAssoc.UserContactTag__r.Function__c == 'Function'){
                FunctionTags.add(tagAssoc.UserContactTag__c);
            }
            /*userTagIds.add(tagAssoc.UserContactTag__c);
            if (tagAssoc.UserContactTag__r.Hierarchy_Level__c !=null) {
                userTagFirstlevels.add(tagAssoc.UserContactTag__r.Hierarchy_Level__c);
            }*/
        }
        /*for (Decimal level: userTagFirstlevels){
            userTagDependentlevels.add(level-1);
            userTagDependentlevels.add(level+1);
        }*/
        //userTagDependentlevels.addAll(userTagFirstlevels);
        
        /*Set <id> contactIds = new Set <id>();
        for (UserContactTagAssociation__c uca: [Select Contact__c from UserContactTagAssociation__c where 
            UserContactTag__c in: TitleTags or UserContactTag__c in: FunctionTags]){
                contactIds.add(uca.Contact__c);
        }*/

        String q ='Select Id, Name,Title, Phone, Email, Account.Name, Account.External_Logo__c, Account.External_Logo2__c, Account.External_Logo3__c, (select UserContactTag__c, UserContactTag__r.name from UserContactTagAssociations__r order by UserContactTag__r.Function__c desc) from Contact ';
        //q+= 'where id in: contactIds ';
        q+= 'where id in (select Contact__c from UserContactTagAssociation__c where UserContactTag__c in: TitleTags)';
        q+= ' and id in (select Contact__c from UserContactTagAssociation__c where UserContactTag__c in: FunctionTags)';
        if (filter != null && filter != '') q += 'and ' + order + ' like \'%' + filter + '%\'';
        q+= ' order by ' + order + ' asc nulls last';
        
        
        List <Contact> conts = Database.query(q);

        /*for (Contact c: conts){
            Set <Id> contactTags = new Set <Id>();
            Integer j = 0;
            while (j < c.UserContactTagAssociations__r.size()){

            //for (UserContactTagAssociation__c uta: c.UserContactTagAssociations__r){
                if (!contactTags.add(c.UserContactTagAssociations__r[j].UserContactTag__c)) {
                    c.UserContactTagAssociations__r.remove[j];
                } else {
                    j++;
                }
            }
        }*/
        return conts;
    }
}