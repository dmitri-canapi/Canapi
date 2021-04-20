trigger UserContactTagAssociationTrigger on UserContactTagAssociation__c (after insert, after update, before delete, after delete) {

    Set <Id> contactIds = new Set <Id>();

    CollaborationGroup CTOgroup = [select Id from CollaborationGroup Where Name = 'CTO\'s Corner' limit 1];
    

    if (Trigger.IsInsert){
        Set <id> userIds = new Set <id>();
        Set <id> chiefOrTechUserIds = new Set <id>();
        Set <id> accIds = new Set <id>();
        list <Document__Share> dsList = new list <Document__Share>();
        
        for(UserContactTagAssociation__c assoc:Trigger.new) {
            if (assoc.User__c != null){
                userIds.add(assoc.User__c);

                if (assoc.Tag_Name__c == 'Chief' || assoc.Tag_Name__c == 'Technology' ){
                    chiefOrTechUserIds.add(assoc.User__c);
                }
            }
            if (assoc.Contact__c != null){
                contactIds.add(assoc.Contact__c);
            }
        }

        Set <id> CTOgroupUsers = new set <id>();
        for (CollaborationGroupMember cgm: [select memberId from CollaborationGroupMember where collaborationGroup.Name='CTO\'s Corner']){
            CTOgroupUsers.add(cgm.memberId);
        }
        //List <User> CTOusers = ;
        List<CollaborationGroupMember> listGroupMemberToInsert = new List<CollaborationGroupMember>(); 
    
        for (User u: [select id, name from user where id in: chiefOrTechUserIds and id in (select user__c from UserContactTagAssociation__c where Tag_Name__c = 'Chief') and id in  (select user__c from UserContactTagAssociation__c where Tag_Name__c ='Technology') and id NOT in: CTOgroupUsers]){
            CollaborationGroupMember gm = new CollaborationGroupMember();
            gm.collaborationGroupId = CTOgroup.Id;
            gm.memberId = u.Id;
            gm.NotificationFrequency = 'D';
            listGroupMemberToInsert.add(gm);
        }
        insert listGroupMemberToInsert;


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

    if(Trigger.IsUpdate){
        Set <id> chiefOrTechUserIds = new Set <id>();
        
        for(UserContactTagAssociation__c assoc:Trigger.new) {
            if (assoc.User__c != null){
                if (assoc.Tag_Name__c == 'Chief' || assoc.Tag_Name__c == 'Technology'){
                    chiefOrTechUserIds.add(assoc.User__c);
                }
            }
        }

        Set <id> CTOgroupUsers = new set <id>();
        for (CollaborationGroupMember cgm: [select memberId from CollaborationGroupMember where collaborationGroup.Name='CTO\'s Corner']){
            CTOgroupUsers.add(cgm.memberId);
        }
        List<CollaborationGroupMember> listGroupMemberToInsert = new List<CollaborationGroupMember>(); 
    
        for (User u: [select id, name from user where id in: chiefOrTechUserIds and id in (select user__c from UserContactTagAssociation__c where Tag_Name__c = 'Chief') and id in  (select user__c from UserContactTagAssociation__c where Tag_Name__c ='Technology') and id NOT in: CTOgroupUsers]){
            CollaborationGroupMember gm = new CollaborationGroupMember();
            gm.collaborationGroupId = CTOgroup.Id;
            gm.memberId = u.Id;
            gm.NotificationFrequency = 'D';
            listGroupMemberToInsert.add(gm);
        }
        insert listGroupMemberToInsert;

    }


    if (Trigger.IsDelete && Trigger.IsBefore){
        Set <id> userIds = new Set <id>();
        Set <id> chiefOrTechUserIds = new Set <id>();
        Set <id> accIds = new Set <id>();
        list <id> docIds = new list <id>();
        
        for(UserContactTagAssociation__c assoc:Trigger.old) {
            if (assoc.User__c != null){
                userIds.add(assoc.User__c);
                if (assoc.Tag_Name__c == 'Chief' || assoc.Tag_Name__c == 'Technology'){
                    chiefOrTechUserIds.add(assoc.User__c);
                }
            }
        }

        delete [select id from CollaborationGroupMember where memberId in: chiefOrTechUserIds and collaborationGroupId =: CTOgroup.Id and CollaborationRole != 'Admin'];

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



    if (Trigger.IsDelete && Trigger.IsAfter){
        for(UserContactTagAssociation__c assoc:Trigger.old) {
            if (assoc.Contact__c != null){
                contactIds.add(assoc.Contact__c);
            }
        }
    }

    if (Trigger.IsInsert || Trigger.IsDelete){
        if (contactIds.size() > 0){
            List <Contact> conts = [select id, (select UserContactTag__r.Name, UserContactTag__r.Function__c from UserContactTagAssociations__r order by UserContactTag__r.Function__c desc, UserContactTag__r.name asc) from Contact where id in: contactIds];

            for (Contact cont: conts){
                Set <String> funcTags = new Set <String>();
                Set <String> titleTags = new Set <String>();
                for (UserContactTagAssociation__c ucta :cont.UserContactTagAssociations__r ){
                    if (ucta.UserContactTag__r.Function__c == 'Function'){
                        funcTags.add(ucta.UserContactTag__r.Name);
                    } else {
                        titleTags.add(ucta.UserContactTag__r.Name);
                    }
                }
                cont.Function_Tags__c = String.join(new List<String>(funcTags), ';');
                cont.Title_Tags__c = String.join(new List<String>(titleTags), ';');
            }
            update conts;
        }
    }
    
}