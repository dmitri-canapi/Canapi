trigger UserContactTagAssociationTrigger on UserContactTagAssociation__c (after insert, before delete) {

    if (Trigger.IsInsert){
        Set <id> userIds = new Set <id>();
        Set <id> accIds = new Set <id>();
        list <Document__Share> dsList = new list <Document__Share>();
        
        for(UserContactTagAssociation__c assoc:Trigger.new) {
            if (assoc.User__c != null){
                userIds.add(assoc.User__c);
            }
        }

        List <User> usrs = [select id, AccountId from User where id in:userIds and id !=: userInfo.getUserId() and AccountId != null and Profile.Name = 'Community: Alliance Portal' and IsActive = true and id in (select User__c from UserContactTagAssociation__c where UserContactTag__r.Name = 'Finance')];
        for (User u: usrs){
            accIds.add(u.AccountId);
        }
        List <Document__c> docs = [Select id, OwnerId, Shared_With_Account__c from  Document__c where Shared_with_Users_from_this_account__c = true and Shared_With_Account__c in:  accIds];

        for (User u: usrs){
            for (Document__c doc : docs){   
                if (doc.OwnerId != u.Id && doc.Shared_With_Account__c == u.AccountId){
                    Document__Share ds = new Document__Share();
                    ds.ParentId = doc.Id;
                    ds.UserOrGroupId = u.Id;
                    ds.AccessLevel = 'Read';
                    dsList.add(ds);
                }
            }
        }
        insert dsList;
    }


    if (Trigger.IsDelete){
        Set <id> userIds = new Set <id>();
        Set <id> accIds = new Set <id>();
        list <id> docIds = new list <id>();
        
        for(UserContactTagAssociation__c assoc:Trigger.old) {
            if (assoc.User__c != null){
                userIds.add(assoc.User__c);
            }
        }

        List <User> usrs = [select id, AccountId from User where id in:userIds and id !=: userInfo.getUserId() and AccountId != null and Profile.Name = 'Community: Alliance Portal' and IsActive = true and id in (select User__c from UserContactTagAssociation__c where UserContactTag__r.Name = 'Finance')];
        for (User u: usrs){
            accIds.add(u.AccountId);
        }
        List <Document__c> docs = [Select id, OwnerId, Shared_With_Account__c from  Document__c where Shared_with_Users_from_this_account__c = true and Shared_With_Account__c in:  accIds];

        for (User u: usrs){
            for (Document__c doc : docs){   
                if (doc.OwnerId != u.Id && doc.Shared_With_Account__c == u.AccountId){
                    docIds.add(doc.Id);
                }
            }
        }
        delete [select id from Document__Share where ParentId in: docIds and RowCause='Manual' and UserOrGroupId in : userIds];
    }
    
}